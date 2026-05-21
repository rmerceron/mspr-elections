# Electio-Analytics — POC MSPR TPRE813

Preuve de concept pour la **prévision de tendances électorales** à partir de données publiques ouvertes.
Périmètre géographique : **Ville de Nantes** (code INSEE `44109`, dép. `44` — Loire-Atlantique).

Projet réalisé dans le cadre du MSPR TPRE813 — EPSI I1 EISI.

---

## Objectif

Constituer un dataset multi-dimensionnel couvrant Nantes sur la période 2013–2022, combinant résultats électoraux et indicateurs socio-économiques, afin d'entraîner un modèle de prévision des tendances politiques.

---

## Données collectées

| # | Indicateur | Source |
|---|---|---|
| 1 | Résultats électoraux — Présidentielles 2017 et 2022 (T1 + T2) | Ministère de l'Intérieur — data.gouv.fr |
| 2 | Criminalité / Sécurité | SSMSI — data.gouv.fr |
| 3 | Démographie (population) | INSEE — geo.api.gouv.fr |
| 4 | Emploi / Chômage | INSEE — Zone d'emploi Nantes |
| 5 | Économie — Créations d'entreprises | recherche-entreprises.api.gouv.fr |
| 6 | Pauvreté / Revenus | INSEE Filosofi |
| 7 | Vie associative | RNA / Nantes Métropole Open Data |

---

## Structure du projet

```
mspr1/
├── nantes_data_preparation.ipynb  # Notebook principal : collecte + nettoyage + export
├── data/
│   ├── raw/    # Données brutes téléchargées (non versionnées)
│   └── clean/  # Dataset final exporté (non versionné)
└── 25-26 I1 EISI - Sujet MSPR TPRE813.pdf
```

---

## Installation et lancement

```bash
# Créer et activer l'environnement virtuel (Python 3.14)
python -m venv .venv
source .venv/Scripts/activate   # Git Bash
# ou
.venv\Scripts\activate          # PowerShell / CMD

# Installer les dépendances
pip install jupyter pandas numpy matplotlib seaborn missingno requests xlrd openpyxl

# Lancer Jupyter
jupyter notebook
```

Ouvrir ensuite `nantes_data_preparation.ipynb` et exécuter les cellules dans l'ordre.

---

## Livrables

1. **Dataset nettoyé** : `data/clean/nantes_indicateurs_clean.csv`
2. **Dataset normalisé** : `data/clean/nantes_indicateurs_normalises.csv`
3. **Code commenté** : `nantes_data_preparation.ipynb`

---

## Sources des données électorales

- T1 2017 : [data.gouv.fr — Résultats du 1er tour](https://www.data.gouv.fr/datasets/election-presidentielle-des-23-avril-et-7-mai-2017-resultats-du-1er-tour)
- T2 2017 : [data.gouv.fr — Résultats définitifs du 2nd tour](https://www.data.gouv.fr/datasets/election-presidentielle-des-23-avril-et-7-mai-2017-resultats-definitifs-du-2nd-tour)
- 2022 : [data.gouv.fr — Élections présidentielles 2022](https://www.data.gouv.fr/fr/pages/donnees-des-elections/)
