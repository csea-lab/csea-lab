#!/usr/bin/env python3

"""
Class to organize and extract data from a NIFTI file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

from pathlib import Path
import nibabel


class Nifti():
    """
    Class to organize and extract data from a NIFTI file.

    Parameters
    ----------
    input_path : str or Path
        Path to the NIFTI file to be processed.

    Attributes
    ----------
    path : Path
        The path of the NIFTI file.
    nibabel_object : Nifti1Image object
        Nibabel's wrapper to access the nifti file.
    header : Nifti1Header object
        Nibabel's wrapper to access the nifti header.
    number_of_volumes : int
        The number of volumes contained in the image.
    repetition_time : float
        The repetition time of each volume. This equals 0 for anatomical scans.
    """

    def __init__(self, input_path):
        
        self.path = Path(input_path)
        self.nibabel_object = nibabel.load(self.path)
        self.header = self.nibabel_object.header
        self.number_of_volumes = self.header["slice_end"] - self.header["slice_start"] + 1
        self.repetition_time = self.header["pixdim"][4]
