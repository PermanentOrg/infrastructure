# Data source for existing deployment (for image management)
data "kubernetes_resource" "archivematica_deployment" {
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata { name = "${var.app_name}-${var.environment}" }
}

# Main Archivematica deployment (storage service, dashboard, mcp server)
resource "kubernetes_deployment" "archivematica" {
  metadata {
    name = "${var.app_name}-${var.environment}"
    labels = {
      App         = "${var.app_name}-${var.environment}"
      Environment = var.environment
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        App = "${var.app_name}-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.app_name}-${var.environment}"
        }
      }
      spec {
        security_context {
          fs_group               = 1000
          fs_group_change_policy = "OnRootMismatch"
        }

        # Storage Service Container
        container {
          image = var.storage_service_image
          name  = "${var.app_name}-storage-service-${var.environment}"
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
                name     = "${var.environment}-archivematica-secrets"
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
            value = var.allowed_hosts
          }
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
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
            name       = "${var.environment}-pipeline-data"
          }
          volume_mount {
            mount_path = "/var/archivematica/storage_service"
            name       = "${var.environment}-staging-data"
          }
          volume_mount {
            mount_path = "/home"
            name       = "${var.environment}-location-data"
            sub_path   = "sips"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "${var.environment}-transfer-share"
          }
          volume_mount {
            mount_path = "/data/storage"
            name       = "${var.environment}-storage-share"
          }
        }

        # Dashboard Container
        container {
          image = var.dashboard_image
          name  = "${var.app_name}-dashboard-${var.environment}"
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
                name     = "${var.environment}-archivematica-secrets"
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
                name     = "${var.environment}-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_GEARMAN_SERVER"
            value = "${var.gearman_service_name}:4730"
          }
          env {
            name  = "ARCHIVEMATICA_DASHBOARD_DASHBOARD_DJANGO_ALLOWED_HOSTS"
            value = var.allowed_hosts
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
                name     = "${var.environment}-archivematica-secrets"
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
            name       = "${var.environment}-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "${var.environment}-transfer-share"
          }
        }

        # MCP Server Container
        container {
          image = var.mcp_server_image
          name  = "${var.app_name}-mcp-server-${var.environment}"
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
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
                name     = "${var.environment}-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "ARCHIVEMATICA_MCPSERVER_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
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
            value = "${var.gearman_service_name}:4730"
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
              memory = var.mcp_server_memory_request
              cpu    = var.mcp_server_cpu_request
            }
            limits = {
              memory = var.mcp_server_memory_limit
              cpu    = var.mcp_server_cpu_limit
            }
          }
          volume_mount {
            mount_path = "/var/archivematica/sharedDirectory"
            name       = "${var.environment}-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "${var.environment}-transfer-share"
          }
        }

        # Init Containers
        init_container {
          image   = var.storage_service_image
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
                name     = "${var.environment}-archivematica-secrets"
                key      = "SS_DB_URL"
                optional = false
              }
            }
          }
        }

        init_container {
          image   = var.storage_service_image
          name    = "archivematica-storage-service-create-user"
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
                name     = "${var.environment}-archivematica-secrets"
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
                name     = "${var.environment}-archivematica-secrets"
                key      = "AM_SS_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "AM_SS_API_KEY"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
                key      = "AM_SS_API_KEY"
                optional = false
              }
            }
          }
          command = ["sh"]
          args    = ["-c", "python manage.py create_user --username=$(AM_SS_USERNAME) --password='$(AM_SS_PASSWORD)' --email=$(AM_SS_EMAIL) --api-key=$(AM_SS_API_KEY) --superuser"]
        }

        init_container {
          image   = var.dashboard_image
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
                name     = "${var.environment}-archivematica-secrets"
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
                name     = "${var.environment}-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
        }

        init_container {
          image   = var.storage_service_image
          name    = "archivematica-rclone-configuration"
          command = ["sh"]
          args    = ["-c", "rclone config create permanentb2 b2 account $(BACKBLAZE_KEY_ID) key $(BACKBLAZE_APPLICATION_KEY) --obscure"]
          env {
            name = "BACKBLAZE_KEY_ID"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
                key      = "BACKBLAZE_KEY_ID"
                optional = false
              }
            }
          }
          env {
            name = "BACKBLAZE_APPLICATION_KEY"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
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
            name       = "${var.environment}-staging-data"
          }
        }

        # Volumes
        volume {
          name = "${var.environment}-pipeline-data"
          persistent_volume_claim {
            claim_name = "${var.environment}-pipeline-data"
          }
        }
        volume {
          name = "${var.environment}-staging-data"
          persistent_volume_claim {
            claim_name = "${var.environment}-staging-data"
          }
        }
        volume {
          name = "${var.environment}-location-data"
          persistent_volume_claim {
            claim_name = "${var.environment}-location-data"
          }
        }
        volume {
          name = "${var.environment}-transfer-share"
          persistent_volume_claim {
            claim_name = "${var.environment}-transfer-share"
          }
        }
        volume {
          name = "${var.environment}-storage-share"
          persistent_volume_claim {
            claim_name = "${var.environment}-storage-share"
          }
        }
      }
    }
  }
}

