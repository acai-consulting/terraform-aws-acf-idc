variable "settings" {
  description = "Settings for the IdC Crawler Principal"

  type = object({
    security = object({
      reporting = object({
        identity_center = optional(object({
          crawled_account = object({
            iam_role_name     = string
            iam_role_path     = optional(string, null)
            iam_role_trustees = list(string)
          })
        }), null)
      })
    })
  })
}

variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
