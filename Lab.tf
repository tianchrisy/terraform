# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "TestEnvi_RG" {
  name     = "TestEnvi-RG"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "TestEnvi_Vnet" {
  name                = "TestEnvi-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TestEnvi_RG.location
  resource_group_name = azurerm_resource_group.TestEnvi_RG.name
}

# Subnet
resource "azurerm_subnet" "TestEnvi_Subnet" {
  name                 = "TestEnvi-subnet"
  resource_group_name  = azurerm_resource_group.TestEnvi_RG.name
  virtual_network_name = azurerm_virtual_network.TestEnvi_Vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "TestEnvi_NIC" {
  name                = "TestEnvi-nic"
  location            = azurerm_resource_group.TestEnvi_RG.location
  resource_group_name = azurerm_resource_group.TestEnvi_RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.TestEnvi_Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.TestEnvi_pip.id
  }
}

# Public IP
resource "azurerm_public_ip" "TestEnvi_pip" {
  name                = "TestEnvi-pip"
  location            = azurerm_resource_group.TestEnvi_RG.location
  resource_group_name = azurerm_resource_group.TestEnvi_RG.name
  allocation_method   = "Dynamic"
}

# Network Security Group
resource "azurerm_network_security_group" "TestEnvi_nsg" {
  name                = "TestEnvi-nsg"
  location            = azurerm_resource_group.TestEnvi_RG.location
  resource_group_name = azurerm_resource_group.TestEnvi_RG.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "TestEnvi_Subnet_NSG" {
  subnet_id                 = azurerm_subnet.TestEnvi_Subnet.id
  network_security_group_id = azurerm_network_security_group.TestEnvi_nsg.id
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "TestEnvi_VM" {
  name                = "TestEnvi-vm"
  resource_group_name = azurerm_resource_group.TestEnvi_RG.name
  location            = azurerm_resource_group.TestEnvi_RG.location
  size                = "Standard_E8_v4"
  admin_username      = ""
  admin_password      = ""

  network_interface_ids = [
    azurerm_network_interface.TestEnvi_NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  storage_data_disk {
    lun                  = 0
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = 256
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Standard"
    version   = "latest"
  }
}
