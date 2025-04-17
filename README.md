## Before you begin

  1. Refer to the [Solution Sizing](http://ibmsizing.falconstor.com) page (login password IBM2023) to get the sizing information about the deduplication repository, backup cache, memory, CPU, and the machine type.
  2. Refer to the [Cost Estimation](https://cloud.ibm.com/catalog/services/power-systems-virtual-server) page, click **Estimate costs** on the top right side panel, select **Virtual Tape Library** as OS, enter values for usage parameters based on the Solution Sizing tool results, click **Calculate cost** and **Save** to see the cost. Click **Review estimate** to go the **Cost estimator** page. Additional costs may apply based on extra capacity for the Cloud Object Storage (COS), or additional network and infrastructure components.
  3. Refer to the [Deployment Guide](https://falconstor-download.s3.us-east.cloud-object-storage.appdomain.cloud/FalconStor%20VTL%20for%20IBM%20Deployment%20Guide.pdf) for deployment scenarios and setup instructions.
  4. Verify that you have Manager service access role for IBM Cloud Schematics.
  5. Review and verify the Identity and Access Management (IAM) information at [Managing Power Systems Virtual Servers (IAM)](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-managing-resources-and-users).

## Required resources

  * Create a Power Systems Virtual Server Instance. For more information, see [Getting started with IBM Power Systems Virtual Servers](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-getting-started).
  * You cannot create a private network during the VM provisioning process. You must first use the Power Systems Virtual Server user interface, command line interface (CLI), or application programming interfaced (API) to [create one](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-configuring-subnet).
  * It is recommended to create a public and private SSH key that you can use to securely connect to your Power Systems Virtual Server. For more information, see [Adding an SSH key](https://cloud.ibm.com/docs/ssh-keys?topic=ssh-keys-adding-an-ssh-key).

## Installing the software

To install the software, configure the following variables:
  * Select a Power Systems Virtual Server CRN.
  * Enter a name for the new image instance that is being created.
  * Set the amount of the VTL licensed repository capacity; must be higher than zero.
  * Set the amount of required memory based on the repository capacity.
  * If necessary, update the required number of CPU cores based on the repository capacity.
  * Check values for the storage type and the system type based on the repository capacity.
  * Enter a Network Name or ID for the selected server instance. Optionally, enter information for other networks.
  * Optionally, enter an SSH Key Name for the selected server instance.
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
