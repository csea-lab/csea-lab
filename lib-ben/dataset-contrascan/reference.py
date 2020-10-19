#!/usr/bin/env python3

"""
This module contains functions I find myself using again and again across the entire contrascan project.

Created 10/6/2020 by Benjamin Velie
veliebm@gmail.com

"""

import re
from pathlib import Path
import pandas


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


def the_path_that_matches(pattern: str, in_directory):
    """
    Finds one and only one path matching the specified pattern. Raises an error if it finds 2+ paths or no paths.

    To learn how to use advanced patterns, read http://www.robelle.com/smugbook/wildcard.html


    Parameters
    ----------
    pattern : str
        Pattern to search for.
    in_directory : str or Path
        Directory in which to search for the pattern.

    Returns
    -------
    Path
        Path found by search.

    Raises
    ------
    IOError
        If it finds 2+ paths or no paths.

    """

    matches = list(Path(in_directory).glob(pattern))

    if not Path(in_directory).is_dir():
        raise IOError(f"{in_directory} either doesn't exist or isn't a directory at all!")

    elif(len(matches)) >= 2:
        raise IOError(f"The directory {in_directory} exists but it contains more than one path that matches '{pattern}': {[match.name for match in matches]}")

    elif(len(matches)) == 0:
        raise IOError(f"The directory {in_directory} exists but it contains no paths that match pattern '{pattern}'")
    
    else:
        return matches[0]


def split_columns_into_text_files(tsv_path, output_dir):
    """
    Converts a tsv file into a collection of text files.

    Each column name becomes the name of a text file. Each value in that column is then
    placed into the text file. Don't worry - this won't hurt your .tsv file, which will lay
    happily in its original location.


    Parameters
    ----------
    tsv_path : str or Path
        Path to the .tsv file to break up.
    output_dir : str or Path
        Directory to write columns of the .tsv file to.
    
    """

    # Alert the user and prepare our paths. ----------------
    tsv_path = Path(tsv_path).absolute()
    output_dir = Path(output_dir).absolute()
    output_dir.mkdir(exist_ok=True, parents=True)
    print(f"Storing the columns of {tsv_path.name} as text files in {output_dir}")


    # Read the .tsv file into a DataFrame and fill n/a values with zero. -----------------
    tsv_info = pandas.read_table(
        tsv_path,
        sep="\t",
        na_values="n/a"
    ).fillna(value=0)


    # Write each column of the dataframe as a text file. -----------------------
    for column_name in tsv_info:
        column_path = output_dir / f"{column_name}.txt"
        tsv_info[column_name].to_csv(column_path, sep=' ', index=False, header=False)
