resource "azurerm_network_security_group" "k8s_sg" {
  name = "sshTraffic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
	  name = "SSH"
	  priority = 1001
	  direction = "Inbound"
	  access = "Allow"
	  protocol = "Tcp"
      source_port_range = "*"
	  destination_port_range = "22"
	  source_address_prefix = "*"
	  destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "k8s_nic-sg" {
  for_each = var.vms
  network_interface_id = azurerm_network_interface.node_nic[each.key].id
  network_security_group_id = azurerm_network_security_group.k8s_sg.id
}
