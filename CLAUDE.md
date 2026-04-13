# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Electio-Analytics POC** — MSPR TPRE813 (EPSI I1 EISI)
Preuve de concept pour la prévision de tendances électorales à partir de données publiques.
Périmètre géographique : **Ville de Nantes** (code INSEE `44109`, dép. `44` Loire-Atlantique).

Le cahier des charges complet est dans `25-26 I1 EISI - Sujet MSPR TPRE813.pdf`.

## Environment

- **Python** : 3.14 (via `py -3.14`)
- **Environnement virtuel** : `.venv/` (Python 3.14, pip 26)
- **Formatter** : Black (configuré dans PyCharm)

## Running the project

```bash
# Activer l'environnement virtuel
.venv/Scripts/activate        # Windows CMD/PowerShell
source .venv/Scripts/activate  # Git Bash

# Lancer Jupyter
py -3.14 -m jupyter notebook

# Installer les dépendances
py -3.14 -m pip install -r requirements.txt
```

## Project structure

```
mspr1/
├── nantes_data_preparation.ipynb  # Notebook principal : collecte + nettoyage
├── data/
│   ├── raw/    # Données brutes téléchargées (CSV, PNG d'exploration)
│   └── clean/  # Données nettoyées et normalisées (export final)
└── 25-26 I1 EISI - Sujet MSPR TPRE813.pdf
```

## Notebook architecture (`nantes_data_preparation.ipynb`)

Le notebook est auto-suffisant et structuré en 10 sections :

| Section | Contenu |
|---------|---------|
| 0 | Configuration, imports, fonctions utilitaires (`rapport_qualite`, `telecharger_csv`, etc.) |
| 1 | Données électorales — Présidentielles 2022 T1+T2 (data.gouv.fr) |
| 2 | Sécurité / Criminalité — Base SSMSI département 44 |
| 3 | Démographie — Population historique Nantes + API `geo.api.gouv.fr` |
| 4 | Emploi — Taux de chômage zone d'emploi Nantes (INSEE) |
| 5 | Économie — Créations d'entreprises + API `recherche-entreprises.api.gouv.fr` |
| 6 | Pauvreté / Revenus — Filosofi INSEE |
| 7 | Vie associative — RNA / Nantes Métropole Open Data |
| 8 | Qualité globale — missingno, rapport disponibilité sources |
| 9 | Consolidation — merge annuel, interpolation, normalisation Min-Max, corrélations |
| 10 | Export — `data/clean/nantes_indicateurs_clean.csv` et `_normalises.csv` |

## Data sources

| Source | URL | Usage |
|--------|-----|-------|
| Ministère Intérieur (data.gouv.fr) | `https://www.data.gouv.fr/fr/pages/donnees-des-elections/` | Résultats électoraux |
| SSMSI criminalité | `https://static.data.gouv.fr/resources/bases-statistiques-communale-...` | Sécurité dép. 44 |
| API géographie INSEE | `https://geo.api.gouv.fr/communes/44109` | Population commune |
| Nantes Métropole Open Data | `https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets` | Indicateurs locaux |
| API entreprises | `https://recherche-entreprises.api.gouv.fr/search` | Établissements actifs |
| INSEE Filosofi | Via data.gouv.fr ou insee.fr | Revenus / pauvreté |

## Key constants

```python
CODE_COMMUNE = '44109'   # Code INSEE Nantes
CODE_DEP     = '44'      # Loire-Atlantique
CODE_REGION  = '52'      # Pays de la Loire
```

## Deliverables (from spec)

1. Dossier de synthèse (justification choix géographique, MCD, résultats modèle)
2. Dataset nettoyé (`data/clean/nantes_indicateurs_clean.csv`)
3. Code commenté (notebooks Jupyter)
4. Support de soutenance