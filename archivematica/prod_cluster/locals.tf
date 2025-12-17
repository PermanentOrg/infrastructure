locals {
  required_images = [
    "archivematica-storage-service-prod",
    "archivematica-dashboard-prod",
    "archivematica-mcp-server-prod",
    "archivematica-mcp-client-prod",
  ]

  need_images = length(setsubtract(local.required_images, keys(var.image_overrides))) > 0
  current_archivematica_prod_deploy = data.kubernetes_resource.archivematica_prod.object
  current_mcp_client_prod_deploy    = data.kubernetes_resource.mcp_client_prod.object

  current_images = merge(
    try(for container in data.kubernetes_resource.archivematica_prod[0].object.spec.template.spec.containers : container.name => container.image }, {}),
    try(for container in data.kubernetes_resource.mcp_client_prod[0].object.spec.template.spec.containers : container.name => container.image }, {}),
  )

  desired_images = merge(local.current_images, var.image_overrides)
}
