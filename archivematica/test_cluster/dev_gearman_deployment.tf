resource "kubernetes_deployment" "archivematica_gearman_dev" {
  metadata {
    name = "archivematica-gearman-dev"
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
        App = "archivematica-gearman-dev"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-gearman-dev"
        }
      }
      spec {
        container {
          image = "artefactual/gearmand:1.1.21.4-alpine"
          name  = "gearman-dev"
          args  = ["--queue-type=redis", "--redis-server=archivematica-redis-dev", "--redis-port=6379"]
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

resource "kubernetes_service" "archivematica_gearman_dev" {
  metadata {
    name      = "archivematica-gearman-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    selector = {
      App = "archivematica-gearman-dev"
    }
    port {
      port        = 4730
      target_port = 4730
    }
    type = "ClusterIP"
  }
}
