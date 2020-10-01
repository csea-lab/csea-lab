"""
A script to run a 1st-level analysis the way it was meant to be done.

That is, without any of these darn jupyter notebooks or nipype nodes.

Created 9/9/2020 by Benjamin Velie.
veliebm@gmail.com

"""

from datetime import datetime
import argparse
import re
import pathlib
import shutil
import json
import pandas
from contextlib import suppress

from nipype.interfaces.fsl import SUSAN
from nipype.interfaces.afni import Deconvolve

from nipype.caching.memory import Memory


class FirstLevel():
    """
    This class runs a first level analysis on a subject in the fMRIPrepped contrascan dataset.

    """

    def __init__(self, bids_dir, subject_id, regressor_names, output_dir, clear_cache=False):
    
        print(f"Processing subject {subject_id}")

        # Track time information.
        self.start_time = datetime.now()
        
        # Store basic info.
        self.subject_id = subject_id
        self.regressor_names = regressor_names
        self.clear_cache = clear_cache

        # Store paths to directories we need in self.dirs.
        self.dirs = dict()
        self.dirs["bids_root"] = pathlib.Path(bids_dir)     # Root of the raw BIDS dataset.
        self.dirs["fmriprep_root"] = self.dirs["bids_root"] / "derivatives" / "fmriprep"    # Root of fmriprep outputs.
        self.dirs["subject_root"] = self.dirs["bids_root"] / "derivatives" / "first_level_analysis" / f"sub-{subject_id}"   # Root of where we'll output info for the subject.
        self.dirs["regressors"] = self.dirs["subject_root"] / "regressors"      # Where we'll store our regressor text files.
        self.dirs["subject_info"] = self.dirs["subject_root"] / "subject_info"      # Where we'll store our subject's onsets in a text file.
        self.dirs["output"] = self.dirs["subject_root"] / output_dir    # Where we'll output the results of the first level analysis.

        # Get paths to all files necessary for the analysis. Store in self.paths dict.
        self.paths = dict()
        self.paths["bold_json"] = list(self.dirs["bids_root"].rglob(f"func/sub-{subject_id}*_task-*_bold.json"))[0]
        self.paths["events_tsv"] = list(self.dirs["bids_root"].rglob(f"func/sub-{subject_id}*_task-*_events.tsv"))[0]
        self.paths["anat"] = list(self.dirs["fmriprep_root"].rglob(f"anat/sub-{subject_id}*_desc-preproc_T1w.nii.gz"))[0]
        self.paths["func"] = list(self.dirs["fmriprep_root"].rglob(f"func/sub-{subject_id}*_desc-preproc_bold.nii.gz"))[0]
        self.paths["regressors_tsv"] = list(self.dirs["fmriprep_root"].rglob(f"func/sub-{subject_id}*_desc-confounds_regressors.tsv"))[0]

        # Create any directory that doesn't exist.
        for directory in self.dirs.values():
            directory.mkdir(exist_ok=True, parents=True)

        # Create nipype Memory object to manage nipype outputs.
        self.memory = Memory(str(self.dirs["subject_root"]))
        if self.clear_cache:
            self._clear_cache()

        # Run our interfaces of interest. Store outputs in a dict.
        self.results = dict()
        self.results["SUSAN"] = self.SUSAN()
        self.results["Deconvolve"] = self.Deconvolve(self.results["SUSAN"])
        
        # Record end time and write our report.
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
            in_file=str(self.paths["func"]),
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
        self._break_tsv(self.paths["events_tsv"], self.dirs["subject_info"])
        self._break_tsv(self.paths["regressors_tsv"], self.dirs["regressors"])
        
        amount_of_regressors = 1 + len(self.regressor_names)

        # Create string to pass to interface. Remove all unnecessary whitespace by default.
        arg_string = ' '.join(f"""

            -input {SUSAN_result.outputs.smoothed_file}
            -GOFORIT 4
            -polort A
            -num_stimts {amount_of_regressors}
            -stim_times 1 {self.dirs["subject_info"]/'onset'}.txt 'CSPLINzero(0,18,10)'
            -stim_label 1 all
            -fout

        """.replace("\n", " ").split())

        # Add individual stim files to the string.
        for i, regressor_name in enumerate(self.regressor_names):
            stim_number = i + 2

            stim_file_info = f"-stim_file {stim_number} {self.dirs['regressors']/regressor_name}.txt -stim_base {stim_number}"
            stim_label_info = f"-stim_label {stim_number} {regressor_name}"

            arg_string += f" {stim_file_info} {stim_label_info}"


        return self.memory.cache(Deconvolve)(
            args=arg_string
        )


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        # Copy our preprocessed anat file into our deconvolve directory to view with AFNI.
        shutil.copyfile(
            src=self.paths["anat"],
            dst=pathlib.Path(self.results["Deconvolve"].runtime.cwd) / self.paths["anat"].name
        )

        # Copy most of our results from each interface. Ignore certain massive files.
        for result in self.results.values():
            self._copy_result(result, ignore_patterns=([
                "*_desc-preproc_bold_smooth.nii",
                ]))

        # Store workflow info into a dict.
        workflow_info = {
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Regressors included": self.regressor_names,
            "Cache cleared before analysis": self.clear_cache,
            "Subject ID": self.subject_id,
            "Interfaces used": [interface for interface in self.results],
            "Original source of regressors": str(self.paths["regressors_tsv"])
        }

        # Write the workflow dict to a json file.
        output_json_path = self.dirs["output"] / f"workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


    def _clear_cache(self):
        """
        Deletes the nipype cache.

        """

        print("Clearing cache")
        cache_path = self.dirs["subject_root"] / "nipype_mem"
        shutil.rmtree(cache_path)


    def _break_tsv(self, tsv_path, output_dir):
        """
        Converts a tsv file into a collection of text files.

        Each column name becomes the name of a text file. Each value in that column is then
        placed into the text file.


        Parameters
        ----------
        tsv_path : str or pathlib.Path
            Path to the .tsv file to read.
        output_dir : str or pathlib.Path
            Directory to write columns of the .tsv file to.

        """

        # Get paths to the tsv and output dir.
        tsv_path = pathlib.Path(tsv_path)
        output_dir = pathlib.Path(output_dir)

        print(f"Breaking up {tsv_path.name} and storing columns in {output_dir}")

        # Read the .tsv file into a dataframe and fill n/a values with zero.
        tsv_info = pandas.read_table(
            tsv_path,
            sep="\t",
            na_values="n/a"
        ).fillna(value=0)

        # Write each column of the dataframe.
        for column_name in tsv_info:
            column_path = output_dir / f"{column_name}.txt"
            tsv_info[column_name].to_csv(column_path, sep=' ', index=False, header=False)


    def _copy_result(self, interface_result, ignore_patterns=["nothing at all"]):
        """
        Copies interface results from the cache to the subject directory.


        Parameters
        ----------
        interface_result : nipype interface result
            Copies files created by this interface.
        ignore_patterns : list
            Ignore Unix-style file patterns when copying.

        """

        # Get name of interface and paths to old dir and new dir.
        old_result_dir = pathlib.Path(interface_result.runtime.cwd)
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


