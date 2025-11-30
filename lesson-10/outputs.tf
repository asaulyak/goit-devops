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

# Виведення інформації про VPC
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

# Виведення інформації про ECR
output "ecr_repository_url" {
  description = "URL ECR"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN ECR"
  value       = module.ecr.repository_arn
}

# Виведення інформації про EKS
# Використовуємо значення з модуля напряму, а не з data source
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

# Додаткові outputs з data source (будуть доступні після створення кластера)
# Розкоментуйте після створення кластера та розкоментування data sources
# output "eks_cluster_endpoint_from_data" {
#   description = "EKS cluster endpoint from data source"
#   value       = try(data.aws_eks_cluster.cluster.endpoint, "Cluster not created yet")
#   sensitive   = false
# }

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Jenkins outputs
output "jenkins_url" {
  description = "Jenkins URL"
  value       = module.jenkins.jenkins_url
}

output "jenkins_loadbalancer_url" {
  description = "Jenkins LoadBalancer URL command"
  value       = module.jenkins.jenkins_loadbalancer_url
}

output "jenkins_admin_password_command" {
  description = "Command to get Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password
  sensitive   = false
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = module.jenkins.namespace
}

# Argo CD outputs
output "argocd_url" {
  description = "Argo CD URL"
  value       = module.argo_cd.argocd_url
}

output "argocd_loadbalancer_url" {
  description = "Argo CD LoadBalancer URL command"
  value       = module.argo_cd.argocd_loadbalancer_url
}

output "argocd_admin_password_command" {
  description = "Command to get Argo CD admin password"
  value       = module.argo_cd.argocd_admin_password
  sensitive   = false
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = module.argo_cd.namespace
}

