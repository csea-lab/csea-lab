"""
A class to help organize and extract data from NIFTI files.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
import nibabel

class Nifti():

    def __init__(self, input_path):
        
        self.path = pathlib.Path(input_path)
        self.file = nibabel.load(input_path)
        self.header = self.file.header
        self.slice_count = self.header["slice_end"] - self.header["slice_start"] + 1