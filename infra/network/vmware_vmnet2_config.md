# 🌐 Configuration Réseau VMware - vmnet2

## 🎯 Objectif
L'objectif est de créer un réseau **Host-only** privé pour connecter l'hôte CachyOS au LAN de pfSense, tout en évitant les conflits en désactivant le serveur DHCP natif de VMware.

## 🔧 Modification du fichier `/etc/vmware/networking`

Ajoutez ou modifiez les lignes suivantes pour définir le réseau `vmnet2` :

```text
answer VNET_2_DISPLAY_NAME LAN-pfSense
answer VNET_2_HOSTONLY_NETMASK 255.255.255.0
answer VNET_2_HOSTONLY_SUBNET 10.20.0.0
answer VNET_2_VIRTUAL_ADAPTER yes
answer VNET_2_PROMISCUOUS yes
```

### Promiscuous mode (pfSense + VLANs)

pfSense active **6 VLAN** sur `em1` (Ethernet1 → vmnet2). FreeBSD exige le **mode promiscuous** sur l'adaptateur parent. Sans cela, VMware affiche :

> *attempted to enable promiscuous mode on adapter Ethernet1*

Sur **Linux**, deux réglages sont nécessaires :

1. **`/etc/vmware/networking`** — `answer VNET_2_PROMISCUOUS yes` (ci-dessus)
2. **Droits sur `/dev/vmnet2`** — règle udev persistante :

```bash
# /etc/udev/rules.d/99-vmware-vmnet2-promiscuous.rules
KERNEL=="vmnet2", MODE="0666"
```

Puis :

```bash
sudo udevadm control --reload-rules
sudo systemctl restart vmware-networks
sudo chmod a+rw /dev/vmnet2
```

> Après `restart vmware-networks`, vérifier que l'hôte garde **10.20.0.254/24** (pas 10.20.0.1).

## 🖥️ Configuration sur l'Hôte

Exécutez les commandes suivantes pour appliquer les changements :

```bash
# Redémarrer les services VMware
sudo systemctl stop vmware-networks
sudo systemctl start vmware-networks

# Vérifier l'existence de l'interface
ip link show | grep vmnet2

# Assigner l'adresse IP à l'interface hôte
sudo ip addr add 10.20.0.254/24 dev vmnet2
sudo ip link set vmnet2 up

# Vérifier le statut
ip addr show vmnet2
```

### 📉 Sortie attendue
```bash
22: vmnet2: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 10.20.0.254/24 scope global vmnet2
```

## 🔗 Association dans pfSense

Dans les paramètres de la VM pfSense :

- **Adaptateur Réseau 2 (LAN)**
- **Type de réseau** : Custom (`vmnet2`)

| Équipement | Configuration | Adresse IP |
| :--- | :--- | :--- |
| **pfSense LAN** | Interface `em1` | `10.20.0.1/24` |
| **Hôte (CachyOS)** | Interface `vmnet2` | `10.20.0.254/24` |

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
- **OS Hôte :** CachyOS x86_64 (Linux 6.19)
- **VMware :** Workstation 25.0.0