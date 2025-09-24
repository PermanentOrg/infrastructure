output "dashboard_public_ingress_name" {
  description = "Name of the public dashboard ingress"
  value       = kubernetes_ingress_v1.dashboard_public.metadata[0].name
}

output "storage_public_ingress_name" {
  description = "Name of the public storage ingress"
  value       = kubernetes_ingress_v1.storage_public.metadata[0].name
}

output "dashboard_internal_ingress_name" {
  description = "Name of the internal dashboard ingress"
  value       = kubernetes_ingress_v1.dashboard_internal.metadata[0].name
}

output "storage_internal_ingress_name" {
  description = "Name of the internal storage ingress"
  value       = kubernetes_ingress_v1.storage_internal.metadata[0].name
}