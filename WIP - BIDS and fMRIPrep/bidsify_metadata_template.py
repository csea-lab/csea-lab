"""
Provides templates for bidsify_paths.py.

bidsify_paths.py automatically grabs the file types defined in this script. Then, it formats those files
according to the functions defined in this script. To add a new file type, just add it to FILETYPES along with
strings the filename must contain to match the new file type. Then, define a new function named
NEWTYPEGOESHERE_template(filename: str, output_dir: str) to tell the program what to do with files matching that file type.

Note that "unsorted" MUST be at the bottom of FILETYPES!

I built this template for Matt Friedl's 2020 concurrent EEG/fMRI study. Other datasets probably require different templates.

Created 8/12/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
import os
import re
import nibabel
import extract_onsets
import extract_durations
import extract_fmri_settings

# Keys to use to sort the files. For example, a filename containing "sT1w" will be sorted as "anat".
FILETYPES = {
            "anat": ["_sT1w.nii"],
            "func": ["_bold.nii"],
            "vmrk": [".vmrk"],
            "dat": [".dat"],
            "settings": ["fMRI settings.txt"],
            "unsorted": [""]
            }


def anat_metadata_extraction_template(path):
    """
    Template to extract metadata from an anatomy file.
    """

    anatomy_file = nibabel.load(path.absolute)
    header_metadata = dict(anatomy_file.header)
    
    other_metadata = {
        "subject" : get_subject_id(path)
    }

    all_metadata = {**header_metadata, **other_metadata}

    return all_metadata


def func_metadata_extraction_template(path):
    """
    Template to extract metadata from a functional file.
    """

    functional_file = nibabel.load(path.absolute())
    header_metadata = dict(functional_file.header)
    
    other_metadata = {
        "subject": get_subject_id(path),
        "tasks": get_tasks(path)
    }

    all_metadata = {**header_metadata, **other_metadata}

    return all_metadata


def vmrk_metadata_extraction_template(path):
    """
    Template to extract metadata from an eeg file.
    """
    
    return {
        "onsets": extract_onsets.get_timings(path),
        "subject": get_subject_id(path),
        "tasks": get_tasks(path)
    }
    

def dat_metadata_extraction_template(path):
    """
    Template to extract metadata from a .dat file.
    """

    return {
        "subject": get_subject_id(path),
        "duration": extract_durations.get_final_duration(path)
    }


def settings_metadata_extraction_template(path):
    """
    Template to extract metadata from an fMRI settings file.
    """
    
    [print(f"'{key}' : '{value}'") for key, value in extract_fmri_settings.get_settings_dict(path).items()]

    return extract_fmri_settings.get_settings_dict(path)


def unsorted_metadata_extraction_template(path):
    """
    Leave unsorted paths untouched.
    """

    return None


def get_tasks(path) -> list:
    """
    Returns a list of tasks found in the target path name.
    """

    return re.findall(r"task-(.+)_", path.stem)


def get_subject_id(path) -> str:
    """
    Returns the subject ID found in the input file name.

    Returns "None" if no subject ID found.
    """
    
    potential_subject_ids = re.findall(r"sub-(\d+)", str(path))

    try:
        subject_id = potential_subject_ids[0]
    except IndexError:
        subject_id = None

    return subject_id
