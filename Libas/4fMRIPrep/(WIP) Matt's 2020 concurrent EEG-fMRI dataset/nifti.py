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
    file : nibabel Nifti1Image
        The NIFTI file loaded with nibabel.
    header : nibabel Nifti1Header
        The header of the NIFTI file.
    volume_count : int
        The number of volumes in the NIFTI file.
    """

    def __init__(self, input_path):
        
        self.path = pathlib.Path(input_path)
        self.file = nibabel.load(input_path)
        self.header = self.file.header
        self.volume_count = self.header["slice_end"] - self.header["slice_start"] + 1