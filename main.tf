# ----------------------------------------------
# Create Virtual Network & Subnet
# ----------------------------------------------

data "azurerm_virtual_network" "veritas_vnet" {
  depends_on = [ module.vnet_resource_group ]
  provider            = azurerm.veritas
  name                = var.vnet_name
  resource_group_name = var.vnet_rg_name
}

data "azurerm_subnet" "veritas_subnet" {
  depends_on = [ module.vnet_resource_group ]
  provider             = azurerm.veritas
  count                = length(var.subnet_name)
  name                 = var.subnet_name[count.index]
  virtual_network_name = data.azurerm_virtual_network.veritas_vnet.name
  resource_group_name  = data.azurerm_virtual_network.veritas_vnet.resource_group_name
}

# ----------------------------------------------
# Create Resource Group
# ----------------------------------------------

module "veritas_resource_group" {
  providers = {
    azurerm = azurerm.veritas
  }
  source  = "./module/terraform-azurerm-avm-res-resources-resourcegroup"
  for_each = toset(var.veritas_resource_group)
  name    = each.value
  location = var.azure_region
  
}
module "vnet_resource_group" {
  providers = {
    azurerm = azurerm.veritas
  }
  source  = "./module/terraform-azurerm-avm-res-resources-resourcegroup"
  name    = var.vnet_rg_name
  location = var.azure_region
  
}

# ----------------------------------------------
# Create Key Vault
# ----------------------------------------------

data "azurerm_client_config" "current" {}

resource "random_password" "admin_password" {
  length           = 12
  min_lower = 2
  min_upper = 2
  min_numeric = 2
  min_special = 2
  special          = true
  override_special = "_%@"
  
}

# module "veritas_keyvault" {
#   providers = {
#     azurerm = azurerm.veritas
#   }
#   source  = "./module/terraform-azurerm-avm-res-keyvault-vault"
#   for_each = var.key_vault_veritas

#   settings = each.value
#   application_id = var.application_id
#   location = var.azure_region
#   environment = var.environment
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   resource_group_name = module.veritas_resource_group[each.value.resource_group_key].name
#   enabled_for_disk_encryption = true
#   soft_delete_retention_days = var.soft_delete_retention_days
#   purge_protection_enabled = var.purge_protection_enabled

#   network_acls = {
#     default_action = "Allow"
#     bypass         = "AzureServices"
#   }

#   role_assignments = {
#     deployment_user_secrets = {
#       role_definition_name = "Key Vault Secrets Officer"
#       principal_id         = data.azurerm_client_config.current.object_id
#     }
#   } 

#   wait_for_rbac_before_key_operations = {
#     create = "60s"
#   }

#   wait_for_rbac_before_secret_operations = {
#     create = "60s"
#   }

#   Secrets = {
#     admin_password = {
#       name = "vtsvm"
#       content_type = "vtsvm"
#       expiration_date = time_offset.expiry_date.rfc3339
#       not_before_date = timestamp()
#     }
#   }

#   secret_value = {
#     admin_password = "P@ssw0rd1234"
#   }



# }  

# ----------------------------------------------
# Create Virtual Machine
# ----------------------------------------------

module "avm_res_virtual_machine_veritas" {
  providers = {
    azurerm = azurerm.veritas
  }
  source  = "./module/terraform-azurerm-avm-res-compute-virtualmachine"
  for_each = var.virtual_machine_veritas
  name     = each.value

  admin_username = var.admin_username
  admin_password = random_password.admin_password.result
  location       = var.azure_region
  resource_group_name = module.veritas_resource_group[each.value.resource_group_vm].name
  disable_password_authentication = false
  enable_telemetry = var.enable_telemetry
  encryption_at_host_enabled = var.encryption_at_host_enabled
  generate_admin_password_or_ssh_key = var.generate_admin_password_or_ssh_key
  environment = var.environment
  application_id = var.application_id
  os_type = "Linux"
  zone = each.value.zone
  size = var.size

  network_interfaces = {
    network_interface_1 = {
      name = "veritas-nic-ipconfig-${each.value.inc}"
      ip_configurations = {
        ip_configuration_1 = {
          name = "veritas-nic-ipconfig-${each.value.inc}"
          subnet_id = data.azurerm_subnet.veritas_subnet[count.index].id
          private_ip_address_allocation = "Dynamic"
        }
      }

    }
  }

  os_disk = {
    caching = "ReadWrite"
    storage_account_type = "Standard_SSD"
    disk_size_gb = 128
  }

}
