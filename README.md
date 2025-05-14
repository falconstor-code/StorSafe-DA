# FalconStor StorSafe PowerVS Deployable Architecture
This repository contains terraform solution that help in deploying FalconStor StorSafe PowerVS Deployable Architecture. The solution is available in the IBM Cloud Catalog and can also be deployed without the catalog.

## Before you begin

  1. You must have an existing deployment of [PowerVS Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global) deployable architecture. This can be deployed from IBM catalog tile. Instructions are provided [here](/docs/powervs-vpc?topic=powervs-vpc-automation-solution-overview). Only following variations are supported to proceed with the deployment of FalconStor StorSafe PowerVS Deployable Architecture.
  - [Standard Landscape Variation](/docs/powervs-vpc?topic=powervs-vpc-deploy-arch-ibm-pvs-inf-standard)
  - [Extend Standard Landscape Variation](/docs/powervs-vpc?topic=powervs-vpc-deploy-arch-ibm-pvs-inf-extension)
  2. Refer to the [Solution Sizing](http://ibmsizing.falconstor.com) page (login password IBM2023) to get the sizing information about the deduplication repository, backup cache, memory, CPU, and the machine type.
  4. Refer to the [Cost Estimation](https://cloud.ibm.com/catalog/services/power-systems-virtual-server) page, click **Estimate costs** on the top right side panel, select **Virtual Tape Library** as OS, enter values for usage parameters based on the Solution Sizing tool results, click **Calculate cost** and **Save** to see the cost. Click **Review estimate** to go the **Cost estimator** page. Additional costs may apply based on extra capacity for the Cloud Object Storage (COS), or additional network and infrastructure components.
  4. Refer to the [Deployment Guide](https://falconstor-download.s3.us-east.cloud-object-storage.appdomain.cloud/FalconStor%20VTL%20for%20IBM%20Deployment%20Guide.pdf) for deployment scenarios and setup instructions.
  5. Verify that you have Manager service access role for IBM Cloud Schematics.
  6. Review and verify the Identity and Access Management (IAM) information at [Managing Power Systems Virtual Servers (IAM)](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-managing-resources-and-users).

## Required resources

  * FalconStor StorSafe PowerVS DA require a Schematics workspace ID of [Power Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global)


## Installing the software

To install the software, configure the following variables:
  * Deploy [Power Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global).
  * Provide a Schematics workspace ID of [Power Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global).
  * Enter a name for the new image instance that is being created.
  * Set the amount of the VTL licensed repository capacity; must be higher than zero.
  * Set the amount of required memory based on the repository capacity.
  * If necessary, update the required number of CPU cores based on the repository capacity.
  * Check values for the storage type and the system type based on the repository capacity.
  * Optionally, enter a subnet name, CIDR and optional IP to create a subnet for the selected server instance.
  * Optionally, enter the existing networks to which StorSafe Instance needs to be attached.
  * Optionally, enter the space separated list of PVM instance IDs to base storage anti-affinity policy against.
  * Optionally, enter the name of a placement group where the VTL instance will be placed.
  * Review all parameter settings. For details on instance parameters, refer to [Terraform Registry](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_instance).

## Upgrading to a new version

For information about applying updates and fixes, see [Downloading fixes and updates](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-downloading-fixes-updates) in the Power Systems Virtual Server documentation.

## Uninstalling the software

Complete the following steps to uninstall a Helm Chart from your account.

1. Go to the **Menu** > **Schematics**.
2. Select your workspace name.
3. Click **Actions** > **Destroy resources**. All resources in your workspace are deleted.
4. Click **Update**.
5. To delete your workspace, click **Actions** > **Delete workspace**.
