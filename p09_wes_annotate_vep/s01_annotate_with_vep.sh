#!/bin/bash

# s01_annotate_with_vep.sh
# Annotating filtered vcfs with vep
# Alexey Larionov, 25Aug2016

# Stop on errors
set -e

# Read parameters
job_file="${1}"
scripts_folder="${2}"

# Update pipeline log
echo "Started s01_annotate_with_vep: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# Set parameters
source "${scripts_folder}/a01_read_config.sh"
echo "Read settings"
echo ""

# Make tmp folder
mkdir -p "${tmp_folder}"

# Go to working folder
init_dir="$(pwd)"
cd "${annotated_vcf_folder}"

# --- Copy source gvcfs to cluster --- #

# Suppress stopping on errors
set +e

# Progress report
echo "Started copying source data"

rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${dataset}_vcf/${dataset}.vcf" "${tmp_folder}/"
exit_code_1="${?}"

rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${dataset}_vcf/${dataset}.vcf.idx" "${tmp_folder}/"
exit_code_2="${?}"

rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${dataset}_vcf/${dataset}_cln.vcf" "${tmp_folder}/"
exit_code_3="${?}"

rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${dataset}_vcf/${dataset}_cln.vcf.idx" "${tmp_folder}/"
exit_code_4="${?}"

# Stop if copying failed
if [ "${exit_code_1}" != "0" ] || [ "${exit_code_2}" != "0" ] || [ "${exit_code_3}" != "0" ] || [ "${exit_code_4}" != "0" ] 
then
  echo ""
  echo "Failed getting source data from NAS"
  echo "Script terminated"
  echo ""
  exit
fi

# Restore stopping at errors
set -e

# ------------------------------------ #

# Progress report
echo "Completed copying source data: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Configure PERL5LIB --- #
PERL5LIB="${ensembl_api_folder}/BioPerl-1.6.1"
PERL5LIB="${PERL5LIB}:${ensembl_api_folder}/ensembl/modules"
PERL5LIB="${PERL5LIB}:${ensembl_api_folder}/ensembl-compara/modules"
PERL5LIB="${PERL5LIB}:${ensembl_api_folder}/ensembl-variation/modules"
PERL5LIB="${PERL5LIB}:${ensembl_api_folder}/ensembl-funcgen/modules"
export PERL5LIB

# --- Run vep script for full vcf --- #

# Progress report
echo "Started VEP for full vcf file"

# Set file names
full_vcf_in="${tmp_folder}/${dataset}.vcf"

full_vep_vcf="${annotated_vcf_folder}/${dataset}_vep.vcf"
full_vep_stats="${annotated_vcf_folder}/${dataset}_vep.html"
full_vep_log="${logs_folder}/${dataset}_vep.log"
full_vep_md5="${annotated_vcf_folder}/${dataset}_vep.md5"

# Run script with vcf output
perl "${vep_script}" \
  -i "${full_vcf_in}" \
  -o "${full_vep_vcf}" --vcf \
  --stats_file "${full_vep_stats}" \
  --cache --offline --dir_cache "${vep_cache}" \
  --pick --allele_number --check_existing --check_alleles \
  --symbol --gmaf --sift b --polyphen b \
  --fields "${vcf_vep_fields}" --vcf_info_field "ANN" \
  --force_overwrite --fork 14 --no_progress \
  &> "${full_vep_log}"

# Progress report
echo "Completed writing vep annotations to vcf file: $(date +%d%b%Y_%H:%M:%S)"

# Make md5 file for full vep-annotated vcf
md5sum $(basename "${full_vep_vcf}") > "${full_vep_md5}"

# --- Run vep script for clean vcf --- #

# Progress report
echo "Started VEP for clean vcf file"

# Set file names
cln_vcf_in="${tmp_folder}/${dataset}_cln.vcf"

cln_vep_vcf="${annotated_vcf_folder}/${dataset}_cln_vep.vcf"
cln_vep_stats="${annotated_vcf_folder}/${dataset}_cln_vep.html"
cln_vep_log="${logs_folder}/${dataset}_cln_vep.log"
cln_vep_md5="${annotated_vcf_folder}/${dataset}_cln_vep.md5"

# Run script with vcf output
perl "${vep_script}" \
  -i "${cln_vcf_in}" \
  -o "${cln_vep_vcf}" --vcf \
  --stats_file "${cln_vep_stats}" \
  --cache --offline --dir_cache "${vep_cache}" \
  --pick --allele_number --check_existing --check_alleles \
  --symbol --gmaf --sift b --polyphen b \
  --fields "${vcf_vep_fields}" --vcf_info_field "ANN" \
  --force_overwrite --fork 14 --no_progress \
  &> "${cln_vep_log}"

# Progress report
echo "Completed writing vep annotations to vcf file: $(date +%d%b%Y_%H:%M:%S)"

# Make md5 file for clean vcf
md5sum $(basename "${cln_vep_vcf}") > "${cln_vep_md5}"

# --- Remove temporary files from cluster --- #
rm -fr "${tmp_folder}"

# --- Copy output to NAS --- #

# Suppress stopping on errors
set +e

# Progress report
echo "Started copying results to NAS"

# Copy files to NAS
rsync -thrqe "ssh -x" "${annotated_vcf_folder}" "${data_server}:${project_location}/${project}/" 
exit_code="${?}"

# Stop if copying failed
if [ "${exit_code}" != "0" ]  
then
  echo ""
  echo "Failed copying results to NAS"
  echo "Script terminated"
  echo ""
  exit
fi

# Restore stopping at errors
set -e

# ------------------------------------ #

# Progress report
log_on_nas="${project_location}/${project}/${dataset}_vep/logs/${dataset}_vep.log"
timestamp="$(date +%d%b%Y_%H:%M:%S)"
ssh -x "${data_server}" "echo \"Completed copying results to NAS: ${timestamp}\" >> ${log_on_nas}"
ssh -x "${data_server}" "echo \"\" >> ${log_on_nas}"

# Remove results from cluster

#rm -fr "${logs_folder}"

rm -f "${full_vep_vcf}"
rm -f "${full_vep_txt}"
rm -f "${full_stats_file}"
rm -f "${full_vep_md5}"

rm -f "${cln_vep_vcf}"
rm -f "${cln_vep_txt}"
rm -f "${cln_stats_file}"
rm -f "${cln_vep_md5}"

ssh -x "${data_server}" "echo \"Removed results from cluster\" >> ${log_on_nas}"
ssh -x "${data_server}" "echo \"\" >> ${log_on_nas}"

# Return to the initial folder
cd "${init_dir}"
