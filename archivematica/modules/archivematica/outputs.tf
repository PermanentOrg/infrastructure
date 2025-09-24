output "dashboard_service_name" {
  description = "Name of the dashboard service"
  value       = kubernetes_service.dashboard.metadata[0].name
}

output "storage_service_name" {
  description = "Name of the storage service"
  value       = kubernetes_service.storage.metadata[0].name
}

output "dashboard_port" {
  description = "Port of the dashboard service"
  value       = kubernetes_service.dashboard.spec[0].port[0].port
}

output "storage_port" {
  description = "Port of the storage service"
  value       = kubernetes_service.storage.spec[0].port[0].port
}

output "deployment_name" {
  description = "Name of the main deployment"
  value       = kubernetes_deployment.archivematica.metadata[0].name
}

output "mcp_client_deployment_name" {
  description = "Name of the MCP client deployment"
  value       = kubernetes_deployment.mcp_client.metadata[0].name
}