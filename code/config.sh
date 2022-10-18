#!/usr/bin/env bash

# set some defaults
app_state=UNSTARTED
job_state=UNSTARTED

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Possible args: s3 bucket name, job role ARN, name of spark job"
fi

if [ -z $1 ]; then
S3_BUCKET=research-emr-tutorial
else
S3_BUCKET=$1
fi

if [ -z $2 ]; then
JOB_ROLE_ARN=arn:aws:iam::147080935342:role/EMRServerlessS3RuntimeRole
else
JOB_ROLE_ARN=$2
fi

if [ -z $3 ]; then
JOB_NAME=My-Spark-Job
else
JOB_NAME$3
fi


