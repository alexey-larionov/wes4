#!/bin/bash

# s01_filter_vcf.sh
# Filtering vcf
# Alexey Larionov, 29Aug2016

# Selected Refs:
# http://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set
# http://gatkforums.broadinstitute.org/gatk/discussion/53/combining-variants-from-different-files-into-one

# stop at any error
set -e

# Read parameters
job_file="${1}"
scripts_folder="${2}"

# Update pipeline log
echo "Started s01_filter_vcf: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# Set parameters
source "${scripts_folder}/a01_read_config.sh"
echo "Read settings"
echo ""

# Go to working folder
init_dir="$(pwd)"
cd "${filtered_vcf_folder}"

# --- Copy source gvcfs to cluster --- #

# Progress report
echo "Started copying source data"

# Source files and folders (on source server)
source_vcf_folder="${dataset_name}_raw_vcf"
source_vcf="${dataset_name}_raw.vcf"

# Intermediate files and folders on HPC
tmp_folder="${filtered_vcf_folder}/tmp"
mkdir -p "${tmp_folder}"
mkdir -p "${histograms_folder}"
mkdir -p "${all_vcfstats_folder}"
mkdir -p "${cln_vcfstats_folder}"

# --- Copy data --- #

# Do not stop at errors
set +e

rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${source_vcf_folder}/${source_vcf}" "${tmp_folder}/"
exit_code_1="${?}"

rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${source_vcf_folder}/${source_vcf}.idx" "${tmp_folder}/"
exit_code_2="${?}"

# Stop if copying failed
if [ "${exit_code_1}" != "0" ] || [ "${exit_code_2}" != "0" ]  
then
  echo ""
  echo "Failed getting source data from NAS"
  echo "Script terminated"
  echo ""
  exit
fi

# Stop ar errors
set -e

# ------------------- #

# Progress report
echo "Completed copying source data: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Select SNPs --- #

# Progress report
echo "Started selecting SNPs"

# File names
raw_input_vcf="${tmp_folder}/${dataset_name}_raw.vcf"
raw_snp_vcf="${tmp_folder}/${dataset_name}_snp_raw.vcf"
select_snp_log="${logs_folder}/${dataset_name}_snp_select.log"

# Selecting SNPs
"${java7}" -Xmx60g -jar "${gatk}" \
  -T SelectVariants \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  -V "${raw_input_vcf}" \
  -o "${raw_snp_vcf}" \
  -selectType SNP \
  -nt 14 &>  "${select_snp_log}"

# Progress report
echo "Completed selecting SNPs: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Select INDELs --- #

# Progress report
echo "Started selecting INDELs"

# File names
raw_indel_vcf="${tmp_folder}/${dataset_name}_indel_raw.vcf"
select_indel_log="${logs_folder}/${dataset_name}_indel_select.log"

# Selecting INDELs
"${java7}" -Xmx60g -jar "${gatk}" \
  -T SelectVariants \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  -V "${raw_input_vcf}" \
  -o "${raw_indel_vcf}" \
  -selectType INDEL \
  -nt 14 &>  "${select_indel_log}"

# Progress report
echo "Completed selecting INDELs: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Filter SNPs --- #

# Progress report
echo "Started filtering SNPs"

# File names
filt_snp_vcf="${tmp_folder}/${dataset_name}_snp_filt.vcf"
filt_snp_log="${logs_folder}/${dataset_name}_snp_filt.log"

# Filtering SNPs
"${java7}" -Xmx60g -jar "${gatk}" \
  -T VariantFiltration \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  -V "${raw_snp_vcf}" \
  -o "${filt_snp_vcf}" \
  --filterName "SNP_DP_LESS_THAN_${MIN_SNP_DP}" \
  --filterExpression "DP < ${MIN_SNP_DP}" \
  --filterName "SNP_QUAL_LESS_THAN_${MIN_SNP_QUAL}" \
  --filterExpression "QUAL < ${MIN_SNP_QUAL}" \
  --filterName "SNP_VQSR_Tranche_${SNP_TS}+" \
  --filterExpression "VQSLOD < ${MIN_SNP_VQSLOD}" \
  &>  "${filt_snp_log}"

