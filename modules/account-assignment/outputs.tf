output "identity_store_id" {
  description = "Identity Store ID associated with the Single Sign-On Instance."
  value       = local.identity_store_id
}

output "identity_store_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance."
  value       = local.identity_store_arn
}

output "account_id" {
  description = "AWS account ID to which permissions should be assigned."
  value       = var.account_id
}

output "user_assignments" {
  description = "User assignments in AWS SSO."
  value       = try(aws_ssoadmin_account_assignment.users, {})
}

output "group_assignments" {
  description = "Group assignments in AWS SSO."
  value       = try(aws_ssoadmin_account_assignment.groups, {})
}