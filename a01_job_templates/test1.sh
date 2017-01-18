#!/bin/bash

# start_job.sh
# Start job described in the job file
# Alexey Larionov, 18Jan2017
# Version 12

# Use: 
# start_job.sh job_file
# start_job.sh job_file repeat sample

# Get job file
job_description="${1}"
job_type="${2}"
sample="${3}"
run_time="${4}"
etc="${5}"

echo ""
echo "${job_description}"
echo "${job_type}"
echo "${sample}"
echo ""

# Check incorrect input
if [ ! -z "${job_type}" ] & [ "${job_type}" != "repeat" ]
then
  echo "Unexpected job type: ${job_type}"
  echo ""
  echo "Standard use:"
  echo "start_job.sh job_file"
  echo ""
  echo "Use in repeat mode:"
  echo "start_job.sh job_file repeat sample time"
  echo ""
  echo "Script terminated"
  exit 1
fi

if [ -z "${sample}" ]
  then
  echo "No sample is given to repeat"
  echo ""
  echo "Standard use:"
  echo "start_job.sh job_file"
  echo ""
  echo "Use in repeat mode:"
  echo "start_job.sh job_file repeat sample time"
  echo ""
  echo "Script terminated"
  exit 1
fi

if [ -z "${run_time}" ]
  then
  echo "No time is given to repeat run"
  echo ""
  echo "Standard use:"
  echo "start_job.sh job_file"
  echo ""
  echo "Use in repeat mode:"
  echo "start_job.sh job_file repeat sample time"
  echo ""
  echo "Script terminated"
  exit 1
fi

if [ ! -z "${etc}" ]
  then
  echo "Unexpected parameter(s) in the command line"
  echo ""
  echo "Standard use:"
  echo "start_job.sh job_file"
  echo ""
  echo "Use in repeat mode:"
  echo "start_job.sh job_file repeat sample time"
  echo ""
  echo "Script terminated"
  exit 1
fi