# Progress report
echo "Completed filtering SNPs: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Filter INDELs --- #

# Progress report
echo "Started filtering INDELs"

# File names
filt_indel_vcf="${tmp_folder}/${dataset_name}_indel_filt.vcf"
filt_indel_log="${logs_folder}/${dataset_name}_indel_filt.log"

# Filtering INDELs
"${java7}" -Xmx60g -jar "${gatk}" \
  -T VariantFiltration \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  -V "${raw_indel_vcf}" \
  -o "${filt_indel_vcf}" \
  --filterName "INDEL_DP_LESS_THAN_${MIN_INDEL_DP}" \
  --filterExpression "DP < ${MIN_INDEL_DP}" \
  --filterName "INDEL_QUAL_LESS_THAN_${MIN_INDEL_QUAL}" \
  --filterExpression "QUAL < ${MIN_INDEL_QUAL}" \
  --filterName "INDEL_VQSR_Tranche_${INDEL_TS}+" \
  --filterExpression "VQSLOD < ${MIN_INDEL_VQSLOD}" \
  &>  "${filt_indel_log}"

# Progress report
echo "Completed filtering INDELs: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Combine split files --- #

# Progress report
echo "Started combining vcfs"

# File name
out_vcf="${filtered_vcf_folder}/${dataset_name}_${filter_name}.vcf"
combining_log="${logs_folder}/${dataset_name}_${filter_name}_cmb.log"

# Combining vcfs
"${java7}" -Xmx60g -jar "${gatk}" \
  -T CombineVariants \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  --variant:snp "${filt_snp_vcf}" \
  --variant:indel "${filt_indel_vcf}" \
  -o "${out_vcf}" \
  -genotypeMergeOptions PRIORITIZE \
  -priority snp,indel \
  &>  "${combining_log}"

# Note:
# The variants do not overlap, so the order of priorities is not important
# (just in case the priorities are set according the expected qulity of calls)  

# Progress report
echo "Completed combining vcfs: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Make md5 file --- #

out_vcf_md5="${filtered_vcf_folder}/${dataset_name}_${filter_name}.md5"
md5sum $(basename "${out_vcf}") $(basename "${out_vcf}.idx") > "${out_vcf_md5}"

# --- Prepare data for histograms --- #

# Progress report
echo "Started preparing data for histograms"

# File names
histograms_data_txt="${histograms_folder}/${dataset_name}_${filter_name}_hist_data.txt"
histograms_data_log="${logs_folder}/${dataset_name}_${filter_name}_hist_data.log"

# Prepare data
"${java7}" -Xmx60g -jar "${gatk}" \
  -T VariantsToTable \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  -V "${out_vcf}" \
  -F SplitVarID -F LocationID -F FILTER -F TYPE -F MultiAllelic \
  -F CHROM -F POS -F REF -F ALT -F DP -F QUAL -F VQSLOD \
  -o "${histograms_data_txt}" \
  -AMD -raw &>  "${histograms_data_log}"  

# -AMD allow missed data
# -raw keep filtered (the filtered variants are removed later in R scripts)

# Progress report
echo "Completed preparing data for histograms: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Generate histograms using R markdown script --- #

# Progress report
echo "Started making histograms"

# File names
histograms_report_html="${histograms_folder}/${dataset_name}_${filter_name}_hist.html"
histograms_plot_log="${logs_folder}/${dataset_name}_${filter_name}_hist_plot.log"

# Prepare R script for html report
html_dataset_filter_name="${dataset_name} ${filter_name}"

html_script="library('rmarkdown', lib='"${r_lib_folder}"'); render('"${scripts_folder}"/r01_make_html.Rmd', params=list(dataset='"${html_dataset_filter_name}"' , working_folder='"${histograms_folder}"/' , data_file='"${histograms_data_txt}"'), output_file='"${histograms_report_html}"')"

