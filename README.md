## Introduction
This Terraform module deploys an Azure Traffic Manager Profile, a DNS-based global traffic load balancer that directs clients to the most appropriate endpoint based on a chosen routing method and endpoint health. Traffic Manager works at the DNS level and does not proxy traffic.

The module provisions a profile (with DNS and monitor configuration) and, optionally, Azure, external, and nested endpoints attached to it.

## Getting Started
To use this module, include it in your Terraform configuration:

## Example Usage

```terraform
module "traffic_manager" {
  source = "git::https://dev.azure.com/#{ADO_org}/#{ADO_project}/_git/az-tf-traffic-manager"

  name                   = "example-tm"
  resource_group_name    = "example-rg"
  profile_status         = "Enabled"
  traffic_routing_method = "Performance"
  traffic_view_enabled   = true

  dns_config = {
    relative_name = "example-app"
    ttl           = 30
  }

  monitor_config = {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
    expected_status_code_ranges  = ["200-299"]
    custom_headers = [
      {
        name  = "host"
        value = "example-app.contoso.com"
      }
    ]
  }

  azure_endpoints = [
    {
      name               = "primary-region"
      target_resource_id = "<app-service-or-public-ip-id>"
      weight             = 100
      priority           = 1
    }
  ]

  external_endpoints = [
    {
      name              = "on-prem-dr"
      target            = "dr.contoso.com"
      endpoint_location = "West US"
      weight            = 50
      priority          = 2
    }
  ]

  nested_endpoints = [
    {
      name                    = "europe-child-profile"
      target_resource_id      = "<child-traffic-manager-profile-id>"
      minimum_child_endpoints = 1
      endpoint_location       = "West Europe"
      priority                = 3
    }
  ]

  tags = {
    Environment   = "Development"
    TerraformRepo = "<repo-name>"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The Traffic Manager Profile name | `string` | n/a | yes |
| resource_group_name | The resource group name | `string` | n/a | yes |
| profile_status | Profile status (Enabled or Disabled) | `string` | `"Enabled"` | no |
| traffic_routing_method | Routing method (Performance, Weighted, Priority, Geographic, Subnet, MultiValue) | `string` | n/a | yes |
| max_return | Endpoints returned for MultiValue routing (1–8) | `number` | `null` | no |
| traffic_view_enabled | Enable Traffic View | `bool` | `false` | no |
| dns_config | DNS config (relative_name, ttl) | `object` | n/a | yes |
| monitor_config | Endpoint monitor config (protocol, port, path, intervals, custom headers, status ranges) | `object` | n/a | yes |
| azure_endpoints | List of Azure (PaaS) endpoints | `list(object)` | `[]` | no |
| external_endpoints | List of external endpoints (FQDN/IP) | `list(object)` | `[]` | no |
| nested_endpoints | List of nested endpoints (child profiles) | `list(object)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

### Endpoint object fields

All three endpoint types share these optional fields: `weight` (1–1000), `priority` (1–1000, unique per profile, required for the Priority routing method), `enabled`, `always_serve_enabled`, `geo_mappings` (required for Geographic routing), `custom_headers`, and `subnets` (required for Subnet routing).

Type-specific fields:

| Endpoint type | Required target | Extra fields |
|---------------|-----------------|--------------|
| `azure_endpoints` | `target_resource_id` | — |
| `external_endpoints` | `target` (FQDN or IP) | `endpoint_location` (required for Performance routing) |
| `nested_endpoints` | `target_resource_id` (child profile ID) | `minimum_child_endpoints`, `minimum_required_child_endpoints_ipv4/ipv6`, `endpoint_location` |

## Outputs

| Name | Description |
|------|-------------|
| id | The Traffic Manager Profile resource ID |
| name | The Traffic Manager Profile name |
| fqdn | The profile FQDN (e.g. example.trafficmanager.net) |
| azure_endpoint_ids | Map of Azure endpoint names to IDs |
| external_endpoint_ids | Map of external endpoint names to IDs |
| nested_endpoint_ids | Map of nested endpoint names to IDs |

## Notes

- **No location**: The Traffic Manager Profile is a global resource and has no `location` argument.
- **monitor_config.path**: Required when `protocol` is HTTP or HTTPS; must be omitted when `protocol` is TCP.
- **Routing method requirements**: `Priority` needs a unique `priority` on each endpoint; `Weighted` uses `weight`; `Geographic` needs `geo_mappings`; `Subnet` needs `subnets`; `MultiValue` uses `max_return` (set automatically only for that method).
- **Performance routing**: `external_endpoints` and `nested_endpoints` must set `endpoint_location`. Azure endpoints derive location from the target resource.
- **Endpoint types**: The module uses the current split resources (`azurerm_traffic_manager_azure_endpoint`, `_external_endpoint`, `_nested_endpoint`), not the deprecated combined `azurerm_traffic_manager_endpoint`.
