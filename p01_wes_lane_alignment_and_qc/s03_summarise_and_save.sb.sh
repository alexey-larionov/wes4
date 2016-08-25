#!/bin/bash

## s03_summarise_and_save.sb.sh
## Collect and plot summary metrics for wes lane alignment and QC
## Move data from HPC to NAS
## SLURM submission script
## Alexey Larionov, 02Aug2016

## Name of the job:
#SBATCH -J summarise_and_save

## How much wallclock time will be required?
#SBATCH --time=01:00:00

## Which project should be charged:
#SBATCH -A TISCHKOWITZ-SL3

## What resources should be allocated?
#SBATCH --nodes=1
#SBATCH --exclusive

## What types of email messages do you wish to receive?
#SBATCH --mail-type=ALL

## Do not resubmit if interrupted by node failure or system downtime
#SBATCH --no-requeue

## Partition (do not change)
#SBATCH -p sandybridge

## Jump the queue
##SBATCH --qos=INTR

## Modules section (required, do not remove)
## Can be modified to set the environment seen by the application
## (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):
. /etc/profile.d/modules.sh                # Enables the module command
module purge                               # Removes all loaded modules
module load default-impi                   # Loads the basic environment (later may be changed to a MedGen specific one)

## Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

## Read parameters
job_file="${1}"
logs_folder="${2}"
scripts_folder="${3}"
pipeline_log="${4}"

## Report settings and run the job
echo ""
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo ""
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo " ------------------ Output ------------------ "
echo ""

## Do the job
log="${logs_folder}/s03_summarise_and_save.log"
"${scripts_folder}/s03_summarise_and_save.sh" \
         "${job_file}" \
         "${scripts_folder}" \
         "${pipeline_log}" \ &> "${log}"
