resource "kubernetes_deployment" "archivematica_gearman_prod" {
  metadata {
    name = "archivematica-gearman-prod"
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
        App = "archivematica-gearman-prod"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-gearman-prod"
        }
      }
      spec {
        container {
          image = "artefactual/gearmand:1.1.21.4-alpine"
          name  = "gearman-prod"
          args  = ["--queue-type=redis", "--redis-server=archivematica-redis-prod", "--redis-port=6379"]
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

resource "kubernetes_service" "archivematica_gearman_prod" {
  metadata {
    name      = "archivematica-gearman-prod"
    namespace = kubernetes_namespace.archivematica_prod.metadata[0].name
  }
  spec {
    selector = {
      App = "archivematica-gearman-prod"
    }
    port {
      port        = 4730
      target_port = 4730
    }
    type = "ClusterIP"
  }
}
