# Remise du dossier final — Moodle 18/06/2026

Le contenu officiel du projet est versionné dans ce dépôt GitHub. Moodle reçoit un **export** de `docs/`, pas des documents séparés.

---

## Contenu à remettre

Générer un ZIP ou des PDF à partir de :

| Fichier source | Export suggéré |
|----------------|----------------|
| [docs/DAT.md](../DAT.md) | `01_DAT.pdf` |
| [docs/security/](../security/) | `02_Securite.pdf` |
| [docs/pca_pra/](../pca_pra/) | `03_PCA_PRA.pdf` |
| [docs/architecture/screenshots/](../architecture/screenshots/) | Dossier `04_PoC_Reseau/` |
| Captures cloud / monitoring | `05_PoC_Cloud/`, `06_PoC_Monitoring/` |
| [docs/database/MCD_Merise.md](../database/MCD_Merise.md) | `07_Base_de_donnees.pdf` |
| [docs/project_management/](../project_management/) | `08_Gestion_projet.pdf` |

Inclure dans le README du ZIP :

```text
Dépôt GitHub : https://github.com/AlexKedevil/ynov-b3-infra
Équipe : Flaujat Sam, Queudeville Alexandre
```

---

## Génération PDF (exemples)

```bash
# Pandoc (si installé)
pandoc docs/DAT.md -o docs/livrable/01_DAT.pdf

# Ou : ouvrir les .md dans VS Code / GitHub → imprimer en PDF
```

---

## Checklist avant remise

- [ ] Tous les livrables [docs/README.md](../README.md) sont à statut « Fait »
- [ ] Screenshots PoC à jour
- [ ] Lien GitHub valide
- [ ] ZIP uploadé sur Moodle avant le 18/06/2026 00:00
