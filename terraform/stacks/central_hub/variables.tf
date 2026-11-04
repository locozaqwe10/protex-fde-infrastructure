variable "hub_name" {
  type = string
}

variable "hub_cidr" {
  type = string
}

variable "spokes" {
  type = map(object({
    account_id = string
    region     = string
    vpc_name   = string
    cidr       = string
  }))
}

variable "redis_node_type" {
  type    = string
  default = "cache.r7g.large"
}

variable "redis_num_nodes" {
  type    = number
  default = 2
}
