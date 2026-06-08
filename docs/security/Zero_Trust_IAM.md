# Zero Trust et gestion des identités (IAM)

> Statut : **À compléter** — sera rempli dans la PR `feature/entra-id-auth`.

---

## 1. Principes Zero Trust appliqués

| Principe | Mise en œuvre Smart Office 2.0 |
|----------|--------------------------------|
| Never trust, always verify | Authentification Entra ID sur chaque accès API |
| Least privilege | Rôles `Employee` / `Admin` sur room-booking |
| Micro-segmentation | VLANs pfSense + isolation Wi-Fi invités |
| Assume breach | Monitoring Grafana/Loki, alertes |

---

## 2. Microsoft Entra ID

*À compléter :*

- Tenant ID
- App Registration `room-booking-api`
- App Registration `room-booking-client` (SPA)
- Scopes et rôles applicatifs
- MFA (Conditional Access ou par utilisateur)

---

## 3. Matrice confiance

| Identité | Rôle | Ressource | Contrôle |
|----------|------|-----------|----------|
| Employé authentifié | Employee | API room-booking | JWT Entra + MFA |
| Administrateur | Admin | CRUD salles | JWT Entra + rôle Admin |
| Invité Wi-Fi | — | Internet seul | VLAN 40 isolé |

---

## 4. VPN télétravail

*À compléter :* WireGuard sur pfSense, accès VLAN USERS depuis l'extérieur.

Voir [../../infra/network/](../../infra/network/) (guide VPN à ajouter).
