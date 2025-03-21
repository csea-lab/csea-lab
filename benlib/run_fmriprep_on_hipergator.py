#!/usr/bin/env python3

"""
Process subjects from a BIDS-valid dataset via Singularity containers on HiPerGator.

Note that you MUST run this script with Python 3, not Python 2.

Created 9/16/2020 by Ben Velie.
veliebm@gmail.com
"""

import argparse
from pathlib import Path
import subprocess
import re
import time
import os


# Track start datetime so we can use it to name the log files.
now = time.localtime()
START_TIME = f"{now.tm_hour}.{now.tm_min}.{now.tm_sec}"
START_DATE = f"{now.tm_mon}.{now.tm_mday}.{now.tm_year}"


def write_script(script_path, time_requested, email_address, number_of_processors, qos, subject_id, bids_dir, singularity_image_path):
    """
    Writes the SLURM script that we'll automatically submit to the cluster.

    Parameters
    ----------
    script_path : str
        Where to write the script.
    time_requested : str
        Amount of time to request for job. Format as d-hh:mm:ss.
    email_address : str
        Email address to send job updates to.
    number_of_processors : str
        Amount of processors to use in the job.
    qos : str
        QOS to use for the job. Can choose investment QOS (akeil) or burst QOS (akeil-b).
    subject_id : str
        Subject ID to target.
    bids_dir : str or Path
        Path to the root of the BIDS directory.
    singularity_image_path : str or Path
        Path to an fMRIPrep Singularity image.
    """

    # Get the contents of the SLURM script as a nice, big string.
    script_contents = f"""#! /bin/bash

# {__file__} generated this script on {START_DATE} at {START_TIME}.
# Then, {__file__} ran this script, which kindly asks fMRIPrep to preprocess sub-{subject_id} inside a
# Singularity container using the great might of HiPerGator.

#SBATCH --job-name=sub-{subject_id} 				# Job name
#SBATCH --ntasks=1					                # Run a single task		
#SBATCH --cpus-per-task={number_of_processors}		# Number of CPU cores per task
#SBATCH --mem=8gb						            # Job memory request. You should never need to change this from 8gb for fMRIPrep.
#SBATCH --time={time_requested}				        # Walltime in hh:mm:ss or d-hh:mm:ss
#SBATCH --qos={qos}                                 # QOS level to use. Can be investment (akeil) or burst (akeil-b).
# Outputs ----------------------------------
#SBATCH --mail-type=ALL					            # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user={email_address}		            # Where to send mail	
#SBATCH --output={script_path.stem}.log                  # Standard output log
#SBATCH --error={script_path.stem}.err           	    # Standard error log
pwd; hostname; date				                    # Useful things we'll want to see in the log
# ------------------------------------------

DERIVS_DIR="{bids_dir}/derivatives/preprocessing/sub-{subject_id}"
LOCAL_FREESURFER_DIR="$DERIVS_DIR/freesurfer"

# Make sure FS_LICENSE is defined in the container.
export SINGULARITYENV_FS_LICENSE="/blue/akeil/.licenses/freesurfer.txt"

# Prepare derivatives folder.
mkdir -p "$DERIVS_DIR"
mkdir -p "$LOCAL_FREESURFER_DIR"

# Compose command to start singularity.
SINGULARITY_CMD="singularity run --cleanenv {singularity_image_path}"

# Remove IsRunning files from FreeSurfer.
find "$LOCAL_FREESURFER_DIR/sub-$subject"/ -name "*IsRunning*" -type f -delete

# Compose the command line.
cmd="$SINGULARITY_CMD {bids_dir} $DERIVS_DIR participant --participant-label {subject_id} -vv --resource-monitor --write-graph --nprocs {number_of_processors} --mem_mb 8000"

# Setup done, run the command.
echo Running task "$SLURM_ARRAY_TASK_ID"
echo Commandline: "$cmd"
eval "$cmd"
exitcode=$?

echo Finished processing subject "$subject" with exit code $exitcode
exit $exitcode
    """

    # Write the SLURM script.
    with open(script_path, "w") as script:
        script.write(script_contents)


def subject_id_of(path) -> str:
    """
    Returns the subject ID closest to the end of the input string or Path.

    Inputs
    ------
    path : str or Path
        String or Path containing the subject ID.

    Returns
    -------
    str
        Subject ID found in the filename

    Raises
    ------
    RuntimeError
        If no subject ID found in input filename.
    """

    try:
        subject_ids = re.findall(r"sub-(\d+)", str(path))
        return subject_ids[-1]
    except IndexError:
        raise RuntimeError(f"No subject ID found in {path}")


