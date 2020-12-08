variable "perm_ami_owner" {
  description = "Owner ID for Permanent-built AMIs"
  type        = string
  default     = "364159549467"
}

variable "perm_env" {
  description = "Permanent environment keywords"
  type = object({
    name = string
    sg   = string
    zone = string
  })
}
