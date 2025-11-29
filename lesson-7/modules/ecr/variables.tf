variable "ecr_name" {
  description = "ECR repo name"
  type        = string
}

variable "scan_on_push" {
  description = "Autoscan on push"
  type        = bool
  default     = true
}

