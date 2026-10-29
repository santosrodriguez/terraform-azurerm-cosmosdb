terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
}

data "azurecaf_name" "acr_name" {
  resource_type = "azurerm_cosmosdb_account"
  name = "${var.solution_name}-${var.location}-${var.environment}"
  suffixes = [ format("0%2d", var.instance_number) ]
}

locals {
  private_endpoint_dns_zone_id = ["/subscriptions/56bdaed4-70cf-4a28-8fb8-0efc135bb29f/resourceGroups/rg-azuredns-prd-01/providers/Microsoft.Network/privateDnsZones/privatelink.${var.database_type}.cosmos.azure.com"]
  private_endpoint_dns_zone_group_name = "default"
}


resource "azurerm_cosmosdb_account" "cosmos_account" {
  name = data.azurecaf_name.acr_name.result
  location = var.location
  resource_group_name = var.resource_group_name
  offer_type = var.offer_type
  kind       = var.kind
  public_network_access_enabled = var.public_network_access_enabled
  minimal_tls_version = var.minimal_tls_version
  identity {
    type = "SystemAssigned"
  }
  dynamic "analytical_storage" {
    for_each = { for k, v in var.analytical_storage : k => v if v != null }
    content {
      schema_type = analytical_storage.value.schema_type
    }
  }
  dynamic "backup" {
    for_each = { for k, v in var.backup : k => v if v != null }
    content {
      interval_in_minutes = backup.value.interval_in_minutes
      retention_in_hours = backup.value.retention_in_hours
      storage_redundancy = backup.value.storage_redundancy
      tier = backup.value.tier
      type = backup.value.type
    }
  }
  dynamic "capacity" {
    for_each = { for k, v in var.capacity : k => v if v != null }
    content {
      total_throughput_limit = capacity.value.total_throughput_limit
    }
  }
  dynamic "consistency_policy" {
    for_each = { for k, v in var.consistency_policy : k => v if v != null }
    content {
      consistency_level = consistency_policy.value.consistency_level
      max_interval_in_seconds = consistency_policy.value.max_interval_in_seconds
      max_staleness_prefix = consistency_policy.value.max_staleness_prefix
    }
  }
  dynamic "cors_rule" {
    for_each = { for k, v in var.cors_rule : k => v if v != null }
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      exposed_headers = cors_rule.value.exposed_headers
      max_age_in_seconds = cors_rule.value.max_age_in_seconds
    }
  }
  dynamic "geo_location" {
    for_each = { for k, v in var.geo_location : k => v if v != null }
    content {
      failover_priority = geo_location.value.failover_priority
      zone_redundant   = geo_location.value.zone_redunant
      location = geo_location.value.location
    }
  }
  dynamic "restore" {
    for_each = { for k, v in var.restore : k => v if v != null }
    content {
      source_cosmosdb_account_id = restore.value.source_cosmosdb_account_id
      restore_timestamp_in_utc = restore.value.restore_timestamp_in_utc
      dynamic "database" {
        for_each = { for k, v in each.value.restore : k => v if v != null }
        content {
          collection_names = database.value.collection_names
          name = database.value.name
        }
      }
      tables_to_restore = restore.value.tables_to_restore
    }
  }
  dynamic "virtual_network_rule" {
    for_each = { for k, v in var.virtual_network_rule : k => v if v != null }
    content {
      id = virtual_network_rule.value.virtual_network_subnet_id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }
}

resource "azurerm_private_endpoint" "cosmos_pep" {
  name = "pe-${azurerm_cosmosdb_account.cosmos_account.name}"
  location = azurerm_cosmosdb_account.cosmos_account.location
  resource_group_name = azurerm_cosmosdb_account.cosmos_account.resource_group_name
  subnet_id = var.private_endpoint_subnet_id
  private_service_connection {
    name                           = "pe-connection-${azurerm_cosmosdb_account.cosmos_account.name}"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos_account.id
    is_manual_connection           = false
    subresource_names              = lower(var.database_type) == "cassandra" ? ["Cassandra"] : lower(var.database_type) == "mongodb" ? ["MongoDB"] : lower(var.database_type) == "table" ? ["Table"] : lower(var.database_type) == "gremlin" ? ["Gremlin"] : lower(var.database_type) == "documents" ? ["Sql"] : [ ] 
  }
  private_dns_zone_group {
    private_dns_zone_ids = local.private_endpoint_dns_zone_id
    name = local.private_endpoint_dns_zone_group_name
  }
}
