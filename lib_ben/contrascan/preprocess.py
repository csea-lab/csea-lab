"""
Script to preprocess subjects in Nipype using an AFNI-based pipeline.

Subjects must be organized in BIDS-format. Also, this script was written to preprocess
the contrascan dataset, so I don't know how useful it'll be for a different dataset.

Created 9/17/2020 by Benjamin Velie.
veliebm@gmail.com

"""

import nipype.interfaces.afni as afni

import pytz
from datetime import datetime
import argparse
import re
import pathlib
import shutil
import json
import pandas

from nipype.caching.memory import Memory


class Preprocess():
    """
    This class preprocesses a subject from a BIDS-valid dataset.
    
    Here we use an AFNI-based pipeline.

    """

    def __init__(self, bids_dir, subject_id, clear_cache=False):

        # Track time information.
        self.start_time = datetime.now()
        self._timezone = pytz.timezone("US/Eastern")
        
        # Store basic info.
        self.subject_id = subject_id
        self.bids_dir = pathlib.Path(bids_dir)
        self.clear_cache = clear_cache

        # Make subject directory.
        self.subject_dir = self.bids_dir / "derivatives" / "preprocessing" / f"sub-{subject_id}"
        self.subject_dir.mkdir(exist_ok=True, parents=True)

        # Make output directory.
        formatted_start_time = self.start_time.astimezone(self._timezone).strftime("time-%H.%M.%S_date-%m.%d.%Y")
        self.output_dir = self.subject_dir / formatted_start_time
        self.output_dir.mkdir(exist_ok=True)

        # Create nipype Memory object to manage nipype outputs.
        self.memory = Memory(str(self.subject_dir))
        if self.clear_cache:
            self._clear_cache()

        self.end_time = datetime.now()

        self.write_report()


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        # Write info about the workflow into a json file.
        workflow_info = {
            "Time to complete workflow" : str(self.end_time - self.start_time),
            "Cache cleared before analysis": self.clear_cache,
            "Subject ID": self.subject_id
        }

        output_json_path = self.output_dir / f"workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")

    def _clear_cache(self):
        """
        Deletes the nipype cache.

        """

        print("Clearing cache")
        cache_path = self.subject_dir / "nipype_mem"
        shutil.rmtree(cache_path)


    def _copy_result(self, interface_result, ignore_pattern="nothing at all"):
        """
        Copies interface results from the cache to the subject directory.


        Parameters
        ----------
        interface_result : nipype interface result
            Copies files created by this interface.
        ignore_pattern : str
            Ignore Unix-style file pattern when copying.

        """

        interface_result_dir = pathlib.Path(interface_result.runtime.cwd)

        interface_name = interface_result_dir.parent.stem

        new_interface_result_dir = self.output_dir / interface_name

        print(f"Copying {interface_name} and ignoring {ignore_pattern}")

        shutil.copytree(
            src=interface_result_dir,
            dst=new_interface_result_dir,
            ignore=shutil.ignore_patterns(ignore_pattern)
        )


def _get_subject_id(path) -> str:
    """
    Returns the subject ID found in the input file name.

    
    Parameters
    ----------
    path: str or pathlib.Path
        String to search or path to the target file.


    Returns
    -------
    str
        Subject ID detected closest to the end of the filename.


    Raises
    ------
    LookupError
        If no subject ID found.

    """
    
    try:
        return re.findall(r"sub-(\d+)", str(path))[-1]
    except IndexError:
        raise LookupError("No subject ID found in path.")


if __name__ == "__main__":
    """
    Enables usage of the program from a shell.

    The user must specify the location of the BIDS directory.
    They can also specify EITHER a specific subject OR all subjects. Cool stuff!

    """

    parser = argparse.ArgumentParser(
        description="Preprocesses a subject from the contrascan dataset.",
        epilog="The user must specify the location of the target BIDS directory. They must also specify EITHER a specific subject OR all subjects. Cool stuff!"
    )

    parser.add_argument(
        "bids_dir",
        type=str,
        help="Root of the BIDS directory."
    )

    parser.add_argument(
        "-c",
        "--clear-cache",
        action='store_true',
        help="Clears cache before running each subject. Use if you're testing processing times."
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "-s",
        "--subject",
        type=str,
        help="Analyze a specific subject ID."
    )

    group.add_argument(
        '-a',
        '--all',
        action='store_true',
        help="Analyze all subjects."
    )


    args = parser.parse_args()

    # Option 1: Process all subjects.
    if args.all:
        bids_dir = pathlib.Path(args.bids_dir)

        # Extract subject id's from the folder names in bids_dir and run them through the program.
        for subject_dir in bids_dir.glob("sub-*"):
            subject_id = _get_subject_id(subject_dir)
            print(f"Processing subject {subject_id}")
            Preprocess(bids_dir, subject_id, args.clear_cache)

    # Option 2: Process a single subject.
    else:
        Preprocess(args.bids_dir, args.subject, args.clear_cache)
