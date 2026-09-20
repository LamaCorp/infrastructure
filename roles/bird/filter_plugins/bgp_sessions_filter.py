from copy import deepcopy
from typing import ClassVar


class FilterModule:
    session_types: ClassVar = {
        "peers": "peer",
        "upstreams": "upstream",
        "customers": "customer",
        "cores": "core",
        "looking_glasses": "lookingglass",
        "telemetries": "telemetry",
    }

    def filters(self):
        return {
            "make_bgp_sessions_list": self.make_bgp_sessions_list,
        }

    def make_bgp_sessions_list(self, bgp_sessions):
        sessions = []
        for type_ in self.session_types:
            if type_ not in bgp_sessions:
                continue

            defaults = bgp_sessions.get("defaults", {})
            defaults.update(bgp_sessions[type_].get("defaults", {}))

            for session in bgp_sessions[type_].get("sessions", []):
                data = deepcopy(defaults)
                data.update(session)
                data["type"] = self.session_types[type_]
                data["peer_type_formatted"] = "PEER_TYPE_PEER"

                if "irr" in data:
                    data["irr_formatted"] = data["irr"]
                    chars_to_replace = (":", "-", " ")
                    for char in chars_to_replace:
                        data["irr_formatted"] = data["irr_formatted"].replace(char, "_")

                match data.get("peer_type", "peer"):
                    case "peer":
                        data["peer_type_formatted"] = "PEER_TYPE_PEER"
                    case "private":
                        data["peer_type_formatted"] = "PEER_TYPE_PRIVATE_PEER"
                    case "ixp":
                        data["peer_type_formatted"] = "PEER_TYPE_IXP"

                if "v4" in data.get("remote", {}):
                    data["protocol_number"] = 4
                    data["protocol"] = "v4"
                    if "irr" in data:
                        data["bgpq4_cmd"] = (
                            f"bgpq4 -b -A -m 24 -4 -l AS_SET_FOR_{data['irr_formatted']}_4 {data['irr']}"
                        )
                    sessions.append(deepcopy(data))
                if "v6" in data.get("remote", {}):
                    data["protocol_number"] = 6
                    data["protocol"] = "v6"
                    if "irr" in data:
                        data["bgpq4_cmd"] = (
                            f"bgpq4 -b -A -m 48 -6 -l AS_SET_FOR_{data['irr_formatted']}_6 {data['irr']}"
                        )
                    sessions.append(deepcopy(data))

        return sessions
