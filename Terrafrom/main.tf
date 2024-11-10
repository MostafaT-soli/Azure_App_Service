locals {
  name = var.azurerm_frontend_name
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

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "ansumanapp-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.4.0.0/16"]
}

# Subnets for App Service instances and app gateway
resource "azurerm_subnet" "appserv" {
  name                 = "frontend-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.4.1.0/24"]
  service_endpoints = ["Microsoft.Web"]
  }

resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.4.2.0/24"]
  service_endpoints = ["Microsoft.Web"]
  }
# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.azurerm_container_registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_app_service_plan" "main" {
  name                = "app-service-plan-name"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"  # or "Linux" based on your requirements
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_public_ip" "agw" {
  name                  = "ansuman-agw-pip"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  allocation_method     = "Static"
  sku                   = "Standard" 
}

resource "azurerm_app_service" "frontend" {
  name                = var.azurerm_frontend_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
  site_config {
    linux_fx_version = "DOCKER|${var.azurerm_container_registry_name}.azurecr.io/${var.azurerm_container_repo_name}:latest"
    always_on = true
    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.appgw.id
      name       = "Allow APP GW"
      priority   = 100
    }
  }
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://${var.azurerm_container_registry_name}.azurecr.io"
  }
}

# Application Gateway
resource "azurerm_application_gateway" "agw" {
  name                = "ansuman-agw"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }


  gateway_ip_configuration {
    name      = "subnet"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = "${azurerm_public_ip.agw.id}"
  }

  backend_address_pool {
    name        = "AppService"
    fqdns = ["${azurerm_app_service.frontend.name}.azurewebsites.net"]
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  probe {
    name                = "probe"
    protocol            = "Http"
    path                = "/users"
    host                = "${azurerm_app_service.frontend.name}.azurewebsites.net"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  backend_http_settings {
    name                  = "http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "probe"
    pick_host_name_from_backend_address = true
  }

  request_routing_rule {
    name                       = "http"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "AppService"
    backend_http_settings_name = "http"
    priority                   = 1

  }
}