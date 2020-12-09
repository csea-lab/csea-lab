#!/usr/bin/env python3

"""
Class to organize and extract data from a .vmrk file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com

"""

from pathlib import Path
import pandas
import re


class Vmrk():
    """
    Class to organize and extract data from a .vmrk file.


    Parameters
    ----------
    input_path : str or Path
        Path to the .vmrk file.


    Attributes
    ----------
    path : Path
        Path to the .vmrk file.
    dataframe : DataFrame
        DataFrame containing the values of the body of the .vmrk file.

    """

    ONSET_CODE = "S  2"
    FMRI_CODE = "R128"


    def __init__(self, input_path):

        self._parameters = locals()

        self.path = Path(input_path)
        self.dataframe = self._as_dataframe()


    def __repr__(self):
        """
        Defines how the class represents itself as a string. Useful for debugging in iPython.

        """

        parameter_string = ""
        for parameter, value in self._parameters.items():
            if parameter != "self":
                parameter_string += f"{parameter}={value}"

        return f"{__class__.__name__}({parameter_string})"


    def onsets(self) -> list:
        """
        Returns a list of onsets from the .vmrk file converted to seconds and adjusted to start time.

        """

        # Raw onsets stores our onsets unadjusted for start time or converted to seconds
        raw_onsets = []
        for i, code in enumerate(self.dataframe["Description"]):
            if code == self.ONSET_CODE:
                raw_onsets.append(float(self.dataframe["Position in data points"][i]))

        return [self._converted_to_seconds_and_adjusted_to_start_time(timing) for timing in raw_onsets]


    def raw_start_time(self) -> float:
        """
        Returns the raw time at which the fMRI began scanning.

        """

        for i, code in enumerate(self.dataframe["Description"]):
            if code == self.FMRI_CODE:
                return float(self.dataframe["Position in data points"][i])

        # Raise an error if we can't find the start time.
        raise LookupError("No fMRI start signal found.")


    def write_onsets_to(self, path):
        """
        A file of onsets converted to seconds and adjusted to the start time outputs into the target path.

        Very handy to get your stimulus onsets all in one place, lemme tell ya.

        """

        output_path = Path(path)

        with output_path.open(mode='w') as txt_file:
            txt_file.writelines((f"{onset}\n" for onset in self.onsets()))


    def _converted_to_seconds_and_adjusted_to_start_time(self, timing):
        """
        Converts a timing value into seconds and adjusts it to the start time.

        Each raw time is divided by 5000 to convert it to seconds. Also, the time list is adjusted to the
        time the fMRI began scanning.

        """
        
        raw_time = (timing - self.raw_start_time()) / 5000
        return (round(raw_time, 4))


    def header_string(self) -> str:
        """
        Returns the header of the vmrk file as a nice, big string.

        """

        line_list = self.path.read_text().splitlines()
        header_lines = [line for line in line_list if not re.search(pattern="Mk[0-9]+=", string=line)]
        return "\n".join(header_lines)


    def body_string(self) -> str:
        """
        Returns the body of the vmrk file as a nice, big string without the header.

        """

        line_list = self.path.read_text().splitlines()
        body_lines = [line for line in line_list if re.search(pattern=r"Mk[0-9]+=", string=line)]
        return "\n".join(body_lines)


    def column_names(self) -> list:
        """
        Returns the name of each column in the .vmrk file as defined in the header.

        Includes one extra column named "Special" that catches any dangling bits of data appended to the end
        of the .vmrk lines.

        """

        return re.findall(pattern=r"(?<=\<).+?(?=\>)", string=self.header_string()) + ["Special"]


    def _as_dataframe(self) -> pandas.DataFrame:
        """
        Reads the .vmrk file and returns it as a fresh, clean DataFrame.

        Columns are numbered in order. Rows are also numbered in order.

        """

        # Format our data into a clean list of lists.
        line_list = [line.replace("Mk", "") for line in self.body_string().splitlines()]
        split_line_list = [re.split(pattern="[,=]", string=line) for line in line_list]

        # From the list of lists birth a glorious DataFrame with column names extracted from the header.
        return pandas.DataFrame(split_line_list, columns=self.column_names())