def _get_subject_id(path) -> str:
    """
    Returns the subject ID found in the input file name.


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
        If no subject ID found in input filename.

    """
    
    potential_subject_ids = re.findall(r"sub-(\d+)", str(path))

    subject_id = potential_subject_ids[-1]

    return subject_id


if __name__ == "__main__":
    """
    Enables usage of the program from a shell.

    The user must specify the location of the BIDS directory.
    They can also specify EITHER a specific subject OR all subjects. Cool stuff!

    """

    parser = argparse.ArgumentParser(
        description="Runs a first-level analysis on subjects from an fMRIPrepped dataset. The user must specify the path to the root of the raw BIDS directory fMRIPrep was run on. You must also specify EITHER a list of specific subjects OR all subjects. Finally, you can use a config file by appending @ to the config file name and passing it as a positional argument to this program. (i.e. 'python {__file__} @config.txt [args...]')",
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
        "--output_dir_name",
        "-o",
        type=str,
        required=True,
        help="<Mandatory> Name of output directory to use within subject directory."
    )

    parser.add_argument(
        "--regressors",
        "-r",
        type=str,
        nargs='+',
        required=True,
        help="<Mandatory> List of regressors to use from fMRIPrep."
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

    # Option 1: Process all subjects.
    if args.all:
        bids_root = pathlib.Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            subject_ids.append(_get_subject_id(subject_dir))

    # Option 2: Process specific subjects.
    else:
        subject_ids = args.subjects

    for subject_id in subject_ids:
        FirstLevel(
            bids_dir=args.bids_dir,
            subject_id=subject_id,
            regressor_names=args.regressors,
            output_dir=args.output_dir_name,
            clear_cache=args.clear_cache
        )