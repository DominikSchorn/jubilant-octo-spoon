locals {
  test = true
}

resource "random_pet" "this" {
  count = local.test ? 10 : 0
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "echo '192.168.0.1'"
  }
}

resource "azurerm_storage_account" "this" {
  name                            = "this"
  resource_group_name             = "this"
  location                        = "this"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

