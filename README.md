This pipeline was used for multiple WES progects in 2015-2017.  
The pipeline was deployed on the Cambridge university cluster.  
It processes WES data from fastq to annotated vcf. 

This repository is intended for the author's pesonal use. 
Version 08.16

The main steps of the pipeline include:
- Source FASTQ import, trimming withCutadapt and assessing with FastQC, 
- Alignment against b37 using BWA MEM or backtrack,
- BAM files cleaning, merging, deduplication, preprocessing and QC (samtools, picard, GATK, Qualimap etc)
- Variants calling by GATK HC - GVCF 
- Variants assessment (custom R scripts and samtools vcfstats) 
- Variants filtering by VQSR and a custom hard filters (DP and QUAL) 
- Variants annotation using kgen ,exac and VEP
- Export of annotated variants to plain text files for downstream analysis in R.

Code is split into modules (steps), located in folders with self-explanatory names.  
After each step the user assess the results (metrics produced by fastQC, picard, qualimap, 
vqsr, vcfstats, vep etc) before taking analysis to the next step.   
The steps are started by the launcher script with a job description file (located in 
folder with the job description templates).  

Updates in version of 08.16

1) Removed option for importing CRUK data
2) Updated what results are kept on on HPC (logs etc)
3) Make adaptors trimming optional (cutadapt)
4) Base quality fastq trimming from both ends (cutadapt)  
5) Allow for PE and SE data
6) Allow for BWA-MEM and BWA-Backtrack
7) Additional bams checks and cleaning after BWA 
8) Updated variables names for target folders / intervals
9) Removed resource monitoring
10) Use padding 10 in all GATK steps
11) Split and process multi-allelic variants
12) Added exac annotations
13) Added kgen AFs instead of masks (removed the tables with masks)
14) Removed PDF reports (keep HTML only)
15) Removed TXT outputs and some fields in VEP
16) Removed "clean" and "full" outputs at some steps (keep only one output)
17) Added some cleaning to exported VV table
18) Switched to last version of GATK in most steps
