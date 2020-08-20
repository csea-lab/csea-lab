"""
Class to organize and extract data from an fMRI settings file.

Created 8/20/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
from copy import deepcopy


class Settings():

    """
    Class to organize data extracted from an fMRI settings file.

    Parameters
    ----------
    input_path : str or Path
        Path to the fMRI settings file to be processed.

    ...

    Attributes
    ----------
    path : Path
        The path of the NIFTI file.
    raw : str
        The raw text extracted from the file.
    dict : dict
        A dictionary of clean info extracted from the file.
    """

    _SUBSETTING_FLAG = "!@#SUBSETTING#@!"

    def __init__(self, input_path):
        
        self.path = pathlib.Path(input_path)
        self.raw_text = self.path.read_text()
        self.dict = self.get_settings_dict()


    def get_settings_dict(self) -> dict:
        """
        Returns a dictionary of each setting in the file and its value. Subvalues are stored in sub-dictionaries.

        Suppose you wanted to access setting X. It'll be equal to DICTNAME["X"]["value"].
        Suppose you wanted to access subvalue Y for setting X. It'll be equal to
        DICTNAME["X"]["subvalues"]["Y"].
        """

        # Get the target file as a raw list of tuples.
        raw_keys_and_values = self._get_raw_keys_and_values()

        # Clean raw keys and values but append a subsetting flag to each subsetting tuple.
        flagged_keys_and_values = self._clean_raw_keys_and_values(raw_keys_and_values)
    
        # Get a dict from our keys and values list
        return self._dictify(flagged_keys_and_values)


    def get_repetition_time(self):
        """
        Returns the repetition time (in seconds) extracted from the target settings file.
        """

        TR_in_ms = self.dict["TR"]["subvalues"]["(ms)"]

        TR = float(TR_in_ms[0]) / 1000

        return TR


    def _dictify(self, flagged_keys_and_values) -> dict:
        """
        Returns a properly formatted dict from a list of flagged keys and values.
        """

        # Get all our not subsettings settings into a dict.
        settings_dict = {key: {"value": value, "subvalues": {}} for (key, value) in flagged_keys_and_values if not self._is_subsetting(key)}

        for i, tuple in enumerate(flagged_keys_and_values):
            if self._is_subsetting(tuple[0]):

                # Find corresponding setting.
                setting_key = ""
                for setting_tuple in reversed(flagged_keys_and_values[0:i]):
                    if not self._is_subsetting(setting_tuple[0]):
                        setting_key = setting_tuple[0]
                        break

                # Remove flags from subsetting.
                deflagged_key = tuple[0].replace(self._SUBSETTING_FLAG, "")
                deflagged_value = tuple[1].replace(self._SUBSETTING_FLAG, "")

                # Update subsettings dict for the setting
                settings_dict[setting_key]["subvalues"][deflagged_key] = [deflagged_value]

        return settings_dict


    def _get_raw_keys_and_values(self) -> list:
        """
        Returns a list of raw key:value pairs stored in tuples.
        """

        lines = self.path.read_text().splitlines()

        raw_keys, raw_tuples = self._split_keys_and_values(lines)

        return self._merge(raw_keys,raw_tuples)


    def _split_keys_and_values(self, raw_keys_and_values: list) -> tuple: 

        """
        Splits a list of raw keys and values into a raw keys list and a raw values list.
        """

        raw_keys = []
        raw_values = []

        for pair in raw_keys_and_values:
            split_pair = pair.split("=")
            raw_keys.append(split_pair[0])
            raw_values.append(split_pair[1])

        return raw_keys, raw_values


    def _clean_raw_keys_and_values(self, raw_keys_and_values: list) -> list:
        """
        Returns a list of cleaned keys and values that are flagged as settings or subsettings.
        """

        depunctuated_raw_keys_and_values = self._remove_unwanted_punctuation(raw_keys_and_values)

        flagged_keys_and_values = self._flag_and_dewhitespace(depunctuated_raw_keys_and_values)

        return flagged_keys_and_values


    def _is_subsetting(self, string: str) -> bool:
        """
        Returns true if a string is a subsetting.

        A string is a subsetting if it begins with an empty space OR it
        contains the subsetting flag.
        """

        return string[0:1] == " " or self._SUBSETTING_FLAG in string


    def _remove_unwanted_punctuation(self, raw_keys_and_values) -> list:
        """
        Removes unwanted punctuation from a list of key-value tuples.
        """
    
        keys_and_values = deepcopy(raw_keys_and_values)

        unwanted_punctuation = '";'

        for character in unwanted_punctuation:
            keys_and_values = [(key.replace(character, ""), value.replace(character, "")) for (key, value) in keys_and_values]

        return keys_and_values


    def _flag_and_dewhitespace(self, raw_keys_and_values) -> list:
        """
        Returns a list of settings tuples with extra whitespace removed and labelled subsettings.
        """
    
        keys_and_values = deepcopy(raw_keys_and_values)

        # Remove all whitespace from right side of keys and values
        right_dewhitespaced_keys_and_values = [(key.rstrip(), value.rstrip()) for (key, value) in keys_and_values]

        # Add the subsetting flag to the end of each key and value where the value is a subsetting
        flagged_keys_and_values = [(key + self._SUBSETTING_FLAG, value + self._SUBSETTING_FLAG) if self._is_subsetting(key) else (key, value) for (key, value) in right_dewhitespaced_keys_and_values]

        # Strip all whitespace from left side of keys and values now
        finished_keys_and_values = [(key.lstrip(), value.lstrip()) for (key, value) in flagged_keys_and_values]

        return finished_keys_and_values

    
    def _merge(self, list1, list2): 
        """
        Merges two lists into a list of tuples.
        """

        merged_list = tuple(zip(list1, list2))  

        return merged_list