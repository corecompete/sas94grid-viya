
# SAS 9 Grid Manager for Platform + Viya Quickstart Template for Azure
This README for SAS 9 Grid Manager for Platform + Viya Quickstart Template for Azure is used to deploy the following SAS 9 Grid Manager for Platform + Viya products in the Azure cloud:


## SAS 9 Components
* SAS Enterprise BI Server 9.4
* SAS Enterprise Miner 15.1
* SAS Enterprise Guide 8.2 
* SAS Data Integration Server 9.4 
* SAS Grid Manager for Platform 9.44 
* SAS Office Analytics 7.4
* Platform Suite for SAS 10.11

## SAS Viya
* SAS Visual Analytics 8.5 on Linux
* SAS Visual Statistics 8.5 on Linux
* SAS Visual Data Mining and Machine Learning 8.5 on Linux
* SAS Data Preparation 2.5

This Quickstart is a reference architecture for users who want to deploy the SAS 9 Grid Manager for Platform + Viya platform, using microservices and other cloud-friendly technologies. By deploying the SAS platform in Azure, you get SAS analytics, data visualization, and machine-learning capabilities in an Azure-validated environment. 


## Contents
- [SAS 9 Grid Manager for Platform + Viya Quickstart Template for Azure](#sas9-Grid-Manager-for-Platform-viya-quickstart-template-for-azure)
  - [Prerequisites](#prerequisites)


<a name="Summary"></a>
## Solution Summary
By default, Quickstart deployments enable Transport Layer Security (TLS) for secure communication.

This SAS 9 Grid Manager for Platform + Viya Quickstart Template for Azure will deploy the SAS 9 Grid Manager for Platform and Viya into its own network. The deployment creates the network and other infrastructure.  After the deployment process completes, you will have the outputs for the web endpoints for a SAS MidTier and Viya deployment on recommended virtual machines (VMs)

![Network Diagram](sas94-grid-viya-architecture-diagram.svg)

<a name="Prerequisites"></a>
## Prerequisites
Before deploying SAS Quickstart Template for Azure, you must have the following:
* Azure user account with Contributor and Admin Roles
* Sufficient quota of at least 100 Cores based on licensed core for MPP environments ( SAS 9.4 and Viya)
* A SAS Software Order Confirmation Email that contains supported Quickstart products:
 
	The license file {emailed from SAS as SAS_Viya_deployment_data.zip} which describes your SAS Software Order.
	SAS 9.4 software order details required to download the sasdepot.
 
* A resource group that does not already contain a Quickstart deployment. For more information, see [Resource groups](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-groups).
### Download SAS Software for 9.4 and Viya
* Follow the SAS Instruction to [download the SAS 9.4 Software](https://documentation.sas.com/?docsetId=biig&docsetTarget=n03005intelplatform00install.htm&docsetVersion=9.4&locale=en).
* Follow the SAS Instruction to Create the [SAS Viya Mirror Repository](https://documentation.sas.com/?docsetId=dplyml0phy0lax&docsetTarget=p1ilrw734naazfn119i2rqik91r0.htm&docsetVersion=3.5&locale=en).

	Download SAS Mirror Manager from the [SAS Mirror Manager download site](https://support.sas.com/en/documentation/install-center/viya/deployment-tools/35/mirror-manager.html) to the machine where you want to create your mirror repository and uncompress the downloaded file.

* Run the command to Mirror the SAS viya repository:

		mirrormgr  mirror  --deployment-data  <path-to-SAS_Viya_deployment_data>.zip --path <location-of-mirror-repository> --log-file mirrormgr.log --platform 64-redhat-linux-6  --latest
 
### Upload the SAS Software to an Azure File Share
* Create Azure File Share with premium options. Follow the   Microsoft Azure instructions to "[Create a Premium File Share](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-create-premium-fileshare?tabs=azure-portal)"
* Upload the SAS_Viya_deployment_data.zip {emailed from SAS} to viyarepo folder where the software for viya is located. Instructions to Mount on [windows](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows), [Mac](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-mac) and [Linux](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux).
* The QuickStart deployment requires below parameters.storage account name, file share name, sasdepot folder, viyarepo folder, SAS Client license file, SAS Server license file, storage account key
* Create two directories for SAS 9.4 and SAS Viya in the File share(eg: sasdepot and viyarepo)
* Upload the SAS Software(sasdepot) to sasdepot folder. 
* Get Storage Account Access key. Follow the Microsoft Azure instructions to "[view storage account access key](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal)"
 
### Best Practices When Deploying SAS Viya on Azure
We recommend the following as best practices:
* Create a separate resource group for each Quickstart deployment. For more information, see [Resource groups](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-groups).
* In resource groups that contain a Quickstart deployment, include only the Quickstart deployment in the resource group to facilitate the deletion of the deployment as a unit.

### Deployment Steps
Sign in to the [Azure portal](https://portal.azure.com/).
* Now you're ready to create your template for deployment
* In the Azure portal, search for templates and select the template icon
* Click on add and provide a template name and description.
* Paste the azuredeploy.json code to ARM template and click on OK to save the template.
* Select the created template and click on deploy. 
* Fill in the parameters field as required, accept the terms and condition at the botton to proceed with the purchase. 
