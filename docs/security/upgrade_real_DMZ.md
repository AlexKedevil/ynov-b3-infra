# Évolution — vers une DMZ isolée

Ce document décrit l'évolution de la DMZ vers une **zone à part entière**, au-delà
de la DMZ-VLAN actuellement en place (voir [firewall_policies.md](firewall_policies.md#cas-particulier-de-la-dmz)).

---

## Point de départ

L'implémentation actuelle réalise la DMZ sous forme d'un VLAN (60) filtré par
pfSense, au même titre que les autres segments. Ce cloisonnement logique, associé à
un jeu de règles *default deny*, isole déjà les services exposés au niveau du
pare-feu.

Sa limite : les services accessibles depuis Internet partagent la même
infrastructure de commutation que les ressources internes. En cas de compromission
d'un service exposé, la séparation ne repose que sur la configuration de pfSense.
L'objectif de cette évolution est de traiter la DMZ comme une zone dédiée, sans
aucun chemin direct vers le LAN interne.

---

## Rôle de la DMZ

La DMZ héberge tout composant qui doit être joignable depuis l'extérieur du réseau
du siège, sans jamais donner d'accès direct au LAN interne. Dans le périmètre du
projet, elle accueillerait :

- **un reverse proxy** (nginx ou HAProxy) en frontal de l'application de
  réservation de salles, terminant le TLS et relayant les requêtes vers le
  back-end ;
- **le point de publication du service métier** (room-booking) lorsqu'il est
  hébergé on-premise plutôt que sur Azure ;
- à terme, tout service exposé complémentaire (portail de messagerie, passerelle
  applicative, serveur de fichiers externe).

Les bases de données et les données sensibles (R&D, PostgreSQL) restent, elles,
dans le VLAN SERVEURS (50), jamais dans la DMZ : seul le reverse proxy y accède, et
uniquement sur le port applicatif requis.

---

## Matrice de flux cible

| Flux | Politique |
|------|-----------|
| Internet → DMZ | Autorisé, limité aux ports publics (HTTPS 443) |
| DMZ → SERVEURS (50) | Restreint aux seuls ports applicatifs nécessaires (ex. 5432 PostgreSQL) |
| DMZ → LAN interne | Interdit |
| DMZ → Internet | Restreint (mises à jour, résolution DNS) |
| LAN interne → DMZ | Autorisé (administration, publication de contenu) |
| MGMT (10) → DMZ | Autorisé (SSH/HTTPS administration) |

Le principe directeur est qu'aucune connexion ne doit pouvoir être initiée depuis
la DMZ vers le réseau interne : un service exposé compromis reste ainsi confiné à
sa zone.

---

## Mise en œuvre sur pfSense

1. **Interface dédiée** — affecter le VLAN 60 (`em1.60`, `10.20.60.0/24`) à une
   interface `DMZ` distincte, idéalement portée par un port physique ou un trunk
   séparé du LAN de production.
2. **NAT entrant (port forward)** — sur l'interface WAN, rediriger le trafic
   `TCP/443` vers l'adresse du reverse proxy en DMZ (ex. `10.20.60.10:443`).
   pfSense crée automatiquement la règle de pare-feu associée.
3. **Règles sortantes de la DMZ** — autoriser explicitement le seul flux
   `DMZ → 10.20.50.x` sur le port applicatif du back-end, puis un `block` général
   vers `LAN net`, `MGMT net` et les autres VLANs internes (*default deny*).
4. **Filtrage des flux internes → DMZ** — n'ouvrir depuis USERS (20) et MGMT (10)
   que les ports d'administration et de publication nécessaires.
5. **Journalisation** — activer les logs sur les règles DMZ et les faire remonter
   vers la chaîne de supervision (syslog pfSense → Loki), afin de détecter toute
   tentative de connexion anormale depuis la zone exposée.

---

## Statut

En PoC, la publication du service métier est assurée par l'hébergement cloud
(Azure ACI), qui remplit le rôle d'isolation vis-à-vis du réseau du siège. La DMZ
isolée décrite ici constitue l'équivalent on-premise, retenu comme cible pour un
déploiement interne en production.
