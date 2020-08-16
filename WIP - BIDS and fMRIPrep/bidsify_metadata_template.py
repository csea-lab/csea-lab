"""
Provides templates for bidsify_metadata.py.

bidsify_metadata.py recursively scans through a directory tree. When it finds a file matching the template FILETYPES,
 it extracts metadata from it. All metadata is stored in a master dictionary. Each key in the master dictionary is the name of a file, 
 and each value is the file's metadata. You can define what metadata is extracted from a file by adding a new function to this
 template file. Just name it FILETYPEHERE_metadata_extraction_template(path). You can also add new file types to extract.
 Just add them to FILETYPES. Each key in FILETYPES is a type of file, and each value is a string within the file type's name
 that is unique to that file type.

Note that "unsorted" MUST be at the bottom of FILETYPES!

I built this template for Matt Friedl's 2020 concurrent EEG/fMRI study. Other datasets probably require different templates.

Created 8/12/2020 by Benjamin Velie.
veliebm@gmail.com
"""

import pathlib
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
    
    return extract_fmri_settings.get_settings_dict(path)


def unsorted_metadata_extraction_template(path):
    """
    Do not extract metadata from unsorted paths.
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
