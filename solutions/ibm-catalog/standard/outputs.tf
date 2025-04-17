###############################################################
# Outputs
###############################################################
output "powervs_workspace_guid" {
  description = "The GUID of resource instance - Power Virtual Server workspace."
  value       = local.powervs_workspace_guid
}

output "powervs_workspace_name" {
  description = "The name of Power Virtual Server workspace."
  value       = local.powervs_workspace_name
}

output "powervs_zone" {
  description = "The zone where PowerVS infrastructure is created."
  value       = local.powervs_zone
}

output "storsight_instance" {
  description = "Details of Windows VSI created in Edge VPC of PowerVS infrastructure with VPC landing zone."
  value       = var.create_storsight_instance ? module.create_storsight_instance[0].list[0] : {}
}

output "storsafe_vtl_instance" {
  description = "The name, id and private IPS of FalconStor StorSafe vtl instance."
  value = {
    instance_name        = module.pi_instance.pi_instance_name
    instance_id          = module.pi_instance.pi_instance_id
    instance_private_ips = module.pi_instance.pi_instance_private_ips
  }
}

output "storsafe_vtl_instance_subnets" {
  description = "The subnets attached to the FalconStor StorSafe vtl instance."
  value       = local.pi_subnet_list
}

output "storsafe_vtl_volumes_list" {
  description = "List of volumes created - configuration, index and tape volumes."
  value       = local.storsafe_vtl_volume_list
}
