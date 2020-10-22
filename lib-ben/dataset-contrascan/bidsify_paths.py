#!/usr/bin/env python3

"""
Renames and copies all neuroimaging files recursively within a directory tree into a BIDS-compliant directory tree.

You can customize which files are copied and where they go. Just edit bidsify_paths_template.py.

Note this script does NOT extract and format metadata. But you can use bidsify_metadata.py to do that!

Created 8/11/2020 by Benjamin Velie.
veliebm@ufl.edu

"""

import argparse
import bidsify_paths_template
from pathlib import Path
import shutil


def main(input_dir, output_dir):
    """
    Structure an input directory into BIDS but without any metadata included.


    Parameters
    ----------
    input_dir : str or Path
        Directory to transform into BIDS.
    output_dir : str or Path
        Where to create the new BIDS directory.

    """

    # Force our parameters to become path objects.
    input_path = Path(input_dir)
    output_path = Path(output_dir)

    # Store old and new paths in a dict.
    old_and_new_paths = bidsify_paths(input_path, output_path)

    # Copy the files.
    copy_files(old_and_new_paths)


def get_file_type(path) -> str:
    """
    Returns the type of neuroimaging file the target file is.

    Returns any file type in FILETYPES, which comes from the bidsify_paths_template module.


    Parameters
    ----------
    path : Path
        Path to the file you'd like to classify.


    Returns
    -------
    str
        The type of file it is.

    """

    for file_type, keyword_list in bidsify_paths_template.FILETYPES.items():
        for keyword in keyword_list:
            if keyword in path.name:
                return file_type


def bidsify_paths(input_dir_path, output_dir_path) -> dict:
    """
    Returns a dictionary with each key equal to an old path and its value equal to a new path.

    
    Parameters
    ----------
    input_dir_path : Path
        The directory to transmogrify into BIDS.
    output_dir_path : Path
        Where you want your BIDS directory to be.


    Returns
    -------
    dict
        Each key is a Path globbed from input_dir_path. Each value is its new location, which is also a Path object.

    """

    old_and_new_paths = {}
    
    for old_path in input_dir_path.rglob("*"):
        old_and_new_paths[old_path] = bidsify_path(old_path, output_dir_path)

    return old_and_new_paths


def bidsify_path(input_path, output_dir_path) -> str:
    """
    Returns a path reformatted to BIDS.


    Parameters
    ----------
    input_path : Path
        Path to a file you'd like to modify into BIDS.
    output_dir_path : Path
        Where you want your BIDS directory to be.


    Returns
    -------
    Path
        The file's new location.

    """

    file_type = get_file_type(input_path)
    template_to_access = getattr(bidsify_paths_template, f"{file_type}_template")

    return template_to_access(input_path, output_dir_path)


def copy_files(old_and_new_paths: dict):
    """
    Given a dictionary containing old paths and new paths, copies the old to the new.


    Parameters
    ----------
    old_and_new_paths : dict
        Each key is an unbidsified path. Each value is its new location.

    """

    for old_path, new_path in old_and_new_paths.items():
        if not new_path.exists():
            new_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy(old_path, new_path)

            print(f"Copied {old_path.name}  ->  {new_path.absolute()}")


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.

    """

    parser = argparse.ArgumentParser(description="Renames and moves files into a BIDS-compliant directory structure.")
    parser.add_argument("input_dir", type=str, help="Input directory.")
    parser.add_argument("output_dir", type=str, help="Path to where the BIDS directory will be.")

    args = parser.parse_args()

    main(args.input_dir, args.output_dir)