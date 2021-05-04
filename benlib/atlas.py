#!/usr/bin/env python3
"""
Contains a class to use an atlas to look up your location inside a brain.

Created 2/8/2021 by Benjamin Velie.
"""

from pathlib import Path
from typing import Dict, Tuple
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
    >>> print(coordinate_lookup[(100, 100, 100)])

    prints the following:

    'Right Cerebral White Matter'
    """
    def __init__(self):
        pass

    def __getitem__(self, thruple: Tuple[int, int, int]) -> str:
        assert len(thruple) == 3, "You must pass a tuple with exactly 3 coordinates, i.e. (x, y, z)"
        x, y, z = thruple
        return self.translation_array[x, y, z]

    @cached_property
    def _image(self) -> nibabel.nifti1.Nifti1Image:
        """
        Returns raw atlas image to be translated.
        """
        nifti_path = self._MNI_dir / "tpl-MNI152NLin2009cAsym_res-01_desc-carpet_dseg.nii.gz"
        return nibabel.load(nifti_path)
    
    @cached_property
    def _translation_dictionary(self) -> Dict[int, str]:
        """
        Returns a dict containing the code for each area of the brain recorded in 
        {MNI_dir}/"tpl-MNI152NLin2009cAsym_desc-carpet_dseg.tsv"

        Each key is an index, and each value is a brain region.
        """
        tsv_lookup = self._MNI_dir / "tpl-MNI152NLin2009cAsym_desc-carpet_dseg.tsv"
        dataframe_lookup = pandas.read_csv(tsv_lookup, delimiter="\t")
        return dict(zip(dataframe_lookup["index"], dataframe_lookup["name"]))

    @cached_property
    def _MNI_dir(self) -> Path:
        """
        Uses templateflow to download MNI brain stuff. Returns directory in which it's downloaded.
        """
        return templateflow.api.get("MNI152NLin2009cAsym")[0].parent

    @cached_property
    def translation_array(self) -> numpy.array:
        """
        Returns an array. Contains an atlas location at each coordinate in the array.
        """
        untranslated_array = numpy.asarray(self._image.dataobj).astype(int)
        return self._replace_using_dict(untranslated_array, self._translation_dictionary)

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

    def _replace_using_dict(self, array: numpy.array, dictionary: Dict) -> numpy.array:
        """
        Replace all keys in target array with their specified values.
        """
        keys = numpy.array(list(dictionary.keys()))
        values = numpy.array(list(dictionary.values()))

        mapping_array = numpy.zeros(keys.max()+1, dtype=values.dtype)
        mapping_array[keys] = values

        return mapping_array[array]
