# * Terraform Configuration to create nOps Enterprise Application
# Todo: Put this block into a versions.tf file
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }

  #backend "azurerm" {
  #  resource_group_name  = "rg-methods-terraform"
  #  storage_account_name = "methodsmpnterraform"
  #  container_name       = "methods-terraform-state"
  #  key                  = "azure-methods/nops.tfstate"
  #  subscription_id      = "eef2d7b1-c33f-48ec-a949-5b87caad5c13"
  #}
}

provider "azurerm" {
  features {}
  subscription_id = "eef2d7b1-c33f-48ec-a949-5b87caad5c13"
}

provider "azuread" {
  tenant_id = "a0728e0e-8468-4c6a-bb7b-9f21a8d2cbbd"
}

# This sets a datasource that uses the locally logged in user via Azure CLI as the principal for this terraform execution
data "azuread_client_config" "current" {}

# This creates a datasource in Terraform that reads in all of the defined published_app_ids that exist in the Azure. The results that this produces are then called in the code
# to be used for the specific API permissions required. 
data "azuread_application_published_app_ids" "well_known" {}

# This uses the azuread_application_published_app_ids datasource results and references a new datasource in Terraform that reads in the defined published_app_id
# for Microsoft Graph that exists in the Azure.
data "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# This uses the azuread_application_published_app_ids datasource results and references a new datasource in Terraform that reads in the defined published_app_id
# for Azure Service Management that exists in the Azure. 
data "azuread_service_principal" "azure_service_management" {
  application_id = data.azuread_application_published_app_ids.well_known.result.AzureServiceManagement
}

# This code block will spit out the output of the Azure Service Management object ID it has found in the azuread_application_published_app_ids results to the console
#output "published_app_ids" {
#  value = data.azuread_application_published_app_ids.well_known.result["AzureServiceManagement"]
#}

#This code block will spit out the output of the AuditLog.Read.All API permission ID that is scoped to the Microsoft Graph application ID it has found in the 
#azuread_application_published_app_ids results to the console. This essentially will read in the possible API permissions to toggle and give you the object ID of the
#AuditLog.Read.All permission. Remove the trailking [] and it will spit out the full list of possible API id values. This references the DELEGATED permissions for
#Microsoft Graphs

#output "published_msgraph_delegated_ids_apis" {
#  value = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.Read.All"]
#}


#This code block will spit out the output of the Directory.Read.All API permission ID that is scoped to the Microsoft Graph application ID it has found in the 
#azuread_application_published_app_ids results to the console. This essentially will read in the possible API permissions to toggle and give you the object ID of the
#AuditLog.Read.All permission. Remove the trailking [] and it will spit out the full list of possible API id values. This references the APPLICATION permissions for
#Microsoft Graphs

#output "published_msgraph_application_ids_roles" {
#  value = data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
#}

resource "azuread_application" "tf-nops" {
  display_name     = "tf-nops"
  sign_in_audience = "AzureADMyOrg"
  web {
    redirect_uris = [
      "https://localhost/",
    ]

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
  # This references the Azure Service Management published app and reads the user_impersonation API object ID from the datasoure built above to give permission
  # to this azuread application being create at the scope level
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["AzureServiceManagement"]

    resource_access {
      id   = data.azuread_service_principal.azure_service_management.oauth2_permission_scope_ids["user_impersonation"]
      type = "Scope"
    }
  }

  # This references the Microsoft Graph published app and reads the 4 API object IDs from the datasoure built above to give permission
  # to this azuread application being create at the scope and role level. Scope is a Delegated permission and Role is an Application permission. 
  # These id's can be seen by uncommenting the outputs above to list them 
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read.All"]
      type = "Scope"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["AuditLog.Read.All"]
      type = "Role"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Reports.Read.All"]
      type = "Role"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
      type = "Role"
    }
  }
}

# Create a client secret for application id
resource "azuread_application_password" "tf-nops" {
  end_date              = "2299-12-30T23:00:00Z" # Forever
  application_object_id = azuread_application.tf-nops.object_id
  display_name          = "tf-nops-secret"
}

output "published_tf_nops_secret" {
  value = nonsensitive(azuread_application_password.tf-nops.value)
}

