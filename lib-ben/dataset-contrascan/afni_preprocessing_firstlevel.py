#!/usr/bin/env python3

"""
Script to process the contrascan dataset from preprocessing through the 1st-level analysis.

Subjects must be organized in BIDS-format.

Created 9/17/2020 by Benjamin Velie.
veliebm@gmail.com

"""

# Import some standard Python modules. -------------------
from datetime import datetime
from pathlib import Path
import argparse
import json
import re
import shutil


# Import some friendly and nice CSEA custom modules. -------------------
from reference import subject_id_of, the_path_that_matches, split_columns_into_text_files
from afni import AFNI


class Pipeline():
    """
    This class preprocesses a subject then runs a first-level analysis.

    """

    def __init__(self, bids_dir, subject_id):

        # Track time information. Store parameters. Tell user what's happening. -------------------
        self.start_time = datetime.now()
        self.bids_dir = bids_dir
        self.subject_id = subject_id
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


        # Run our programs of interest in order. Store outputs in a dict. -----------------------
        self.results = {}
        self.results["align_epi_anat.py"] = self.align_epi_anat()
        self.results["@auto_tlrc 1"] = self.auto_tlrc1()
        self.results["3dcalc 1"] = self.calc1()
        self.results["3dresample"] = self.resample()
        self.results["3dTshift"] = self.tshift()
        self.results["3dvolreg"] = self.volreg()
        self.results["3dmerge"] = self.merge()
        self.results["3dROIstats"] = self.roistats()
        self.results["1dplot 1"] = self.plot1()
        self.results["3dToutcount"] = self.outcount()
        self.results["1dplot 2"] = self.plot2()
        self.results["1deval"] = self.eval()
        self.results["3dTstat"] = self.tstat()
        self.results["3dcalc 2"] = self.calc2()
        self.results["3dDeconvolve"] = self.deconvolve()
        self.results["@auto_tlrc 2"] = self.auto_tlrc2()


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

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -anat {self.paths["anat"]}
            -epi {self.paths["func"]}
            -epi_base 10
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="align_epi_anat.py",
            args=args,
            working_directory=self.dirs["output"]/"align_epi_anat.py"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_T1w_al+orig.HEAD", in_directory=results.working_directory)
        return results


    def auto_tlrc1(self):
        """
        Aligns our anatomy to base TT_N27.

        Wraps @auto_tlrc.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/@auto_tlrc_sphx.html#ahelp-auto-tlrc


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program ---------------------
        args = f"""
            -no_ss
            -base TT_N27+tlrc
            -input {self.results["align_epi_anat.py"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="@auto_tlrc",
            args=args,
            working_directory=self.dirs["output"]/"@auto_tlrc1"
        )

        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_T1w_al+tlrc.HEAD", in_directory=results.working_directory)
        return results


    def calc1(self):
        """
        Calculate a rough skull mask. Specifically, discard all voxels with values less than zero.

        Wraps 3dcalc.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dcalc_sphx.html#ahelp-3dcalc


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
        -a {self.results["align_epi_anat.py"].outfile}
        -expr step(a)
        -prefix sub-{subject_id}_anat_aligned_tmp_mask
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dcalc",
            args=args,
            working_directory=self.dirs["output"]/"3dcalc1"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_tmp_mask+orig.HEAD", in_directory=results.working_directory)
        return results


    def resample(self):
        """
        TODO: Explain what the hell 3dresample actually does.

        Wraps 3dresample.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dresample_sphx.html#ahelp-3dresample


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -master {self.paths["func"]}
            -prefix sub-{subject_id}_func_skull_al_mask
            -inset {self.results["3dcalc 1"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dresample",
            args=args,
            working_directory=self.dirs["output"]/"3dresample"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_skull_al_mask+orig.HEAD", in_directory=results.working_directory)
        return results


    def tshift(self):
        """
        Performs slice-time correction.

        Wraps 3dTshift.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dTshift_sphx.html#ahelp-3dtshift


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -tzero 0
            -tpattern alt+z
            -quintic
            -prefix sub-{subject_id}_func_tshift
            {self.paths["func"]}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dTshift",
            args=args,
            working_directory=self.dirs["output"]/"3dTshift"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_tshift+orig.HEAD", in_directory=results.working_directory)
        return results


    def volreg(self):
        """
        Align each dataset to the base volume using the same image as used in align_epi_anat.py

        Wraps 3dvolreg.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dvolreg_sphx.html#ahelp-3dvolreg


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
        -verbose
        -zpad 1
        -base {self.results["3dTshift"].outfile}[10]
        -1Dfile sub-{subject_id}_regressors-motion.1D
        -prefix sub-{subject_id}_func_tshift_volreg
        {self.results["3dTshift"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dvolreg",
            args=args,
            working_directory=self.dirs["output"]/"3dvolreg"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_volreg+orig.HEAD", in_directory=results.working_directory)
        results.motion_regressors = the_path_that_matches("*_regressors-motion.1D", in_directory=results.working_directory)
        return results


    def merge(self):
        """
        Blur each volume. For inplane 2.5 use 5 fwhm - 2x times inplane is best.

        Wraps 3dmerge.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dmerge_sphx.html#ahelp-3dmerge


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -1blur_fwhm 5.0
            -doall
            -prefix sub-{subject_id}_func_smoothed
            {self.results["3dvolreg"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dmerge",
            args=args,
            working_directory=self.dirs["output"]/"3dmerge"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_smoothed+orig.HEAD", in_directory=results.working_directory)
        return results


    def roistats(self):
        """
        Get the mean for each of n slices for each timepoint to check on residual motion.

        TODO: Explain what that summary actually means??

        This wrapper is a little funny. 3dROIstats doesn't create a file - it prints a matrix
        to stdout. Luckily, our convenient and nifti AFNI class can capture the matrix from
        stdout and write it to disk. Just check it carefully to ensure the AFNI class didn't
        get overly enthusiastic and include too many rows in the matrix :)

        Wraps 3dROIstats.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dROIstats_sphx.html#ahelp-3droistats


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        # We append 3dcalc separately to the args so we don't accidentally split it.
        mask_arg = ["-mask", f"3dcalc(-a {self.results['3dresample'].outfile} -expr a*(k+1) -datum short -nscale)"]
        other_args = f"""
        -quiet
        {self.results["3dvolreg"].outfile}
        """.split()


        # Run program and store results. -----------------------
        working_directory_of_program = self.dirs["output"]/"3dROIstats"
        results = AFNI(
            program="3dROIstats",
            args=mask_arg + other_args,
            working_directory=working_directory_of_program,
            write_matrix_lines_to=working_directory_of_program / f"sub-{self.subject_id}_func_sliceaverage.1D"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_sliceaverage.1D", in_directory=results.working_directory)
        return results


    def plot1(self):
        """
        Save the slice average plot in a jpg file.

        Wraps 1dplot.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/1dplot_sphx.html#ahelp-1dplot


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -one
            -jpg
            sub-{subject_id}_func_sliceaverage.jpg
            {self.results["3dROIstats"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="1dplot",
            args=args,
            working_directory=self.dirs["output"]/"1dplot1"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_sliceaverage.jpg", in_directory=results.working_directory)
        return results


    def outcount(self):
        """
        Detect outliers in our data.

        This wrapper is a little funny. 3dToutcount doesn't create a file - it prints a matrix
        to stdout. Luckily, our convenient and nifti AFNI class can capture the matrix from
        stdout and write it to disk. Just check it carefully to ensure the AFNI class didn't
        get overly enthusiastic and include too many rows in the matrix :)

        Wraps 3dToutcount.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dToutcount_sphx.html#ahelp-3dtoutcount


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------

        # We append 3dcalc separately to the args so we don't accidentally split it.
        mask_arg = ["-mask", f"3dcalc(-a {self.results['3dresample'].outfile} -expr a*(k+1) -datum short -nscale)"]
        other_args = f"""
            -fraction {self.results["3dvolreg"].outfile}
        """.split()


        # Run program and store results. -----------------------
        working_directory_of_program = self.dirs["output"]/"3dToutcount"
        results = AFNI(
            program="3dToutcount",
            args=mask_arg + other_args,
            working_directory=working_directory_of_program,
            write_matrix_lines_to=working_directory_of_program / f"sub-{self.subject_id}_func_outliers.1D"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_outliers.1D", in_directory=results.working_directory)
        return results


    def plot2(self):
        """
        Save the outliers plot into a jpg file.

        Wraps 1dplot.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/1dplot_sphx.html#ahelp-1dplot


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -jpg
            sub-{self.subject_id}_func_outliers.jpg
            {self.results["3dToutcount"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="1dplot",
            args=args,
            working_directory=self.dirs["output"]/"1dplot2"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_outliers.jpg", in_directory=results.working_directory)
        return results


    def eval(self):
        """
        Flag trials that have too many outliers.

        This wrapper is a little funny. 1deval doesn't create a file - it prints a matrix
        to stdout. Luckily, our convenient and nifti AFNI class can capture the matrix from
        stdout and write it to disk. Just check it carefully to ensure the AFNI class didn't
        get overly enthusiastic and include too many rows in the matrix :)

        Wraps 1deval.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/1deval_sphx.html#ahelp-1deval


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -a {self.results["3dToutcount"].outfile}
            -expr step(.05-a)
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="1deval",
            args=args,
            working_directory=self.dirs["output"] / "1deval",
            write_matrix_lines_to=self.dirs["output"] / "1deval" / f"sub-{self.subject_id}_func_wholebraincensor.1D"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_wholebraincensor.1D", in_directory=results.working_directory)
        return results


    def tstat(self):
        """
        I have utterly no idea what this does. But hey, it's something we need?

        Wraps 3dTstat.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dTstat_sphx.html#ahelp-3dtstat


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""
            -prefix sub-{subject_id}_func_mean
            {self.results["3dmerge"].outfile}
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dTstat",
            args=args,
            working_directory=self.dirs["output"] / "3dTstat"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_mean+orig.HEAD", in_directory=results.working_directory)
        return results


    def calc2(self):
        """
        I also have no idea what this does! Something to do with scaling mayhaps?

        Wraps 3dcalc.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dcalc_sphx.html#ahelp-3dcalc


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""

            -float
            -a {self.results["3dmerge"].outfile}
            -b {self.results["3dTstat"].outfile}
            -c {self.results["3dresample"].outfile}
            -expr c*(((a-b)/b)*100)
            -prefix sub-{self.subject_id}_func_scaled

        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dcalc",
            args=args,
            working_directory=self.dirs["output"] / "3dcalc2"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_scaled+orig.HEAD", in_directory=results.working_directory)
        return results


    def deconvolve(self):
        """
        Performs a nice and simple 1st-level analysis.

        Wraps 3dDeconvolve.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dDeconvolve_sphx.html#ahelp-3ddeconvolve


        Returns
        -------
        AFNI object
            Stores information about the program.

        """

        # Grab onsets from our BIDS event file. --------------------
        split_columns_into_text_files(
            tsv_path=self.paths["events_tsv"],
            output_dir=self.dirs["output"] / "other"
        )
        onsets_path = the_path_that_matches("onset.txt", in_directory=self.dirs["output"] / "other")


        # Prepare the arguments we want to pass to the program. ---------------------
        args = f"""

            -input {self.results['3dcalc 2'].outfile}
            -polort A
            -GOFORIT 4
            -censor {self.results['1deval'].outfile}
            -num_stimts 7
            -stim_times 1 {onsets_path} CSPLINzero(0,18,10)
            -stim_label 1 all
            -stim_file 2 {self.results["3dvolreg"].motion_regressors}[0] -stim_base 2 -stim_label 2 roll
            -stim_file 3 {self.results["3dvolreg"].motion_regressors}[1] -stim_base 3 -stim_label 3 pitch
            -stim_file 4 {self.results["3dvolreg"].motion_regressors}[2] -stim_base 4 -stim_label 4 yaw
            -stim_file 5 {self.results["3dvolreg"].motion_regressors}[3] -stim_base 5 -stim_label 5 dS
            -stim_file 6 {self.results["3dvolreg"].motion_regressors}[4] -stim_base 6 -stim_label 6 dL
            -stim_file 7 {self.results["3dvolreg"].motion_regressors}[5] -stim_base 7 -stim_label 7 dP
            -jobs 2
            -fout
            -iresp 1 sub-{self.subject_id}_func_CSPLINz_all_IRF
            -bucket sub-{self.subject_id}_func_CSPLINz_all_stats

        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="3dDeconvolve",
            args=args,
            working_directory=self.dirs["output"] / "3dDeconvolve"
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_stats+orig.HEAD", in_directory=results.working_directory)
        results.IRF = the_path_that_matches("*_IRF+orig.HEAD", in_directory=results.working_directory)
        return results


    def auto_tlrc2(self):
        """
        Aligns our IRF file to our anat file.

        Wraps @auto_tlrc.

        AFNI command info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/@auto_tlrc_sphx.html#ahelp-auto-tlrc


        Returns
        -------
        AFNI object
            Stores information about the program.

        """
        
        # Copy the input files to the @auto_tlrc folder. Otherwise, we risk its great wrath. ---------------
        program_working_directory = self.dirs["output"] / "@auto_tlrc2"
        program_working_directory.mkdir(exist_ok=True)
        shutil.copy2(src=self.results["@auto_tlrc 1"].outfile, dst=program_working_directory / self.results["@auto_tlrc 1"].outfile.name)
        shutil.copy2(src=self.results["3dDeconvolve"].IRF, dst=program_working_directory / self.results["3dDeconvolve"].IRF.name)


        # Prepare the arguments we want to pass to the program ---------------------
        args = f"""
            -apar {self.results["@auto_tlrc 1"].outfile.name}
            -input {self.results["3dDeconvolve"].IRF.name}
            -dxyz 2.5
        """.split()


        # Run program and store results. -----------------------
        results = AFNI(
            program="@auto_tlrc",
            args=args,
            working_directory=program_working_directory
        )


        # Store path to outfile as an attribute of the results. Return results. ----------------------------
        results.outfile = the_path_that_matches("*_IRF+tlrc.HEAD", in_directory=results.working_directory)
        return results


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        # Store workflow info into a dict. --------------------------------
        workflow_info = {
            "Time to complete workflow": str(self.end_time - self.start_time),
            "Subject ID": self.subject_id,
            "Programs used (in order) and their return codes during the MOST RECENT run": [f"{result.program}: {result.process.returncode}" for result in self.results.values()]
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
        description=f"Preprocess subjects from the contrascan dataset. You must specify a path to the target BIDS directory. You must also specify whether to preprocess EITHER all subjects OR a list of specific subjects.",
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
        Pipeline(
            bids_dir=args.bids_dir,
            subject_id=subject_id,
        )