variable "spoke" {
  type = list(
    object(
      {
        resource_group_name = string,
        vnets = list(
          object({
            name        = string,
            subnet_mask = number,
            subnets = list(object({
              name               = string,
              subnet_mask        = number,
              is_firewall_subnet = optional(bool),
              is_bastion_subnet  = optional(bool)
            }))
          })
        )
      }
    )
  )
}

variable "network_manager_id" {
  type = string
}

variable "ipam_pool_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "region" {
  type = string
}

variable "hub_id" {
  type = string
  nullable = true
  default = null
}

variable "fw_private_ip" {
  type = string
  nullable = true
  default = null
}
