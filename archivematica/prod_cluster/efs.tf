resource "aws_security_group" "prod_archivematica_efs" {
  name_prefix = "${local.cluster_name}-efs-"
  description = "Allow NFS access to the prod archivematica EFS filesystem from cluster nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from prod archivematica cluster nodes"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_efs_file_system" "prod_archivematica" {
  encrypted = true
}

resource "aws_efs_mount_target" "prod_archivematica" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.prod_archivematica.id
  subnet_id       = each.value
  security_groups = [aws_security_group.prod_archivematica_efs.id]
}

module "efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.60.0"

  role_name_prefix      = "${local.cluster_name}-efs-csi-"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.prod_archivematica.id
    directoryPerms   = "0755"
    uid              = "1000"
    gid              = "1000"
  }
  mount_options       = ["actimeo=1", "lookupcache=positive"]
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
}
