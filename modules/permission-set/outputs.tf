output "identity_store_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance."
  value       = local.identity_store_arn
}

output "permission_set" {
  description = "Permission set configured to be used with AWS SSO."
  value       = aws_ssoadmin_permission_set.sso
}