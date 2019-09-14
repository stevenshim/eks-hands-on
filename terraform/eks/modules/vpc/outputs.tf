output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_public_subnet_ids" {
  value = aws_subnet.vpc_public_subnets.*.id
}

output "vpc_private_subnet_ids" {
  value = aws_subnet.vpc_private_subnets.*.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}