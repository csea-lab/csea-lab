"""
Class to organize and extract data from a .vmrk file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib


class Vmrk():
    """
    Class to organize and extract data from a .vmrk file.

    Parameters
    ----------
    input_path : str or Path
        Path to the .vmrk file.

    ...

    Attributes
    ----------
    path : Path
        Path to the .vmrk file.
    raw_text : str
        Raw text extracted from the .vmrk file.
    """

    ONSET_CODE = "S  2"
    FMRI_CODE = "R128"

    def __init__(self, input_path):

        self.path = pathlib.Path(input_path)


    def timings(self) -> list:
        """
        Returns a list of timings from the .vmrk file.

        Automatically converts times into seconds and adjusts them to the specified
        start time.
        """

        raw_timings = self._raw_timings()

        return self._clean_timings(raw_timings)

    
    def start_time(self) -> float:
        """
        Returns the time at which the fMRI began scanning.
        """

        for line in self.line_list():
            if self.FMRI_CODE in line:

                return self._get_timing(line) / 5000

    
    def line_list(self) -> list:
        """
        Returns the .vmrk file as a list of lines.
        """

        return self.path.read_text().splitlines()
    

    def output_timings(self, output_dir_path):
        """
        Outputs a txt file of timings into the specified directory.
        """

        output_dir_path = pathlib.Path(output_dir_path)
        txt_path = output_dir_path / f"{self.path.stem}_onsets.txt"

        formatted_timings = (f"{str(timing)}\n" for timing in self.timings())

        with txt_path.open(mode='w') as txt_file:
            txt_file.writelines(formatted_timings)


    def raw_text(self):
        """
        Returns the raw text extracted from the file.
        """

        return self.path.read_text()


    def _clean_timings(self, raw_timings: list) -> list:
        """
        Converts a list of raw times into clean times.

        Each raw time is divided by 5000 to convert it to seconds. Also, the time list is adjusted to the
        time the fMRI began scanning.
        """

        clean_timings = []

        for raw_time in raw_timings:
            time = raw_time / 5000 - self.start_time()
            clean_timings.append(time)

        return clean_timings


    def _raw_timings(self) -> list:
        """
        Returns a list of all raw stimulus onset timings.

        Note that the times must be further cleaned.
        """

        lines = self.line_list()
        raw_timings = []

        for line in lines:
            if self.ONSET_CODE in line:
                raw_time = self._get_timing(line)
                raw_timings.append(raw_time)

        return raw_timings


    def _get_timing(self, line: str) -> str:
        """
        Returns the stimulus timing from a line of text in the .vmrk file.
        """

        return float(line.split(",")[2])