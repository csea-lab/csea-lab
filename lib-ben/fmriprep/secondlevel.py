#!/usr/bin/env python3
"""
A script to run an AFNI 2nd level analysis... but in Python???

Created 9/29/2020 by Benjamin Velie.
veliebm@gmail.com
"""

# Import some standard Python libraries.
from datetime import datetime
import argparse
from pathlib import Path
import json

# Import some CSEA custom libraries.
from reference import subject_id_of, the_path_that_matches, task_name_of
from afni import AFNI


class SecondLevel():
    """
    This class runs a second level analysis on subjects for whom you've already run a first-level analysis.
    """

    def __init__(self, subject_ids, bids_dir, firstlevel_name, secondlevel_name):

        # Track when the program begins running.
        self.start_time = datetime.now()

        # Store input parameters.
        self.subject_ids = subject_ids
        self.bids_dir = bids_dir
        self.firstlevel_name = firstlevel_name
        self.secondlevel_name = secondlevel_name

        # Set name of analysis equal to 1st-level name unless the user provided a 2nd-level name.
        self.analysis_name = self.firstlevel_name
        if self.secondlevel_name:
            self.analysis_name = secondlevel_name

        # Tell the user what this class looks like internally.
        print(f"Executing {self.__repr__()}")

        # Store in self.dirs paths to directories we need.
        self.dirs = {}
        self.dirs["bids_root"] = Path(self.bids_dir)     # Location of the raw BIDS dataset.
        self.dirs["firstlevel"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-1" / self.firstlevel_name     # Location of the results of our first-level analyses.
        self.dirs["output"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-2" / self.analysis_name    # Location where we'll store the results of this second-level analysis.

        # Get a list of available tasks for our subjects.
        task_dirs = self.dirs["firstlevel"].glob(f"sub-*/task-*")
        self.task_names = {task_name_of(task_dir) for task_dir in task_dirs}

        # Gather into a dict of dicts all the paths we'll use. Sort by task and subject ID.
        self.paths = {}
        for task_name in self.task_names:
            self.paths[task_name] = {}
            for subject_id in self.subject_ids:
                self.paths[task_name][subject_id] = {}
                self.paths[task_name][subject_id]["deconvolve_outfile"] = the_path_that_matches(f"sub-{subject_id}_task-{task_name}*stats*.HEAD", in_directory=self.dirs["firstlevel"]/f"sub-{subject_id}/task-{task_name}/3dDeconvolve")
                self.paths[task_name][subject_id]["reml_outfile"] = the_path_that_matches(f"sub-{subject_id}_task-{task_name}*stats*.HEAD", in_directory=self.dirs["firstlevel"]/f"sub-{subject_id}/task-{task_name}/3dREMLfit")

        # Run our regressions.
        self.results = {}
        for task_name in self.task_names:
            self.results[task_name] = {}
            self.results[task_name]["3dttest++"] = self.ttest(task_name)
            self.results[task_name]["3dMEMA"] = self.mema(task_name)

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.
        
        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        """

        return f"SecondLevel(subject_ids={self.subject_ids}, bids_dir='{self.bids_dir}', firstlevel_name='{self.firstlevel_name}')"


    def ttest(self, task_name):
        """
        Run AFNI's 3dttest++ on the outfiles of the specified task.

        3dttest++ info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dttest++_sphx.html#ahelp-3dttest
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dttest++"

        # Get basic arguments as a list of parameters to be fed into the command line.
        args = "-setA ttest".split()

        # Append our deconvolve files as arguments.
        for subject_id in self.subject_ids:
            args += [f"sub-{subject_id}"] + [f'{self.paths[task_name][subject_id]["deconvolve_outfile"]}[4]']

        # Execute the command and return its results.
        return AFNI(program="3dttest++", args=args, working_directory=working_directory)


    def mema(self, task_name):
        """
        Runs AFNI's 3dMEMA 2nd-level analysis using the output bucket of 3dREMLfit.

        3dMEMA info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dMEMA_sphx.html#ahelp-3dmema
        How to gather specific sub-briks from the 3dREMLfit outfile: https://afni.nimh.nih.gov/pub/dist/doc/program_help/common_options.html
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dMEMA"

        # Create base arguments to pass to program.
        args = (f"""
            -prefix {self.firstlevel_name}_task-{task_name}_mema
            -jobs 4
            -verb 1
            -missing_data 0

            """).split()

        # Append our 3dREMLfit outfiles to the command.
        args += "-set activation-vs-0".split()
        for subject_id in self.subject_ids:
            args += [
                subject_id,
                f"{self.paths[task_name][subject_id]['reml_outfile']}[7]",     # Use a beta estimate from reml outfile
                f"{self.paths[task_name][subject_id]['reml_outfile']}[8]"       # Use a T value from reml outfile
            ]

        # Execute the command and return its results.
        return AFNI(program="3dMEMA", args=args, working_directory=working_directory)


    def write_report(self):
        """
        Writes files containing info about the analysis to help us stay sane.
        """

        # Store workflow info into a dict.
        workflow_info = {
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Title of first level analysis": self.firstlevel_name,
            "Title of second level analysis": self.analysis_name,
            "Subject IDs included": self.subject_ids
        }

        # Write the workflow dict to a json file.
        output_json_path = self.dirs["output"] / "workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Runs a 2nd-level analysis on subjects for whom you have already run a 1st-level analysis. You must specify the path to the raw BIDS dataset you ran your 1st-level analysis on. You must also specify whether to analyze EITHER a list of specific subjects OR all subjects. Finally, you must specify the title of the directory containing your 1st-level analysis results.", fromfile_prefix_chars="@")

    parser.add_argument("--bids_dir", "-b", required=True, help="<Mandatory> Path to the root of the BIDS directory. Example: '--bids_dir /readwrite/contrascan/bids_attempt-2'")
    parser.add_argument("--firstlevel_name", "-f", required=True, help="<Mandatory> Name of the 1st-level analysis directory to access within the BIDS directory. Example: to access 'bidsroot/derivatives/first_level_analysis/sub-$SUBJECT_ID/analysis_regressors-csf', use '--firstlevel_name analysis_regressors-csf'")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--subjects", "-s", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze a list of specific subject IDs. Example: '--subjects 107 108 110'. Mutually exclusive with --all.")
    group.add_argument('--all', '-a', action='store_true', help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects.")

    parser.add_argument("--secondlevel_name", default=None, help="Default: Name of the 1st-level analysis. What to name the 2nd-level analysis. Example: '--secondlevel_name hello_this_is_a_test'")

    # Parse args from the command line and create an empty list to store the subject ids we picked.
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

    # Launch the second level analysis on the subjects we picked.
    SecondLevel(
        subject_ids=subject_ids,
        bids_dir=args.bids_dir,
        firstlevel_name=args.firstlevel_name,
        secondlevel_name=args.secondlevel_name
    )
