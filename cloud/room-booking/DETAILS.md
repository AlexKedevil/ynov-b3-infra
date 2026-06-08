# Room Booking Service (Proof of Concept)

Application Flask containerisée pour la réservation de salles — livrable cloud Smart Office 2.0.

## Stack

| Composant | Technologie |
|-----------|-------------|
| API | Flask 3 + Gunicorn |
| SQL | PostgreSQL 16 |
| NoSQL | Redis 7 (cache disponibilité) |
| Auth | Microsoft Entra ID — PR suivante `feature/entra-id-auth` |

## Structure

```text
room-booking/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── init.sql              # Schéma + données de démo
├── DETAILS.md
└── src/
    ├── app.py            # Routes API
    ├── config.py
    ├── db.py
    └── cache.py
```

## Démarrage local

```bash
cd cloud/room-booking
docker compose up --build
```

## API Endpoints

### `GET /health`
Statut du service.

### `GET /rooms`
Liste des salles.

### `POST /rooms`
Créer une salle (auth Entra à venir).

```json
{"name": "Salle Epsilon", "capacity": 10, "floor": 2}
```

### `GET /bookings`
Liste des réservations. Paramètres optionnels : `room_id`, `date` (YYYY-MM-DD).

### `GET /rooms/{id}/availability?date=2026-06-10`
Créneaux occupés (cache Redis 5 min).

### `POST /bookings`
Créer une réservation.

```json
{
  "room_id": 1,
  "user_email": "employee@smartoffice.local",
  "start_time": "2026-06-10T09:00:00+02:00",
  "end_time": "2026-06-10T10:00:00+02:00"
}
```

### `DELETE /bookings/{id}`
Annuler une réservation.

## Tests rapides

```bash
curl http://localhost:8080/health
curl http://localhost:8080/rooms
curl -X POST http://localhost:8080/bookings \
  -H "Content-Type: application/json" \
  -d '{"room_id":1,"user_email":"test@smartoffice.local","start_time":"2026-06-10T14:00:00+02:00","end_time":"2026-06-10T15:00:00+02:00"}'
curl "http://localhost:8080/rooms/1/availability?date=2026-06-10"
```

## Déploiement Azure

Pipeline : GitHub Actions → ACR `smartofficeynov` → ACI (France Central).

> L'image Docker ne contient que l'app. PostgreSQL et Redis sont dans `docker-compose` pour le dev local ; le déploiement ACI multi-container sera ajouté dans `feature/azure-aci-deploy`.
