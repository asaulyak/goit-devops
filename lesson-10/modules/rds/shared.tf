# Спільні ресурси для RDS та Aurora

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name      = "${var.db_identifier}-subnet-group"
      ManagedBy = "Terraform"
    }
  )
}

# Security Group для RDS
resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for ${var.db_identifier} database"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound from VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "Allow inbound from specified security groups"
      from_port       = var.db_port
      to_port         = var.db_port
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.db_identifier}-sg"
      ManagedBy = "Terraform"
    }
  )
}

# Parameter Group для звичайного RDS
resource "aws_db_parameter_group" "rds" {
  count  = var.use_aurora ? 0 : 1
  family = var.parameter_group_family
  name   = "${var.db_identifier}-parameter-group"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.db_identifier}-parameter-group"
      ManagedBy = "Terraform"
    }
  )
}

# Parameter Group для Aurora Cluster
resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  family = var.parameter_group_family
  name   = "${var.db_identifier}-cluster-parameter-group"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.db_identifier}-cluster-parameter-group"
      ManagedBy = "Terraform"
    }
  )
}

