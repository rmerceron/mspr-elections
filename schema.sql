-- =============================================================
-- schema.sql — Electio-Analytics POC
-- Base : electio_analytics.db (SQLite)
-- Périmètre : Nantes (INSEE 44109, Dép. 44)
-- =============================================================

-- -------------------------------------------------------------
-- TABLE 1 : indicateurs_annuels
-- Dataset principal consolidé — une ligne par année
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS indicateurs_annuels (
    annee                   INTEGER NOT NULL,   -- Année (2012–2025)
    code_commune            TEXT    NOT NULL,   -- Code INSEE commune (44109)
    nom_commune             TEXT    NOT NULL,   -- Nom de la commune

    -- Démographie (source : INSEE Recensement)
    population              INTEGER,            -- Population légale
    croissance_pct          REAL,               -- Croissance démographique (%)

    -- Emploi (source : INSEE zone d'emploi 5301)
    taux_chomage_pct        REAL,               -- Taux de chômage BIT (%)

    -- Économie (source : INSEE SIRENE)
    creations_entreprises   INTEGER,            -- Créations d'entreprises

    -- Pauvreté / Revenus (source : INSEE Filosofi)
    revenu_median_uc        REAL,               -- Revenu médian par UC (€)
    taux_pauvrete_pct       REAL,               -- Taux de pauvreté (%)
    indice_gini             REAL,               -- Indice de Gini (0–1)
    rapport_d9_d1           REAL,               -- Rapport interdécile D9/D1

    -- Vie associative (source : RNA / Nantes Métropole)
    nb_associations         INTEGER,            -- Nombre d'associations actives
    creations_asso          INTEGER,            -- Créations d'associations par an

    -- Sécurité (source : SSMSI — agrégé département 44)
    total_faits_delictueux  INTEGER,            -- Total faits enregistrés

    PRIMARY KEY (annee, code_commune)
);

-- -------------------------------------------------------------
-- TABLE 2 : indicateurs_normalises
-- Mêmes données + colonnes _norm (Min-Max 0–1)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS indicateurs_normalises (
    annee                        INTEGER NOT NULL,
    code_commune                 TEXT    NOT NULL,
    nom_commune                  TEXT,

    -- Indicateurs bruts (identiques à indicateurs_annuels)
    population                   INTEGER,
    croissance_pct               REAL,
    taux_chomage_pct             REAL,
    creations_entreprises        INTEGER,
    revenu_median_uc             REAL,
    taux_pauvrete_pct            REAL,
    indice_gini                  REAL,
    rapport_d9_d1                REAL,
    nb_associations              INTEGER,
    creations_asso               INTEGER,
    total_faits_delictueux       INTEGER,

    -- Colonnes normalisées Min-Max (0 = minimum historique, 1 = maximum)
    population_norm              REAL,
    croissance_pct_norm          REAL,
    taux_chomage_pct_norm        REAL,
    creations_entreprises_norm   REAL,
    revenu_median_uc_norm        REAL,
    taux_pauvrete_pct_norm       REAL,
    indice_gini_norm             REAL,
    rapport_d9_d1_norm           REAL,
    nb_associations_norm         REAL,
    creations_asso_norm          REAL,
    total_faits_delictueux_norm  REAL,

    PRIMARY KEY (annee, code_commune)
);

-- -------------------------------------------------------------
-- TABLE 3 : elections_pres_2022_t1
-- Résultats par bureau de vote — Tour 1 Présidentielle 2022
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS elections_pres_2022_t1 (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    code_commune        TEXT,
    annee               TEXT,
    tour                TEXT,
    scrutin             TEXT,
    inscrits            INTEGER,
    votants             INTEGER,
    exprimes            INTEGER,
    blancs              INTEGER,
    nuls                INTEGER
);

-- -------------------------------------------------------------
-- TABLE 4 : elections_pres_2022_t2
-- Résultats par bureau de vote — Tour 2 Présidentielle 2022
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS elections_pres_2022_t2 (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    code_commune        TEXT,
    annee               TEXT,
    tour                TEXT,
    scrutin             TEXT,
    inscrits            INTEGER,
    votants             INTEGER,
    exprimes            INTEGER,
    blancs              INTEGER,
    nuls                INTEGER
);

-- -------------------------------------------------------------
-- TABLE 5 : securite_dep44
-- Délinquance enregistrée — Département 44 (SSMSI), agrégé annuel
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS securite_dep44 (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    annee                   INTEGER,
    code_commune            TEXT,
    total_faits_delictueux  INTEGER
);

-- -------------------------------------------------------------
-- TABLE 6 : pipeline_log
-- Journal d'exécution du pipeline ETL (traçabilité)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pipeline_log (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    date_execution  TEXT    NOT NULL,   -- Horodatage ISO 8601
    nb_lignes_clean INTEGER,            -- Lignes dans le dataset final
    nb_colonnes     INTEGER,            -- Colonnes dans le dataset final
    periode         TEXT,               -- Ex : "2012–2025"
    commune         TEXT,               -- Nom de la commune
    code_insee      TEXT,               -- Code INSEE
    sources         TEXT                -- Sources utilisées (liste séparée par virgules)
);

-- -------------------------------------------------------------
-- INDEX pour optimiser les requêtes
-- -------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_indic_annee    ON indicateurs_annuels (annee);
CREATE INDEX IF NOT EXISTS idx_indic_commune  ON indicateurs_annuels (code_commune);
CREATE INDEX IF NOT EXISTS idx_secu_annee     ON securite_dep44 (annee);
