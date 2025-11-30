# Outputs для звичайного RDS
output "rds_instance_id" {
  description = "ID RDS instance"
  value       = var.use_aurora ? null : try(aws_db_instance.main[0].id, null)
}

output "rds_instance_arn" {
  description = "ARN RDS instance"
  value       = var.use_aurora ? null : try(aws_db_instance.main[0].arn, null)
}

output "rds_instance_endpoint" {
  description = "Endpoint RDS instance"
  value       = var.use_aurora ? null : try(aws_db_instance.main[0].endpoint, null)
}

output "rds_instance_address" {
  description = "Address RDS instance"
  value       = var.use_aurora ? null : try(aws_db_instance.main[0].address, null)
}

output "rds_instance_port" {
  description = "Port RDS instance"
  value       = var.use_aurora ? null : try(aws_db_instance.main[0].port, null)
}

# Outputs для Aurora Cluster
output "aurora_cluster_id" {
  description = "ID Aurora cluster"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].id, null) : null
}

output "aurora_cluster_arn" {
  description = "ARN Aurora cluster"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].arn, null) : null
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint Aurora cluster"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].endpoint, null) : null
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint Aurora cluster"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].reader_endpoint, null) : null
}

output "aurora_cluster_port" {
  description = "Port Aurora cluster"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].port, null) : null
}

output "aurora_cluster_instance_ids" {
  description = "IDs Aurora cluster instances"
  value       = var.use_aurora ? aws_rds_cluster_instance.main[*].id : []
}

output "aurora_cluster_instance_endpoints" {
  description = "Endpoints Aurora cluster instances"
  value       = var.use_aurora ? aws_rds_cluster_instance.main[*].endpoint : []
}

# Спільні outputs
output "db_subnet_group_id" {
  description = "ID DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_name" {
  description = "Name DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "security_group_id" {
  description = "ID Security Group для RDS"
  value       = aws_security_group.rds.id
}

output "parameter_group_name" {
  description = "Name Parameter Group (для звичайного RDS)"
  value       = var.use_aurora ? null : try(aws_db_parameter_group.rds[0].name, null)
}

output "cluster_parameter_group_name" {
  description = "Name Cluster Parameter Group (для Aurora)"
  value       = var.use_aurora ? try(aws_rds_cluster_parameter_group.aurora[0].name, null) : null
}

# Універсальні outputs для зручності
output "database_endpoint" {
  description = "Endpoint бази даних (RDS або Aurora writer)"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].endpoint, null) : try(aws_db_instance.main[0].endpoint, null)
}

output "database_address" {
  description = "Address бази даних (RDS або Aurora writer)"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].endpoint, null) : try(aws_db_instance.main[0].address, null)
}

output "database_port" {
  description = "Port бази даних"
  value       = var.use_aurora ? try(aws_rds_cluster.main[0].port, null) : try(aws_db_instance.main[0].port, null)
}

