locals {
  senders = {
    authentik = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-authentik"]
    }
    lemmy = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-lemmy"]
    }
    mastodon = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-mastodon"]
    }
    matrix = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-matrix"]
    }
    mattermost = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-mattermost"]
    }
    nextcloud = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-nextcloud"]
    }
    rocketchat-lama = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-rocketchat-lama"]
    }
    rocketchat-sdlh = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-rocketchat-sdlh"]
    }
    vaultwarden = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-vaultwarden"]
    }
  }
}

resource "aws_iam_user" "smtp_users" {
  for_each = local.senders
  name     = each.key
}

resource "aws_iam_access_key" "smtp_users" {
  for_each = aws_iam_user.smtp_users
  user     = each.value.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name   = "ses_sender"
  policy = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "ses_sender" {
  for_each   = aws_iam_user.smtp_users
  user       = each.value.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

resource "vault_generic_secret" "infra_aws_ses_senders" {
  for_each = local.senders

  path = "infra/aws/ses/senders/${each.key}"
  data_json = jsonencode({
    username = aws_iam_access_key.smtp_users[each.key].id
    password = aws_iam_access_key.smtp_users[each.key].ses_smtp_password_v4
  })
}

resource "vault_generic_secret" "ses_senders_k8s" {
  for_each = merge([
    for k, v in local.senders : {
      for k8s_namespace in try(v.k8s_namespaces, []) : "${k}_${v.k8s_cluster}_${k8s_namespace}" => merge(v, {
        sender        = k
        k8s_cluster   = v.k8s_cluster
        k8s_namespace = k8s_namespace
      })
    }
  ]...)
  path = "k8s-${each.value.k8s_cluster}/${each.value.k8s_namespace}/aws-ses-${each.value.sender}"
  data_json = jsonencode(merge(each.value, {
    username = aws_iam_access_key.smtp_users[each.value.sender].id
    password = aws_iam_access_key.smtp_users[each.value.sender].ses_smtp_password_v4
  }))
}
