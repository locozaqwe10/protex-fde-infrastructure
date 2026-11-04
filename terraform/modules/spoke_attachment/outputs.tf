output "vpc_id" {
  value = data.aws_vpc.spoke.id
}

output "vpc_cidr" {
  value = data.aws_vpc.spoke.cidr_block
}

output "private_subnet_ids" {
  value = data.aws_subnets.private.ids
}
