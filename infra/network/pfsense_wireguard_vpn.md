# 🔐 VPN télétravail — WireGuard sur pfSense

Accès distant **Zero Trust** : les employés en télétravail rejoignent uniquement les VLANs **USERS (20)** et **SERVEURS (50)** — pas le LAN complet.

**Contexte Smart Office 2.0** — documenté pour la cible production ; configuration manuelle sur le lab VMware.

---

## Architecture

```text
[Télétravailleur]
  Client WireGuard (10.20.100.x)
        │ UDP 51820
        ▼
   pfSense WAN
        │ interface wg0
        ├──► VLAN 20 USERS   10.20.20.0/24
        └──► VLAN 50 SERVEURS 10.20.50.0/24

Non autorisé par défaut : VLAN 10 MGMT, 40 GUEST, 60 DMZ
```

| Paramètre | Valeur |
|-----------|--------|
| Port WireGuard | **51820/UDP** (WAN) |
| Sous-réseau VPN | **10.20.100.0/24** |
| IP pfSense (wg0) | **10.20.100.1** |
| DNS pour clients | **10.20.50.10** (AD/DNS cible) ou `10.20.0.1` (lab) |
| VLANs accessibles | **20** (bureaux), **50** (serveurs) |

---

## Étape 1 — Activer WireGuard (pfSense WebGUI)

1. **VPN → WireGuard → Settings** → cocher **Enable WireGuard**
2. **VPN → WireGuard → Tunnels** → **+ Add**
   - **Description :** `WG-Remote-Staff`
   - **Listen port :** `51820`
   - **Interface Keys :** Generate (garder la clé privée côté pfSense)
   - **Interface Addresses :** `10.20.100.1/24`
3. **Save** puis **Apply Changes**

---

## Étape 2 — Ajouter un peer (client télétravail)

**VPN → WireGuard → Peers** → **+ Add**

| Champ | Valeur |
|-------|--------|
| Tunnel | `WG-Remote-Staff` |
| Description | `laptop-alexandre` |
| Public Key | Clé publique du client (générée sur le poste) |
| Allowed IPs | `10.20.100.2/32` (IP VPN du client) |
| Persistent Keepalive | `25` (si client derrière NAT) |

Répéter pour chaque appareil (`10.20.100.3/32`, …).

---

## Étape 3 — Règles firewall (interface WireGuard)

**Firewall → Rules → WireGuard** (onglet `WireGuard`)

| # | Action | Source | Destination | Description |
|---|--------|--------|-------------|-------------|
| 1 | Pass | `WireGuard net` | `VLAN20 net` | VPN → USERS (bureaux) |
| 2 | Pass | `WireGuard net` | `VLAN50 net` | VPN → SERVEURS |
| 3 | Block | `WireGuard net` | `any` | Default deny (log) |

> Les réponses sont gérées par l'état **stateful** pfSense. Pas de règle entrante sur VLAN20/50 nécessaire pour le retour.

**Firewall → Rules → WAN**

| Action | Protocole | Destination | Port | Description |
|--------|-----------|-------------|------|-------------|
| Pass | UDP | WAN address | 51820 | WireGuard entrant |

---

## Étape 4 — Configuration client

Exporter depuis pfSense : **VPN → WireGuard → Status** → QR / config, ou construire manuellement :

```ini
[Interface]
PrivateKey = <CLE_PRIVEE_CLIENT>
Address = 10.20.100.2/32
DNS = 10.20.50.10

[Peer]
PublicKey = <CLE_PUBLIQUE_PFSENSE>
Endpoint = <IP_PUBLIQUE_WAN>:51820
AllowedIPs = 10.20.20.0/24, 10.20.50.0/24, 10.20.100.0/24
PersistentKeepalive = 25
```

**AllowedIPs** limité aux VLANs 20 et 50 — le trafic Internet du télétravailleur ne transite pas par le bureau (split tunnel).

### Générer les clés client (Linux)

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

---

## Étape 5 — Tests

```bash
# Depuis le client connecté au VPN
ping 10.20.20.1    # gateway VLAN USERS
ping 10.20.50.1    # gateway VLAN SERVEURS
ping 10.20.10.1    # doit ÉCHOUER (MGMT bloqué)
```

Sur pfSense : **Status → WireGuard** — handshake actif, transfert RX/TX.

Logs firewall : **Status → System Logs → Firewall** — trafic `wg0`.

---

## Intégration Zero Trust

- Accès **minimal** : seulement VLAN20 + VLAN50 (pas MGMT ni DMZ)
- **MFA** : combiné avec Entra ID pour les apps cloud (HTTPS) ; VPN = couche réseau pour ressources on-prem
- **Supervision** : logs WireGuard + pfSense → Loki ([pfsense_syslog_loki.md](pfsense_syslog_loki.md))

Voir [docs/security/Zero_Trust_IAM.md](../../docs/security/Zero_Trust_IAM.md).

---

## PoC étudiant — limites

| Élément | Lab VMware | Production cible |
|---------|------------|------------------|
| WireGuard | Configurable sur pfSense WAN | Oui |
| Accès Azure (ACI) | Via **HTTPS public**, pas via VPN site-to-site | IPsec vers VNet (Backlog Trello) |
| Test client réel | Nécessite IP WAN joignable ou test depuis vmnet | FAI fixe / DynDNS |

Pour une démo locale sans WAN public : tester le tunnel entre **deux VMs** sur vmnet2 ou depuis l'hôte vers pfSense LAN (lab uniquement).

---

## Captures (à ajouter après config)

| Fichier | Contenu |
|---------|---------|
| `docs/architecture/screenshots/pfsense_wireguard_tunnel.png` | Tunnel + peer |
| `docs/architecture/screenshots/pfsense_wireguard_firewall.png` | Règles interface WireGuard |

---

## Liens

- [Configuration VLANs](pfsense_vlan_config.md)
- [Politiques firewall](../../docs/security/firewall_policies.md)
- [Plan IP/VLAN](../../docs/architecture/Plan_Adressage_IP_VLAN.md)
- [DAT — télétravail](../../docs/DAT.md#4-flux-réseau)
