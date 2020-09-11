"""
A script to run a 1st-level analysis the way it was meant to be done.

That is, without any of these darn jupyter notebooks or nipype nodes.

Created 9/9/2020 by Benjamin Velie.
veliebm@gmail.com

"""


import argparse
import re
import pathlib
import json
import pandas

from nilearn.plotting import plot_stat_map

from nipype.interfaces.fsl import SUSAN
from nipype.interfaces.spm import Level1Design, EstimateModel, EstimateContrast
from nipype.algorithms.modelgen import SpecifySPMModel

from nipype.interfaces.base import Bunch
from nipype.caching.memory import Memory


class FirstLevel():
    """
    This class runs a first level analysis on a subject in the fMRIPrepped contrascan dataset.

    """

    def __init__(self, bids_dir, subject_id):

        self.subject_id = subject_id
        self.bids_dir = pathlib.Path(bids_dir)

        # Prepare output directory.
        self.output_dir = self.bids_dir / "derivatives" / "first_level_analysis" / f"sub-{subject_id}"
        self.output_dir.mkdir(exist_ok=True)

        # Get paths to all files necessary for the analysis.
        self.bold_json_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_task-*_bold.json"))[0]
        self.bold_tsv_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_task-*_events.tsv"))[0]
        self.anat_path = list(self.bids_dir.rglob(f"anat/sub-{subject_id}*_desc-preproc_T1w.nii.gz"))[0]
        self.func_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_desc-preproc_bold.nii.gz"))[0]
        self.regressors_path = list(self.bids_dir.rglob(f"func/sub-{subject_id}*_desc-confounds_regressors.tsv"))[0]

        # Create nipype Memory object to manage nipype outputs.
        self.memory = Memory(str(self.output_dir))

        # Run necessary interfaces.
        self.SUSAN_result = self.SUSAN()
        self.SpecifySPMModel_result = self.SpecifySPMModel(self.SUSAN_result)
        self.Level1Design_result = self.Level1Design(self.SpecifySPMModel_result)
        self.EstimateModel_result = self.EstimateModel(self.Level1Design_result)
        self.EstimateContrast_result = self.EstimateContrast(self.EstimateModel_result)


    def SUSAN(self):
        """
        Smooths the functional image.

        Returns a nipype InterfaceResult object.

        """

        return self.memory.cache(SUSAN)(
            in_file=str(self.func_path),
            brightness_threshold=2000.0,
            fwhm=5.0,
            output_type="NIFTI"
        )


    def SpecifySPMModel(self, SUSAN_result):
        """
        Generates SPM-specific model.

        Returns a nipype InterfaceResult object.

        """

        return self.memory.cache(SpecifySPMModel)(
            functional_runs=str(SUSAN_result.outputs.smoothed_file),
            concatenate_runs=False,
            input_units='secs',
            output_units='secs',
            time_repetition=self.time_repetition(),
            high_pass_filter_cutoff=128,
            subject_info = self.subject_info()
        )


    def Level1Design(self, SpecifySPMModel_result):
        """
        Generates an SPM design matrix.

        Returns a nipype InterfaceResult object.

        """

        return self.memory.cache(Level1Design)(
            bases={'hrf': {'derivs': [1, 0]}},
            timing_units='secs',
            interscan_interval=self.time_repetition(),
            session_info=SpecifySPMModel_result.outputs.session_info
        )


    def EstimateModel(self, Level1Design_result):
        """
        Estimates the parameters of the model.

        Returns a nipype InterfaceResult object.

        """

        return self.memory.cache(EstimateModel)(
            estimation_method={'Classical': 1},
            spm_mat_file=Level1Design_result.outputs.spm_mat_file
        )


    def EstimateContrast(self, EstimateModel_result):
        """
        Estimates the parameters of the model.

        Returns a nipype InterfaceResult object.

        """


        return self.memory.cache(EstimateContrast)(
            spm_mat_file=EstimateModel_result.outputs.spm_mat_file,
            beta_images=EstimateModel_result.outputs.beta_images,
            residual_image=EstimateModel_result.outputs.residual_image,
            contrasts=self.contrasts()
        )


    def time_repetition(self):
        """
        Returns the time repetition. To run SpecifySPMModel(), we need this.

        """

        with open(self.bold_json_path, 'r') as json_file:
            task_info = json.load(json_file)
        return task_info['RepetitionTime']


    def subject_info(self):
        """
        Returns some subject info. To run SpecifySPMModel(), we need this.

        """

        # First we'll extract info from the events file.
        trialinfo = pandas.read_table(self.bold_tsv_path)
        conditions = []
        onsets = []
        durations = []
        for group in trialinfo.groupby('trial_type'):
            conditions.append(group[0])
            onsets.append(list(group[1].onset))
            durations.append(list(group[1].duration))


        # Now we'll extract info from the regressors file.
        regressorinfo = pandas.read_table(self.regressors_path,
                                      sep="\t",
                                      na_values="n/a")
        regressors=[]
        regressor_names=[]

        for column_name in regressorinfo:

            # Grab motion regressors
            if "trans" in column_name or "rot" in column_name:
                regressor_names.append(column_name)
                regressors.append(list(regressorinfo[column_name].fillna(0)))


        return [Bunch(conditions=conditions,
                    onsets=onsets,
                    durations=durations,
                    #amplitudes=None,
                    #tmod=None,
                    #pmod=None,
                    regressor_names=regressor_names,
                    regressors=regressors
                    )]

   
    def contrasts(self):
        """
        Returns the list of contrasts to analyze. To run EstimateContrast(), we need this.

        """

        # Condition names
        condition_names = ['gabor']

        # Contrasts
        cont01 = ['gabor', 'T', condition_names, [1]]

        return [cont01]


    def write_report(self):
        """
        Writes some files to subject folder to check the quality of the analysis.

        """

        for contrast_path in self.output_dir.rglob("nipype-interfaces-spm-model-EstimateContrast/**/spmT*.nii"):
            output_path = self.output_dir / f"{contrast_path.stem}.png"
            print(f"Writing {output_path}")
            plot_stat_map(
                str(contrast_path),
                output_file=str(output_path),
                title=contrast_path.stem,
                bg_img=str(self.anat_path),
                threshold=3,
                display_mode="y",
                cut_coords=(-5, 0, 5, 10, 15),
                dim=-1
            )


