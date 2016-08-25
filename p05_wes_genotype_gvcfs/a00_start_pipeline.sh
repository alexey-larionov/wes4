#!/bin/bash

# a00_start_pipeline.sh
# Start genotyping gvcfs
# Alexey Larionov, 24Aug2016

## Read parameter
job_file="${1}"
scripts_folder="${2}"

# Read job's settings
source "${scripts_folder}/a01_read_config.sh"

# Start lane pipeline log
mkdir -p "${logs_folder}"
log="${logs_folder}/${dataset}_genotype_and_assess.log"

echo "WES library: genotype gvcfs" > "${log}"
echo "${dataset}: genotype gvcfs, add var IDs, multiallelic flag and calculate stats">> "${log}" 
echo "Started: $(date +%d%b%Y_%H:%M:%S)" >> "${log}"
echo "" >> "${log}" 

echo "====================== Settings ======================" >> "${log}"
echo "" >> "${log}"

source "${scripts_folder}/a02_report_settings.sh" >> "${log}"

echo "=================== Pipeline steps ===================" >> "${log}"
echo "" >> "${log}"

# Submit job
slurm_time="--time=${time_to_request}"
slurm_account="--account=${account_to_use}"

sbatch "${slurm_time}" "${slurm_account}" \
  "${scripts_folder}/s01_genotype_gvcfs.sb.sh" \
  "${job_file}" \
  "${scripts_folder}" \
  "${log}"

# Update pipeline log
echo "" >> "${log}"
echo "Submitted s01_genotype_gvcfs: $(date +%d%b%Y_%H:%M:%S)" >> "${log}"
echo "" >> "${log}"