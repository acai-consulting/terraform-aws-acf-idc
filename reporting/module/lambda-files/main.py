import json
import os
import botocore
import boto3
from botocore.exceptions import ClientError
import os
from typing import List, Dict, Optional
import globals
from pull_data.ssoadmin_wrapper import SsoAdminWrapper
from pull_data.identitystore_wrapper import IdentitystoreWrapper
from transformer import Transformer
from rendering.csv import CSV

import logging
LOGLEVEL = os.environ.get('LOG_LEVEL', 'INFO').upper()
logging.getLogger().setLevel(LOGLEVEL)
for noisy_log_source in ['boto', 'boto3', 'botocore', 'urllib3']:
    logging.getLogger(noisy_log_source).setLevel(logging.WARN)
LOGGER = logging.getLogger()

REGION = os.environ['AWS_REGION']
CRAWLER_ARN = os.environ['CRAWLER_ARN']


def lambda_handler(event, context):
    try:
        context_logger = LOGGER
        context_logger.debug(f"botocore={botocore.__version__}  boto3={boto3.__version__}")
        context_logger.debug(json.dumps(event))

        crawler_session = globals.assume_remote_role(
            custom_logger = context_logger,
            remote_role_arn = CRAWLER_ARN, 
            sts_region_name = REGION
        )

        ssoadmin_wrapper = SsoAdminWrapper(crawler_session)
        assignments= ssoadmin_wrapper.get_assignments()        

            
        identitystore_wrapper = IdentitystoreWrapper(
                crawler_session,
                ssoadmin_wrapper.identitystore_id
            )
        identitystore_wrapper.fill_cache()
        
        LOGGER.info(json.dumps(identitystore_wrapper.cache))

        transformer = Transformer(assignments, identitystore_wrapper)
        transformed = transformer.transform_assignments()

        csv = CSV(transformed)
        csv.render()
        
        return {
            'statusCode': 200,
            'body': "Success"
        }

    except ClientError as e:
        LOGGER.exception(f"Unexpected error")
        raise e
    except Exception as e:
        LOGGER.exception(f"Unexpected error")
        raise e
