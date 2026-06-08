# Gestion des incidents (ITSM)

> Statut : **À compléter** — PR `feature/project-management-docs`.

---

## Outils

- **Ticketing / suivi projet :** [Trello b3-infra](https://trello.com/b/EXl0H0QS/b3-infra)
- **Code et docs :** GitHub
- **Communication équipe :** Discord / Teams

---

## Processus de gestion des incidents

### Niveaux

| Niveau | Exemples | Délai de prise en charge |
|--------|----------|--------------------------|
| P1 — Critique | Réseau bureau down, fuite de données | 15 min |
| P2 — Majeur | room-booking indisponible, VPN down | 1 h |
| P3 — Mineur | Lenteur Wi-Fi invités | 4 h |
| P4 — Demande | Nouvelle salle dans room-booking | 24 h |

### Escalade

```text
Utilisateur → L1 (helpdesk / équipe projet) → L2 (admin réseau/cloud) → DSI
```

1. **Détection** — monitoring, utilisateur, alerte Grafana
2. **Enregistrement** — carte Trello colonne « Incident »
3. **Classification** — P1–P4
4. **Résolution** — selon [PCA/PRA](../pca_pra/PCA_PRA.md)
5. **Clôture** — post-mortem si P1/P2

---

## Tableau de bord

*Captures Trello à ajouter dans [screenshots/](screenshots/) — PR finale.*
