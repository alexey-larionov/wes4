#!/bin/bash

# a02_report_setings.sh
# Report settings for wes library preprocess and gvcf pipeline
# Alexey Larionov, 23Aug2016

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
echo "library: ${library}"
echo ""
echo "------------------- HPC settings ---------------------"
echo ""
echo "working_folder: ${working_folder}"
echo ""
echo "account_copy_in: ${account_copy_in}"
echo "time_copy_in: ${time_copy_in}"
echo ""
echo "account_process_gvcf: ${account_process_gvcf}"
echo "time_process_gvcf: ${time_process_gvcf}"
echo ""
echo "account_move_out: ${account_move_out}"
echo "time_move_out: ${time_move_out}"
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
echo "java6: ${java6}"
echo "java7: ${java7}"
echo ""
echo "picard: ${picard}"
echo "gatk: ${gatk}"
echo ""
echo "r_folder: ${r_folder}"
echo ""
echo "Resources" 
echo "---------"
echo ""
echo "resources_folder: ${resources_folder}"
echo ""
echo "decompressed_bundle_folder: ${decompressed_bundle_folder}"
echo "ref_genome: ${ref_genome}"
echo "dbsnp: ${dbsnp}"
echo "dbsnp129: ${dbsnp129}"
echo "hapmap: ${hapmap}"
echo "omni: ${omni}"
echo "phase1_1k_hc: ${phase1_1k_hc}"
echo "indels_1k: ${indels_1k}"
echo "indels_mills: ${indels_mills}"
echo ""
echo "targets_folder: ${targets_folder}"
echo "targets_intervals: ${targets_intervals}"
echo ""
echo "Working sub-folders on HPC"
echo "--------------------------"
echo ""
echo "project_folder: ${project_folder}"
echo "library_folder: ${library_folder}"
echo ""
echo "merged_folder: ${merged_folder}"
echo "dedup_bam_folder: ${dedup_bam_folder}"
echo ""
echo "processed_folder: ${processed_folder}"
echo "logs_folder: ${logs_folder}"
echo "proc_bam_folder: ${proc_bam_folder}"
echo "idr_folder: ${idr_folder}"
echo "bqr_folder: ${bqr_folder}"
echo ""
echo "gvcf_folder: ${gvcf_folder}"
echo "" 
