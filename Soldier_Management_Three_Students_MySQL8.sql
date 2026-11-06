-- ============================================================================
-- Soldier Management SQL Quiz — MySQL 8
-- Fichier : Soldier_Management_Three_Students_MySQL8.sql
-- Contient 3 blocs indépendants (un par étudiant, une base sms_<numéro> chacun).
-- Exécution : mysql -u <compte_examen> -p < Soldier_Management_Three_Students_MySQL8.sql
--             (placer soldiers_seed.sql dans le même dossier, lancer depuis ce dossier)
--
-- VALEURS PERSONNELLES (formules du sujet) :
--   P = dernier chiffre du numéro
--   U = (deux derniers chiffres mod 6) + 1
--   M = ((P + 5) mod 5) + 1      -- l'exemple du sujet (7 -> M=3) montre un modulo 5 (5 missions)
--   Rang du soldat 32  = ((P + 6) mod 6) + 1
--   Unité du soldat 33 = ((U + 6) mod 6) + 1
--
--   Etudiant            P   U   M   rang_32   unite_33
--   202612707 (DAUGLA)  7   2   3   2         3
--   202512831 (ANAS)    1   2   2   2         3
--   202511479 (ATEM)    9   2   5   4         3
--
-- ER (à dessiner à la main) :
--   ranks(PK rank_id) 1 ---- N soldiers(PK soldier_id, FK rank_id, FK unit_id)
--   units(PK unit_id) 1 ---- N soldiers
--   soldiers N ---- N missions(PK mission_id), via soldier_missions
--       soldier_missions(PK composite soldier_id+mission_id, FK soldier_id, FK mission_id, mission_role)
--
-- NOTE : les « Rows returned » marqués <A_REMPLIR> dépendent de soldiers_seed.sql
--        (non fourni) : à relever après exécution.
-- ============================================================================

-- ############################################################################
-- ETUDIANT : DAUGLA DOURAH — 202612707   (P=7, U=2, M=3)
-- ############################################################################
DROP DATABASE IF EXISTS sms_202612707;
CREATE DATABASE sms_202612707 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sms_202612707;

-- Instruction obligatoire en première ligne du travail
SELECT DATABASE(), CURRENT_USER(), NOW();
-- Fait : affiche la base active, l'utilisateur et l'heure, pour prouver d'où vient le travail.
-- Lignes retournées : 1

-- ===================== PARTIE A : création des tables =======================

-- Fait : crée ranks ; nom obligatoire et unique, niveau limité de 1 à 6 par un CHECK.
CREATE TABLE ranks (
    rank_id    INT          NOT NULL,
    rank_name  VARCHAR(50)  NOT NULL,
    rank_level TINYINT      NOT NULL,
    PRIMARY KEY (rank_id),
    UNIQUE KEY uq_ranks_name (rank_name),
    CONSTRAINT ck_ranks_level CHECK (rank_level BETWEEN 1 AND 6)
) ENGINE=InnoDB;

-- Fait : crée units ; nom obligatoire et unique, lieu obligatoire.
CREATE TABLE units (
    unit_id       INT          NOT NULL,
    unit_name     VARCHAR(80)  NOT NULL,
    unit_location VARCHAR(80)  NOT NULL,
    PRIMARY KEY (unit_id),
    UNIQUE KEY uq_units_name (unit_name)
) ENGINE=InnoDB;

