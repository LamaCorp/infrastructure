#!/usr/bin/env bash

set -xeuo pipefail

OSPF_INTERFACE="$(ip --brief addr show | grep "${NODE_IP}" | cut -d' ' -f1 | cut -d@ -f1)"
NODE_IP="$(ip addr show dev "${OSPF_INTERFACE}" | grep inet | grep -v inet6 | awk '{ print $2 }' | cut -d/ -f1)"

# shellcheck disable=SC2010
sed -e "s/NODE_IP/${NODE_IP}/" -e "s/OSPF_INTERFACE/${OSPF_INTERFACE}/" /config/bird.conf >/etc/bird/bird.conf

exec bird -f -R
