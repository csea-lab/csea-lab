#!/usr/bin/env python3
"""
Tirelessly runs a 2nd level analysis using the results of our afni_proc.py execution script.

Created 12/17/2020 by Benjamin Velie.
veliebm@gmail.com
"""

# Import pedantic and boring standard Python libraries.
from datetime import datetime
import argparse
from pathlib import Path
import json
from shutil import copy2

# Import exciting and rejeuvenating CSEA custom libraries.
from reference import subject_id_of, the_path_that_matches, task_name_of
from afni import AFNI, subbrick_labels_of


class SecondLevel():
    """
    This class runs a second level analysis on subjects for whom you've already run a first-level analysis.
    """

    def __init__(self, subject_ids, bids_dir):

        # Track when the program begins running.
        self.start_time = datetime.now()

        # Store input parameters.
        self.subject_ids = subject_ids
        self.bids_dir = bids_dir

        # Tell the user what this class looks like internally.
        print(f"Executing {self.__repr__()}")

        # Store in self.dirs paths to directories we need.
        self.dirs = {}
        self.dirs["bids_root"] = Path(self.bids_dir)     # Location of the raw BIDS dataset.
        self.dirs["firstlevel"] = self.dirs["bids_root"] / "derivatives/analysis_level-1/preprocessing_AND_deconvolution_with_only_afniproc"     # Location of the results of our first-level analyses.
        self.dirs["output"] = self.dirs["bids_root"] / "derivatives/analysis_level-2/based_on_preprocessing_AND_deconvolution_with_only_afniproc"    # Location where we'll store the results of this second-level analysis.

        # Gather into a dict of dicts all the paths we'll use. Sort by subject ID.
        self.paths = {}
        for subject_id in self.subject_ids:
            self.paths[subject_id] = {}
            self.paths[subject_id]["1st_level_results"] = self.dirs["firstlevel"]/f"sub-{subject_id}/{subject_id}.results"
            self.paths[subject_id]["deconvolve_outfile"] = the_path_that_matches(f"stats.{subject_id}+tlrc.HEAD", in_directory=self.paths[subject_id]["1st_level_results"])
            self.paths[subject_id]["reml_outfile"] = the_path_that_matches(f"stats.{subject_id}_REML+tlrc.BRIK", in_directory=self.paths[subject_id]["1st_level_results"])

        # Run our regressions.
        self.results = {}
        self.results["3dttest++"] = self.ttest()
        self.results["3dMEMA"] = self.mema()

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.
        
        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        """

        return f"SecondLevel(subject_ids={self.subject_ids}, bids_dir='{self.bids_dir}')"


    def ttest(self):
        """
        Run AFNI's 3dttest++ on the outfiles of each subject. Also concatenates 3dttest++ outfiles together.

        3dttest++ info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dttest++_sphx.html#ahelp-3dttest

        3dTcat info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dTcat_sphx.html#ahelp-3dtcat
        """

        working_directory = self.dirs["output"] / "3dttest++"

        # Gather the labels of the subbricks we want to include.
        representative_dataset = list(self.paths.values())[0]["deconvolve_outfile"]
        labels = subbrick_labels_of(representative_dataset)

        # For each relevant subbrick for each subject, run 3dttest++.
        results = {}
        for label in labels:
            if "_Coef" in label:

                # Build arguments to pass to the program.
                args = r"-zskip 100% -setA ttest".split()
                for subject_id in self.subject_ids:
                    args += [f"sub-{subject_id}"] + [f'{self.paths[subject_id]["deconvolve_outfile"]}[{label}]']

                # Run program. Store path to outfile as an attribute of the AFNI object.
                label_working_directory = working_directory / f"subbrick-{label}"
                results[label] = AFNI(program="3dttest++", args=args, working_directory=label_working_directory)
                results[label].outfile = the_path_that_matches("*.HEAD", in_directory=label_working_directory)

        # Concatenate outfiles into some rockin' time series :)
        outfiles = [result.outfile for result in results.values() if result.program == "3dttest++"]
        results["concatenated_results"] = self.concatenate(paths_to_datasets=outfiles, parent_working_directory=working_directory)

        # Copy the MNI template to each directory so we can use it in the AFNI viewer.
        directories = [path for path in working_directory.glob("*") if path.is_dir()]
        for directory in directories:
            self.download_TT_N27_brain_into(directory)

        # Return the results as a dictionary. Keys = subbrick labels, values = 3dttest++ results.
        return results
 

    def mema(self):
        """
        Runs AFNI's 3dMEMA 2nd-level analysis. Also concatenates the results together using 3dTcat.

        3dMEMA info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dMEMA_sphx.html#ahelp-3dmema
        How to gather specific sub-briks from the 3dREMLfit outfile: https://afni.nimh.nih.gov/pub/dist/doc/program_help/common_options.html
        """

        working_directory = self.dirs["output"] / "3dMEMA"

        # Gather the labels of the sub-bricks we want to include.
        representative_dataset = list(self.paths.values())[0]["reml_outfile"]
        labels = subbrick_labels_of(representative_dataset)

        # For each relevant subbrick for each subject, run 3dMEMA.
        results = {}
        for i, label in enumerate(labels):
            if "_Coef" in label:

                # Create base arguments to pass to program.
                args = (f"""
                    -prefix memamemamema
                    -jobs 5
                    -verb 1
                    -missing_data 0
                    -set activation-vs-0
                    """).split()

                # Append our 3dREMLfit outfiles to the command.
                for subject_id in self.subject_ids:
                    args += [
                        subject_id,
                        f'{self.paths[subject_id]["reml_outfile"]}[{i}]',    # Append a beta sub-brick to the command
                        f'{self.paths[subject_id]["reml_outfile"]}[{i+1}]',  # Append a Tstat sub-brick to the command
                    ]

                # Run program. Store path to outfile as an attribute of the AFNI object.
                label_working_directory = working_directory / f"subbrick-{label}"
                results[label] = AFNI(program="3dMEMA", args=args, working_directory=label_working_directory)
                results[label].outfile = the_path_that_matches("*.HEAD", in_directory=label_working_directory)

        # Concatenate outfiles into some rockin' time series :)
        outfiles = [result.outfile for result in results.values() if result.program == "3dMEMA"]
        results["concatenated_results"] = self.concatenate(paths_to_datasets=outfiles, parent_working_directory=working_directory)

        # Copy the MNI template to each directory so we can use it in the AFNI viewer.
        directories = [path for path in working_directory.glob("*") if path.is_dir()]
        for directory in directories:
            self.download_TT_N27_brain_into(directory)

        # Return the results as a dictionary. Keys = subbrick labels, values = 3dttest++ results.
        return results


    def write_report(self):
        """
        Writes files containing info about the analysis to help us stay sane.
        """

        # Store workflow info into a dict.
        workflow_info = {
            "Start time": str(self.start_time),
            "End time": str(self.end_time),
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Subject IDs included": self.subject_ids
        }

        # Write the workflow dict to a json file.
        output_json_path = self.dirs["output"] / "workflow_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(workflow_info, json_file, indent="\t")


    def concatenate(self, paths_to_datasets: list, parent_working_directory: Path):
        """
        Runs 3dTcat to neatly organize all subbricks from the datasets you specify.
        """
        subbrick_labels = subbrick_labels_of(paths_to_datasets[0])

        results = {}
        for label in subbrick_labels:
            tcat_args = "-tr 2".split()
            for path in paths_to_datasets:
                tcat_args += [f"{path}[{label}]"]
            results[label] = AFNI(program="3dTcat", args=tcat_args, working_directory=parent_working_directory/f"{label}_concatenated")

        return results


    def download_TT_N27_brain_into(self, directory):
        """
        Copies the TT_N27+tlrc brain into the target directory.
        """
        home_dir = Path.home()

        copy2(src=home_dir/"abin/TT_N27+tlrc.BRIK.gz", dst=directory)
        copy2(src=home_dir/"abin/TT_N27+tlrc.HEAD", dst=directory)


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Runs a 2nd-level analysis on subjects for whom you have already run a 1st-level analysis. You must specify the path to the raw BIDS dataset you ran your 1st-level analysis on. You must also specify whether to analyze EITHER a list of specific subjects OR all subjects. Finally, you must specify the title of the directory containing your 1st-level analysis results.", fromfile_prefix_chars="@")

    parser.add_argument("--bids_dir", required=True, help="<Mandatory> Path to the root of the BIDS directory. Example: '--bids_dir /readwrite/contrascan/bids_attempt-2'")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--subjects", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze a list of specific subject IDs. Example: '--subjects 107 108 110'")
    group.add_argument("--all", action="store_true", help="<Mandatory> Analyze all subjects. Example: '--all'")
    group.add_argument("--all_except", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze all subjects but exclude those specified here. Example: '--all_except 109 111'")

    # Parse args from the command line and create an empty list to store the subject ids we picked.
    args = parser.parse_args()
    subject_ids = []

    # Option 1: Process all subjects.
    if args.all or args.all_except:
        bids_root = Path(args.bids_dir)
        for subject_dir in bids_root.glob("sub-*"):
            if subject_id_of(subject_dir) not in args.all_except:
                subject_ids.append(subject_id_of(subject_dir))

    # Option 2: Process specific subjects.
    else:
        subject_ids = args.subjects

    # Launch the second level analysis on the subjects we picked.
    SecondLevel(
        subject_ids=subject_ids,
        bids_dir=args.bids_dir,
    )
