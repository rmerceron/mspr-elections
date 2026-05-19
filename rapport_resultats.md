# Rapport de résultats — POC Electio-Analytics — Nantes

**MSPR TPRE813 (EPSI I1 EISI)**
Périmètre : Ville de Nantes (INSEE `44109`, dép. `44` Loire-Atlantique)
Source notebook : `nantes_data_preparation.ipynb`
Date : 2026-05-19

---

## 1. Synthèse exécutive

Le notebook `nantes_data_preparation.ipynb` met en œuvre la chaîne complète prévue par le cahier des charges :
collecte multi-sources, nettoyage, consolidation annuelle, normalisation, analyse exploratoire, modélisation
supervisée et projection à 3 ans.

- **Période couverte** : 2012 – 2025 (14 années)
- **Indicateurs consolidés** : 25 colonnes pour 14 lignes annuelles
- **Sources mobilisées** : 8 / 8 disponibles (élections, sécurité, démographie, emploi, économie, revenus, vie associative)
- **Observations électorales pour l'apprentissage** : 4 (2017 T1, 2017 T2, 2022 T1, 2022 T2)
- **Modèle final retenu** : Régression Ridge (α = 1.0)
- **Projection 2026 – 2028** : taux d'abstention ≈ **26.6 %** (participation ≈ **73.4 %**)

---

## 2. Données collectées

### 2.1 Élections présidentielles

| Année | Tour | Niveau géo | Inscrits | Votants | Taux participation | Taux abstention |
|------:|:----:|:-----------|---------:|--------:|-------------------:|----------------:|
| 2017  | T1   | Cantons Nantes        | 187 820 | 152 010 | 80.9 % | 19.1 % |
| 2017  | T2   | Cantons Nantes        | 187 771 | 140 650 | 74.9 % | 25.1 % |
| 2022  | T1   | Bureaux vote Nantes   | 196 999 | 148 737 | 75.5 % | 24.5 % |
| 2022  | T2   | Bureaux vote Nantes   | 196 895 | 140 108 | 71.2 % | 28.8 % |

Source : Ministère de l'Intérieur via data.gouv.fr. La cible du modèle est `taux_abstention`.

### 2.2 Disponibilité des sources

Toutes les sources prévues ont été récupérées avec succès (**8/8**) :

