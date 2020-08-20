"""
Class to organize and extract data from a NIFTI file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
import nibabel

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

    def count_volumes(self):
        """
        Returns the number of volumes in the NIFTI file.
        """

        return self.header()["slice_end"] - self.header()["slice_start"] + 1