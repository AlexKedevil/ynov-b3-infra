# Modèle conceptuel de données — Room Booking

Aligné sur [cloud/room-booking/init.sql](../../cloud/room-booking/init.sql).

---

## MCD (Merise)

```text
┌─────────────┐         RESERVER          ┌──────────────┐
│  UTILISATEUR│ (1,N) ──────────────────── (0,N) │ RESERVATION │
│             │                              │              │
│ id (PK)     │                              │ id (PK)      │
│ email       │                              │ start_time   │
│ role        │                              │ end_time     │
└─────────────┘                              └──────┬───────┘
                                                    │ (1,1)
                                                    │
                                             ┌──────▼───────┐
                                             │    SALLE     │
                                             │ id (PK)      │
                                             │ name         │
                                             │ capacity     │
                                             │ floor        │
                                             └──────────────┘
```

### ENTITE : SALLE (`rooms`)

| Attribut | Type SQL | Contrainte |
|----------|----------|------------|
| id | SERIAL | PK |
| name | VARCHAR(100) | NOT NULL |
| capacity | INT | NOT NULL, > 0 |
| floor | INT | NOT NULL, ≥ 0 |

### ENTITE : UTILISATEUR (`users`)

| Attribut | Type SQL | Contrainte |
|----------|----------|------------|
| id | SERIAL | PK |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| role | VARCHAR(20) | `employee` \| `admin` |

> **Évolution Entra ID :** attribut `entra_oid` prévu pour lier le compte Microsoft (non requis en mode `AUTH_DISABLED`).

### ENTITE : RESERVATION (`bookings`)

| Attribut | Type SQL | Contrainte |
|----------|----------|------------|
| id | SERIAL | PK |
| room_id | INT | FK → rooms, ON DELETE CASCADE |
| user_id | INT | FK → users, ON DELETE CASCADE |
| start_time | TIMESTAMPTZ | NOT NULL |
| end_time | TIMESTAMPTZ | NOT NULL, > start_time |

### Règles métier

- Une salle ne peut pas avoir deux réservations qui se chevauchent (vérifié dans l'API Flask).
- Index `idx_bookings_room_time` pour les requêtes de disponibilité.

---

## MLD (schéma relationnel implémenté)

```sql
rooms (id, name, capacity, floor)
users (id, email, role)
bookings (id, room_id → rooms.id, user_id → users.id, start_time, end_time)
```

---

## Usage Redis (NoSQL — cache)

| Clé | Contenu | TTL |
|-----|---------|-----|
| `availability:{room_id}:{date}` | Créneaux occupés (JSON) | Court (invalidation à chaque booking) |

Redis n'est pas source de vérité — PostgreSQL reste la BDD relationnelle principale.

---

## Liens

- [backup_restore.md](backup_restore.md)
- [DAT — § Services applicatifs](../DAT.md#10-services-applicatifs-et-bases-de-données)
