variable "azurerm_container_registry_name" {
  description = "Name of azure registry "
  type        = string
  default     = "mtarekacr1234"
}

variable "azurerm_container_repo_name" {
  description = "Name of application repo "
  type        = string
  default     = "micro"
}

variable "azurerm_frontend_name" {
  description = "Name of the main project"
  type        = string
  default     = "frontend2325"
}


variable "DOCKER_REGISTRY_SERVER_PASSWORD" {
  description = "DOCKER_REGISTRY_SERVER_PASSWORD"
  type        = string
}

