variable "vpc_cidr_block" {
  description = "CIDR for VPC"
  type        = string
}

variable "public_subnets" {
  description = "CIDR for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availablity zones for subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

