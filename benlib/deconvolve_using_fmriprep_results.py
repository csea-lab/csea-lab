#!/usr/bin/env python3
"""
A script to run a 1st-level analysis on an fMRIPrepped dataset using the beautiful and eternal AFNI.

Created 11/16/2020 by Benjamin Velie.
veliebm@gmail.com
"""

# Import some standard Python modules.
from datetime import datetime
import argparse
from pathlib import Path
import shutil
import json
import pandas
import sys

# Import some CSEA custom modules. (Scrappy and made with love :))
from reference import subject_id_of, the_path_that_matches, stem_of, task_name_of
from afni import AFNI


class FirstLevel():
    """
    This class runs a 1st-level analysis on an fMRIPrepped dataset using the beautiful and eternal AFNI.
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
        self.dirs["output"] = self.dirs["bids_root"] / "derivatives" / "analysis_level-1" / outputs_title / f"sub-{subject_id}"    # Where we'll output the results of the first level analysis.

        # Get paths to all files necessary for the analysis. Store in a dict of dicts, except for anat_path.
        self.anat_path = the_path_that_matches(f"anat/sub-{subject_id}*_space-*_desc-preproc_T1w.nii.gz", in_directory=self.dirs["fmriprep_root"])
        func_scans = list(self.dirs["fmriprep_root"].glob(f"func/sub-{subject_id}*_space-*_desc-preproc_bold.nii.gz"))
        task_names = [task_name_of(path) for path in func_scans]
        self.paths = {}
        for task_name in task_names:
            self.paths[task_name] = {}
            self.paths[task_name]["events_tsv"] = the_path_that_matches(f"sub-{subject_id}/func/sub-{subject_id}*_task-{task_name}*_events.tsv", in_directory=self.dirs["bids_root"])
            self.paths[task_name]["func_mask"] = the_path_that_matches(f"func/sub-{subject_id}*_task-{task_name}*_space-*_desc-brain_mask.nii.gz", in_directory=self.dirs["fmriprep_root"])
            self.paths[task_name]["regressors_tsv"] = the_path_that_matches(f"func/sub-{subject_id}*_task-{task_name}*_desc-confounds_timeseries.tsv", in_directory=self.dirs["fmriprep_root"])
            self.paths[task_name]["func_scan"] = the_path_that_matches(f"func/sub-{subject_id}*_task-{task_name}*_space-*_desc-preproc_bold.nii.gz", in_directory=self.dirs["fmriprep_root"])

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        # Run our programs of interest. Must be run in the correct order.
        self.results = {}
        for task_name in self.paths:
            self.results[task_name] = {}
            self.results[task_name]["3dmerge"] = self.merge(task_name)
            self.results[task_name]["3dTstat"] = self.tstat(task_name)
            self.results[task_name]["3dcalc"] = self.calc(task_name)
            self.results[task_name]["3dDeconvolve"] = self.deconvolve(task_name)
            self.results[task_name]["3dREMLfit"] = self.remlfit(task_name)

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.

        I learned a lot about this topic from https://docs.python.org/3/reference/datamodel.html#basic-customization
        """

        return f"{self.__class__.__name__}(bids_dir='{self.bids_dir}', subject_id='{self.subject_id}', regressor_names={self.regressor_names}, outputs_title='{self.outputs_title}')"


    def merge(self, task_name):
        """
        Smooths a functional image.

        3dmerge info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dmerge_sphx.html#ahelp-3dmerge
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dmerge"

        # Create the list of arguments and run 3dmerge.
        args = f"""
                -1blur_fwhm 5.0
                -doall
                -prefix sub-{self.subject_id}_task-{task_name}_bold_smoothed
                {self.paths[task_name]["func_scan"]}
        
        """.split()
        results = AFNI(program="3dmerge", args=args, working_directory=working_directory)

        # Store the path of the smoothed image as an attribute of the result object.
        results.outfile = the_path_that_matches("*.HEAD", in_directory=working_directory)

        return results


    def tstat(self, task_name):
        """
        Get the mean of each voxel in a functional dataset.

        3dTstat info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dTstat_sphx.html#ahelp-3dtstat
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dTstat"

        # Prepare arguments and run the program.
        args = f"""
            -prefix sub-{self.subject_id}_task-{task_name}_bold_mean
            {self.results[task_name]["3dmerge"].outfile}

        """.split()
        results = AFNI(program="3dTstat", args=args, working_directory=working_directory)

        # Store path to outfile as an attribute of the results.
        results.outfile = the_path_that_matches("*_mean+tlrc.HEAD", in_directory=working_directory)

        return results


    def calc(self, task_name):
        """
        For each voxel in a smoothed func image, calculate the voxel as percent of the mean.

        3dcalc info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dcalc_sphx.html#ahelp-3dcalc
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dcalc"

        # Prepare arguments and run the program.
        args = f"""
                -float
                -a {self.results[task_name]["3dmerge"].outfile}
                -b {self.results[task_name]["3dTstat"].outfile}
                -expr ((a-b)/b)*100
                -prefix sub-{self.subject_id}_task-{task_name}_bold_scaled

        """.split()
        results = AFNI(program="3dcalc", args=args, working_directory=working_directory)

        # Store path to outfile as an attribute of the results.
        results.outfile = the_path_that_matches("*_scaled+tlrc.HEAD", in_directory=working_directory)

        return results


    def deconvolve(self, task_name):
        """
        Runs a within-subject analysis on a smoothed functional image.

        3dDeconvolve info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dDeconvolve_sphx.html#ahelp-3ddeconvolve
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dDeconvolve"
        subject_info_directory = self.dirs["output"] / f"task-{task_name}" / "task_info"
        regressors_directory = self.dirs["output"] / f"task-{task_name}" / "all_regressors_available_for_task"

        # Prepare regressor text files to scan into the interface.
        self._split_columns_into_text_files(self.paths[task_name]["events_tsv"], subject_info_directory)
        self._split_columns_into_text_files(self.paths[task_name]["regressors_tsv"], regressors_directory)
        onsets_path = subject_info_directory / "onset.txt"

        # Total amount of regressors to include in the analysis.
        amount_of_regressors = 1 + len(self.regressor_names)

        # Create list of arguments to pass to 3dDeconvolve.
        args = f"""
                -input {self.results[task_name]["3dcalc"].outfile}
                -GOFORIT 4
                -polort A
                -fout
                -bucket sub-{self.subject_id}_task-{task_name}_bold_deconvolve_stats
                -num_stimts {amount_of_regressors}
                -stim_times 1 {onsets_path} CSPLINzero(0,18,10)
                -stim_label 1 all
                -iresp 1 sub-{self.subject_id}_task-{task_name}_bold_deconvolve_IRF

        """.split()

        # Add individual stim files to the string.
        for i, regressor_name in enumerate(self.regressor_names):
            stim_number = i + 2
            stim_file_info = f"-stim_file {stim_number} {regressors_directory/regressor_name}.txt -stim_base {stim_number}"
            stim_label_info = f"-stim_label {stim_number} {regressor_name}"
            args += stim_file_info.split() + stim_label_info.split()

        # Run 3dDeconvolve.
        results = AFNI(program="3dDeconvolve", args=args, working_directory=working_directory)

        # Store the path of the matrix as an attribute of the result object.
        results.matrix = the_path_that_matches("*xmat.1D", in_directory=working_directory)

        # Copy anatomy file into working directory to use with AFNI viewer.
        shutil.copyfile(src=self.anat_path, dst=working_directory / self.anat_path.name)

        return results
    

    def remlfit(self, task_name):
        """
        Runs a 3dREMLfit within-subject analysis on a smoothed functional image using a matrix created by 3dDeconvolve.

        3dREMLfit info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dREMLfit_sphx.html#ahelp-3dremlfit
        """

        working_directory = self.dirs["output"] / f"task-{task_name}" / "3dREMLfit"

        # Create the list of arguments to pass to 3dREMLfit.
        args = f"""
                -matrix {self.results[task_name]["3dDeconvolve"].matrix}
                -input {self.results[task_name]["3dcalc"].outfile}
                -fout 
                -tout
                -Rbuck sub-{self.subject_id}_task-{task_name}_bold_reml_stats
                -Rvar sub-{self.subject_id}_task-{task_name}_bold_reml_varianceparameters
                -verb

        """.split()

        # Run 3dREMLfit.
        results = AFNI(program="3dREMLfit", args=args, working_directory=working_directory)

        # Copy anatomy file into working directory to use with AFNI viewer.
        shutil.copyfile(src=self.anat_path, dst=working_directory / self.anat_path.name)

        return results


    def write_report(self):
        """
        Write some files to subject folder to check the quality of the analysis.
        """

        # Store workflow info into a dict.
        workflow_info = {
            "You analyzed this subject": self.subject_id,
            "The workflow took this long to run": str(self.end_time - self.start_time),
            "You included these regressors in the analysis": self.regressor_names,
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

    parser = argparse.ArgumentParser(description="Runs a first-level analysis on subjects from an fMRIPrepped dataset. The user must specify the path to the root of the raw BIDS directory fMRIPrep was run on. You must also specify EITHER a list of specific subjects OR all subjects.", fromfile_prefix_chars="@")
    parser.add_argument("--bids_dir", "-b", type=Path, required=True, help="<Mandatory> Path to the root of the BIDS directory.")
    parser.add_argument("--outputs_title", "-o", required=True, help="<Mandatory> Title of output directory to use within subject directory.")
    parser.add_argument("--regressors", "-r", nargs='+', required=True, help="<Mandatory> List of regressors to use from fMRIPrep.")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--subjects", "-s", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Preprocess a list of specific subject IDs. Mutually exclusive with --all.")
    group.add_argument('--all', '-a', action='store_true', help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects.")
    group.add_argument("--all_except", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze all subjects but exclude those specified here. Example: '--all_except 109 111'")

    # Parse args from the command line and create an empty list to store the subject ids we picked.
    args = parser.parse_args()
    print(f"Arguments: {args}")
    subject_ids = []

    # Option 1: Process all subjects except some.
    if args.all_except:
        bids_root = Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            if subject_id_of(subject_dir) not in args.all_except:
                subject_ids.append(subject_id_of(subject_dir))

    # Option 2: Process all subjects.
    elif args.all:
        bids_root = Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            subject_ids.append(subject_id_of(subject_dir))

    # Option 3: Process specific subjects.
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
