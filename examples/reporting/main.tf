# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  alias  = "org_mgmt"
  # please use the target role you need.
  # create additional providers in case your module provisions to multiple core accounts.
  assume_role {
    role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Org-Mgmt Account
    #role_arn = "arn:aws:iam::590183833356:role/OrganizationAccountAccessRole"  # ACAI AWS Testbed Core Logging Account
    #role_arn = "arn:aws:iam::992382728088:role/OrganizationAccountAccessRole"  # ACAI AWS Testbed Core Security Account
    #role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole"  # ACAI AWS Testbed Workload Account
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "core_logging"
  # please use the target role you need.
  # create additional providers in case your module provisions to multiple core accounts.
  assume_role {
    #role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Org-Mgmt Account
    role_arn = "arn:aws:iam::590183833356:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Core Logging Account
    #role_arn = "arn:aws:iam::992382728088:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Core Security Account
    #role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Workload Account
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  alias  = "core_security"
  # please use the target role you need.
  # create additional providers in case your module provisions to multiple core accounts.
  assume_role {
    #role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Org-Mgmt Account
    #role_arn = "arn:aws:iam::590183833356:role/OrganizationAccountAccessRole"  # ACAI AWS Testbed Core Logging Account
    role_arn = "arn:aws:iam::992382728088:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Core Security Account
    #role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole"  # ACAI AWS Testbed Workload Account
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ BACKEND
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "remote" {
    organization = "acai"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-testbed"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ AWS IAM IDENTITY CENTER REPORTING
# ---------------------------------------------------------------------------------------------------------------------
module "idc_crawler_role" {
  source = "../../reporting/principal"

  settings = {
    security = {
      reporting = {
        identity_center = {
          crawled_account = {
            iam_role_name     = "reporting-idc-crawler-role"
            iam_role_trustees = ["992382728088"] # Core Security Account ID
          }
        }
      }
    }
  }
  providers = {
    aws = aws.org_mgmt
  }
}

module "idc_report" {
  source = "../../reporting/crawler"

  settings = {
    security = {
      reporting = {
        identity_center = {
          crawler = {
            lambda_name             = "report--identity-center"
            lambda_description      = "report--identity-center"
            execution_iam_role_name = "report--identity-center--execution-role"
          }
          crawled_account = {
            iam_role_arn = module.idc_crawler_role.idc_crawler_role_arn
          }
        }
      }
    }
  }
  providers = {
    aws = aws.core_security
  }
}


resource "aws_lambda_invocation" "idc_report" {
  function_name = "report--identity-center"

  input = <<JSON
{
}
JSON
  depends_on = [
    module.idc_report
  ]
  provider = aws.core_security
}

