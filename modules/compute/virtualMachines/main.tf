

data "azurerm_network_interface" "networkinterface" {
  for_each = {for networkinterface in var.network_interface_details:networkinterface.network_interface_name=>networkinterface}
 name=each.key
 resource_group_name = var.resource_group_name
}

resource "azurerm_linux_virtual_machine" "virtualmachines" {
  for_each = {for machine in var.virtual_machine_details:machine.virtual_machine_name=>machine}
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "linuxadmin"
  admin_password = "Azure@123"
  disable_password_authentication = false  
  network_interface_ids = [
    data.azurerm_network_interface.networkinterface[each.value.network_interface_name].id
  ]


  lifecycle {
    ignore_changes = [ identity ]
  }
    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

