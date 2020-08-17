"""
Extracts the necessary metadata from a dataset to make it BIDS compliant. 

The dataset must already be named according to BIDS standards. Thus, I recommend running bidsify_paths.py before this program.

Created 8/13/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import argparse
import bidsify_metadata_template
import os
import pathlib


def main(input_dir):

    # Force input dir to become a path object.
    input_dir_path = pathlib.Path(input_dir)

    # Gather into path_list all file paths in the input directory and recursively its subdirectories.
    path_list = [path for path in input_dir_path.rglob("*") if path.is_file()]

    # Iterate through the list of file paths and extract metadata from each file into a dictionary.
    metadata_dict = {path: extract_metadata(path) for path in path_list}
    
    # [print(f"{key}  :  {value}") for key, value in metadata_dict.items()]
    
    # Use dictionary of metadata to bidsify the dataset.


def extract_metadata(path):
    """
    Extracts metadata from a file.

    bidsify_metadata_template.py defines what metadata is extracted.
    """

    file_type = get_file_type(path)
    extraction_template = getattr(bidsify_metadata_template, f"{file_type}_metadata_extraction_template")

    return extraction_template(path)


def get_file_type(path) -> str:
    """
    Returns the type of neuroimaging file the target file is.

    Returns any file type in FILETYPES.
    """

    for file_type, keyword_list in bidsify_metadata_template.FILETYPES.items():
        for keyword in keyword_list:
            if keyword in path.name:
                return file_type


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Makes a dataset BIDS compliant.")
    parser.add_argument("directory", type=str, help="Target directory.")

    args = parser.parse_args()

    main(args.directory)