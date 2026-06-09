# Édition des schémas d'architecture

Les schémas sont en **SVG** (texte XML) dans ce dossier.

| Fichier | Rôle |
|---------|------|
| `smart_office_hybrid.svg` | Architecture hybride **simple** (README par défaut) |
| `smart_office_hybrid_azure_style.svg` | Variante **style Azure** (icônes, zones) |
| `network_vlan.svg` | Réseau on-prem VLAN uniquement |
| `network diagram.xml` | Source **draw.io** (VLAN, édition visuelle) |

## Outils recommandés

### 1. [draw.io / diagrams.net](https://app.diagrams.net/) (le plus simple visuellement)

- Ouvrir `network diagram.xml` directement, ou
- **Fichier → Importer** un `.svg`, modifier, **Exporter → SVG** ou PNG
- Avantage : glisser-déposer, flèches qui accrochent aux blocs

### 2. [Inkscape](https://inkscape.org/) (gratuit, Linux)

```bash
inkscape docs/architecture/smart_office_hybrid_azure_style.svg
```

- Outil « Sélecteur » : déplacer blocs et lignes
- Exporter PNG : `Fichier → Exporter au format PNG`

### 3. VS Code / Cursor (déjà dans le projet)

- Ouvrir le `.svg` → prévisualisation intégrée
- Édition manuelle des coordonnées (`x`, `y`, `x1`, `y1` dans les balises `<line>` / `<rect>`)
- Précis mais fastidieux pour beaucoup de flèches

### 4. Export PNG pour le README

```bash
rsvg-convert -w 1400 docs/architecture/smart_office_hybrid_azure_style.svg \
  -o docs/architecture/screenshots/smart_office_hybrid_azure_style.png
```

Après modification du SVG, relancer cette commande pour mettre à jour le PNG du README.

## Conseils

- Moins de flèches = plus lisible ; reprendre le modèle de `smart_office_hybrid.svg` (6 flux principaux).
- Une flèche = un sens logique ; éviter les couloirs qui se croisent.
- Pour Moodle : PNG exportés depuis SVG ou draw.io.
