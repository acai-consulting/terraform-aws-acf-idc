# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ BACKEND
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "remote" {
    organization = "nuvibit"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-s-testing"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_reader" {
  statement {
    sid = "S3Reader"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  sso_permission_sets = [
    {
      name : "AdministratorAccess"
      description : "This permission set grants full admin access"
      session_duration : 2
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "aws"
          policy_name : "AdministratorAccess"
          policy_path : "/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "Billing+ViewOnlyAccess"
      description : "This permission set grants billing and read-only access"
      session_duration : 10
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "aws"
          policy_name : "Billing"
          policy_path : "/job-function/"
        },
        {
          managed_by : "aws"
          policy_name : "ViewOnlyAccess"
          policy_path : "/job-function/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "SupportUser"
      description : "This permission set grants access to support users"
      session_duration : 10
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "aws"
          policy_name : "SupportUser"
          policy_path : "/job-function/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "CustomerPolicy"
      description : "This permission set grants reader access to S3"
      session_duration : 10
      inline_policy_json : ""
      managed_policies : [
        {
          managed_by : "customer"
          policy_name : "CustomerPolicy"
          policy_path : "/customer-path/"
        }
      ]
      boundary_policy : {}
    },
    {
      name : "InlineS3Reader"
      description : "This permission set grants reader access to S3"
      session_duration : 10
      inline_policy_json : data.aws_iam_policy_document.s3_reader.json
      managed_policies : []
      boundary_policy : {}
    }
  ]

  sso_account_assignments = [
    {
      account_id = "151251261561"
      permissions = [
        {
          permission_set_name = "AdministratorAccess"
          users               = ["user@example.com"]
          groups              = ["group-aws-admins"]
        }
      ]
    },
    {
      account_id = "6136161326123"
      permissions = [
        {
          permission_set_name = "AdministratorAccess"
          users               = ["admin@example.com"]
          groups              = []
        },
        {
          permission_set_name = "Billing+ViewOnlyAccess"
          users               = []
          groups              = ["group-aws-billing"]
        },
        {
          permission_set_name = "SupportUser"
          users               = []
          groups              = ["group-aws-supporter"]
        },
        {
          permission_set_name = "CustomerPolicy"
          users               = ["customer@example.com"]
          groups              = []
        },
        {
          permission_set_name = "InlineS3Reader"
          users               = []
          groups              = ["group-aws-s3reader"]
        }
      ]
    }
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SSO - IAM IDENTITY CENTER
# ---------------------------------------------------------------------------------------------------------------------
module "sso_identity_center" {
  source = "../../"

  permission_sets     = local.sso_permission_sets
  account_assignments = local.sso_account_assignments
}
