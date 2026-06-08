# Room Booking Service (Proof of Concept)

Application Flask containerisée pour la réservation de salles — livrable cloud Smart Office 2.0.

## Stack

| Composant | Technologie |
|-----------|-------------|
| API | Flask 3 + Gunicorn |
| SQL | PostgreSQL 16 |
| NoSQL | Redis 7 (cache disponibilité) |
| Auth | Microsoft Entra ID (JWT + MSAL) — voir [entra_portal_setup.md](../../docs/security/entra_portal_setup.md) |

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
    ├── auth.py           # Validation JWT Entra ID
    ├── db.py
    ├── cache.py
    └── static/login.html # Page MSAL (démo)
```

## Démarrage local

```bash
cd cloud/room-booking
docker compose up --build
```

Par défaut `AUTH_DISABLED=true` — API accessible sans jeton pour le dev.

Avec Entra ID : copier `.env.example` → `.env`, suivre [entra_portal_setup.md](../../docs/security/entra_portal_setup.md), puis :

```bash
docker compose --env-file .env up --build
```

Page de connexion : [http://localhost:8080/login](http://localhost:8080/login)

## API Endpoints

Toutes les routes sauf `/health`, `/auth/config`, `/login`, `/static/*` requièrent  
`Authorization: Bearer <token>` quand `AUTH_DISABLED=false`.

### `GET /health`
Statut du service (public).

### `GET /login`
Redirection vers la page MSAL.

### `GET /rooms`
Liste des salles (Employee+).

### `POST /rooms`
Créer une salle (**Admin** uniquement).

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
  "start_time": "2026-06-10T09:00:00+02:00",
  "end_time": "2026-06-10T10:00:00+02:00"
}
```

L'email utilisateur est extrait du jeton Entra ID.

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

**ACI (France Central) :** groupe multi-container (app + postgres + redis).

- URL : `http://ynov-smartoffice-b3.francecentral.azurecontainer.io:8080`
- Guide : [infra/azure/aci-deploy.md](../../infra/azure/aci-deploy.md)
- Secret GitHub requis : `AZURE_CREDENTIALS` (Service Principal)
