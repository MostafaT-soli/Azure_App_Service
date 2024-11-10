# DevOps Documentation

## Overview

This documentation covers the architecture and deployment of Azure Pipeline for a Python microservice application and automation deployment of the infrastructure on Azure cloud via Terraform and App servcies.

---
## High level desighn 

![HLD](https://github.com/MostafaT-soli/Azure_App_Service/blob/main/HL.drawio.png)

## Terraform Deployment

### Terraform will deploy the following:

1. Resource Group: This will contain all the below resources.

2. Web Application (App Service): This is where our web application will be hosted.

3. Application Gateway: This will be our only entry for the application.

4. Virtual Network and Subnet: For pod network communication.

5. Container Registry: To upload the containerized application.

### Terraform Deployment Requirements

* Terraform must be installed.
* Azure CLI (az command) must be installed and logged into Azure Cloud.

```bash
az login
```
* Create a `terraform.tfvars` file in your local repository and add an `ssh_key_path` variable referencing a  public key file.

### Terraform Commands Requirements

1. Go to the Terraform directory.

2. Run `terraform init` to download modules.

3. Run `terraform plan` to create a plan.

4. Run `terraform apply` to apply such plan.

---

## AKS Preparation

Once AKS is deployed, log in to AKS and proceed with the following steps:

1. Deploy nginx ingress controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml
```

2. Create a prod namespace

```bash
kubectl create ns prod
```

3. Create a certificate and add it to a secret for ingress

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.crt -subj "/CN=micro.mostafa.com" -addext "subjectAltName = DNS:micro.mostafa.com,DNS:www.micro.mostafa.com"
kubectl create secret tls my-tls-secret --key mykey.key --cert mycert.crt -n prod
```

4. Create an image pull secret

First, log into the ACR and show the credentials using the Azure CLI command

```bash
az acr login --name <acr_name>
az acr credential show --name <acr_name>
```

Create a JSON file from the provided credentials as an example

```json
{
  "auths": {
    "your-registry": {
      "username": "your-username",
      "password": "your-password",
      "email": "your-email",
      "auth": "base64-encoded-auth-info"
    }
  }
}
```

Create the image pull secret referencing the above JSON file

```bash
kubectl create secret generic azure-acr-secret --from-file=.dockerconfigjson=.json --type=kubernetes.io/dockerconfigjson -n prod
```

----

## Pipeline Preparation

1. Import the 'Devops' repository and the 'Microservices' repository in the same organization within the same project in Azure DevOps Repos.

2. Create two service connections to enable Azure DevOps to connect to AKS and ACR.

   > Note: These service connections are referenced in the variables.yml under the `AZ-pipeline` folder.

   - A Docker Registry: To allow Azure DevOps to connect to the ACR, basic authentication has been used.
   - Kubernetes service connection: To enable Azure DevOps to connect to the Kubernetes server.

3. Create a new pipeline and select an existing YAML file, referencing the `pipeline.yml` file under the `AZ-pipeline` folder.

### Any changes to the Microservices repository will trigger the build and deploy pipeline.