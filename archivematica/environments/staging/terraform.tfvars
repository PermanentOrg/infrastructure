# Example terraform.tfvars for staging environment
# Copy this file and customize for your staging environment

region = "us-west-2"
subnet_ids = ["subnet-a3f202fa", "subnet-fc843999", "subnet-0fc91a78"]
staging_security_group_id = "sg-fea0e79b"

# Customize these values for your environment
whitelisted_cidrs = [
  # Add your allowed IP ranges here
]

# Optional: Override specific Docker images
# image_overrides = {
#   "archivematica-storage-service-staging" = "your-custom-image:tag"
#   "archivematica-dashboard-staging" = "your-custom-image:tag"
# }