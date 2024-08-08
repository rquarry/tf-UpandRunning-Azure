output "tfState Storage Blob ID" {
    value = azurerm_storage_blob.tfStateStorage.id
}

output "tfState Storage Blob URL" {
    value = azurerm_storage_blob.tfStateStorage.url
}

output "primary access key" {
  value = azurerm_storage_account.persistent_storage.primary_access_key
}

output "secondary access key " {
    value = azurerm_storage_account.persistent_storage.secondary_access_key
}