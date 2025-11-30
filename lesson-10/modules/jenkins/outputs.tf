output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://jenkins.${kubernetes_namespace.jenkins.metadata[0].name}.svc.cluster.local:8080"
}

output "jenkins_loadbalancer_url" {
  description = "Jenkins LoadBalancer URL (check with: kubectl get svc -n ${kubernetes_namespace.jenkins.metadata[0].name})"
  value       = "Run: kubectl get svc jenkins -n ${kubernetes_namespace.jenkins.metadata[0].name} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "jenkins_admin_password" {
  description = "Jenkins admin password (get with: kubectl get secret jenkins -n ${kubernetes_namespace.jenkins.metadata[0].name} -o jsonpath='{.data.jenkins-admin-password}' | base64 -d)"
  value       = "Run: kubectl get secret jenkins -n ${kubernetes_namespace.jenkins.metadata[0].name} -o jsonpath='{.data.jenkins-admin-password}' | base64 -d"
  sensitive   = false
}

output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