-- Fait : crée missions ; end_date NULL = mission en cours ; la fin ne peut pas précéder le début.
CREATE TABLE missions (
    mission_id   INT          NOT NULL,
    mission_name VARCHAR(80)  NOT NULL,
    start_date   DATE         NOT NULL,
    end_date     DATE         NULL,
    PRIMARY KEY (mission_id),
    UNIQUE KEY uq_missions_name (mission_name),
    CONSTRAINT ck_missions_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- Fait : crée soldiers ; numérotation automatique, matricule unique, statut limité par ENUM
--        (défaut Active), enlistement après naissance, rang et unité obligatoirement existants (FK).
CREATE TABLE soldiers (
    soldier_id      INT          NOT NULL AUTO_INCREMENT,
    service_number  VARCHAR(30)  NOT NULL,
    first_name      VARCHAR(60)  NOT NULL,
    last_name       VARCHAR(60)  NOT NULL,
    date_of_birth   DATE         NOT NULL,
    enlistment_date DATE         NOT NULL,
    status          ENUM('Active','On Leave','Retired') NOT NULL DEFAULT 'Active',
    rank_id         INT          NOT NULL,
    unit_id         INT          NOT NULL,
    PRIMARY KEY (soldier_id),
    UNIQUE KEY uq_soldiers_service_number (service_number),
    CONSTRAINT ck_soldiers_dates CHECK (enlistment_date > date_of_birth),
    CONSTRAINT fk_soldiers_rank FOREIGN KEY (rank_id) REFERENCES ranks (rank_id),
    CONSTRAINT fk_soldiers_unit FOREIGN KEY (unit_id) REFERENCES units (unit_id)
) ENGINE=InnoDB;

-- Fait : table d'association N-N ; la clé primaire composée interdit un soldat deux fois sur la
--        même mission ; les FK imposent que soldat et mission existent ; rôle obligatoire.
CREATE TABLE soldier_missions (
    soldier_id   INT         NOT NULL,
    mission_id   INT         NOT NULL,
    mission_role VARCHAR(60) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id),
    CONSTRAINT fk_sm_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers (soldier_id),
    CONSTRAINT fk_sm_mission FOREIGN KEY (mission_id) REFERENCES missions (mission_id)
) ENGINE=InnoDB;

-- ===================== PARTIE B : insertion des données =====================

-- B1 — Fait : insère les 6 grades (niveau = ordre hiérarchique).
INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
 (1,'Private',1),(2,'Corporal',2),(3,'Sergeant',3),
 (4,'Lieutenant',4),(5,'Captain',5),(6,'Major',6);

-- B1 — Fait : insère les 6 unités avec leur camp.
INSERT INTO units (unit_id, unit_name, unit_location) VALUES
 (1,'Alpha Company','North Camp'),(2,'Bravo Company','South Camp'),
 (3,'Charlie Company','East Camp'),(4,'Delta Company','West Camp'),
 (5,'Signals Unit','Central Camp'),(6,'Medical Unit','Central Camp');

-- B1 — Fait : insère les 5 missions ; « none » du sujet = NULL (mission en cours).
INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
 (1,'Exercise Falcon','2025-02-03','2025-02-28'),
 (2,'Flood Relief','2025-04-14','2025-05-30'),
 (3,'Border Patrol','2025-07-01',NULL),
 (4,'Peace Support','2025-09-15',NULL),
 (5,'Field Medical Camp','2026-01-12','2026-01-23');

-- B2 — Fait : exécute le script du professeur (30 soldats + leurs missions).
--      Commande du client mysql ; à lancer depuis le dossier contenant soldiers_seed.sql.
SOURCE soldiers_seed.sql;

-- B3 — Fait : ajoute 3 soldats (31 = moi, 32 et 33 fictifs) avec mon numéro dans le matricule.
--      Soldat 32 : rang 2 ; soldat 33 : rang 2, unité 3 ; tous Active. Dates inventées.
INSERT INTO soldiers
 (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id)
VALUES
 (31,'ST-202612707',  'DAUGLA','DOURAH','2000-05-14','2022-09-01','Active',1,2),
 (32,'ST-202612707-2','Moussa',  'Kabore', '1998-03-22','2018-06-10','Active',2,2),
 (33,'ST-202612707-3','Idriss',  'Mahamat', '1999-11-05','2019-01-15','Active',2,3);

-- B3 — Fait : affecte les soldats 31 et 32 à la mission M=3 ; le soldat 33 n'a aucune mission.
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
 (31,3,'Logistics Officer'),
 (32,3,'Squad Leader');

-- ===================== PARTIE C : requêtes ==================================

-- C1 — Fait : les 10 derniers soldats ajoutés, du plus récent au plus ancien (ID décroissant).
SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;
-- Lignes retournées : 10

-- C2 — Fait : ces mêmes 10 soldats, de l'ID le plus bas au plus haut (sous-requête puis tri croissant).
SELECT * FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS derniers
ORDER BY soldier_id ASC;
-- Lignes retournées : 10

