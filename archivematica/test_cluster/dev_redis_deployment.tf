resource "kubernetes_deployment" "archivematica_redis_dev" {
  metadata {
    name = "archivematica-redis-dev"
    labels = {
      App         = "archivematica-dev"
      Environment = "dev"
    }
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "archivematica-redis-dev"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-redis-dev"
        }
      }
      spec {
        container {
          image = "redis:6-alpine"
          name  = "archivematica-redis-dev"
          port {
            container_port = 6379
          }
          resources {
            limits = {
              memory = "512Mi"
              cpu    = "250m"
            }
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
          }
          volume_mount {
            name       = "archivematica-redis-data-dev"
            mount_path = "/data"
          }
        }
        volume {
          name = "archivematica-redis-data-dev"
          persistent_volume_claim {
            claim_name = "archivematica-redis-pvc-dev"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "archivematica_redis_dev" {
  metadata {
    name      = "archivematica-redis-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    selector = {
      App = "archivematica-redis-dev"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "archivematica_redis_pvc_dev" {
  metadata {
    name      = "archivematica-redis-pvc-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }

    storage_class_name = "gp2"
  }
}
