#!/usr/bin/env python3

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

# Import some standard Python libraries. -------------------
from datetime import datetime
import argparse
from pathlib import Path
import json


# Import some friendly and nice CSEA custom libraries. -------------------
from reference import subject_id_of, the_path_that_matches
from afni import AFNI


class Preprocess():
    """
    This class preprocesses a subject using the power of AFNI.

    """

    def __init__(self, bids_dir, subject_id):

        # Track time information. Store parameters. -------------------
        self.start_time = datetime.now()
        self.bids_dir = bids_dir
        self.subject_id = subject_id


        # Tell the user what this class looks like internally. ----------------
        print(f"Executing {self.__repr__()}")


        # Store all our dirs in one dict. -----------------------
        self.dirs = {}
        self.dirs["bids_root"] = Path(self.bids_dir)     # Root of the raw BIDS dataset.
        self.dirs["output"] = self.dirs["bids_root"] / "derivatives" / "preprocessing_afni" / f"sub-{subject_id}"   # Where we'll output info for the subject.


        # Gather paths to the files we need. ------------------------
        self.paths = {}
        self.paths["events_tsv"] = the_path_that_matches(f"**/func/sub-{subject_id}*_task-*_events.tsv", in_directory=self.dirs["bids_root"])
        self.paths["anat"] = the_path_that_matches(f"sub-{subject_id}/anat/sub-{subject_id}*_T1w.nii", in_directory=self.dirs["bids_root"])
        self.paths["func"] = the_path_that_matches(f"sub-{subject_id}/func/sub-{subject_id}*_bold.nii", in_directory=self.dirs["bids_root"])


        # Create any directory that doesn't exist. -------------------------
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)


        # Run our programs of interest. Store outputs in a dict. -----------------------
        self.results = {}
        self.results["align_epi_anat"] = self.align_epi_anat()


        # Record end time and write our report. --------------------------
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.
        
        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        
        """

        return f"{self.__class__.__name__}(bids_dir='{self.bids_dir}', subject_id='{self.subject_id}')"


    def align_epi_anat(self):
        """
        Aligns our anatomical image to our functional image.

        Wraps align_epi_anat.py.
        
        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/align_epi_anat.py_sphx.html#ahelp-align-epi-anat-py


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to align_epi_anat.py. ---------------------
        args = f"""
            -anat {self.paths["anat"]}
            -epi {self.paths["func"]}
            -epi_base 10
        """.split()


        # Run align_epi_anat.py and return info about it. -----------------------
        return AFNI(
            where_to_create_working_directory=self.dirs["output"],
            program="align_epi_anat.py",
            args=args
        )


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        # Store workflow info into a dict. --------------------------------
        workflow_info = {
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Subject ID": self.subject_id,
            "Programs used": [result.program for result in self.results.values()],
            "Commands executed": [[result.program] + [result.args] for result in self.results.values()]
        }


        # Write the workflow dict to a json file. ------------------------------------
        output_json_path = self.dirs["output"] / f"workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.

    """

    parser = argparse.ArgumentParser(
        description=f"Preprocess a subject from the contrascan dataset. You must specify the path to the target BIDS directory. You also need to tell the program what you'd like the output directory to be named. Regarding which subjects to preprocess, you can specify EITHER a list of specific subjects OR all subjects.",
        fromfile_prefix_chars="@"
    )

    parser.add_argument(
        "--bids_dir",
        "-b",
        type=Path,
        required=True,
        help="<Mandatory> Path to the root of the BIDS directory."
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--subjects",
        "-s",
        metavar="SUBJECT_ID",
        nargs="+",
        help="<Mandatory> Preprocess a list of specific subject IDs. Mutually exclusive with --all."
    )

    group.add_argument(
        '--all',
        '-a',
        action='store_true',
        help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects."
    )


    # Parse command-line args and make an empty list to store subject ids in. -----------------------
    args = parser.parse_args()
    subject_ids = []


    # Option 1: Select all subjects. ---------------------------
    if args.all:
        bids_root = Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            subject_ids.append(subject_id_of(subject_dir))


    # Option 2: Select specific subjects. -------------------------
    else:
        subject_ids = args.subjects


    # Preprocess the subjects we've selected. ------------------------
    for subject_id in subject_ids:
        Preprocess(
            bids_dir=args.bids_dir,
            subject_id=subject_id,
        )
