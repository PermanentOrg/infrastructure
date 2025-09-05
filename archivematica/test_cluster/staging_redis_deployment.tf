resource "kubernetes_deployment" "archivematica_redis_staging" {
  metadata {
    name = "archivematica-redis-staging"
    labels = {
      App         = "archivematica-staging"
      Environment = "staging"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "archivematica-redis-staging"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-redis-staging"
        }
      }
      spec {
        container {
          image = "redis:6-alpine"
          name  = "archivematica-redis-staging"
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
            name       = "archivematica-redis-data-staging"
            mount_path = "/data"
          }
        }
        volume {
          name = "archivematica-redis-data-staging"
          persistent_volume_claim {
            claim_name = "archivematica-redis-pvc-staging"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "archivematica_redis_staging" {
  metadata {
    name = "archivematica-redis-staging"
  }
  spec {
    selector = {
      App = "archivematica-redis-staging"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "archivematica_redis_pvc_staging" {
  metadata {
    name = "archivematica-redis-pvc-staging"
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
