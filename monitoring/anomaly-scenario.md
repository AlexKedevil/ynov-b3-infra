# Scénario de détection d'anomalie

PoC UF_INFRA_B3 : deux sources de logs, un tableau de bord Grafana, détection visuelle d'incident.

---

## Prérequis

```bash
# Terminal 1 — application
cd cloud/room-booking
docker compose up -d

# Terminal 2 — monitoring
cd monitoring
docker compose up -d
```

- Grafana : http://localhost:3000 (`admin` / `smartoffice`)
- Dashboard : **Smart Office — Logs & Anomalies**

---

## Anomalie 1 — Scan de ports (pfSense simulé)

Le conteneur `pfsense-log-simulator` écrit des logs firewall dans `/var/log/pfsense/firewall.log`.
Toutes les ~2 min, il génère un **pic de 25 connexions bloquées** + une ligne `anomaly_detected`.

**Dans Grafana :**
- Panneau *pfSense simulé — connexions bloquées* : pic visible
- Panneau *Alertes pfSense simulées* : ligne `type=port_scan_spike`

**LogQL alerte (optionnelle dans Grafana → Alerting) :**

```logql
sum(rate({job="pfsense"} |= "action=block" [2m])) > 0.5
```

---

## Anomalie 2 — Erreurs API room-booking

```bash
chmod +x monitoring/scripts/simulate-anomaly.sh
./monitoring/scripts/simulate-anomaly.sh http://localhost:8080
```

Le script envoie des requêtes invalides (room inexistante, JSON mal formé) → logs Gunicorn `4xx`.

**Dans Grafana :**
- Panneau *room-booking — erreurs HTTP* : montée du taux
- Panneau *Logs room-booking — requêtes en erreur* : détail des requêtes

**LogQL alerte :**

```logql
sum(rate({container=~".*room-booking.*"} |~ " (4|5)[0-9]{2} " [2m])) > 0.1
```

---

## Chaîne ITSM (lien livrable)

1. **Détection** — Grafana / Loki (ce PoC)
2. **Analyse** — corrélation logs firewall + API ([ITSM.md](../docs/project_management/ITSM.md))
3. **Réponse** — blocage source WAN (pfSense) ou rollback déploiement ACI

---

## Arrêt

```bash
cd monitoring && docker compose down
cd cloud/room-booking && docker compose down
```
