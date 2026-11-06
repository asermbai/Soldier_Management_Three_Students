-- ============================================================================
-- Soldier Management SQL Quiz — MySQL 8 — file sms_202512831.sql
-- Run from the folder that contains soldiers_seed.sql:
--   mysql -u <exam_account> -p < sms_202512831.sql
-- Rows marked <TO_FILL> depend on soldiers_seed.sql: write the real number after running.
-- ============================================================================

-- ############################################################################
-- STUDENT: ANAS NOM_A_COMPLETER — 202512831   (P=1, U=2, M=2)
-- ############################################################################
DROP DATABASE IF EXISTS sms_202512831;
CREATE DATABASE sms_202512831 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sms_202512831;

-- Mandatory first statement of the work
SELECT DATABASE(), CURRENT_USER(), NOW();
-- Does: shows the active database, the user and the time, to prove where the work comes from.
-- Rows returned: 1

-- ===================== PART A: create the tables =======================

-- Does: creates ranks; name is required and unique; level is limited to 1-6 by a CHECK.
CREATE TABLE ranks (
    rank_id    INT          NOT NULL,
    rank_name  VARCHAR(50)  NOT NULL,
    rank_level TINYINT      NOT NULL,
    PRIMARY KEY (rank_id),
    UNIQUE KEY uq_ranks_name (rank_name),
    CONSTRAINT ck_ranks_level CHECK (rank_level BETWEEN 1 AND 6)
) ENGINE=InnoDB;

-- Does: creates units; name is required and unique; location is required.
CREATE TABLE units (
    unit_id       INT          NOT NULL,
    unit_name     VARCHAR(80)  NOT NULL,
    unit_location VARCHAR(80)  NOT NULL,
    PRIMARY KEY (unit_id),
    UNIQUE KEY uq_units_name (unit_name)
) ENGINE=InnoDB;

-- Does: creates missions; NULL end_date = ongoing mission; the end cannot be before the start.
CREATE TABLE missions (
    mission_id   INT          NOT NULL,
    mission_name VARCHAR(80)  NOT NULL,
    start_date   DATE         NOT NULL,
    end_date     DATE         NULL,
    PRIMARY KEY (mission_id),
    UNIQUE KEY uq_missions_name (mission_name),
    CONSTRAINT ck_missions_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- Does: creates soldiers; automatic numbering, unique service number, status limited by ENUM
--       (default Active), enlistment after birth, rank and unit must already exist (FK).
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

-- Does: many-to-many link table; the composite primary key stops a soldier being listed twice on
--       the same mission; the FKs force soldier and mission to exist; role is required.
CREATE TABLE soldier_missions (
    soldier_id   INT         NOT NULL,
    mission_id   INT         NOT NULL,
    mission_role VARCHAR(60) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id),
    CONSTRAINT fk_sm_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers (soldier_id),
    CONSTRAINT fk_sm_mission FOREIGN KEY (mission_id) REFERENCES missions (mission_id)
) ENGINE=InnoDB;

-- ===================== PART B: insert the data =====================

-- B1 — Does: inserts the 6 ranks (level = order in the hierarchy).
INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
 (1,'Private',1),(2,'Corporal',2),(3,'Sergeant',3),
 (4,'Lieutenant',4),(5,'Captain',5),(6,'Major',6);

-- B1 — Does: inserts the 6 units with their camp.
INSERT INTO units (unit_id, unit_name, unit_location) VALUES
 (1,'Alpha Company','North Camp'),(2,'Bravo Company','South Camp'),
 (3,'Charlie Company','East Camp'),(4,'Delta Company','West Camp'),
 (5,'Signals Unit','Central Camp'),(6,'Medical Unit','Central Camp');

-- B1 — Does: inserts the 5 missions; 'none' in the paper = NULL (ongoing mission).
INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
 (1,'Exercise Falcon','2025-02-03','2025-02-28'),
 (2,'Flood Relief','2025-04-14','2025-05-30'),
 (3,'Border Patrol','2025-07-01',NULL),
 (4,'Peace Support','2025-09-15',NULL),
 (5,'Field Medical Camp','2026-01-12','2026-01-23');

-- B2 — Does: runs the teacher's script (30 soldiers + their mission assignments).
--       mysql client command; run it from the folder containing soldiers_seed.sql.
SOURCE soldiers_seed.sql;

