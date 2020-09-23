"""
A script to run a 1st-level analysis the way it was meant to be done.

That is, without any of these darn jupyter notebooks or nipype nodes.

Created 9/9/2020 by Benjamin Velie.
veliebm@gmail.com

"""

import pytz
from datetime import datetime
import argparse
import re
import pathlib
import shutil
import json
import pandas

from nipype.interfaces.fsl import SUSAN
from nipype.interfaces.afni import Deconvolve

from nipype.caching.memory import Memory


class FirstLevel():
    """
    This class runs a first level analysis on a subject in the fMRIPrepped contrascan dataset.

    """

    def __init__(self, bids_dir, subject_id, regressor_names, output_dir=None, clear_cache=False):

        # Track time information.
        self.start_time = datetime.now()
        self.timezone = pytz.timezone("US/Eastern")
        
        # Store basic info.
        self.subject_id = subject_id
        self.bids_dir = pathlib.Path(bids_dir)
        self.regressor_names = regressor_names
        self.clear_cache = clear_cache

        # Make subject directory.
        self.subject_dir = self.bids_dir / "derivatives" / "first_level_analysis" / f"sub-{subject_id}"
        self.subject_dir.mkdir(exist_ok=True, parents=True)

        # Make directory to store regressor files.
        self.regressor_dir = self.subject_dir / "regressors"
        self.regressor_dir.mkdir(exist_ok=True)

        # Make directory to store subject info.
        self.subject_info_dir = self.subject_dir / "subject_info"
        self.subject_info_dir.mkdir(exist_ok=True)

        # Make output directory.
        if not output_dir:
            formatted_start_time = self.start_time.astimezone(self.timezone).strftime("date-%m.%d.%Y_time-%H.%M.%S")
            self.output_dir = self.subject_dir / formatted_start_time
        else:
            self.output_dir = self.subject_dir / output_dir
        self.output_dir.mkdir(exist_ok=True)

        # Get paths to all files necessary for the analysis.
        self.bold_json_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_task-*_bold.json"))[0]
        self.bold_tsv_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_task-*_events.tsv"))[0]
        self.anat_path = list(self.bids_dir.rglob(f"anat/sub-{subject_id}*_desc-preproc_T1w.nii.gz"))[0]
        self.func_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_desc-preproc_bold.nii.gz"))[0]
        self.regressors_tsv_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_desc-confounds_regressors.tsv"))[0]

        # Create nipype Memory object to manage nipype outputs.
        self.memory = Memory(str(self.subject_dir))
        if self.clear_cache:
            print("Clearing cache")
            cache_path = self.subject_dir / "nipype_mem"
            shutil.rmtree(cache_path)

        # Run necessary interfaces.
        self.SUSAN_result = self.SUSAN()
        self.Deconvolve_result = self.Deconvolve(self.SUSAN_result)
        
        self.end_time = datetime.now()

        self.write_report()


    def SUSAN(self):
        """
        Smooths the functional image.

        Wraps FSL's SUSAN.

        FSL command info: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/SUSAN
        Nipype interface info: https://nipype.readthedocs.io/en/0.12.0/interfaces/generated/nipype.interfaces.fsl.preprocess.html#susan


        Returns
        -------
        nipype InterfaceResult
            Information about the outputs of SUSAN.

        """

        return self.memory.cache(SUSAN)(
            in_file=str(self.func_path),
            brightness_threshold=2000.0,
            fwhm=5.0,
            output_type="NIFTI"
        )


    def Deconvolve(self, SUSAN_result):
        """
        Runs the first level regression on the smoothed functional image.

        Wraps AFNI's 3dDeconvolve.
        
        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dDeconvolve.html
        Nipype interface info: https://nipype.readthedocs.io/en/latest/api/generated/nipype.interfaces.afni.model.html#Deconvolve


        Parameters
        ----------
        SUSAN_result : nipype InterfaceResult
            Information about the outputs of the SUSAN step.


        Returns
        -------
        nipype InterfaceResult
            Information about the outputs of Deconvolve.

        """

        # Prepare regressor text files to scan into the interface.
        self._break_tsv(self.bold_tsv_path, self.subject_info_dir)
        self._break_tsv(self.regressors_tsv_path, self.regressor_dir)
        
        amount_of_regressors = 1 + len(self.regressor_names)

        # Create string to pass to interface. Remove all unnecessary whitespace by default.
        arg_string = ' '.join(f"""

            -input {SUSAN_result.outputs.smoothed_file}
            -GOFORIT 4
            -polort A
            -num_stimts {amount_of_regressors}
            -stim_times 1 {self.subject_info_dir/'onset'}.txt 'CSPLINzero(0,18,10)'
            -stim_label 1 all
            -fout

        """.replace("\n", " ").split())

        # Add individual stim files to the string.
        for i, regressor_name in enumerate(self.regressor_names):
            stim_number = i + 2

            stim_file_info = f"-stim_file {stim_number} {self.regressor_dir/regressor_name}.txt -stim_base {stim_number}"
            stim_label_info = f"-stim_label {stim_number} {regressor_name}"

            arg_string += f" {stim_file_info} {stim_label_info}"


        return self.memory.cache(Deconvolve)(
            args=arg_string
        )


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        # Copy results of each interface to its own dir.
        self._copy_result(self.SUSAN_result, ignore_pattern="*_desc-preproc_bold_smooth.nii")
        self._copy_result(self.Deconvolve_result)

        # Write info about the workflow into a json file.
        workflow_info = {
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Regressors included": self.regressor_names,
            "Cache cleared before analysis": self.clear_cache,
            "Subject ID": self.subject_id,
            "Preprocessing source": "fMRIPrep"
        }

        output_json_path = self.output_dir / f"workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


    def _break_tsv(self, tsv_path, output_dir):
        """
        Converts a tsv file into a collection of text files.

        Each column name becomes the name of a text file. Each value in that column is then
        placed into the text file.

        """

        tsv_path = pathlib.Path(tsv_path)
        output_dir = pathlib.Path(output_dir)

        print(f"Breaking up {tsv_path.name} and storing columns in {output_dir}")

        # Read the .tsv file into a dataframe and fill n/a values with zero.
        tsv_info = pandas.read_table(
            tsv_path,
            sep="\t",
            na_values="n/a"
        ).fillna(value=0)

        for column_name in tsv_info:
            column_path = output_dir / f"{column_name}.txt"
            tsv_info[column_name].to_csv(column_path, sep=' ', index=False, header=False)


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

    Returns "None" if no subject ID found.

    """
    
    potential_subject_ids = re.findall(r"sub-(\d+)", str(path))

    try:
        subject_id = potential_subject_ids[-1]
    except IndexError:
        subject_id = None

    return subject_id


if __name__ == "__main__":
    """
    Enables usage of the program from a shell.

    The user must specify the location of the BIDS directory.
    They can also specify EITHER a specific subject OR all subjects. Cool stuff!

    """

    parser = argparse.ArgumentParser(
        description="Runs a first-level analysis on a subject from the fMRIPrepped contrascan dataset.",
        epilog="The user must specify the location of the BIDS directory fMRIPrep was used on. They must also specify EITHER a specific subject OR all subjects. Cool stuff!"
    )

    parser.add_argument(
        "bids_dir",
        type=str,
        help="Root of the BIDS directory."
    )

    parser.add_argument(
        "-r",
        "--regressors",
        type=str,
        nargs='+',
        required=True,
        help="List of regressors to use from fMRIPrep."
    )

    parser.add_argument(
        "-c",
        "--clear-cache",
        action='store_true',
        help="Clears cache before running each subject. Use if you're testing processing times."
    )

    parser.add_argument(
        "-o",
        "--output_dir",
        type=str,
        help="Directory to store outputs in. Defaults to current date/time. Automaticall placed in subject directory."
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
            FirstLevel(bids_dir, subject_id, args.regressors, output_dir=args.output_dir, clear_cache=args.clear_cache)

    # Option 2: Process a single subject.
    else:
        FirstLevel(args.bids_dir, args.subject, args.regressors, output_dir=args.output_dir, clear_cache=args.clear_cache)