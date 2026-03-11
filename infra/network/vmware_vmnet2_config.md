# 🌐 Configuration Réseau VMware - vmnet2

## 🎯 Objectif
L'objectif est de créer un réseau **Host-only** privé pour connecter l'hôte CachyOS au LAN de pfSense, tout en évitant les conflits en désactivant le serveur DHCP natif de VMware.

## 🔧 Modification du fichier `/etc/vmware/networking`

Ajoutez ou modifiez les lignes suivantes pour définir le réseau `vmnet2` :

```text
answer VNET_2_DISPLAY_NAME LAN-pfSense
answer VNET_2_HOSTONLY_NETMASK 255.255.0.0
answer VNET_2_HOSTONLY_SUBNET 10.20.0.0
answer VNET_2_VIRTUAL_ADAPTER yes
```

## 🖥️ Configuration sur l'Hôte (CachyOS)

Exécutez les commandes suivantes pour appliquer les changements :

```bash
# Redémarrer les services VMware
sudo systemctl stop vmware-networks
sudo systemctl start vmware-networks

# Vérifier l'existence de l'interface
ip link show | grep vmnet2

# Assigner l'adresse IP à l'interface hôte
sudo ip addr add 10.20.0.254/16 dev vmnet2
sudo ip link set vmnet2 up

# Vérifier le statut
ip addr show vmnet2
```

### 📉 Sortie attendue
```bash
22: vmnet2: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 10.20.0.254/16 scope global vmnet2
```

## 🔗 Association dans pfSense

Dans les paramètres de la VM pfSense :

- **Adaptateur Réseau 2 (LAN)**
- **Type de réseau** : Custom (`vmnet2`)

| Équipement | Configuration | Adresse IP |
| :--- | :--- | :--- |
| **pfSense LAN** | Interface `em1` | `10.20.0.1/24` |
| **Hôte (CachyOS)** | Interface `vmnet2` | `10.20.0.254/16` |

## ✅ Tests de Connectivité

```bash
# Depuis la machine hôte
ping 10.20.0.1              # Vérifier le LAN pfSense
curl -k https://10.20.0.1   # Vérifier l'accès WebGUI

# Depuis pfSense (via Diagnostics > Ping)
ping 8.8.8.8                # Vérifier la sortie Internet via WAN
```

---
**Informations Système :**
- **Date :** 2026-03-11
- **OS Hôte :** CachyOS x86_64 (Linux 6.19)
- **VMware :** Workstation 25.0.0