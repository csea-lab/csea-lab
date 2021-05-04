#!/usr/bin/env python3
"""
Contains a class to use an atlas to look up your location inside a brain.

Created 2/8/2021 by Benjamin Velie.
"""

import templateflow.api
import pandas
import nibabel
import numpy
from functools import cached_property


class Atlas():
    """
    Looks up atlas coordinates for you. All coordinates are in voxel space, NOT scanner space.
    Your data MUST be aligned and resampled to the 1mm MNI152NLin2009cAsym brain.

    You may use the lookup like a Python dictionary if you'd like. For example,

    >>> coordinate_lookup = Atlas()
    >>> print(coordinate_lookup[100, 100, 100])

    prints the following:

    'Right Cerebral White Matter'
    """
    def __init__(self):
        pass

    def __getitem__(self, thruple):
        if len(thruple) != 3:
            raise TypeError("You must pass a tuple with exactly 3 coordinates, i.e. (x, y, z)")
        return self.translate_coordinates(thruple[0], thruple[1], thruple[2])

    @cached_property
    def atlas_array(self):
        """
        Returns an array. Contains an atlas location at each coordinate in the array.
        """
        lookup_dict = self.get_lookup_dict()
        nifti_path = self.get_MNI_dir() / "tpl-MNI152NLin2009cAsym_res-01_desc-carpet_dseg.nii.gz"
        image = nibabel.load(nifti_path)
        unsorted_array = image.get_fdata()
        return self._replace_using_dict(unsorted_array, lookup_dict)

    def mask_image(self, image, region: str) -> numpy.ma.masked_array:
        """
        Given a NiBabel image, returns a masked array for a region of interest.
        
        Image must be in the same space as the atlas.
        """
        image_array = image.get_fdata()
        number_of_dimensions = image_array.ndim

        assert number_of_dimensions == 3 or number_of_dimensions == 4, "Image must be 3-dimensional or 4-dimensional."

        if number_of_dimensions == 3:
            mask = self.get_3d_mask(region)
        else:
            fourth_dimension_length=image_array.shape[3]
            mask = self.get_4d_mask(region, fourth_dimension_length)

        masked_image = numpy.ma.masked_array(image_array, mask=mask)

        return masked_image

    def get_4d_mask(self, region: str, fourth_dimension_length: int) -> numpy.array:
        """
        Returns a 4d array where each coordinate of the specified region equals False, and all other values are True.

        Use this for atlasing EPI images or other 4d structures.
        """
        third_dimensional_array = self.get_3d_mask(region)
        fourth_dimensional_array = numpy.repeat(third_dimensional_array[..., numpy.newaxis], fourth_dimension_length, axis=-1)
        
        return fourth_dimensional_array

    def get_3d_mask(self, region: str) -> numpy.array:
        """
        Returns a 3d array where each coordinate of the specified region is False, and all other values are True.
        """

        mask = self.atlas_array != region

        return mask

    def translate_coordinates(self, x, y, z):
        """
        Given X, Y, Z coordinates, returns the name of the spot in the brain.
        """
        return self.atlas_array[x, y, z]

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
