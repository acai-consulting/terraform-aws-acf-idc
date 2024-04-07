
output "core_configuration_to_write" {
  description = "This must be in sync with the Account Baselining"
  # https://dev.azure.com/ipmsecurity/AWS-MA-Core-Security/_git/terraform-aws-account-baseline-stacksets?path=/stacksets_security.tf&version=GBmain&_a=contents
  value = {
    security = {
      reporting = {
        identity_center = {
          crawler = {
            iam_role_arn = module.lambda.lambda_execution_role_arn
          }
        }
      }
    }
  }
}
