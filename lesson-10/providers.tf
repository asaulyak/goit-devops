# Kubernetes провайдер
# Використовує ТІЛЬКИ exec блок для автентифікації - не потребує data source
# Exec блок виконується тільки під час apply, коли кластер вже існує
# Це дозволяє виконувати terraform plan без помилок
provider "kubernetes" {
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

# Helm провайдер
# Використовує ТІЛЬКИ exec блок для автентифікації
provider "helm" {
  kubernetes {
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

# Data sources для отримання інформації про EKS кластер
# Використовуються для outputs
# 
# ВАЖЛИВО: Під час першого plan/apply кластер не існує, тому ці data sources
# дадуть помилку. Є два варіанти:
#
# Варіант 1: Тимчасово закоментуйте ці data sources, виконайте terraform apply,
#            потім розкоментуйте їх.
#
# Варіант 2: Просто ігноруйте помилку під час plan і виконайте terraform apply -
#            після створення кластера все працюватиме.
#
# Рекомендація: Використовуйте Варіант 2 - просто виконайте terraform apply,
# навіть якщо plan показує помилку.

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

