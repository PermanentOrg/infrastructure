variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  default     = ["subnet-a3f202fa", "subnet-fc843999", "subnet-0fc91a78"]
}

variable "staging_security_group_id" {
  description = "ID of the Staging security group"
  type        = string
  default     = "sg-fea0e79b"
}

variable "whitelisted_cidrs" {
  description = "IPs allowed to access Archivematica from outside the security group"
  type        = list(string)
}

variable "image_overrides" {
  description = "A map of docker images to be updated"
  type = map(string)
  default = {}
}

# Secret variables
variable "staging_ss_database_url" {
  description = "URL of the storage service database for the staging environment"
  type        = string
  sensitive   = true
}

variable "staging_ss_password" {
  description = "Password to the staging environment's storage service"
  type        = string
  sensitive   = true
}

variable "staging_ss_api_key" {
  description = "API key for the staging environment's storage service"
  type        = string
  sensitive   = true
}

variable "staging_archivematica_dashboard_db_host" {
  description = "Host address of the staging environment's database"
  type        = string
}

variable "staging_archivematica_dashboard_db_password" {
  description = "Password to the staging environment's database"
  type        = string
  sensitive   = true
}

variable "staging_django_secret_key" {
  description = "Signing key for django in the staging environment"
  type        = string
  sensitive   = true
}

variable "staging_backblaze_key_id" {
  description = "Key ID for Backblaze in the staging environment"
  type        = string
  sensitive   = true
}

variable "staging_backblaze_application_key" {
  description = "Application key for Backblaze in the staging environment"
  type        = string
  sensitive   = true
}