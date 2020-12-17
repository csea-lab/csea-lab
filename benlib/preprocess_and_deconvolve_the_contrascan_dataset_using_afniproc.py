#!/usr/bin/env python3
"""
This script uses afni_proc.py to completely preprocess and deconvolve subjects of the contrascan dataset.

Created 12/15/2020 by Benjamin Velie
veliebm@gmail.com
"""

# Import bland and boring standard Python modules.
from datetime import datetime
import argparse
from pathlib import Path
import json
import sys
import pandas

# Import fresh and exciting CSEA custom modules.
from reference import subject_id_of, the_path_that_matches, task_name_of
from afni import AFNI


class Pipeline():
    """
    This class preprocesses and deconvolves a BIDSified dataset using afni_proc.py.
    """

    def __init__(self, bids_dir, subject_id):
    
        # Track time information.
        self.start_time = datetime.now()

        # Store parameters.
        self.bids_dir = bids_dir
        self.subject_id = subject_id

        # Tell the user what this class looks like internally.
        print(f"Executing {self.__repr__()}")

        # Store paths to directories we need in self.dirs.
        self.dirs = {}
        self.dirs["bids_root"] = Path(bids_dir)     # Root of the raw BIDS dataset.
        self.dirs["subject_dir"] = self.dirs["bids_root"] / f"sub-{subject_id}"
        self.dirs["output"] = self.dirs["bids_root"] / "derivatives" / "afni_proc" / "analysis_level-1" / f"sub-{subject_id}"    # Where we'll output the results of the first level analysis.

        # Get paths to all files necessary for the analysis. Store in a dict of dicts, except for anat_path.
        self.anat_path = the_path_that_matches(f"anat/*_T1w.nii", in_directory=self.dirs["subject_dir"])
        func_scans = list(self.dirs["subject_dir"].glob(f"func/*_bold.nii"))
        self.task_names = [task_name_of(path) for path in func_scans]
        self.paths = {}
        for task_name in self.task_names:
            self.paths[task_name] = {}
            self.paths[task_name]["events_tsv"] = the_path_that_matches(f"func/*_task-{task_name}*_events.tsv", in_directory=self.dirs["subject_dir"])
            self.paths[task_name]["func_scan"] = the_path_that_matches(f"func/*_bold.nii", in_directory=self.dirs["subject_dir"])

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        self.results = self.afni_proc()

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.

        I learned a lot about this topic from https://docs.python.org/3/reference/datamodel.html#basic-customization
        """

        return f"{self.__class__.__name__}(bids_dir='{self.bids_dir}', subject_id='{self.subject_id}')"


    def afni_proc(self):
        """
        Runs afni_proc.py for all tasks.

        afni_proc.py info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/afni_proc.py_sphx.html
        """

        working_directory = self.dirs["output"]
        args = ["-regress_stim_times"]

        for task_name in self.task_names:
            task_info_dir = self.dirs["output"] / f"task-{task_name}_info"
            self._split_columns_into_text_files(self.paths[task_name]["events_tsv"], task_info_dir)
            args += [task_info_dir/"onset.txt"]            

        args += ["-dsets"] + [self.paths[task_name]["func_scan"] for task_name in self.task_names]
        args += f"""                                      
            -subj_id {self.subject_id}
            -copy_anat {self.anat_path}
            -blocks tshift align tlrc volreg blur mask scale regress
            -tcat_remove_first_trs 1
            -align_opts_aea -cost lpc+ZZ -giant_move -check_flip
            -tlrc_base TT_N27+tlrc
            -tlrc_NL_warp
            -volreg_align_to MIN_OUTLIER
            -volreg_align_e2a
            -volreg_tlrc_warp
            -blur_size 4.0
            -regress_stim_labels stim
            -regress_basis CSPLINzero(0,14,8)
            -regress_opts_3dD -jobs 2
            -regress_motion_per_run
            -regress_censor_motion 0.3
            -regress_censor_outliers 0.05
            -regress_reml_exec
            -regress_compute_fitts
            -regress_make_ideal_sum sum_ideal.1D
            -regress_est_blur_epits
            -regress_est_blur_errts
            -regress_run_clustsim no
            -execute

        """.split()

        return AFNI(program="afni_proc.py", args=args, working_directory=working_directory)


    def write_report(self):
        """
        Write some files to subject folder to check the quality of the analysis.
        """

        # Store workflow info into a dict.
        workflow_info = {
            "You analyzed this subject": self.subject_id,
            "The workflow took this long to run": str(self.end_time - self.start_time),
            "You passed these arguments to the script": sys.argv
        }

        # Write the workflow dict to a json file.
        output_json_path = self.dirs["output"] / f"workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


    def _split_columns_into_text_files(self, tsv_path, output_dir):
        """
        Converts a tsv file into a collection of text files.

        Each column name becomes the name of a text file. Each value in that column is then
        placed into the text file. Don't worry - this won't hurt your .tsv file, which will lay
        happily in its original location.


        Parameters
        ----------
        tsv_path : str or Path
            Path to the .tsv file to break up.
        output_dir : str or Path
            Directory to write columns of the .tsv file to.
        """

        # Alert the user and prepare our paths.
        tsv_path = Path(tsv_path).absolute()
        output_dir = Path(output_dir).absolute()
        output_dir.mkdir(exist_ok=True, parents=True)
        print(f"Storing the columns of {tsv_path.name} as text files in directory {output_dir}")

        # Read the .tsv file into a DataFrame and fill n/a values with zero.
        tsv_info = pandas.read_table(
            tsv_path,
            sep="\t",
            na_values="n/a"
        ).fillna(value=0)

        # Write each column of the dataframe as a text file.
        for column_name in tsv_info:
            column_path = output_dir / f"{column_name}.txt"
            tsv_info[column_name].to_csv(column_path, sep=' ', index=False, header=False)


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Runs BIDSified subjects through an afni_proc.py pipeline crafted by Andreas. You must specify the path to the root of the BIDS directory. You must also specify EITHER a list of specific subjects OR all subjects.", fromfile_prefix_chars="@")
    parser.add_argument("--bids_dir", type=Path, required=True, help="<Mandatory> Path to the root of the BIDS directory.")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--subjects", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Preprocess a list of specific subject IDs. Mutually exclusive with --all.")
    group.add_argument('--all', action='store_true', help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects.")

    # Parse command-line args and make an empty list to store subject ids in.
    args = parser.parse_args()
    subject_ids = []

    # Option 1: Process all subjects.
    if args.all:
        bids_root = Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            subject_ids.append(subject_id_of(subject_dir))

    # Option 2: Process specific subjects.
    else:
        subject_ids = args.subjects

    for subject_id in subject_ids:

        # Run a first level analysis on a subject.
        Pipeline(
            bids_dir=args.bids_dir,
            subject_id=subject_id,
        )
