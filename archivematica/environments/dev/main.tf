# Provider configuration
terraform {
  required_version = ">= 1.9.7"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "per-terraform-backend"
    key     = "archivematica/dev/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Data sources
data "aws_eks_cluster" "cluster" {
  name = "archivematica-dev"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "archivematica-dev"
}

# Local values for image management
locals {
  current_archivematica_deploy = try(data.kubernetes_resource.archivematica_dev.object, null)
  current_mcp_client_deploy = try(data.kubernetes_resource.mcp_client_dev.object, null)

  current_containers = concat(
    try(local.current_archivematica_deploy.spec.template.spec.containers, []),
    try(local.current_mcp_client_deploy.spec.template.spec.containers, [])
  )

  current_images = { for container in local.current_containers : container.name => container.image }

  desired_images = {
    for name, image in local.current_images :
    name => (contains(keys(var.image_overrides), name)
      ? var.image_overrides[name]
      : local.current_images[name]
    )
  }
}

# Data sources for existing deployments (needed for image management)
data "kubernetes_resource" "archivematica_dev" {
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata { name = "archivematica-dev" }
}

data "kubernetes_resource" "mcp_client_dev" {
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata { name = "archivematica-mcp-client-dev" }
}

# Redis module
module "redis" {
  source = "../../modules/redis"

  environment     = "dev"
  app_name        = "archivematica"
  memory_limit    = "512Mi"
  memory_request  = "256Mi"
  storage_size    = "2Gi"
  storage_class   = "gp2"
  replicas        = 1
}

# Gearman module
module "gearman" {
  source = "../../modules/gearman"

  environment         = "dev"
  app_name            = "archivematica"
  redis_service_name  = module.redis.service_name
  memory_limit        = "2048Mi"
  memory_request      = "256Mi"
  cpu_limit           = "1000m"
  cpu_request         = "1m"
  replicas            = 1
}

# Archivematica module
module "archivematica" {
  source = "../../modules/archivematica"

  environment     = "dev"
  app_name        = "archivematica"
  replicas        = 1
  mcp_client_replicas = 4

  # Images from the current deployment or overrides
  storage_service_image = local.desired_images["archivematica-storage-service-dev"]
  dashboard_image       = local.desired_images["archivematica-dashboard-dev"]
  mcp_server_image      = local.desired_images["archivematica-mcp-server-dev"]
  mcp_client_image      = local.desired_images["archivematica-mcp-client-dev"]

  # Service configuration
  gearman_service_name = module.gearman.service_name
  allowed_hosts        = "dev.archivematica.permanent.org"

  # Resource configuration
  mcp_server_memory_limit    = "2048Mi"
  mcp_server_memory_request  = "256Mi"
  mcp_server_cpu_limit       = "333m"
  mcp_server_cpu_request     = "1m"

  mcp_client_memory_limit    = "2048Mi"
  mcp_client_memory_request  = "256Mi"
  mcp_client_cpu_limit       = "1000m"
  mcp_client_cpu_request     = "1m"

  # Storage configuration
  pipeline_data_storage    = "2Gi"
  staging_data_storage     = "2Gi"
  location_data_storage    = "2Gi"
  transfer_share_storage   = "2Gi"
  storage_share_storage    = "2Gi"
  storage_class           = "gp2"
}

# Ingress module
module "ingress" {
  source = "../../modules/ingress"

  environment               = "dev"
  app_name                 = "archivematica"
  dashboard_service_name   = module.archivematica.dashboard_service_name
  storage_service_name     = module.archivematica.storage_service_name

  subnet_ids              = var.subnet_ids
  certificate_arn         = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
  whitelisted_cidrs       = var.whitelisted_cidrs
  security_group_id       = var.dev_security_group_id

  dashboard_port          = 8001
  storage_port           = 8002
}