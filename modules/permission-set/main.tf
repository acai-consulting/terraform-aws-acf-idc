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
data "aws_ssoadmin_instances" "sso" {
  count = var.identity_store_arn == "" ? 1 : 0
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  identity_store_arn               = var.identity_store_arn == "" ? tolist(data.aws_ssoadmin_instances.sso[0].arns)[0] : var.identity_store_arn
  permissions_boundary_managed_by  = lower(try(var.boundary_policy.managed_by, ""))
  permissions_boundary_exists      = length(local.permissions_boundary_managed_by) > 0
  permissions_boundary_policy_name = try(var.boundary_policy.policy_name, "none")
  permissions_boundary_policy_path = try(var.boundary_policy.policy_path, "/")
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SSO PERMISSION SETS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "sso" {
  name             = var.name
  description      = var.description
  instance_arn     = local.identity_store_arn
  session_duration = "PT${var.session_duration}H"
}

resource "aws_ssoadmin_managed_policy_attachment" "aws_managed" {
  for_each = {
    for policy in var.managed_policies : policy.policy_name => policy.policy_path
    if lower(policy.managed_by) == "aws"
  }

  instance_arn = local.identity_store_arn
  managed_policy_arn = format(
    "arn:aws:iam::aws:policy%s%s",
    each.value,
    each.key
  )
  permission_set_arn = aws_ssoadmin_permission_set.sso.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "customer_managed" {
  for_each = {
    for policy in var.managed_policies : policy.policy_name => policy.policy_path
    if lower(policy.managed_by) == "customer"
  }

  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.sso.arn
  customer_managed_policy_reference {
    name = each.key
    path = each.value
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "inline" {
  count = length(var.inline_policy_json) > 0 ? 1 : 0

  inline_policy      = var.inline_policy_json
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.sso.arn
}

resource "aws_ssoadmin_permissions_boundary_attachment" "boundary_aws_managed" {
  count = local.permissions_boundary_exists && local.permissions_boundary_managed_by == "aws" ? 1 : 0

  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.sso.arn
  permissions_boundary {
    managed_policy_arn = format(
      "arn:aws:iam::aws:policy%s%s",
      local.permissions_boundary_policy_name,
      local.permissions_boundary_policy_path
    )
  }
}

resource "aws_ssoadmin_permissions_boundary_attachment" "boundary_customer_managed" {
  count = local.permissions_boundary_exists && local.permissions_boundary_managed_by == "customer" ? 1 : 0

  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.sso.arn
  permissions_boundary {
    customer_managed_policy_reference {
      name = local.permissions_boundary_policy_name
      path = local.permissions_boundary_policy_path
    }
  }
}