data "kubernetes_resource" "archivematica_staging" {
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata { name = "archivematica-staging" }
}

resource "kubernetes_deployment" "archivematica_staging" {
  metadata {
    name = "archivematica-staging"
    labels = {
      App         = "archivematica-staging"
      Environment = "staging"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "archivematica-staging"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-staging"
        }
      }
      spec {
        security_context {
          fs_group               = 1000
          fs_group_change_policy = "OnRootMismatch"
        }
        container {
          image = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:storage-service-main-30826d7"
          name  = "archivematica-storage-service-staging"
          env {
            name  = "SS_GUNICORN_BIND"
            value = "0.0.0.0:8002"
          }
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "storage_service.settings.production"
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
                name     = "staging-archivematica-secrets"
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
            value = "staging.archivematica.permanent.org"
          }
          env {
            name  = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
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
            name       = "staging-pipeline-data"
          }
          volume_mount {
            mount_path = "/var/archivematica/storage_service"
            name       = "staging-staging-data"
          }
          volume_mount {
            mount_path = "/home"
            name       = "staging-location-data"
            sub_path   = "sips"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "staging-transfer-share"
          }
          volume_mount {
            mount_path = "/data/storage"
            name       = "staging-storage-share"
          }
        }
        container {
          image = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:dashboard-main-0025af3"
          name  = "archivematica-dashboard-staging"
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
            value = "/src/src/archivematicaCommon/lib/"
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
                name     = "staging-archivematica-secrets"
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
                name     = "staging-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_GEARMAN_SERVER"
            value = "archivematica-gearman-staging:4730"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_DJANGO_ALLOWED_HOSTS"
            value = "staging.archivematica.permanent.org"
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
                name     = "staging-archivematica-secrets"
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
            name       = "staging-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "staging-transfer-share"
          }
        }
        container {
          image = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:mcp-server-main-0025af3"
          name  = "archivematica-mcp-server-staging"
          env {
            name  = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
                key      = "DJANGO_SECRET_KEY"
                optional = false
              }
            }
          }
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "settings.common"
          }
          env {
            name  = "ARCHIVEMATICA_MCPSERVER_CLIENT_USER"
            value = "archivematica"
          }
          env {
            name = "ARCHIVEMATICA_MCPSERVER_CLIENT_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "ARCHIVEMATICA_MCPSERVER_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
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
            value = "archivematica-gearman-staging:4730"
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
            name       = "staging-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "staging-transfer-share"
          }
        }
        init_container {
          image   = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:storage-service-main-30826d7"
          name    = "archivematica-storage-service-migrations"
          command = ["sh"]
          args    = ["-c", "python manage.py migrate --noinput"]
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "storage_service.settings.local"
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
            value = "/staging/null"
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
                name     = "staging-archivematica-secrets"
                key      = "SS_DB_URL"
                optional = false
              }
            }
          }
        }
        init_container {
          image   = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:storage-service-main-30826d7"
          name  = "archivematica-storage-service-create-user"
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "storage_service.settings.local"
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
                name     = "staging-archivematica-secrets"
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
                name     = "staging-archivematica-secrets"
                key      = "AM_SS_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "AM_SS_API_KEY"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
                key      = "AM_SS_API_KEY"
                optional = false
              }
            }
          }
          command = ["sh"]
          args    = ["-c", "python manage.py create_user --username=$(AM_SS_USERNAME) --password='$(AM_SS_PASSWORD)' --email=$(AM_SS_EMAIL) --api-key='$(AM_SS_API_KEY)' --superuser"]
        }
        init_container {
          image   = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:dashboard-main-0025af3"
          name    = "archivematica-dashboard-migration"
          command = ["sh"]
          args    = ["-c", "python /src/src/dashboard/src/manage.py migrate --noinput"]
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
                name     = "staging-archivematica-secrets"
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
                name     = "staging-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
        }
        init_container {
          image   = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:storage-service-main-30826d7"
          name    = "archivematica-rclone-configuration"
          command = ["sh"]
          args    = ["-c", "rclone config create permanentb2 b2 account $(BACKBLAZE_KEY_ID) key $(BACKBLAZE_APPLICATION_KEY) --obscure"]
          env {
            name = "BACKBLAZE_KEY_ID"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
                key      = "BACKBLAZE_KEY_ID"
                optional = false
              }
            }
          }
          env {
            name = "BACKBLAZE_APPLICATION_KEY"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
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
            name       = "staging-staging-data"
          }
        }
        volume {
          name = "staging-pipeline-data"
          persistent_volume_claim {
            claim_name = "staging-pipeline-data"
          }
        }
        volume {
          name = "staging-staging-data"
          persistent_volume_claim {
            claim_name = "staging-staging-data"
          }
        }
        volume {
          name = "staging-location-data"
          persistent_volume_claim {
            claim_name = "staging-location-data"
          }
        }
        volume {
          name = "staging-transfer-share"
          persistent_volume_claim {
            claim_name = "staging-transfer-share"
          }
        }
        volume {
          name = "staging-storage-share"
          persistent_volume_claim {
            claim_name = "staging-storage-share"
          }
        }
      }
    }
  }
}

