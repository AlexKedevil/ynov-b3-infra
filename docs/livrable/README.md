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

## Génération automatique (ZIP)

```bash
# Captures PoC a jour (Grafana, backup, VPN, cloud)
./scripts/capture-lab-proofs.sh

# ZIP Moodle (markdown + screenshots)
./docs/livrable/build_moodle_zip.sh
# -> docs/livrable/SmartOffice_B3_YYYYMMDD.zip
```

## Génération PDF (optionnel)

```bash
pandoc docs/DAT.md -o docs/livrable/01_DAT.pdf
# Ou : VS Code / GitHub -> imprimer en PDF
```

---

## Checklist avant remise

- [x] Tous les livrables [docs/README.md](../README.md) sont à statut « Fait »
- [x] Screenshots PoC (`./scripts/capture-lab-proofs.sh`)
- [x] Lien GitHub valide
- [ ] ZIP uploadé sur Moodle avant le 18/06/2026 00:00 (`build_moodle_zip.sh`)
