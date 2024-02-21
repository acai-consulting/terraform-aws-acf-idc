variable "account_id" {
  description = "AWS account ID to which permissions should be assigned."
  type        = string
}

variable "identity_store_id" {
  description = "The Identity Store ID associated with the Single Sign-On Instance. If omitted the value will be requested by data source."
  type        = string
  default     = ""
}

variable "identity_store_arn" {
  description = "The Identity Store ARN associated with the Single Sign-On Instance. If omitted the value will be requested by data source."
  type        = string
  default     = ""
}

variable "permissions" {
  description = "List of Single Sign-On permissions for users and groups."
  type = list(object({
    permission_set_name = string
    users               = list(string)
    groups              = list(string)
  }))
  default = []
}