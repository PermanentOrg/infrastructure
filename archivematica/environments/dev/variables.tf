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

variable "dev_security_group_id" {
  description = "ID of the Development security group"
  type        = string
  default     = "sg-eca0e789"
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
variable "dev_ss_database_url" {
  description = "URL of the storage service database for the dev environment"
  type        = string
  sensitive   = true
}

variable "dev_ss_password" {
  description = "Password to the dev environment's storage service"
  type        = string
  sensitive   = true
}

variable "dev_ss_api_key" {
  description = "API key for the dev environment's storage service"
  type        = string
  sensitive   = true
}

variable "dev_archivematica_dashboard_db_host" {
  description = "Host address of the dev environment's database"
  type        = string
}

variable "dev_archivematica_dashboard_db_password" {
  description = "Password to the dev environment's database"
  type        = string
  sensitive   = true
}

variable "dev_django_secret_key" {
  description = "Signing key for django in the dev environment"
  type        = string
  sensitive   = true
}

variable "dev_backblaze_key_id" {
  description = "Key ID for Backblaze in the dev environment"
  type        = string
  sensitive   = true
}

variable "dev_backblaze_application_key" {
  description = "Application key for Backblaze in the dev environment"
  type        = string
  sensitive   = true
}