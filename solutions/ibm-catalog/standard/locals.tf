# Extract schematics workspace location
locals {
  schematics_ws_location = regex("^[a-z/-]+", var.prerequisite_workspace_id)
  powervs_infrastructure = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
}

# Extract Edge VPC data
locals {
  vsi_list = local.powervs_infrastructure[0].vsi_list.value
  network_services_instance = try(
    [for vsi in local.vsi_list : vsi if can(regex("network-services", vsi.name))][0],
    null
  )
  vpc_name = local.network_services_instance.vpc_name
  vpc_id   = local.network_services_instance.vpc_id

  resource_group_id = var.create_storsight_instance ? data.ibm_is_instance.network_services_instance[0].resource_group : null
  security_group = try(
    [for sg in data.ibm_is_vpc.edge_vpc_data[0].security_group : sg
      if can(regex("network-services-sg", sg.group_name))
    ][0],
    null
  )
  security_group_ids = var.create_storsight_instance ? [local.security_group.group_id] : []
  ssh_key_ids        = var.create_storsight_instance ? [data.ibm_is_instance.network_services_instance[0].keys[0].id] : []
  subnets = var.create_storsight_instance ? [{
    name = data.ibm_is_subnet.network_services_subnet[0].name,
    id   = data.ibm_is_subnet.network_services_subnet[0].id,
    zone = data.ibm_is_subnet.network_services_subnet[0].zone,
    cidr = data.ibm_is_subnet.network_services_subnet[0].ipv4_cidr_block
  }] : []
}

# Extract power virtual server workspace data
locals {
  prefix                 = local.powervs_infrastructure[0].prefix.value
  powervs_workspace_guid = local.powervs_infrastructure[0].powervs_workspace_guid.value
  powervs_workspace_crn  = local.powervs_infrastructure[0].powervs_workspace_id.value
  powervs_workspace_name = local.powervs_infrastructure[0].powervs_workspace_name.value
  powervs_sshkey_name    = local.powervs_infrastructure[0].powervs_ssh_public_key.value.name
  powervs_mgmt_net       = local.powervs_infrastructure[0].powervs_management_subnet.value.name
  powervs_bkp_net        = local.powervs_infrastructure[0].powervs_backup_subnet.value.name
}

# Extract the image id of the pi_instance_boot_image
locals {
  catalog_images = {
    for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images :
    stock_image.name => stock_image.image_id
  }
  pi_image_id = lookup(local.catalog_images, var.pi_instance_boot_image, null)
}

# Extract the placement_group_id and anti-affinity configuration
locals {
  placement_group                = [for x in data.ibm_pi_placement_groups.cloud_instance_groups.placement_groups : x if x.name == var.placement_group]
  placement_group_id             = length(local.placement_group) > 0 ? local.placement_group[0].id : ""
  enable_anti_affinity           = var.pvm_instances != null ? (length(var.pvm_instances) > 0 ? true : false) : false
  enable_existing_subnets_attach = var.existing_powervs_subnets != null ? (length(var.existing_powervs_subnets) > 0 ? true : false) : false
}

# Consolidate subnet list
locals {
  pi_subnet_list = flatten([
    [{
      cidr = data.ibm_pi_network.powervs_management_subnet.cidr
      id   = data.ibm_pi_network.powervs_management_subnet.id,
      ip   = var.management_net_ip != null && var.management_net_ip != "" ? var.management_net_ip : null
      name = data.ibm_pi_network.powervs_management_subnet.pi_network_name,
    }],
    [{
      cidr = data.ibm_pi_network.powervs_backup_subnet.cidr
      id   = data.ibm_pi_network.powervs_backup_subnet.id,
      ip   = var.backup_net_ip != null && var.backup_net_ip != "" ? var.backup_net_ip : null
      name = data.ibm_pi_network.powervs_backup_subnet.pi_network_name,
    }],
    var.private_subnet_3 != null ?
    [{
      cidr = resource.ibm_pi_network.private_subnet_3[0].pi_cidr
      id   = resource.ibm_pi_network.private_subnet_3[0].network_id
      ip   = var.private_subnet_3.ip
      name = resource.ibm_pi_network.private_subnet_3[0].pi_network_name
    }]
    : [],
    var.private_subnet_4 != null ?
    [{
      cidr = resource.ibm_pi_network.private_subnet_4[0].pi_cidr
      id   = resource.ibm_pi_network.private_subnet_4[0].network_id
      ip   = var.private_subnet_4.ip
      name = resource.ibm_pi_network.private_subnet_4[0].pi_network_name
    }]
    : [],
    local.enable_existing_subnets_attach ? [
      for subnet in var.existing_powervs_subnets : {
        id   = data.ibm_pi_network.existing_powervs_subnets[subnet.name].id
        name = subnet.name
        cidr = data.ibm_pi_network.existing_powervs_subnets[subnet.name].cidr
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
