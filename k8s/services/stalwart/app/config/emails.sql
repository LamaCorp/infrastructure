SELECT address FROM (
    (
        SELECT
            authentik_core_user.username AS name,
            jsonb_array_elements_text(authentik_core_user.attributes->'mailAlias') AS address,
            'alias' AS type
        FROM authentik_core_user
        WHERE
            authentik_core_user.type NOT LIKE '%service_account'
            AND
            authentik_core_user.username != 'AnonymousUser'
            AND
            authentik_core_user.attributes ? 'mailPrimaryAddress'
            AND
            authentik_core_user.password LIKE 'pbkdf2_sha256\$%'
            AND
            array_length(string_to_array(authentik_core_user.password, '$'), 1) = 4
            AND
            authentik_core_user.attributes ? 'mailAlias'
    )
    UNION
    (
        SELECT
            authentik_core_group.name AS name,
            jsonb_array_elements_text(authentik_core_group.attributes->'mailAlias') AS address,
            'alias' AS type
        FROM authentik_core_group
        WHERE
            authentik_core_group.attributes ? 'mailPrimaryAddress'
            AND
            authentik_core_group.attributes ->> 'mailPrimaryAddress' IS NOT NULL
            AND
            authentik_core_group.attributes ? 'mailAlias'
    )
)
WHERE
    name = $1
ORDER BY type DESC, address ASC
