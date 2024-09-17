import os
import boto3
from botocore.config import Config as boto3_config
import logging
LOGLEVEL = os.environ.get('LOG_LEVEL', 'INFO').upper()
logging.getLogger().setLevel(LOGLEVEL)
for noisy_log_source in ['boto', 'boto3', 'botocore', 'urllib3']:
    logging.getLogger(noisy_log_source).setLevel(logging.WARN)
LOGGER = logging.getLogger()

REGION = os.environ['AWS_REGION']
REPORT_BUCKET_NAME = os.environ['REPORT_BUCKET_NAME']
REPORT_BUCKET_FOLDER_NAME = 'idc-reports'

BOTO3_CONFIG_SETTINGS = boto3_config(
    region_name = REGION,
    retries = dict(
        max_attempts = 10,
        mode = 'adaptive'
    )
)

def assume_remote_role(remote_role_arn, sts_region_name = None, customer_session = None):
    try:
        """Assumes the provided role in the auditing member account and returns a session"""

        # Beginning the assume role process for account
        sts_client = None
        if sts_region_name is None:
            if customer_session is None:
                sts_client = boto3.client('sts')
            else:
                sts_client = customer_session.client('sts')
        else:
            if customer_session is None:
                sts_client = boto3.client('sts', region_name = sts_region_name)
            else:
                sts_client = customer_session.client('sts', region_name = sts_region_name)

        LOGGER.debug(f"Assuming role {remote_role_arn}")
        response = sts_client.assume_role(
            RoleArn=remote_role_arn,
            RoleSessionName='RemoteSession'
        )

        # Storing STS credentials
        session = boto3.Session(
            aws_access_key_id=response['Credentials']['AccessKeyId'],
            aws_secret_access_key=response['Credentials']['SecretAccessKey'],
            aws_session_token=response['Credentials']['SessionToken']
        )
        LOGGER.debug(f"Assumed role {remote_role_arn}")
        return session

    except Exception as e:
        LOGGER.exception(f"Was not able to assume role {remote_role_arn}")
        return None

def upload_file_to_s3( local_file_path, file_name):
    if REPORT_BUCKET_NAME != "":
        s3_client = boto3.client('s3')
        s3_bucket_name = REPORT_BUCKET_NAME
        s3_key = f"{REPORT_BUCKET_FOLDER_NAME}/{file_name}"
        s3_url = f"s3://{s3_bucket_name}/{s3_key}"
        
        LOGGER.info(f"Excel report will be uploaded to S3: {s3_url}")
        
        with open(local_file_path, 'rb') as content:
            s3_client.put_object(
                Bucket=s3_bucket_name, 
                Key=s3_key, 
                Body=content,
            )
        
        LOGGER.info(f"Excel report has been uploaded to S3: {s3_url}")
        return s3_url
    
    else:
        LOGGER.info(f"No output bucket provided.")
        