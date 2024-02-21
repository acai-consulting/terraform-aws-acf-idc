variable "identity_store_arn" {
  description = "The Identity Store ARN associated with the Single Sign-On Instance. If omitted the value will be requested by data source."
  type        = string
  default     = ""
}

variable "name" {
  description = "The name of the Permission Set."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z+=,.@_-]+$", var.name))
    error_message = "\"name\" must be alphanumeric, including the following common characters: \"+\", \"=\", \",\", \".\", \"@\", \"_\", \"-\"."
  }
}

variable "description" {
  description = "The description of the Permission Set."
  type        = string
  default     = ""
}

variable "session_duration" {
  description = "The length of time (hours) that the application user sessions are valid."
  type        = number
  default     = 1

  validation {
    condition     = var.session_duration > 0 && var.session_duration < 13
    error_message = "Invalid \"session_duration\". Value must be greater than 0 and less than 13."
  }
}

variable "inline_policy_json" {
  description = "IAM inline policy which will be attached to the Permission Set. Value must be a valid JSON."
  type        = string
  default     = ""

  validation {
    condition     = length(var.inline_policy_json) == 0 || can(jsondecode(var.inline_policy_json))
    error_message = "\"inline_policy_json\" must be valid JSON."
  }
}

variable "managed_policies" {
  description = "List of AWS or customer managed policies which will be attached to the Permission Set."
  type = list(object({
    managed_by  = string
    policy_name = string
    policy_path = string
  }))
  default = []

  validation {
    condition     = can(regex("^(?i:aws|customer)?$", try(var.managed_policies.managed_by, "")))
    error_message = "Invalid value for \"managed_by\". Valid options if set are \"aws\" or \"customer\"."
  }

  validation {
    condition = alltrue([
      for policy in var.managed_policies :
      can(regex("^\\/(.*\\/)?$", policy.policy_path))
    ])
    error_message = "Invalid \"policy_path\". Must be \"/\" or start and finish with \"/\" e.g. \"/my-custom-path/\"."
  }
}

variable "boundary_policy" {
  description = "Boundary policy which should be attached to the Permission Set. Can either be an AWS-managed IAM policy or a customer managed policy."
  type = map(object({
    managed_by  = string
    policy_name = string
    policy_path = string
  }))
  default = {}

  validation {
    condition     = can(regex("^(?i:aws|customer)?$", try(var.boundary_policy.managed_by, "")))
    error_message = "Invalid value for \"managed_by\". Valid options if set are \"aws\" or \"customer\"."
  }

  validation {
    condition     = can(regex("^\\/(.*\\/)?$", try(var.boundary_policy.policy_path, "/")))
    error_message = "Invalid \"policy_path\". Must be \"/\" or start and finish with \"/\" e.g. \"/my-custom-path/\"."
  }
}
