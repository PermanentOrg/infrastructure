resource "kubernetes_deployment" "gearman" {
  metadata {
    name = "${var.app_name}-gearman-${var.environment}"
    labels = {
      App         = "${var.app_name}-${var.environment}"
      Environment = var.environment
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        App = "${var.app_name}-gearman-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.app_name}-gearman-${var.environment}"
        }
      }
      spec {
        container {
          image = var.gearman_image
          name  = "gearman-${var.environment}"
          args  = ["--queue-type=redis", "--redis-server=${var.redis_service_name}", "--redis-port=6379"]
          port {
            container_port = 4730
          }
          resources {
            requests = {
              memory = var.memory_request
              cpu    = var.cpu_request
            }
            limits = {
              memory = var.memory_limit
              cpu    = var.cpu_limit
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gearman" {
  metadata {
    name = "${var.app_name}-gearman-${var.environment}"
  }
  spec {
    selector = {
      App = "${var.app_name}-gearman-${var.environment}"
    }
    port {
      port        = 4730
      target_port = 4730
    }
    type = "ClusterIP"
  }
}