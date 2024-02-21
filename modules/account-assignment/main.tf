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
  count = var.identity_store_arn == "" || var.identity_store_id == "" ? 1 : 0
}

data "aws_identitystore_user" "sso" {
  for_each = { for user in local.users_nested : user.index => user.user_name }

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path = "UserName"
      # workaround in case UserName is cut off by scim sync
      attribute_value = substr(each.value, 0, 54)
    }
  }
}

data "aws_identitystore_group" "sso" {
  for_each = { for group in local.groups_nested : group.index => group.group_name }

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}

data "aws_ssoadmin_permission_set" "sso" {
  for_each     = { for p in var.permissions : p.permission_set_name => p }
  instance_arn = local.identity_store_arn
  name         = each.key
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  identity_store_id  = var.identity_store_id == "" ? tolist(data.aws_ssoadmin_instances.sso[0].identity_store_ids)[0] : var.identity_store_id
  identity_store_arn = var.identity_store_arn == "" ? tolist(data.aws_ssoadmin_instances.sso[0].arns)[0] : var.identity_store_arn

  users_nested = distinct(flatten([
    for p in var.permissions : [
      for user in p.users : {
        index : "${p.permission_set_name}/${user}"
        permission_set : p.permission_set_name
        user_name : user
      }
    ]
  ]))

  groups_nested = distinct(flatten([
    for p in var.permissions : [
      for group in p.groups : {
        index : "${p.permission_set_name}/${group}"
        permission_set : p.permission_set_name
        group_name : group
      }
    ]
  ]))
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SSO USERS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_account_assignment" "users" {
  for_each = {
    for user in local.users_nested : user.index => user.permission_set
    if contains(keys(data.aws_identitystore_user.sso), user.index)
  }

  instance_arn       = local.identity_store_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.sso[each.value].arn

  principal_id   = data.aws_identitystore_user.sso[each.key].id
  principal_type = "USER"

  target_id   = var.account_id
  target_type = "AWS_ACCOUNT"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SSO GROUPS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_account_assignment" "groups" {
  for_each = {
    for group in local.groups_nested : group.index => group.permission_set
    if contains(keys(data.aws_identitystore_group.sso), group.index)
  }

  instance_arn       = local.identity_store_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.sso[each.value].arn

  principal_id   = data.aws_identitystore_group.sso[each.key].id
  principal_type = "GROUP"

  target_id   = var.account_id
  target_type = "AWS_ACCOUNT"
}
