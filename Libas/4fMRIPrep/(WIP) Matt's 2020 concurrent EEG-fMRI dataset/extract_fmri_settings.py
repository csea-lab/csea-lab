"""
Library of functions to extract fMRI settings from a text file containing fMRI settings.

Created 8/13/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
from copy import deepcopy


# Can be any string not naturally found in the fMRI settings file
_SUBSETTING_FLAG = "!@#SUBSETTING#@!"


def get_settings_dict(input_path) -> dict:
    """
    Returns a dictionary of each setting in the file and its value. Subvalues are stored in sub-dictionaries.

    Suppose you wanted to access setting X. It'll be equal to DICTNAME["X"]["value"].
    Suppose you wanted to access subvalue Y for setting X. It'll be equal to
    DICTNAME["X"]["subvalues"]["Y"].
    """

    # Convert input path into a path object.
    input_path = pathlib.Path(input_path)

    # Get the target file as a raw list of tuples.
    raw_keys_and_values = _get_raw_keys_and_values(input_path)

    # Clean raw keys and values but append a subsetting flag to each subsetting tuple.
    flagged_keys_and_values = _clean_raw_keys_and_values(raw_keys_and_values)
    
    # Get a dict from our keys and values list
    return _dictify(flagged_keys_and_values)


def _dictify(flagged_keys_and_values) -> dict:
    """
    Returns a properly formatted dict from a list of flagged keys and values.
    """

    # Get all our not subsettings settings into a dict.
    settings_dict = {key: {"value": value, "subvalues": {}} for (key, value) in flagged_keys_and_values if not is_subsetting(key)}

    for i, tuple in enumerate(flagged_keys_and_values):
        if is_subsetting(tuple[0]):

            # Find corresponding setting.
            setting_key = ""
            for setting_tuple in reversed(flagged_keys_and_values[0:i]):
                if not is_subsetting(setting_tuple[0]):
                    setting_key = setting_tuple[0]
                    break

            # Remove flags from subsetting.
            deflagged_key = tuple[0].replace(_SUBSETTING_FLAG, "")
            deflagged_value = tuple[1].replace(_SUBSETTING_FLAG, "")

            # Update subsettings dict for the setting
            settings_dict[setting_key]["subvalues"][deflagged_key] = [deflagged_value]

    return settings_dict


def _get_raw_keys_and_values(input_path) -> list:
    """
    Returns a list of raw key:value pairs stored in tuples.
    """

    lines = input_path.read_text().splitlines()

    raw_keys, raw_tuples = _split_keys_and_values(lines)

    return merge(raw_keys,raw_tuples)


def _split_keys_and_values(raw_keys_and_values: list) -> tuple: 

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


def _clean_raw_keys_and_values(raw_keys_and_values: list) -> list:
    """
    Returns a list of cleaned keys and values that are flagged as settings or subsettings.
    """

    depunctuated_raw_keys_and_values = _remove_unwanted_punctuation(raw_keys_and_values)

    flagged_keys_and_values = _flag_and_dewhitespace(depunctuated_raw_keys_and_values)

    return flagged_keys_and_values


def is_subsetting(string: str) -> bool:
    """
    Returns true if a string is a subsetting.

    A string is a subsetting if it begins with an empty space OR it
    contains the subsetting flag.
    """

    return string[0:1] == " " or _SUBSETTING_FLAG in string


def _remove_unwanted_punctuation(raw_keys_and_values) -> list:
    """
    Removes unwanted punctuation from a list of key-value tuples.
    """
    
    keys_and_values = deepcopy(raw_keys_and_values)

    unwanted_punctuation = '";'

    for character in unwanted_punctuation:
        keys_and_values = [(key.replace(character, ""), value.replace(character, "")) for (key, value) in keys_and_values]

    return keys_and_values


def _flag_and_dewhitespace(raw_keys_and_values) -> list:
    """
    Returns a list of settings tuples with extra whitespace removed and labelled subsettings.
    """
    
    keys_and_values = deepcopy(raw_keys_and_values)

    # Remove all whitespace from right side of keys and values
    right_dewhitespaced_keys_and_values = [(key.rstrip(), value.rstrip()) for (key, value) in keys_and_values]

    # Add the subsetting flag to the end of each key and value where the value is a subsetting
    flagged_keys_and_values = [(key + _SUBSETTING_FLAG, value + _SUBSETTING_FLAG) if is_subsetting(key) else (key, value) for (key, value) in right_dewhitespaced_keys_and_values]

    # Strip all whitespace from left side of keys and values now
    finished_keys_and_values = [(key.lstrip(), value.lstrip()) for (key, value) in flagged_keys_and_values]

    return finished_keys_and_values


def merge(list1, list2): 
    """
    Merges two lists into a list of tuples.
    """

    merged_list = tuple(zip(list1, list2))  

    return merged_list 