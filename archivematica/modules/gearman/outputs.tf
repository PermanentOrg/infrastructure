output "service_name" {
  description = "Name of the Gearman service"
  value       = kubernetes_service.gearman.metadata[0].name
}

output "service_port" {
  description = "Port of the Gearman service"
  value       = kubernetes_service.gearman.spec[0].port[0].port
}