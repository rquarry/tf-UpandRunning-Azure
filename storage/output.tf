output "tfState_Storage" {
    value = azurerm_storage_blob.tfStateStorage.id
}

output "tfState_Storage_Blob_URL" {
    value = azurerm_storage_blob.tfStateStorage.url
}

output "primary_access_key" {
  value = azurerm_storage_account.persistent_storage.primary_access_key
  sensitive = true
}

output "secondary_access_key" {
    value = azurerm_storage_account.persistent_storage.secondary_access_key
    sensitive = true
}