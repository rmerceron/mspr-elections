# Rapport des datasets — Electio-Analytics POC (Nantes)

**Projet :** MSPR TPRE813 — Prévision de tendances électorales
**Périmètre :** Ville de Nantes (code INSEE `44109`, département Loire-Atlantique `44`)
**Notebook :** `nantes_data_preparation.ipynb`

---

## Vue d'ensemble

Le projet vise à construire un modèle prédictif des tendances électorales à partir d'indicateurs socio-économiques publics. Le choix des datasets repose sur l'hypothèse, largement documentée en science politique, que le vote est influencé par le contexte socio-économique local : emploi, sécurité, revenus, dynamisme économique, tissu associatif et évolution démographique.

Tous les datasets proviennent de **sources publiques et ouvertes** (open data), garantissant la reproductibilité et la conformité légale du projet.

---

## 1. Données électorales — Présidentielles 2022 (Tours 1 & 2)

| Champ | Détail |
|-------|--------|
| **Source** | Ministère de l'Intérieur via data.gouv.fr |
| **URL Tour 1** | `https://static.data.gouv.fr/resources/elections-presidentielles-2022-resultats-du-1er-tour/20250626-142312/elections-presidentielles-2022-resultats-du-1er-tour.csv` |
| **URL Tour 2** | `https://static.data.gouv.fr/resources/elections-presidentielles-2022-resultats-du-2nd-tour/20250626-135901/resultats-elections-presidentielles-2022-2nd-tour.csv` |
| **Format** | CSV (séparateur `;`) |
| **Granularité** | Bureau de vote / commune |
| **Fichiers locaux** | `data/raw/pres_2022_t1.csv`, `data/raw/pres_2022_t2.csv` |

### Justification du choix

Les résultats électoraux constituent la **variable cible** du projet. L'élection présidentielle 2022 est le scrutin national le plus récent disponible en open data avec une granularité communale. Elle offre une vision complète du paysage politique (12 candidats au T1, 2 au T2) et permet de mesurer les parts de vote, l'abstention et les votes blancs/nuls à l'échelle de Nantes. Le notebook recherche également les données de la présidentielle 2017 pour établir une évolution temporelle du comportement électoral.

---

## 2. Données de sécurité — SSMSI (délinquance départementale)

| Champ | Détail |
|-------|--------|
| **Source** | Service Statistique Ministériel de la Sécurité Intérieure (SSMSI) via data.gouv.fr |
| **URL** | `https://static.data.gouv.fr/resources/bases-statistiques-communale-departementale-et-regionale-de-la-delinquance-enregistree-par-la-police-et-la-gendarmerie-nationales/20260129-160318/donnee-dep-data.gouv-2025-geographie2025-produit-le2026-01-22.csv` |
| **Format** | CSV (séparateur `;`) |
| **Granularité** | Département (44 — Loire-Atlantique) |
| **Fichier local** | `data/raw/securite_dep.csv` |
| **Indicateurs** | Nombre de faits par type d'infraction, taux pour mille habitants |

### Justification du choix

La sécurité est un thème électoral majeur en France, régulièrement cité parmi les premières préoccupations des électeurs. Les données SSMSI fournissent une base statistique officielle et normalisée de la délinquance enregistrée, couvrant plusieurs années. L'utilisation du taux pour mille habitants permet des comparaisons temporelles fiables. La granularité départementale (et non communale) est une limitation acceptée, le département 44 restant représentatif du bassin de vie nantais.

---

## 3. Données démographiques — INSEE / API Géo

| Champ | Détail |
|-------|--------|
| **Source** | INSEE — API Géo & Recensement de la Population (RP) |
| **URL API Géo** | `https://geo.api.gouv.fr/communes/44109?fields=nom,code,codesPostaux,codeDepartement,codeRegion,population` |
| **URL RP (référence)** | `https://www.insee.fr/fr/statistiques/8268913` (RP 2021 — Individus — Commune 44109) |
| **Format** | JSON (API) / Série temporelle reconstruite |
| **Granularité** | Commune (Nantes 44109) |
| **Indicateurs** | Population totale, évolution démographique annuelle |

### Justification du choix

La démographie est un facteur structurant du vote : la taille et l'évolution d'une population influencent les besoins en services publics, logement et transports — autant de sujets politiques. L'API Géo de l'INSEE fournit la population légale la plus récente. La série temporelle historique permet de suivre la croissance démographique de Nantes et de la mettre en regard des résultats électoraux. Les données du Recensement de la Population (RP 2021) offrent des détails par âge et sexe, utiles pour comprendre la structure électorale.

---

## 4. Données d'emploi — INSEE (zone d'emploi de Nantes)

| Champ | Détail |
|-------|--------|
| **Source** | INSEE — Taux de chômage par zone d'emploi |
| **Portail de recherche** | data.nantesmetropole.fr & data.gouv.fr |
| **Granularité** | Zone d'emploi 5301 (Nantes) |
| **Indicateurs** | Taux de chômage annuel (%) |
| **Série** | 2012–2025 |

### Justification du choix

Le chômage est l'un des déterminants les plus documentés du vote, en particulier du vote protestataire et de l'abstention. Un taux de chômage élevé est corrélé à un vote plus fort pour les partis antisystème. La zone d'emploi de Nantes (code 5301) correspond au bassin économique de la ville et offre une mesure pertinente de la santé du marché du travail local. Les données INSEE sont la référence officielle pour cet indicateur en France.

---

## 5. Données économiques — Activité des entreprises (API SIRENE / recherche-entreprises)

