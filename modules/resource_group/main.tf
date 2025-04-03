module "rg_name" {
  source = "../naming"
  
  resource_type = "resource_group"
  name          = var.name
  region        = var.region
}

resource "azapi_resource" "this" {
  type = "Microsoft.Resources/resourceGroups@2024-07-01"
  name = module.rg_name.standard_name
  location = var.region
  tags = var.tags
}