output "id" {
  description = "The ID of the Traffic Manager Profile."
  value       = azurerm_traffic_manager_profile.traffic_manager.id
}

output "name" {
  description = "The name of the Traffic Manager Profile."
  value       = azurerm_traffic_manager_profile.traffic_manager.name
}

output "fqdn" {
  description = "The fully qualified domain name of the Traffic Manager Profile (e.g. example.trafficmanager.net)."
  value       = azurerm_traffic_manager_profile.traffic_manager.fqdn
}

output "azure_endpoint_ids" {
  description = "A map of Azure endpoint names to their resource IDs."
  value       = { for k, v in azurerm_traffic_manager_azure_endpoint.azure_endpoint : k => v.id }
}

output "external_endpoint_ids" {
  description = "A map of external endpoint names to their resource IDs."
  value       = { for k, v in azurerm_traffic_manager_external_endpoint.external_endpoint : k => v.id }
}

output "nested_endpoint_ids" {
  description = "A map of nested endpoint names to their resource IDs."
  value       = { for k, v in azurerm_traffic_manager_nested_endpoint.nested_endpoint : k => v.id }
}
