#!/bin/bash

## s02_preprocess_and_gvcf.sb.sh
## Bam preprocessing and making gvcf for a wes sample
## SLURM submission script
## Alexey Larionov, 23Aug2016

## Name of the job:
#SBATCH -J preprocess_and_gvcf

## How much wallclock time will be required?
#SBATCH --time=02:00:00

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

## Modules section (required, do not remove)
## Can be modified to set the environment seen by the application
## (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):
. /etc/profile.d/modules.sh                # Enables the module command
module purge                               # Removes all loaded modules
module load default-impi                   # Loads the basic environment (later may be changed to a MedGen specific one)

## Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

## Read parameters
sample="${1}"
job_file="${2}"
logs_folder="${3}"
scripts_folder="${4}"
pipeline_log="${5}"

## Report settings and run the job
echo ""
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo ""
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo "Sample: ${sample}"
echo ""
echo " ------------------ Output ------------------ "
echo ""

## Do the job
sample_log="${logs_folder}/s02_preprocess_and_gvcf_${sample}.log"
"${scripts_folder}/s02_preprocess_and_gvcf.sh" \
         "${sample}" \
         "${job_file}" \
         "${scripts_folder}" \
         "${pipeline_log}" &> "${sample_log}"