-- B3 — Does: adds 3 soldiers (31 = me, 32 and 33 fictional) with my student number in the service number.
--       Soldier 32: rank 2; soldier 33: rank 2, unit 3; all Active. Dates are invented.
INSERT INTO soldiers
 (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id)
VALUES
 (31,'ST-202512831',  'ANAS','NOM_A_COMPLETER','2000-05-14','2022-09-01','Active',1,2),
 (32,'ST-202512831-2','Samuel',  'Ndayisaba', '1998-03-22','2018-06-10','Active',2,2),
 (33,'ST-202512831-3','Brahim',  'Oumar', '1999-11-05','2019-01-15','Active',2,3);

-- B3 — Does: assigns soldiers 31 and 32 to mission M=2; soldier 33 has no mission.
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
 (31,2,'Logistics Officer'),
 (32,2,'Squad Leader');

-- ===================== PART C: queries ==================================

-- C1 — Does: the last 10 soldiers added, newest first (ID descending).
SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;
-- Rows returned: 10

-- C2 — Does: the same 10 soldiers, lowest ID to highest (subquery, then ascending sort).
SELECT * FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS derniers
ORDER BY soldier_id ASC;
-- Rows returned: 10

-- C3 — Does: soldiers whose ID is 10, 15 or 20 (IN operator).
SELECT * FROM soldiers WHERE soldier_id IN (10, 15, 20);
-- Rows returned: 3

-- C4 — Does: soldiers whose ID is 10+P, 15+P or 20+P with P=1 -> 11,16,21 (IN).
SELECT * FROM soldiers WHERE soldier_id IN (10 + 1, 15 + 1, 20 + 1);
-- Rows returned: 3

-- C5 — Does: Active soldiers with an ID from 10 to 20 inclusive (BETWEEN).
SELECT * FROM soldiers WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;
-- Rows returned: <TO_FILL>

-- C6 — Does: each soldier's ID and name with rank name, highest rank level first, then last name.
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
ORDER BY r.rank_level DESC, s.last_name;
-- Rows returned: 33

-- C7 — Does: Active soldiers in unit U=2 with rank, unit name and location.
SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.unit_location
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
WHERE s.status = 'Active' AND s.unit_id = 2;
-- Rows returned: <TO_FILL>

-- C8 — Does: everyone on mission M=2 with soldier name, role and unit name.
SELECT m.mission_name, s.first_name, s.last_name, sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN missions m ON m.mission_id = sm.mission_id
JOIN soldiers s ON s.soldier_id = sm.soldier_id
JOIN units    u ON u.unit_id    = s.unit_id
WHERE sm.mission_id = 2;
-- Rows returned: <TO_FILL>

-- C9 — Does: soldiers never assigned to a mission (LEFT JOIN, rows with no match).
SELECT s.soldier_id, s.first_name, s.last_name
FROM soldiers s
LEFT JOIN soldier_missions sm ON sm.soldier_id = s.soldier_id
WHERE sm.soldier_id IS NULL;
-- Rows returned: <TO_FILL> (at least 1: soldier 33)

-- C10 — Does: number of soldiers per unit, largest unit first (LEFT JOIN keeps empty units).
SELECT u.unit_name, COUNT(s.soldier_id) AS nb_soldiers
FROM units u
LEFT JOIN soldiers s ON s.unit_id = u.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY nb_soldiers DESC;
-- Rows returned: 6

-- ===================== PART D: index and view ==============================

-- D1 — Does: execution plan BEFORE the index (search by last name).
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Rows returned: 1 (EXPLAIN row). Expected: type = ALL, key = NULL (full table scan).

-- D1 — Does: creates the index on last_name.
CREATE INDEX idx_soldiers_last_name ON soldiers (last_name);

-- D1 — Does: the same EXPLAIN AFTER the index.
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
-- Rows returned: 1. Expected: type changes from ALL to ref and key changes from NULL to
-- idx_soldiers_last_name: MySQL now looks up the index instead of scanning every row.
-- (On a 33-row table the optimizer may keep ALL: write what you really see.)

-- D2 — Does: soldier profile view (full name, rank, unit, location, status).
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

-- D3 — Does: every soldier in unit U=2 through the view, ordered by full name.
SELECT * FROM v_soldier_profile
WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = 2)
ORDER BY full_name;
-- Rows returned: <TO_FILL>

-- ===================== CHANGE ORDER =========================================
-- To complete during the exam (task given by the teacher).
-- Does: <explain>   Rows returned: <number>
