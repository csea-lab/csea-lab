"""
Script to preprocess subjects in Nipype using an AFNI-based pipeline.

Subjects must be organized in BIDS-format. Also, this script was written to preprocess
the contrascan dataset, so I don't know how useful it'll be for a different dataset.

!!!WARNINGS!!!
    - If you don't have an X Server properly configured and running AND you're running this script
    in a container, the Align step will fail.


Created 9/17/2020 by Benjamin Velie.
veliebm@gmail.com

"""

from nipype import config
config.enable_debug_mode()

import os
import pytz
from datetime import datetime
import argparse
import re
import pathlib
import shutil
import json
import pandas
from contextlib import suppress

from nipype.caching.memory import Memory
import nipype.interfaces.afni as afni
import bids


class Preprocess():
    """
    This class preprocesses a subject from a BIDS-valid dataset.
    
    Here we use an AFNI-based pipeline.

    """

    def __init__(self, bids_dir, subject_id, clear_cache=False):

        print(f"Preprocessing subject {subject_id}")

        # Track time information.
        self.start_time = datetime.now()
        self._timezone = pytz.timezone("US/Eastern")
        
        # Store basic info.
        self.subject_id = subject_id
        self.bids = bids.layout.BIDSLayout(bids_dir)
        self.bids_dir = pathlib.Path(self.bids.root)
        self.clear_cache = clear_cache

        # Make subject directory.
        self.subject_dir = self.bids_dir / "derivatives" / "preprocessing" / f"sub-{subject_id}"
        self.subject_dir.mkdir(exist_ok=True, parents=True)

        # Load files of interest as BIDSFile objects.
        self.anat = self.bids.get(subject=107, datatype="anat", suffix="T1w", extensions=".nii")[0]
        self.func = self.bids.get(subject=107, datatype="func", suffix="bold", extensions=".nii")[0]
        self.events = self.bids.get(subject=107, datatype="func", suffix="events", extensions=".tsv")[0]

        # Make output directory.
        formatted_start_time = self.start_time.astimezone(self._timezone).strftime("date-%m.%d.%Y_time-%H.%M.%S")
        self.output_dir = self.subject_dir / formatted_start_time
        self.output_dir.mkdir(exist_ok=True)

        # Create nipype Memory object to manage nipype outputs.
        self.memory = Memory(str(self.subject_dir))
        if self.clear_cache:
            self._clear_cache()

        # Run our interfaces of interest. Store outputs in a dict. The order in which the interfaces run matters.
        self.results = dict()
        self.results["AlignEpiAnatPy"] = self.AlignEpiAnatPy()
        self.results["AutoTLRC"] = self.AutoTLRC()

        self.end_time = datetime.now()

        self.write_report()


    def AlignEpiAnatPy(self):
        """
        Aligns our anatomical image to our functional image.

        Wraps align_epi_anat.py.
        
        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/program_help/align_epi_anat.py.html
        Nipype interface info: https://nipype.readthedocs.io/en/latest/api/generated/nipype.interfaces.afni.preprocess.html


        Returns
        -------
        nipype InterfaceResult
            An object to access the outputs of the interface.

        """

        # Setup our X Server. Otherwise the interface won't work.
        os.environ["DISPLAY"] = "host.docker.internal:0"

        return self.memory.cache(afni.preprocess.AlignEpiAnatPy)(
            anat=self.anat.path,
            in_file=self.func.path,
            epi_base=10,
            epi2anat=False
        )


    def AutoTLRC(self):
        """
        Transforms our anatomical dataset to align with a standard space template.

        Wraps @auto_tlrc.
        
        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/program_help/@auto_tlrc.html
        Nipype interface info: https://nipype.readthedocs.io/en/latest/api/generated/nipype.interfaces.afni.preprocess.html#AutoTLRC


        Returns
        -------
        nipype InterfaceResult
            An object to access the outputs of the interface.

        """

        aligned_anat_path = next(pathlib.Path(self.results["AlignEpiAnatPy"].runtime.cwd).glob("*_T1w_al+orig.BRIK"))

        return self.memory.cache(afni.preprocess.AutoTLRC)(
            base="TT_avg152T1+tlrc",
            in_file=aligned_anat_path
        )


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

        # Store most of our results from each interface.
        for result in self.results.values():
            self._copy_result(result, ignore_patterns=(
                "*_copy+orig.BRIK",
                "*_bold.nii"
                ))


    def _clear_cache(self):
        """
        Deletes the nipype cache.

        """

        print("Clearing cache")
        cache_path = self.subject_dir / "nipype_mem"
        shutil.rmtree(cache_path)


    def _copy_result(self, interface_result, ignore_patterns=("nothing at all")):
        """
        Copies interface results from the cache to the subject directory.


        Parameters
        ----------
        interface_result : nipype interface result
            Copies files created by this interface.
        ignore_patterns : iterable
            Ignore Unix-style file patterns when copying.

        """

        interface_result_dir = pathlib.Path(interface_result.runtime.cwd)

        interface_name = interface_result_dir.parent.stem

        new_interface_result_dir = self.output_dir / interface_name

        print(f"Copying {interface_name} and ignoring {ignore_patterns}")

        # Supress error because shutil successfully copies the files even if it throws an exception.
        with suppress(OSError):
            shutil.copytree(
                src=interface_result_dir,
                dst=new_interface_result_dir,
                ignore=shutil.ignore_patterns(*ignore_patterns),
                copy_function=shutil.copyfile
        )


if __name__ == "__main__":
    """
    Enables usage of the program from a shell.

    The user must specify the location of the BIDS directory.
    They can also specify EITHER a specific subject OR all subjects.

    """

    parser = argparse.ArgumentParser(
        description="Preprocesses a subject from the contrascan dataset. You can use a config file by appending @ to the config file name.",
        epilog="The user must specify the location of the target BIDS directory. They must also specify EITHER a specific subject OR all subjects.",
        fromfile_prefix_chars="@"
    )

    parser.add_argument(
        "--bids_dir",
        "-b",
        type=str,
        required=True,
        help="<Mandatory> Path to the root of the BIDS directory."
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--subjects",
        "-s",
        metavar="SUBJECT_ID",
        type=str,
        nargs="+",
        help="<Mandatory> Preprocess a list of specific subject IDs. Mutually exclusive with --all."
    )

    group.add_argument(
        '--all',
        '-a',
        action='store_true',
        help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects."
    )

    parser.add_argument(
        "--clear-cache",
        "-c",
        action='store_true',
        help="Clears cache before running each subject. Use if you're testing processing times."
    )


    args = parser.parse_args()

    subject_ids = list()
    bids_dataset = bids.layout.BIDSLayout(args.bids_dir)

    # Option 1: Process all subjects.
    if args.all:
        subject_ids = bids_dataset.get_subjects()
    
    # Option 2: Process subjects selected by user.
    else:
        subject_ids = args.subjects

for subject_id in subject_ids:
    Preprocess(args.bids_dir, subject_id, args.clear_cache)
