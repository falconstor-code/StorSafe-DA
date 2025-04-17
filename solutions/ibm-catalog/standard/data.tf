###############################################################
# Data from the pre-requisite PowerVS deployable architecture
###############################################################
data "ibm_schematics_workspace" "schematics_workspace" {
  provider     = ibm.ibm_sch
  workspace_id = var.prerequisite_workspace_id
  location     = local.schematics_ws_location
}

data "ibm_schematics_output" "schematics_output" {
  provider     = ibm.ibm_sch
  workspace_id = var.prerequisite_workspace_id
  location     = local.schematics_ws_location
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}

###############################################################
# Data retrieval for boot image of VPC StorSight instance
###############################################################
data "ibm_is_image" "is_instance_boot_image_data" {
  count = var.create_storsight_instance ? 1 : 0
  name  = var.is_instance_boot_image
}

data "ibm_is_instance" "network_services_instance" {
  count = var.create_storsight_instance ? 1 : 0
  name  = local.network_services_instance.name
}

data "ibm_is_subnet" "network_services_subnet" {
  count      = var.create_storsight_instance ? 1 : 0
  identifier = data.ibm_is_instance.network_services_instance[0].network_attachments[0].subnet[0].id
}

data "ibm_is_vpc" "edge_vpc_data" {
  count = var.create_storsight_instance ? 1 : 0
  name  = local.vpc_name
}

###############################################################
# Data for Catalog Stock Images
###############################################################
data "ibm_pi_catalog_images" "catalog_images_ds" {
  pi_cloud_instance_id = local.powervs_workspace_guid
  vtl                  = true
}

###############################################################
# Data for Virtual Appliance Instance and Volumes creation
###############################################################
data "ibm_pi_placement_groups" "cloud_instance_groups" {
  pi_cloud_instance_id = local.powervs_workspace_guid
}

data "ibm_pi_key" "key" {
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_key_name          = local.powervs_sshkey_name
}

data "ibm_pi_network" "powervs_management_subnet" {
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = local.powervs_mgmt_net
}

data "ibm_pi_network" "powervs_backup_subnet" {
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = local.powervs_bkp_net
}

data "ibm_pi_network" "existing_powervs_subnets" {
  for_each = local.enable_existing_subnets_attach ? { for subnet in var.existing_powervs_subnets : subnet.name => subnet } : {}

  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = each.value.name
}
