variable "network_manager_id" {
  type = string
}

variable "ipam_pool_id" {
  type = string
}

variable "spokes" {
  type = map(object({
    resource_group_name = string
    region = string
    network_group_id = string
  }))
}

variable "fw_private_ip" {
  type = string
}

variable "nm_resource_group_name" {
  type = string
}

variable "existing_hub_vnet_id" {
  type = string
}

variable "connectivity_config" {
  type = object({
    name = string
  })
}
