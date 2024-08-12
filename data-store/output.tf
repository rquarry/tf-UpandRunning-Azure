output "address" {
    value = azurerm_mysql_flexible_server.az_flexsv1.fqdn
    description = "FQDN of server "
}