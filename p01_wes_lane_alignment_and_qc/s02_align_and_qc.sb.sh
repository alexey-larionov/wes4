#!/bin/bash

## s02_align_and_qc.sb.sh
## Wes sample alignment and QC
## SLURM submission script
## Alexey Larionov, 27Jul2016

## Name of the job:
#SBATCH -J align_and_qc

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
data_type="${6}"

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

# Log file
sample_log="${logs_folder}/s02_align_and_qc_${sample}_${data_type}.log"

# pe data
if [ "${data_type}" == "pe" ]
then 
  "${scripts_folder}/s02_align_and_qc_pe.sh" \
         "${sample}" \
         "${job_file}" \
         "${scripts_folder}" \
         "${pipeline_log}" \
         "${data_type}" &> "${sample_log}"
fi

# se data
if [ "${data_type}" == "se" ]
then 
  "${scripts_folder}/s02_align_and_qc_se.sh" \
         "${sample}" \
         "${job_file}" \
         "${scripts_folder}" \
         "${pipeline_log}" \
         "${data_type}" &> "${sample_log}"
fi
