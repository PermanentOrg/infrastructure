locals {
  required_dev_images = [
    "archivematica-storage-service-dev",
    "archivematica-dashboard-dev",
    "archivematica-mcp-server-dev",
    "archivematica-mcp-client-dev",
  ]

  required_staging_images = [
    "archivematica-storage-service-staging",
    "archivematica-dashboard-staging",
    "archivematica-mcp-server-staging",
    "archivematica-mcp-client-staging",
  ]

  need_dev_images     = length(setsubtract(local.required_dev_images, keys(var.image_overrides))) > 0
  need_staging_images = length(setsubtract(local.required_staging_images, keys(var.image_overrides))) > 0

  current_images = merge(
    try({ for container in data.kubernetes_resource.archivematica_dev[0].object.spec.template.spec.containers : container.name => container.image }, {}),
    try({ for container in data.kubernetes_resource.mcp_client_dev[0].object.spec.template.spec.containers : container.name => container.image }, {}),
    try({ for container in data.kubernetes_resource.archivematica_staging[0].object.spec.template.spec.containers : container.name => container.image }, {}),
    try({ for container in data.kubernetes_resource.mcp_client_staging[0].object.spec.template.spec.containers : container.name => container.image }, {}),
  )

  desired_images = merge(local.current_images, var.image_overrides)
}
