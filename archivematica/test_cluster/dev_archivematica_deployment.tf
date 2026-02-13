resource "kubernetes_namespace" "archivematica_dev" {
  metadata {
    name = "archivematica-dev"
  }
}

data "kubernetes_resource" "archivematica_dev" {
  count       = local.need_dev_images ? 1 : 0
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata {
    name = "archivematica-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
}

resource "kubernetes_deployment" "archivematica_dev" {
  metadata {
    name = "archivematica-dev"
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
        App = "archivematica-dev"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-dev"
        }
        annotations = {
          "instrumentation.opentelemetry.io/inject-python" = "false"
        }
      }
      spec {
        security_context {
          fs_group               = 1000
          fs_group_change_policy = "OnRootMismatch"
        }
        container {
          image = local.desired_images["archivematica-storage-service-dev"]
          name  = "archivematica-storage-service-dev"
          env {
            name  = "SS_GUNICORN_BIND"
            value = "0.0.0.0:8002"
          }
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "archivematica.storage_service.storage_service.settings.production"
          }
          env {
            name  = "FORWARDED_ALLOW_IPS"
            value = "*"
          }
          env {
            name  = "SS_GNUPG_HOME_PATH"
            value = "/var/archivematica/storage_service/.gnupg"
          }
          env {
            name  = "SS_GUNICORN_ACCESSLOG"
            value = "/dev/null"
          }
          env {
            name  = "SS_GUNICORN_RELOAD"
            value = "true"
          }
          env {
            name  = "SS_GUNICORN_RELOAD_ENGINE"
            value = "auto"
          }
          env {
            name = "SS_DB_URL"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "SS_DB_URL"
                optional = false
              }
            }
          }
          env {
            name  = "SS_GUNICORN_LOGLEVEL"
            value = "debug"
          }
          env {
            name  = "SS_GUNICORN_WORKERS"
            value = "3"
          }
          env {
            name  = "RCLONE_CONFIG"
            value = "/var/archivematica/storage_service/.rclone.conf"
          }
          env {
            name  = "DJANGO_ALLOWED_HOSTS"
            value = "*"
          }
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "DJANGO_SECRET_KEY"
                optional = false
              }
            }
          }
          port {
            container_port = 8002
          }
          volume_mount {
            mount_path = "/var/archivematica/sharedDirectory"
            name       = "dev-pipeline-data"
          }
          volume_mount {
            mount_path = "/var/archivematica/storage_service"
            name       = "dev-staging-data"
          }
          volume_mount {
            mount_path = "/home"
            name       = "dev-location-data"
            sub_path   = "sips"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "dev-transfer-share"
          }
          volume_mount {
            mount_path = "/data/storage"
            name       = "dev-storage-share"
          }
        }
        container {
          image = local.desired_images["archivematica-dashboard-dev"]
          name  = "archivematica-dashboard-dev"
          env {
            name  = "AM_GUNICORN_BIND"
            value = "0.0.0.0:8001"
          }
          env {
            name  = "DJANGO_SETTINGS_MODULES"
            value = "settings.production"
          }
          env {
            name  = "FORWARDED_ALLOW_IPS"
            value = "*"
          }
          env {
            name  = "AM_GUNICORN_ACCESSLOG"
            value = "/dev/null"
          }
          env {
            name  = "AM_GUNICORN_RELOAD"
            value = "true"
          }
          env {
            name  = "AM_GUNICORN_RELOAD_ENGINE"
            value = "auto"
          }
          env {
            name  = "AM_GUNICORN_LOGLEVEL"
            value = "debug"
          }
          env {
            name  = "AM_GUNICORN_WORKERS"
            value = "1"
          }
          env {
            name  = "AM_GUNICORN_PROC_NAME"
            value = "archivematica-dashboard"
          }
          env {
            name  = "AM_GUNICORN_CHDIR"
            value = "/src/src/archivematica/archivematicaCommon"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_EMAIL_PORT"
            value = "587"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_CLIENT_PORT"
            value = "3306"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_CLIENT_DATABASE"
            value = "MCP"
          }
          env {
            name = "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_CLIENT_USER"
            value = "archivematica"
          }
          env {
            name = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_GEARMAN_SERVER"
            value = "archivematica-gearman-dev:4730"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_DJANGO_ALLOWED_HOSTS"
            value = "dev.archivematica.permanent.org"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_SEARCH_ENABLED"
            value = "false"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_STORAGE_SERVICE_CLIENT_QUICK_TIMEOUT"
            value = "20"
          }
          env {
            name = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "DJANGO_SECRET_KEY"
                optional = false
              }
            }
          }
          port {
            container_port = 8001
          }
          volume_mount {
            mount_path = "/var/archivematica/sharedDirectory"
            name       = "dev-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "dev-transfer-share"
          }
        }
        container {
          image = local.desired_images["archivematica-mcp-server-dev"]
          name  = "archivematica-mcp-server-dev"
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "DJANGO_SECRET_KEY"
                optional = false
              }
            }
          }
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "archivematica.MCPServer.settings.common"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_CLIENT_USER"
            value = "archivematica"
          }
          env {
            name = "ARCHIVEMATICA_MCPSERVER_CLIENT_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "ARCHIVEMATICA_MCPSERVER_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_CLIENT_DATABASE"
            value = "MCP"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_MCPSERVER_MCPARCHIVEMATICASERVER"
            value = "archivematica-gearman-dev:4730"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_SEARCH_ENABLED"
            value = "false"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_MCPSERVER_RPC_THREADS"
            value = "8"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_MCPSERVER_WORKER_THREADS"
            value = "1"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_MCPSERVER_CONCURRENT_PACKAGES"
            value = "100"
          }
          resources {
            requests = {
              memory = "256Mi"
              cpu    = "1m"
            }
            limits = {
              memory = "2048Mi"
              cpu    = "333m"
            }
          }
          volume_mount {
            mount_path = "/var/archivematica/sharedDirectory"
            name       = "dev-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "dev-transfer-share"
          }
        }
        init_container {
          image   = local.desired_images["archivematica-storage-service-dev"]
          name    = "archivematica-storage-service-migrations"
          command = ["sh"]
          args    = ["-c", "python -m archivematica.storage_service.manage migrate --noinput"]
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "archivematica.storage_service.storage_service.settings.local"
          }
          env {
            name  = "FORWARDED_ALLOW_IPS"
            value = "*"
          }
          env {
            name  = "SS_GNUPG_HOME_PATH"
            value = "/var/archivematica/storage_service/.gnupg"
          }
          env {
            name  = "SS_GUNICORN_ACCESSLOG"
            value = "/dev/null"
          }
          env {
            name  = "SS_GUNICORN_RELOAD"
            value = "true"
          }
          env {
            name  = "SS_GUNICORN_RELOAD_ENGINE"
            value = "auto"
          }
          env {
            name = "SS_DB_URL"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "SS_DB_URL"
                optional = false
              }
            }
          }
        }
        init_container {
          image = local.desired_images["archivematica-storage-service-dev"]
          name  = "archivematica-storage-service-create-user"
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "archivematica.storage_service.storage_service.settings.local"
          }
          env {
            name  = "FORWARDED_ALLOW_IPS"
            value = "*"
          }
          env {
            name  = "SS_GNUPG_HOME_PATH"
            value = "/var/archivematica/storage_service/.gnupg"
          }
          env {
            name  = "SS_GUNICORN_ACCESSLOG"
            value = "/dev/null"
          }
          env {
            name  = "SS_GUNICORN_RELOAD"
            value = "true"
          }
          env {
            name  = "SS_GUNICORN_RELOAD_ENGINE"
            value = "auto"
          }
          env {
            name = "SS_DB_URL"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "SS_DB_URL"
                optional = false
              }
            }
          }
          env {
            name  = "AM_SS_USERNAME"
            value = "admin"
          }
          env {
            name  = "AM_SS_EMAIL"
            value = "engineers@permanent.org"
          }
          env {
            name = "AM_SS_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "AM_SS_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "AM_SS_API_KEY"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "AM_SS_API_KEY"
                optional = false
              }
            }
          }
          command = ["sh"]
          args    = ["-c", "python -m archivematica.storage_service.manage create_user --username=$(AM_SS_USERNAME) --password='$(AM_SS_PASSWORD)' --email=$(AM_SS_EMAIL) --api-key=$(AM_SS_API_KEY) --superuser"]
        }
        init_container {
          image   = local.desired_images["archivematica-dashboard-dev"]
          name    = "archivematica-dashboard-migration"
          command = ["sh"]
          args    = ["-c", "python /src/src/archivematica/dashboard/manage.py migrate --noinput"]
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "settings.local"
          }
          env {
            name  = "FORWARDED_ALLOW_IPS"
            value = "*"
          }
          env {
            name  = "AM_GUNICORN_ACCESSLOG"
            value = "/dev/null"
          }
          env {
            name  = "AM_GUNICORN_RELOAD"
            value = "true"
          }
          env {
            name  = "AM_GUNICORN_RELOAD_ENGINE"
            value = "auto"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_EMAIL_PORT"
            value = "587"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_CLIENT_PORT"
            value = "3306"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_CLIENT_DATABASE"
            value = "MCP"
          }
          env {
            name = "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_CLIENT_USER"
            value = "archivematica"
          }
          env {
            name = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
        }
        init_container {
          image   = local.desired_images["archivematica-storage-service-dev"]
          name    = "archivematica-rclone-configuration"
          command = ["sh"]
          args    = ["-c", "rclone config create permanentb2 b2 account $(BACKBLAZE_KEY_ID) key $(BACKBLAZE_APPLICATION_KEY) --obscure"]
          env {
            name = "BACKBLAZE_KEY_ID"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "BACKBLAZE_KEY_ID"
                optional = false
              }
            }
          }
          env {
            name = "BACKBLAZE_APPLICATION_KEY"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "BACKBLAZE_APPLICATION_KEY"
                optional = false
              }
            }
          }
          env {
            name  = "RCLONE_CONFIG"
            value = "/var/archivematica/storage_service/.rclone.conf"
          }
          volume_mount {
            mount_path = "/var/archivematica/storage_service"
            name       = "dev-staging-data"
          }
        }
        volume {
          name = "dev-pipeline-data"
          persistent_volume_claim {
            claim_name = "dev-pipeline-data"
          }
        }
        volume {
          name = "dev-staging-data"
          persistent_volume_claim {
            claim_name = "dev-staging-data"
          }
        }
        volume {
          name = "dev-location-data"
          persistent_volume_claim {
            claim_name = "dev-location-data"
          }
        }
        volume {
          name = "dev-transfer-share"
          persistent_volume_claim {
            claim_name = "dev-transfer-share"
          }
        }
        volume {
          name = "dev-storage-share"
          persistent_volume_claim {
            claim_name = "dev-storage-share"
          }
        }
      }
    }
  }
}