if __name__ == "__main__":
    """
    This section of the script only runs when you run the script directly from the shell.

    Thus, this is where we read and interpret arguments from the command line.
    """

    parser = argparse.ArgumentParser(description=f"Launch this script on HiPerGator to run fMRIPrep on your BIDS-valid dataset! Each subject receives their own container. You may specify EITHER specific subjects OR all subjects. Final outputs are written to bids_dir/derivatives/preprocessing/. Intermediate results are written to the current working directory. Remember to only do your work in subdirectories of /blue/akeil/{os.getlogin()}!", fromfile_prefix_chars="@")

    parser.add_argument("--bids_dir", "-b", type=Path, required=True, help="<Mandatory> Path to the root of the BIDS directory. Example: '--bids_dir /blue/akeil/veliebm/files/contrascan/bids_attempt-3'")

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--subjects", "-s", metavar="SUBJECT_ID", nargs="+", help="<Mandatory> Preprocess a list of specific subject IDs. Mutually exclusive with '--all'. Example: '--subjects 107 110 123'")
    group.add_argument('--all', '-a', action='store_true', help="<Mandatory> Analyze all subjects. Mutually exclusive with '--subjects'. Example: '--all'")

    parser.add_argument("--time", "-t", default="4-00:00:00", metavar="d-hh:mm:ss", help="Default: 4-00:00:00. Maximum time the job can run. Burst QOS max allowed: 4 days. Investment QOS max allowed: 31 days. Example (3.5 days): '--time 3-12:00:00'")
    parser.add_argument("--n_procs", '-n', default="2", metavar="PROCESSORS", help="Default: 2. Number of processors to use per subject. Example: '--n_procs 4'")
    parser.add_argument("--qos", "-q", default="akeil-b", choices=["akeil", "akeil-b"], help="Default: akeil-b (burst QOS). QOS level to use. Example (investment QOS): '--qos akeil'")
    parser.add_argument("--email", "-e", metavar="EMAIL_ADDRESS", default=f"{os.getlogin()}@ufl.edu", help=f"Default: {os.getlogin()}@ufl.edu. Email address to send job updates to. Example: '--email veliebm@gmail.com'")

    # Gather arguments from the command line.
    args = parser.parse_args()
    print(f"Arguments: {args}")

    # Option 1: Process all subjects.
    subject_ids = []
    if args.all:
        bids_root = args.bids_dir
        for subject_dir in bids_root.glob("sub-*"):
            subject_ids.append(subject_id_of(subject_dir))

    # Option 2: Process specific subjects.
    else:
        subject_ids = args.subjects

    # Get fMRIPrep singularity image.
    images_dir = Path().absolute() / "images"
    singularity_image_path = images_dir / "fmriprep_latest.sif"
    if singularity_image_path.exists():
        print(f"Detected a singularity image at {singularity_image_path}")
        print("I'm going to use this image.")
    else:
        print(f"Failed to detect a pre-existing singularity image at {singularity_image_path}")
        print("Attempting to download a fresh image.")
        images_dir.mkdir(exist_ok=True, parents=True)
        process = subprocess.Popen(["singularity", "pull", "docker://poldracklab/fmriprep:latest"], cwd=images_dir)
        process.wait()
        print("Downloaded fresh image.")
    
    for subject_id in subject_ids:

        # Create working directory for subject.
        work_path = Path(f"./sub-{subject_id}").absolute()
        work_path.mkdir(exist_ok=True)

        script_path = work_path / f"sub-{subject_id}_date-{START_DATE}_time-{START_TIME}_fmriprep.sh"

        # Write SLURM script.
        write_script(
            script_path=script_path,
            time_requested=args.time,
            email_address=args.email,
            number_of_processors=args.n_procs,
            qos=args.qos,
            subject_id=subject_id,
            bids_dir=args.bids_dir.absolute(),
            singularity_image_path=singularity_image_path
        )

        # Run SLURM script.
        print(f"Submitting {script_path.name}")
        subprocess.Popen(["sbatch", script_path], cwd=work_path)

    print("All intermediate work and logs will be saved to folders in the current working directory.")
    print("All final results will be written to the derivatives folder in the root of your BIDS dataset.")