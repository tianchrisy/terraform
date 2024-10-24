resource "azurerm_resource_group" "practiceName_RG" {
  name     = "example-resources"
  location = "Central US"

  tags = {
    environment = "practiceInfrastructure"
  }
}

resource "azurerm_virtual_machine" "virtualMachineDC1" {
  name                = "virtualMachineDC1"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.practiceName_RG.name
  vm_size             = "Standard_E4s_v3"

  storage_os_disk {
    name              = var.practiceName + "-osdisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 127
    
  }
  os_profile {
    computer_name  = var.practiceName + "-DC1"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  network_interface_ids = [
    azurerm_network_interface.virtualMachineDC1_nic.id,
  ]


  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "practiceInfrastructure"
  }

}
