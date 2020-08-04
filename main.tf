# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>2.0"
    features {}
}

# Provision Resource Group
resource "azurerm_resource_group" "udacitynd" {
 name     = var.resource_gn
 location = "East US"

  tags     = var.tags
}

# Provision Virtula Network
resource "azurerm_virtual_network" "udacitynd" {
 name                = "${var.resource_name_prefix}VirtualNetwork"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.udacitynd.location
 resource_group_name = azurerm_resource_group.udacitynd.name

  tags     = var.tags
}

# Provision Subnet
resource "azurerm_subnet" "udacitynd" {
 name                 = "${var.resource_name_prefix}Subnet"
 resource_group_name  = azurerm_resource_group.udacitynd.name
 virtual_network_name = azurerm_virtual_network.udacitynd.name
 address_prefixes      = ["10.0.2.0/24"]
}

# Provision Public IP
resource "azurerm_public_ip" "udacitynd" {
 name                         = "${var.resource_name_prefix}publicIPForLB"
 location                     = azurerm_resource_group.udacitynd.location
 resource_group_name          = azurerm_resource_group.udacitynd.name
 allocation_method            = "Static"

  tags     = var.tags
}

# Provision Load Balanacer
resource "azurerm_lb" "udacitynd" {
 name                = "${var.resource_name_prefix}loadBalancer"
 location            = azurerm_resource_group.udacitynd.location
 resource_group_name = azurerm_resource_group.udacitynd.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.udacitynd.id
 }

 tags     = var.tags
}

resource "azurerm_lb_backend_address_pool" "udacitynd" {
 resource_group_name = azurerm_resource_group.udacitynd.name
 loadbalancer_id     = azurerm_lb.udacitynd.id
 name                = "${var.resource_name_prefix}BackEndAddressPool"

}

# Provision Network Security Group
resource "azurerm_network_security_group" "udacitynd" {
    name                = "${var.resource_name_prefix}NetworkSecurityGroup"
    location            = azurerm_resource_group.udacitynd.location
    resource_group_name = azurerm_resource_group.udacitynd.name
    
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
        name                       = "Internet"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    # Alternative solution for deny internet traffic
    #    security_rule {
    #     name                       = "Internet_http"
    #     priority                   = 1003
    #     direction                  = "Inbound"
    #     access                     = "Deny"
    #     protocol                   = "Tcp"
    #     source_port_range          = "*"
    #     destination_port_range     = "80"
    #     source_address_prefix      = "*"
    #     destination_address_prefix = "*"
    # }
    #    security_rule {
    #     name                       = "Internet_https"
    #     priority                   = 1004
    #     direction                  = "Inbound"
    #     access                     = "Deny"
    #     protocol                   = "Tcp"
    #     source_port_range          = "*"
    #     destination_port_range     = "443"
    #     source_address_prefix      = "*"
    #     destination_address_prefix = "*"
    # }
    

  tags     = var.tags
}

# Provision Network Interface Card 
resource "azurerm_network_interface" "udacitynd" {
 count               = var.number_instance
 name                = "${var.resource_name_prefix}NIC_${count.index}"
 location            = azurerm_resource_group.udacitynd.location
 resource_group_name = azurerm_resource_group.udacitynd.name

 ip_configuration {
   name                          = "udacityndConfiguration"
   subnet_id                     = azurerm_subnet.udacitynd.id
   private_ip_address_allocation = "dynamic"
 }
  tags     = var.tags
}

# Associate  the security group to the network interface card
resource "azurerm_network_interface_security_group_association" "udacitynd" {
    count                    = var.number_instance
    network_interface_id = azurerm_network_interface.udacitynd[count.index].id
    network_security_group_id = azurerm_network_security_group.udacitynd.id

}

# Provision Mangaed Disk
resource "azurerm_managed_disk" "udacitynd" {
 count                = var.number_instance
 name                 = "${var.resource_name_prefix}DataDiskExisting_${count.index}"
 location             = azurerm_resource_group.udacitynd.location
 resource_group_name  = azurerm_resource_group.udacitynd.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"

tags     = var.tags
}

# Provision Availability Set
resource "azurerm_availability_set" "avset" {
 name                         = "${var.resource_name_prefix}AvailabilitySet"
 location                     = azurerm_resource_group.udacitynd.location
 resource_group_name          = azurerm_resource_group.udacitynd.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true

 tags     = var.tags
}

# Packer Image Resource Group
 data "azurerm_resource_group" "image" {
  name = "udacityNDResourceGroup"
}

# Packer Image
data "azurerm_image" "image" {
  name                = "udacityNDDeployWebServerPackerImage"
  resource_group_name = data.azurerm_resource_group.image.name
}

# Provision Virtual Machine
resource "azurerm_virtual_machine" "udacitynd" {
 count                 = var.number_instance
 name                  = "${var.resource_name_prefix}VirtualMachine_${count.index}"
 location              = azurerm_resource_group.udacitynd.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.udacitynd.name
 network_interface_ids = [element(azurerm_network_interface.udacitynd.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true


 storage_image_reference {
   id=data.azurerm_image.image.id
 }

 storage_os_disk {
   name              = "${var.resource_name_prefix}OSDisk_${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Provision Optional Data Disks
 storage_data_disk {
   name              = "${var.resource_name_prefix}DataDiskNew_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "1023"
 }

 storage_data_disk {
   name            = element(azurerm_managed_disk.udacitynd.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.udacitynd.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.udacitynd.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = var.admin_uname
   admin_password = var.admin_pwd
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

tags     = var.tags
}
