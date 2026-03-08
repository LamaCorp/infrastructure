locals {
  postgres_clusters = {
    "postgresql.fsn.as212024.net" = {
      static_roles = {
        "k3s.fsn.as212024.net_infra-observability_grafana" = {
          postgres_role = "grafana"
        }
        "k3s.fsn.as212024.net_services-atuin" = {
          postgres_role = "atuin"
        }
        "k3s.fsn.as212024.net_services-authentik" = {
          postgres_role = "authentik"
        }
        "k3s.fsn.as212024.net_services-gatus-devoups" = {
          postgres_role = "gatus_devoups"
        }
        "k3s.fsn.as212024.net_services-gatus-phowork" = {
          postgres_role = "gatus_phowork"
        }
        "k3s.fsn.as212024.net_services-gatus-prologin" = {
          postgres_role = "gatus_prologin"
        }
        "k3s.fsn.as212024.net_services-gatus-zarak" = {
          postgres_role = "gatus_zarak"
        }
        "k3s.fsn.as212024.net_services-hedgedoc" = {
          postgres_role = "hedgedoc"
        }
        "k3s.fsn.as212024.net_services-immich" = {
          postgres_role = "immich"
        }
        "k3s.fsn.as212024.net_services-lemmy_lemmy" = {
          postgres_role = "lemmy"
        }
        "k3s.fsn.as212024.net_services-mastodon" = {
          postgres_role = "mastodon"
        }
        "k3s.fsn.as212024.net_services-matrix_mautrix-slack" = {
          postgres_role = "matrix_mautrix_slack"
        }
        "k3s.fsn.as212024.net_services-matrix_media-repo" = {
          postgres_role = "matrix_media_repo"
        }
        "k3s.fsn.as212024.net_services-matrix_synapse" = {
          postgres_role = "matrix_synapse"
        }
        "k3s.fsn.as212024.net_services-mattermost" = {
          postgres_role = "mattermost"
        }
        "k3s.fsn.as212024.net_services-netbox" = {
          postgres_role = "netbox"
        }
        "k3s.fsn.as212024.net_services-nextcloud" = {
          postgres_role = "nextcloud"
        }
        "k3s.fsn.as212024.net_services-paperless-ngx-risson" = {
          postgres_role = "paperless_risson"
        }
      }
    }
  }

  postgres_static_roles_computed = merge([
    for cluster_name, cluster in local.postgres_clusters : {
      for role_name, role in try(cluster.static_roles, {}) : "${cluster_name}_${role_name}" => merge(role, {
        cluster_name = cluster_name
        role_name    = role_name
      })
    }
  ]...)
}

resource "random_password" "postgres" {
  for_each = local.postgres_clusters
  length   = 64
  special  = false
}

resource "vault_generic_secret" "postgres" {
  for_each = local.postgres_clusters
  path     = "${vault_mount.databases.path}/postgres/${each.key}/postgres"
  data_json = jsonencode({
    password = random_password.postgres[each.key].result
  })
}

resource "vault_database_secrets_mount" "postgres" {
  path = "postgres"

  default_lease_ttl_seconds = 24 * 60 * 60 * 30 # 30 days
  max_lease_ttl_seconds     = 24 * 60 * 60 * 30 # 30 days

  lifecycle {
    ignore_changes = [
      # managed below
      postgresql,
    ]
  }
}

resource "vault_database_secret_backend_connection" "postgres" {
  for_each      = local.postgres_clusters
  backend       = vault_database_secrets_mount.postgres.path
  name          = each.key
  allowed_roles = [for role in concat(keys(try(each.value.dynamic_roles, {})), keys(try(each.value.static_roles, {}))) : "${each.key}_${role}"]
  postgresql {
    username       = "postgres"
    password       = random_password.postgres[each.key].result
    connection_url = "postgresql://{{username}}:{{password}}@${try(each.value.endpoint, each.key)}/postgres"
  }
}

resource "vault_database_secret_backend_static_role" "postgres" {
  for_each        = local.postgres_static_roles_computed
  backend         = vault_database_secrets_mount.postgres.path
  db_name         = each.value.cluster_name
  name            = each.key
  username        = each.value.postgres_role
  rotation_period = try(each.value.rotation_period, 24 * 60 * 60 * 30) # 30 days
}
