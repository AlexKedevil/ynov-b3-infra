# 🚀 Room Booking Service (Proof of Concept)

Ce service est une application Python (Flask) containerisée servant de preuve de concept (PoC) pour le déploiement cloud hybride du projet Smart Office 2.0.

## 🛠️ Stack Technique

- **Langage:** Python 3.9+
- **Framework:** Flask
- **Containerisation:** Docker & Docker Compose
- **Déploiement Cible:** Azure Container Instances (ACI)

## 📁 Structure du Service

```text
room-booking/
├── Dockerfile          # Image multi-stage pour Python
├── docker-compose.yml  # Orchestration pour le développement local
├── DETAILS.md          # Documentation détaillée (ce fichier)
└── src/
    └── app.py          # Logique de l'API
```

## 🚀 Lancement Rapide

### Avec Docker Compose (Recommandé)

Le fichier `docker-compose.yml` permet de lancer le service avec toutes ses configurations en une seule commande :

```bash
docker-compose up --build
```

Le service sera accessible sur [http://localhost:8080](http://localhost:8080).

### Avec Docker (Manuel)

```bash
docker build -t room-booking .
docker run -p 8080:8080 room-booking
```

## 📡 API Endpoints

### `GET /`
Retourne le statut du service et les informations du projet.

**Exemple de réponse :**
```json
{
  "service": "room-booking",
  "version": "1.0.0",
  "status": "healthy",
  "project": "Smart Office 2.0 - B3 INYOV"
}
```

## ☁️ Déploiement Azure

Ce service est automatiquement déployé via GitHub Actions vers **Azure Container Registry (ACR)** puis instancié sur **Azure Container Instances (ACI)**.
