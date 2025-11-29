# Виведення інформації про S3 та DynamoDB
output "s3_bucket_name" {
  description = "S3 buxket name"
  value       = module.s3_backend.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN S3"
  value       = module.s3_backend.bucket_arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.s3_backend.table_name
}

output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR for VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "ID for public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ID for private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "ID NAT Gateway"
  value       = module.vpc.nat_gateway_ids
}

output "ecr_repository_url" {
  description = "URL ECR"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN ECR"
  value       = module.ecr.repository_arn
}

