#!/usr/bin/env python3

"""
A script to run a 1st-level analysis using the beautiful and eternal AFNI.

Created 9/9/2020 by Benjamin Velie.
veliebm@gmail.com

"""

# Import some standard Python libraries.
from datetime import datetime
import argparse
from pathlib import Path
import shutil
import json
import pandas

# Import some CSEA custom libraries. (Scrappy and made with love :))
from reference import subject_id_of, the_path_that_matches, split_columns_into_text_files
from afni import AFNI


class FirstLevel():
    """
    This class runs a first level analysis on a subject in the fMRIPrepped contrascan dataset.

    """

    def __init__(self, bids_dir, subject_id, regressor_names: list, outputs_title):
    
        # Track time information.
        self.start_time = datetime.now()
        
        # Store parameters.
        self.bids_dir = bids_dir
        self.subject_id = subject_id
        self.regressor_names = regressor_names
        self.outputs_title = outputs_title

        # Tell the user what this class looks like internally.
        print(f"Executing {self.__repr__()}")

        # Store paths to directories we need in self.dirs.
        self.dirs = {}
        self.dirs["bids_root"] = Path(bids_dir)     # Root of the raw BIDS dataset.
        self.dirs["fmriprep_root"] = self.dirs["bids_root"] / "derivatives" / "preprocessing" / f"sub-{subject_id}" / "fmriprep" / f"sub-{subject_id}"   # Root of fmriprep outputs for this subject.
        self.dirs["output"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-1" / f"sub-{subject_id}" / outputs_title    # Where we'll output the results of the first level analysis.
        self.dirs["regressors"] = self.dirs["output"] / "all_regressors_available"      # Where we'll store our regressor text files.
        self.dirs["subject_info"] = self.dirs["output"] / "subject_info"      # Where we'll store our subject's onsets in a text file.

        # Get paths to all files necessary for the analysis. Raise an error if Python can't find a file.
        self.paths = {}
        self.paths["events_tsv"] = the_path_that_matches(f"sub-{subject_id}/func/sub-{subject_id}*_task-*_events.tsv", in_directory=self.dirs["bids_root"])
        self.paths["anat"] = the_path_that_matches(f"anat/sub-{subject_id}*_space-*_desc-preproc_T1w.nii.gz", in_directory=self.dirs["fmriprep_root"])
        self.paths["func"] = the_path_that_matches(f"func/sub-{subject_id}*_space-*_desc-preproc_bold.nii.gz", in_directory=self.dirs["fmriprep_root"])
        self.paths["mask"] = the_path_that_matches(f"func/sub-{subject_id}*_space-*_desc-brain_mask.nii.gz", in_directory=self.dirs["fmriprep_root"])
        self.paths["regressors_tsv"] = the_path_that_matches(f"func/sub-{subject_id}*_desc-confounds_timeseries.tsv", in_directory=self.dirs["fmriprep_root"])

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        # Run our programs of interest. Must be run in the correct order.
        self.results = {}
        self.results["3dmerge"] = self.merge()
        self.results["3dDeconvolve"] = self.deconvolve()
        self.results["3dREMLfit"] = self.remlfit()

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.

        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization

        """

        return f"{self.__class__.__name__}(bids_dir='{self.bids_dir}', subject_id='{self.subject_id}', regressor_names={self.regressor_names}, outputs_title='{self.outputs_title}')"


    def merge(self):
        """
        Smooths the functional image.

        3dmerge info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dmerge_sphx.html#ahelp-3dmerge

        """

        working_directory = self.dirs["output"] / "3dmerge"

        # Create the list of arguments and run 3dmerge.
        args = f"""
                -1blur_fwhm 5.0
                -doall
                -prefix {self.paths['func'].stem}_smoothed
                {self.paths['func']}
        
        """.split()
        merge_result = AFNI(program="3dmerge", args=args, working_directory=working_directory)

        # Store the path of the smoothed image as an attribute of the result object.
        merge_result.smoothed_image = the_path_that_matches("*.HEAD", in_directory=merge_result.working_directory)

        return merge_result


    def deconvolve(self):
        """
        Runs the 1st-level regression on the smoothed functional image.

        3dDeconvolve info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dDeconvolve_sphx.html#ahelp-3ddeconvolve

        """

        working_directory = self.dirs["output"] / "3dDeconvolve"

        # Prepare regressor text files to scan into the interface.
        split_columns_into_text_files(self.paths["events_tsv"], self.dirs["subject_info"])
        split_columns_into_text_files(self.paths["regressors_tsv"], self.dirs["regressors"])
        
        # Total amount of regressors to include in the analysis.
        amount_of_regressors = 1 + len(self.regressor_names)

        # Create list of arguments to pass to 3dDeconvolve.
        args = f"""
                -input {self.results["3dmerge"].smoothed_image}
                -mask {self.paths["mask"]}
                -GOFORIT 4
                -polort A
                -fout
                -bucket sub-{self.subject_id}_deconvolve_stats
                -num_stimts {amount_of_regressors}
                -stim_times 1 {self.dirs["subject_info"]/'onset'}.txt CSPLINzero(0,18,10)
                -stim_label 1 all
                -iresp 1 sub-{self.subject_id}_deconvolve_IRF

        """.split()

        # Add individual stim files to the string.
        for i, regressor_name in enumerate(self.regressor_names):
            stim_number = i + 2
            stim_file_info = f"-stim_file {stim_number} {self.dirs['regressors']/regressor_name}.txt -stim_base {stim_number}"
            stim_label_info = f"-stim_label {stim_number} {regressor_name}"
            args += stim_file_info.split() + stim_label_info.split()

        # Run 3dDeconvolve.
        deconvolve_result = AFNI(program="3dDeconvolve", args=args, working_directory=working_directory)

        # Store the path of the matrix as an attribute of the result object.
        deconvolve_result.matrix = the_path_that_matches("*xmat.1D", in_directory=deconvolve_result.working_directory)

        # Copy anatomy file into working directory to use with AFNI viewer.
        shutil.copyfile(src=self.paths["anat"], dst=working_directory / self.paths["anat"].name)

        return deconvolve_result
    

    def remlfit(self):
        """
        Runs a 3dREMLfit 1st-level regression on the smoothed functional image using the matrix created by 3dDeconvolve.

        3dREMLfit info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dREMLfit_sphx.html#ahelp-3dremlfit

        """

        working_directory = self.dirs["output"] / "3dREMLfit"

        # Create the list of arguments to pass to 3dREMLfit.
        args = f"""
                -matrix {self.results["3dDeconvolve"].matrix}
                -input {self.results["3dmerge"].smoothed_image}
                -mask {self.paths["mask"]}
                -fout
                -tout
                -Rbuck sub-{self.subject_id}_REML_stats
                -Rvar sub-{self.subject_id}_REML_varianceparameters
                -verb
        """.split()
        
        # Run 3dREMLfit.
        reml_result = AFNI(program="3dREMLfit", args=args, working_directory=working_directory)

        # Copy anatomy file into working directory to use with AFNI viewer.
        shutil.copyfile(src=self.paths["anat"], dst=working_directory / self.paths["anat"].name)

        return reml_result


    def write_report(self):
        """
        Write some files to subject folder to check the quality of the analysis.

        """

        # Store workflow info into a dict.
        workflow_info = {
            "Subject ID": self.subject_id,
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Regressors included": self.regressor_names,
            "Programs used": [result.program for result in self.results.values()],
            "Commands executed": [[result.program] + [result.args] for result in self.results.values()]
        }

        # Write the workflow dict to a json file.
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
        description="Runs a first-level analysis on subjects from an fMRIPrepped dataset. The user must specify the path to the root of the raw BIDS directory fMRIPrep was run on. You must also specify EITHER a list of specific subjects OR all subjects.",
        fromfile_prefix_chars="@"
    )

    parser.add_argument(
        "--bids_dir",
        "-b",
        type=Path,
        required=True,
        help="<Mandatory> Path to the root of the BIDS directory."
    )

    parser.add_argument(
        "--outputs_title",
        "-o",
        required=True,
        help="<Mandatory> Title of output directory to use within subject directory."
    )

    parser.add_argument(
        "--regressors",
        "-r",
        nargs='+',
        required=True,
        help="<Mandatory> List of regressors to use from fMRIPrep."
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
        FirstLevel(
            bids_dir=args.bids_dir,
            subject_id=subject_id,
            regressor_names=args.regressors,
            outputs_title=args.outputs_title,
        )