data "kubernetes_resource" "mcp_client_staging" {
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata { name = "archivematica-mcp-client-staging" }
}

resource "kubernetes_deployment" "mcp_client_staging" {
  metadata {
    name = "archivematica-mcp-client-staging"
    labels = {
      App         = "archivematica-staging"
      Environment = "staging"
    }
  }
  spec {
    replicas = 4
    selector {
      match_labels = {
        App = "archivematica-mcp-client-staging"
      }
    }
    template {
      metadata {
        labels = {
          App = "archivematica-mcp-client-staging"
        }
      }
      spec {
        container {
          image = "364159549467.dkr.ecr.us-west-2.amazonaws.com/archivematica:mcp-client-main-0025af3"
          name  = "archivematica-mcp-client-staging"
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
                key      = "DJANGO_SECRET_KEY"
                optional = false
              }
            }
          }
          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "settings.common"
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
                name     = "staging-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "ARCHIVEMATICA_MCPCLIENT_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "staging-archivematica-secrets"
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
            value = "archivematica-gearman-staging:4730"
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
            name       = "staging-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "staging-transfer-share"
          }
        }
        volume {
          name = "staging-pipeline-data"
          persistent_volume_claim {
            claim_name = "staging-pipeline-data"
          }
        }
        volume {
          name = "staging-transfer-share"
          persistent_volume_claim {
            claim_name = "staging-transfer-share"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "archivematica_dashboard_service_staging" {
  metadata {
    name = "archivematica-dashboard-staging"
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = "archivematica-staging"
    }
    port {
      port        = 8001
      target_port = 8001
    }
  }
}

resource "kubernetes_service" "archivematica_storage_service_staging" {
  metadata {
    name = "archivematica-storage-staging"
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = "archivematica-staging"
    }
    port {
      port        = 8002
      target_port = 8002
    }
  }
}

resource "kubernetes_persistent_volume_claim" "archivematica_staging_pipeline_data_pvc" {
  metadata {
    name = "staging-pipeline-data"
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

resource "kubernetes_persistent_volume_claim" "archivematica_staging_staging_data_pvc" {
  metadata {
    name = "staging-staging-data"
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

resource "kubernetes_persistent_volume_claim" "archivematica_staging_location_data_pvc" {
  metadata {
    name = "staging-location-data"
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

resource "kubernetes_persistent_volume_claim" "archivematica_staging_transfer_share_pvc" {
  metadata {
    name = "staging-transfer-share"
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

resource "kubernetes_persistent_volume_claim" "archivematica_staging_storage_share_pvc" {
  metadata {
    name = "staging-storage-share"
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
