#!/usr/bin/env python3

"""
Processes all .vmrk files within a directory and outputs lists of their stimulus onsets into .txt files.

Text files will have the same name as their .vmrk files, but with ".vmrk" replaced with "_onsets.txt".

Created by Ben Velie on 8/5/2020.
veliebm@gmail.com

"""

import argparse
import pathlib

ONSET_CODE = "S  2"
FMRI_CODE = "R128"


def main(input_dir, output_dir, offset):
    """
    Outputs stimulus onsets from all .vmrk files in the input directory to text files in the output directory.

    Text files will have the same name as their .vmrk files, but with ".vmrk" replaced with "_onsets.txt".
    """

    # Force our parameters to become path objects
    input_path = pathlib.Path(input_dir)
    output_path = pathlib.Path(output_dir)

    # Get the .vmrk files to access
    print(f"Accessing {input_path.absolute()} and its children.")
    vmrk_paths = input_path.rglob("*.vmrk")
    
    # Extract timings from the files
    for vmrk_path in vmrk_paths:
        timings = get_timings(vmrk_path, offset)
        output_txt(output_path, vmrk_path, timings)


# Functions to get the list of times from the .vmrk

def get_timings(vmrk_path, offset) -> list:
    """
    Returns a list of timings from a .vmrk file.

    Automatically converts times into seconds and adjusts them to the specified start time.
    Also applies the offset to each time.
    """

    start_time = get_start_time(vmrk_path)
    raw_timings = _get_raw_timings(vmrk_path)
    almost_finished_timings = _clean_timings(raw_timings, start_time)
    return [timing + offset for timing in almost_finished_timings]


def _clean_timings(raw_timings: list, start_time: int) -> list:
    """
    Converts a list of raw times into clean times.

    Each raw time is divided by 5000 to convert it to seconds. Also, the time list is adjusted to the
    time the fMRI began scanning.
    """

    clean_timings = []

    for raw_time in raw_timings:
        time = (raw_time - start_time) / 5000
        clean_timings.append(time)

    return clean_timings


def _get_raw_timings(vmrk_path) -> list:
    """
    Returns a list of all raw stimulus onset timings.

    Note that the times must be further cleaned.
    """

    lines = get_line_list(vmrk_path)
    raw_timings = []

    for line in lines:
        if ONSET_CODE in line:
            raw_time = float(get_timing(line))
            raw_timings.append(raw_time)

    return raw_timings


# Functions to access files

def get_line_list(path) -> list:
    """
    Returns a file as a list of lines.
    """

    return path.read_text().splitlines()


def output_txt(output_path, vmrk_path, timings: list):
    """
    Outputs a txt file of timings into the specified directory.
    """

    txt_path = output_path / f"{vmrk_path.stem}_onsets.txt"
    txt_path.parent.mkdir(exist_ok=True, parents=True)

    print(f"Writing {txt_path.absolute()}")

    formatted_timings = (f"{str(timing)}\n" for timing in timings)
    
    with txt_path.open(mode='w') as txt_file:
        txt_file.writelines(formatted_timings)


# Other functions

def get_start_time(path) -> float:
    """
    Returns the time at which the fMRI began scanning in a .vmrk file.
    """

    lines = get_line_list(path)
    for line in lines:
        if FMRI_CODE in line:

            return float(get_timing(line))


def get_timing(line: str) -> str:
    """
    Returns the stimulus timing from a line of text grabbed from a .vmrk file.
    """

    return line.split(",")[2]


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """
    
    # Get parameters from the command line.
    parser = argparse.ArgumentParser(description="Get onsets from all .vmrk files in the target directory.")
    parser.add_argument("input_dir", help="Input directory.")
    parser.add_argument("output_dir", help="Output directory.")
    parser.add_argument("--offset", type=float, default=0, help="What you want to offset each onset time by. Default: 0. Example: --offset '-2.5' would subtract 2.5 from each onset time.")
    args = parser.parse_args()

    main(args.input_dir, args.output_dir, args.offset)
