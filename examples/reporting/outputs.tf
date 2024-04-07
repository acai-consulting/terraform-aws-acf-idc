output "aws_identity_center" {
  value =  jsondecode(aws_lambda_invocation.idc_report.result)
}
