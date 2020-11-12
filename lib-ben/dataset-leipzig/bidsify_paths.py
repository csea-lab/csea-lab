#!/usr/bin/env python3
"""
The time has come... again! Here we bidsify the paths of the Leipzig dataset to prepare it for fMRIPrep.

Run bidsify_metadata.py after this to finalize our fMRIPrep prep.

Created 11/10/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import argparse
from pathlib import Path
from re import search
from shutil import copy, copytree, rmtree


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
    raw_dir = bids_dir / "sourcedata"

    copy_all_paths_to_sourcedata(input_dir, raw_dir)

    fix_acquisition_numbers_of_json_files(raw_dir)

    old_and_new_paths = create_dictionary_of_old_and_new_paths(raw_dir, bids_dir)

    copy_files_to_their_new_homes(old_and_new_paths)


def copy_all_paths_to_sourcedata(input_dir: Path, raw_dir: Path):
    """
    Copies every single path in the input directory into bids_dir/sourcedata/

    Every. Single. One.
    """

    user_wants_to_continue = "y"

    if raw_dir.exists():
        print(f"{raw_dir} already exists. Do you want to overwrite it?")
        user_wants_to_continue = input("(y/n): ")
    
    if user_wants_to_continue == "y":
        rmtree(raw_dir, ignore_errors=True)
        print(f"Copying {input_dir.name} to {raw_dir}")
        print("This will probably take a really long time.")
        copytree(src=input_dir, dst=raw_dir, dirs_exist_ok=True)
        print("Copying complete.")

    else:
        print(f"OK. I won't overwrite {raw_dir.name}, but I'll try bidsifying what's already inside it.")


def fix_acquisition_numbers_of_json_files(raw_dir: Path):
    """
    Fixes the acquisition numbers of all json files in raw_dir.

    They begin as single digit numbers. They must become 2 digit numbers, i.e. they
    need one zero in front of them. This function converts the 1 digit numbers
    into 2 digit numbers.  
    """

    print("Fixing the acquisition numbers of the .json files in sourcedata.")

    for old_path in raw_dir.rglob("*.json"):

        parts_of_stem_of_old_path = old_path.stem.split("_")
        stem_parts_with_correct_acquisition_number = parts_of_stem_of_old_path[:-1] + [acquisition_number_of(old_path)]
        fresh_new_stem = "_".join(stem_parts_with_correct_acquisition_number)
        fresh_new_path = old_path.with_name(fresh_new_stem + old_path.suffix)
        old_path.replace(fresh_new_path)


def create_dictionary_of_old_and_new_paths(raw_dir: Path, bids_dir: Path) -> dict:
    """
    The meat and potatoes of this script.

    Recursively finds each file in the input directory, then generates a new path for that file
    in the bids directory. Then, this function returns the new paths and old paths in a dictionary
    to be copied over later.
    """

    old_and_new_paths = {}
    old_paths = list(raw_dir.rglob("*"))
    print(f"Sorting {len(old_paths)} paths.")  

    def task_name_of(path_to_func_or_json):
        """
        Returns the task name of a func or json file.
        """

        list_of_lines_containing_raw_subject_info = []
        for path in old_paths:
            if filetype_of(path) == "subject info":
                list_of_lines_containing_raw_subject_info = path.read_text().splitlines()
                break

        for line in list_of_lines_containing_raw_subject_info:
            if path_to_func_or_json.stem in line:
                return line.split("z")[1]      


    for old_path in old_paths:

        new_path = old_path

        if filetype_of(old_path.with_suffix(".nii")) == "anat" and acquisition_number_of(old_path) == "14":
            new_path = bids_dir / f"sub-{subject_id_of(old_path)}" / "anat" / f"sub-{subject_id_of(old_path)}_T1w{old_path.suffix}"

        elif filetype_of(old_path.with_suffix(".nii")) == "func" and acquisition_number_of(old_path) != "02":
            new_path = bids_dir / f"sub-{subject_id_of(old_path)}" / "func" / f"sub-{subject_id_of(old_path)}_task-{task_name_of(old_path)}_acq-{acquisition_number_of(old_path)}_bold{old_path.suffix}"

        old_and_new_paths[old_path] = new_path

    print("Paths sorted.")

    return old_and_new_paths


def copy_files_to_their_new_homes(old_and_new_paths: dict):
    """
    Copies all the old paths in the dictionary to their new locations.
    """
    
    print("Copying old paths to their new homes.")
    for old_path, new_path in old_and_new_paths.items():

        if not new_path.exists():
            new_path.parent.mkdir(parents=True, exist_ok=True)
            copy(old_path, new_path)
            print(f"Copied {old_path.name}  ->  {new_path.absolute()}")


def filetype_of(path: Path) -> str:
    """
    Returns the type of file a path is.

    Returns "json", "onsets", "subject info", "anat", "func", "field map", or "unsorted".
    """

    filetype = "unsorted"

    if path.suffix == ".json":
        filetype = "json"

    elif path.suffix == ".txt":
        if search(pattern="v[0-9][0-9]_[0-9]", string=path.stem):
            filetype = "onsets"
        elif "subject_info" in path.stem:
            filetype = "subject info"

    elif path.suffix == ".nii":
        if "_t1_" in path.stem:
            filetype = "anat"
        elif "_lessvoids_" in path.stem:
            filetype = "func"
        elif "field_map" in path.stem:
            filetype = "field map"

    return filetype


def subject_id_of(path: Path) -> str:
    """
    Returns the subject ID found in the input file name.

    Specifically, if the filename contains a 'V' and then 2 numerals in a row, returns it as the subject ID.
    """

    match = search(pattern="V([0-9][0-9])", string=str(path))
    return match.group(1)


def acquisition_number_of(path_to_func_or_anat_or_json: Path) -> str:
    """
    Returns the acquisition number of a scan so we can keep track of their order.

    Automatically pads the acquisition number with one zero if the acquisition number is
    below 10.
    """

    return path_to_func_or_anat_or_json.stem.split("_")[-1].zfill(2)


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
