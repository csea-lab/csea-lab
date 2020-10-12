#!/usr/bin/env python3

"""
A script to run an AFNI 2nd level analysis... but in Python???

Created 9/29/2020 by Benjamin Velie.
veliebm@gmail.com

"""

from datetime import datetime
import argparse
import re
from pathlib import Path
import json
import subprocess
from reference import with_whitespace_trimmed, subject_id_of


class SecondLevel():
    """
    This class runs a second level analysis on subjects for whom you've already run a first-level analysis.

    """

    def __init__(self, subject_ids, bids_dir, firstlevel_name):

        # Track when the program begins running.
        self.start_time = datetime.now()

        # Store input parameters.
        self.subject_ids = subject_ids
        self.bids_dir = bids_dir
        self.firstlevel_name = firstlevel_name

        # Tell the user what this class looks like internally.
        print(f"Executing {self.__repr__()}")

        # Store in self.dirs paths to directories we need.
        self.dirs = {}
        self.dirs["bids_root"] = Path(self.bids_dir)     # Location of the raw BIDS dataset.
        self.dirs["firstlevel_root"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-1"     # Location of all results of all our first-level analyses.
        self.dirs["secondlevel_root"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-2"    # Location where we'll store all results of all second-level analyses.
        self.dirs["output"] = self.dirs["secondlevel_root"] / self.firstlevel_name     # Location where we'll store the results of this specific analysis.

        # Store in self.paths paths to files we need. Each key is a subject ID, and each value is a path.
        self.paths = {}
        self.paths["deconvolve"] = {subject_id: self.dirs["firstlevel_root"]/f"sub-{subject_id}"/firstlevel_name/"nipype-interfaces-afni-model-Deconvolve/Decon.nii" for subject_id in subject_ids}
        self.paths["smoothed_image"] = {subject_id: self.dirs["firstlevel_root"]/f"sub-{subject_id}"/firstlevel_name/"nipype-interfaces-afni-model-Deconvolve/Decon.nii" for subject_id in subject_ids}
        self.paths["reml"] = {subject_id: self.dirs["firstlevel_root"]/f"sub-{subject_id}"/firstlevel_name/"nipype-interfaces-afni-model-Remlfit/Decon.nii_REML+tlrc.HEAD" for subject_id in subject_ids}

        # Raise an error if our files don't exist.
        for category in self.paths.values():
            for path in category.values():
                if not path.is_file():
                    raise OSError(f"{path} doesn't exist.")

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        # Run our regressions.
        self.runtimes = {}
        self.runtimes["ttest"] = self.ttest()
        self.runtimes["mema"] = self.mema()

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.
        
        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        
        """

        return f"SecondLevel(subject_ids={self.subject_ids}, bids_dir='{self.bids_dir}', firstlevel_name='{self.firstlevel_name}')"


    def ttest(self):
        """
        Run AFNI's 3dttest++ on each subject.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dttest++_sphx.html#ahelp-3dttest


        Returns
        -------
        CompletedProcess
            Contains some info about the 3dttest command execution.

        """

        # Get base command as a list of parameters to be fed into the command line.
        command = "3dttest++ -setA".split()

        # Append our deconvolve outfiles to the command.
        command += self.paths["deconvolve"].values()

        # Execute the command and return its results.
        return subprocess.run(
            command,
            cwd=self.dirs["output"]
        )


    def mema(self):
        """
        Runs AFNI's 3dMEMA 2nd-level analysis on the smoothed functional image using the matrix created by 3dREMLfit.
        
        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dMEMA_sphx.html#ahelp-3dmema


        Returns
        -------
        CompletedProcess
            Contains some info about the 3dMEMA command execution.

        """

        # Create base command to pass to interface. Remove all unnecessary whitespace by default.
        command = with_whitespace_trimmed(f"""
            3dMEMA   -prefix mema
            -jobs 2
            -missing_data 0
            """).split()

        # Append our 3dREMLfit outfiles to the command.
        command += "-set activation-vs-0".split()
        for subject_id in self.subject_ids:
            command += [
                subject_id,
                self.paths['smoothed_image'][subject_id],
                self.paths['reml'][subject_id]
            ]

        # Execute the command and return its results.
        return subprocess.run(
            command,
            cwd=self.dirs["output"]
        )        


    def write_report(self):
        """
        Writes files containing info about the analysis to help us stay sane.

        """

        # Store workflow info into a dict.
        workflow_info = {
            "Time to complete workflow": str(self.end_time - self.start_time),
            "First level analysis name": self.firstlevel_name,
            "Subject IDs used": self.subject_ids,
            "Interfaces used": "3dttest++, 3dMEMA",
        }

        # Write the workflow dict to a json file.
        output_json_path = self.dirs["output"] / "workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    """

    parser = argparse.ArgumentParser(
        description="Runs a 2nd-level analysis on subjects for whom you have already run a 1st-level analysis. You must specify the path to the raw BIDS dataset you ran your 1st-level analysis on. You must also specify whether to analyze EITHER a list of specific subjects OR all subjects. Finally, you must specify the name of the directory containing your 1st-level analysis results.",
        fromfile_prefix_chars="@"
    )

    parser.add_argument(
        "--bids_dir",
        "-b",
        required=True,
        help="<Mandatory> Path to the root of the BIDS directory. Example: '--bids_dir /readwrite/contrascan/bids_attempt-2'"
    )

    parser.add_argument(
        "--firstlevel_name",
        "-f",
        required=True,
        help="<Mandatory> Name of the 1st-level analysis directory to access within the BIDS directory. Example: to access 'bidsroot/derivatives/first_level_analysis/sub-$SUBJECT_ID/analysis_regressors-csf', use '--firstlevel_name analysis_regressors-csf'"
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--subjects",
        "-s",
        metavar="SUBJECT_ID",
        nargs="+",
        help="<Mandatory> Analyze a list of specific subject IDs. Example: '--subjects 107 108 110'. Mutually exclusive with --all."
    )

    group.add_argument(
        '--all',
        '-a',
        action='store_true',
        help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects."
    )

    group.add_argument

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
        firstlevel_name=args.firstlevel_name
    )
