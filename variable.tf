variable "subscription_name" {
  description = "The name of the Azure subscription"
  type        = string
}

# ------------------------------
# Variables - Naming Module
# ------------------------------

variable "azure_region" {
  description = "The Azure region to deploy resources"
  type        = string

}

variable "environment" {
  description = "The environment to deploy resources"
  type        = string

}

variable "application_id" {
  description = "The application id of the service principal"
  type        = string

}

# ---------------------------
# Variable - Resource group
# ---------------------------

variable "veritas_resource_group" {
  description = "The name of the resource group"
  type        = list(string)
}

# ---------------------------
# Variables - Key Vault
# ---------------------------

variable "soft_delete_retention_days" {
  description = "The number of days to retain soft deleted keys in the Key Vault"
  type        = number
  default     = 90

}

variable "purge_protection_enabled" {
  description = "Enable or disable purge protection for the Key Vault"
  type        = bool
  default     = false

}

variable "key_vault_veritas" {
  description = "The name of the Key Vault"
  type        = string

}

variable "days_to_expire" {
  description = "The number of days before the certificate expires"
  type        = number
  default     = 90

}

# ---------------------------
# Variables - Virtual Machine
# ---------------------------

variable "virtual_machine_veritas" {
  description = "The name of the virtual machine"
  type        = map(any)

}

variable "size" {
  description = "The size of the virtual machine"
  type        = string

}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string

}

# ---------------------------
# Variables - VNET and Subnet
# ---------------------------

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string

}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = list(any)

}

variable "vnet_rg_name" {
  description = "The name of the resource group for the virtual network"
  type        = string

}


