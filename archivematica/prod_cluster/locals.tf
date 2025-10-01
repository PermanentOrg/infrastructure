locals {
  current_archivematica_prod_deploy = data.kubernetes_resource.archivematica_prod.object
  current_mcp_client_prod_deploy    = data.kubernetes_resource.mcp_client_prod.object

  current_containers = concat(
    try(local.current_archivematica_prod_deploy.spec.template.spec.containers),
    try(local.current_mcp_client_prod_deploy.spec.template.spec.containers)
  )

  current_images = { for container in local.current_containers : container.name => container.image }

  desired_images = {
    for name, image in local.current_images :
    name => (contains(keys(var.image_overrides), name)
      ? var.image_overrides[name]
      : local.current_images[name]
    )
  }
}
