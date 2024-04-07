import logging
import boto3
from typing import List, Dict, Optional
import globals

class AccountWrapper:
    """
    A wrapper class for retrieving and managing AWS accounts via the AWS Organizations API.

    Attributes:
        _organizations_client (boto3.client): A Boto3 client configured for AWS Organizations.
        accounts (List[Dict]): A list of dictionaries, each representing an AWS account with details.

    Args:
        crawler_session (boto3.Session): The Boto3 session object used to create clients.
    """
    def __init__(self, crawler_session: boto3.Session):
        self._organizations_client = crawler_session.client('organizations', config=globals.BOTO3_CONFIG_SETTINGS)
        self.accounts: List[Dict] = []
        self._load_accounts()


    def _load_accounts(self):
        """
        Loads account information from AWS Organizations, populating the accounts list with account details.
        """
        logging.info('Loading all active accounts with organizations:ListAccounts API call.')

        paginator = self._organizations_client.get_paginator('list_accounts')
        for page in paginator.paginate():
            for account in page.get('Accounts', []):
                self._add_account(account)

    def _add_account(self, account_info: Dict):
        """
        Adds an account to the accounts list if it's not already present.

        Args:
            account_info (Dict): A dictionary containing account details from AWS Organizations.
        """
        account_entry = {
            'id': account_info["Id"],
            'arn': account_info["Arn"],
            'email': account_info["Email"],
            'name': account_info["Name"],
            'status': account_info["Status"],
            'joined_method': account_info["JoinedMethod"],
            'joined_timestamp': account_info["JoinedTimestamp"]
        }
        if account_entry not in self.accounts:
            self.accounts.append(account_entry)


    def get_account_entry_by_id(self, account_id: str) -> Optional[Dict]:
        """
        Retrieves an account's details by its ID.

        Args:
            account_id (str): The unique identifier for the account.

        Returns:
            Optional[Dict]: The account details if found, None otherwise.
        """
        return next((account for account in self.accounts if account['id'] == account_id), None)


    def get_account_name_by_id(self, account_id: str) -> Optional[str]:
        """
        Retrieves an account's name by its ID.

        Args:
            account_id (str): The unique identifier for the account.

        Returns:
            Optional[str]: The name of the account if found, None otherwise.
        """
        account_entry = self.get_account_entry_by_id(account_id)
        return account_entry['name'] if account_entry else None