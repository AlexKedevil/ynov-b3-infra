# 🛡️ Installation et Configuration Initiale pfSense

Cette documentation détaille les étapes d'installation et de configuration initiale de pfSense dans un environnement virtualisé.

## 📋 Informations de la Machine Virtuelle

| Paramètre | Valeur |
| :--- | :--- |
| **Nom VM** | `FW-01-pfSense` |
| **Version pfSense** | `2.7.2-RELEASE` (amd64) |
| **Processeurs** | 2 vCPU |
| **Mémoire Vive** | 2 GB RAM |
| **Stockage** | 20 GB (UFS) |
| **Interface WAN** | Adaptateur 1 → NAT (`vmnet8`) |
| **Interface LAN** | Adaptateur 2 → Custom (`vmnet2`) |

## 📀 Étapes d'Installation

1.  **Téléchargement** : [ISO pfSense](https://www.pfsense.org/download/)
2.  **Choix de l'image** : Sélectionner `AMD64`, `memstick installer`.
3.  **Partitionnement** : Choisir `Auto (UFS)` + `GPT`.
4.  **Finalisation** : Extraire l'ISO après l'installation et redémarrer la VM.

## 🔧 Configuration Console (Menu pfSense)

Une fois redémarré, utilisez le menu console pour configurer les interfaces de base :

-   **Option 2 : Set interface(s) IP address**
    -   Interface LAN : `em1`
    -   Adresse IPv4 : `10.20.0.1`
    -   Masque de sous-réseau : `24`
    -   Activer le serveur DHCP : **Oui**
    -   Plage DHCP : `10.20.0.100` - `10.20.0.200`
    -   Activer HTTPS WebConfigurator : **Oui**
-   **Option 14 : Enable Secure Shell (sshd)**
    -   Activer pour permettre l'accès SSH futur (après configuration du Firewall).

## 🌐 Setup Wizard (WebGUI)

1.  Accéder à l'URL : [https://10.20.0.1](https://10.20.0.1)
2.  Identifiants par défaut : `admin` / `pfsense`
3.  **Général** : Hostname `pfsense`, Domain `smartoffice.lan`, timezone `Europe/Paris`
4.  **DNS** : primaire `1.1.1.1`, secondaire `9.9.9.9`, *Override DNS* activé
5.  **WAN** : DHCP (NAT vmnet8), MTU 1500, *Block RFC1918* et *Block Bogon* activés
6.  **LAN** : `10.20.0.1/24`, DHCP `10.20.0.100`–`10.20.0.200` (déjà partiellement configuré via console)
7.  **Mot de passe Admin** : *À définir (consulter le coffre-fort sécurisé)*
8.  **Reload** → **Finish**

### Vérifications post-wizard

```bash
ping 10.20.0.1
curl -k https://10.20.0.1
# Diagnostics → Ping → 8.8.8.8 depuis la WebGUI
```
