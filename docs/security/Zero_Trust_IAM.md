# Zero Trust et gestion des identités (IAM)

Smart Office 2.0 — Microsoft Entra ID pour l'API room-booking.

---

## 1. Principes Zero Trust appliqués

| Principe | Mise en œuvre |
|----------|---------------|
| Never trust, always verify | JWT Entra ID validé sur chaque route API (sauf `/health`) |
| Least privilege | Rôles applicatifs `Employee` et `Admin` |
| Micro-segmentation | VLANs pfSense + Wi-Fi invités isolé (VLAN 40) |
| Assume breach | Logs structurés + monitoring (Grafana/Loki) |

---

## 2. Architecture IAM

```text
[Utilisateur] → [Entra ID + MFA] → [Jeton JWT]
       ↓
[room-booking API] → validation JWKS → accès selon rôle
       ↓
[PostgreSQL / Redis]
```

| App Registration | Rôle |
|------------------|------|
| `room-booking-api` | Expose l'API, définit scopes et rôles |
| `room-booking-client` | SPA MSAL — page `/login` pour obtenir un jeton |

Configuration détaillée : [entra_portal_setup.md](entra_portal_setup.md)

---

## 3. Matrice confiance

| Identité | Rôle Entra | Endpoints autorisés |
|----------|------------|---------------------|
| Employé authentifié | `Employee` | GET/POST bookings, GET rooms, GET availability |
| Administrateur | `Admin` | Tout Employee + POST /rooms |
| Invité Wi-Fi (VLAN 40) | — | Internet uniquement, pas d'accès API interne |
| Développement local | — | `AUTH_DISABLED=true` (bypass, non production) |

---

## 4. Validation technique

- Bibliothèque : `PyJWT` + JWKS Entra (`/discovery/v2.0/keys`)
- En-tête : `Authorization: Bearer <access_token>`
- Claims utilisés : `preferred_username`, `roles`
- Email de réservation : issu du jeton (pas du corps de requête)

Code : [cloud/room-booking/src/auth.py](../../cloud/room-booking/src/auth.py)

---

## 5. MFA

MFA activé sur le compte de démonstration Entra ID (voir guide portail).

En production cible : Conditional Access exigeant MFA pour accès à l'API et VPN télétravail.

---

## 6. Compléments réseau

- **Pare-feu** : [firewall_policies.md](firewall_policies.md)
- **VPN télétravail** : guide WireGuard à ajouter (`infra/network/pfsense_wireguard_vpn.md`)
