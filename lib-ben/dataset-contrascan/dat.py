#!/usr/bin/env python3

"""
Class to organize and extract data from a .dat file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com

"""

from pathlib import Path
import pandas
from reference import with_whitespace_trimmed


class Dat():
    """
    Class to organize and extract data from a .dat file.


    Parameters
    ----------
    input_path : str or Path
        Path to the .dat file to be processed.


    Attributes
    ----------
    path : Path
        Path to the .dat file.

    """

    def __init__(self, input_path):

        self.path = Path(input_path)
        self.dataframe = self._as_dataframe()


    def durations(self) -> list:
        """
        Returns a list of durations extracted from the .dat file.

        Automatically converts times into seconds.

        """

        # Get raw durations from the last column in the DataFrame.
        raw_durations = self.dataframe[self.dataframe.columns[-1]]

        # Clean the raw durations into standard float numbers, then return them.
        return [float(duration) for duration in raw_durations]


    def average_duration(self) -> float:
        """
        Returns the average stimulus duration recorded in the .dat file.

        """

        return sum(self.durations()) / len(self.durations())


    def _as_dataframe(self) -> pandas.DataFrame:
        """
        Reads the .dat file and returns it as a fresh, clean DataFrame.

        Columns are numbered in order. Rows are also numbered in order.

        """

        # Format our data into a dewhitespaced list of lists
        line_list = self.path.read_text().splitlines()
        dewhitespaced_line_list = [with_whitespace_trimmed(line) for line in line_list]
        split_line_list = [line.split() for line in dewhitespaced_line_list]

        # Return the list of lists as a glorious DataFrame
        return pandas.DataFrame(split_line_list)
