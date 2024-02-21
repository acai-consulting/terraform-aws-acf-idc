output "identity_store_id" {
  description = "Identity Store ID associated with the Single Sign-On Instance."
  value       = local.identity_store_id
}

output "identity_store_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance."
  value       = local.identity_store_arn
}

output "sso_permission_sets" {
  description = "Map of permission sets configured to be used with Single Sign-On."
  value = {
    for m in module.sso_permission_sets : m.permission_set.name => m.permission_set
  }
}

output "sso_user_assignments" {
  description = "Map of user assignments with Single Sign-On."
  value = {
    for m in module.sso_account_assignments : m.account_id => m.user_assignments
  }
}

output "sso_group_assignments" {
  description = "Map of group assignments with Single Sign-On."
  value = {
    for m in module.sso_account_assignments : m.account_id => m.group_assignments
  }
}