# Supervision et détection d'anomalies

PoC UF_INFRA_B3 : Grafana + Loki + Promtail, logs **pfSense VM** via syslog — tableau de bord, collecte de logs, détection d'incident.

> **SIEM :** un déploiement Wazuh complet est une **cible production** (voir [DAT §11](../docs/DAT.md#11-supervision-et-détection)). Pour le PoC B3, la supervision et la détection d'anomalies sont couvertes par **Grafana + Loki** (logs firewall pfSense, application room-booking, alertes LogQL).

---

## Stack

| Composant | Rôle |
|-----------|------|
| Grafana | Tableaux de bord et alertes LogQL |
| Loki | Agrégation des logs |
| Promtail | Syslog pfSense (UDP 1514) + logs Docker room-booking |
| pfSense (VMware) | Source firewall réelle → `10.20.0.254:1514` |

Configuration pfSense : [infra/network/pfsense_syslog_loki.md](../infra/network/pfsense_syslog_loki.md)

---

## Déploiement local

```bash
# 1. Application
cd cloud/room-booking
docker compose up -d

# 2. Monitoring
cd monitoring
docker compose up -d

# 3. Configurer pfSense (une fois) puis tester
./scripts/test-pfsense-syslog.sh
```

| Service | URL / Port |
|---------|------------|
| Grafana | http://localhost:3000 (`admin` / `smartoffice`) |
| Loki | http://localhost:3100 |
| Syslog pfSense | UDP `10.20.0.254:1514` |
| Dashboard | **Smart Office — Logs & Anomalies** |

### Mode simulateur (VM arrêtée)

```bash
docker compose --profile simulator up -d
```

---

## Scénario d'anomalie

Voir [anomaly-scenario.md](anomaly-scenario.md).

```bash
chmod +x scripts/*.sh
./scripts/simulate-anomaly.sh http://localhost:8080
```

---

## Liens

- [pfSense → Loki](../infra/network/pfsense_syslog_loki.md)
- [DAT — § Supervision](../docs/DAT.md#11-supervision-et-détection)
- [ITSM](../docs/project_management/ITSM.md)
- [room-booking](../cloud/room-booking/)
- Capture PoC : [grafana_dashboard_poc.png](../docs/project_management/screenshots/grafana_dashboard_poc.png)
