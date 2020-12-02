variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "perm_ami_owner" {
  description = "Owner ID for Permanent-built AMIs"
  type        = string
  default     = "364159549467"
}

variable "key_name" {
  description = "Owner ID for Permanent-built AMIs"
  type        = string
  default     = "364159549467"
}

variable "perm_env" {
  description = "Permanent environment keywords"
  type = object({
    name = string
    sg   = string
  })
  default = {
    name = "dev"
    sg   = "Development"
  }
}