-- C3 — Fait : les soldats dont l'ID est 10, 15 ou 20 (opérateur IN).
SELECT * FROM soldiers WHERE soldier_id IN (10, 15, 20);
-- Lignes retournées : 3

-- C4 — Fait : les soldats dont l'ID est 10+P, 15+P ou 20+P avec P=7 -> 17,22,27 (IN).
SELECT * FROM soldiers WHERE soldier_id IN (10 + 7, 15 + 7, 20 + 7);
-- Lignes retournées : 3

-- C5 — Fait : les soldats Active dont l'ID est entre 10 et 20 inclus (BETWEEN).
SELECT * FROM soldiers WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;
-- Lignes retournées : <A_REMPLIR>

-- C6 — Fait : ID et nom de chaque soldat avec son grade, grade le plus haut d'abord, puis nom.
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
ORDER BY r.rank_level DESC, s.last_name;
-- Lignes retournées : 33

-- C7 — Fait : soldats Active de l'unité U=2 avec grade, nom d'unité et lieu.
SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.unit_location
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
WHERE s.status = 'Active' AND s.unit_id = 2;
-- Lignes retournées : <A_REMPLIR>

-- C8 — Fait : tous les participants de la mission M=3 avec nom, rôle et unité.
SELECT m.mission_name, s.first_name, s.last_name, sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN missions m ON m.mission_id = sm.mission_id
JOIN soldiers s ON s.soldier_id = sm.soldier_id
JOIN units    u ON u.unit_id    = s.unit_id
WHERE sm.mission_id = 3;
-- Lignes retournées : <A_REMPLIR>

-- C9 — Fait : soldats jamais affectés à une mission (LEFT JOIN, ligne sans correspondance).
SELECT s.soldier_id, s.first_name, s.last_name
FROM soldiers s
LEFT JOIN soldier_missions sm ON sm.soldier_id = s.soldier_id
WHERE sm.soldier_id IS NULL;
-- Lignes retournées : <A_REMPLIR> (au moins 1 : le soldat 33)

-- C10 — Fait : nombre de soldats par unité, plus grande unité d'abord (LEFT JOIN garde les unités vides).
SELECT u.unit_name, COUNT(s.soldier_id) AS nb_soldiers
FROM units u
LEFT JOIN soldiers s ON s.unit_id = u.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY nb_soldiers DESC;
-- Lignes retournées : 6

-- ===================== PARTIE D : index et vue ==============================

