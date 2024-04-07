
output "core_configuration_to_write" {
  description = "This must be in sync with the Account Baselining"
  # https://dev.azure.com/ipmsecurity/AWS-MA-Core-Security/_git/terraform-aws-account-baseline-stacksets?path=/stacksets_security.tf&version=GBmain&_a=contents
  value = {
    security = {
      reporting = {
        identity_center = {
          crawled_account = {
            iam_role_arn = aws_iam_role.idc_crawler_role.arn
          }
        }
      }
    }
  }
}
