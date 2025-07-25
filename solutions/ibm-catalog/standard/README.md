# IBM Cloud Catalog - FalconStor StorSafe PowerVS Deployable Architecture

## Summary

- Optionally creates a StorSight VSI in Edge VPC of Power Virtual Server with VPC landing zone
- Optionally creates a Windows VSI in Edge VPC of Power Virtual Server with VPC landing zone
- Creates a StorSafe instance in PowerVS Workspace of the landing zone
- Options to create up to 2 new subnets in PowerVS Workspace for StorSafe instance
- Option to attach existing PowerVS Workspace subnets to StorSafe Instance
- Creates configuration, index and tape - storage volumes in PowerVS Workspace of the landing zone

## Before you begin
- **This solution requires a schematics workspace ID as input.**
- If you do not have a [Power Virtual Server with VPC landing zone deployment](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?catalog_query=aHR0cHM6Ly9jbG91ZC5pYm0uY29tL2NhdGFsb2c%2Fc2VhcmNoPXBvd2VyI3NlYXJjaF9yZXN1bHRz) that is the full stack solution for a PowerVS Workspace with Secure Landing Zone, create it first.

## Architecture Diagram
![storsafe-pvs-da](https://raw.githubusercontent.com/falconstor-code/StorSafe-DA/main/xdocs/deploy-storsafe-pvs-da.svg)


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.80.4 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_create_storsight_instance"></a> [create\_storsight\_instance](#module\_create\_storsight\_instance) | terraform-ibm-modules/landing-zone-vsi/ibm | 5.4.6 |
| <a name="module_create_windows_instance"></a> [create\_windows\_instance](#module\_create\_windows\_instance) | terraform-ibm-modules/landing-zone-vsi/ibm | 5.4.6 |
| <a name="module_pi_instance"></a> [pi\_instance](#module\_pi\_instance) | terraform-ibm-modules/powervs-instance/ibm | 2.6.2 |

### Resources

| Name | Type |
|------|------|
| [ibm_is_image.import_custom_storsight_image](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/resources/is_image) | resource |
| [ibm_pi_network.optional_subnet_3](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/resources/pi_network) | resource |
| [ibm_pi_network.optional_subnet_4](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/resources/pi_network) | resource |
| [ibm_pi_volume.configuration_volume](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/resources/pi_volume) | resource |
| [ibm_pi_volume.index_volume](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/resources/pi_volume) | resource |
| [ibm_pi_volume.tape_volume](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/resources/pi_volume) | resource |
| [ibm_is_image.is_instance_boot_image_data](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/is_image) | data source |
| [ibm_is_image.storsight_boot_image_data](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/is_image) | data source |
| [ibm_pi_catalog_images.catalog_images_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/pi_catalog_images) | data source |
| [ibm_pi_network.existing_subnets](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/pi_network) | data source |
| [ibm_pi_placement_groups.cloud_instance_groups](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/pi_placement_groups) | data source |
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.80.4/docs/data-sources/schematics_workspace) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_affinity_policy"></a> [affinity\_policy](#input\_affinity\_policy) | The storage anti-affinity policy to use for placement of the StorSafe volume if PVM instance IDs are specified. | `string` | `"anti-affinity"` | no |
| <a name="input_backup_net_ip"></a> [backup\_net\_ip](#input\_backup\_net\_ip) | The IP address from the backup subnet to be assigned to the StorSafe instance. | `string` | `""` | no |
| <a name="input_create_storsight_instance"></a> [create\_storsight\_instance](#input\_create\_storsight\_instance) | The option to create a StorSight instance in the Edge VPC. | `bool` | `true` | no |
| <a name="input_create_windows_instance"></a> [create\_windows\_instance](#input\_create\_windows\_instance) | The option to create a Windows instance in the Edge VPC. | `bool` | `true` | no |
| <a name="input_custom_storsight_image"></a> [custom\_storsight\_image](#input\_custom\_storsight\_image) | The information of the custom image to be imported to create StorSight instance in VPC. | <pre>object({<br/>    name             = string<br/>    cos_href         = string<br/>    operating_system = string<br/>  })</pre> | <pre>{<br/>  "cos_href": "cos://us-east/falconstor-download/falconstor-storsight-vpc.vhd",<br/>  "name": "falconstor-storsight-rocky-linux-8",<br/>  "operating_system": "rocky-linux-8-amd64"<br/>}</pre> | no |
| <a name="input_existing_subnets"></a> [existing\_subnets](#input\_existing\_subnets) | Existing subnets to use for network isolation. Enter the subnet name and optionally the IP address from this subnet to be assigned to the StorSafe instance according to examples below:<br/>  [<br/>    {<br/>      "name" : "subnet\_3",<br/>      "ip"   : "10.40.33.0"<br/>    },<br/>    {<br/>      "name" : "subnet\_4"<br/>    }<br/>  ] | <pre>list(object({<br/>    name = string<br/>    ip   = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name to assign to the StorSafe instance. | `string` | n/a | yes |
| <a name="input_management_net_ip"></a> [management\_net\_ip](#input\_management\_net\_ip) | The IP address from the management subnet to be assigned to the StorSafe instance. | `string` | `""` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to assign to the StorSafe instance in GB according to the following formula: memory >= 16 + (2 * license\_repository\_capacity). | `number` | `18` | no |
| <a name="input_optional_subnet_3"></a> [optional\_subnet\_3](#input\_optional\_subnet\_3) | The option to create a third network subnet that can be used to isolate traffic, for example, for COS access. To skip subnet creation, set this value to null. Otherwise, enter the subnet name and CIDR range, and optionally the IP address from this subnet to be assigned to the StorSafe instance according to following examples:<br/>  Example for subnet creation specifying an IP address:<br/>    {<br/>      "name" : "storsafe\_net3",<br/>      "cidr" : "10.70.0.0/24",<br/>      "ip"   : "10.70.0.21"<br/>    }<br/>  Example for subnet creation without specifying an IP address:<br/>    {<br/>      "name" : "storsafe\_net3",<br/>      "cidr" : "10.70.0.0/24"<br/>    } | <pre>object({<br/>    name = string<br/>    cidr = string<br/>    ip   = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_optional_subnet_4"></a> [optional\_subnet\_4](#input\_optional\_subnet\_4) | The option to create a fourth network subnet that can be used to isolate traffic, for example, for data replication. To skip subnet creation, set this value to null. Otherwise, enter the subnet name and CIDR range, and optionally the IP address from this subnet to be assigned to the StorSafe instance according to following examples.<br/>  Example for subnet creation specifying an IP address:<br/>    {<br/>      "name" : "storsafe\_net4",<br/>      "cidr" : "10.71.0.0/24",<br/>      "ip"   : "10.71.0.21"<br/>    }<br/>  Example for subnet creation without specifying an IP address:<br/>    {<br/>      "name" : "storsafe\_net4",<br/>      "cidr" : "10.71.0.0/24"<br/>    } | <pre>object({<br/>    name = string<br/>    cidr = string<br/>    ip   = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The server placement group name where the StorSafe instance will be placed, as defined for the selected Power Systems Virtual Server CRN. | `string` | `""` | no |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of an existing 'Power Virtual Server with VPC landing zone' catalog solution. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?) to create one. | `string` | n/a | yes |
| <a name="input_processor_mode"></a> [processor\_mode](#input\_processor\_mode) | The type of processor mode in which the StorSafe instance will run: 'shared', 'capped', or 'dedicated'. | `string` | `"shared"` | no |
| <a name="input_pvm_instances"></a> [pvm\_instances](#input\_pvm\_instances) | List of PVM instance names to which the storage anti-affinity policy should be applied. Example ["instance1", "instance2"] Set to null to disable anti-affinity. | `list(string)` | `[]` | no |
| <a name="input_repository_capacity"></a> [repository\_capacity](#input\_repository\_capacity) | The StorSafe licensed repository capacity in TB. | `number` | `1` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | The type of storage tier for all volumes to attach to the StorSafe instance: 'tier1' (high performance) or 'tier3'. | `string` | `"tier1"` | no |
| <a name="input_storsafe_instance_boot_image"></a> [storsafe\_instance\_boot\_image](#input\_storsafe\_instance\_boot\_image) | The boot image to be used while creating the StorSafe PowerVS instance. | `string` | `"VTL-FalconStor-11_13_001"` | no |
| <a name="input_storsight_instance_configuration"></a> [storsight\_instance\_configuration](#input\_storsight\_instance\_configuration) | The instance profile to be used while creating StorSight instance. | <pre>object({<br/>    profile          = string<br/>    boot_volume_size = number<br/>  })</pre> | <pre>{<br/>  "boot_volume_size": 200,<br/>  "profile": "bx2-4x16"<br/>}</pre> | no |
| <a name="input_system_type"></a> [system\_type](#input\_system\_type) | The type of system on which to create the StorSafe instance: 's922' or 'e980' for Power 9; 's1022' for Power 10 if present in the selected datacenter. | `string` | `"s922"` | no |
| <a name="input_vcpus"></a> [vcpus](#input\_vcpus) | The number of vCPUs, AKA virtual processors, to assign to the StorSafe instance; one vCPU is equal to one physical CPU core. | `number` | `1` | no |
| <a name="input_volume_configuration_size"></a> [volume\_configuration\_size](#input\_volume\_configuration\_size) | The size of the block storage volume for the StorSafe Configuration Repository in GB. | `number` | `20` | no |
| <a name="input_volume_index_size"></a> [volume\_index\_size](#input\_volume\_index\_size) | The size of the block storage volume for the index of StorSafe Deduplication Repository in GB; the maximum size of a volume is 2 TB; attach extra volumes later, if necessary. | `number` | `1024` | no |
| <a name="input_volume_tape_size"></a> [volume\_tape\_size](#input\_volume\_tape\_size) | The size of the block storage volume for the StorSafe tape backup cache in GB; the maximum size of a volume is 2 TB; attach extra volumes later, if necessary. | `number` | `1024` | no |
| <a name="input_windows_instance_configuration"></a> [windows\_instance\_configuration](#input\_windows\_instance\_configuration) | The boot image and instance profile to be used while creating the windows instance in VPC. | <pre>object({<br/>    boot_image       = string<br/>    instance_profile = string<br/>  })</pre> | <pre>{<br/>  "boot_image": "ibm-windows-server-2022-full-standard-amd64-23",<br/>  "instance_profile": "bx2-2x8"<br/>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | The GUID of resource instance - Power Virtual Server workspace. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | The name of Power Virtual Server workspace. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | The zone where PowerVS infrastructure is created. |
| <a name="output_storsafe_vtl_instance"></a> [storsafe\_vtl\_instance](#output\_storsafe\_vtl\_instance) | The name, id and private IPS of FalconStor StorSafe instance. |
| <a name="output_storsafe_vtl_instance_subnets"></a> [storsafe\_vtl\_instance\_subnets](#output\_storsafe\_vtl\_instance\_subnets) | The subnets attached to the FalconStor StorSafe instance. |
| <a name="output_storsafe_vtl_volumes_list"></a> [storsafe\_vtl\_volumes\_list](#output\_storsafe\_vtl\_volumes\_list) | List of volumes created - configuration, index and tape volumes. |
| <a name="output_storsight_instance"></a> [storsight\_instance](#output\_storsight\_instance) | Details of StorSight VSI created in Edge VPC of PowerVS infrastructure with VPC landing zone. |
| <a name="output_windows_instance"></a> [windows\_instance](#output\_windows\_instance) | Details of Windows VSI created in Edge VPC of PowerVS infrastructure with VPC landing zone. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
