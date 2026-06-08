# Supervision et détection d'anomalies

> Statut : **À faire** — PR `feature/monitoring-stack`.

Livrable PoC UF_INFRA_B3 : tableau de bord, collecte de logs, simulation d'incident.

---

## Stack prévue

| Composant | Rôle |
|-----------|------|
| Grafana | Tableaux de bord et alertes |
| Loki | Agrégation des logs |
| Promtail | Collecte logs (room-booking, simulateur pfSense) |

---

## Déploiement local

```bash
# À compléter après implémentation
cd monitoring
docker compose up -d
```

- Grafana : `http://localhost:3000`
- Scénario d'anomalie : *documenté ici après PR monitoring*

---

## Liens

- [DAT — § Supervision](../docs/DAT.md#11-supervision-et-détection)
- [room-booking logs](../cloud/room-booking/)
