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
  description = "The StorSafe VTL licensed repository capacity in TB."
  type        = number
  default     = 1
}

variable "memory" {
  description = "The amount of memory to assign to the StorSafe VTL instance in GB according to the following formula: memory >= 16 + (2 * license_repository_capacity)."
  type        = number
  default     = 18

}

variable "vcpus" {
  description = "The number of vCPUs, AKA virtual processors, to assign to the StorSafe VTL instance; one vCPU is equal to one physical CPU core."
  type        = number
  default     = 1
}

variable "instance_name" {
  description = "The name to assign to the StorSafe VTL instance."
  type        = string
}

variable "processor_mode" {
  description = "The type of processor mode in which the StorSafe VTL instance will run: 'shared', 'capped', or 'dedicated'."
  type        = string
  default     = "shared"
}

variable "system_type" {
  description = "The type of system on which to create the StorSafe VTL instance: 's922' or 'e980' for Power 9; 's1022' for Power 10 if present in the selected datacenter."
  type        = string
  default     = "s922"
}

variable "storage_type" {
  description = "The type of storage tier for all volumes to attach to the StorSafe VTL instance: 'tier1' (high performance) or 'tier3'."
  type        = string
  default     = "tier1"
}

variable "management_net_ip" {
  description = "The IP address from the management subnet to be assigned to the StorSafe VTL instance."
  type        = string
  default     = ""
}

variable "backup_net_ip" {
  description = "The IP address from the backup subnet to be assigned to the StorSafe VTL instance."
  type        = string
  default     = ""
}

variable "private_subnet_3" {
  description = <<EOT
  Configure this input object to create a new subnet for your instance. To skip subnet creation, set this value to null. Follow the example formats to configure. Mandatory fields - 'name', 'cidr'. Optional field - 'ip'.
  Subnet creation with ip assign example:
    {
      "name" : "vtl_subnet",
      "cidr" : "10.70.0.0/24",
      "ip"   : "10.70.0.21",
    }
  Subnet creation without ip assign example:
    {
      "name" : "vtl_subnet",
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
      var.private_subnet_3 == null ||
      (
        can(cidrnetmask(try(var.private_subnet_3.cidr, ""))) &&
        (
          startswith(try(var.private_subnet_3.cidr, ""), "10.") ||
          startswith(try(var.private_subnet_3.cidr, ""), "192.168.") ||
          can(regex("^172\\.(1[6-9]|2[0-9]|3[0-1])\\.", try(var.private_subnet_3.cidr, "")))
        ) &&
        (
          try(var.private_subnet_3.ip, null) == null ||
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.private_subnet_3.ip))
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

variable "private_subnet_4" {
  description = <<EOT
  Configure this input object to create a new subnet for your instance. To skip subnet creation, set this value to null. Follow the example formats to configure. Mandatory fields - 'name', 'cidr'. Optional field - 'ip'.
  Subnet creation with ip assign example:
    {
      "name" : "vtl_subnet",
      "cidr" : "10.71.0.0/24",
      "ip"   : "10.71.0.21"
    }
  Subnet creation without ip assign example:
    {
      "name" : "vtl_subnet",
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
      var.private_subnet_4 == null ||
      (
        can(cidrnetmask(try(var.private_subnet_4.cidr, ""))) &&
        (
          startswith(try(var.private_subnet_4.cidr, ""), "10.") ||
          startswith(try(var.private_subnet_4.cidr, ""), "192.168.") ||
          can(regex("^172\\.(1[6-9]|2[0-9]|3[0-1])\\.", try(var.private_subnet_4.cidr, "")))
        ) &&
        (
          try(var.private_subnet_4.ip, null) == null ||
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.private_subnet_4.ip))
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

variable "existing_powervs_subnets" {
  description = <<EOT
  Configuration for a existing private subnets to be attached to the StorSafe VTL instance including its name, and an optional IP address to assign to StorSafe VTL instance. To configure, follow the example format provided. Mandatory field - 'name'. Optional field - 'ip'.
  [
    {
      "name" : "subnet_x",
      "ip"   : "10.40.33.0"
    },
    {
      "name" : "subnet_y"
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
  description = "The server placement group name where the StorSafe VTL instance will be placed, as defined for the selected Power Systems Virtual Server CRN."
  type        = string
  default     = ""
}

variable "affinity_policy" {
  description = "The storage anti-affinity policy to use for placement of the StorSafe VTL volume if PVM instance IDs are specified."
  type        = string
  default     = "anti-affinity"
}

variable "pvm_instances" {
  description = "List of PVM instance names to which the storage anti-affinity policy should be applied. Example [\"instance1\", \"instance2\"] Set to null to disable anti-affinity."
  type        = list(string)
  default     = []
}

variable "volume_configuration_size" {
  description = "The size of the block storage volume for the StorSafe VTL Configuration Repository in GB."
  type        = number
  default     = 20
}

variable "volume_index_size" {
  description = "The size of the block storage volume for the index of StorSafe VTL Deduplication Repository in GB; the maximum size of a volume is 2 TB; attach extra volumes later, if necessary."
  type        = number
  default     = 1024
}

variable "volume_tape_size" {
  description = "The size of the block storage volume for the StorSafe VTL tape backup cache in GB; the maximum size of a volume is 2 TB; attach extra volumes later, if necessary."
  type        = number
  default     = 1024
}

variable "create_storsight_instance" {
  description = "The boolean option to create a windows StorSight instance in the Edge VPC of the pre-requisite Landing zone infrastructure."
  type        = bool
  default     = false
}

# hidden variables
variable "pi_instance_boot_image" {
  description = "The boot image to be used while creating the StorSafe VTL PowerVS instance."
  type        = string
  default     = "VTL-FalconStor-11_13_001"
}

variable "is_instance_boot_image" {
  description = "The boot image to be used while creating the StorSight VPC instance."
  type        = string
  default     = "ibm-windows-server-2022-full-standard-amd64-23"
}

variable "is_instance_profile" {
  description = "The boot image to be used while creating the StorSight VPC instance."
  type        = string
  default     = "bx2-2x8"
}
