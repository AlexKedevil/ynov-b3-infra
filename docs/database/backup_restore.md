# Sauvegarde et restauration — PostgreSQL

> Statut : **À compléter** — procédure testée après déploiement room-booking.

---

## Politique de sauvegarde

| Élément | Fréquence | Rétention | Emplacement |
|---------|-----------|-----------|-------------|
| PostgreSQL (room-booking) | Quotidienne | 30 jours | On-prem / Azure Blob |
| Configuration pfSense | Hebdomadaire | 12 semaines | NAS / export XML |
| Code et docs | Continu | Illimité | GitHub |

---

## Sauvegarde PostgreSQL

```bash
# À valider une fois PostgreSQL déployé
docker compose exec postgres pg_dump -U roombooking roombooking > backup_$(date +%Y%m%d).sql
```

---

## Restauration

```bash
docker compose exec -T postgres psql -U roombooking roombooking < backup_YYYYMMDD.sql
```

---

## Tests

- [ ] Sauvegarde manuelle réalisée
- [ ] Restauration testée sur environnement de test
- [ ] RTO / RPO documentés dans [../pca_pra/PCA_PRA.md](../pca_pra/PCA_PRA.md)
