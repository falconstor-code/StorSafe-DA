###############################################################
# Deploy StorSight instance in Edge VPC
###############################################################

module "create_storsight_instance" {
  count   = var.create_storsight_instance ? 1 : 0
  source  = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version = "4.7.1"

  create_security_group = false
  image_id              = data.ibm_is_image.is_instance_boot_image_data[0].id
  machine_type          = var.is_instance_profile
  prefix                = local.prefix
  resource_group_id     = local.resource_group_id
  security_group_ids    = local.security_group_ids
  ssh_key_ids           = local.ssh_key_ids
  subnets               = local.subnets
  user_data             = ""
  vpc_id                = local.vpc_id
  vsi_per_subnet        = 1
}

###############################################################
# Create Private Subnets in PowerVS Workspace
###############################################################

resource "ibm_pi_network" "private_subnet_3" {
  count                = var.private_subnet_3 != null ? 1 : 0
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = var.private_subnet_3.name
  pi_cidr              = var.private_subnet_3.cidr
  pi_network_type      = "vlan"
  pi_network_mtu       = 9000
}

resource "ibm_pi_network" "private_subnet_4" {
  count = var.private_subnet_4 != null ? 1 : 0

  depends_on           = [ibm_pi_network.private_subnet_3]
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = var.private_subnet_4.name
  pi_cidr              = var.private_subnet_4.cidr
  pi_network_type      = "vlan"
  pi_network_mtu       = 9000
}

###############################################################
# Deploy Virtual Appliance Instance and Volumes
###############################################################

module "pi_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "2.6.1"

  pi_workspace_guid              = local.powervs_workspace_guid
  pi_ssh_public_key_name         = length(local.powervs_sshkey_name) > 0 ? data.ibm_pi_key.key.id : null
  pi_image_id                    = local.pi_image_id
  pi_networks                    = local.pi_subnet_list
  pi_instance_name               = var.instance_name
  pi_server_type                 = var.system_type
  pi_number_of_processors        = var.vcpus
  pi_memory_size                 = var.memory
  pi_cpu_proc_type               = var.processor_mode
  pi_boot_image_storage_tier     = var.storage_type
  pi_placement_group_id          = local.placement_group_id
  pi_affinity_policy             = local.enable_anti_affinity ? var.affinity_policy : null
  pi_anti_affinity               = local.enable_anti_affinity ? { anti_affinity_instances = var.pvm_instances } : null
  pi_license_repository_capacity = var.repository_capacity == 0 ? 1 : var.repository_capacity
}

resource "ibm_pi_volume" "configuration_volume" {
  pi_volume_size       = var.volume_configuration_size
  pi_volume_name       = "${var.instance_name}_configuration-volume"
  pi_volume_type       = var.storage_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = local.powervs_workspace_guid
}

resource "ibm_pi_volume" "index_volume" {
  pi_volume_size       = var.volume_index_size
  pi_volume_name       = "${var.instance_name}_index-volume"
  pi_volume_type       = var.storage_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = local.powervs_workspace_guid
}

resource "ibm_pi_volume" "tape_volume" {
  pi_volume_size       = var.volume_tape_size
  pi_volume_name       = "${var.instance_name}_tape-volume"
  pi_volume_type       = var.storage_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = local.powervs_workspace_guid
}
