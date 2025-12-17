resource "kubernetes_deployment" "archivematica_gearman_staging" {
  metadata {
    name = "archivematica-gearman-staging"
    labels = {
      App         = "archivematica-staging"
      Environment = "staging"
    }
    namespace = kubernetes_namespace.archivematica_staging.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "archivematica-gearman-staging"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-gearman-staging"
        }
      }
      spec {
        container {
          image = "artefactual/gearmand:1.1.21.4-alpine"
          name  = "gearman-staging"
          args  = ["--queue-type=redis", "--redis-server=archivematica-redis-staging", "--redis-port=6379"]
          port {
            container_port = 4730
          }
          resources {
            requests = {
              memory = "256Mi"
              cpu    = "1m"
            }
            limits = {
              memory = "2048Mi"
              cpu    = "1000m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "archivematica_gearman_staging" {
  metadata {
    name      = "archivematica-gearman-staging"
    namespace = kubernetes_namespace.archivematica_staging.metadata[0].name
  }
  spec {
    selector = {
      App = "archivematica-gearman-staging"
    }
    port {
      port        = 4730
      target_port = 4730
    }
    type = "ClusterIP"
  }
}
