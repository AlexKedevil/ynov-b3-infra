# Scénario de détection d'anomalie

PoC UF_INFRA_B3 : logs **pfSense réel** (VMware) + API room-booking, tableau Grafana.

---

## Prérequis

```bash
# Terminal 1 — application
cd cloud/room-booking
docker compose up -d

# Terminal 2 — monitoring (syslog pfSense sur UDP 1514)
cd monitoring
docker compose up -d
```

Configurer pfSense une fois : [infra/network/pfsense_syslog_loki.md](../infra/network/pfsense_syslog_loki.md)

- Grafana : http://localhost:3000 (`admin` / `smartoffice`)
- Dashboard : **Smart Office — Logs & Anomalies**

Test syslog :

```bash
chmod +x scripts/test-pfsense-syslog.sh
./scripts/test-pfsense-syslog.sh
```

---

## Anomalie 1 — Trafic bloqué pfSense (réel)

1. Vérifier que pfSense envoie les logs vers `10.20.0.254:1514` (voir guide ci-dessus).
2. Générer du trafic refusé : ping inter-VLAN bloqué, VM invité → LAN, ou règle WAN de test.

**Dans Grafana :**
- Panneau *pfSense — connexions bloquées* : montée du taux
- Panneau *Logs pfSense (VM VMware)* : lignes `filterlog` avec `block`

**LogQL alerte :**

```logql
sum(rate({job="pfsense",source="pfsense-vm"} |~ ",block," [2m])) > 0.1
```

**Mode démo sans VM :** `docker compose --profile simulator up -d` (voir README).

---

## Anomalie 2 — Erreurs API room-booking

```bash
./scripts/simulate-anomaly.sh http://localhost:8080
```

**Dans Grafana :**
- Panneau *room-booking — erreurs HTTP* : montée du taux
- Panneau *Logs room-booking — requêtes en erreur* : détail des `400`

**LogQL alerte :**

```logql
sum(rate({container=~".*room-booking.*"} |~ " (4|5)[0-9]{2} " [2m])) > 0.1
```

---

## Chaîne ITSM

1. **Détection** — Grafana / Loki
2. **Analyse** — corrélation firewall + API ([ITSM.md](../docs/project_management/ITSM.md))
3. **Réponse** — règle pfSense ou rollback ACI

---

## Arrêt

```bash
cd monitoring && docker compose down
cd cloud/room-booking && docker compose down
```
