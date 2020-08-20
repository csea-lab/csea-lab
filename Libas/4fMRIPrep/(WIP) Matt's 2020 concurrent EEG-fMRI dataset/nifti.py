"""
Class to organize and extract data from a NIFTI file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
import nibabel
import re


class Nifti():
    """
    Class to organize and extract data from a NIFTI file.

    Parameters
    ----------
    input_path : str or Path
        Path to the NIFTI file to be processed.

    ...

    Attributes
    ----------
    path : Path
        The path of the NIFTI file.
    """

    def __init__(self, input_path):
        
        self.path = pathlib.Path(input_path)

    
    def load(self):
        """
        Returns the complete NIFTI file.
        """

        return nibabel.load(self.path)


    def header(self):
        """
        Returns the header of the NIFTI file.
        """

        return nibabel.load(self.path).header


    def count_volumes(self) -> int:
        """
        Returns the number of volumes in the NIFTI file.
        """

        return self.header()["slice_end"] - self.header()["slice_start"] + 1


    def tasks(self) -> list:
        """
        Returns a list of all tasks found in the filename.

        Note that this only works if the file is named in BIDS convention.
        Returns [] if no tasks found.
        """

        return re.findall(r"task-(.+)_", self.path.stem)


    def subject(self) -> list:
        """
        If the file is named according to BIDS, returns the subject's name.

        Returns "None" if no subject ID found.
        """
        
        potential_subject_ids = re.findall(r"sub-(\d+)", str(self.path))

        try:
            subject_id = potential_subject_ids[-1]
        except IndexError:
            subject_id = None

        return subject_id