# Azure Firewall Network Rule Collection Module

This module manages an Azure Firewall Network Rule Collection, allowing you to define network filtering rules for Azure Firewalls.

## Features

- Creates and manages network rule collections for Azure Firewalls
- Supports the full range of network rule configuration options
- Allows multiple rules per collection with protocol, source, and destination specifications
- Flexible configuration with support for IP addresses, IP groups, and FQDNs

## Usage

```hcl
module "firewall_network_rules" {
  source = "../modules/fw_network_rule_collection"

  name                = "allow-outbound-traffic"
  azure_firewall_name = "my-azure-firewall"
  resource_group_name = "my-firewall-resource-group"
  priority            = 200
  action              = "Allow"
  
  rules = [
    {
      name                  = "allow-dns"
      source_addresses      = ["10.0.0.0/24"]
      destination_addresses = ["8.8.8.8", "8.8.4.4"]
      destination_ports     = ["53"]
      protocols             = ["TCP", "UDP"]
    },
    {
      name                  = "allow-web"
      source_addresses      = ["10.0.0.0/24"]
      destination_fqdns     = ["*.microsoft.com"]
      destination_ports     = ["80", "443"]
      protocols             = ["TCP"]
    }
  ]
  
  tags = {
    Environment = "Production"
  }
}
```

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `name` | string | The name of the network rule collection |
| `azure_firewall_name` | string | The name of the Azure Firewall |
| `resource_group_name` | string | The name of the resource group where the Azure Firewall exists |
| `priority` | number | The priority of the rule collection (100-65000, must be unique) |
| `action` | string | The action type of the rule collection (Allow or Deny) |
| `rules` | list(object) | The list of rules in the collection (see structure below) |

### Rules Object Structure

Each rule object must contain:

```hcl
{
  name                  = string                  # Name of the rule
  source_addresses      = optional(list(string))  # Source IP addresses
  source_ip_groups      = optional(list(string))  # Source IP groups
  destination_addresses = optional(list(string))  # Destination IP addresses
  destination_ip_groups = optional(list(string))  # Destination IP groups
  destination_fqdns     = optional(list(string))  # Destination FQDNs
  destination_ports     = list(string)            # Destination ports
  protocols             = list(string)            # Protocols (TCP, UDP, ICMP, Any)
}
```

## Optional Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `tags` | map(string) | A mapping of tags to assign to the resources | `{}` |

## Notes

- At least one source and one destination must be specified for each rule
- The priority must be unique across rule collections within the same Azure Firewall
- Valid protocol values are: "TCP", "UDP", "ICMP", and "Any"
- This module manages the rule collection only, not the Azure Firewall itself

## Requirements

- Azure Provider >= 3.0.0
- Terraform >= 1.0.0 