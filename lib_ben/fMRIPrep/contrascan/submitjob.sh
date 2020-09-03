#! /bin/bash
# Script to submit contrascan to HiPerGator to process with fMRIPrep.
# Shamelessly stolen from https://fmriprep.org/en/stable/singularity.html on 9/3/2020
# then further edited by Benjamin Velie.
# veliebm@gmail.com
#
#SBATCH -J fmriprep                         # The name of the job.    
#SBATCH --time=48:00:00                     # Time limit on the job.
#SBATCH -n 1                                # Number of tasks.
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4G
#SBATCH --qos akeil                         # Here we name which quality of service level we want to use. akeil is the low resources one we can use easily, akeil-b is our high-performance one you'll probably need to wait a while in line to use.
# Outputs ----------------------------------
#SBATCH -o Logs/%x-%A-%a.out
#SBATCH -e Logs/%x-%A-%a.err
#SBATCH --mail-user=veliebm@ufl.edu         # Your UF email address so you can get updates about the job.
#SBATCH --mail-type=ALL                     # What notifications to send to your email.
# ------------------------------------------

BIDS_DIR="$STUDY"
DERIVS_DIR="derivatives/fmriprep"
LOCAL_FREESURFER_DIR="$STUDY/derivatives/freesurfer"

# Make sure FS_LICENSE is defined in the container.
export SINGULARITYENV_FS_LICENSE=/blue/akeil/veliebm/Files/Licenses/freesurfer.txt

# Prepare some writeable bind-mount points.
TEMPLATEFLOW_HOST_HOME=$HOME/.cache/templateflow
FMRIPREP_HOST_CACHE=$HOME/.cache/fmriprep
mkdir -p "${TEMPLATEFLOW_HOST_HOME}"
mkdir -p "${FMRIPREP_HOST_CACHE}"

# Prepare derivatives folder
mkdir -p "${BIDS_DIR}"/${DERIVS_DIR}

# Designate a templateflow bind-mount point
export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
SINGULARITY_CMD="singularity run --cleanenv -B $BIDS_DIR:/data -B ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} -B $L_SCRATCH:/work -B ${LOCAL_FREESURFER_DIR}:/fsdir /blue/akeil/veliebm/Files/Images/fmriprep_latest.sif"

# Parse the participants.tsv file and extract one subject ID from the line corresponding to this SLURM task.
subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*)\>.*/\1/gp" "${BIDS_DIR}"/participants.tsv )

# Remove IsRunning files from FreeSurfer
find "${LOCAL_FREESURFER_DIR}"/sub-"$subject"/ -name "*IsRunning*" -type f -delete

# Compose the command line
cmd="${SINGULARITY_CMD} /data /data/${DERIVS_DIR} participant --participant-label $subject -w /work/ -vv --output-spaces MNI152NLin2009cAsym:res-2 anat fsnative fsaverage5 --use-aroma --fs-subjects-dir /fsdir"

# Setup done, run the command
echo Running task "${SLURM_ARRAY_TASK_ID}"
echo Commandline: "$cmd"
eval "$cmd"
exitcode=$?

# Output results to a table
echo "sub-$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> "${SLURM_JOB_NAME}"."${SLURM_ARRAY_JOB_ID}".tsv
echo Finished tasks "${SLURM_ARRAY_TASK_ID}" with exit code $exitcode
exit $exitcode