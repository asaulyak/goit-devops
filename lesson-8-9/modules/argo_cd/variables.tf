variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "cluster_auth_token" {
  description = "EKS cluster authentication token"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "argo_cd_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.2.0"
}

variable "argo_cd_values_file" {
  description = "Path to Argo CD values.yaml file"
  type        = string
  default     = "values.yaml"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

variable "git_repository_url" {
  description = "Git repository URL for Argo CD to monitor"
  type        = string
  default     = ""
}

variable "git_repository_path" {
  description = "Path to Helm chart in Git repository"
  type        = string
  default     = "charts/django-app"
}

variable "application_name" {
  description = "Name of the Argo CD application"
  type        = string
  default     = "django-app"
}

variable "target_namespace" {
  description = "Target namespace for the application"
  type        = string
  default     = "default"
}

variable "target_revision" {
  description = "Target Git revision (branch or tag)"
  type        = string
  default     = "main"
}

