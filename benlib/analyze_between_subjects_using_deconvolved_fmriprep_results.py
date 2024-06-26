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
from shutil import copy2

# Import some CSEA custom libraries.
from reference import subject_id_of, the_path_that_matches, task_name_of
from afni import AFNI, subbrick_labels_of
import templateflow.api


class SecondLevel():
    """
    This class runs a second level analysis on subjects for whom you've already run a first-level analysis.
    """

    def __init__(self, subject_ids, bids_dir, firstlevel_name, secondlevel_name, tasks_to_compare):

        # Track when the program begins running.
        self.start_time = datetime.now()

        # Store input parameters.
        self.subject_ids = subject_ids
        self.bids_dir = bids_dir
        self.firstlevel_name = firstlevel_name
        self.secondlevel_name = secondlevel_name
        self.tasks_to_compare = tasks_to_compare

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

        # Run our regressions compared against zero.
        for task_name in self.task_names:
            self.ttest(task_name)
            self.mema(task_name)

        # Run our regressions compared against each other.
        if self.tasks_to_compare:
            for i in range(0, len(self.tasks_to_compare), 2):
                self.ttest(self.tasks_to_compare[i], comparison_task=self.tasks_to_compare[i+1])
                self.mema(self.tasks_to_compare[i], comparison_task=self.tasks_to_compare[i+1])

        # Record end time and write our report.
        self.end_time = datetime.now()
        self.write_report()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.
        
        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        """

        return f"SecondLevel(subject_ids={self.subject_ids}, bids_dir='{self.bids_dir}', firstlevel_name='{self.firstlevel_name}', secondlevel_name='{self.secondlevel_name}', tasks_to_compare={self.tasks_to_compare})"


    def ttest(self, task_name, comparison_task=None):
        """
        Run AFNI's 3dttest++ on the outfiles of the specified task. Also concatenates them together.

        If you specify a comparison task, 3dttest will compare both tasks against each other AND against zero! What a time to be alive!

        3dttest++ info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dttest++_sphx.html#ahelp-3dttest

        3dTcat info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dTcat_sphx.html#ahelp-3dtcat
        """

        base_working_directory = self.dirs["output"] / f"task-{task_name}" / "3dttest++"
        if comparison_task:
            base_working_directory = self.dirs["output"] / f"task-{task_name}_vs_task-{comparison_task}" / "3dttest++"

        # Gather the labels of the subbricks we want to include.
        representative_dataset = list(self.paths[task_name].values())[0]["deconvolve_outfile"]
        labels = subbrick_labels_of(representative_dataset)

        # For each relevant subbrick for each subject, run 3dttest++.
        results = {}
        for label in labels:
            if "_Coef" in label:

                # Build base arguments to pass to the program.
                args = f"-zskip 100% -setA {task_name}".split()
                for subject_id in self.subject_ids:
                    args += [f"sub-{subject_id}"] + [f'{self.paths[task_name][subject_id]["deconvolve_outfile"]}[{label}]']

                if comparison_task:
                    args += ["-setB", comparison_task]
                    for subject_id in self.subject_ids:
                        args += [f"sub-{subject_id}"] + [f'{self.paths[comparison_task][subject_id]["deconvolve_outfile"]}[{label}]']
    

                # Run program. Store path to outfile as an attribute of the AFNI object.
                working_directory = base_working_directory / f"subbrick-{label}"
                results[label] = AFNI(program="3dttest++", args=args, working_directory=working_directory)
                results[label].outfile = the_path_that_matches("*.HEAD", in_directory=working_directory)

        # Concatenate outfiles into some rockin' time series :)
        outfiles = [result.outfile for result in results.values()]
        results["concatenated_results"] = self.concatenate(paths_to_datasets=outfiles, parent_working_directory=base_working_directory)

        # Copy the MNI template to each directory so we can use it in the AFNI viewer.
        directories = [path for path in base_working_directory.glob("*") if path.is_dir()]
        for directory in directories:
            self.download_MNI_brain_into(directory)

        # Return the results as a dictionary. Keys = subbrick labels, values = 3dttest++ results.
        return results
 

    def mema(self, task_name, comparison_task=None):
        """
        Runs AFNI's 3dMEMA 2nd-level analysis using the output bucket of 3dREMLfit.

        If you specify a comparison task, 3dMEMA will compare both tasks against each other AND against zero! What a time to be alive!

        3dMEMA info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dMEMA_sphx.html#ahelp-3dmema
        How to gather specific sub-briks from the 3dREMLfit outfile: https://afni.nimh.nih.gov/pub/dist/doc/program_help/common_options.html
        """

        base_working_directory = self.dirs["output"] / f"task-{task_name}" / "3dMEMA"
        if comparison_task:
            base_working_directory = self.dirs["output"] / f"task-{task_name}_vs_task-{comparison_task}" / "3dMEMA"

        # Gather the labels of the sub-bricks we want to include.
        representative_dataset = list(self.paths[task_name].values())[0]["reml_outfile"]
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
                    -groups task-{task_name}
                    """).split()

                if comparison_task:
                    args += [f"task-{comparison_task}"]

                # Append our 3dREMLfit outfiles to the command for our first task.
                args += ["-set", f"task-{task_name}"]
                for subject_id in self.subject_ids:
                    args += [
                        subject_id,
                        f'{self.paths[task_name][subject_id]["reml_outfile"]}[{i}]',    # Append a beta sub-brick to the command
                        f'{self.paths[task_name][subject_id]["reml_outfile"]}[{i+1}]',  # Append a Tstat sub-brick to the command
                    ]

                # Include the !bonus task! if necessary :D
                if comparison_task:
                    args += ["-set", f"task-{comparison_task}"]
                    for subject_id in self.subject_ids:
                        args += [
                            subject_id,
                            f'{self.paths[comparison_task][subject_id]["reml_outfile"]}[{i}]',    # Append a beta sub-brick to the command
                            f'{self.paths[comparison_task][subject_id]["reml_outfile"]}[{i+1}]',  # Append a Tstat sub-brick to the command
                        ]

                # Run program. Store path to outfile as an attribute of the AFNI object.
                working_directory = base_working_directory / f"subbrick-{label}"
                results[label] = AFNI(program="3dMEMA", args=args, working_directory=working_directory)
                results[label].outfile = the_path_that_matches("*.HEAD", in_directory=working_directory)

        # Concatenate outfiles into some rockin' time series :)
        outfiles = [result.outfile for result in results.values() if result.program == "3dMEMA"]
        results["concatenated_results"] = self.concatenate(paths_to_datasets=outfiles, parent_working_directory=base_working_directory)

        # Copy the MNI template to each directory so we can use it in the AFNI viewer.
        directories = [path for path in base_working_directory.glob("*") if path.is_dir()]
        for directory in directories:
            self.download_MNI_brain_into(directory)

        # Return the results as a dictionary. Keys = subbrick labels, values = 3dMEMA results.
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
            "Title of first level analysis": self.firstlevel_name,
            "Title of second level analysis": self.analysis_name,
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


    def download_MNI_brain_into(self, directory):
        """
        Uses templateflow to download the MNI brain and move it into the target directory.
        """

        for path in templateflow.api.get("MNI152NLin2009cAsym"):
            if path.name == "tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz":
                copy2(src=path, dst=directory/path.name)


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Runs a 2nd-level analysis on subjects for whom you have already run a 1st-level analysis. You must specify the path to the raw BIDS dataset you ran your 1st-level analysis on. You must also specify whether to analyze EITHER a list of specific subjects OR all subjects. Finally, you must specify the title of the directory containing your 1st-level analysis results.", fromfile_prefix_chars="@")

    parser.add_argument("--bids_dir", required=True, help="<Mandatory> Path to the root of the BIDS directory. Example: '--bids_dir /readwrite/contrascan/bids_attempt-2'")
    parser.add_argument("--firstlevel_name", required=True, help="<Mandatory> Name of the 1st-level analysis directory to access within the BIDS directory. Example: to access 'bidsroot/derivatives/first_level_analysis/sub-$SUBJECT_ID/analysis_regressors-csf', use '--firstlevel_name analysis_regressors-csf'")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--subjects", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze a list of specific subject IDs. Example: '--subjects 107 108 110'. Mutually exclusive with --all.")
    group.add_argument('--all', action='store_true', help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects.")
    group.add_argument("--all_except", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze all subjects but exclude those specified here. Example: '--all_except 109 111'")

    parser.add_argument("--secondlevel_name", default=None, help="Default: Name of the 1st-level analysis. What to name the 2nd-level analysis. Example: '--secondlevel_name hello_this_is_a_test'")
    parser.add_argument("--compare_tasks", metavar="TASK", nargs="+", help="Default: None. Compares specific pairs of tasks together. Example: '--compare_tasks alpha nietzche 10 potato' will compare task alpha vs task nietzche and task 10 vs task potato.")

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

    # Launch the second level analysis on the subjects we picked.
    SecondLevel(
        subject_ids=subject_ids,
        bids_dir=args.bids_dir,
        firstlevel_name=args.firstlevel_name,
        secondlevel_name=args.secondlevel_name,
        tasks_to_compare=args.compare_tasks
    )
