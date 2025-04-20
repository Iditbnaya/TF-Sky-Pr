resource "azurerm_firewall_network_rule_collection" "this" {
  name                = var.name
  azure_firewall_name = var.azure_firewall_name
  resource_group_name = var.resource_group_name
  priority            = var.priority
  action              = var.action

  dynamic "rule" {
    for_each = var.rules
    content {
      name = rule.value.name
      source_addresses = rule.value.source_addresses != null ? rule.value.source_addresses : null
      source_ip_groups = rule.value.source_ip_groups != null ? rule.value.source_ip_groups : null
      destination_addresses = rule.value.destination_addresses != null ? rule.value.destination_addresses : null
      destination_ip_groups = rule.value.destination_ip_groups != null ? rule.value.destination_ip_groups : null
      destination_fqdns = rule.value.destination_fqdns != null ? rule.value.destination_fqdns : null
      destination_ports = rule.value.destination_ports
      protocols = rule.value.protocols
    }
  }
}

