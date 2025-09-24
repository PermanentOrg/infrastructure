output "redis_service_name" {
  description = "Name of the Redis service"
  value       = module.redis.service_name
}

output "gearman_service_name" {
  description = "Name of the Gearman service"
  value       = module.gearman.service_name
}

output "dashboard_service_name" {
  description = "Name of the Archivematica dashboard service"
  value       = module.archivematica.dashboard_service_name
}

output "storage_service_name" {
  description = "Name of the Archivematica storage service"
  value       = module.archivematica.storage_service_name
}

output "dashboard_public_ingress_name" {
  description = "Name of the public dashboard ingress"
  value       = module.ingress.dashboard_public_ingress_name
}

output "storage_public_ingress_name" {
  description = "Name of the public storage ingress"
  value       = module.ingress.storage_public_ingress_name
}