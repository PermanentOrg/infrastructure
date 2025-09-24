resource "kubernetes_ingress_v1" "archivematica_dashboard_ingress_dev" {
  metadata {
    name = "archivematica-dashboard-ingress-dev"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/inbound-cidrs"   = join(",", var.whitelisted_cidrs)
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_dashboard_service_dev.metadata.0.name
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

resource "kubernetes_ingress_v1" "archivematica_storage_ingress_dev" {
  metadata {
    name = "archivematica-storage-ingress-dev"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/inbound-cidrs"   = join(",", var.whitelisted_cidrs)
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_storage_service_dev.metadata.0.name
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
resource "kubernetes_ingress_v1" "archivematica_dashboard_internal_ingress_dev" {
  metadata {
    name = "archivematica-dashboard-internal-ingress-dev"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/security-groups" = var.dev_security_group_id
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_dashboard_service_dev.metadata.0.name
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

resource "kubernetes_ingress_v1" "archivematica_storage_internal_ingress_dev" {
  metadata {
    name = "archivematica-storage-internal-ingress-dev"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/e5302df5-6f76-4341-bc41-cd368b6e7411"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/security-groups" = var.dev_security_group_id
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.archivematica_storage_service_dev.metadata.0.name
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
