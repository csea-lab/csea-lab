"""
Provides templates for bidsify_paths.py.

bidsify_paths.py automatically grabs the file types defined in this script. Then, it formats those files
according to the functions defined in this script. To add a new file type, just add it to FILETYPES along with
strings the filename must contain to match the new file type. Then, define a new function named
NEWTYPEGOESHERE_template(input_path, output_dir_path) to tell the program what to do with files matching that file type.

Note that "unsorted" MUST be at the bottom of FILETYPES!

I built this template for Matt Friedl's 2020 concurrent EEG/fMRI study. Other datasets probably require different templates.
But you can use bidsify_paths.py for any conceivable dataset!

Created 8/12/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import re
import pathlib


# Task name to use when naming fMRI and EEG files
TASK = "gabor"

# Keys to use to sort the files. For example, a filename containing "sT1w" will be sorted as "anat".
FILETYPES = {
            "anat": ["sT1W"],
            "func": ["EPI"],
            "eeg": [".eeg", ".vmrk", ".vhdr"],
            "dat": [".dat"],
            "unsorted": [""]
            }


def anat_template(input_path, output_dir_path):
    """
    Template to bidsify anatomical paths.
    """

    subject_id = get_subject_id(input_path)

    new_name = f"sub-{subject_id}_sT1w{input_path.suffix}"
    
    return output_dir_path / f"sub-{subject_id}" / "anat" / new_name


def func_template(input_path, output_dir_path):
    """
    Template to bidsify functional paths.
    """

    subject_id = get_subject_id(input_path)

    new_name = f"sub-{subject_id}_task-{TASK}_bold{input_path.suffix}"

    return output_dir_path / f"sub-{subject_id}" / "func" / new_name


def eeg_template(input_path, output_dir_path):
    """
    Template to bidsify eeg paths.
    """

    subject_id = get_subject_id(input_path)

    new_name = f"sub-{subject_id}_task-{TASK}_eeg{input_path.suffix}"

    return output_dir_path / f"sub-{subject_id}" / "eeg" / new_name


def dat_template(input_path, output_dir_path):
    """
    Template to bidsify .dat paths.
    """

    subject_id = get_subject_id(input_path)

    new_name = f"sub-{subject_id}_task-{TASK}{input_path.suffix}"

    return output_dir_path / "sourcedata" / new_name


def unsorted_template(input_path, output_dir_path):
    """
    Leave unsorted paths untouched.
    """

    return input_path


def get_subject_id(input_path) -> str:
    """
    Returns the subject ID found in the input file name.

    Specifically, if the filename contains 3 numerals in a row, returns it as the subject ID
    """

    return re.search("[0-9][0-9][0-9]", input_path.stem)[0]
