#!/usr/bin/env python3

"""
Extracts the necessary metadata from a dataset to make it BIDS compliant. 

The dataset must already be named according to BIDS standards. Thus, I recommend running bidsify_paths.py before this program.

Created 8/13/2020 by Benjamin Velie.
veliebm@gmail.com

"""

# Standard python modules
from pathlib import Path
import argparse
import re
import pandas
import json

# Python modules I wrote for CSEA to help organize our data
import dat, vmrk, settings, nifti


FILETYPES = {
            "anat": ["_T1w.nii"],
            "func": ["_bold.nii"],
            "vmrk": [".vmrk"],
            "dat": [".dat"],
            "settings": ["settings.txt"]
            }


def main(input_dir):
    """
    Extracts metadata from a collection of BIDSified files and formats that metadata.


    Parameters
    ----------
    input_dir : str or Path
        Path to the root of the collection of the BIDSified files.

    """
    
    # Force input dir to become a path object.
    input_dir_path = Path(input_dir)

    # Gather into paths all file paths in the input directory and recursively its subdirectories.
    path_list = [path for path in input_dir_path.rglob("*") if path.is_file()]

    # Organize files into a dataframe.
    file_dataframe = organize_files(path_list)

    # Write the functional tsv files.
    write_func_tsvs(file_dataframe)

    # Write the functional json files.
    write_func_jsons(file_dataframe)

    # Write the dataset description json.
    write_dataset_description(file_dataframe)


def organize_files(path_list):
    """
    Organizes the paths within the BIDS directory by subject name and file type. Returns a DataFrame.


    Parameters
    ----------
    path_list : list
        List of paths 


    Returns
    -------
    DataFrame
        Contains metadata about each file. Columns are labeled by subject ID and rows are labeled by file type.

    """

    # Get lists of subjects and file types.
    subject_list = list({get_subject_id(path) for path in path_list if not get_subject_id(path) is None})
    filetypes = FILETYPES.keys()

    # Make a dict of paths where each key is the (subject id, file type) for each path.
    organized_paths = {(get_subject_id(path), get_file_type(path)): path for path in path_list}

    # Load empty, but labelled, dataframe.
    files = pandas.DataFrame(columns=subject_list, index=filetypes)

    # Load dataframe with extracted files.
    for subject in subject_list:
        for filetype in filetypes:
            path = organized_paths[(subject, filetype)]
            files[subject][filetype] = extract_file(path)

    return files


def write_func_tsvs(file_dataframe):
    """
    Given a complete dataframe of files, writes appropriate tsvs for func files.


    Parameters
    ----------
    file_dataframe : DataFrame
        DataFrame created by organize_files() containing metadata about each file

    """

    for subject in file_dataframe:
        onsets = file_dataframe[subject]["vmrk"].timings()
        duration = file_dataframe[subject]["dat"].average_duration()

        # Prep a dataframe to write to .tsv.
        tsv_tuples = [ ("onset", "duration", "trial_type") ]
        for onset in onsets:
            tsv_tuples.append( (onset, duration, "gabor") )
        tsv_dataframe = pandas.DataFrame(tsv_tuples)

        # Get .tsv path.
        func_file = file_dataframe[subject]["func"]
        tsv_path = Path(str(func_file.path).replace("_bold.nii", "_events.tsv"))

        # Write the .tsv
        tsv_dataframe.to_csv(tsv_path, sep="\t", header=False, index=False)


def write_func_jsons(file_dataframe):
    """
    Given a full file dataframe, writes appropriate jsons for functional files.


    Parameters
    ----------
    file_dataframe : DataFrame
        DataFrame created by organize_files() containing metadata about each file

    """

    for subject in file_dataframe:

        # Get json path.
        func_file = file_dataframe[subject]["func"]
        json_path = func_file.path.with_suffix(".json")

        # Acquire values we'll need in the json.
        repetition_time = file_dataframe[subject]["settings"].repetition_time()
        task = file_dataframe[subject]["func"].tasks()[0]
        volume_count = file_dataframe[subject]["func"].count_volumes()
        slice_timings = calculate_slice_timings(repetition_time, volume_count)

        # Prepare a dict to write to json.
        json_dict = {
            "RepetitionTime": repetition_time,
            "TaskName": task,
            "SliceTiming": slice_timings
        }

        # Write the json.
        with open(json_path, "w") as out_file:
            json.dump(json_dict, out_file, indent="\t")


