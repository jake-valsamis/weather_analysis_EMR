**This capsule runs a PySpark job on EMR Serverless that analyzes data from the NOAA Global Surface Summary of Day dataset from the Registry of Open Data on AWS.**

extreme_weather.py analyzes data from a given year and finds the weather location with the most extreme rain, wind, snow, and temperature.

There are several AWS requirements:
1) An AWS user with credentials attached to this capsule as user secrets. This user must have full EMR access (at least access to EMR Serverless)
2) An S3 bucket with read and write permissions for this user 
3) A runtime role for the EMR job. The job role ARN is needed to run the job. 

The S3 bucket name and job role ARN can be specified in the App Panel or hardcoded as default parameters in config.sh 

Before running the capsule, the data in s3://noaa-gsod-pds/2022/ must be put on your own S3 bucket. Change line 23 in extreme_weather.py to be the name of your S3 bucket and if you put the data anywhere besides s3://${YOUR_S3_BUCKET}/noaa-gsod-pds/2022/ you'll need to change the path on line 55 of extreme_weather.py. 

Additionally, extreme_weather.py must be copied to your own S3 bucket using line 5 in run_on_cluster.sh

This capsule was built off the example provided here: 
https://github.com/aws-samples/emr-serverless-samples/tree/main/examples/pyspark