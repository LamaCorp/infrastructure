from users.models import Group
from django.db import transaction


def save_all_claims_as_extra_data(response, storage, social=None, *_args, **_kwargs):
    """Update user extra-data using data from provider."""
    if not social:
        return {}

    social.extra_data = response
    storage.user.changed(social)

    return {}


def update_groups(backend, response, social, user=None, *_args, **_kwargs):
    if not social:
        return {}
    if backend.name != "oidc":
        return {}
    if not user:
        return {}

    try:
        user_groups = []
        for group in response.get("groups", []):
            user_group, _ = Group.objects.get_or_create(name=group)
            user_groups.append(user_group)
        with transaction.atomic():
            user.groups.clear()
            user.groups.add(*set(user_groups))
    except Exception as exc:
        raise ValueError from exc
    return {}


def update_roles(backend, response, social, user=None, *_args, **_kwargs):
    if not social:
        return {}
    if backend.name != "oidc":
        return {}
    if not user:
        return {}

    user.is_superuser = "superuser" in response.get("entitlements", [])
    user.is_staff = "staff" in response.get("entitlements", [])
    user.save()

    return {}
