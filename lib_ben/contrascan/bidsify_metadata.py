"""
Extracts the necessary metadata from a dataset to make it BIDS compliant. 

The dataset must already be named according to BIDS standards. Thus, I recommend running bidsify_paths.py before this program.

Created 8/13/2020 by Benjamin Velie.
veliebm@gmail.com
"""

# Standard python modules
import pathlib
import argparse
import re
import pandas
import json

# Python modules I wrote for CSEA
from lib_ben.contrascan import dat, vmrk, settings, nifti


FILETYPES = {
            "anat": ["_T1w.nii"],
            "func": ["_bold.nii"],
            "vmrk": [".vmrk"],
            "dat": [".dat"],
            "settings": ["settings.txt"]
            }


def main(input_dir):
    
    # Force input dir to become a path object.
    input_dir_path = pathlib.Path(input_dir)

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
    Organizes a list of paths by subject name and file type. Returns a dataframe.
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
    """

    for subject in file_dataframe:
        onsets = file_dataframe[subject]["vmrk"].timings()
        duration = file_dataframe[subject]["dat"].average_duration()

        # Prep a dataframe to write to .tsv.
        tsv_tuples = [ ("onset", "duration") ]
        for onset in onsets:
            tsv_tuples.append( (onset, duration) )
        tsv_dataframe = pandas.DataFrame(tsv_tuples)

        # Get .tsv path.
        func_file = file_dataframe[subject]["func"]
        tsv_path = pathlib.Path(str(func_file.path).replace("_bold.nii", "_events.tsv"))

        # Write the .tsv
        tsv_dataframe.to_csv(tsv_path, sep="\t", header=False, index=False)


def write_func_jsons(file_dataframe):
    """
    Given a full file dataframe, writes appropriate jsons for functional files.
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
    """

    for file_type, keyword_list in FILETYPES.items():
        for keyword in keyword_list:
            if keyword in path.name:
                return file_type
    
    return "unsorted"


def calculate_slice_timings(repetition_time: float, volume_count: int):
    """
    Returns the slice timings in a list.

    Slice must be interleaved in the + direction.
    """

    # Generate a slice order of length volume_count in interleaved order.
    slice_order = list(range(0, volume_count, 2)) + list(range(1, volume_count, 2))

    # Calculate the slice timing list from the slice order.
    slice_timings = [slice / volume_count * repetition_time for slice in slice_order]
    
    return slice_timings


if __name__ == "__main__":

    # Add command line argument to let user pick directory to target.
    parser = argparse.ArgumentParser(description="Makes a dataset BIDS compliant.")
    parser.add_argument("directory", type=str, help="Target directory.")

    args = parser.parse_args()

    main(args.directory)