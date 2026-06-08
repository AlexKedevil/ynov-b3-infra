# Modèle conceptuel de données — Room Booking

> Statut : **À compléter** — sera rempli dans la PR `feature/dat-pca-security-docs`.

---

## Entités (Merise)

### ENTITE : SALLE

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_salle | INT | PK |
| nom | VARCHAR(100) | NOT NULL |
| capacite | INT | NOT NULL |
| etage | INT | NOT NULL |

### ENTITE : UTILISATEUR

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_utilisateur | INT | PK |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| entra_oid | VARCHAR(255) | UNIQUE (lien Entra ID) |
| role | ENUM | employee, admin |

### ENTITE : RESERVATION

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_reservation | INT | PK |
| date_debut | TIMESTAMP | NOT NULL |
| date_fin | TIMESTAMP | NOT NULL |
| #id_salle | INT | FK → SALLE |
| #id_utilisateur | INT | FK → UTILISATEUR |

---

## Associations

- **RESERVER** : UTILISATEUR (1,N) — (0,N) RESERVATION — (1,1) SALLE
- Contrainte métier : pas de chevauchement de créneaux pour une même salle

---

## Schéma relationnel (aperçu)

```sql
-- À implémenter dans cloud/room-booking/init.sql
CREATE TABLE rooms (...);
CREATE TABLE users (...);
CREATE TABLE bookings (...);
```

---

## Usage Redis (NoSQL)

- Clé `availability:{room_id}:{date}` — créneaux libres (cache)
- TTL court pour rafraîchissement depuis PostgreSQL
