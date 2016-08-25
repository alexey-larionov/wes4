This is a pipeline to process whole exome sequencing data from fastq to annotated vcf. 
The pipeline is deployed on a local university cluster.  
This repository is intended for the author's pesonal use. 
Version 08.16 - updates in progress

The main steps include:
- Source FASTQ import, trimming withCutadapt and assessing with FastQC, 
- Alignment against b37 using BWA MEM or backtrack,
- BAM files cleaning, merging, deduplication, preprocessing and QC (samtools, picard, GATK, Qualimap etc)
- Variants calling by GATK HC - GVCF 
- Variants assessment (custom R scripts and samtools vcfstats) 
- Variants filtering by VQSR and a set of custom hard filters 
- Variants annotation by VEP and GATK
- Export of annotated variants to plain text fils for downstream analysis in R.

Code is split into modules (steps), located in folders with self-explanatory names.  
After each step the user assess the results (metrics produced by fastQC, picard, qualimap, 
vqsr, vcfstats, vep etc) before taking analysis to the next step.   
The steps are started by the launcher script with a job description file (located in 
folder with the job description templates).  

Updates in version of 08.16

1) Removed option for importing CRUK data (step 1)
2) Updated what results are kept on on HPC (keep logs etc, all steps)
3) Make adaptors trimming optional (cutadapt, step 1)
4) Base quality fastq trimming from both ends (cutadapt, step 1)  
5) Allow for PE and SE data (steps 1 and 2)
6) Allow for BWA-MEM and BWA-Backtrack (step 1)
7) Updated bams checks and cleaning after BWA (step 1) 
8) Updated names for target intervals in s01 (all steps)
9) Removed resource monitoring in s01 (all steps)
10) Updated names for target folders / intevals (all steps)
11) Use padding 10 in all GATK steps
12) Split multi-allelic variants (p05)
13) Added various exac annotations (p05)
14) Added 1k AFs instead of masks, removed the tables with masks etc (p05)
15) Removed PDF reports, keeping HTML only (p05 etc)
16) Removed TXT outputs in VEP (p07)
17) Removed 1k and MAFs in VEP (p07)
18) Added separated tables with 1k and Exac (p08)
19) Removed separate export of multi- and bi- allelic tables
