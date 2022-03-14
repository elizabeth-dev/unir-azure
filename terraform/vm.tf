resource "azurerm_linux_virtual_machine" "k8s_nodes" {
  for_each = var.vms
  name = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = var.vm_size
  admin_username = "azadmin"
  network_interface_ids = [azurerm_network_interface.node_nic[each.key].id]
  disable_password_authentication = true

  custom_data = each.key == "master" ? data.cloudinit_config.master_cloudinit.rendered : data.cloudinit_config.worker_cloudinit.rendered

  admin_ssh_key {
	  username = "azadmin"
	  public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
	caching = "ReadWrite"
	storage_account_type = "Standard_LRS"
  }

  source_image_reference {
	publisher = "Canonical"
	offer = "0001-com-ubuntu-server-focal-daily"
	sku = "20_04-daily-lts-gen2"
	version = "20.04.202203100"
  }

  boot_diagnostics {
	storage_account_uri = azurerm_storage_account.stAcc.primary_blob_endpoint
  }

}