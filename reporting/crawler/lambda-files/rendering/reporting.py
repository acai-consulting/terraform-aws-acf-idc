from datetime import datetime
import os
import boto3
import xlsxwriter
import globals
from io import StringIO
from pull_data.ssoadmin_wrapper import SsoAdminWrapper
from pull_data.identitystore_wrapper import IdentitystoreWrapper

class ExcelReport:
    def __init__(self, transformed):
        self.transformed = transformed

    def create_excel(self):
        # Generate the timestamp for file naming
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_name = f"{timestamp}_assignments.xlsx"
        local_file_path = f"/tmp/{file_name}"
        
        # Create the Excel workbook and worksheet
        workbook = xlsxwriter.Workbook(local_file_path)
        worksheet = workbook.add_worksheet("Assignments")

        # Define the header format and write the headers
        header_format = workbook.add_format({'bold': True, 'align': 'center', 'valign': 'vcenter', 'bg_color': '#D3D3D3'})
        headers = ['Account-ID', 'Account-Name', 'PermSet-Name', 'Group-Name', 'User-Name', 'Group-ID', 'User-ID']
        for col_num, header in enumerate(headers):
            worksheet.write(0, col_num, header, header_format)

        # Set column widths for better readability
        worksheet.set_column('A:A', 20)  # Account-ID
        worksheet.set_column('B:B', 30)  # Account-Name
        worksheet.set_column('C:C', 30)  # PermSet-Name
        worksheet.set_column('D:D', 30)  # Group-Name
        worksheet.set_column('E:E', 30)  # User-Name
        worksheet.set_column('F:F', 50)  # Group-ID
        worksheet.set_column('G:G', 50)  # User-ID

        # Freeze the header row
        worksheet.freeze_panes(1, 0)
        
        # Apply the auto-filter to the first row (header row)
        worksheet.autofilter(0, 0, 0, len(headers) - 1)  # Apply filter to the entire header row

        # Write the transformed data into the Excel worksheet
        row_num = 1  # Start after the header row
        for account_id, account_info in self.transformed['accounts'].items():
            for permission_set_name, permission_set_info in account_info['permission_sets'].items():
                # Case for group-based assignment
                for group_id in permission_set_info['groups']:
                    group_details = self.transformed['principals']['groups'].get(group_id, {})
                    group_name = group_details.get('display_name', f'Group-{group_id}')
                    
                    # Write each user within the group
                    for user_id in group_details.get('assigned_users', []):
                        user_details = self.transformed['principals']['users'].get(user_id, {})
                        user_name = user_details.get('user_name', f'User-{user_id}')
                        worksheet.write_row(row_num, 0, [account_id, account_info['account_name'], permission_set_name, group_name, user_name, group_id, user_id])
                        row_num += 1

                # Case for direct user assignments (without a group)
                for user_id in permission_set_info.get('users', []):  
                    user_details = self.transformed['principals']['users'].get(user_id, {})
                    user_name = user_details.get('user_name', f'User-{user_id}')
                    worksheet.write_row(row_num, 0, [account_id, account_info['account_name'], permission_set_name, '', user_name, '', user_id])
                    row_num += 1

        # Close the workbook after writing all data
        workbook.close()

        # Log and upload the file to S3
        file_size = os.path.getsize(local_file_path)
        globals.LOGGER.info(f'Local Excel created. File size: {file_size / (1024 * 1024):.2f} MB')
        globals.upload_file_to_s3(local_file_path, file_name)
