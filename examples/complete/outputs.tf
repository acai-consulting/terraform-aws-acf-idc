output "account_id" {
  description = "AWS Account ID number of the account that owns or contains the calling entity."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_identity_center" {
  value = module.aws_identity_center
}


output "test_success_1" {
  value = module.aws_identity_center.permission_sets.Platform_ViewOnly.arn == module.aws_identity_center.user_assignments["590183833356"][0].permission_set_arn
}

output "test_success_2" {
  value = module.aws_identity_center.permission_sets.Platform_AdminAccess.arn == module.aws_identity_center.user_assignments["992382728088"][0].permission_set_arn
}
