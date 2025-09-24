variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "archivematica"
}

variable "dashboard_service_name" {
  description = "Name of the dashboard service"
  type        = string
}

variable "storage_service_name" {
  description = "Name of the storage service"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
}

variable "whitelisted_cidrs" {
  description = "List of CIDRs allowed to access the ingress"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for internal ingress"
  type        = string
}

variable "dashboard_port" {
  description = "Port for dashboard service"
  type        = number
  default     = 8001
}

variable "storage_port" {
  description = "Port for storage service"
  type        = number
  default     = 8002
}