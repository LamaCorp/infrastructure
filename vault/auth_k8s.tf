locals {
  k8s-clusters = {
    "k3s.fsn.as212024.net" = {
      endpoint       = "https://kubernetes.default.svc:443"
      ca_cert_base64 = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJkekNDQVIyZ0F3SUJBZ0lCQURBS0JnZ3Foa2pPUFFRREFqQWpNU0V3SHdZRFZRUUREQmhyTTNNdGMyVnkKZG1WeUxXTmhRREUzTURFME9UZzJPVEV3SGhjTk1qTXhNakF5TURZek1UTXhXaGNOTXpNeE1USTVNRFl6TVRNeApXakFqTVNFd0h3WURWUVFEREJock0zTXRjMlZ5ZG1WeUxXTmhRREUzTURFME9UZzJPVEV3V1RBVEJnY3Foa2pPClBRSUJCZ2dxaGtqT1BRTUJCd05DQUFSQmsveFZMQWdzSDRBMlJhNGQzMlhWYW42eldhNGdxeVA5SzErWDI4WmsKakZwK21PV2cvL2pGblk1NEU3TU9YWktCZmFPRmVjWlhhREFQcExyM1BiRkVvMEl3UURBT0JnTlZIUThCQWY4RQpCQU1DQXFRd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVXhOaXdkQUtWT2ZWTlZydDhpZ0JxCjRta0NORnN3Q2dZSUtvWkl6ajBFQXdJRFNBQXdSUUlnS3czOEtybzBQQ0F0NDNLRlI4Ry9HMHRyaXVkaDZnSnkKd0NMVjVCVlg1aHNDSVFEdUJ4U0tLb2dFakR3WmtvYzF0RHczQUt6RnRnUkJwcHM5d2Raa2lHNkxLUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KCg=="
      extra_roles = {
        authentik = {
          sa_names      = ["authentik"]
          sa_namespaces = ["services-authentik"]
          policy        = <<-EOF
            path "${vault_mount.authentik.path}/data/*" {
              capabilities = ["create", "read", "update", "patch", "delete"]
            }
            path "auth/authentik/config" {
              capabilities = ["update"]
            }
          EOF
        }
      }
      pod_cidrs = [
        "172.28.128.0/22",
        "172.28.136.0/22",
        "2001:67c:17fc:110::/60",
      ]
    }
  }

  k8s-clusters_extra_roles_computed = merge([
    for cluster_name, cluster in local.k8s-clusters : {
      for role_name, role in try(cluster.extra_roles, {}) : "${cluster_name}_${role_name}" => merge(role, {
        cluster_name = cluster_name
        role_name    = role_name
        pod_cidrs    = try(cluster.pod_cidrs, [])
      })
    }
  ]...)
}

resource "vault_mount" "k8s-clusters" {
  for_each = local.k8s-clusters
  path     = "k8s-${each.key}"
  type     = "kv"
  options = {
    version = 2
  }
}

resource "vault_auth_backend" "k8s-clusters" {
  for_each = local.k8s-clusters
  type     = "kubernetes"
  path     = "k8s-${each.key}"
}

resource "vault_kubernetes_auth_backend_config" "k8s-clusters" {
  for_each               = local.k8s-clusters
  backend                = vault_auth_backend.k8s-clusters[each.key].path
  kubernetes_host        = each.value.endpoint
  kubernetes_ca_cert     = base64decode(each.value.ca_cert_base64)
  disable_iss_validation = true
}

resource "vault_policy" "k8s-clusters_common" {
  for_each = local.k8s-clusters
  name     = "k8s_${each.key}_common"
  policy   = <<-EOF
    path "${vault_mount.k8s-global.path}/data/global/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.k8s-global.path}/data/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }

    path "${vault_mount.k8s-clusters[each.key].path}/data/global/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.k8s-clusters[each.key].path}/data/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }

    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }

    %{for postgres_cluster in keys(local.postgres_clusters)}
    path "${vault_database_secrets_mount.postgres.path}/creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.postgres.path}/creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}_*" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.postgres.path}/static-creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.postgres.path}/static-creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}_*" {
      capabilities = ["read"]
    }
    %{endfor}

    %{for mongodb_cluster in keys(local.mongodb_clusters)}
    path "${vault_database_secrets_mount.mongodb.path}/creds/${mongodb_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.mongodb.path}/creds/${mongodb_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}_*" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.mongodb.path}/static-creds/${mongodb_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.mongodb.path}/static-creds/${mongodb_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}_*" {
      capabilities = ["read"]
    }
    %{endfor}
  EOF
}

resource "vault_kubernetes_auth_backend_role" "k8s-clusters_common" {
  for_each                         = local.k8s-clusters
  backend                          = vault_auth_backend.k8s-clusters[each.key].path
  role_name                        = "common"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["*"]
  token_policies                   = [vault_policy.k8s-clusters_common[each.key].name]
  token_ttl                        = 24 * 60 * 60 # 24h
  token_bound_cidrs                = try(each.value.pod_cidrs, [])
}

resource "vault_policy" "k8s-clusters_extra-roles" {
  for_each = local.k8s-clusters_extra_roles_computed

  name   = "k8s-clusters_${each.key}"
  policy = each.value.policy
}
resource "vault_kubernetes_auth_backend_role" "k8s-clusters_extra-roles" {
  for_each                         = local.k8s-clusters_extra_roles_computed
  backend                          = vault_auth_backend.k8s-clusters[each.value.cluster_name].path
  role_name                        = each.value.role_name
  bound_service_account_names      = each.value.sa_names
  bound_service_account_namespaces = each.value.sa_namespaces
  token_policies                   = [vault_policy.k8s-clusters_extra-roles[each.key].name]
  token_ttl                        = 24 * 60 * 60 # 24h
  token_bound_cidrs                = each.value.pod_cidrs
}
