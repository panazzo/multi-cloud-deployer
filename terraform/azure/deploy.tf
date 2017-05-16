resource "azurerm_resource_group" "resource_group_test" {
  name     = "resource-group-multi-cloud-deployer-test"
  location = "West US"
}

resource "azurerm_virtual_network" "virtual_network_test" {
  name                = "virtualnetworkmulticlouddeployertest"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.resource_group_test.name}"
}

resource "azurerm_subnet" "subnet_test" {
  name                 = "subnetmulticlouddeployertest"
  resource_group_name  = "${azurerm_resource_group.resource_group_test.name}"
  virtual_network_name = "${azurerm_virtual_network.virtual_network_test.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "public_ip_test" {
  name                         = "publicipmulticlouddeployertest"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.resource_group_test.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "publicipmulticlouddeployertest"
  }
}

resource "azurerm_network_interface" "network_interface_test" {
  name                 = "networkinterfacemulticlouddeployertest"
  location             = "West US"
  resource_group_name  = "${azurerm_resource_group.resource_group_test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.subnet_test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip_test.id}"
  }
}


resource "azurerm_storage_account" "storage_account_test" {
  name                = "storageaccountpanazzo"
  resource_group_name = "${azurerm_resource_group.resource_group_test.name}"
  location            = "westus"
  account_type        = "Standard_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "storage_container_test" {
  name                  = "storagecontainermulticlouddeployertest"
  resource_group_name   = "${azurerm_resource_group.resource_group_test.name}"
  storage_account_name  = "${azurerm_storage_account.storage_account_test.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "virtual_machine_test" {
  name                  = "virtualmachinemulticlouddeployertest"
  location              = "West US"
  resource_group_name   = "${azurerm_resource_group.resource_group_test.name}"
  network_interface_ids = ["${azurerm_network_interface.network_interface_test.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "14.04.2-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "osdiskmulticlouddeployertest"
    vhd_uri       = "${azurerm_storage_account.storage_account_test.primary_blob_endpoint}${azurerm_storage_container.storage_container_test.name}/osdiskmulticlouddeployertest.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234"
    custom_data = "${file("install.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}