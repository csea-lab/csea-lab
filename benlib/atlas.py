#!/usr/bin/env python3
"""
Contains a class to use an atlas to look up your location inside a brain using an atlas.

Created 2/8/2021 by Benjamin Velie.
"""

import templateflow.api
from pathlib import Path
import pandas
import nibabel
import numpy


class Atlas():
    """
    Looks up atlas coordinates for you. Currently uses the MNI152NLin2009cAsym brain.
    This is NOT meant to work with the AFNI viewer. This coordinate system is for the matrices you
    get by extracting raw data from nifti files.

    Use the lookup just like a Python dictionary. For example,

    >>> coordinate_lookup = Atlas()
    >>> print(coordinate_lookup[100, 100, 100])

    prints the following:

    'Right Cerebral White Matter'
    """
    def __init__(self):
        self.atlas_array = self.get_atlas_array()


    def __getitem__(self, thruple):
        if len(thruple) != 3:
            raise TypeError("You must pass a tuple with exactly 3 coordinates, i.e. (x, y, z)")
        return self.translate_coordinates(thruple[0], thruple[1], thruple[2])


    def get_4d_region(self, region: str, fourth_dimension_length: int):
        """
        Returns a 4d array where each coordinate of the specified region equals 1, and all other values are the numpy null value.

        Use this for atlasing EPI images or other 4d structures.
        """
        third_dimensional_array = self.get_region(region)
        fourth_dimensional_array = numpy.repeat(third_dimensional_array[..., numpy.newaxis], fourth_dimension_length, axis=-1)

        print(f"4d atlas of {region}:")
        print(fourth_dimensional_array)
        print(f"Shape of 4d atlas of {region}: {fourth_dimensional_array.shape}")
        
        return fourth_dimensional_array


    def get_region(self, region: str):
        """
        Returns a 3d array where each coordinate of the specified region equals 1, and all other values are the numpy null value.
        """
        working_array = self.atlas_array.copy()
        working_array[working_array != region] = numpy.NaN
        working_array[working_array == region] = 1

        print(f"3d atlas of {region}:")
        print(working_array)
        print(f"Shape of 3d atlas of {region}: {working_array.shape}")

        return working_array


    def translate_coordinates(self, x, y, z):
        """
        Given X, Y, Z coordinates, returns the name of the spot in the brain.
        """
        return self.atlas_array[x, y, z]


    def get_atlas_array(self):
        """
        Returns an array. Contains an atlas location at each coordinate in the array.
        """
        lookup_dict = self.get_lookup_dict()
        nifti_path = self.get_MNI_dir() / "tpl-MNI152NLin2009cAsym_res-01_desc-carpet_dseg.nii.gz"
        image = nibabel.load(nifti_path)
        unsorted_array = image.get_fdata()
        return self._replace_using_dict(unsorted_array, lookup_dict)


    def _replace_using_dict(self, array, dictionary):
        """
        Replace all keys in target array with their specified values.
        """
        # Extract out keys and values
        keys = numpy.array(list(dictionary.keys()))
        values = numpy.array(list(dictionary.values()))

        # Get argsort indices
        sidx = keys.argsort()

        key_sort = keys[sidx]
        value_sort = values[sidx]
        return value_sort[numpy.searchsorted(key_sort, array)]


    def get_lookup_dict(self):
        """
        Returns a dict containing the code for each area of the brain recorded in 
        {MNI_dir}/"tpl-MNI152NLin2009cAsym_desc-carpet_dseg.tsv"

        Each key is an index, and each value is a brain region.
        """
        MNI_dir = self.get_MNI_dir()
        tsv_lookup = MNI_dir / "tpl-MNI152NLin2009cAsym_desc-carpet_dseg.tsv"
        dataframe_lookup = pandas.read_csv(tsv_lookup, delimiter="\t")
        return dict(zip(dataframe_lookup["index"], dataframe_lookup["name"]))


    def get_MNI_dir(self):
        """
        Uses templateflow to download MNI brain stuff. Returns directory in which it's downloaded.
        """
        return templateflow.api.get("MNI152NLin2009cAsym")[0].parent
