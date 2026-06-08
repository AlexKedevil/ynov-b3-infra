# Plan de Continuité d'Activité (PCA) et Plan de Reprise d'Activité (PRA)

> Statut : **Fait**

Voir aussi [BIA.md](BIA.md).

---

## PCA — Maintenir l'activité en cas d'incident

### Panne FAI

1. Basculer télétravail sur 4G/5G personnelle (politique RH)
2. Services cloud (room-booking) restent accessibles via Internet mobile
3. Communication interne via Teams/messagerie mobile
4. Bureau local : mode dégradé sans cloud, réseau LAN interne si pfSense OK

### Cyberattaque

1. Isoler segments réseau affectés (règles pfSense emergency)
2. Révoquer sessions Entra ID (`Revoke-AzureADUserAllRefreshToken` cible)
3. Activer procédure restauration depuis sauvegardes NAS / Blob
4. Escalade DSI + analyse logs Grafana/Loki (corrélation firewall + API)
5. Notification équipe via Trello colonne « Incident »

### Indisponibilité room-booking (ACI)

1. Vérifier statut Azure : `az container show -g rg-smartoffice -n smartoffice-booking`
2. Redéployer depuis ACR : workflow GitHub Actions ou `az container create`
3. Communication utilisateurs : réservation manuelle temporaire (Teams)

---

## PRA — Reprise après incident majeur

| Ordre | Composant | Action | Responsable |
|-------|-----------|--------|-------------|
| 1 | Lien WAN / FAI | Contacter FAI, activer lien secours si disponible | Admin réseau |
| 2 | pfSense | Restaurer config XML depuis NAS | Admin réseau |
| 3 | Entra ID | Vérifier annuaire, MFA, rôles App | Admin IAM |
| 4 | PostgreSQL | Restaurer dernier `pg_dump` | Admin BDD |
| 5 | ACI room-booking | Redéployer image depuis ACR | DevOps |
| 6 | Monitoring | `docker compose up -d` dans `monitoring/` | DevOps |

---

## Objectifs

| Indicateur | Valeur cible |
|------------|--------------|
| RTO réseau bureau | 2 h |
| RPO données réservations | 1 h |
| RTO service cloud | 1 h |

---

## Tests réalisés (PoC)

| Test | Date | Résultat |
|------|------|----------|
| Déploiement ACI via GitHub Actions | 06/2026 | OK — health check `/health` |
| Restauration PostgreSQL locale (`pg_dump` / `psql`) | 06/2026 | OK — procédure documentée |
| Export config pfSense (XML manuel) | 06/2026 | OK — via WebGUI Diagnostics |
| Détection anomalie Grafana (pfSense + API) | 06/2026 | OK — voir `monitoring/anomaly-scenario.md` |

Prochain test planifié avant soutenance : restauration complète room-booking (BDD + ACI) en < 1 h.
