"""
Class to organize and extract data from a .dat file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib


class Dat():
    """
    Class to organize and extract data from a NIFTI file.

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

        self.path = pathlib.Path(input_path)


    def durations(self) -> list:
        """
        Returns a list of durations extracted from the .dat file.

        Automatically converts times into seconds.
        """

        raw_durations = self._raw_durations()

        return self._clean_durations(raw_durations)


    def line_list(self) -> list:
        """
        Returns the .dat file as a list of lines.
        """

        return self.path.read_text().splitlines()


    def average_duration(self) -> float:
        """
        Returns the average stimulus duration recorded in the .dat file.
        """

        return sum(self.durations()) / len(self.durations())


    def _clean_durations(self, raw_durations: list) -> list:
        """
        Converts a list of raw durations into clean durations.

        Each raw duration is converted from scientific notation to a float.
        """

        clean_durations = []

        for raw_duration in raw_durations:
            duration = float(raw_duration)
            clean_durations.append(duration)

        return clean_durations


    def _raw_durations(self) -> list:
        """
        Returns a list of all raw durations from the .dat file.

        Note that the durations must be further cleaned.
        """

        raw_durations = []

        for line in self.line_list():
            raw_duration = line.split(" ")[4]
            raw_durations.append(raw_duration)

        return raw_durations