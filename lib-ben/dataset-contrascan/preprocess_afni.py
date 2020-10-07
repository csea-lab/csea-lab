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
from datetime import datetime
import argparse
import re
from pathlib import Path
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

    def __init__(self, bids_dir, subject_id, output_dir, clear_cache=False):

        print(f"Preprocessing subject {subject_id}")

        # Track time information.
        self.start_time = datetime.now()
        
        # Store basic info.
        self.subject_id = subject_id
        self.bids = bids.layout.BIDSLayout(bids_dir)
        self.clear_cache = clear_cache

        # Store all our dirs in one dict.
        self.dirs = {}
        self.dirs["bids_root"] = Path(bids_dir)     # Root of the raw BIDS dataset.
        self.dirs["subject_root"] = self.dirs["bids_root"] / "derivatives" / "preprocessing_afni" / f"sub-{subject_id}"   # Root of where we'll output info for the subject.
        self.dirs["output"] = self.dirs["subject_root"] / output_dir    # Where we'll output the results of this particular preprocessing run.

        # Load files of interest as BIDSFile objects.
        self.files = {}
        self.files["anat"] = self.bids.get(subject=107, datatype="anat", suffix="T1w", extensions=".nii")[0]
        self.files["func"] = self.bids.get(subject=107, datatype="func", suffix="bold", extensions=".nii")[0]
        self.files["events"] = self.bids.get(subject=107, datatype="func", suffix="events", extensions=".tsv")[0]

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        # Create nipype Memory object to manage nipype outputs.
        self.memory = Memory(str(self.dirs["subject_root"]))
        if self.clear_cache:
            self._clear_cache()

        # Run our interfaces of interest. Store outputs in a dict. The order in which the interfaces run matters.
        self.results = {}
        self.results["AlignEpiAnatPy"] = self.AlignEpiAnatPy()
        self.results["AutoTLRC"] = self.AutoTLRC()

        # Write everything interesting to the computer.
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

        # Setup our X Server. Otherwise the interface won't work. Note that you still probably must manually start an X Server on your external computer.
        os.environ["DISPLAY"] = "host.docker.internal:0"

        return self.memory.cache(afni.preprocess.AlignEpiAnatPy)(
            anat=self.files["anat"].path,
            in_file=self.files["func"].path,
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

        aligned_anat_path = next(Path(self.results["AlignEpiAnatPy"].runtime.cwd).glob("*_T1w_al+orig.BRIK"))

        return self.memory.cache(afni.preprocess.AutoTLRC)(
            base="TT_avg152T1+tlrc",
            in_file=aligned_anat_path
        )


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        # Store info about the workflow in a dict.
        workflow_info = {
            "Time to complete workflow" : str(self.end_time - self.start_time),
            "Cache cleared before analysis": self.clear_cache,
            "Subject ID": self.subject_id,
            "Interfaces used": self.results.keys()
        }

        # Write the dict to a json file.
        output_json_path = self.dirs["output"] / f"workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")

        # Copy over most of our results from each interface.
        for result in self.results.values():
            self._copy_cache(result, ignore_patterns=(
                "*_copy+orig.BRIK",
                "*_bold.nii"
                ))


    def _clear_cache(self):
        """
        Deletes the nipype cache.

        """

        print("Clearing cache")
        shutil.rmtree(self.memory.base_dir)


    def _copy_cache(self, interface_result, ignore_patterns=["nothing at all"]):
        """
        Copies an interface result from the cache to the subject directory.


        Parameters
        ----------
        interface_result : InterfaceResult
            Copies files created by this interface.
        ignore_patterns : list
            Ignore Unix-style file patterns when copying.

        """

        # Get name of interface and paths to old dir and new dir.
        old_result_dir = Path(interface_result.runtime.cwd)
        interface_name = old_result_dir.parent.stem
        new_result_dir = self.dirs["output"] / interface_name

        print(f"Copying {interface_name} and ignoring {ignore_patterns}")

        # Delete result dir if it already exists.
        if new_result_dir.exists():
            shutil.rmtree(new_result_dir)

        # Recursively copy old result dir to new location. Suppress OSError because the copying works even if an OSError is thrown.
        with suppress(OSError):
            shutil.copytree(
                src=old_result_dir,
                dst=new_result_dir,
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
        description=f"Preprocess a subject from the contrascan dataset. You must specify the path to the target BIDS directory. You also need to tell the program what you'd like the output directory to be named. Regarding which subjects to preprocess, you can specify EITHER a list of specific subjects OR all subjects. Finally, you can use a config file by appending @ to the config file name and passing it as a positional argument to this program. (i.e. 'python {__file__} @config.txt [args...]')",
        fromfile_prefix_chars="@"
    )

    parser.add_argument(
        "--bids_dir",
        "-b",
        type=str,
        required=True,
        help="<Mandatory> Path to the root of the BIDS directory."
    )

    parser.add_argument(
        "--output_dir",
        "-o",
        type=str,
        required=True,
        help="<Mandatory> Name of output directory to use within subject directory."
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

    # Preprocess the subjects we've selected.
    for subject_id in subject_ids:
        Preprocess(
            bids_dir=args.bids_dir,
            subject_id=subject_id,
            output_dir=args.output_dir,
            clear_cache=args.clear_cache,
        )
