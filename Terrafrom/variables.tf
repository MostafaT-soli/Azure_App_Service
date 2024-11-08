variable "azurerm_container_registry_name" {
  description = "Name of azure registry "
  type        = string
  default     = "mtarekacr1234"
}

variable "azurerm_web_app_name" {
  description = "Name of the main project"
  type        = string
  default     = "Web_App"
}
