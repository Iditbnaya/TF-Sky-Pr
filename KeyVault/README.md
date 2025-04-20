# 🔐 Azure Key Vault Terraform Module

This module deploys an Azure Key Vault resource with optional configurations for networking, RBAC, and policy-compliant settings such as purge protection.

> 🚨 Compliant with Azure Policy: `Key vaults should have deletion protection enabled`

---

## 📦 Module Features

- Creates an Azure Key Vault instance
- Configures:
  - RBAC Authorization
  - Soft delete and purge protection
  - Network ACLs (IP restrictions)
- Supports Diagnostic Settings integration (optional future enhancement)

---

## 🚀 Usage

```hcl
module "keyvault" {
  source                        = "../../modules/keyvault"
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name

  # Compliance
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  enable_rbac_authorization     = var.enable_rbac_authorization

  # SKU & Features
  sku                           = var.sku
  public_network_access_enabled = var.public_network_access_enabled
  enabled_for_deployment        = var.enabled_for_deployment
  enabled_for_disk_encryption   = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  # Network ACLs
  allowed_ip_addresses          = var.allowed_ip_addresses
  default_action                = var.default_action
  allow_bypass                  = var.allow_bypass
}
```

---

## 📥 Input Variables

| Name                         | Type            | Description                                      | Required |
|------------------------------|------------------|--------------------------------------------------|----------|
| `name`                       | `string`         | Name of the Key Vault                            | ✅ Yes   |
| `location`                   | `string`         | Azure Region                                     | ✅ Yes   |
| `resource_group_name`        | `string`         | Resource Group name                              | ✅ Yes   |
| `sku`                        | `string`         | Key Vault SKU (e.g. `standard`, `premium`)       | ✅ Yes   |
| `enable_rbac_authorization` | `bool`           | Enable RBAC authorization                        | ✅ Yes   |
| `soft_delete_retention_days`| `number`         | Retention period for deleted secrets (7-90)      | ✅ Yes   |
| `purge_protection_enabled`  | `bool`           | Enables purge protection (required by policy)    | ✅ Yes   |
| `public_network_access_enabled` | `bool`       | Allows public access to Key Vault                | ✅ Yes   |
| `enabled_for_deployment`    | `bool`           | Enable template deployment                       | ✅ Yes   |
| `enabled_for_disk_encryption`| `bool`          | Enable disk encryption via Key Vault             | ✅ Yes   |
| `enabled_for_template_deployment` | `bool`     | Enable ARM templates                             | ✅ Yes   |
| `allowed_ip_addresses`      | `list(string)`   | List of IPs allowed to access Key Vault          | ✅ Yes   |
| `default_action`            | `string`         | Default action for unlisted IPs (`Deny`/`Allow`) | ✅ Yes   |
| `allow_bypass`              | `string`         | Bypass rules for Azure services (`AzureServices`) | ✅ Yes   |

---

## 📤 Output Variables

| Name          | Description                        |
|---------------|------------------------------------|
| `vault_uri`   | URI of the deployed Key Vault      |
| `vault_id`    | Full resource ID of the Key Vault  |

---

## 🔐 Policy Compliance

This module complies with the following Azure Policy:

- ✅ `Key vaults should have deletion protection enabled`

Make sure to set:

```hcl
purge_protection_enabled = true
```

To prevent policy enforcement errors when deploying Key Vaults.

---

## 👩‍💻 Author

Built by [@Iditbnaya](https://github.com/Iditbnaya)
Part of the [TF-Sky-Pr](https://github.com/Iditbnaya/TF-Sky-Pr) Azure infrastructure suite ☁️

---

## 📜 License

MIT © 2025
