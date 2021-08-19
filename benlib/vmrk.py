#!/usr/bin/env python3
"""
Class to organize and extract data from a .vmrk file.

Created 8/20/2020 by Ben Velie.
Last updated 5/20/2021 by Ben Velie.
"""

from pathlib import Path
import pandas
import re
from dataclasses import dataclass
from os import PathLike
from functools import cached_property
from typing import List

@dataclass
class Vmrk():
    """
    Class to organize and extract data from a .vmrk file.

    Parameters
    ----------
    input_path : str or Path
        Path to a .vmrk file.

    Attributes
    ----------
    path : Path
        Path to a .vmrk file.
    dataframe : DataFrame
        DataFrame containing the values of the body of the .vmrk file.
    """
    path: PathLike
    ONSET_CODE = "S  2"
    FMRI_CODE = "R128"

    def __post_init__(self):
        self.path = Path(self.path).absolute()

    @cached_property
    def dataframe(self) -> pandas.DataFrame:
        """
        Reads the .vmrk file and returns it as a fresh, clean DataFrame.

        Columns are numbered in order. Rows are also numbered in order.
        """

        # Format our data into a clean list of lists.
        line_list = [line.replace("Mk", "") for line in self.body_string.splitlines()]
        split_line_list = [re.split(pattern="[,=]", string=line) for line in line_list]

        # From the list of lists birth a glorious DataFrame with column names extracted from the header.
        dataframe = pandas.DataFrame(split_line_list, columns=self.column_names)

        return dataframe

    @cached_property
    def onsets(self) -> List:
        """
        Returns a list of onsets from the .vmrk file converted to seconds and adjusted to start time.
        """

        # Raw onsets stores our onsets unadjusted for start time or converted to seconds
        raw_onsets = []
        for i, code in enumerate(self.dataframe["Description"]):
            if code == self.ONSET_CODE:
                raw_onsets.append(float(self.dataframe["Position in data points"][i]))

        return [self._converted_to_seconds_and_adjusted_to_start_time(timing) for timing in raw_onsets]

    @cached_property
    def raw_start_time(self) -> float:
        """
        Returns the raw time at which the fMRI began scanning.
        """

        for i, code in enumerate(self.dataframe["Description"]):
            if code == self.FMRI_CODE:
                return float(self.dataframe["Position in data points"][i])

        # Raise an error if we can't find the start time.
        raise LookupError("No fMRI start signal found.")

    @cached_property
    def header_string(self) -> str:
        """
        Returns the header of the vmrk file as a nice, big string.

        """

        line_list = self.path.read_text().splitlines()
        header_lines = [line for line in line_list if not re.search(pattern="Mk[0-9]+=", string=line)]
        return "\n".join(header_lines)

    @cached_property
    def body_string(self) -> str:
        """
        Returns the body of the vmrk file as a nice, big string without the header.

        """

        line_list = self.path.read_text().splitlines()
        body_lines = [line for line in line_list if re.search(pattern=r"Mk[0-9]+=", string=line)]
        return "\n".join(body_lines)

    @cached_property
    def column_names(self) -> list:
        """
        Returns the name of each column in the .vmrk file as defined in the header.

        Includes one extra column named "Special" that catches any dangling bits of data appended to the end
        of the .vmrk lines.
        """

        return re.findall(pattern=r"(?<=\<).+?(?=\>)", string=self.header_string) + ["Special"]

    def write_onsets_to(self, path: PathLike, add_to_onsets: float=0):
        """
        A file of onsets converted to seconds and adjusted to the start time outputs into the target path.

        You may also optionally specify a value for add_to_onsets that will then be added to all onsets.

        Very handy to get your stimulus onsets all in one place, lemme tell ya.
        """

        output_path = Path(path)

        with output_path.open(mode='w') as txt_file:
            txt_file.writelines((f"{onset + add_to_onsets}\n" for onset in self.onsets))

    def _converted_to_seconds_and_adjusted_to_start_time(self, timing):
        """
        Converts a timing value into seconds and adjusts it to the start time.

        Each raw time is divided by 5000 to convert it to seconds. Also, the time list is adjusted to the
        time the fMRI began scanning.
        """
        
        raw_time = (timing - self.raw_start_time) / 5000
        return (round(raw_time, 4))
