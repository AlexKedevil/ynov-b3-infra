# Smart Office 2.0 - Room Booking Service
# Dockerfile pour le déploiement sur Azure Container Instances

# Image de base Python légère et optimisée pour la production
FROM python:3.11-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier le fichier d'application depuis l'hôte vers le conteneur
COPY src/app.py .

# Exposer le port 8080 pour les requêtes HTTP
EXPOSE 8080

# Variable d'environnement pour la version de l'application
# Permet de tracer quelle version est déployée
ENV APP_VERSION=1.0.0

# Commande de démarrage : lance le serveur HTTP Python
CMD ["python", "app.py"]