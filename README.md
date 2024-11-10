# DevOps Documentation

## Overview

This documentation covers the architecture and deployment of Azure Pipeline for a Python microservice application and automation deployment of the infrastructure on Azure cloud via Terraform and App servcies.

---

## Application Deployment HLD 

![APPHLD](https://github.com/MostafaT-soli/Azure_App_Service/blob/main/Endpoint.png)

### Application Deployment HLD Details 

1. Entry point will be through the application gateway.

2. From the App Service, the connection will be restricted only to the application gateway endpoint.

## Pipline High level Design

![PiplineHLD](https://github.com/MostafaT-soli/Azure_App_Service/blob/main/HL.drawio.png)

### Pipline HLD Details 

1. Developer will commit the code to the Azure Repo.

2. Code commit will trigger the AZDO pipeline to build the image and push it to the Azure Container Registry.

3. The Azure Container Registry will trigger the deployment of the new image via webhook on the App Service.

---
## Terraform Deployment

### Terraform will deploy the following:

1. Resource Group: This will contain all the below resources.

2. Web Application (App Service): This is where our web application will be hosted.

3. Application Gateway: This will be our only entry for the application.

4. Virtual Network and Subnet: For pod network communication.

5. Azure Container Registry: To upload the containerized application.

### Terraform Deployment Requirements

* Terraform must be installed.
* Azure CLI (az command) must be installed and logged into Azure Cloud.

```bash
az login
```

### Terraform Commands Requirements

1. Go to the Terraform directory.

2. Run `terraform init` to download modules.

3. Run `terraform plan` to create a plan.

4. Run `terraform apply` to apply such plan.

---

## Continuous Deployment Preparation 

> Note: Once the Terraform script is successful, we will proceed with the following steps:

- Enable the Continuous deployment option for the newly created app under the deployment center.

- Copy the Webhook URL and create a new Webhook under the Azure Container Repository.

----

## Pipeline Preparation

1. Import the this repo as 'Devops' repository and the 'Microservices' repository in the same organization within the same project in Azure DevOps Repos.

> Note: Please stick with exact repositor names 'Devops' and  'Microservices' as this is configured in the main trigger of the pipline 

2. Create a service connections to enable Azure DevOps to deploy to ACR.

   > Note: These service connections are referenced in the variables.yml under the `AZ-pipeline` folder.

   - A Docker Registry: To allow Azure DevOps to connect to the ACR, basic authentication has been used.

3. Create a new pipeline and select an existing YAML file, referencing the `pipeline.yml` file under the `AZ-pipeline` folder.

### Any changes to the Microservices repository will trigger the build pipeline.