variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "S3 bucket for Terraform"
  type        = string
  default     = "goit-devops-terraform-state"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "terraform-locks"
}

variable "vpc_cidr_block" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDR for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "lesson-5-vpc"
}

variable "ecr_name" {
  description = "ECR name"
  type        = string
  default     = "lesson-5-ecr"
}

variable "scan_on_push" {
  description = "Autoscan on push"
  type        = bool
  default     = true
}

