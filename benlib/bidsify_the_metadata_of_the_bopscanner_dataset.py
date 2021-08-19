#!/usr/bin/env python3
"""
This courageous script formats the metadata of the bidsified paths hewn from bidsify_paths.py.

Created 11/3/2020 by Ben Velie.
veliebm@gmail.com
"""

# Standard python modules.
import argparse
from pathlib import Path
import pandas
import json

# Modules I wrote myself for CSEA stuff.
from reference import subject_id_of, task_name_of
from vmrk import Vmrk
from dat import Dat
from nifti import Nifti


def main(bids_dir):
    """
    Finishes the diamond in the rough you created with bidsify_paths.py.
    """

    bids_dir = Path(bids_dir).absolute()
    path_list = [path for path in bids_dir.rglob("*") if path.is_file()]

    distilled_paths = filter_useful_paths_into_a_dataframe(path_list)

    write_func_tsvs(distilled_paths)

    write_func_jsons(distilled_paths)

    write_dataset_description(distilled_paths)
    

def filter_useful_paths_into_a_dataframe(path_list):
    """
    Classifies the file types of the paths we actually care about then finegles them into a DataFrame.
    """

    print("Gathering metadata.")

    paths_we_actually_care_about = [path for path in path_list if filetype_of(path) != "unsorted"]
    subjects = {subject_id_of(path) for path in paths_we_actually_care_about}
    filetypes = {filetype_of(path) for path in paths_we_actually_care_about}

    # Make a dict of paths where each key is the (subject id, file type) for each value, which is the path.
    dictionary_of_paths = {(subject_id_of(path), filetype_of(path)): path for path in paths_we_actually_care_about}

    # Load empty, but labelled, dataframe.
    nicely_organized_dataframe = pandas.DataFrame(columns=subjects, index=filetypes)

    # Load extracted files into dataframe.
    for subject in subjects:
        for filetype in filetypes:
            path = dictionary_of_paths[(subject, filetype)]

            if filetype == "vmrk":
                nicely_organized_dataframe[subject][filetype] = Vmrk(path)

            if filetype == "dat":
                nicely_organized_dataframe[subject][filetype] = Dat(path)

            if filetype == "func":
                nicely_organized_dataframe[subject][filetype] = Nifti(path)

    return nicely_organized_dataframe


def write_func_tsvs(distilled_paths):
    """
    Given a complete dataframe of files, writes appropriate tsvs for func files.

    Parameters
    ----------
    distilled_paths : DataFrame
        DataFrame created by organize_files() containing metadata about each file
    """

    print("Writing .tsv files for all functional scans.")

    def fixed(unfixed_onsets):
        """Returns fresh, clean onsets using the raw onsets we get from our .vmrk file."""
        return [onset for onset in unfixed_onsets]

    for subject in distilled_paths:
        unfixed_onsets = distilled_paths[subject]["vmrk"].onsets
        onsets = fixed(unfixed_onsets)
        duration = 2.5
        trial_types = distilled_paths[subject]["dat"].trial_codes

        # Prep a dataframe to write to .tsv.
        tsv_tuples = [ ("onset", "duration", "trial_type") ]
        for i, onset in enumerate(onsets):
            tsv_tuples.append( (onset, duration, trial_types[i]) )
        tsv_dataframe = pandas.DataFrame(tsv_tuples)

        # Get .tsv path.
        func_file = distilled_paths[subject]["func"]
        tsv_path = Path(str(func_file.path).replace("_bold.nii", "_events.tsv"))

        # Write the .tsv
        tsv_dataframe.to_csv(tsv_path, sep="\t", header=False, index=False)


def write_func_jsons(distilled_paths):
    """
    Given a complete dataframe of files, writes appropriate jsons for func files.

    Parameters
    ----------
    distilled_paths : DataFrame
        DataFrame created by organize_files() containing metadata about each file
    """

    print("Writing .json files for all functional scans.")

    def calculate_slice_timings_given(repetition_time: float, volume_count: int) -> list:
        """
        Returns the slice timings in a list. Slices must be interleaved in the + direction.
        """
        # Generate a slice order of length volume_count in interleaved order.
        slice_order = list(range(0, volume_count, 2)) + list(range(1, volume_count, 2))
        # Calculate the slice timing list from the slice order.
        slice_timings = [slice / volume_count * repetition_time for slice in slice_order]
        return slice_timings


    for subject in distilled_paths:

        path_to_functional_file = distilled_paths[subject]["func"]
        future_path_to_json_file = path_to_functional_file.path.with_suffix(".json")

        # Acquire values we'll need in the json.
        repetition_time = distilled_paths[subject]["func"].repetition_time
        task = task_name_of(distilled_paths[subject]["func"].path)
        number_of_volumes = distilled_paths[subject]["func"].number_of_volumes
        slice_timings = calculate_slice_timings_given(repetition_time, number_of_volumes)

        # Prepare a dict to write to json.
        json_dict = {
            "RepetitionTime": float(repetition_time),
            "TaskName": task,
            "SliceTiming": slice_timings
        }

        # Write the json.
        with open(future_path_to_json_file, "w") as out_file:
            json.dump(json_dict, out_file, indent="\t")


def write_dataset_description(distilled_paths):
    """
    Writes the description for the dataset.

    Parameters
    ----------
    distilled_paths : DataFrame
        DataFrame containing distilled metadata about each file
    """

    print("Writing a description of the dataset in the root of the BIDS directory.")
    
    # Get dataset description path.
    path_to_functional_file = distilled_paths["101"]["func"]
    future_path_to_description = path_to_functional_file.path.parent.parent.parent / f"dataset_description.json"

    # Prepare a dict to write to json.
    description_dict = {
        "Name": "bopscanner",
        "BIDSVersion": "1.4.0",
        "Authors": ["Kierstin Riels", "Benjamin Velie", "Andreas Keil"]
    }

    # Write the json.
    with open(future_path_to_description, "w") as out_file:
        json.dump(description_dict, out_file, indent="\t")


def filetype_of(path: Path) -> str:
    """
    Returns the type of file a path is.

    Returns "vmrk", "dat", "func", or "unsorted".
    """

    filetype = "unsorted"

    if path.suffix == ".vmrk":
        filetype = "vmrk"

    elif path.suffix == ".dat":
        filetype = "dat"

    elif path.suffix == ".nii":
        if "bold" in path.stem:
            filetype = "func"

    return filetype


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Finishes the diamond in the rough you created with bidsify_paths.py.")
    parser.add_argument("bids_dir", help="Path to the root of the BIDS directory.")

    args = parser.parse_args()

    main(args.bids_dir)
