"""
Processes all .vmrk files within a directory and outputs lists of their stimulus onsets into .txt files.

Created by Ben Velie on 8/5/2020.
veliebm@gmail.com
"""

import argparse
import pathlib

ONSET_CODE = "S  2"
FMRI_CODE = "R128"


def main(input_dir, output_dir):
    """
    Outputs stimulus onsets from all .vmrk files in the input directory to the output directory.
    """

    # Force our parameters to become path objects
    input_path = pathlib.Path(input_dir)
    output_path = pathlib.Path(output_dir)

    # Get the .vmrk files to access
    print(f"Accessing {input_path.absolute()}")
    vmrk_paths = input_path.glob("*.vmrk")
    
    # Extract timings from the files
    for vmrk_path in vmrk_paths:
        timings = get_timings(vmrk_path)
        output_txt(output_path, vmrk_path, timings)


# Functions to get the list of times from the .vmrk

def get_timings(vmrk_path) -> list:
    """
    Returns a list of timings from a .vmrk file.

    Automatically converts times into seconds and adjusts them to the specified
    start time.
    """

    start_time = get_start_time(vmrk_path)
    raw_timings = _get_raw_timings(vmrk_path)

    return _clean_timings(raw_timings, start_time)


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
    Returns the selected file as a list of lines.
    """

    return path.read_text().splitlines()


def output_txt(output_path, vmrk_path, timings: list):
    """
    Outputs a txt file into the specified directory.
    """

    txt_path = output_path / f"{vmrk_path.stem}_onsets.txt"

    print(f"Writing {txt_path.absolute()}")

    formatted_timings = (f"{str(timing)}\n" for timing in timings)
    
    with txt_path.open(mode='w') as txt_file:
        txt_file.writelines(formatted_timings)


# Other functions

def get_start_time(path) -> float:
    """
    Returns the time at which the fMRI began scanning.
    """

    lines = get_line_list(path)
    for line in lines:
        if FMRI_CODE in line:

            return float(get_timing(line))


def get_timing(line: str) -> str:
    """
    Returns the stimulus timing from the line of text.
    """

    return line.split(",")[2]


if __name__ == "__main__":
    # Get parameters from the command line.
    parser = argparse.ArgumentParser(description="Get onsets from all .vmrk files in the target directory.")
    parser.add_argument("input_dir", type=str, help="Input directory.")
    parser.add_argument("output_dir", type=str, help="Output directory.")
    args = parser.parse_args()

    main(args.input_dir, args.output_dir)
