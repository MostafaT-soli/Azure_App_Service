locals {
  name = "micro-application"
  tags = {
    Application = "micro"
    Author      = "Mostafa (Melsayed)"
  }
}

resource "azurerm_resource_group" "main" {
  name     = local.name
  location = "East US"

  tags = local.tags
}

module "network" {
  source              = "Azure/subnets/azurerm"
  version             = "1.0.0"
  resource_group_name = azurerm_resource_group.main.name

  subnets = {
    aks = {
      address_prefixes  = ["10.52.0.0/16"]
      service_endpoints = ["Microsoft.Storage"]
    }
  }

  virtual_network_address_space = ["10.52.0.0/16"]
  virtual_network_location      = azurerm_resource_group.main.location
  virtual_network_name          = "${local.name}-vnet"
  virtual_network_tags          = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.azurerm_container_registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}