# Analyse des impacts sur l'activité (BIA)

> Statut : **À compléter** — PR `feature/dat-pca-security-docs`.

---

## Contexte

Startup biotechnologie — 200 employés cibles, activité R&D et bureautique fortement dépendante de l'IT.

---

## Tableau des risques

| Scénario | Probabilité | Impact métier | RTO cible | RPO cible |
|----------|-------------|---------------|-----------|-----------|
| Panne FAI / WAN | Moyenne | Élevé — télétravail et cloud inaccessibles | 4 h | N/A |
| Cyberattaque (ransomware) | Faible | Critique — données et réputation | 24 h | 1 h |
| Panne serveur AD / Entra ID | Faible | Élevé — plus d'authentification | 2 h | 15 min |
| Panne pfSense / réseau local | Moyenne | Élevé — bureau paralysé | 2 h | N/A |
| Indisponibilité Azure (ACI) | Faible | Moyen — réservation salles | 1 h | 0 |
| Panne PostgreSQL | Moyenne | Moyen — perte données réservations | 2 h | 1 h |

---

## Processus critiques

1. Accès réseau bureau et Wi-Fi
2. Authentification employés (Entra ID)
3. Réservation de salles (room-booking)
4. Accès Internet et messagerie

---

## Dépendances

*À compléter : chaîne de dépendances entre FAI → pfSense → VLANs → services.*
