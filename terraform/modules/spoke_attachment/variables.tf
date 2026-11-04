variable "spoke_name" {
  type = string
}

variable "central_cidrs" {
  type        = list(string)
  description = "Central VPC subnet CIDRs for SG ingress rules"
}
