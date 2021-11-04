# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "company" {
  type        = string
  default     = "company"
}

variable "project" {
  type        = string
  default     = "project-template"
}

variable "environment" {
  type        = string
  default     = "stage"
}

variable "component" {
  type        = string
  default     = "network"
}

variable "cidr" {
  type        = string
  default     = ""
}

variable "azs" {
  description = "Name (e.g app or cluster)"
  type        = list(string)
  default     = [""]
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = false
}

variable "public_subnets" {
  type        = list(string)
  default     = [""]
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  type        = bool
  default     = false
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  type        = bool
  default     = false
}

variable "private_subnets" {
  type        = list(string)
  default     = [""]
}

variable "enable_ipv6" {
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  type        = bool
  default     = false
}