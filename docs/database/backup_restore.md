# Sauvegarde et restauration — PostgreSQL

> Statut : **Fait** — procédure validée en local (`docker compose`).

---

## Politique de sauvegarde

| Élément | Fréquence | Rétention | Emplacement |
|---------|-----------|-----------|-------------|
| PostgreSQL (room-booking) | Quotidienne | 30 jours | NAS on-prem / Azure Blob (cible) |
| Configuration pfSense | Hebdomadaire | 12 semaines | NAS / export XML |
| Code et docs | Continu | Illimité | GitHub |
| Images Docker | À chaque push `main` | Tags SHA + `latest` | ACR `smartofficeynov` |

---

## Sauvegarde PostgreSQL (local)

```bash
cd cloud/room-booking
docker compose exec -T postgres pg_dump -U roombooking roombooking \
  > backup_$(date +%Y%m%d_%H%M).sql
```

Vérifier le fichier :

```bash
head -5 backup_*.sql   # doit contenir CREATE TABLE / COPY
```

---

## Restauration (local)

```bash
cd cloud/room-booking
# Arrêter l'app pour éviter les écritures concurrentes
docker compose stop room-booking

docker compose exec -T postgres psql -U roombooking -d roombooking \
  -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

docker compose exec -T postgres psql -U roombooking roombooking \
  < backup_YYYYMMDD_HHMM.sql

docker compose start room-booking
curl -s http://localhost:8080/rooms | head -c 200
```

---

## Sauvegarde ACI (cible Azure)

```bash
# Depuis Cloud Shell — export manuel avant changement majeur
az container exec --resource-group rg-smartoffice \
  --name smartoffice-booking --container-name postgres \
  --exec-command "pg_dump -U roombooking roombooking" > aci_backup.sql
```

Stockage cible : conteneur Azure Blob `backups/postgres/`.

---

## Tests

- [x] Sauvegarde manuelle locale (`pg_dump`)
- [x] Restauration testée sur environnement Docker local
- [x] RTO / RPO documentés dans [PCA_PRA.md](../pca_pra/PCA_PRA.md)

---

## Liens

- [DAT — § Stockage](../DAT.md#9-stratégie-de-stockage-et-sauvegarde)
