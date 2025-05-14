###############################################################
# Inputs
###############################################################
variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prerequisite_workspace_id" {
  description = "IBM Cloud Schematics workspace ID of an existing 'Power Virtual Server with VPC landing zone' catalog solution. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?) to create one."
  type        = string
}

variable "repository_capacity" {
  description = "The StorSafe licensed repository capacity in TB."
  type        = number
  default     = 1
}

variable "memory" {
  description = "The amount of memory to assign to the StorSafe instance in GB according to the following formula: memory >= 16 + (2 * license_repository_capacity)."
  type        = number
  default     = 18

}

variable "vcpus" {
  description = "The number of vCPUs, AKA virtual processors, to assign to the StorSafe instance; one vCPU is equal to one physical CPU core."
  type        = number
  default     = 1
}

variable "instance_name" {
  description = "The name to assign to the StorSafe instance."
  type        = string
}

variable "processor_mode" {
  description = "The type of processor mode in which the StorSafe instance will run: 'shared', 'capped', or 'dedicated'."
  type        = string
  default     = "shared"
}

variable "system_type" {
  description = "The type of system on which to create the StorSafe instance: 's922' or 'e980' for Power 9; 's1022' for Power 10 if present in the selected datacenter."
  type        = string
  default     = "s922"
}

variable "storage_type" {
  description = "The type of storage tier for all volumes to attach to the StorSafe instance: 'tier1' (high performance) or 'tier3'."
  type        = string
  default     = "tier1"
}

variable "management_net_ip" {
  description = "The IP address from the management subnet to be assigned to the StorSafe instance."
  type        = string
  default     = ""
}

variable "backup_net_ip" {
  description = "The IP address from the backup subnet to be assigned to the StorSafe instance."
  type        = string
  default     = ""
}

variable "optional_subnet_3" {
  description = <<EOT
  The option to create a third network subnet that can be used to isolate traffic, for example, for COS access. To skip subnet creation, set this value to null. Otherwise, enter the subnet name and CIDR range, and optionally the IP address from this subnet to be assigned to the StorSafe instance according to following examples:
  Example for subnet creation specifying an IP address:
    {
      "name" : "storsafe_net3",
      "cidr" : "10.70.0.0/24",
      "ip"   : "10.70.0.21"
    }
  Example for subnet creation without specifying an IP address:
    {
      "name" : "storsafe_net3",
      "cidr" : "10.70.0.0/24"
    }
  EOT
  type = object({
    name = string
    cidr = string
    ip   = optional(string)
  })

  default = null

  validation {
    condition = (
      var.optional_subnet_3 == null ||
      (
        can(cidrnetmask(try(var.optional_subnet_3.cidr, ""))) &&
        (
          startswith(try(var.optional_subnet_3.cidr, ""), "10.") ||
          startswith(try(var.optional_subnet_3.cidr, ""), "192.168.") ||
          can(regex("^172\\.(1[6-9]|2[0-9]|3[0-1])\\.", try(var.optional_subnet_3.cidr, "")))
        ) &&
        (
          try(var.optional_subnet_3.ip, null) == null ||
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.optional_subnet_3.ip))
        )
      )
    )

    error_message = <<EOT
    If provided, 'cidr' must:
    - Be a valid IPv4 CIDR block (e.g., 10.0.0.0/16, 172.16–31.0.0/16, or 192.168.0.0/16),
    - Fall within private IP address ranges.

    If 'ip' is provided, it must be a valid IPv4 address (e.g., 192.168.1.10).
    EOT
  }
}

