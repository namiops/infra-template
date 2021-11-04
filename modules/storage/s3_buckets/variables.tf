variable "company" {
  type        = string
  default     = "liquid"
}

variable "project" {
  type        = string
  default     = ""
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "component" {
  type = string
  default = "s3"
}

variable "bucket_list" {
  type        = list(
    object({
      name = string
      versioning = bool
      acl = string
    })
  )
  default     = []
}

variable "versioning" {
  type = bool
  default = true
}

