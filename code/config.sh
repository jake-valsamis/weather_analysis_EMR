#!/usr/bin/env bash

# set some defaults
app_state=UNSTARTED
job_state=UNSTARTED

JOB_ROLE_ARN=$CUSTOM_KEY

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Possible args: S3 bucket name, name of spark job"
fi

if [ -z $1 ]; then
S3_BUCKET=research-emr-tutorial
else
S3_BUCKET=$1
fi

if [ -z $2 ]; then
JOB_NAME=My-Spark-Job
else
JOB_NAME=$2
fi

current_year=$(date +'%Y')