# Create namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = var.cluster_auth_token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = var.cluster_auth_token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

# Install Argo CD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argo_cd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/${var.argo_cd_values_file}")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Install Argo CD Application via Helm chart (only if git repository URL is provided)
resource "helm_release" "argocd_applications" {
  count = var.git_repository_url != "" ? 1 : 0
  
  name       = "argocd-applications"
  chart      = "${path.module}/charts"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "applications[0].name"
    value = var.application_name
  }

  set {
    name  = "applications[0].namespace"
    value = var.target_namespace
  }

  set {
    name  = "applications[0].repoURL"
    value = var.git_repository_url
  }

  set {
    name  = "applications[0].targetPath"
    value = var.git_repository_path
  }

  set {
    name  = "applications[0].targetRevision"
    value = var.target_revision
  }

  set {
    name  = "namespace"
    value = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [
    helm_release.argocd
  ]
}

