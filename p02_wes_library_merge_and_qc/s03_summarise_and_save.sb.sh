#!/bin/bash

## s03_summarise_and_save.sb.sh
## Plot summary metrics for merged wes samples and save results to NAS
## SLURM submission script
## Alexey Larionov, 23Aug2016

## Name of the job:
#SBATCH -J summarise_and_save

## How much wallclock time will be required?
#SBATCH --time=01:00:00

## Which project should be charged:
#SBATCH -A TISCHKOWITZ-SL2

## What resources should be allocated?
#SBATCH --nodes=1
#SBATCH --exclusive

## What types of email messages do you wish to receive?
#SBATCH --mail-type=ALL

## Do not resubmit if interrupted by node failure or system downtime
#SBATCH --no-requeue

## Partition (do not change)
#SBATCH -p sandybridge

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

#job_file="/scratch/medgen/scripts/wes_pipeline_08.16/a01_job_templates/TEMPLATE_02_wes_library_merge_qc_v1.job"
#logs_folder="/scratch/medgen/users/eleanor/Pipeline_working_directory/gastric_Aug16/gastric/IGP_L1/merged/f00_logs/"
#scripts_folder="/scratch/medgen/scripts/wes_pipeline_08.16/p02_wes_library_merge_and_qc/"
#pipeline_log="/scratch/medgen/users/eleanor/Pipeline_working_directory/gastric_Aug16/gastric/IGP_L1/merged/f00_logs/a00_pipeline_gastric_IGP_L1.log"

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
