# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
  environment = "china"
}

variable "azure_location" {
  type        = string
  description = "Azure Location"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group"
  default     = "ArcBox-mooncake-RG"
}

variable "client_vm_name" {
  type        = string
  description = "The name of the client virtual machine."
  default     = "ArcBox-Client"
}

variable "capi_vm_name" {
  type        = string
  description = "The name of the client virtual machine."
  default     = "ArcBox-CAPI-MGMT"
}

variable "rancher_vm_name" {
  type        = string
  description = "The name of the client virtual machine."
  default     = "ArcBox-K3s"
}

variable "virtual_network_name" {
  type        = string
  description = "ArcBox vNET name."
  default     = "ArcBox-vNET"
}

variable "subnet_name" {
  type        = string
  description = "ArcBox subnet name."
  default     = "ArcBox-Subnet"
}

variable "workspace_name" {
  type        = string
  description = "Log Analytics workspace name."
  default     = "ArcBox-Workspace"
}

variable "github_username" {
  type        = string
  description = "User's github account where they have forked https://github.com/microsoft/azure-arc-jumpstart-apps"
  default     = "microsoft"
}

variable "github_repo" {
  type        = string
  description = "Specify a GitHub repo (used for testing purposes)"
  default     = "microsoft"
}

variable "github_branch" {
  type        = string
  description = "Specify a GitHub branch (used for testing purposes)"
  default     = "main"
}

variable "spn_client_id" {
  type        = string
  description = "Arc Service Principal clientID."
}

variable "spn_client_secret" {
  type        = string
  description = "Arc Service Principal client secret."
  sensitive   = true
}

variable "spn_tenant_id" {
  type        = string
  description = "Arc Service Principal tenantID."
}

variable "client_admin_username" {
  type        = string
  description = "Username for the client virtual machine."
  default     = "arcdemo"
}

variable "client_admin_password" {
  type        = string
  description = "Password for Windows admin account. Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character. The value must be between 12 and 123 characters long."
  default     = "ArcPassword123!!"
  sensitive   = true
}

variable "client_admin_ssh" {
  type        = string
  description = "SSH Key for the Linux VM's."
  sensitive   = true
}

variable "deploy_bastion" {
  type        = bool
  description = "Choice to deploy Azure Bastion"
  default     = false
}

### This should be swapped to a lower-case value to avoid case sensitivity ###
variable "deployment_flavor" {
  type        = string
  description = "The flavor of ArcBox you want to deploy. Valid values are: 'Full', 'ITPro', or 'DevOps'."
  default     = "ITPro"

  validation {
    condition     = contains(["Full", "ITPro", "DevOps"], var.deployment_flavor)
    error_message = "Valid options for Deployment Flavor: 'Full', 'ITPro', and 'DevOps'."
  }
}
##############################################################################

locals {
  template_base_url = "https://eslzfiles.blob.core.chinacloudapi.cn/azure-arc/"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.azure_location
}

module "management_storage" {
  source = "./modules/mgmt/mgmtStorage"

  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "management_artifacts" {
  source = "./modules/mgmt/mgmtArtifacts"

  resource_group_name  = azurerm_resource_group.rg.name
  spn_client_id        = var.spn_client_id
  virtual_network_name = var.virtual_network_name
  subnet_name          = var.subnet_name
  workspace_name       = var.workspace_name
  deploy_bastion       = var.deploy_bastion
  deployment_flavor    = var.deployment_flavor

  depends_on = [azurerm_resource_group.rg]
}

module "management_policy" {
  source = "./modules/mgmt/mgmtPolicy"

  resource_group_name = azurerm_resource_group.rg.name
  workspace_name      = var.workspace_name
  workspace_id        = module.management_artifacts.workspace_id
  deployment_flavor   = var.deployment_flavor

  depends_on = [azurerm_resource_group.rg]
}

module "client_vm" {
  source = "./modules/clientVmMooncake"

  resource_group_name  = azurerm_resource_group.rg.name
  vm_name              = var.client_vm_name
  virtual_network_name = var.virtual_network_name
  subnet_name          = var.subnet_name
  template_base_url    = local.template_base_url
  storage_account_name = module.management_storage.storage_account_name
  workspace_name       = var.workspace_name
  spn_client_id        = var.spn_client_id
  spn_client_secret    = var.spn_client_secret
  spn_tenant_id        = var.spn_tenant_id
  deployment_flavor    = var.deployment_flavor
  admin_username       = var.client_admin_username
  admin_password       = var.client_admin_password
  github_username      = var.github_username
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  deploy_bastion       = var.deploy_bastion

  depends_on = [
    azurerm_resource_group.rg,
    module.management_artifacts,
    module.management_storage
  ]
}
