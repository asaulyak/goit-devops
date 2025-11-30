output "argocd_url" {
  description = "Argo CD URL"
  value       = "http://argocd-server.${kubernetes_namespace.argocd.metadata[0].name}.svc.cluster.local"
}

output "argocd_loadbalancer_url" {
  description = "Argo CD LoadBalancer URL (check with: kubectl get svc -n ${kubernetes_namespace.argocd.metadata[0].name})"
  value       = "Run: kubectl get svc argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_admin_password" {
  description = "Argo CD admin password (get with: kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
  value       = "Run: kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  sensitive   = false
}

output "namespace" {
  description = "Argo CD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