# Execute R script for html report
echo "-------------- Preparing html report -------------- " >> "${histograms_plot_log}"
echo "" >> "${histograms_plot_log}"
"${r_bin_folder}/R" -e "${html_script}" &>> "${histograms_plot_log}"
echo "" >> "${histograms_plot_log}"

# Progress report
echo "Completed making histograms: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- vcfstats for all variants --- #

# Progress report
echo "Started calculating vcfstats and making plots for all variants"
echo ""

# File names
all_vcf_stats="${all_vcfstats_folder}/${dataset_name}_${filter_name}_all.vchk"

# Calculate vcf stats
"${bcftools}" stats -F "${ref_genome}" "${out_vcf}" > "${all_vcf_stats}" 

# Plot the stats
"${plot_vcfstats}" "${all_vcf_stats}" -p "${all_vcfstats_folder}/"
echo ""

# Completion message to log
echo "Completed calculating vcf stats: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Make a "clean" copy of vcf without filtered variants --- #

# Progress report
echo "Started making clean vcf vithout filtered variants"

# File names
cln_vcf="${filtered_vcf_folder}/${dataset_name}_${filter_name}_cln.vcf"
cln_vcf_md5="${filtered_vcf_folder}/${dataset_name}_${filter_name}_cln.md5"
cln_vcf_log="${logs_folder}/${dataset_name}_${filter_name}_cln.log"

# Exclude filtered variants
"${java7}" -Xmx60g -jar "${gatk}" \
  -T SelectVariants \
  -R "${ref_genome}" \
  -L "${targets_intervals}" -ip 10 \
  -V "${out_vcf}" \
  -o "${cln_vcf}" \
  --excludeFiltered \
  -nt 14 &>  "${cln_vcf_log}"

# Make md5 file
md5sum $(basename "${cln_vcf}") $(basename "${cln_vcf}.idx") > "${cln_vcf_md5}"

# Completion message to log
echo "Completed making clean vcf: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- vcfstats for clean data --- #

# Progress report
echo "Started calculating vcfstats and making plots for clean variants"
echo ""

# File names
cln_vcf_stats="${cln_vcfstats_folder}/${dataset_name}_${filter_name}_cln.vchk"

# Calculate vcf stats
"${bcftools}" stats -F "${ref_genome}" "${cln_vcf}" > "${cln_vcf_stats}" 

# Plot the stats
"${plot_vcfstats}" "${cln_vcf_stats}" -p "${cln_vcfstats_folder}/"
echo ""

# Completion message to log
echo "Completed calculating vcf stats: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# --- Copy results to NAS --- #

# Progress report
echo "Started copying results to NAS"

# Remove temporary data
rm -fr "${tmp_folder}"

# --- Copy files to NAS --- #

# Suppress stopping at errors
set +e

rsync -thrqe "ssh -x" "${filtered_vcf_folder}" "${data_server}:${project_location}/${project}/" 
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

# Stop at errors
set -e

# ------------------------ #

# Progress report to log on nas
log_on_nas="${project_location}/${project}/${dataset_name}_${filter_name}_vcf/logs/${dataset_name}_${filter_name}.log"
timestamp="$(date +%d%b%Y_%H:%M:%S)"
ssh -x "${data_server}" "echo \"Completed copying results to NAS: ${timestamp}\" >> ${log_on_nas}"
ssh -x "${data_server}" "echo \"\" >> ${log_on_nas}"

# Remove results from cluster
rm -f "${out_vcf}"
rm -f "${out_vcf}.idx"
rm -f "${out_vcf_md5}"

rm -f "${cln_vcf}"
rm -f "${cln_vcf}.idx"
rm -f "${cln_vcf_md5}"

#rm -fr "${logs_folder}"
#rm -fr "${histograms_folder}"
#rm -fr "${vcfstats_folder}"

echo $(ssh -x "${data_server}" "echo \"Removed vcfs from cluster\" >> ${log_on_nas}")
ssh -x "${data_server}" "echo \"\" >> ${log_on_nas}"

# Return to the initial folder
cd "${init_dir}"