# Data source for existing MCP client deployment
data "kubernetes_resource" "mcp_client" {
  kind        = "Deployment"
  api_version = "apps/v1"
  metadata { name = "${var.app_name}-mcp-client-${var.environment}" }
}

# MCP Client deployment
resource "kubernetes_deployment" "mcp_client" {
  metadata {
    name = "${var.app_name}-mcp-client-${var.environment}"
    labels = {
      App         = "${var.app_name}-${var.environment}"
      Environment = var.environment
    }
  }
  spec {
    replicas = var.mcp_client_replicas
    selector {
      match_labels = {
        App = "${var.app_name}-mcp-client-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.app_name}-mcp-client-${var.environment}"
        }
      }
      spec {
        container {
          image = var.mcp_client_image
          name  = "${var.app_name}-mcp-client-${var.environment}"
          env {
            name = "DJANGO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
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
                name     = "${var.environment}-archivematica-secrets"
                key      = "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD"
                optional = false
              }
            }
          }
          env {
            name = "ARCHIVEMATICA_MCPCLIENT_CLIENT_HOST"
            value_from {
              secret_key_ref {
                name     = "${var.environment}-archivematica-secrets"
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
            value = "${var.gearman_service_name}:4730"
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
              memory = var.mcp_client_memory_request
              cpu    = var.mcp_client_cpu_request
            }
            limits = {
              memory = var.mcp_client_memory_limit
              cpu    = var.mcp_client_cpu_limit
            }
          }
          volume_mount {
            mount_path = "/var/archivematica/sharedDirectory"
            name       = "${var.environment}-pipeline-data"
          }
          volume_mount {
            mount_path = "/home/transfer"
            name       = "${var.environment}-transfer-share"
          }
        }
        volume {
          name = "${var.environment}-pipeline-data"
          persistent_volume_claim {
            claim_name = "${var.environment}-pipeline-data"
          }
        }
        volume {
          name = "${var.environment}-transfer-share"
          persistent_volume_claim {
            claim_name = "${var.environment}-transfer-share"
          }
        }
      }
    }
  }
}

# Services
resource "kubernetes_service" "dashboard" {
  metadata {
    name = "${var.app_name}-dashboard-${var.environment}"
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = "${var.app_name}-${var.environment}"
    }
    port {
      port        = 8001
      target_port = 8001
    }
  }
}

resource "kubernetes_service" "storage" {
  metadata {
    name = "${var.app_name}-storage-${var.environment}"
  }
  spec {
    type = "ClusterIP"
    selector = {
      App = "${var.app_name}-${var.environment}"
    }
    port {
      port        = 8002
      target_port = 8002
    }
  }
}

# Persistent Volume Claims
resource "kubernetes_persistent_volume_claim" "pipeline_data" {
  metadata {
    name = "${var.environment}-pipeline-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.pipeline_data_storage
      }
    }
    storage_class_name = var.storage_class
  }
}

resource "kubernetes_persistent_volume_claim" "staging_data" {
  metadata {
    name = "${var.environment}-staging-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.staging_data_storage
      }
    }
    storage_class_name = var.storage_class
  }
}

resource "kubernetes_persistent_volume_claim" "location_data" {
  metadata {
    name = "${var.environment}-location-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.location_data_storage
      }
    }
    storage_class_name = var.storage_class
  }
}

resource "kubernetes_persistent_volume_claim" "transfer_share" {
  metadata {
    name = "${var.environment}-transfer-share"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.transfer_share_storage
      }
    }
    storage_class_name = var.storage_class
  }
}

resource "kubernetes_persistent_volume_claim" "storage_share" {
  metadata {
    name = "${var.environment}-storage-share"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_share_storage
      }
    }
    storage_class_name = var.storage_class
  }
}