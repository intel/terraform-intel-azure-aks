terraform {
  required_version = ">=1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.86"
      #version = ">= 3.47, < 4.0"
    }
    curl = {
      source  = "anschoewe/curl"
      version = "1.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}