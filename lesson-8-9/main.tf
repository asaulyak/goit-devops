terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.bucket_name
  table_name  = var.table_name
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = var.vpc_name
}

module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = var.ecr_name
  scan_on_push = var.scan_on_push
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  
  node_group_name      = var.node_group_name
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size = var.node_group_desired_size
  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  
  tags = var.tags
}

# Data sources for EKS cluster (used for Kubernetes/Helm providers)
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Jenkins module
module "jenkins" {
  source = "./modules/jenkins"
  
  cluster_name          = module.eks.cluster_name
  cluster_endpoint      = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = data.aws_eks_cluster.cluster.certificate_authority[0].data
  cluster_auth_token    = data.aws_eks_cluster_auth.cluster.token
  
  namespace            = var.jenkins_namespace
  jenkins_chart_version = var.jenkins_chart_version
  ecr_repository_url   = module.ecr.repository_url
  aws_region          = var.aws_region
  
  resources = var.jenkins_resources
  agent_resources = var.jenkins_agent_resources
  
  tags = var.tags
}

# Argo CD module
module "argo_cd" {
  source = "./modules/argo_cd"
  
  cluster_name          = module.eks.cluster_name
  cluster_endpoint      = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = data.aws_eks_cluster.cluster.certificate_authority[0].data
  cluster_auth_token    = data.aws_eks_cluster_auth.cluster.token
  
  namespace            = var.argocd_namespace
  argo_cd_chart_version = var.argocd_chart_version
  aws_region           = var.aws_region
  
  git_repository_url  = var.git_repository_url
  git_repository_path = var.git_repository_path
  application_name    = var.argocd_application_name
  target_namespace    = var.argocd_target_namespace
  target_revision     = var.argocd_target_revision
  
  tags = var.tags
}

