variable "kube_version" {
  description = "Spesify kubernetes version"
  type        = string
  default     = "1.30"
}

variable "auto_scaling_enabled" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

variable "agent_count" {
  description = "Node Count"
  type        = number
  default     = null
}

variable "agents_max_count" {
  description = "Max Node Count"
  type        = number
  default     = 3
}

variable "agents_min_count" {
  description = "Min Node Count"
  type        = number
  default     = 1
}

variable "agent_vm_size" {
  description = "Node type"
  type        = string
  default     = "Standard_D4_v3"
}

variable "ssh_key_path" {
  description = "SSH key path"
  type        = string
}

variable "os_disk_size_gb" {
  description = "OS Disk Size"
  type        = number
  default     = 30
}

variable "azurerm_container_registry_name" {
  description = "Name of azure registry "
  type        = string
  default     = "mtarekacr1234"
}
