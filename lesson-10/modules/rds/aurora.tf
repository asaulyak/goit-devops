# Створення Aurora Cluster

resource "aws_rds_cluster" "main" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier      = "${var.db_identifier}-cluster"
  engine                  = var.engine
  engine_version          = var.engine_version
  engine_mode             = var.aurora_engine_mode
  database_name           = var.db_name
  master_username         = var.username
  master_password         = var.password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name

  port                    = var.db_port
  publicly_accessible     = var.publicly_accessible
  backup_retention_period  = var.backup_retention_period
  preferred_backup_window = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection       = var.deletion_protection
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id

  serverlessv2_scaling_configuration = var.aurora_serverless_v2_scaling_configuration

  tags = merge(
    var.tags,
    {
      Name      = "${var.db_identifier}-cluster"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_rds_cluster_instance" "main" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier         = "${var.db_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.main[0].engine
  engine_version     = aws_rds_cluster.main[0].engine_version

  publicly_accessible = var.publicly_accessible

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge(
    var.tags,
    {
      Name      = "${var.db_identifier}-instance-${count.index + 1}"
      ManagedBy = "Terraform"
    }
  )
}

