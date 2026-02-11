"""Netbox configuration"""

ALLOWED_HOSTS = ["netbox.as212024.net"]

DATABASE = {
    "NAME": "netbox",
    "USER": "{{ .username }}",
    "PASSWORD": "{{ .password }}",
    "HOST": "postgresql.fsn.as212024.net",
    "OPTIONS": {
        "sslmode": "prefer",
    },
}

REDIS = {
    "tasks": {
        "HOST": "redis.fsn.as212024.net",
        "PORT": 6385,
        "DATABASE": 0,
    },
    "caching": {
        "HOST": "redis.fsn.as212024.net",
        "PORT": 6385,
        "DATABASE": 1,
    },
}

SECRET_KEY = "{{ .secret_key }}"

EXEMPT_VIEW_PERMISSIONS = ["*"]

SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True

PLUGINS = ["netbox_bgp"]

DJANGO_ADMIN_ENABLED = True

TIME_ZONE = "Europe/Paris"

REMOTE_AUTH_ENABLED = True
REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth"

SOCIAL_AUTH_OIDC_ENDPOINT = "https://auth.as212024.net/application/o/netbox/"
SOCIAL_AUTH_OIDC_KEY = "{{ .client_id }}"
SOCIAL_AUTH_OIDC_SECRET = "{{ .client_secret }}"
LOGOUT_REDIRECT_URL = "https://auth.as212024.net/application/o/netbox/end-session/"
SOCIAL_AUTH_OIDC_SCOPE = ["openid", "profile", "email", "entitlements"]

SOCIAL_AUTH_PIPELINE = (
    "social_core.pipeline.social_auth.social_details",
    "social_core.pipeline.social_auth.social_uid",
    "social_core.pipeline.social_auth.social_user",
    "social_core.pipeline.user.get_username",
    "social_core.pipeline.user.create_user",
    "social_core.pipeline.social_auth.associate_user",
    "social_core.pipeline.social_auth.load_extra_data",
    "social_core.pipeline.user.user_details",
    "netbox.custom_pipeline.save_all_claims_as_extra_data",
    "netbox.custom_pipeline.update_groups",
    "netbox.custom_pipeline.update_roles",
)
