# pfSense → Loki (syslog vers Promtail)

Relie le **pfSense réel** (VMware `10.20.0.1`) au stack monitoring (`Promtail` sur l'hôte `10.20.0.254`).

```text
pfSense (10.20.0.1) --syslog UDP--> vmnet2 host (10.20.0.254:1514) --> syslog-ng --> Promtail --> Loki --> Grafana
```

---

## Prérequis

- Interface hôte `vmnet2` : `10.20.0.254` ([vmware_vmnet2_config.md](vmware_vmnet2_config.md))
- Stack monitoring démarré : `cd monitoring && docker compose up -d`
- Port **UDP 1514** exposé par le conteneur `syslog-ng` (→ fichier lu par Promtail)

Vérification :

```bash
ss -ulnp | grep 1514
./monitoring/scripts/test-pfsense-syslog.sh
```

---

## Configuration pfSense (WebGUI)

1. Ouvrir https://10.20.0.1/ et se connecter.
2. **Status → System Logs → Settings**
3. Section **Remote Logging Options** :
   - Cocher **Send log messages to remote syslog server**
   - **Source Address** : laisser par défaut (interface LAN)
   - **IP Protocol** : **IPv4**
   - **Remote log servers** : `10.20.0.254`
   - **Port** : `1514`
   - **Remote Syslog Contents** : cocher au minimum :
     - **Firewall Events**
     - **System Events**
4. **Save**

---

## Générer du trafic firewall (test)

Depuis pfSense : **Diagnostics → Ping** vers une IP inter-VLAN bloquée par vos règles, ou depuis une VM invité VLAN 40 vers le LAN.

Dans Grafana (dashboard *Smart Office — Logs & Anomalies*), panneau **Logs pfSense (VM)** doit afficher des lignes `filterlog` ou `block`.

Requête Loki manuelle :

```bash
curl -G -s "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={job="pfsense",source="pfsense-vm"}' \
  --data-urlencode 'limit=5'
```

---

## Simulateur (sans VM pfSense)

Si la VM est arrêtée, mode démo :

```bash
cd monitoring
docker compose --profile simulator up -d
```

---

## Dépannage

| Problème | Action |
|----------|--------|
| Aucun log dans Grafana | Vérifier `vmnet2` UP, port 1514, IP `10.20.0.254` dans pfSense |
| Logs système seulement | Activer **Firewall Events** dans Remote Syslog Contents |
| Conflit port 514 | Utiliser **1514** (pas besoin de root sur l'hôte) |

---

## Production / hybride

En cible, le même flux peut être étendu : pfSense site + logs ACI (Azure Monitor / autre collecteur) centralisés dans Grafana Cloud ou Loki managé.
