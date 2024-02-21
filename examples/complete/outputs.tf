output "region" {
  description = "The name of the selected region."
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "AWS Account ID number of the account that owns or contains the calling entity."
  value       = data.aws_caller_identity.current.account_id
}