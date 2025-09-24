resource "kubernetes_secret" "archivematica_secrets" {
  metadata {
    name = "dev-archivematica-secrets"
  }

  data = {
    "SS_DB_URL"                               = var.dev_ss_database_url
    "AM_SS_PASSWORD"                          = var.dev_ss_password
    "AM_SS_API_KEY"                           = var.dev_ss_api_key
    "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"     = var.dev_archivematica_dashboard_db_host
    "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD" = var.dev_archivematica_dashboard_db_password
    "DJANGO_SECRET_KEY"                       = var.dev_django_secret_key
    "BACKBLAZE_KEY_ID"                        = var.dev_backblaze_key_id
    "BACKBLAZE_APPLICATION_KEY"               = var.dev_backblaze_application_key
  }
}