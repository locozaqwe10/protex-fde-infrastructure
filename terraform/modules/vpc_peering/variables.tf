variable "name" {
  type = string
}

variable "requester_vpc_id" {
  type = string
}

variable "accepter_vpc_id" {
  type = string
}

variable "accepter_account_id" {
  type = string
}

variable "accepter_region" {
  type = string
}

variable "requester_route_table_ids" {
  type = map(string)
}

variable "accepter_route_table_ids" {
  type = map(string)
}

variable "requester_cidr_blocks" {
  type = list(string)
}

variable "accepter_cidr_blocks" {
  type = list(string)
}
