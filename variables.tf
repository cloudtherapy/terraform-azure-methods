variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "methods_client_id" {
  type        = string
  sensitive   = true
  description = "Client ID of the Azure Application"
}

variable "methods_client_secret" {
  type        = string
  sensitive   = true
  description = "Client Secret of the Azure Application"
}

variable "methods_tenant_id" {
  type        = string
  sensitive   = true
  description = "Tenant ID of the Azure Application"
}

variable "methods_subscription_id" {
  type        = string
  sensitive   = true
  description = "Subscription ID of the Azure Application"
}

variable "vpn_passphrase" {
  type        = string
  sensitive   = true
  description = "VPN Passphrase"
}