resource "kubernetes_ingress_v1" "archivematica_dashboard_ingress_prod" {
  metadata {
    name = "archivematica-dashboard-ingress-dev"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/ba6adc44-5a9d-47cb-a64f-ddb840f6f19d"
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
              name = kubernetes_service.archivematica_dashboard_service_prod.metadata.0.name
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

resource "kubernetes_ingress_v1" "archivematica_storage_ingress_prod" {
  metadata {
    name = "archivematica-storage-ingress-prod"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/ba6adc44-5a9d-47cb-a64f-ddb840f6f19d"
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
              name = kubernetes_service.archivematica_storage_service_prod.metadata.0.name
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
resource "kubernetes_ingress_v1" "archivematica_dashboard_internal_ingress_prod" {
  metadata {
    name = "archivematica-dashboard-internal-ingress-prod"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/ba6adc44-5a9d-47cb-a64f-ddb840f6f19d"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-internal"
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
              name = kubernetes_service.archivematica_dashboard_service_prod.metadata.0.name
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

resource "kubernetes_ingress_v1" "archivematica_storage_internal_ingress_prod" {
  metadata {
    name = "archivematica-storage-internal-ingress-prod"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/subnets"         = "${var.subnet_ids[0]},${var.subnet_ids[1]},${var.subnet_ids[2]}"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:364159549467:certificate/ba6adc44-5a9d-47cb-a64f-ddb840f6f19d"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":8000}]"
      "alb.ingress.kubernetes.io/group.name"      = "archivematica-internal"
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
              name = kubernetes_service.archivematica_storage_service_prod.metadata.0.name
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
