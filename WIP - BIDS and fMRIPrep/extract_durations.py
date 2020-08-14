"""
Library of functions to read stimulus durations from a .dat file.

Created by Ben Velie on 8/13/2020.
veliebm@gmail.com
"""

import argparse
import pathlib


def get_durations(input_path) -> list:
    """
    Returns a list of durations extracted from a .dat file.

    Automatically converts times into seconds.
    """

    # Force input path to become a path object
    input_path = pathlib.Path(input_path)

    raw_durations = _get_raw_durations(input_path)

    return _clean_durations(raw_durations)


def _clean_durations(raw_durations: list) -> list:
    """
    Converts a list of raw durations into clean durations.

    Each raw duration is converted from scientific notation to a float.
    """

    clean_durations = []
    
    for raw_duration in raw_durations:
        duration = float(raw_duration)
        clean_durations.append(duration)

    return clean_durations


def _get_raw_durations(path) -> list:
    """
    Returns a list of all raw durations from a .dat file.

    Note that the durations must be further cleaned.
    """

    lines = get_line_list(path)
    raw_durations = []

    for line in lines:
        raw_duration = line.split(" ")[4]
        raw_durations.append(raw_duration)

    return raw_durations


def get_line_list(path) -> list:
    """
    Returns the selected file as a list of lines.
    """

    return path.read_text().splitlines()


def get_average_duration(dat_path) -> float:
    """
    Returns the average stimulus duration recorded in a .dat file.
    """

    durations = get_durations(dat_path)
    
    return sum(durations) / len(durations) 


def get_final_duration(dat_path) -> float:
    """
    Returns the final duration recorded in a .dat file.
    """
    
    return get_durations(dat_path)[-1]