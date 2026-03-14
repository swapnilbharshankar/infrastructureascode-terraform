terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "4.64.0"
        } 
    }
}
provider "azurerm" {
    # Configuration options 
    features {
        resource_group {
            prevent_deletion_if_contains_resources = false
        }
    }
}