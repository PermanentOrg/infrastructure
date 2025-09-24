# Public Dashboard Ingress
resource "kubernetes_ingress_v1" "dashboard_public" {
  metadata {
    name = "${var.app_name}-dashboard-ingress-${var.environment}"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = join(",", var.subnet_ids)
      "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = var.app_name
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
              name = var.dashboard_service_name
              port {
                number = var.dashboard_port
              }
            }
          }
        }
      }
    }
  }
}

# Public Storage Service Ingress
resource "kubernetes_ingress_v1" "storage_public" {
  metadata {
    name = "${var.app_name}-storage-ingress-${var.environment}"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = join(",", var.subnet_ids)
      "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = var.app_name
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
              name = var.storage_service_name
              port {
                number = var.storage_port
              }
            }
          }
        }
      }
    }
  }
}

# Internal Dashboard Ingress
resource "kubernetes_ingress_v1" "dashboard_internal" {
  metadata {
    name = "${var.app_name}-dashboard-internal-ingress-${var.environment}"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = join(",", var.subnet_ids)
      "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "${var.app_name}-internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/security-groups" = var.security_group_id
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
              name = var.dashboard_service_name
              port {
                number = var.dashboard_port
              }
            }
          }
        }
      }
    }
  }
}

# Internal Storage Service Ingress
resource "kubernetes_ingress_v1" "storage_internal" {
  metadata {
    name = "${var.app_name}-storage-internal-ingress-${var.environment}"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = join(",", var.subnet_ids)
      "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = "${var.app_name}-internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/security-groups" = var.security_group_id
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
              name = var.storage_service_name
              port {
                number = var.storage_port
              }
            }
          }
        }
      }
    }
  }
}