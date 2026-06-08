# Plan de Continuité d'Activité (PCA) et Plan de Reprise d'Activité (PRA)

> Statut : **À compléter** — PR `feature/dat-pca-security-docs`.

Voir aussi [BIA.md](BIA.md).

---

## PCA — Maintenir l'activité en cas d'incident

### Panne FAI

1. Basculer télétravail sur 4G/5G personnelle (politique RH)
2. Services cloud (room-booking) restent accessibles via Internet mobile
3. Communication interne via Teams/messagerie mobile

### Cyberattaque

1. Isoler segments réseau affectés (règles pfSense emergency)
2. Révoquer sessions Entra ID
3. Activer procédure restauration depuis sauvegardes
4. Escalade DSI + prestataire sécurité

---

## PRA — Reprise après incident majeur

| Ordre | Composant | Action | Responsable |
|-------|-----------|--------|-------------|
| 1 | Lien WAN / FAI | Contacter FAI, activer lien secours si disponible | Admin réseau |
| 2 | pfSense | Restaurer config XML sauvegarde | Admin réseau |
| 3 | Entra ID | Vérifier annuaire, MFA | Admin IAM |
| 4 | PostgreSQL | Restaurer dernier `pg_dump` | Admin BDD |
| 5 | ACI room-booking | Redéployer image depuis ACR | DevOps |

---

## Objectifs

| Indicateur | Valeur cible |
|------------|--------------|
| RTO réseau bureau | 2 h |
| RPO données réservations | 1 h |
| RTO service cloud | 1 h |

---

## Tests

*À compléter : date du dernier test de restauration.*
