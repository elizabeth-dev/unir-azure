resource "azurerm_virtual_network" "k8s_vnet" {
  name = "k8snet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "k8s_subnet" {
  name = "k8s_subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "node_ip" {
  for_each = var.vms
  name = "ip-${each.key}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  sku = "Basic"
}

resource "azurerm_network_interface" "node_nic" {
  for_each = var.vms
  name = "nic-${each.key}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true
  internal_dns_name_label = each.key

  ip_configuration {
	name = "ipconf-${each.key}"
	subnet_id = azurerm_subnet.k8s_subnet.id
	private_ip_address_allocation = "Static"
	private_ip_address = each.value
	public_ip_address_id = azurerm_public_ip.node_ip[each.key].id
  }
}
