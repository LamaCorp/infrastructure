locals {
  repositories = {
    "nucleus.fsn.as212024.net" = [
      "archives",
      "user_root",
    ]
    "gate-1.bar.as212024.net" = [
      "user_root",
    ]
    "edge-1.pvl.as212024.net" = [
      "user_root",
    ]
    "edge-2.fra.as212024.net" = [
      "user_root",
    ]

    "mail.fsn.as212024.net" = [
      "mail",
      "user_root",
    ]
    "mongodb.fsn.as212024.net" = [
      "mongodb",
      "user_root",
    ]
    "postgresql.fsn.as212024.net" = [
      "postgresql",
      "user_root",
    ]
    "redis.fsn.as212024.net" = [
      "redis",
      "user_root",
    ]

    "k3s-1.fsn.as212024.net" = [
      "local_path_provisioner",
      "rancher",
      "user_root",
    ]
    "k3s-1.bar.as212024.net" = [
      "local_path_provisioner",
      "user_root",
    ]
    "k3s-2.bar.as212024.net" = [
      "local_path_provisioner",
      "user_root",
    ]

    "pine.fsn.as212024.net" = [
      "srv",
      "user_root",
    ]

    "ntp-1.bar.as212024.net" = [
      "user_root",
    ]

    "caster.bar.risson.net" = [
      "user_root",
    ]
    "homeassistant.bar.risson.net" = [
      "homeassistant",
      "user_root",
    ]
    "recorder.bar.risson.net" = [
      "frigate",
      "user_root",
    ]
  }

  repositories_computed = merge([
    for machine, repositories in local.repositories : {
      for repository in repositories :
      "${machine}_${repository}" => {
        machine    = machine
        repository = repository
      }
    }
  ]...)
}
