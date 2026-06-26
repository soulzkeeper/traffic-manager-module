resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  profile_status         = var.profile_status
  traffic_routing_method = var.traffic_routing_method
  max_return             = var.traffic_routing_method == "MultiValue" ? var.max_return : null
  traffic_view_enabled   = var.traffic_view_enabled
  tags                   = var.tags

  dns_config {
    relative_name = var.dns_config.relative_name
    ttl           = var.dns_config.ttl
  }

  monitor_config {
    protocol                     = var.monitor_config.protocol
    port                         = var.monitor_config.port
    path                         = var.monitor_config.path
    interval_in_seconds          = var.monitor_config.interval_in_seconds
    timeout_in_seconds           = var.monitor_config.timeout_in_seconds
    tolerated_number_of_failures = var.monitor_config.tolerated_number_of_failures
    expected_status_code_ranges  = var.monitor_config.expected_status_code_ranges

    dynamic "custom_header" {
      for_each = var.monitor_config.custom_headers
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "azure_endpoint" {
  for_each = { for ep in var.azure_endpoints : ep.name => ep }

  name                 = each.value.name
  profile_id           = azurerm_traffic_manager_profile.traffic_manager.id
  target_resource_id   = each.value.target_resource_id
  weight               = each.value.weight
  priority             = each.value.priority
  enabled              = each.value.enabled
  always_serve_enabled = each.value.always_serve_enabled
  geo_mappings         = each.value.geo_mappings

  dynamic "custom_header" {
    for_each = each.value.custom_headers
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  dynamic "subnet" {
    for_each = each.value.subnets
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }
}

resource "azurerm_traffic_manager_external_endpoint" "external_endpoint" {
  for_each = { for ep in var.external_endpoints : ep.name => ep }

  name                 = each.value.name
  profile_id           = azurerm_traffic_manager_profile.traffic_manager.id
  target               = each.value.target
  endpoint_location    = each.value.endpoint_location
  weight               = each.value.weight
  priority             = each.value.priority
  enabled              = each.value.enabled
  always_serve_enabled = each.value.always_serve_enabled
  geo_mappings         = each.value.geo_mappings

  dynamic "custom_header" {
    for_each = each.value.custom_headers
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  dynamic "subnet" {
    for_each = each.value.subnets
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }
}

resource "azurerm_traffic_manager_nested_endpoint" "nested_endpoint" {
  for_each = { for ep in var.nested_endpoints : ep.name => ep }

  name                                   = each.value.name
  profile_id                             = azurerm_traffic_manager_profile.traffic_manager.id
  target_resource_id                     = each.value.target_resource_id
  minimum_child_endpoints                = each.value.minimum_child_endpoints
  minimum_required_child_endpoints_ipv4  = each.value.minimum_required_child_endpoints_ipv4
  minimum_required_child_endpoints_ipv6  = each.value.minimum_required_child_endpoints_ipv6
  endpoint_location                      = each.value.endpoint_location
  weight                                 = each.value.weight
  priority                               = each.value.priority
  enabled                                = each.value.enabled
  always_serve_enabled                   = each.value.always_serve_enabled
  geo_mappings                           = each.value.geo_mappings

  dynamic "custom_header" {
    for_each = each.value.custom_headers
    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  dynamic "subnet" {
    for_each = each.value.subnets
    content {
      first = subnet.value.first
      last  = subnet.value.last
      scope = subnet.value.scope
    }
  }
}
