variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "prod_env" {
  description = "Name of the prod environment"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-3da37958"
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  default     = ["subnet-a3f202fa", "subnet-fc843999", "subnet-0fc91a78"]
}
variable "security_group_id" {
  description = "ID of the prodelopment security group"
  type        = string
  default     = "sg-9c3f62f9"
}

variable "prod_ss_database_url" {
  description = "URL of the storage service database for the prod environment"
  type        = string
}

variable "prod_ss_password" {
  description = "Password to the prod environment's storage service"
  type        = string
}

variable "prod_ss_api_key" {
  description = "API key for the prod environment's storage service"
  type        = string
}

variable "prod_archivematica_dashboard_db_host" {
  description = "Host address of the prod environment's database"
  type        = string
}

variable "prod_archivematica_dashboard_db_password" {
  description = "Password to the prod environment's database"
  type        = string
}

variable "prod_django_secret_key" {
  description = "Signing key for django in the prod environment"
  type        = string
}

variable "prod_backblaze_key_id" {
  description = "Key ID for Backblaze in the prod environment"
  type        = string
}

variable "prod_backblaze_application_key" {
  description = "Application key for Backblaze in the prod environment"
  type        = string
}

variable "whitelisted_cidrs" {
  description = "IPs allowed to access Archivematica from outside the security group"
  type        = list(string)
}

variable "image_overrides" {
  description = "A map of docker images to be updated"
  type        = map(string)
  default     = {}
}

variable "alert_email" {
  description = "The email to which to send Cloudwatch alerts"
  type        = string
  default     = "engineering@permanent.org"
}