| Champ | Détail |
|-------|--------|
| **Source** | INSEE SIRENE / API recherche-entreprises.api.gouv.fr |
| **URL API SIRENE** | `https://api.insee.fr/api-sirene/3.11/siret` |
| **URL API recherche** | `https://recherche-entreprises.api.gouv.fr/search` (paramètre `commune=44109`) |
| **Format** | JSON (API REST) |
| **Granularité** | Commune (Nantes 44109) |
| **Indicateurs** | Nombre d'établissements actifs, créations d'entreprises |

### Justification du choix

Le dynamisme économique local — mesuré par le nombre de créations d'entreprises et le stock d'établissements actifs — est un indicateur du climat économique perçu par les habitants. Une économie locale dynamique tend à favoriser le vote pour les partis de gouvernement, tandis qu'un déclin économique nourrit le mécontentement électoral. L'API recherche-entreprises permet un accès libre et sans authentification aux données SIRENE agrégées par commune, ce qui en fait une source pratique et fiable.

---

## 6. Données de pauvreté et revenus — INSEE Filosofi

| Champ | Détail |
|-------|--------|
| **Source** | INSEE — Fichier Localisé Social et Fiscal (Filosofi) |
| **URL de référence** | `https://www.insee.fr/fr/statistiques/7756941` (Filosofi 2021) |
| **Portail de recherche** | data.gouv.fr (recherche `filosofi revenus pauvrete commune 2021`) |
| **Granularité** | Commune (Nantes 44109) |
| **Indicateurs** | Revenu médian par unité de consommation (€), taux de pauvreté (%) |
| **Série** | 2015–2021 |

### Justification du choix

Les inégalités de revenus et la pauvreté sont des facteurs déterminants du comportement électoral. Le dispositif Filosofi de l'INSEE croise les données fiscales (DGFiP) et sociales (CAF, MSA) pour produire des indicateurs précis à l'échelle communale. Le revenu médian reflète le niveau de vie typique des ménages, tandis que le taux de pauvreté mesure la part de la population vivant sous le seuil de pauvreté. Ces deux indicateurs permettent de caractériser la situation sociale de Nantes et d'évaluer son impact potentiel sur les choix électoraux.

---

## 7. Vie associative — RNA / Nantes Métropole Open Data

| Champ | Détail |
|-------|--------|
| **Source** | Répertoire National des Associations (RNA) via data.gouv.fr & Nantes Métropole Open Data |
| **Portail Nantes Métropole** | `https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets` |
| **Portail data.gouv.fr** | Recherche `repertoire national associations RNA nantes` |
| **Granularité** | Commune (Nantes) |
| **Indicateurs** | Nombre d'associations actives, créations annuelles |
| **Série** | 2012–2025 (estimations) |

### Justification du choix

Le tissu associatif est un marqueur du **capital social** d'un territoire — concept démontré comme influent sur la participation électorale et l'engagement civique (Robert Putnam, *Bowling Alone*). Un réseau associatif dense (sport, culture, social) traduit une vie locale active et une plus forte participation démocratique. Les données RNA, gérées par le Ministère de l'Intérieur, constituent le référentiel officiel des associations en France. Nantes Métropole Open Data complète cette source avec des datasets locaux.

---

## 8. Portail Nantes Métropole Open Data (source transversale)

| Champ | Détail |
|-------|--------|
| **Source** | Nantes Métropole Open Data |
| **URL API** | `https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets` |
| **Format** | CSV / JSON (API REST) |
| **Usage** | Recherche et téléchargement de datasets locaux (démographie, emploi, associations, etc.) |

### Justification du choix

Ce portail open data est la source de données locale officielle de la métropole nantaise. Il permet d'accéder à des datasets spécifiques au territoire qui ne sont pas disponibles à cette granularité dans les bases nationales. L'API v2.1 permet une recherche par mots-clés et un export CSV automatisé. Le notebook l'utilise comme source complémentaire pour les sections démographie, emploi et vie associative.

---

## Synthèse des sources et portée

| # | Thématique | Source principale | Type d'accès | Granularité |
|---|-----------|-------------------|--------------|-------------|
| 1 | Élections | Ministère de l'Intérieur / data.gouv.fr | CSV statique | Commune / Bureau de vote |
| 2 | Sécurité | SSMSI / data.gouv.fr | CSV statique | Département |
| 3 | Démographie | INSEE API Géo + RP | API JSON | Commune |
| 4 | Emploi | INSEE | Données publiques | Zone d'emploi |
| 5 | Économie | SIRENE / recherche-entreprises | API JSON | Commune |
| 6 | Pauvreté / Revenus | INSEE Filosofi | Données publiques | Commune |
| 7 | Vie associative | RNA / Nantes Métropole | API JSON | Commune |

---

## Cohérence globale des choix

Les 7 thématiques retenues couvrent les **principaux déterminants socio-économiques du vote** identifiés par la littérature en science politique :

1. **Contexte économique** (emploi, entreprises, revenus) — Le vote est fortement corrélé à la perception de la situation économique personnelle et territoriale.
2. **Cohésion sociale** (pauvreté, inégalités, vie associative) — Les fractures sociales alimentent les clivages électoraux et l'abstention.
3. **Sécurité** — Thème structurant du débat politique français, influençant le positionnement droite/gauche.
4. **Démographie** — La structure de la population (âge, croissance) détermine les attentes politiques et le profil électoral.

Toutes les sources sont **publiques, gratuites et accessibles sans authentification** (à l'exception de l'API SIRENE v3 qui nécessite un token INSEE, contournée par l'API recherche-entreprises). Ce choix garantit la **reproductibilité** complète du projet.

Les données sont consolidées dans un dataset final (`data/clean/nantes_indicateurs_clean.csv`) avec normalisation Min-Max (`data/clean/nantes_indicateurs_normalises.csv`), prêt pour la modélisation.