def _get_subject_id(path) -> str:
    """
    Returns the subject ID found in the input file name.

    Returns "None" if no subject ID found.

    """
    
    potential_subject_ids = re.findall(r"sub-(\d+)", str(path))

    try:
        subject_id = potential_subject_ids[-1]
    except IndexError:
        subject_id = None

    return subject_id


if __name__ == "__main__":
    """
    Enables usage of the program from a shell.

    The user must specify the location of the BIDS directory.
    They can also specify EITHER a specific subject OR all subjects. Cool stuff!

    """

    parser = argparse.ArgumentParser(description="Runs a first-level analysis on a subject from the fMRIPrepped contrascan dataset.",
                                    epilog="The user must specify the location of the BIDS directory fMRIPrep was used on. They must also specify EITHER a specific subject OR all subjects. Cool stuff!")

    parser.add_argument("bids_dir",
                        type=str,
                        help="Root of the BIDS directory."
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-s",
                        "--subject",
                        type=str,
                        metavar="subject_id",
                        help="Analyze a specific subject.")

    group.add_argument('-a',
                        '--all',
                        action='store_true',
                        help="Analyze all subjects.")


    args = parser.parse_args()


    if args.all:
        bids_dir = pathlib.Path(args.bids_dir)

        # Extract subject id's from the folder names in bids_dir and run them through the program.
        for subject_dir in bids_dir.glob("sub-*"):
            subject_id = _get_subject_id(subject_dir)
            print(f"Processing subject {subject_id}")
            FirstLevel(bids_dir, subject_id).write_report()

    else:
        FirstLevel(args.bids_dir, args.subject).write_report()