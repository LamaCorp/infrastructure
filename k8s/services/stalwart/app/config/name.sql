SELECT * FROM (
    (
        SELECT
            authentik_core_user.username AS name,
            '$pbkdf2-sha256$i=' ||
                split_part(authentik_core_user.password, '$', 2) ||
                '$' ||
                rtrim(encode(split_part(authentik_core_user.password, '$', 3)::bytea, 'base64'), '=') ||
                '$' ||
                rtrim(encode(decode(split_part(authentik_core_user.password, '$', 4), 'base64'), 'base64'), '=')
            AS secret,
            authentik_core_user.name AS description,
            'individual' AS type,
            coalesce(authentik_core_user.attributes ->> 'mailQuota', '1048576')::bigint AS quota,
            authentik_core_user.is_active AS active,
            authentik_core_user.attributes ->> 'mailPrimaryAddress' AS address
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
    )
    UNION
    (
        SELECT
            authentik_core_group.name AS name,
            '' AS secret,
            authentik_core_group.name AS description,
            'group' AS type,
            0 AS quota,
            true AS active,
            authentik_core_group.attributes ->> 'mailPrimaryAddress' AS address
        FROM authentik_core_group
    )
)
WHERE
    name = $1
LIMIT 1