variable "optional_subnet_4" {
  description = <<EOT
  The option to create a fourth network subnet that can be used to isolate traffic, for example, for data replication. To skip subnet creation, set this value to null. Otherwise, enter the subnet name and CIDR range, and optionally the IP address from this subnet to be assigned to the StorSafe instance according to following examples.
  Example for subnet creation specifying an IP address:
    {
      "name" : "storsafe_net4",
      "cidr" : "10.71.0.0/24",
      "ip"   : "10.71.0.21"
    }
  Example for subnet creation without specifying an IP address:
    {
      "name" : "storsafe_net4",
      "cidr" : "10.71.0.0/24"
    }
  EOT

  type = object({
    name = string
    cidr = string
    ip   = optional(string)
  })

  default = null

  validation {
    condition = (
      var.optional_subnet_4 == null ||
      (
        can(cidrnetmask(try(var.optional_subnet_4.cidr, ""))) &&
        (
          startswith(try(var.optional_subnet_4.cidr, ""), "10.") ||
          startswith(try(var.optional_subnet_4.cidr, ""), "192.168.") ||
          can(regex("^172\\.(1[6-9]|2[0-9]|3[0-1])\\.", try(var.optional_subnet_4.cidr, "")))
        ) &&
        (
          try(var.optional_subnet_4.ip, null) == null ||
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.optional_subnet_4.ip))
        )
      )
    )

    error_message = <<EOT
    If provided, 'cidr' must:
    - Be a valid IPv4 CIDR block (e.g., 10.0.0.0/16, 172.16–31.0.0/16, or 192.168.0.0/16),
    - Fall within private IP address ranges.

    If 'ip' is provided, it must be a valid IPv4 address (e.g., 192.168.1.10).
    EOT
  }
}

variable "existing_subnets" {
  description = <<EOT
  Existing subnets to use for network isolation. Enter the subnet name and optionally the IP address from this subnet to be assigned to the StorSafe instance according to examples below:
  [
    {
      "name" : "subnet_3",
      "ip"   : "10.40.33.0"
    },
    {
      "name" : "subnet_4"
    }
  ]
  EOT
  type = list(object({
    name = string
    ip   = optional(string)
  }))
  default = null
}

variable "placement_group" {
  description = "The server placement group name where the StorSafe instance will be placed, as defined for the selected Power Systems Virtual Server CRN."
  type        = string
  default     = ""
}

variable "pvm_instances" {
  description = "List of PVM instance names to which the storage anti-affinity policy should be applied. Example [\"instance1\", \"instance2\"] Set to null to disable anti-affinity."
  type        = list(string)
  default     = []
}

variable "volume_configuration_size" {
  description = "The size of the block storage volume for the StorSafe Configuration Repository in GB."
  type        = number
  default     = 20
}

variable "volume_index_size" {
  description = "The size of the block storage volume for the index of StorSafe Deduplication Repository in GB; the maximum size of a volume is 2 TB; attach extra volumes later, if necessary."
  type        = number
  default     = 1024
}

variable "volume_tape_size" {
  description = "The size of the block storage volume for the StorSafe tape backup cache in GB; the maximum size of a volume is 2 TB; attach extra volumes later, if necessary."
  type        = number
  default     = 1024
}

variable "create_storsight_instance" {
  description = "The option to create a StorSight instance in the Edge VPC."
  type        = bool
  default     = true
}

variable "create_windows_instance" {
  description = "The option to create a Windows instance in the Edge VPC."
  type        = bool
  default     = true
}

# hidden variables
variable "affinity_policy" {
  description = "The storage anti-affinity policy to use for placement of the StorSafe volume if PVM instance IDs are specified."
  type        = string
  default     = "anti-affinity"
}

variable "storsafe_instance_boot_image" {
  description = "The boot image to be used while creating the StorSafe PowerVS instance."
  type        = string
  default     = "VTL-FalconStor-11_13_001"
}

variable "windows_instance_configuration" {
  description = "The boot image and instance profile to be used while creating the windows instance in VPC."
  type = object({
    boot_image       = string
    instance_profile = string
  })
  default = {
    boot_image       = "ibm-windows-server-2022-full-standard-amd64-23"
    instance_profile = "bx2-2x8"
  }
}

variable "custom_storsight_image" {
  description = "The information of the custom image to be imported to create StorSight instance in VPC."
  type = object({
    name             = string
    cos_href         = string
    operating_system = string
  })
  default = {
    name             = "falconstor-storsight-rocky-linux-8"
    cos_href         = "cos://us-east/falconstor-download/falconstor-storsight-vpc.vhd"
    operating_system = "rocky-linux-8-amd64"
  }
}

variable "storsight_instance_configuration" {
  description = "The instance profile to be used while creating StorSight instance."
  type = object({
    profile          = string
    boot_volume_name = string
    boot_volume_size = number
  })
  default = {
    profile          = "bx2-4x16"
    boot_volume_name = "storsight-boot-volume"
    boot_volume_size = 200
  }
}
