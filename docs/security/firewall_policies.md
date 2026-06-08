# Politiques pare-feu (pfSense)

Synthèse des règles de filtrage inter-VLAN configurées sur pfSense.

---

## Principes généraux

1. **Default deny** entre VLANs — autoriser uniquement les flux nécessaires
2. **VLAN INVITES (40)** — accès Internet uniquement, aucun accès LAN
3. **VLAN MGMT (10)** — accès restreint aux administrateurs
4. **VLAN DMZ (60)** — services exposés, flux entrants filtrés

---

## Règles par VLAN

Les captures détaillées sont dans [../architecture/screenshots/](../architecture/screenshots/) :

| VLAN | Fichier capture |
|------|-----------------|
| 10 MGMT | [pfsense_firewall_vlan10_mgmt.png](../architecture/screenshots/pfsense_firewall_vlan10_mgmt.png) |
| 20 USERS | [pfsense_firewall_vlan20_users.png](../architecture/screenshots/pfsense_firewall_vlan20_users.png) |
| 30 WIFI_STAFF | [pfsense_firewall_vlan30_staff.png](../architecture/screenshots/pfsense_firewall_vlan30_staff.png) |
| 40 WIFI_GUEST | [pfsense_firewall_vlan40_guest.png](../architecture/screenshots/pfsense_firewall_vlan40_guest.png) |
| 50 SERVEURS | [pfsense_firewall_vlan50_servers.png](../architecture/screenshots/pfsense_firewall_vlan50_servers.png) |
| 60 DMZ | [pfsense_firewall_vlan60_dmz.png](../architecture/screenshots/pfsense_firewall_vlan60_dmz.png) |

---

## VPN télétravail (WireGuard)

Les clients VPN (`10.20.100.0/24`) accèdent **uniquement** à :

- **VLAN 20 USERS** — postes et imprimantes bureau
- **VLAN 50 SERVEURS** — AD, DNS, applications internes

Pas d'accès MGMT (10), GUEST (40), DMZ (60) depuis le VPN.

Procédure complète : [pfsense_wireguard_vpn.md](../../infra/network/pfsense_wireguard_vpn.md).

---

## Procédures de configuration

- [Installation pfSense](../../infra/network/pfsense_initial_setup.md)
- [Configuration VLANs](../../infra/network/pfsense_vlan_config.md)
- [VPN WireGuard](../../infra/network/pfsense_wireguard_vpn.md)
