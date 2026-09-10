locals {
  mongodb_clusters = {
    "mongodb.fsn.as212024.net" = {
      static_roles = {
        "k3s.fsn.as212024.net_services-rocketchat-lama" = {
          database     = "rocketchatLama"
          mongodb_user = "rocketchat"
        }
        "k3s.fsn.as212024.net_services-rocketchat-sdlh" = {
          database     = "rocketchatSdlh"
          mongodb_user = "rocketchat"
        }
      }
    }
  }

  mongodb_static_connections_computed = merge([
    for cluster_name, cluster in local.mongodb_clusters : {
      for role_name, role in try(cluster.static_roles, {}) : "${cluster_name}_${role.database}" => {
        cluster_name = cluster_name
        database      = role.database
      }
    }
  ]...)

  mongodb_static_roles_computed = merge([
    for cluster_name, cluster in local.mongodb_clusters : {
      for role_name, role in try(cluster.static_roles, {}) : "${cluster_name}_${role_name}" => merge(role, {
        cluster_name = cluster_name
        role_name    = role_name
      })
    }
  ]...)

  mongodb_dynamic_roles_computed = merge([
    for cluster_name, cluster in local.mongodb_clusters : {
      for role_name, role in try(cluster.dynamic_roles, {}) : "${cluster_name}_${role_name}" => merge(role, {
        cluster_name = cluster_name
        role_name    = role_name
      })
    }
  ]...)
}

resource "random_password" "mongodb" {
  for_each = local.mongodb_clusters
  length   = 64
  special  = false
}

resource "vault_generic_secret" "mongodb" {
  for_each = local.mongodb_clusters
  path     = "${vault_mount.databases.path}/mongodb/${each.key}/admin"
  data_json = jsonencode({
    password = random_password.mongodb[each.key].result
  })
}

resource "vault_database_secrets_mount" "mongodb" {
  path = "mongodb"

  default_lease_ttl_seconds = 24 * 60 * 60 * 30 # 30 days
  max_lease_ttl_seconds     = 24 * 60 * 60 * 30 # 30 days

  lifecycle {
    ignore_changes = [
      # managed below
      mongodb,
    ]
  }
}

resource "vault_database_secret_backend_connection" "mongodb_static" {
  for_each      = local.mongodb_static_connections_computed
  backend       = vault_database_secrets_mount.mongodb.path
  name          = each.key
  allowed_roles = [for role_name, role in local.mongodb_static_roles_computed : role_name if "${role.cluster_name}_${role.database}" == each.key]
  mongodb {
    username       = "admin"
    password       = random_password.mongodb[each.value.cluster_name].result
    connection_url = "mongodb://{{username}}:{{password}}@${try(each.value.endpoint, each.value.cluster_name)}/${each.value.database}?authSource=admin"
  }
}

resource "vault_database_secret_backend_static_role" "mongodb" {
  for_each        = local.mongodb_static_roles_computed
  backend         = vault_database_secrets_mount.mongodb.path
  db_name         = "${each.value.cluster_name}_${each.value.database}"
  name            = each.key
  username        = each.value.mongodb_user
  rotation_period = try(each.value.rotation_period, 24 * 60 * 60 * 30) # 30 days
}

resource "vault_database_secret_backend_connection" "mongodb" {
  for_each      = local.mongodb_clusters
  backend       = vault_database_secrets_mount.mongodb.path
  name          = each.key
  allowed_roles = [for role in keys(try(each.value.dynamic_roles, {})) : "${each.key}_${role}"]
  mongodb {
    username       = "admin"
    password       = random_password.mongodb[each.key].result
    connection_url = "mongodb://{{username}}:{{password}}@${try(each.value.endpoint, each.key)}/admin"
  }
}

resource "vault_database_secret_backend_role" "mongodb" {
  for_each    = local.mongodb_dynamic_roles_computed
  backend     = vault_database_secrets_mount.mongodb.path
  db_name     = each.value.cluster_name
  name        = each.key
  default_ttl = try(each.value.rotation_period, 24 * 60 * 60 * 30) # 30 days
  max_ttl     = try(each.value.rotation_period, 24 * 60 * 60 * 30) # 30 days
  creation_statements = [jsonencode({
    db = each.value.database
    roles = try(each.value.roles, [{
      role = "dbOwner"
      db   = each.value.database
    }])
  })]
  revocation_statements = [jsonencode({
    db = each.value.database
  })]
}
