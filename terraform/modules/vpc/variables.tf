variable "name" {
  type = string
}

variable "cidr_block" {
  type = string

  validation {
    condition     = can(regex("/(1[6-9]|20)$", var.cidr_block))
    error_message = "CIDR must be between /16 and /20."
  }
}

variable "subnet_tiers" {
  type = map(object({
    cidr_newbits = number
    az_count     = number
    public       = optional(bool, false)
  }))
}

variable "enable_flow_logs" {
  type    = bool
  default = true
}

variable "enable_nat" {
  type    = bool
  default = false
}
