provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "app" {
  name     = "rg-${var.app}-${random_string.suffix.result}"
  location = var.location
  tags     = { hashicorp-learn = "circleci", label = var.label }
}

resource "azurerm_storage_account" "app" {
  name                     = "st${lower(replace(var.app, "/[^a-zA-Z0-9]/", ""))}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.app.name
  location                 = azurerm_resource_group.app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = { hashicorp-learn = "circleci", label = var.label }
}

resource "azurerm_storage_account_static_website" "app" {
  storage_account_id = azurerm_storage_account.app.id
  index_document     = "index.html"
  error_404_document = "error.html"
}

resource "azurerm_storage_blob" "app" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.app.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = "./assets/index.html"

  depends_on = [azurerm_storage_account_static_website.app]
}