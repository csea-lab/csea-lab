"""
Library of functions to extract fMRI settings from a text file containing fMRI settings.

Created 8/13/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib

# Can be any string that will never appear in the settings file naturally
SUBSETTING_FLAG = "@@SUBSETTING@@"


def get_settings_dict(input_path) -> dict:
    """
    Returns a dictionary of each setting in the file and its value. Subsettings are stored in sub-dictionaries.
    """

    # Convert input path into a path object
    input_path = pathlib.Path(input_path)

    raw_keys_and_values = get_lines(input_path)

    

    depunctuated_raw_keys_and_values = remove_unwanted_punctuation(raw_keys_and_values)

    raw_settings_raw_subsettings_dict = combine_subsettings(depunctuated_raw_keys_and_values)

    #clean_raw_settings_raw_subsettings_dict(raw_settings_raw_subsettings_dict)
    
    return(raw_settings_raw_subsettings_dict)


def clean_raw_settings_raw_subsettings_dict(dict) -> dict:
    """
    Returns a cleaned up version of the dictionary.
    """

    # Turns each subsetting list into a clean dictionary
    dict = {setting: make_dict(subsetting_list) for setting, subsetting_list in dict.items()}

    # Turns the setting list into a clean dictionary
    clean_settings_dict = make_dict(dict.keys())

    for i, key in enumerate(dict.keys()):
        key = clean_settings_dict.keys()[i]

    return dict


def make_dict(lines: list) -> dict:
    """
    Breaks a list of lines into a list of settings and their values.
    """ 

    raw_keys, raw_values = split(lines)

    keys = remove_extra_whitespace(raw_keys)
    values = remove_extra_whitespace(raw_values)

    return dict(zip(keys, values))


def get_lines(input_path) -> list:
    """
    Returns a list of raw key:value pairs from the target file.
    """

    return input_path.read_text().splitlines()


def combine_subsettings(lines: str) -> dict:
    """
    Returns a dictionary with all subsettings placed in lists attached to their main settings.
    """

    combined_dict = {}

    for i, target_line in enumerate(lines):
        if not is_subsetting(target_line):
            combined_dict[target_line] = []
        else:
            for line in reversed(lines[0:i]):
                if not is_subsetting(line):
                    combined_dict[line].append(target_line)
                    break

    return combined_dict


def flag_subsettings(lines: list) -> list:
    """
    Flags any setting containing whitespace at the beginning as a subsetting.
    """

    # This will flag both the keys and the values.
    for i, line in enumerate(lines):
        if line[0:1].isspace():
            lines[i] = SUBSETTING_FLAG + line + SUBSETTING_FLAG

    return lines


def is_subsetting(line: str) -> bool:
    """
    Returns true if a line is a subsetting.

    A line is a subsetting if the beginning of it is an empty space.
    """

    return line[0:1] == " "


def remove_extra_whitespace(strings: list) -> list:
    """
    Removes all whitespace from the ends of each string in a list of strings.
    """

    return [string.strip() for string in strings]


def remove_unwanted_punctuation(strings: list) -> list:
    """
    Removes unwanted punctuation from all strings in a list.
    """
    
    unwanted_punctuation = '";'

    for punctuation in unwanted_punctuation:
        for i, string in enumerate(strings):
            strings[i] = string.replace(punctuation, "")

    return strings


def split(raw_keys_and_values: list) -> tuple: 
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