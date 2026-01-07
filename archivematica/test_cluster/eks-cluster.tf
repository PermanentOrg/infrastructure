module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.2.0"

  name               = local.cluster_name
  kubernetes_version = "1.33"

  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids
  endpoint_public_access = true
  security_group_id      = var.dev_security_group_id
  access_entries = {
    liam = {
      principal_arn     = "arn:aws:iam::364159549467:user/liam"
      user_name         = "liam"
      kubernetes_groups = ["eks-admins"]
    },
    cecilia = {
      principal_arn     = "arn:aws:iam::364159549467:user/cecilia"
      user_name         = "cecilia"
      kubernetes_groups = ["eks-admins"]
    }
  }

  addons = {
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts           = "OVERWRITE"
    }
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts           = "OVERWRITE"
    }
    vpc-cni = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts           = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
      resolve_conflicts        = "OVERWRITE"
    }
    amazon-cloudwatch-observability = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts           = "OVERWRITE"
      service_account_role_arn    = module.cloudwatch_observability_irsa.iam_role_arn
    }
  }

  eks_managed_node_groups = {
    one = {
      name     = "node-group-1"
      ami_type = "AL2023_x86_64_STANDARD"

      vpc_security_group_ids = [var.dev_security_group_id, var.staging_security_group_id]

      instance_types = ["t3.large"]

      min_size     = 3
      max_size     = 3
      desired_size = 3

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 32
            volume_type           = "gp2"
            delete_on_termination = true
            encrypted             = true
          }
        }
      }
    }
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.60.0"

  role_name_prefix      = "${local.cluster_name}-ebs-csi-"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type = "gp3"
  }
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

resource "kubernetes_cluster_role_binding" "eks_admins_cluster_admin" {
  metadata {
    name = "eks-admins-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "eks-admins"
    api_group = "rbac.authorization.k8s.io"
  }
}

module "cloudwatch_observability_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.60.0"

  // It is generally our practice to avoid abbreviations, but this actually does have a
  // length limit we'd run into if we spelled out "observability"
  role_name_prefix = "${local.cluster_name}-o11y-"

  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn

      namespace_service_accounts = [
        "amazon-cloudwatch:cloudwatch-agent",
        "amazon-cloudwatch:adot-collector",
      ]
    }
  }
}
