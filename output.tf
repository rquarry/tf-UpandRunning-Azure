output "public_ip" {
    value = azurerm_public_ip.vmip[1].ip_address
}