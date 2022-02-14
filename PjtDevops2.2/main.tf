# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "DevOpsgroup" {
    name     = "RessourcesDevOps"
    location = "francecentral"

    tags = {
        environment = "pjtDevOps"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "DevOpsnetwork" {
    name                = "DevOpsnet"
    address_space       = ["10.0.0.0/16"]
    location            = "francecentral"
    resource_group_name = azurerm_resource_group.DevOpsgroup.name

    tags = {
        environment = "pjtDevOps"
    }
}

# Create subnet
resource "azurerm_subnet" "DevOpssubnet" {
    name                 = "DevOpsSubnet"
    resource_group_name  = azurerm_resource_group.DevOpsgroup.name
    virtual_network_name = azurerm_virtual_network.DevOpsnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "DevOpspublicip" {
    name                         = "myPublicIP"
    location                     = "francecentral"
    resource_group_name          = azurerm_resource_group.DevOpsgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "pjtDevOps"
    }
}

resource "azurerm_public_ip" "DevOpspublicip2" {
    name                         = "myPublicIP2"
    location                     = "francecentral"
    resource_group_name          = azurerm_resource_group.DevOpsgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "pjtDevOps"
    }
}

resource "azurerm_public_ip" "DevOpspublicip3" {
    name                         = "myPublicIP3"
    location                     = "francecentral"
    resource_group_name          = azurerm_resource_group.DevOpsgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "pjtDevOps"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "DevOpsnsg" {
    name                = "SecurityGroupPjtDevops"
    location            = "francecentral"
    resource_group_name = azurerm_resource_group.DevOpsgroup.name

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

     security_rule {
        name                       = "TCP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    tags = {
        environment = "pjtDevOps"
    }
}

# Create network interface
resource "azurerm_network_interface" "DevOpsnic" {
    name                      = "myNIC"
    location                  = "francecentral"
    resource_group_name       = azurerm_resource_group.DevOpsgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.DevOpssubnet.id
       # private_ip_address_allocation = "Dynamic"
       # public_ip_address_id          = azurerm_public_ip.DevOpspublicip.id
         private_ip_address_allocation = "static"
         private_ip_address            = "10.0.1.10"
        #private_ip_address            = "${cidrhost(10.0.1.4/27, 4)}"
         public_ip_address_id          = azurerm_public_ip.DevOpspublicip.id
    }

    tags = {
        environment = "pjtDevOps"
    }
}

resource "azurerm_network_interface" "DevOpsnic2" {
    name                      = "myNIC2"
    location                  = "francecentral"
    resource_group_name       = azurerm_resource_group.DevOpsgroup.name

    ip_configuration {
        name                          = "myNicConfiguration2"
        subnet_id                     = azurerm_subnet.DevOpssubnet.id
       private_ip_address_allocation = "static"
         private_ip_address            = "10.0.1.11"
        public_ip_address_id          = azurerm_public_ip.DevOpspublicip2.id
    }

    tags = {
        environment = "pjtDevOps"
    }
}

resource "azurerm_network_interface" "DevOpsnic3" {
    name                      = "myNIC3"
    location                  = "francecentral"
    resource_group_name       = azurerm_resource_group.DevOpsgroup.name

    ip_configuration {
        name                          = "myNicConfiguration3"
        subnet_id                     = azurerm_subnet.DevOpssubnet.id
       private_ip_address_allocation = "static"
         private_ip_address            = "10.0.1.12"
        public_ip_address_id          = azurerm_public_ip.DevOpspublicip3.id
    }

    tags = {
        environment = "pjtDevOps"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.DevOpsnic.id
    network_security_group_id = azurerm_network_security_group.DevOpsnsg.id
}

resource "azurerm_network_interface_security_group_association" "example2" {
    network_interface_id      = azurerm_network_interface.DevOpsnic2.id
    network_security_group_id = azurerm_network_security_group.DevOpsnsg.id
}

resource "azurerm_network_interface_security_group_association" "example3" {
    network_interface_id      = azurerm_network_interface.DevOpsnic3.id
    network_security_group_id = azurerm_network_security_group.DevOpsnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.DevOpsgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.DevOpsgroup.name
    location                    = "francecentral"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "pjtDevOps"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "DevOpsvm" {
    name                  = "VmPjt"
    location              = "francecentral"
    resource_group_name   = azurerm_resource_group.DevOpsgroup.name
    network_interface_ids = [azurerm_network_interface.DevOpsnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "VmPjt"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "pjtDevOps"
    }
}

resource "azurerm_linux_virtual_machine" "DevOpsvm2" {
    name                  = "VmPjt2"
    location              = "francecentral"
    resource_group_name   = azurerm_resource_group.DevOpsgroup.name
    network_interface_ids = [azurerm_network_interface.DevOpsnic2.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk2"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "VmPjt2"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "pjtDevOps"
    }
}


resource "azurerm_linux_virtual_machine" "DevOpsvm3" {
    name                  = "VmPjt3"
    location              = "francecentral"
    resource_group_name   = azurerm_resource_group.DevOpsgroup.name
    network_interface_ids = [azurerm_network_interface.DevOpsnic3.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk3"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "LoadBalancer"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "pjtDevOps"
    }
}


