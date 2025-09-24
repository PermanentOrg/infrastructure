# Archivematica Infrastructure

This directory contains Terraform modules and environment configurations for deploying Archivematica infrastructure using a modular approach.

## Structure

```
archivematica/
├── modules/                    # Reusable Terraform modules
│   ├── redis/                 # Redis deployment module
│   ├── gearman/              # Gearman deployment module
│   ├── archivematica/        # Main Archivematica application module
│   └── ingress/              # Ingress/load balancer module
├── environments/             # Environment-specific configurations
│   ├── dev/                  # Development environment
│   └── staging/              # Staging environment
└── test_cluster/            # EKS cluster infrastructure (shared)
```

## Usage

### Deploy Dev Environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy Staging Environment

```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

## Modules

### Redis Module
- **Path**: `modules/redis/`
- **Purpose**: Deploys Redis instance with persistent storage
- **Configuration**: Memory limits, storage size, replica count

### Gearman Module
- **Path**: `modules/gearman/`
- **Purpose**: Deploys Gearman job server connected to Redis
- **Dependencies**: Requires Redis service name

### Archivematica Module
- **Path**: `modules/archivematica/`
- **Purpose**: Deploys main Archivematica application stack
- **Components**:
  - Storage Service container
  - Dashboard container
  - MCP Server container
  - MCP Client deployment (separate)
  - Required PVCs and services
- **Dependencies**: Requires Gearman service name

### Ingress Module
- **Path**: `modules/ingress/`
- **Purpose**: Creates ALB ingresses for public and internal access
- **Components**:
  - Public dashboard ingress (HTTPS:443)
  - Public storage service ingress (HTTPS:8000)
  - Internal dashboard ingress
  - Internal storage service ingress
- **Dependencies**: Requires dashboard and storage service names

## Environment Configuration

Each environment directory contains:

- **main.tf**: Module instantiations and configuration
- **variables.tf**: Variable declarations
- **outputs.tf**: Output values
- **terraform.tfvars**: Environment-specific variable values

### Key Environment Differences

- **Cluster names**: `archivematica-dev` vs `archivematica-staging`
- **Hostnames**: `dev.archivematica.permanent.org` vs `staging.archivematica.permanent.org`
- **Security groups**: Different for each environment
- **State files**: Separate S3 backend paths

## Benefits of This Approach

1. **DRY Principle**: Single source of truth for each component
2. **Environment Isolation**: Separate state files and configurations
3. **Easy Scaling**: Environment-specific resource sizing
4. **Maintainability**: Changes apply consistently across environments
5. **Modularity**: Components can be deployed independently if needed

## Infrastructure Layers

### EKS Cluster Infrastructure (`test_cluster/`)
The `test_cluster/` directory contains shared infrastructure that creates and manages the EKS cluster itself:
- **eks-cluster.tf**: Creates the EKS cluster and node groups
- **load_balancer.tf**: Sets up AWS Load Balancer Controller
- **main.tf**: Provider configuration for cluster creation

This is deployed once per cluster and shared by both dev and staging environments.

### Application Deployments (`environments/`)
The modular application deployments (Redis, Gearman, Archivematica, Ingress) are deployed per-environment using the reusable modules.

## Image Management

The configuration preserves the existing image override system. Images are managed through:

1. **Current deployment inspection**: Reads existing container images
2. **Override capability**: `image_overrides` variable can specify new images
3. **Fallback**: Uses current images if no override specified

This ensures zero-disruption deployment while allowing for image updates.