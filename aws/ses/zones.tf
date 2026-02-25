locals {
  zones = toset([
    "lama-corp.space",
  ])
}

resource "aws_ses_domain_identity" "this" {
  for_each = local.zones
  domain   = each.key
}

resource "aws_ses_domain_dkim" "this" {
  for_each = local.zones
  domain   = aws_ses_domain_identity.this[each.key].domain
}

resource "aws_ses_domain_identity_verification" "this" {
  for_each = local.zones
  domain   = aws_ses_domain_identity.this[each.key].id
}
