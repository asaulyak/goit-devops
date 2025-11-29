output "vpc_id" {
  description = "ID VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "ID public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "ID private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "ID NAT Gateway"
  value       = aws_nat_gateway.main[*].id
}

output "public_route_table_id" {
  description = "ID Route Table public subnets"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "ID Route Tables private subnets"
  value       = aws_route_table.private[*].id
}

