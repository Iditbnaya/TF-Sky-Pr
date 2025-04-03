module "bastion_name" {
  source = "../naming"

  resource_type = "bastion"
  name = "${var.name}-bastion"
  region = var.region
}

module "pip-name" {
  source = "../naming"

  resource_type = "pip"
  name = "${var.name}-bastion-pip"
  region = var.region
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name = module.pip-name.standard_name
  location = var.region
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name = module.bastion_name.standard_name
  location = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "bastion-ip-config"
    subnet_id = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }

  depends_on = [ azurerm_public_ip.bastion_public_ip ]
}
