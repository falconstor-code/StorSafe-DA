###############################################################
# Deploy Windows Instance in Edge VPC
###############################################################

resource "ibm_is_image" "import_custom_storsight_image" {
  count = var.create_storsight_instance ? 1 : 0

  name             = var.custom_storsight_image.name
  href             = var.custom_storsight_image.cos_href
  operating_system = var.custom_storsight_image.operating_system
  timeouts {
    create = "1h"
  }
}

module "create_storsight_instance" {
  count   = var.create_windows_instance ? 1 : 0
  source  = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version = "5.4.6"

  create_security_group         = false
  image_id                      = data.ibm_is_image.storsight_boot_image_data[0].id
  machine_type                  = var.storsight_instance_configuration.profile
  prefix                        = "${local.prefix}-storsight"
  resource_group_id             = local.resource_group_id
  security_group_ids            = local.security_group_ids
  ssh_key_ids                   = local.ssh_key_ids
  subnets                       = local.subnets
  user_data                     = ""
  vpc_id                        = local.vpc_id
  vsi_per_subnet                = 1
  kms_encryption_enabled        = true
  skip_iam_authorization_policy = true
  boot_volume_size              = var.storsight_instance_configuration.boot_volume_size
  boot_volume_encryption_key    = local.boot_volume_encryption_key
}

module "create_windows_instance" {
  count   = var.create_windows_instance ? 1 : 0
  source  = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version = "5.4.6"

  create_security_group         = false
  image_id                      = data.ibm_is_image.is_instance_boot_image_data[0].id
  machine_type                  = var.windows_instance_configuration.instance_profile
  prefix                        = "${local.prefix}-windows"
  resource_group_id             = local.resource_group_id
  security_group_ids            = local.security_group_ids
  ssh_key_ids                   = local.ssh_key_ids
  subnets                       = local.subnets
  user_data                     = ""
  vpc_id                        = local.vpc_id
  vsi_per_subnet                = 1
  kms_encryption_enabled        = true
  skip_iam_authorization_policy = true
  boot_volume_encryption_key    = local.boot_volume_encryption_key
}

###############################################################
# Create Private Subnets in PowerVS Workspace
###############################################################

resource "ibm_pi_network" "optional_subnet_3" {
  count                = var.optional_subnet_3 != null ? 1 : 0
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = var.optional_subnet_3.name
  pi_cidr              = var.optional_subnet_3.cidr
  pi_network_type      = "vlan"
  pi_network_mtu       = 9000
}

resource "ibm_pi_network" "optional_subnet_4" {
  count = var.optional_subnet_4 != null ? 1 : 0

  depends_on           = [ibm_pi_network.optional_subnet_3]
  pi_cloud_instance_id = local.powervs_workspace_guid
  pi_network_name      = var.optional_subnet_4.name
  pi_cidr              = var.optional_subnet_4.cidr
  pi_network_type      = "vlan"
  pi_network_mtu       = 9000
}

###############################################################
# Deploy Virtual Appliance Instance and Volumes
###############################################################

module "pi_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "2.6.2"

  pi_workspace_guid              = local.powervs_workspace_guid
  pi_ssh_public_key_name         = local.powervs_sshkey_name
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
