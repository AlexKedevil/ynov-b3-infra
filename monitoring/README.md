# Supervision et détection d'anomalies

> Statut : **Fait** — Grafana + Loki + Promtail (PoC local).

Livrable PoC UF_INFRA_B3 : tableau de bord, collecte de logs, simulation d'incident.

---

## Stack

| Composant | Rôle |
|-----------|------|
| Grafana | Tableaux de bord et alertes LogQL |
| Loki | Agrégation des logs |
| Promtail | Collecte logs Docker (room-booking) + pfSense simulé |

---

## Déploiement local

```bash
# 1. Application (logs Docker collectés par Promtail)
cd cloud/room-booking
docker compose up -d

# 2. Monitoring
cd monitoring
cp .env.example .env   # optionnel
docker compose up -d
```

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 (`admin` / `smartoffice`) |
| Loki | http://localhost:3100 |
| Dashboard | **Smart Office — Logs & Anomalies** |

---

## Scénario d'anomalie

Voir [anomaly-scenario.md](anomaly-scenario.md).

```bash
chmod +x scripts/simulate-anomaly.sh scripts/pfsense-log-generator.sh
./scripts/simulate-anomaly.sh http://localhost:8080
```

---

## Liens

- [DAT — § Supervision](../docs/DAT.md#11-supervision-et-détection)
- [ITSM — gestion d'incident](../docs/project_management/ITSM.md)
- [room-booking](../cloud/room-booking/)
