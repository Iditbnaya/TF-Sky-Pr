module "fw-name" {
  source = "../naming"

  resource_type = "fw"
  name = "${var.name}"
  region = var.region
}

module "pip-name" {
  source = "../naming"

  resource_type = "pip"
  name = "${var.name}-fw-pip"
  region = var.region
}

resource "azurerm_public_ip" "firewall_public_ip" {
  name = module.pip-name.standard_name
  location = var.region
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name = module.fw-name.standard_name
  location = var.region
  resource_group_name = var.resource_group_name
  sku_name = var.sku_name
  sku_tier = var.sku_tier
  
  ip_configuration {
    name = "fw-ip-config"
    subnet_id = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }

  depends_on = [ azurerm_public_ip.firewall_public_ip ]
}
