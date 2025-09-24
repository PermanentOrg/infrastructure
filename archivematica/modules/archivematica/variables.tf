variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "archivematica"
}

variable "replicas" {
  description = "Number of replicas for main deployment"
  type        = number
  default     = 1
}

variable "mcp_client_replicas" {
  description = "Number of MCP client replicas"
  type        = number
  default     = 4
}

# Image variables
variable "storage_service_image" {
  description = "Storage service Docker image"
  type        = string
}

variable "dashboard_image" {
  description = "Dashboard Docker image"
  type        = string
}

variable "mcp_server_image" {
  description = "MCP server Docker image"
  type        = string
}

variable "mcp_client_image" {
  description = "MCP client Docker image"
  type        = string
}

# Service configuration
variable "gearman_service_name" {
  description = "Name of the Gearman service"
  type        = string
}

variable "allowed_hosts" {
  description = "Django allowed hosts"
  type        = string
}

# Resource configuration
variable "mcp_server_memory_limit" {
  description = "Memory limit for MCP server"
  type        = string
  default     = "2048Mi"
}

variable "mcp_server_memory_request" {
  description = "Memory request for MCP server"
  type        = string
  default     = "256Mi"
}

variable "mcp_server_cpu_limit" {
  description = "CPU limit for MCP server"
  type        = string
  default     = "333m"
}

variable "mcp_server_cpu_request" {
  description = "CPU request for MCP server"
  type        = string
  default     = "1m"
}

variable "mcp_client_memory_limit" {
  description = "Memory limit for MCP client"
  type        = string
  default     = "2048Mi"
}

variable "mcp_client_memory_request" {
  description = "Memory request for MCP client"
  type        = string
  default     = "256Mi"
}

variable "mcp_client_cpu_limit" {
  description = "CPU limit for MCP client"
  type        = string
  default     = "1000m"
}

variable "mcp_client_cpu_request" {
  description = "CPU request for MCP client"
  type        = string
  default     = "1m"
}

# Storage configuration
variable "pipeline_data_storage" {
  description = "Storage size for pipeline data"
  type        = string
  default     = "2Gi"
}

variable "staging_data_storage" {
  description = "Storage size for staging data"
  type        = string
  default     = "2Gi"
}

variable "location_data_storage" {
  description = "Storage size for location data"
  type        = string
  default     = "2Gi"
}

variable "transfer_share_storage" {
  description = "Storage size for transfer share"
  type        = string
  default     = "2Gi"
}

variable "storage_share_storage" {
  description = "Storage size for storage share"
  type        = string
  default     = "2Gi"
}

variable "storage_class" {
  description = "Storage class for PVCs"
  type        = string
  default     = "gp2"
}