#!/usr/bin/env bash

source ./config.sh

# transfer data to S3 
aws s3 sync ../data/noaa-gsod-pds/${current_year}/ s3://${S3_BUCKET}/noaa-gsod-pds/${current_year}/

# update S3 bucket in extreme_weather.py
python ./update_py.py $S3_BUCKET

aws s3 cp extreme_weather.py s3://${S3_BUCKET}/code/pyspark/

# create and start an Application on EMR Serverless
create_app=$(aws emr-serverless create-application \
  --type SPARK \
  --name $JOB_NAME \
  --release-label "emr-6.6.0" \
    --initial-capacity '{
        "DRIVER": {
            "workerCount": 2,
            "workerConfiguration": {
                "cpu": "2vCPU",
                "memory": "4GB"
            }
        },
        "EXECUTOR": {
            "workerCount": 10,
            "workerConfiguration": {
                "cpu": "4vCPU",
                "memory": "8GB"
            }
        }
    }' \
    --maximum-capacity '{
        "cpu": "200vCPU",
        "memory": "200GB",
        "disk": "1000GB"
    }')

APPLICATION_ID=$(echo $create_app | /usr/bin/jq --raw-output '.applicationId')

echo "My application's ID: $APPLICATION_ID"

until [ "$app_state" = "CREATED" ];
do
  # get state of application
    get_state=$(aws emr-serverless get-application \
            --application-id $APPLICATION_ID)
    app_state=$(echo $get_state | /usr/bin/jq --raw-output '.application.state')
    echo $app_state
done

# once application is in created state, start it
aws emr-serverless start-application \
    --application-id $APPLICATION_ID

echo "Job Started"

# run the job
run_job=$(aws emr-serverless start-job-run \
    --application-id $APPLICATION_ID \
    --execution-role-arn $JOB_ROLE_ARN \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "s3://'${S3_BUCKET}'/code/pyspark/extreme_weather.py",
            "sparkSubmitParameters": "--conf spark.driver.cores=1 --conf spark.driver.memory=3g --conf spark.executor.cores=4 --conf spark.executor.memory=3g --conf spark.executor.instances=10"
        }
    }' \
    --configuration-overrides '{
        "monitoringConfiguration": {
            "s3MonitoringConfiguration": {
                "logUri": "s3://'${S3_BUCKET}'/logs/"
            }
        }
    }')

JOB_RUN_ID=$(echo $run_job | /usr/bin/jq --raw-output '.jobRunId')

until [ "$job_state" = "SUCCESS" ] || [ "$job_state" = "FAILED" ];
do
    sleep 10
    # monitor job progress
    get_job_state=$(aws emr-serverless get-job-run \
        --application-id $APPLICATION_ID \
        --job-run-id $JOB_RUN_ID)
    job_state=$(echo $get_job_state | /usr/bin/jq --raw-output '.jobRun.state')
    echo $job_state
done

echo "Job complete"

# get output 
aws s3 cp s3://${S3_BUCKET}/logs/applications/$APPLICATION_ID/jobs/$JOB_RUN_ID/SPARK_DRIVER/stdout.gz ../results/
gunzip ../results/stdout.gz 
mv ../results/stdout ../results/extreme_weather_report.txt

# clean up: stop and delete application 
aws emr-serverless stop-application \
    --application-id $APPLICATION_ID
sleep 10
aws emr-serverless delete-application \
    --application-id $APPLICATION_ID

echo "Application $APPLICATION_ID deleted"

# delete intermediate files from S3
aws s3 rm s3://${S3_BUCKET}/noaa-gsod-pds/${current_year} --recursive