#!/usr/bin/env python3
"""
A script to bidsify the paths of the contrascan dataset.

Created 11/3/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import argparse
from pathlib import Path
from re import search
from shutil import copy


def main(input_dir, bids_dir):
    """
    Structure an input directory into BIDS but without any metadata included.

    Parameters
    ----------
    input_dir : str or Path
        Directory to transform into BIDS.
    bids_dir : str or Path
        Where to create the new BIDS directory.
    """

    input_dir = Path(input_dir).absolute()
    bids_dir = Path(bids_dir).absolute()

    old_and_new_paths = create_dictionary_of_old_and_new_paths(input_dir, bids_dir)

    copy_files_to_their_new_homes(old_and_new_paths)


def create_dictionary_of_old_and_new_paths(input_dir: Path, bids_dir: Path) -> dict:
    """
    The meat and potatoes of this script.

    Recursively finds each file in the input directory, then generates a new path for that file
    in the bids directory. Then, this function returns the new paths and old paths in a dictionary
    to be copied over later.
    """

    old_and_new_paths = {}
    old_paths = list(input_dir.rglob("*"))
    print(f"Sorting {len(old_paths)} paths.")
    for old_path in old_paths:

        if filetype_of(old_path) == "anat":
            new_path = bids_dir / f"sub-{subject_id_of(old_path)}" / "anat" / f"sub-{subject_id_of(old_path)}_T1w{old_path.suffix}"

        elif filetype_of(old_path) == "func":
            new_path = bids_dir / f"sub-{subject_id_of(old_path)}" / "func" / f"sub-{subject_id_of(old_path)}_task-contrascan_bold{old_path.suffix}"

        elif filetype_of(old_path) == "eeg":
            new_path = bids_dir / f"sub-{subject_id_of(old_path)}" / "eeg" / f"sub-{subject_id_of(old_path)}_task-contrascan_eeg{old_path.suffix}"

        elif filetype_of(old_path) == "dat":
            new_path = bids_dir / "sourcedata" / f"sub-{subject_id_of(old_path)}_task-contrascan{old_path.suffix}"

        elif filetype_of(old_path) == "unsorted":
            new_path = old_path

        old_and_new_paths[old_path] = new_path

    return old_and_new_paths


def copy_files_to_their_new_homes(old_and_new_paths: dict):
    """
    Copies all the old paths in the dictionary to their new locations.
    """

    for old_path, new_path in old_and_new_paths.items():

        if not new_path.exists():
            new_path.parent.mkdir(parents=True, exist_ok=True)
            copy(old_path, new_path)
            print(f"Copied {old_path.name}  ->  {new_path.absolute()}")


def filetype_of(path: Path) -> str:
    """
    Returns the type of file a path is.

    Returns "eeg", "dat", "anat", "func", or "unsorted".
    """

    if path.suffix == ".vmrk" or path.suffix == ".eeg" or path.suffix == ".vhdr":
        return "eeg"

    elif path.suffix == ".dat":
        return "dat"

    elif path.suffix == ".nii":
        if "sT1W" in path.stem:
            return "anat"
        elif "EPI" in path.stem:
            return "func"

    else:
        return "unsorted"


def subject_id_of(path: Path) -> str:
    """
    Returns the subject ID found in the input file name.

    Specifically, if the filename contains 3 numerals in a row, returns it as the subject ID.
    """

    matches = search(pattern="[0-9][0-9][0-9]", string=str(path))
    return matches[0]


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Renames and moves files into a BIDS-compliant directory structure.")
    parser.add_argument("input_dir", help="Input directory.")
    parser.add_argument("output_dir", help="Path to where the BIDS directory will be.")

    args = parser.parse_args()

    main(args.input_dir, args.output_dir)
