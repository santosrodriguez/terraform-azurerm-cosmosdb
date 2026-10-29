variable "analytical_storage" {
  type = object({
    schema_type = optional(string)
  })
}

variable "automatic_failover_enabled" {
  type = bool
}

variable "backup" {
  type = object({
    interval_in_minutes = optional(number)
    retention_in_hours = optional(number)
    storage_redundancy = optional(string)
    tier = optional(string)
    type = optional(string)
  })
  default = { }
}

variable "capabilities" {
  type = list(object({
    name = optional(string)
  }))
  default = [{}]
}

variable "capacity" {
  type = object({
    total_throughput_limit = optional(number)
  })
  default = { }
}

variable "consistency_policy" {
  type = object({
    consistency_level = optional(string)
    max_interval_in_seconds = optional(number)
    max_staleness_prefix = optional(number)
  })
  default = { }
}

variable "cors_rule" {
  type = object({
    allowed_headers = optional(list(string))
    allowed_methonds = optional(list(string))
    allowed_origins = optional(list(string))
    exposed_headers = optional(list(string))
    max_age_in_seconds = optional(number)
  })
  default = { }
}

variable "database" {
  type = object({
    name = optional(string)
    collation_names = optional(list(string))
  })
  default = { }
}

variable "database_type" {
  type = string
  validation {
    condition = contains(["mongodb", "cassandra", "gremlin", "table", "documents"], lower(var.database_type))
    error_message = "Invalid Database Type.  Valid values are mongodb, cassandra, gremlin, table, and documents"
  }
}

variable "environment" {
  type = string
}

variable "geo_location" {
  type = object({
    failover_priority = optional(number)
    zone_redunant = optional(bool, false)
    location = optional(string)
  })
  default = { }
}

variable "instance_number" {
  type = number
  default = 1
}

variable "kind" {
  type = string
}

variable "location" {
  type = string
  default = "eastus"
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "public_network_access_enabled" {
  type = bool
  default = false
}

variable "minimal_tls_version" {
  type = string
  default = "Tls12"
}

variable "offer_type" {
  type = string
  default = "Standard"
}

variable "resource_group_name" {
  type = string
}

variable "restore" {
  type = object({
    source_cosmosdb_account_id = optional(string)
    restore_timestamp_in_utc = optional(string)
    database = optional(object({
      name = string
      collection_names = optional(list(string))
    }))
    gremlin_database = optional(list(object({  
      name = string
      graph_names = optional(list(string))
    })))
    tables_to_restore = optional(list(string))
  })
  default = { }
}

variable "solution_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "virtual_network_rule" {
  type = list(object({
    virtual_network_subnet_id = optional(string)
    ignore_missing_vnet_service_endpoint = optional(bool)
  }))
  default = [{}]
}
