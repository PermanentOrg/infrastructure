variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "archivematica"
}

variable "redis_image" {
  description = "Redis Docker image"
  type        = string
  default     = "redis:6-alpine"
}

variable "memory_limit" {
  description = "Memory limit for Redis container"
  type        = string
  default     = "512Mi"
}

variable "memory_request" {
  description = "Memory request for Redis container"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit for Redis container"
  type        = string
  default     = "250m"
}

variable "cpu_request" {
  description = "CPU request for Redis container"
  type        = string
  default     = "250m"
}

variable "storage_size" {
  description = "Storage size for Redis PVC"
  type        = string
  default     = "2Gi"
}

variable "storage_class" {
  description = "Storage class for Redis PVC"
  type        = string
  default     = "gp2"
}

variable "replicas" {
  description = "Number of Redis replicas"
  type        = number
  default     = 1
}