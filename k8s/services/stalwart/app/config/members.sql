SELECT member_of FROM
    (
        SELECT
            authentik_core_user.username AS name,
            authentik_core_group.name AS member_of
        FROM authentik_core_user
        INNER JOIN authentik_core_user_ak_groups
            ON (authentik_core_user.id = authentik_core_user_ak_groups.user_id)
        INNER JOIN authentik_core_group
            ON (authentik_core_user_ak_groups.group_id = authentik_core_group.group_uuid)
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
WHERE
    name = $1
