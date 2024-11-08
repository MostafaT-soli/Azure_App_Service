terraform {
  required_version = ">=1.8.0"
  # required_providers {
  #   azurerm = {
  #     source  = "hashicorp/azurerm"
  #     version = ">= 3.106.1, < 4.0"
  #   }
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
  # subscription_id = "b1ec803b-00c3-42bb-83ca-d12723a0e6a3"
  # client_id       = "your_client_id"
  # client_secret   = "your_client_secret"
  # tenant_id       = "33440fc6-b7c7-412c-bb73-0e70b0198d5a"
}
