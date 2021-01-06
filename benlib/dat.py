#!/usr/bin/env python3

"""
Class to organize and extract data from a .dat file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

from pathlib import Path
import pandas


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
    dataframe : DataFrame
        DataFrame containing each value of the .dat table. Rows and columns are numbered from 0 onward.
    """

    def __init__(self, input_path):

        self.path = Path(input_path)
        self.dataframe = self._as_dataframe()
        self.durations = self._durations()
        self.average_duration = sum(self.durations) / len(self.durations)
        self.trial_codes = list(self.dataframe[self.dataframe.columns[2]])


    def _durations(self) -> list:
        """
        Returns a list of durations extracted from the .dat file.

        Automatically converts times into seconds.
        """

        raw_durations = self.dataframe[self.dataframe.columns[3]]

        # Clean the raw durations into standard float numbers, then return them.
        return [float(duration) for duration in raw_durations]


    def _as_dataframe(self) -> pandas.DataFrame:
        """
        Reads the .dat file and returns it as a fresh, clean DataFrame.

        Columns are numbered in order. Rows are also numbered in order.
        """

        # Format our data into a dewhitespaced list of lists
        line_list = self.path.read_text().splitlines()
        dewhitespaced_line_list = [" ".join(line.rstrip().split()) for line in line_list]
        split_line_list = [line.split() for line in dewhitespaced_line_list]

        # Return the list of lists as a glorious DataFrame
        return pandas.DataFrame(split_line_list)
