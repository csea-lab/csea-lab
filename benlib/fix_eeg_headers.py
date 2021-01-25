#!/usr/bin/env python3
"""
Fixes the headers of the EEG files in your BIDS dataset.

Created 1/25/2021 by Benjamin Velie.
veliebm@gmail.com
"""

import argparse
from pathlib import Path
from re import search


def main(bids_dir):
    """
    Fix all EEG headers in the target BIDS dataset.
    """

    # Get the paths to the files to access.
    print(f"Accessing {bids_dir.absolute()} and its child directories.")
    vhdr_paths = bids_dir.glob("sub-*/eeg/*.vhdr")
    vmrk_paths = bids_dir.glob("sub-*/eeg/*.vmrk")

    for path in vhdr_paths:
        fix_datafile(path)
        fix_markerfile(path)

    for path in vmrk_paths:
        fix_datafile(path)


def fix_markerfile(path_to_header):
    """
    Fixes the MarkerFile attribute in a .vhdr file.
    """

    # Read the file.
    with open(path_to_header, "r") as eeg_file:
        content = eeg_file.read()

    # Replace the DataFile attribute.
    old_markerfile = search(pattern=r"(?<=MarkerFile=).+?(?=\n)", string=content).group(0)
    new_markerfile = path_to_header.with_suffix(".vmrk").name
    new_content = content.replace(old_markerfile, new_markerfile)

    print(f"In {path_to_header} changing MarkerFile attribute from {old_markerfile} to {new_markerfile}")

    # Write our changes to the file.
    with open(path_to_header, "w") as eeg_file:
        eeg_file.write(new_content)


def fix_datafile(path_to_header):
    """
    Fixes the DataFile attribute in an EEG file.
    """

    # Read the file.
    with open(path_to_header, "r") as eeg_file:
        content = eeg_file.read()

    # Replace the DataFile attribute.
    old_datafile = search(pattern=r"(?<=DataFile=).+?(?=\n)", string=content).group(0)
    new_datafile = path_to_header.with_suffix(".eeg").name
    new_content = content.replace(old_datafile, new_datafile)

    print(f"In {path_to_header} changing DataFile attribute from {old_datafile} to {new_datafile}")

    # Write our changes to the file.
    with open(path_to_header, "w") as eeg_file:
        eeg_file.write(new_content)


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """
    
    # Get parameters from the command line.
    parser = argparse.ArgumentParser(description="Fix all EEG headers in the target BIDS dataset. You must do this if you renamed your EEG files when organizing the dataset.")
    parser.add_argument("bids_dir", type=Path, help="BIDS directory.")
    args = parser.parse_args()

    main(args.bids_dir)
