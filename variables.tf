variable "name" {
  description = "(Required) The name of the Traffic Manager Profile. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Traffic Manager Profile. Changing this forces a new resource to be created."
  type        = string
}

variable "profile_status" {
  description = "(Optional) The status of the profile. Possible values are Enabled and Disabled. Defaults to Enabled."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.profile_status)
    error_message = "profile_status must be either Enabled or Disabled."
  }
}

variable "traffic_routing_method" {
  description = "(Required) Specifies the algorithm used to route traffic. Possible values are Performance, Weighted, Priority, Geographic, Subnet, and MultiValue."
  type        = string

  validation {
    condition     = contains(["Performance", "Weighted", "Priority", "Geographic", "Subnet", "MultiValue"], var.traffic_routing_method)
    error_message = "traffic_routing_method must be one of Performance, Weighted, Priority, Geographic, Subnet, or MultiValue."
  }
}

variable "max_return" {
  description = "(Optional) The amount of endpoints to return for DNS queries to this profile. Required and only used when traffic_routing_method is MultiValue. Possible values are between 1 and 8."
  type        = number
  default     = null
}

variable "traffic_view_enabled" {
  description = "(Optional) Whether Traffic View is enabled for this Traffic Manager Profile. Defaults to false."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "dns_config" {
  description = "(Required) The DNS configuration of the profile. relative_name is combined with the Traffic Manager domain to form the FQDN; ttl is the DNS TTL (1-2147483647)."
  type = object({
    relative_name = string
    ttl           = number
  })
}

variable "monitor_config" {
  description = "(Required) The endpoint monitoring configuration. path is required when protocol is HTTP or HTTPS and must not be set for TCP."
  type = object({
    protocol                     = string
    port                         = number
    path                         = optional(string)
    interval_in_seconds          = optional(number, 30)
    timeout_in_seconds           = optional(number, 10)
    tolerated_number_of_failures = optional(number, 3)
    expected_status_code_ranges  = optional(list(string))
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
  })
}

variable "azure_endpoints" {
  description = "(Optional) A list of Azure endpoints (PaaS resources such as App Service or Public IP) to attach to the profile."
  type = list(object({
    name                 = string
    target_resource_id   = string
    weight               = optional(number, 1)
    priority             = optional(number)
    enabled              = optional(bool, true)
    always_serve_enabled = optional(bool, false)
    geo_mappings         = optional(list(string))
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })), [])
  }))
  default = []
}

variable "external_endpoints" {
  description = "(Optional) A list of external endpoints (services outside Azure, by FQDN or IP) to attach to the profile. endpoint_location is required for the Performance routing method."
  type = list(object({
    name                 = string
    target               = string
    endpoint_location    = optional(string)
    weight               = optional(number, 1)
    priority             = optional(number)
    enabled              = optional(bool, true)
    always_serve_enabled = optional(bool, false)
    geo_mappings         = optional(list(string))
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })), [])
  }))
  default = []
}

variable "nested_endpoints" {
  description = "(Optional) A list of nested endpoints (child Traffic Manager profiles) to attach to the profile. endpoint_location is required for the Performance routing method."
  type = list(object({
    name                                  = string
    target_resource_id                    = string
    minimum_child_endpoints               = optional(number)
    minimum_required_child_endpoints_ipv4 = optional(number)
    minimum_required_child_endpoints_ipv6 = optional(number)
    endpoint_location                     = optional(string)
    weight                                = optional(number, 1)
    priority                              = optional(number)
    enabled                               = optional(bool, true)
    always_serve_enabled                  = optional(bool, false)
    geo_mappings                          = optional(list(string))
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })), [])
  }))
  default = []
}
