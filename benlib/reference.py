#!/usr/bin/env python3

"""
This module contains functions I find myself using again and again for BIDSifying things.

Created 11/11/2020 by Benjamin Velie
veliebm@gmail.com
"""

from re import search
from pathlib import Path
import json


def subject_id_of(path) -> str:
    """
    Returns the subject ID closest to the end of the input string or Path.

    Inputs
    ------
    path : str or Path
        String or Path containing the subject ID.

    Returns
    -------
    str
        Subject ID found in the filename

    Raises
    ------
    RuntimeError
        If no subject ID found in input filename.
    """

    try:
        match = search(r"sub-([0-9]+)", str(path))
        return match.group(1)
    except AttributeError:
        raise RuntimeError(f"No subject ID found in {path}. Is this file named correctly?")


def task_name_of(path) -> str:
    """
    Returns the task name closest to the end of the input string or Path.

    Inputs
    ------
    path : str or Path
        String or Path containing the task name.

    Returns
    -------
    str
        Task name found in the filename

    Raises
    ------
    RuntimeError
        If no task name found in input filename.
    """

    try:
        match = search(r"task-(.+?)(?=$|[_.])", str(path))
        return match.group(1)
    except AttributeError:
        raise RuntimeError(f"No task name found in {path}. Is this file named correctly?")


def the_path_that_matches(pattern: str, in_directory):
    """
    Finds one and only one path matching the specified pattern. Raises an error if it finds 2+ paths or no paths.

    To learn how to use advanced patterns, read http://www.robelle.com/smugbook/wildcard.html

    Parameters
    ----------
    pattern : str
        Pattern to search for.
    in_directory : str or Path
        Directory in which to search for the pattern.

    Returns
    -------
    Path
        Path found by search.

    Raises
    ------
    IOError
        If it finds 2+ paths or no paths.
    """

    matches = list(Path(in_directory).glob(pattern))

    if not Path(in_directory).is_dir():
        raise IOError(f"{in_directory} either doesn't exist or isn't a directory at all!")

    elif(len(matches)) >= 2:
        raise IOError(f"The directory {in_directory} exists but contains more than one path that matches '{pattern}': {[match.name for match in matches]}")

    elif(len(matches)) == 0:
        raise IOError(f"The directory {in_directory} exists but contains no paths that match pattern '{pattern}'")
    
    else:
        return matches[0]


def append_to_json_file(key, value, path_to_json):
    """
    Adds a key-value pair to your json file of choice.
    """

    contents = {}

    with open(path_to_json, "r") as json_file:
        contents = json.load(json_file)
        contents[key] = value

    with open(path_to_json, "w") as json_file:
        json.dump(contents, json_file, indent="\t")


def value_of_key_in_json_file(key, path_to_json):
    """
    Gets the value of the specified key in the specified json file.
    """

    with open(path_to_json, "r") as json_file:
        contents = json.load(json_file)
        return contents[key]


def stem_of(path: Path):
    """
    Returns the TRUE stem of a path, even if it has multiple suffixes.

    If you call this on an AFNI dataset, it'll also return whatever comes before
    "+tlrc" or "+orig"
    """

    if search(r"\+tlrc\.", path.name) or search(r"\+orig\.", path.name):
        return path.name.split("+")[-2]
    else:
        return path.stem.split('.')[0]
