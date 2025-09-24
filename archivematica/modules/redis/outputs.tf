output "service_name" {
  description = "Name of the Redis service"
  value       = kubernetes_service.redis.metadata[0].name
}

output "service_port" {
  description = "Port of the Redis service"
  value       = kubernetes_service.redis.spec[0].port[0].port
}

output "deployment_name" {
  description = "Name of the Redis deployment"
  value       = kubernetes_deployment.redis.metadata[0].name
}