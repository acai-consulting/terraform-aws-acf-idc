import os
import boto3
from botocore.config import Config as boto3_config
import globals

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

def assume_remote_role(custom_logger, remote_role_arn, sts_region_name = None, customer_session = None):
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

        custom_logger.debug(f"Assuming role {remote_role_arn}")
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
        custom_logger.debug(f"Assumed role {remote_role_arn}")
        return session

    except Exception as e:
        custom_logger.exception(f"Was not able to assume role {remote_role_arn}")
        return None

def save_to_s3(object_name, content):
    if REPORT_BUCKET_NAME != "":
        # Add a file to your Object Store
        s3_client = boto3.client('s3')
        response = s3_client.put_object(
            Bucket=REPORT_BUCKET_NAME,
            Key=f"{REPORT_BUCKET_FOLDER_NAME}/{object_name}",
            Body=content
        )
        return response
    
