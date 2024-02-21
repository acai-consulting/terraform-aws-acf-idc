variable "permission_sets" {
  description = "A list of permission sets."
  type = list(object({
    name               = string
    description        = string
    session_duration   = number
    inline_policy_json = string
    managed_policies = list(object({
      managed_by  = string
      policy_name = string
      policy_path = string
    }))
    boundary_policy = map(object({
      managed_by  = string
      policy_name = string
      policy_path = string
    }))
  }))
  default = []

  validation {
    condition     = length(var.permission_sets) == length(distinct([for p in var.permission_sets : p.name]))
    error_message = "\"name\" must be unique in list of \"permission_sets\"."
  }
}

variable "account_assignments" {
  description = "A list of account assignments."
  type = list(object({
    account_id = string,
    permissions = list(object({
      permission_set_name = string
      users               = list(string)
      groups              = list(string)
    }))
  }))
  default = []

  validation {
    condition     = length(var.account_assignments) == length(distinct([for a in var.account_assignments : a.account_id]))
    error_message = "\"account_id\" must be unique in list of \"account_assignments\"."
  }
}