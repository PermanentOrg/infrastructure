resource "kubernetes_deployment" "redis" {
  metadata {
    name = "${var.app_name}-redis-${var.environment}"
    labels = {
      App         = "${var.app_name}-${var.environment}"
      Environment = var.environment
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        App = "${var.app_name}-redis-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.app_name}-redis-${var.environment}"
        }
      }
      spec {
        container {
          image = var.redis_image
          name  = "${var.app_name}-redis-${var.environment}"
          port {
            container_port = 6379
          }
          resources {
            limits = {
              memory = var.memory_limit
              cpu    = var.cpu_limit
            }
            requests = {
              memory = var.memory_request
              cpu    = var.cpu_request
            }
          }
          volume_mount {
            name       = "${var.app_name}-redis-data-${var.environment}"
            mount_path = "/data"
          }
        }
        volume {
          name = "${var.app_name}-redis-data-${var.environment}"
          persistent_volume_claim {
            claim_name = "${var.app_name}-redis-pvc-${var.environment}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "${var.app_name}-redis-${var.environment}"
  }
  spec {
    selector = {
      App = "${var.app_name}-redis-${var.environment}"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "redis" {
  metadata {
    name = "${var.app_name}-redis-pvc-${var.environment}"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    storage_class_name = var.storage_class
  }
}