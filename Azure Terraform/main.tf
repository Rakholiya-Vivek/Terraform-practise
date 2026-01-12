variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

# Provider block for Azure
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

#------------------------------------------------------------------------

# Create a new Virtual Network (VNet)
resource "azurerm_virtual_network" "my_vnet" {
  name                = "MyNewVNet"
  location            = "East US"
  resource_group_name = "MyResourceGroup"
  address_space       = ["10.0.0.0/16"]  # Example address space

  tags = {
    environment = "Terraform"
  }
}

# Create a new Subnet inside the new Virtual Network
resource "azurerm_subnet" "my_subnet" {
  name                 = "MyNewSubnet"
  resource_group_name  = "MyResourceGroup"
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]  # Example subnet range

  # Optional: Add Network Security Group (NSG) or route table if needed
}

# Reference the existing Public IP (MyVMPublicIP)
data "azurerm_public_ip" "my_existing_public_ip" {
  name                = "MyVMPublicIP"
  resource_group_name = "MyResourceGroup"  # Your resource group name
}

# Create the Network Interface (NIC) and associate it with the new subnet and public IP
resource "azurerm_network_interface" "my_nic" {
  name                = "myVMNIC"
  location            = "East US"
  resource_group_name = "MyResourceGroup"

  ip_configuration {
    name                          = "internal"
    subnet_id                    = azurerm_subnet.my_subnet.id  # Associating with the newly created subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = data.azurerm_public_ip.my_existing_public_ip.id  # Associate with the existing public IP
  }
}

# Create the Virtual Machine and associate the NIC
resource "azurerm_virtual_machine" "my_vm" {
  name                  = "MyVM"
  location              = "East US"
  resource_group_name   = "MyResourceGroup"
  network_interface_ids = [azurerm_network_interface.my_nic.id]  # Referencing the NIC we created earlier
  vm_size               = "Standard_B1s"

  # OS Image Reference
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # OS Disk
  storage_os_disk {
    name          = "my-os-disk"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "my-vm"
    admin_username = "azureuser"
  }

  # SSH Key-based Authentication
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")  # Use the existing public SSH key
      path     = "/home/azureuser/.ssh/authorized_keys"  # The location on the VM where the key will be placed
    }
  }
}
#-----------------------------------------------------------------------------

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "Southeast Asia"
}

# Create a Virtual Network (Optional, for secure access)
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Create a Subnet (Optional)
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

   depends_on = [
    azurerm_virtual_network.example
  ]
}

# Create the MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "example" {
  name                     = "example-mysql-serverrr"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  version                  = "8.0.21"  # MySQL version (e.g., 8.0 or 5.7)
  administrator_login      = "mysqladmin"
  administrator_password   = "YourSecurePassword123"  # Make sure to use a secure password

  sku_name = "B_Standard_B1ms"  # SKU for the MySQL flexible server

  storage {
    size_gb = 32  # Size of the disk (in GB)
  }

}