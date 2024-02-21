# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.47"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ssoadmin_instances" "sso" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  identity_store_id  = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
  identity_store_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SSO PERMISSION SETS
# ---------------------------------------------------------------------------------------------------------------------
module "sso_permission_sets" {
  source = "./modules/permission-set"

  for_each = { for p in var.permission_sets : p.name => p }

  identity_store_arn = local.identity_store_arn
  name               = each.value.name
  description        = each.value.description
  session_duration   = each.value.session_duration
  inline_policy_json = each.value.inline_policy_json
  managed_policies   = each.value.managed_policies
  boundary_policy    = each.value.boundary_policy
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SSO ACCOUNT ASSIGNMENTS
# ---------------------------------------------------------------------------------------------------------------------
module "sso_account_assignments" {
  source = "./modules/account-assignment"

  for_each = { for a in var.account_assignments : a.account_id => a }

  identity_store_id  = local.identity_store_id
  identity_store_arn = local.identity_store_arn
  account_id         = each.value.account_id
  permissions        = each.value.permissions

  depends_on = [
    module.sso_permission_sets
  ]
}
