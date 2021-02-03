#!/usr/bin/env python3
"""
Extract fMRI data from nifti files. Wow!

Created 2/3/2021 by Benjamin Velie.
veliebm@gmail.com
"""

import argparse
from pathlib import Path
import nibabel
import numpy
import json


def main(path: Path):
    """
    Extracts the time series from a nifti file.
    """
    image = nibabel.load(path)
    header = image.header
    matrix = image.get_fdata()
    
    header_out_path = path.parent / f"{path.stem}_header.json"
    write_header(header, header_out_path)

    matrix_out_path = path.parent / f"{path.stem}_matrix.npy"
    write_matrix(matrix, matrix_out_path)


def write_header(header, out_path):
    """
    Writes the header to the specified path as a json file.
    """
    # Get the header as a dict and turn all numpy arrays into their component parts.
    header_dict = {key: array.tolist() for key, array in dict(header).items()}

    # Bytes objects aren't serializable, so we must turn all bytes objects into strings.
    def filter_bytes_into_string(some_object):
        if type(some_object) == bytes:
            return some_object.decode("UTF-8")
        else:
            return some_object
    cleaned_dict = {key: filter_bytes_into_string(value) for key, value in header_dict.items()}

    # Write the json file.
    with open(out_path, "w") as write_file:
        print(f"Writing header to {out_path}")
        json.dump(cleaned_dict, write_file, indent="\t")


def write_matrix(matrix, out_path):
    """
    Writes the matrix to the specified path as a json file.
    """
    print(f"Writing matrix to {out_path}")
    numpy.save(out_path, matrix)


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Extracts the time series from the target nifti file.", fromfile_prefix_chars="@")
    parser.add_argument("path", type=Path, help="<Mandatory> Path to the nifti file you want to extract.")

    args = parser.parse_args()
    print(f"Arguments: {args}")

    main(
        path=args.path.absolute()
    )