data "kubernetes_resource" "mcp_client_dev" {
  count       = local.need_dev_images ? 1 : 0
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata {
    name = "archivematica-mcp-client-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
}

resource "kubernetes_deployment" "mcp_client_dev" {
  metadata {
    name = "archivematica-mcp-client-dev"
    labels = {
      App         = "archivematica-dev"
      Environment = "dev"
    }
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    replicas = 4
    selector {
      match_labels = {
        App = "archivematica-mcp-client-dev"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-mcp-client-dev"
        }
        annotations = {
          "instrumentation.opentelemetry.io/inject-python" = "false"
        }
      }
      spec {
        container {
          image = local.desired_images["archivematica-mcp-client-dev"]
          name  = "archivematica-mcp-client-dev"
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "DJANGO_SECRET_KEY"
                optional = false
              }
            }
          }
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "archivematica.MCPClient.settings.common"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_EMAIL_BACKEND"
            value = "django.core.mail.backends.smtp.EmailBackend"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_EMAIL_HOST"
            value = "smtp.sendgrid.net"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_EMAIL_PORT"
            value = "587"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_CLIENT_USER"
            value = "archivematica"
          }
          env {
            name = "ARCHIVEMATICA_MCPCLIENT_CLIENT_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "ARCHIVEMATICA_MCPCLIENT_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "dev-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_CLIENT_DATABASE"
            value = "MCP"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_MCPARCHIVEMATICASERVER"
            value = "archivematica-gearman-dev:4730"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_SEARCH_ENABLED"
            value = "false"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_CAPTURE_CLIENT_SCRIPT_OUTPUT"
            value = "true"
          }
          env {
            name  = "ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_STORAGE_SERVICE_CLIENT_QUICK_TIMEOUT"
            value = "20"
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
          volume_mount {
            mount_path = "/var/archivematica/sharedDirectory"
            name       = "dev-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "dev-transfer-share"
          }
        }
        volume {
          name = "dev-pipeline-data"
          persistent_volume_claim {
            claim_name = "dev-pipeline-data"
          }
        }
        volume {
          name = "dev-transfer-share"
          persistent_volume_claim {
            claim_name = "dev-transfer-share"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "archivematica_dashboard_service_dev" {
  metadata {
    name      = "archivematica-dashboard-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = "archivematica-dev"
    }
    port {
      port        = 8001
      target_port = 8001
    }
  }
}

resource "kubernetes_service" "archivematica_storage_service_dev" {
  metadata {
    name      = "archivematica-storage-dev"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = "archivematica-dev"
    }
    port {
      port        = 8002
      target_port = 8002
    }
  }
}

resource "kubernetes_persistent_volume_claim" "archivematica_dev_pipeline_data_pvc" {
  metadata {
    name      = "dev-pipeline-data"
    namespace = kubernetes_namespace.archivematica_dev.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "16Gi"
      }
    }

    storage_class_name = "gp3"
  }
}

resource "kubernetes_persistent_volume_claim" "archivematica_dev_staging_data_pvc" {
  metadata {
    name      = "dev-staging-data"
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

resource "kubernetes_persistent_volume_claim" "archivematica_dev_location_data_pvc" {
  metadata {
    name      = "dev-location-data"
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

resource "kubernetes_persistent_volume_claim" "archivematica_dev_transfer_share_pvc" {
  metadata {
    name      = "dev-transfer-share"
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

resource "kubernetes_persistent_volume_claim" "archivematica_dev_storage_share_pvc" {
  metadata {
    name      = "dev-storage-share"
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
