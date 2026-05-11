# ⚙️ Configuration pfSense - Setup Wizard

Détails des paramètres appliqués lors du passage de l'assistant de configuration (Setup Wizard).

## 📋 Informations Générales

| Paramètre | Valeur | Justification |
| :--- | :--- | :--- |
| **Hostname** | `pfsense` | Nom d'hôte standard. |
| **Domain** | `smartoffice.lan` | Évite les conflits mDNS (`.local`). |
| **Primary DNS** | `1.1.1.1` | Cloudflare : Rapidité & Confidentialité. |
| **Secondary DNS** | `9.9.9.9` | Quad9 : Sécurité & Redondance. |
| **Override DNS** | ✅ Activé | Permet la flexibilité via le WAN DHCP. |
| **Timezone** | `Europe/Paris` | Heure locale pour les logs. |
| **NTP Server** | `2.pfsense.pool.ntp.org` | Source de temps fiable. |

## 🌐 Interface WAN

| Paramètre | Valeur | Justification |
| :--- | :--- | :--- |
| **Type** | DHCP | VMware NAT (vmnet8) fournit l'IP. |
| **MTU** | `1500` | Standard Ethernet. |
| **Block RFC1918** | ✅ Activé | Bloque les réseaux privés sur le WAN. |
| **Block Bogon** | ✅ Activé | Sécurité contre les IPs non-routables. |

## 🏠 Interface LAN

| Paramètre | Valeur | Justification |
| :--- | :--- | :--- |
| **IP Address** | `10.20.0.1` | Passerelle par défaut du réseau local. |
| **Subnet Mask** | `/24` (255.255.255.0) | Segmentation claire. |
| **DHCP Server** | ✅ Activé | Distribution dynamique des IPs. |
| **DHCP Range** | `10.20.0.100 - 10.20.0.200` | Supporte jusqu'à 100 clients. |

## ✅ Vérifications Post-Installation

```bash
# Tester la connectivité depuis l'hôte
ping 10.20.0.1                    # Réponse du LAN
curl -k https://10.20.0.1         # Accès WebGUI

# Tester l'accès internet depuis pfSense (via WebGUI ou SSH)
# Menu Diagnostics -> Ping -> 8.8.8.8
```



---
**Informations de build :**
- **Version :** `2.7.2-RELEASE`
- **Environnement :** VMware Workstation 25 (Laboratoire)