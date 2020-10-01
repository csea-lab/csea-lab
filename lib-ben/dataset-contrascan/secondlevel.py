"""
A script to run an AFNI 2nd level analysis... but in Python???

Created 9/29/2020 by Benjamin Velie.
veliebm@gmail.com

"""

from datetime import datetime
import argparse
import re
import pathlib
import json
import subprocess

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

        # Tell the user what this class looks like internally.
        print(f"Executing {self.__repr__()}")

        # Store in self.dirs paths to directories we need.
        self.dirs = dict()
        self.dirs["bids_root"] = pathlib.Path(self.bids_dir)     # Location of the raw BIDS dataset.
        self.dirs["firstlevel_root"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-1"     # Location of all results of all our first-level analyses.
        self.dirs["secondlevel_root"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-2"    # Location where we'll store all results of all second-level analyses.
        self.dirs["output"] = self.dirs["secondlevel_root"] / self.secondlevel_name     # Location where we'll store the results of this specific analysis.

        # Store in self.paths paths to files we need.
        self.paths = dict()
        self.paths["deconvolve_outfile"] = {subject_id: self.dirs["firstlevel_root"]/f"sub-{subject_id}"/firstlevel_name/"nipype-interfaces-afni-model-Deconvolve"/"Decon.nii" for subject_id in subject_ids}

        # Raise an error if our files don't exist.
        for category in self.paths.values():
            for path in category.values():
                if not path.is_file():
                    raise OSError(f"{path} doesn't exist.")

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        # Run our regression.
        self.ttest()

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.
        
        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        
        """

        return f"SecondLevel(subject_ids={self.subject_ids}, bids_dir='{self.bids_dir}', firstlevel_name='{self.firstlevel_name}', secondlevel_name='{self.secondlevel_name}')"


    def ttest(self):
        """
        Run AFNI's 3dttest on each subject.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dttest.html


        Returns
        -------
        subprocess.CompletedProcess
            Contains some info about the 3dttest command execution.

        """

        # Get base command as a list of parameters to be fed into the command line.
        command = "3dttest -base1 0 -set2".split()
        
        # Append our deconvolve outfiles to the command.
        for path in self.paths["deconvolve_outfile"].values():
            command.append(path)

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
            "Interfaces used": "3dttest",
        }

        # Write the workflow dict to a json file.
        output_json_path = self.dirs["output"] / "workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


def _get_subject_id(path) -> str:
    """
    Returns the subject ID found in the input filename.


    Inputs
    ------
    path : str or pathlib.Path
        String or path containing the subject ID.


    Returns
    -------
    str
        Subject ID found in the filename


    Raises
    ------
    IndexError
        If no subject ID found in the filename.

    """
    
    potential_subject_ids = re.findall(r"sub-(\d+)", str(path))

    subject_id = potential_subject_ids[-1]

    return subject_id


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

    parser.add_argument(
        "--secondlevel_name",
        "-o",
        required=True,
        help="<Mandatory> What we shall name 2nd-level analysis directory. Example: '--secondlevel_name secondlevel_attempt-4'"
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


    args = parser.parse_args()

    subject_ids = list()

    # Option 1: Process all subjects.
    if args.all:
        bids_root = pathlib.Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            subject_ids.append(_get_subject_id(subject_dir))

    # Option 2: Process specific subjects.
    else:
        subject_ids = args.subjects


    SecondLevel(
        subject_ids=subject_ids,
        bids_dir=args.bids_dir,
        firstlevel_name=args.firstlevel_name,
        secondlevel_name=args.secondlevel_name,
    )
