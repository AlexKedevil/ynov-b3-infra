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

## Cas particulier de la DMZ

Dans l'implémentation actuelle, la DMZ n'est pas physiquement séparée du reste du LAN : elle est réalisée sous la forme d'un VLAN (60) filtré par pfSense, au même
titre que les autres segments. L'approche retenue au départ consistait à s'appuyer uniquement sur une segmentation VLAN stricte, en considérant que le cloisonnement logique et un jeu de règles *default deny* suffisaient à isoler les services exposés.

Cette approche présente toutefois une limite : les services accessibles depuis
Internet partagent alors la même infrastructure de commutation que les ressources internes. En cas de compromission d'un service exposé, la surface d'attaque vers le LAN reste plus large que souhaitable, la séparation ne reposant que sur la configuration du pare-feu.

L'architecture cible corrige ce point en traitant la DMZ comme une zone à part
entière, dédiée exclusivement aux services exposés :

| Flux | Politique |
|------|-----------|
| Internet → DMZ | Autorisé, limité aux ports publics (HTTPS 443) |
| DMZ → SERVEURS (50) | Restreint aux seuls ports applicatifs nécessaires (ex. BDD) |
| DMZ → LAN interne | Interdit |
| LAN interne → DMZ | Autorisé (administration, publication de contenu) |

Le principe directeur est qu'aucune connexion ne doit pouvoir être initiée depuis la DMZ vers le réseau interne : un service exposé compromis reste ainsi confiné à sa zone. 
En production, cette DMZ hébergerait un reverse proxy en frontal de
l'application (room-booking), la publication du service métier étant assurée en PoC par l'hébergement cloud (Azure ACI), qui remplit ce rôle d'isolation vis-à-vis du réseau du siège.

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
