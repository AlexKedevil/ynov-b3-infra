# Gestion des incidents (ITSM)

> Statut : **Fait**

---

## Outils

| Rôle | Outil |
|------|-------|
| Ticketing / suivi projet | [Trello b3-infra](https://trello.com/b/EXl0H0QS/b3-infra) |
| Code et documentation | [GitHub ynov-b3-infra](https://github.com/AlexKedevil/ynov-b3-infra) |
| Supervision | Grafana + Loki (local PoC) |
| Communication équipe | Discord / Teams |

---

## Processus de gestion des incidents

### Niveaux

| Niveau | Exemples | Délai de prise en charge |
|--------|----------|--------------------------|
| P1 — Critique | Réseau bureau down, fuite de données | 15 min |
| P2 — Majeur | room-booking indisponible, pfSense down | 1 h |
| P3 — Mineur | Lenteur Wi-Fi invités, alerte Grafana non bloquante | 4 h |
| P4 — Demande | Nouvelle salle dans room-booking | 24 h |

### Escalade

```text
Utilisateur → L1 (helpdesk / équipe projet) → L2 (admin réseau/cloud) → DSI
```

1. **Détection** — Grafana/Loki (pfSense `filterlog`, HTTP 4xx), utilisateur, GitHub Actions failed
2. **Enregistrement** — carte Trello (colonne En cours, label incident)
3. **Classification** — P1–P4
4. **Résolution** — selon [PCA/PRA](../pca_pra/PCA_PRA.md)
5. **Clôture** — post-mortem si P1/P2, carte → Fait

### Exemples liés au PoC

| Incident | Détection | Action |
|----------|-----------|--------|
| Pic blocages firewall | Grafana panneau pfSense | Vérifier règles VLAN 40, logs `filterlog` |
| Erreurs API room-booking | Grafana + script anomaly | Vérifier PostgreSQL, logs Gunicorn |
| Deploy ACI failed | GitHub Actions | Voir `infra/azure/aci-deploy.md`, re-run workflow |
| Logs pfSense absents | Loki vide | Vérifier Remote Syslog `10.20.0.254:1514` |

---

## Tableau de bord projet

Captures Trello : [screenshots/](screenshots/)

Guide board : [trello_board_guide.md](trello_board_guide.md)

---

## Liens

- [Backlog / sprints](backlog_sprints.md)
- [PCA / PRA](../pca_pra/PCA_PRA.md)
- [Monitoring](../../monitoring/anomaly-scenario.md)
