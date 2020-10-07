"""
This module contains functions I find myself using again and again across the entire contrascan project.

Created 10/6/2020 by Benjamin Velie
veliebm@gmail.com

"""

import re
from pathlib import Path


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
        subject_ids = re.findall(r"sub-(\d+)", str(path))
        return subject_ids[-1]
    except IndexError:
        raise RuntimeError(f"No subject ID found in {path}")


def with_whitespace_trimmed(docstring: str) -> str:
    """
    Removes extra whitespace from a string or docstring.


    Inputs
    ------
    docstring : str
        The docstring to de-whitespace.

    
    Returns
    -------
    str
        The docstring with each extra space and newline shortened to a single space (" ").

    """

    return ' '.join(docstring.replace("\n", " ").split())