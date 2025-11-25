resource "kubernetes_secret" "prod-archivematica-secrets" {
  metadata {
    name      = "prod-archivematica-secrets"
    namespace = kubernetes_namespace.archivematica_prod.metadata[0].name
  }

  data = {
    "SS_DB_URL"                               = var.prod_ss_database_url
    "AM_SS_PASSWORD"                          = var.prod_ss_password
    "AM_SS_API_KEY"                           = var.prod_ss_api_key
    "ARCHIVEMATICA_DASHBOARD_CLIENT_HOST"     = var.prod_archivematica_dashboard_db_host
    "ARCHIVEMATICA_DASHBOARD_CLIENT_PASSWORD" = var.prod_archivematica_dashboard_db_password
    "DJANGO_SECRET_KEY"                       = var.prod_django_secret_key
    "BACKBLAZE_KEY_ID"                        = var.prod_backblaze_key_id
    "BACKBLAZE_APPLICATION_KEY"               = var.prod_backblaze_application_key
  }
}
