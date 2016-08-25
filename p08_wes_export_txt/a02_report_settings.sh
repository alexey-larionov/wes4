#!/bin/bash

# a02_report_config.sh
# Reporting settings for data export
# Alexey Larionov, 25Aug2016

pipeline_info=$(grep "^#" "${job_file}")
pipeline_info=${pipeline_info//"#"/}

echo "------------------- Pipeline summary -----------------"
echo ""
echo "${pipeline_info}"
echo ""
echo "--------- Data location and analysis settings --------"
echo ""
echo "data_server: ${data_server}"
echo "project_location: ${project_location}"
echo ""
echo "project: ${project}"
echo "dataset: ${dataset}"
echo ""
echo "------------------- HPC settings ---------------------"
echo ""
echo "working_folder: ${working_folder}"
echo ""
echo "account_to_use: ${account_to_use}"
echo "time_to_request: ${time_to_request}"
echo ""
echo "----------------- Standard settings ------------------"
echo ""
echo "scripts_folder: ${scripts_folder}"
echo ""
echo "Tools"
echo "-----"
echo ""
echo "tools_folder: ${tools_folder}"
echo ""
echo "java7: ${java7}"
echo "gatk: ${gatk}"
echo ""
echo "r_bin_folder: ${r_bin_folder}"
echo "r_lib_folder: ${r_lib_folder}"
echo "" 
echo "Resources" 
echo "---------"
echo ""
echo "resources_folder: ${resources_folder}"
echo ""
echo "decompressed_bundle_folder: ${decompressed_bundle_folder}"
echo "ref_genome: ${ref_genome}"
echo ""
echo "targets_folder: ${targets_folder}"
echo "targets_intervals: ${targets_intervals}"
echo ""
echo "Working sub-folders on HPC"
echo "--------------------------"
echo ""
echo "project_folder: ${project_folder}"
echo "export_folder: ${export_folder}"
echo "biallelic_folder: ${biallelic_folder}"
echo "multiallelic_folder: ${multiallelic_folder}"
echo "logs_folder: ${logs_folder}"
echo "tmp_folder: ${tmp_folder}"
echo "" 
echo "Additional settings"
echo "--------------------------"
echo ""
echo "vep_fields: ${vep_fields}"
echo ""