def write_dataset_description(file_dataframe):
    """
    Given a complete file dataframe, writes the dataset description for the dataset.


    Parameters
    ----------
    file_dataframe : DataFrame
        DataFrame created by organize_files() containing metadata about each file

    """

    # Get dataset description path.
    anat_file = file_dataframe["107"]["anat"]
    description_path = anat_file.path.parent.parent.parent / f"dataset_description.json"

    # Prepare a dict to write to json.
    description_dict = {
        "Name": "Concurrent EEG/fMRI dataset",
        "BIDSVersion": "1.4.0",
        "Authors": ["Wendel Friedl", "Andreas Keil"]
    }

    # Write the json.
    with open(description_path, "w") as out_file:
        json.dump(description_dict, out_file, indent="\t")


def get_subject_id(path) -> str:
    """
    Returns the subject ID found in the input file name.

    Returns "None" if no subject ID found.


    Parameters
    ----------
    path : Path or str
        Path to the file you want to extract a subject ID from.


    Returns
    -------
    str
        ID of subject in filename.
    None
        If no subject ID found.

    """
    
    potential_subject_ids = re.findall(r"sub-(\d+)", str(path))

    try:
        subject_id = potential_subject_ids[-1]
    except IndexError:
        subject_id = None

    return subject_id


def extract_file(path):
    """
    Returns the object extracted from the input path.


    Parameters
    ----------
    path : Path
        Path to a file you want to extract metadata from.


    Returns
    -------
    Nifti
        If path leads to a .nii file.
    Vmrk
        If path leads to a .vmrk file.
    Dat
        If path leads to a .dat file.
    Settings
        If path leads to an fMRI settings file.
    None
        If path leads to none of the above.    

    """

    filetype = get_file_type(path)

    if filetype == "anat" or filetype == "func":
        return nifti.Nifti(path)
        
    elif filetype == "vmrk":
        return vmrk.Vmrk(path)

    elif filetype == "dat":
        return dat.Dat(path)

    elif filetype == "settings":
        return settings.Settings(path)

    else:
        return None


def get_file_type(path) -> str:
    """
    Returns the type of neuroimaging file the target file is.

    Returns any file type in FILETYPES. Returns unsorted if no filetype matched.


    Parameters
    ----------
    path : Path
        Path to a file you want to classify.
    

    Returns
    -------
    str
        Type of file the input path is.

    """

    for file_type, keyword_list in FILETYPES.items():
        for keyword in keyword_list:
            if keyword in path.name:
                return file_type
    
    return "unsorted"


def calculate_slice_timings(repetition_time: float, volume_count: int):
    """
    Returns the slice timings in a list.

    Slices must be interleaved in the + direction.


    Parameters
    ----------
    repetition_time : float
        Repetition time of each scan in the functional image.
    volume_count : int
        Number of volumes in the functional image.


    Returns
    -------
    list
        List of slice timings.

    """

    # Generate a slice order of length volume_count in interleaved order.
    slice_order = list(range(0, volume_count, 2)) + list(range(1, volume_count, 2))

    # Calculate the slice timing list from the slice order.
    slice_timings = [slice / volume_count * repetition_time for slice in slice_order]
    
    return slice_timings


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.

    """

    # Add command line argument to let user pick directory to target.
    parser = argparse.ArgumentParser(description="Makes a dataset BIDS compliant.")
    parser.add_argument("directory", type=str, help="Target directory.")

    args = parser.parse_args()

    main(args.directory)