-- D1 — Fait : plan d'exécution AVANT l'index (recherche par nom de famille).
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Lignes retournées : 1 (ligne d'EXPLAIN). Attendu : type = ALL, key = NULL (lecture de toute la table).

-- D1 — Fait : crée l'index sur last_name.
CREATE INDEX idx_soldiers_last_name ON soldiers (last_name);

-- D1 — Fait : même EXPLAIN APRES l'index.
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Lignes retournées : 1. Attendu : type passe de ALL à ref et key passe de NULL à
-- idx_soldiers_last_name : MySQL cherche via l'index au lieu de parcourir toutes les lignes.
-- (Sur une table de 33 lignes l'optimiseur peut garder ALL : recopier ce que vous voyez réellement.)

-- D2 — Fait : vue profil soldat (nom complet, grade, unité, lieu, statut).
CREATE VIEW v_soldier_profile AS
SELECT s.soldier_id,
       CONCAT(s.first_name, ' ', s.last_name) AS full_name,
       r.rank_name,
       u.unit_name,
       u.unit_location AS location,
       s.status
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id;

-- D3 — Fait : tous les soldats de l'unité U=2 via la vue, triés par nom complet.
SELECT * FROM v_soldier_profile
WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = 2)
ORDER BY full_name;
-- Lignes retournées : <A_REMPLIR>

-- ===================== CHANGE ORDER =========================================
-- A compléter pendant l'examen (tâche donnée par le professeur).
-- Fait : <expliquer>   Lignes retournées : <nombre>

-- ############################################################################
-- ETUDIANT : ANAS NOM_A_COMPLETER — 202512831   (P=1, U=2, M=2)
-- ############################################################################
DROP DATABASE IF EXISTS sms_202512831;
CREATE DATABASE sms_202512831 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sms_202512831;

-- Instruction obligatoire en première ligne du travail
SELECT DATABASE(), CURRENT_USER(), NOW();
-- Fait : affiche la base active, l'utilisateur et l'heure, pour prouver d'où vient le travail.
-- Lignes retournées : 1

-- ===================== PARTIE A : création des tables =======================

-- Fait : crée ranks ; nom obligatoire et unique, niveau limité de 1 à 6 par un CHECK.
CREATE TABLE ranks (
    rank_id    INT          NOT NULL,
    rank_name  VARCHAR(50)  NOT NULL,
    rank_level TINYINT      NOT NULL,
    PRIMARY KEY (rank_id),
    UNIQUE KEY uq_ranks_name (rank_name),
    CONSTRAINT ck_ranks_level CHECK (rank_level BETWEEN 1 AND 6)
) ENGINE=InnoDB;

-- Fait : crée units ; nom obligatoire et unique, lieu obligatoire.
CREATE TABLE units (
    unit_id       INT          NOT NULL,
    unit_name     VARCHAR(80)  NOT NULL,
    unit_location VARCHAR(80)  NOT NULL,
    PRIMARY KEY (unit_id),
    UNIQUE KEY uq_units_name (unit_name)
) ENGINE=InnoDB;

-- Fait : crée missions ; end_date NULL = mission en cours ; la fin ne peut pas précéder le début.
CREATE TABLE missions (
    mission_id   INT          NOT NULL,
    mission_name VARCHAR(80)  NOT NULL,
    start_date   DATE         NOT NULL,
    end_date     DATE         NULL,
    PRIMARY KEY (mission_id),
    UNIQUE KEY uq_missions_name (mission_name),
    CONSTRAINT ck_missions_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- Fait : crée soldiers ; numérotation automatique, matricule unique, statut limité par ENUM
--        (défaut Active), enlistement après naissance, rang et unité obligatoirement existants (FK).
CREATE TABLE soldiers (
    soldier_id      INT          NOT NULL AUTO_INCREMENT,
    service_number  VARCHAR(30)  NOT NULL,
    first_name      VARCHAR(60)  NOT NULL,
    last_name       VARCHAR(60)  NOT NULL,
    date_of_birth   DATE         NOT NULL,
    enlistment_date DATE         NOT NULL,
    status          ENUM('Active','On Leave','Retired') NOT NULL DEFAULT 'Active',
    rank_id         INT          NOT NULL,
    unit_id         INT          NOT NULL,
    PRIMARY KEY (soldier_id),
    UNIQUE KEY uq_soldiers_service_number (service_number),
    CONSTRAINT ck_soldiers_dates CHECK (enlistment_date > date_of_birth),
    CONSTRAINT fk_soldiers_rank FOREIGN KEY (rank_id) REFERENCES ranks (rank_id),
    CONSTRAINT fk_soldiers_unit FOREIGN KEY (unit_id) REFERENCES units (unit_id)
) ENGINE=InnoDB;

-- Fait : table d'association N-N ; la clé primaire composée interdit un soldat deux fois sur la
--        même mission ; les FK imposent que soldat et mission existent ; rôle obligatoire.
CREATE TABLE soldier_missions (
    soldier_id   INT         NOT NULL,
    mission_id   INT         NOT NULL,
    mission_role VARCHAR(60) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id),
    CONSTRAINT fk_sm_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers (soldier_id),
    CONSTRAINT fk_sm_mission FOREIGN KEY (mission_id) REFERENCES missions (mission_id)
) ENGINE=InnoDB;

-- ===================== PARTIE B : insertion des données =====================

-- B1 — Fait : insère les 6 grades (niveau = ordre hiérarchique).
INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
 (1,'Private',1),(2,'Corporal',2),(3,'Sergeant',3),
 (4,'Lieutenant',4),(5,'Captain',5),(6,'Major',6);

-- B1 — Fait : insère les 6 unités avec leur camp.
INSERT INTO units (unit_id, unit_name, unit_location) VALUES
 (1,'Alpha Company','North Camp'),(2,'Bravo Company','South Camp'),
 (3,'Charlie Company','East Camp'),(4,'Delta Company','West Camp'),
 (5,'Signals Unit','Central Camp'),(6,'Medical Unit','Central Camp');

-- B1 — Fait : insère les 5 missions ; « none » du sujet = NULL (mission en cours).
INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
 (1,'Exercise Falcon','2025-02-03','2025-02-28'),
 (2,'Flood Relief','2025-04-14','2025-05-30'),
 (3,'Border Patrol','2025-07-01',NULL),
 (4,'Peace Support','2025-09-15',NULL),
 (5,'Field Medical Camp','2026-01-12','2026-01-23');

-- B2 — Fait : exécute le script du professeur (30 soldats + leurs missions).
--      Commande du client mysql ; à lancer depuis le dossier contenant soldiers_seed.sql.
SOURCE soldiers_seed.sql;

-- B3 — Fait : ajoute 3 soldats (31 = moi, 32 et 33 fictifs) avec mon numéro dans le matricule.
--      Soldat 32 : rang 2 ; soldat 33 : rang 2, unité 3 ; tous Active. Dates inventées.
INSERT INTO soldiers
 (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id)
VALUES
 (31,'ST-202512831',  'ANAS','NOM_A_COMPLETER','2000-05-14','2022-09-01','Active',1,2),
 (32,'ST-202512831-2','Samuel',  'Ndayisaba', '1998-03-22','2018-06-10','Active',2,2),
 (33,'ST-202512831-3','Brahim',  'Oumar', '1999-11-05','2019-01-15','Active',2,3);

-- B3 — Fait : affecte les soldats 31 et 32 à la mission M=2 ; le soldat 33 n'a aucune mission.
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
 (31,2,'Logistics Officer'),
 (32,2,'Squad Leader');

-- ===================== PARTIE C : requêtes ==================================

-- C1 — Fait : les 10 derniers soldats ajoutés, du plus récent au plus ancien (ID décroissant).
SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;
-- Lignes retournées : 10

-- C2 — Fait : ces mêmes 10 soldats, de l'ID le plus bas au plus haut (sous-requête puis tri croissant).
SELECT * FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS derniers
ORDER BY soldier_id ASC;
-- Lignes retournées : 10

-- C3 — Fait : les soldats dont l'ID est 10, 15 ou 20 (opérateur IN).
SELECT * FROM soldiers WHERE soldier_id IN (10, 15, 20);
-- Lignes retournées : 3

-- C4 — Fait : les soldats dont l'ID est 10+P, 15+P ou 20+P avec P=1 -> 11,16,21 (IN).
SELECT * FROM soldiers WHERE soldier_id IN (10 + 1, 15 + 1, 20 + 1);
-- Lignes retournées : 3

-- C5 — Fait : les soldats Active dont l'ID est entre 10 et 20 inclus (BETWEEN).
SELECT * FROM soldiers WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;
-- Lignes retournées : <A_REMPLIR>

-- C6 — Fait : ID et nom de chaque soldat avec son grade, grade le plus haut d'abord, puis nom.
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
ORDER BY r.rank_level DESC, s.last_name;
-- Lignes retournées : 33

-- C7 — Fait : soldats Active de l'unité U=2 avec grade, nom d'unité et lieu.
SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.unit_location
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
WHERE s.status = 'Active' AND s.unit_id = 2;
-- Lignes retournées : <A_REMPLIR>

-- C8 — Fait : tous les participants de la mission M=2 avec nom, rôle et unité.
SELECT m.mission_name, s.first_name, s.last_name, sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN missions m ON m.mission_id = sm.mission_id
JOIN soldiers s ON s.soldier_id = sm.soldier_id
JOIN units    u ON u.unit_id    = s.unit_id
WHERE sm.mission_id = 2;
-- Lignes retournées : <A_REMPLIR>

-- C9 — Fait : soldats jamais affectés à une mission (LEFT JOIN, ligne sans correspondance).
SELECT s.soldier_id, s.first_name, s.last_name
FROM soldiers s
LEFT JOIN soldier_missions sm ON sm.soldier_id = s.soldier_id
WHERE sm.soldier_id IS NULL;
-- Lignes retournées : <A_REMPLIR> (au moins 1 : le soldat 33)

-- C10 — Fait : nombre de soldats par unité, plus grande unité d'abord (LEFT JOIN garde les unités vides).
SELECT u.unit_name, COUNT(s.soldier_id) AS nb_soldiers
FROM units u
LEFT JOIN soldiers s ON s.unit_id = u.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY nb_soldiers DESC;
-- Lignes retournées : 6

-- ===================== PARTIE D : index et vue ==============================

-- D1 — Fait : plan d'exécution AVANT l'index (recherche par nom de famille).
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Lignes retournées : 1 (ligne d'EXPLAIN). Attendu : type = ALL, key = NULL (lecture de toute la table).

-- D1 — Fait : crée l'index sur last_name.
CREATE INDEX idx_soldiers_last_name ON soldiers (last_name);

-- D1 — Fait : même EXPLAIN APRES l'index.
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Lignes retournées : 1. Attendu : type passe de ALL à ref et key passe de NULL à
-- idx_soldiers_last_name : MySQL cherche via l'index au lieu de parcourir toutes les lignes.
-- (Sur une table de 33 lignes l'optimiseur peut garder ALL : recopier ce que vous voyez réellement.)

-- D2 — Fait : vue profil soldat (nom complet, grade, unité, lieu, statut).
CREATE VIEW v_soldier_profile AS
SELECT s.soldier_id,
       CONCAT(s.first_name, ' ', s.last_name) AS full_name,
       r.rank_name,
       u.unit_name,
       u.unit_location AS location,
       s.status
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id;

-- D3 — Fait : tous les soldats de l'unité U=2 via la vue, triés par nom complet.
SELECT * FROM v_soldier_profile
WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = 2)
ORDER BY full_name;
-- Lignes retournées : <A_REMPLIR>

-- ===================== CHANGE ORDER =========================================
-- A compléter pendant l'examen (tâche donnée par le professeur).
-- Fait : <expliquer>   Lignes retournées : <nombre>

-- ############################################################################
-- ETUDIANT : ATEM GABRIEL BOL — 202511479   (P=9, U=2, M=5)
-- ############################################################################
DROP DATABASE IF EXISTS sms_202511479;
CREATE DATABASE sms_202511479 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sms_202511479;

-- Instruction obligatoire en première ligne du travail
SELECT DATABASE(), CURRENT_USER(), NOW();
-- Fait : affiche la base active, l'utilisateur et l'heure, pour prouver d'où vient le travail.
-- Lignes retournées : 1

-- ===================== PARTIE A : création des tables =======================

-- Fait : crée ranks ; nom obligatoire et unique, niveau limité de 1 à 6 par un CHECK.
CREATE TABLE ranks (
    rank_id    INT          NOT NULL,
    rank_name  VARCHAR(50)  NOT NULL,
    rank_level TINYINT      NOT NULL,
    PRIMARY KEY (rank_id),
    UNIQUE KEY uq_ranks_name (rank_name),
    CONSTRAINT ck_ranks_level CHECK (rank_level BETWEEN 1 AND 6)
) ENGINE=InnoDB;

-- Fait : crée units ; nom obligatoire et unique, lieu obligatoire.
CREATE TABLE units (
    unit_id       INT          NOT NULL,
    unit_name     VARCHAR(80)  NOT NULL,
    unit_location VARCHAR(80)  NOT NULL,
    PRIMARY KEY (unit_id),
    UNIQUE KEY uq_units_name (unit_name)
) ENGINE=InnoDB;

-- Fait : crée missions ; end_date NULL = mission en cours ; la fin ne peut pas précéder le début.
CREATE TABLE missions (
    mission_id   INT          NOT NULL,
    mission_name VARCHAR(80)  NOT NULL,
    start_date   DATE         NOT NULL,
    end_date     DATE         NULL,
    PRIMARY KEY (mission_id),
    UNIQUE KEY uq_missions_name (mission_name),
    CONSTRAINT ck_missions_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- Fait : crée soldiers ; numérotation automatique, matricule unique, statut limité par ENUM
--        (défaut Active), enlistement après naissance, rang et unité obligatoirement existants (FK).
CREATE TABLE soldiers (
    soldier_id      INT          NOT NULL AUTO_INCREMENT,
    service_number  VARCHAR(30)  NOT NULL,
    first_name      VARCHAR(60)  NOT NULL,
    last_name       VARCHAR(60)  NOT NULL,
    date_of_birth   DATE         NOT NULL,
    enlistment_date DATE         NOT NULL,
    status          ENUM('Active','On Leave','Retired') NOT NULL DEFAULT 'Active',
    rank_id         INT          NOT NULL,
    unit_id         INT          NOT NULL,
    PRIMARY KEY (soldier_id),
    UNIQUE KEY uq_soldiers_service_number (service_number),
    CONSTRAINT ck_soldiers_dates CHECK (enlistment_date > date_of_birth),
    CONSTRAINT fk_soldiers_rank FOREIGN KEY (rank_id) REFERENCES ranks (rank_id),
    CONSTRAINT fk_soldiers_unit FOREIGN KEY (unit_id) REFERENCES units (unit_id)
) ENGINE=InnoDB;

-- Fait : table d'association N-N ; la clé primaire composée interdit un soldat deux fois sur la
--        même mission ; les FK imposent que soldat et mission existent ; rôle obligatoire.
CREATE TABLE soldier_missions (
    soldier_id   INT         NOT NULL,
    mission_id   INT         NOT NULL,
    mission_role VARCHAR(60) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id),
    CONSTRAINT fk_sm_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers (soldier_id),
    CONSTRAINT fk_sm_mission FOREIGN KEY (mission_id) REFERENCES missions (mission_id)
) ENGINE=InnoDB;

-- ===================== PARTIE B : insertion des données =====================

-- B1 — Fait : insère les 6 grades (niveau = ordre hiérarchique).
INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
 (1,'Private',1),(2,'Corporal',2),(3,'Sergeant',3),
 (4,'Lieutenant',4),(5,'Captain',5),(6,'Major',6);

-- B1 — Fait : insère les 6 unités avec leur camp.
INSERT INTO units (unit_id, unit_name, unit_location) VALUES
 (1,'Alpha Company','North Camp'),(2,'Bravo Company','South Camp'),
 (3,'Charlie Company','East Camp'),(4,'Delta Company','West Camp'),
 (5,'Signals Unit','Central Camp'),(6,'Medical Unit','Central Camp');

-- B1 — Fait : insère les 5 missions ; « none » du sujet = NULL (mission en cours).
INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
 (1,'Exercise Falcon','2025-02-03','2025-02-28'),
 (2,'Flood Relief','2025-04-14','2025-05-30'),
 (3,'Border Patrol','2025-07-01',NULL),
 (4,'Peace Support','2025-09-15',NULL),
 (5,'Field Medical Camp','2026-01-12','2026-01-23');

-- B2 — Fait : exécute le script du professeur (30 soldats + leurs missions).
--      Commande du client mysql ; à lancer depuis le dossier contenant soldiers_seed.sql.
SOURCE soldiers_seed.sql;

-- B3 — Fait : ajoute 3 soldats (31 = moi, 32 et 33 fictifs) avec mon numéro dans le matricule.
--      Soldat 32 : rang 4 ; soldat 33 : rang 2, unité 3 ; tous Active. Dates inventées.
INSERT INTO soldiers
 (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id)
VALUES
 (31,'ST-202511479',  'ATEM GABRIEL','BOL','2000-05-14','2022-09-01','Active',1,2),
 (32,'ST-202511479-2','Peter',  'Deng', '1998-03-22','2018-06-10','Active',4,2),
 (33,'ST-202511479-3','Yves',  'Habimana', '1999-11-05','2019-01-15','Active',2,3);

-- B3 — Fait : affecte les soldats 31 et 32 à la mission M=5 ; le soldat 33 n'a aucune mission.
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
 (31,5,'Logistics Officer'),
 (32,5,'Squad Leader');

-- ===================== PARTIE C : requêtes ==================================

-- C1 — Fait : les 10 derniers soldats ajoutés, du plus récent au plus ancien (ID décroissant).
SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;
-- Lignes retournées : 10

-- C2 — Fait : ces mêmes 10 soldats, de l'ID le plus bas au plus haut (sous-requête puis tri croissant).
SELECT * FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS derniers
ORDER BY soldier_id ASC;
-- Lignes retournées : 10

-- C3 — Fait : les soldats dont l'ID est 10, 15 ou 20 (opérateur IN).
SELECT * FROM soldiers WHERE soldier_id IN (10, 15, 20);
-- Lignes retournées : 3

-- C4 — Fait : les soldats dont l'ID est 10+P, 15+P ou 20+P avec P=9 -> 19,24,29 (IN).
SELECT * FROM soldiers WHERE soldier_id IN (10 + 9, 15 + 9, 20 + 9);
-- Lignes retournées : 3

-- C5 — Fait : les soldats Active dont l'ID est entre 10 et 20 inclus (BETWEEN).
SELECT * FROM soldiers WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;
-- Lignes retournées : <A_REMPLIR>

-- C6 — Fait : ID et nom de chaque soldat avec son grade, grade le plus haut d'abord, puis nom.
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
ORDER BY r.rank_level DESC, s.last_name;
-- Lignes retournées : 33

-- C7 — Fait : soldats Active de l'unité U=2 avec grade, nom d'unité et lieu.
SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.unit_location
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
WHERE s.status = 'Active' AND s.unit_id = 2;
-- Lignes retournées : <A_REMPLIR>

-- C8 — Fait : tous les participants de la mission M=5 avec nom, rôle et unité.
SELECT m.mission_name, s.first_name, s.last_name, sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN missions m ON m.mission_id = sm.mission_id
JOIN soldiers s ON s.soldier_id = sm.soldier_id
JOIN units    u ON u.unit_id    = s.unit_id
WHERE sm.mission_id = 5;
-- Lignes retournées : <A_REMPLIR>

-- C9 — Fait : soldats jamais affectés à une mission (LEFT JOIN, ligne sans correspondance).
SELECT s.soldier_id, s.first_name, s.last_name
FROM soldiers s
LEFT JOIN soldier_missions sm ON sm.soldier_id = s.soldier_id
WHERE sm.soldier_id IS NULL;
-- Lignes retournées : <A_REMPLIR> (au moins 1 : le soldat 33)

-- C10 — Fait : nombre de soldats par unité, plus grande unité d'abord (LEFT JOIN garde les unités vides).
SELECT u.unit_name, COUNT(s.soldier_id) AS nb_soldiers
FROM units u
LEFT JOIN soldiers s ON s.unit_id = u.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY nb_soldiers DESC;
-- Lignes retournées : 6

-- ===================== PARTIE D : index et vue ==============================

-- D1 — Fait : plan d'exécution AVANT l'index (recherche par nom de famille).
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Lignes retournées : 1 (ligne d'EXPLAIN). Attendu : type = ALL, key = NULL (lecture de toute la table).

-- D1 — Fait : crée l'index sur last_name.
CREATE INDEX idx_soldiers_last_name ON soldiers (last_name);

-- D1 — Fait : même EXPLAIN APRES l'index.
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Lignes retournées : 1. Attendu : type passe de ALL à ref et key passe de NULL à
-- idx_soldiers_last_name : MySQL cherche via l'index au lieu de parcourir toutes les lignes.
-- (Sur une table de 33 lignes l'optimiseur peut garder ALL : recopier ce que vous voyez réellement.)

-- D2 — Fait : vue profil soldat (nom complet, grade, unité, lieu, statut).
CREATE VIEW v_soldier_profile AS
SELECT s.soldier_id,
       CONCAT(s.first_name, ' ', s.last_name) AS full_name,
       r.rank_name,
       u.unit_name,
       u.unit_location AS location,
       s.status
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id;

-- D3 — Fait : tous les soldats de l'unité U=2 via la vue, triés par nom complet.
SELECT * FROM v_soldier_profile
WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = 2)
ORDER BY full_name;
-- Lignes retournées : <A_REMPLIR>

-- ===================== CHANGE ORDER =========================================
-- A compléter pendant l'examen (tâche donnée par le professeur).
-- Fait : <expliquer>   Lignes retournées : <nombre>
