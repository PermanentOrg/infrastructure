variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "archivematica"
}

variable "gearman_image" {
  description = "Gearman Docker image"
  type        = string
  default     = "artefactual/gearmand:1.1.21.4-alpine"
}

variable "redis_service_name" {
  description = "Name of the Redis service to connect to"
  type        = string
}

variable "memory_limit" {
  description = "Memory limit for Gearman container"
  type        = string
  default     = "2048Mi"
}

variable "memory_request" {
  description = "Memory request for Gearman container"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit for Gearman container"
  type        = string
  default     = "1000m"
}

variable "cpu_request" {
  description = "CPU request for Gearman container"
  type        = string
  default     = "1m"
}

variable "replicas" {
  description = "Number of Gearman replicas"
  type        = number
  default     = 1
}