# 📡 Plan d'Adressage IP et Politique VLAN

## Informations Générales
- **Plage réseau:** 10.20.0.0/16 (Classe A Privée)
- **Masque de sous-réseau:** 255.255.0.0
- **Passerelle par défaut:** 10.20.0.1 (pfSense)
- **Serveur DNS primaire:** 10.20.50.10 (AD/DNS)
- **Serveur DNS secondaire:** 8.8.8.8 (Google)

## Tableau des VLANs

| VLAN ID | Nom | Sous-réseau | Passerelle | Plage DHCP | Description |
|:---:|:---|:---|:---|:---|:---|
| 10 | MGMT | 10.20.10.0/24 | 10.20.10.1 | Statique | Gestion équipements (ILO, Switches) |
| 20 | USERS | 10.20.20.0/24 | 10.20.20.1 | .100-.200 | Utilisateurs (Bureau) |
| 30 | WIFI_STAFF | 10.20.30.0/24 | 10.20.30.1 | .50-.200 | Wi-Fi Personnel |
| 40 | WIFI_INVITES | 10.20.40.0/24 | 10.20.40.1 | .50-.250 | Wi-Fi Invités (Isolé) |
| 50 | SERVEURS | 10.20.50.0/24 | 10.20.50.1 | Statique | Serveurs internes (AD, DB) |
| 60 | DMZ | 10.20.60.0/24 | 10.20.60.1 | Statique | Services publics (Web, VPN) |
| 99 | WAN | DHCP | FAI | N/A | Accès Internet |

## Règles de Routage

1. **VLAN MGMT:** Accès restreint aux administrateurs uniquement
2. **VLAN INVITES:** Accès Internet seulement, isolation totale du LAN
3. **VLAN SERVEURS:** Accès uniquement via ports/protocoles autorisés
4. **VLAN USERS:** Accès contrôlé vers DMZ et Internet

## Justification des Choix

| Choix | Justification |
|:---|:---|
| **RFC 1918** | Adressage privé pour sécurité interne |
| **/24 par VLAN** | Suffisant pour 254 hôtes par segment |
| **VLAN 10 pour MGMT** | Séparation trafic de gestion et données |
| **DMZ dédiée** | Isolation des services exposés à Internet |
