#!/usr/bin/env python3
"""
Run a t-test on four regions of interest in the contrascan dataset: R/L intracalcarine cortex and R/L occipital pole.

Created on 2/15/2021 by Benjamin Velie.
veliebm@gmail.com
"""

# Import standard Python libraries.
from typing import Any, Dict, Iterable, List
import nibabel
import scipy
import numpy
import argparse
from pathlib import Path
from dataclasses import field, dataclass

# Import custom CSEA libraries.
from atlas import Atlas
from neuropath import NeuroPath
from reference import the_path_that_matches

# Set constants.
ATLAS = Atlas()
Subject_ids = Iterable[str]

# Define class to store IRF data
@dataclass
class IRF:
    """
    Attributes
    ----------
    bids_path : NeuroPath
        NeuroPath to the location of the IRF.
    image : NiBabel image
        Representation of the IRF's data.
    means : dict[str, List]
        Stores any means we calculate. Key=region, value=list where each item is the mean of a timepoint of the IRF.
    """
    bids_path: NeuroPath
    image: Any
    means: Dict[str, list] = field(default_factory=dict)
    
    
    def __getitem__(self, key: str) -> str:
        """
        Let us access our inner BIDS path.
        """
        return self.bids_path[key]


    def get_mask(self, region: str) -> numpy.ma.masked_array:
        """
        Returns the array for this image masked to the specified region.
        """
        return ATLAS.mask_image(self.image, region)


    def get_mean_of_each_time_point(self, region: str) -> list:
        """
        Finds the mean activation at each time point in the specified region.

        Returns a 1D array of the mean activation in order. Also adds the mean to self.means.
        """
        masked_array = self.get_mask(region)
        
        fourth_dimension_length=masked_array.shape[3]
        means = [masked_array[:,:,:,i].mean() for i in range(fourth_dimension_length)]
        self.means[region] = means
        
        return means


def main(bids_directory: Path, subjects: Subject_ids, regions_of_interest: Iterable[str]):
    """
    Run a t-test on four regions of interest in the contrascan dataset: R/L intracalcarine cortex and R/L occipital pole.
    """
    irf_directory = bids_directory / "derivatives/afniproc_vs_fmriprep_test/"
    
    # Get all IRFs.
    irfs = get_irfs(irf_directory, subjects)
    fmriprep_irfs = [irf for irf in irfs if irf["pipeline"] == "fmriprep"]
    afniproc_irfs = [irf for irf in irfs if irf["pipeline"] == "afniproc"]

    # Within each IRF image, get the average time series of each region of interest.
    _add_means_to_irfs(irfs, regions_of_interest)

    # T test the four regions of interest.
    for region in regions_of_interest:
        fmriprep_means = _get_all_means_for_region(fmriprep_irfs, region)
        afniproc_means = _get_all_means_for_region(afniproc_irfs, region)

        print(region)
        print("-"*10)
        print("fmriprep")
        print(fmriprep_means)
        print("afniproc")
        print(afniproc_means)
        print()


def _get_all_means_for_region(irfs: Iterable[IRF], region: str) -> numpy.array:
    """
    Returns array containing the means for a given region for a list of IRF's.
    """
    return numpy.array([irf.means[region] for irf in irfs])


def _add_means_to_irfs(irfs: Iterable[IRF], regions_of_interest: Iterable[str]) -> None:
    """
    Within each IRF image, get the average time series of each region of interest.
    """
    for irf in irfs:
        print(f"Getting means of regions of interest for {irf.bids_path.path}")
        for region in regions_of_interest:
            irf.get_mean_of_each_time_point(region)
            print(f"{region}  :  {irf.means[region]}")
        print()


def get_irfs(directory: Path, subjects: Subject_ids) -> List[IRF]:
    """
    Returns a list of IRF objects for the target subjects.
    """
    bids_paths = [NeuroPath(path) for path in directory.glob("*_IRF_res-01*.HEAD")]
    return [IRF(bids_path, nibabel.load(bids_path.path)) for bids_path in bids_paths]


def list_subjects_in(directory: Path, exclude: Subject_ids=[]) -> Subject_ids:
    """
    Returns a list of all subjects in a directory.
    """
    subdirectories = directory.glob("sub-*")
    subject_list = [NeuroPath(path)["sub"] for path in subdirectories]
    filtered_subject_list = [subject for subject in subject_list if subject not in exclude]
    
    return filtered_subject_list


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    It contains the parser that parses arguments from the command line.
    """

    parser = argparse.ArgumentParser(description="Run a t-test on four regions of interest in the contrascan data set: R/L intracalcarine cortex and R/L occipital pole.")
  
    group = parser.add_mutually_exclusive_group(required=True)  
    group.add_argument("--subjects", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze a list of specific subject IDs. Example: '--subjects 107 108 110'. Mutually exclusive with --all.")
    group.add_argument('--all', action='store_true', help="<Mandatory> Analyze all subjects. Mutually exclusive with --subjects.")
    group.add_argument("--all_except", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Analyze all subjects but exclude those specified here. Example: '--all_except 109 111'")

    parser.add_argument("--bids_directory", type=Path, required=True, help="<Mandatory> BIDS directory.")

    # Parse args from the command line and create an empty list to store the subject ids we picked.
    arguments = parser.parse_args()
    print(f"Arguments: {arguments}")
    subject_list = []

    # Option 1: Process all subjects except some.
    if arguments.all_except:
        subject_list = list_subjects_in(arguments.bids_directory, exclude=arguments.all_except)
    
    # Option 2: Process all subjects.
    elif arguments.all:
        subject_list = list_subjects_in(arguments.bids_directory)

    # Option 3: Process specific subjects.
    else:
        subject_list = arguments.subjects

    # Launch the program on the subjects we picked.
    main(
        bids_directory=arguments.bids_directory,
        subject_list=subject_list,
    )


# Variables used only for convenience in iPython. Do not use these outside iPython.
bids_directory = Path("/mnt/f/files/dataset-contrascan/bids_attempt-3")
subjects = list_subjects_in(bids_directory, exclude=["102", "126"])
regions_of_interest = ("Left Intracalcarine Cortex", "Right Intracalcarine Cortex", "Left Occipital Pole", "Right Occipital Pole")
