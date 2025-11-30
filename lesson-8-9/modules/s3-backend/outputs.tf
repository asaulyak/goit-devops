output "bucket_name" {
  description = "S3 bucketname"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "bucket_domain_name" {
  description = "Domain name for S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket_domain_name
}

output "table_name" {
  description = "Table name in DynamoDB"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "table_arn" {
  description = "ARN DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}

