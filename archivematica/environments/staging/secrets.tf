resource "kubernetes_secret" "archivematica_secrets" {
  metadata {
    name = "staging-archivematica-secrets"
  }

  data = {
    "SS_DB_URL"                               = var.staging_ss_database_url
    "AM_SS_PASSWORD"                          = var.staging_ss_password
    "AM_SS_API_KEY"                           = var.staging_ss_api_key
    "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"     = var.staging_archivematica_dashboard_db_host
    "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD" = var.staging_archivematica_dashboard_db_password
    "DJANGO_SECRET_KEY"                       = var.staging_django_secret_key
    "BACKBLAZE_KEY_ID"                        = var.staging_backblaze_key_id
    "BACKBLAZE_APPLICATION_KEY"               = var.staging_backblaze_application_key
  }
}