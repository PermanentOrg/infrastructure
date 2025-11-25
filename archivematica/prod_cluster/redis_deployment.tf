resource "kubernetes_deployment" "archivematica_redis_prod" {
  metadata {
    name = "archivematica-redis-prod"
    labels = {
      App         = "archivematica-prod"
      Environment = "prod"
    }
    namespace = kubernetes_namespace.archivematica_prod.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "archivematica-redis-prod"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-redis-prod"
        }
      }
      spec {
        container {
          image = "redis:6-alpine"
          name  = "archivematica-redis-prod"
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
            name       = "archivematica-redis-data-prod"
            mount_path = "/data"
          }
        }
        volume {
          name = "archivematica-redis-data-prod"
          persistent_volume_claim {
            claim_name = "archivematica-redis-pvc-prod"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "archivematica_redis_prod" {
  metadata {
    name      = "archivematica-redis-prod"
    namespace = kubernetes_namespace.archivematica_prod.metadata[0].name
  }
  spec {
    selector = {
      App = "archivematica-redis-prod"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "archivematica_redis_pvc_prod" {
  metadata {
    name      = "archivematica-redis-pvc-prod"
    namespace = kubernetes_namespace.archivematica_prod.metadata[0].name
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
