# Extract schematics workspace location
locals {
  schematics_ws_location = regex("^[a-z/-]+", var.prerequisite_workspace_id)
  powervs_infrastructure = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
}

# Extract Edge VPC data
locals {
  prefix                     = local.powervs_infrastructure[0].prefix.value
  get_vpc_data               = var.create_storsight_instance || var.create_windows_instance
  vpc_id                     = local.network_services_instance.vpc_id
  vsi_list                   = local.powervs_infrastructure[0].vsi_list.value
  ssh_key_ids                = [local.powervs_infrastructure[0].vsi_ssh_key_data.value[0].id]
  boot_volume_encryption_key = local.powervs_infrastructure[0].kms_key_map.value["slz-vsi-volume-key"].crn
  network_services_instance = try(
    [for vsi in local.vsi_list : vsi if can(regex("network-services", vsi.name))][0],
    null
  )
  resource_group_id = local.powervs_infrastructure[0].resource_group_data.value["${local.prefix}-slz-edge-rg"]
  security_group = try(
    [for sg in local.powervs_infrastructure[0].vpc_data.value[0].vpc_data.security_group : sg
      if can(regex("network-services-sg", sg.group_name))
    ][0],
    null
  )
  security_group_ids = local.get_vpc_data ? [local.security_group.group_id] : []
  network_svc_subnet = [for subnet in local.powervs_infrastructure[0].vpc_data.value[0].subnet_zone_list : subnet
  if can(regex("${local.prefix}-edge-vsi-edge", subnet.name))]
  network_svc_subnet_id = local.network_svc_subnet[0].id
  subnets = local.get_vpc_data ? [{
    name = local.network_svc_subnet[0].name,
    id   = local.network_svc_subnet[0].id,
    zone = local.network_svc_subnet[0].zone,
    cidr = local.network_svc_subnet[0].cidr
  }] : []
}

# Extract power virtual server workspace data
locals {
  powervs_workspace_guid    = local.powervs_infrastructure[0].powervs_workspace_guid.value
  powervs_workspace_crn     = local.powervs_infrastructure[0].powervs_workspace_id.value
  powervs_workspace_name    = local.powervs_infrastructure[0].powervs_workspace_name.value
  powervs_sshkey_name       = local.powervs_infrastructure[0].powervs_ssh_public_key.value.name
  powervs_management_subnet = local.powervs_infrastructure[0].powervs_management_subnet.value
  powervs_backup_subnet     = local.powervs_infrastructure[0].powervs_backup_subnet.value
}

# Extract the image id of the storsafe_instance_boot_image
locals {
  catalog_images = {
    for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images :
    stock_image.name => stock_image.image_id
  }
  pi_image_id = lookup(local.catalog_images, var.storsafe_instance_boot_image, null)
}

# Extract the placement_group_id and anti-affinity configuration
locals {
  placement_group                = [for x in data.ibm_pi_placement_groups.cloud_instance_groups.placement_groups : x if x.name == var.placement_group]
  placement_group_id             = length(local.placement_group) > 0 ? local.placement_group[0].id : ""
  enable_anti_affinity           = try(length(var.pvm_instances), 0) > 0 ? true : false
  enable_existing_subnets_attach = try(length(var.existing_subnets), 0) > 0 ? true : false
}

# VPC instances
locals {
  storsight_instance = var.create_storsight_instance ? {
    "id"           = resource.ibm_is_instance.storsight_instance[0].id
    "ipv4_address" = resource.ibm_is_instance.storsight_instance[0].primary_network_interface[0].primary_ipv4_address
    "name"         = resource.ibm_is_instance.storsight_instance[0].name
    "vpc_id"       = resource.ibm_is_instance.storsight_instance[0].vpc
    "zone"         = resource.ibm_is_instance.storsight_instance[0].zone
  } : {}
  windows_instance = var.create_windows_instance ? {
    "id"           = module.create_windows_instance[0].list[0].id
    "ipv4_address" = module.create_windows_instance[0].list[0].ipv4_address
    "name"         = module.create_windows_instance[0].list[0].name
    "vpc_id"       = module.create_windows_instance[0].list[0].vpc_id
    "zone"         = module.create_windows_instance[0].list[0].zone
  } : {}
}

# Consolidate subnet list
locals {
  pi_subnet_list = flatten([
    [{
      cidr = local.powervs_management_subnet.cidr
      id   = local.powervs_management_subnet.id,
      ip   = var.management_net_ip != null && var.management_net_ip != "" ? var.management_net_ip : null
      name = local.powervs_management_subnet.name,
    }],
    [{
      cidr = local.powervs_backup_subnet.cidr
      id   = local.powervs_backup_subnet.id,
      ip   = var.backup_net_ip != null && var.backup_net_ip != "" ? var.backup_net_ip : null
      name = local.powervs_backup_subnet.name,
    }],
    var.optional_subnet_3 != null ?
    [{
      cidr = resource.ibm_pi_network.optional_subnet_3[0].pi_cidr
      id   = resource.ibm_pi_network.optional_subnet_3[0].network_id
      ip   = var.optional_subnet_3.ip
      name = resource.ibm_pi_network.optional_subnet_3[0].pi_network_name
    }]
    : [],
    var.optional_subnet_4 != null ?
    [{
      cidr = resource.ibm_pi_network.optional_subnet_4[0].pi_cidr
      id   = resource.ibm_pi_network.optional_subnet_4[0].network_id
      ip   = var.optional_subnet_4.ip
      name = resource.ibm_pi_network.optional_subnet_4[0].pi_network_name
    }]
    : [],
    local.enable_existing_subnets_attach ? [
      for subnet in var.existing_subnets : {
        id   = data.ibm_pi_network.existing_subnets[subnet.name].id
        name = subnet.name
        cidr = data.ibm_pi_network.existing_subnets[subnet.name].cidr
        ip   = subnet.ip
      }
    ] : []
  ])
}

# Consolidate volume list
locals {
  volume_map = [resource.ibm_pi_volume.configuration_volume, resource.ibm_pi_volume.index_volume, resource.ibm_pi_volume.tape_volume]
  storsafe_vtl_volume_list = [
    for volume in local.volume_map : {
      volume_id               = volume.volume_id
      volume_io_throttle_rate = volume.io_throttle_rate
      volume_name             = volume.pi_volume_name
      volume_pool             = volume.pi_volume_pool
      volume_size             = volume.pi_volume_size
      volume_type             = volume.pi_volume_type
      volume_status           = volume.volume_status
      volume_wwn              = volume.wwn
    }
  ]
}