1. Élections présidentielles 2022 T1
2. Élections présidentielles 2022 T2
3. Sécurité / Criminalité (dép. 44 — SSMSI)
4. Démographie (population historique INSEE)
5. Emploi / Chômage (INSEE zone d'emploi 5301)
6. Économie (créations d'entreprises INSEE)
7. Pauvreté / Revenus (INSEE Filosofi)
8. Vie associative (RNA / Nantes Métropole Open Data)

---

## 3. Exploration des indicateurs

### 3.1 Démographie — Population de Nantes

![Évolution de la population de Nantes](data/raw/demographie_population.png)

Croissance démographique régulière sur la période 2006 – 2021, passant d'environ 282 000 à plus de
320 000 habitants. Pas de rupture de tendance significative.

### 3.2 Emploi — Taux de chômage

![Taux de chômage zone d'emploi Nantes](data/raw/emploi_chomage.png)

Taux de chômage estimé sur la zone d'emploi 5301. Tendance générale à la baisse après le pic du milieu
des années 2010.

### 3.3 Économie — Créations d'entreprises

![Créations d'entreprises à Nantes](data/raw/economie_entreprises.png)

Forte progression des créations d'entreprises sur la période, marquant le dynamisme économique local.

### 3.4 Revenus et pauvreté (Filosofi)

![Revenus médians et taux de pauvreté Nantes](data/raw/pauvrete_revenus.png)

Revenu médian par unité de consommation en hausse, taux de pauvreté relativement stable autour de
17 – 18 %.

### 3.5 Qualité des données — valeurs manquantes

![Cartographie des valeurs manquantes — Élections 2022 T1](data/raw/missing_Élec_2022_T1.png)

![Cartographie des valeurs manquantes — Sécurité Dép. 44](data/raw/missing_Sécurité_Dép44.png)

Les jeux bruts présentent peu de trous internes ; les manquements proviennent surtout du
décalage de granularité temporelle (Filosofi triennal, sécurité tronquée sur les premières années).

---

## 4. Consolidation et normalisation

### 4.1 Dataset consolidé

Le dataset annuel `nantes_indicateurs_clean.csv` (14 lignes × 25 colonnes) regroupe toutes les sources.
Les valeurs manquantes initiales sont notamment :

| Indicateur              | Manquants bruts | % |
|-------------------------|----------------:|--:|
| `population`            | 6 | 42.9 % |
| `croissance_pct`        | 6 | 42.9 % |
| `revenu_median_uc`      | 7 | 50.0 % |
| `taux_pauvrete_pct`     | 7 | 50.0 % |
| `indice_gini`           | 7 | 50.0 % |
| `rapport_d9_d1`         | 7 | 50.0 % |
| `total_faits_delictueux`| 4 | 28.6 % |

![Valeurs manquantes — dataset consolidé](data/clean/missing_consolide.png)

Elles sont comblées par **interpolation linéaire** sur les séries numériques continues. Les colonnes
catégorielles (codes, libellés, étiquettes de zone) sont conservées telles quelles.

### 4.2 Normalisation Min-Max

Onze indicateurs quantitatifs sont normalisés sur l'intervalle [0, 1] pour être comparables :

```
creations_asso_norm, creations_entreprises_norm, croissance_pct_norm,
indice_gini_norm, nb_associations_norm, population_norm,
rapport_d9_d1_norm, revenu_median_uc_norm, taux_chomage_pct_norm,
taux_pauvrete_pct_norm, total_faits_delictueux_norm
```

![Indicateurs normalisés au cours du temps](data/clean/indicateurs_normalises.png)

### 4.3 Matrice de corrélation

![Matrice de corrélation des indicateurs](data/clean/matrice_correlations.png)

Les indicateurs de prospérité (population, revenu médian, créations d'entreprises et d'associations)
sont fortement corrélés entre eux. À l'inverse, ils sont anti-corrélés avec les indicateurs
d'inégalité (Gini, D9/D1, pauvreté, chômage). Cette forte multicolinéarité justifie l'emploi d'un
modèle régularisé (Ridge).

---

## 5. Modélisation

### 5.1 Cible et variables explicatives

- **Cible** : `taux_abstention` (4 observations : 2017 T1/T2, 2022 T1/T2).
- **Variables explicatives** : 11 indicateurs `_norm` issus de la consolidation.
- **Corrélation indicateurs ↔ abstention** : toutes proches de **± 0.66** en valeur absolue (effet
  mécanique lié au très faible nombre d'observations électorales).

![Corrélation des indicateurs avec le taux d'abstention](data/clean/correlation_abstention_rate.png)

### 5.2 Comparaison des modèles (apprentissage)

| Modèle               | MAE   | RMSE  | R²    | MAE (points) |
|----------------------|------:|------:|------:|-------------:|
| Baseline (moyenne)   | 0.027 | 0.035 | 0.000 | 2.65 |
| Régression linéaire  | 0.026 | 0.026 | 0.433 | 2.59 |
| **Ridge (α = 1.0)**  | 0.026 | 0.027 | 0.414 | 2.59 |

### 5.3 Validation croisée Leave-One-Out

| Modèle               | MAE_CV | RMSE_CV | R²_CV  | MAE_CV (points) |
|----------------------|-------:|--------:|-------:|----------------:|
| Baseline (moyenne)   | 0.035 | 0.047 | −0.78 | 3.54 |
| Régression linéaire  | 0.052 | 0.052 | −1.27 | 5.18 |
| **Ridge (α = 1.0)**  | 0.047 | 0.048 | −0.92 | 4.69 |

Les R² négatifs en validation croisée confirment que, avec seulement 4 observations, aucun modèle
ne généralise mieux que la simple moyenne. **Ridge** est cependant retenu : c'est le moins instable
hors apprentissage et il atténue la multicolinéarité.

### 5.4 Prédictions sur le jeu d'apprentissage

| Année | Tour | Abstention observée | Abstention prédite | Erreur absolue |
|------:|:----:|--------------------:|-------------------:|---------------:|
| 2017  | T1   | 0.191 | 0.226 | 0.035 |
| 2017  | T2   | 0.251 | 0.226 | 0.025 |
| 2022  | T1   | 0.245 | 0.262 | 0.017 |
| 2022  | T2   | 0.288 | 0.262 | 0.027 |

![Taux d'abstention observé vs prédit (Ridge)](data/clean/actual_predicted_abstention.png)

### 5.5 Coefficients du modèle Ridge

| Variable                       | Coefficient |
|--------------------------------|------------:|
| `taux_pauvrete_pct_norm`       | −0.0082 |
| `rapport_d9_d1_norm`           | −0.0077 |
| `indice_gini_norm`             | −0.0070 |
| `taux_chomage_pct_norm`        | −0.0068 |
| `revenu_median_uc_norm`        | +0.0066 |
| `population_norm`              | +0.0053 |
| `creations_entreprises_norm`   | +0.0046 |
| `creations_asso_norm`          | +0.0037 |
| `nb_associations_norm`         | +0.0034 |
| `croissance_pct_norm`          | +0.0024 |
| `total_faits_delictueux_norm`  | +0.0021 |

![Influence des variables dans le modèle Ridge](data/clean/influence_ridge_model.png)

Lecture : les indicateurs d'inégalité et de précarité ont un signe négatif (Ridge pénalise
l'abstention prédite lorsqu'ils augmentent), tandis que les indicateurs liés au dynamisme local
ont un signe positif. L'amplitude reste faible car les variables sont normalisées et le modèle est
régularisé.

### 5.6 Projection à 1, 2 et 3 ans

| Année | Abstention prédite | Participation prédite |
|------:|-------------------:|----------------------:|
| 2026  | 0.266 (26.6 %) | 0.734 (73.4 %) |
| 2027  | 0.266 (26.6 %) | 0.734 (73.4 %) |
| 2028  | 0.266 (26.6 %) | 0.734 (73.4 %) |

![Projection du taux d'abstention 2026 – 2028](data/clean/projection_abstention_rate.png)

La projection est quasi-constante : les indicateurs explicatifs sont eux-mêmes extrapolés par
régression linéaire sur leur tendance temporelle, et la régularisation Ridge écrase les variations
restantes.

---

## 6. Livrables produits

| Fichier | Description |
|---------|-------------|
| `data/clean/nantes_indicateurs_clean.csv`        | Dataset annuel consolidé (14 × 25) |
| `data/clean/nantes_indicateurs_normalises.csv`   | Indicateurs normalisés Min-Max |
| `data/clean/elections_pres_2017_t1_nantes.csv`   | Résultats 2017 T1 par canton |
| `data/clean/elections_pres_2017_t2_nantes.csv`   | Résultats 2017 T2 par canton |
| `data/clean/elections_pres_2022_t1_nantes.csv`   | Résultats 2022 T1 par bureau de vote |
| `data/clean/elections_pres_2022_t2_nantes.csv`   | Résultats 2022 T2 par bureau de vote |
| `data/clean/securite_dep44_clean.csv`            | Indicateurs SSMSI dép. 44 nettoyés |
| `data/clean/target_elections.csv`                | Cible agrégée (4 observations) |
| `data/clean/model_resultats_comparaison.csv`     | Métriques apprentissage |
| `data/clean/model_resultats_validation_croisee.csv` | Métriques Leave-One-Out |
| `data/clean/model_predictions_train.csv`         | Prédictions sur l'apprentissage |
| `data/clean/model_coefficients_ridge.csv`        | Coefficients Ridge |
| `data/clean/model_predictions_future.csv`        | Projections 2026 – 2028 |

---

## 7. Limites et pistes d'amélioration

- **Volume électoral très faible** : 4 observations (2 scrutins × 2 tours). C'est la principale
  faiblesse du POC ; elle explique les R² de validation croisée négatifs.
- **Granularités hétérogènes** : indicateurs annuels (population, chômage) vs triennaux (Filosofi)
  vs ponctuels (élections). L'interpolation comble les trous mais ne crée pas de signal réel.
- **Sources nationales/départementales en proxy** : criminalité dép. 44 et zone d'emploi Nantes ne
  reflètent pas exactement le périmètre communal.
- **Pistes** : intégrer législatives, européennes et municipales (× 4 – 5 observations), descendre
  à un niveau infra-communal (bureaux de vote, IRIS), tester des modèles non linéaires (Random
  Forest, Gradient Boosting) une fois le volume suffisant, et croiser avec des données sociologiques
  par IRIS (CSP, diplôme, structure des ménages).