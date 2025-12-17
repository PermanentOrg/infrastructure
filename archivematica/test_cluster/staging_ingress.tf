resource "kubernetes_ingress_v1" "archivematica_dashboard_ingress_staging" {
  metadata {
    name = "archivematica-dashboard-ingress-staging"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-staging"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/inbound-cidrs"   = join(",", var.whitelisted_cidrs)
    }
    namespace = kubernetes_namespace.archivematica_staging.metadata[0].name
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_dashboard_service_staging.metadata.0.name
              port {
                number = 8001
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "archivematica_storage_ingress_staging" {
  metadata {
    name = "archivematica-storage-ingress-staging"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-staging"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/inbound-cidrs"   = join(",", var.whitelisted_cidrs)
    }
    namespace = kubernetes_namespace.archivematica_staging.metadata[0].name
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_storage_service_staging.metadata.0.name
              port {
                number = 8002
              }
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_ingress_v1" "archivematica_dashboard_internal_ingress_staging" {
  metadata {
    name = "archivematica-dashboard-internal-ingress-staging"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-staging-internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/security-groups" = var.staging_security_group_id
    }
    namespace = kubernetes_namespace.archivematica_staging.metadata[0].name
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_dashboard_service_staging.metadata.0.name
              port {
                number = 8001
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "archivematica_storage_internal_ingress_staging" {
  metadata {
    name = "archivematica-storage-internal-ingress-staging"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-staging-internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/security-groups" = var.staging_security_group_id
    }
    namespace = kubernetes_namespace.archivematica_staging.metadata[0].name
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_storage_service_staging.metadata.0.name
              port {
                number = 8002
              }
            }
          }
        }
      }
    }
  }
}
