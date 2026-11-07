-- ============================================================================
-- SOLDIER MANAGEMENT — ONE SHARED DATABASE (MySQL 8)
-- Database: soldier_management_db
-- Students: DOURAH, ANAS, ATEM
--
-- IMPORTANT:
--   1. This is the ONLY setup/schema/data-import script for the project.
--   2. Run it ONCE, from this sql folder, using the MySQL command-line client.
--   3. It DROPS and recreates soldier_management_db. Back up any existing data first.
--   4. The teacher-provided soldiers_seed.sql must be in this same folder. It should
--      insert the common 30 base soldiers and their mission assignments into the
--      soldiers and soldier_missions tables. That seed file was not included in
--      the ZIP supplied for this restructuring.
--   5. After setup, each student runs only their own query file in ../students/.
--      Those query files do not create, drop, or alter databases/tables.
--
-- Run from this folder:
--   mysql -u <mysql_user> -p < Soldier_Management_Three_Students_MySQL8.sql
-- ============================================================================

DROP DATABASE IF EXISTS soldier_management_db;
CREATE DATABASE soldier_management_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE soldier_management_db;

-- Confirm the single active database.
SELECT DATABASE() AS active_database, CURRENT_USER() AS mysql_user, NOW() AS executed_at;

-- ---------------------------------------------------------------------------
-- PART A — Shared reference data and schema (created exactly once)
-- ---------------------------------------------------------------------------

CREATE TABLE project_students (
    student_id     TINYINT UNSIGNED NOT NULL,
    student_number VARCHAR(20) NOT NULL,
    display_name   VARCHAR(100) NOT NULL,
    PRIMARY KEY (student_id),
    UNIQUE KEY uq_project_students_number (student_number)
) ENGINE=InnoDB;

INSERT INTO project_students (student_id, student_number, display_name) VALUES
 (1, '202612707', 'DAUGLA DOURAH'),
 (2, '202512831', 'ANAS NOM_A_COMPLETER'),
 (3, '202511479', 'ATEM GABRIEL BOL');

CREATE TABLE ranks (
    rank_id    INT NOT NULL,
    rank_name  VARCHAR(50) NOT NULL,
    rank_level TINYINT NOT NULL,
    PRIMARY KEY (rank_id),
    UNIQUE KEY uq_ranks_name (rank_name),
    CONSTRAINT ck_ranks_level CHECK (rank_level BETWEEN 1 AND 6)
) ENGINE=InnoDB;

CREATE TABLE units (
    unit_id       INT NOT NULL,
    unit_name     VARCHAR(80) NOT NULL,
    unit_location VARCHAR(80) NOT NULL,
    PRIMARY KEY (unit_id),
    UNIQUE KEY uq_units_name (unit_name)
) ENGINE=InnoDB;

CREATE TABLE missions (
    mission_id   INT NOT NULL,
    mission_name VARCHAR(80) NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE NULL,
    PRIMARY KEY (mission_id),
    UNIQUE KEY uq_missions_name (mission_name),
    CONSTRAINT ck_missions_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

CREATE TABLE soldiers (
    soldier_id      INT NOT NULL AUTO_INCREMENT,
    service_number  VARCHAR(30) NOT NULL,
    first_name      VARCHAR(60) NOT NULL,
    last_name       VARCHAR(60) NOT NULL,
    date_of_birth   DATE NOT NULL,
    enlistment_date DATE NOT NULL,
    status          ENUM('Active','On Leave','Retired') NOT NULL DEFAULT 'Active',
    rank_id         INT NOT NULL,
    unit_id         INT NOT NULL,
    PRIMARY KEY (soldier_id),
    UNIQUE KEY uq_soldiers_service_number (service_number),
    CONSTRAINT ck_soldiers_dates CHECK (enlistment_date > date_of_birth),
    CONSTRAINT fk_soldiers_rank FOREIGN KEY (rank_id) REFERENCES ranks (rank_id),
    CONSTRAINT fk_soldiers_unit FOREIGN KEY (unit_id) REFERENCES units (unit_id)
) ENGINE=InnoDB;

CREATE TABLE soldier_missions (
    soldier_id   INT NOT NULL,
    mission_id   INT NOT NULL,
    mission_role VARCHAR(60) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id),
    CONSTRAINT fk_sm_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers (soldier_id),
    CONSTRAINT fk_sm_mission FOREIGN KEY (mission_id) REFERENCES missions (mission_id)
) ENGINE=InnoDB;

-- Shared ranks: inserted once for the entire team.
INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
 (1,'Private',1),(2,'Corporal',2),(3,'Sergeant',3),
 (4,'Lieutenant',4),(5,'Captain',5),(6,'Major',6);

-- Shared units: inserted once for the entire team.
INSERT INTO units (unit_id, unit_name, unit_location) VALUES
 (1,'Alpha Company','North Camp'),(2,'Bravo Company','South Camp'),
 (3,'Charlie Company','East Camp'),(4,'Delta Company','West Camp'),
 (5,'Signals Unit','Central Camp'),(6,'Medical Unit','Central Camp');

-- Shared missions: inserted once for the entire team.
INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
 (1,'Exercise Falcon','2025-02-03','2025-02-28'),
 (2,'Flood Relief','2025-04-14','2025-05-30'),
 (3,'Border Patrol','2025-07-01',NULL),
 (4,'Peace Support','2025-09-15',NULL),
 (5,'Field Medical Camp','2026-01-12','2026-01-23');

-- ---------------------------------------------------------------------------
-- PART B — Load the teacher's common base dataset exactly once
-- ---------------------------------------------------------------------------
-- The seed file is external because it was not present in the supplied ZIP.
-- Run this setup from the sql folder so this relative SOURCE path resolves.
SOURCE soldiers_seed.sql;

-- Add ownership metadata AFTER the teacher seed is loaded. Doing this after
-- SOURCE preserves compatibility with the teacher's original soldiers INSERTs.
-- Base soldiers from the teacher seed retain NULL ownership metadata.
ALTER TABLE soldiers
    ADD COLUMN added_by_student_id TINYINT UNSIGNED NULL,
    ADD COLUMN student_record_no SMALLINT UNSIGNED NULL,
    ADD KEY idx_soldiers_added_by_student (added_by_student_id),
    ADD UNIQUE KEY uq_student_local_soldier (added_by_student_id, student_record_no),
    ADD CONSTRAINT fk_soldiers_added_by_student
        FOREIGN KEY (added_by_student_id) REFERENCES project_students (student_id),
    ADD CONSTRAINT ck_soldier_student_record
        CHECK (
            (added_by_student_id IS NULL AND student_record_no IS NULL)
            OR
            (added_by_student_id IS NOT NULL AND student_record_no BETWEEN 31 AND 33)
        );

-- ---------------------------------------------------------------------------
-- PART C — Add the three students' nine records to the SAME soldiers table
-- ---------------------------------------------------------------------------
-- student_record_no preserves the original local record number (31, 32, 33).
-- soldier_id is generated globally by AUTO_INCREMENT, so no PK collisions occur.
-- Student-specific P/U/M values from the original assignment are preserved.

-- DOURAH — 202612707 (P=7, U=2, M=3)
INSERT INTO soldiers
 (service_number, first_name, last_name, date_of_birth, enlistment_date,
  status, rank_id, unit_id, added_by_student_id, student_record_no)
VALUES
 ('ST-202612707',   'DAUGLA','DOURAH','2000-05-14','2022-09-01','Active',1,2,1,31),
 ('ST-202612707-2', 'Moussa','Kabore','1998-03-22','2018-06-10','Active',2,2,1,32),
 ('ST-202612707-3', 'Idriss','Mahamat','1999-11-05','2019-01-15','Active',2,3,1,33);

-- ANAS — 202512831 (P=1, U=2, M=2)
INSERT INTO soldiers
 (service_number, first_name, last_name, date_of_birth, enlistment_date,
  status, rank_id, unit_id, added_by_student_id, student_record_no)
VALUES
 ('ST-202512831',   'ANAS','NOM_A_COMPLETER','2000-05-14','2022-09-01','Active',1,2,2,31),
 ('ST-202512831-2', 'Samuel','Ndayisaba','1998-03-22','2018-06-10','Active',2,2,2,32),
 ('ST-202512831-3', 'Brahim','Oumar','1999-11-05','2019-01-15','Active',2,3,2,33);

-- ATEM — 202511479 (P=9, U=2, M=5)
INSERT INTO soldiers
 (service_number, first_name, last_name, date_of_birth, enlistment_date,
  status, rank_id, unit_id, added_by_student_id, student_record_no)
VALUES
 ('ST-202511479',   'ATEM GABRIEL','BOL','2000-05-14','2022-09-01','Active',1,2,3,31),
 ('ST-202511479-2', 'Peter','Deng','1998-03-22','2018-06-10','Active',4,2,3,32),
 ('ST-202511479-3', 'Yves','Habimana','1999-11-05','2019-01-15','Active',2,3,3,33);

-- Assign each student's first two contributed soldiers to their personalized
-- mission. The third contributed soldier intentionally has no mission.
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role)
SELECT soldier_id, 3, 'Logistics Officer'
FROM soldiers WHERE added_by_student_id = 1 AND student_record_no = 31;
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role)
SELECT soldier_id, 3, 'Squad Leader'
FROM soldiers WHERE added_by_student_id = 1 AND student_record_no = 32;

INSERT INTO soldier_missions (soldier_id, mission_id, mission_role)
SELECT soldier_id, 2, 'Logistics Officer'
FROM soldiers WHERE added_by_student_id = 2 AND student_record_no = 31;
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role)
SELECT soldier_id, 2, 'Squad Leader'
FROM soldiers WHERE added_by_student_id = 2 AND student_record_no = 32;

INSERT INTO soldier_missions (soldier_id, mission_id, mission_role)
SELECT soldier_id, 5, 'Logistics Officer'
FROM soldiers WHERE added_by_student_id = 3 AND student_record_no = 31;
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role)
SELECT soldier_id, 5, 'Squad Leader'
FROM soldiers WHERE added_by_student_id = 3 AND student_record_no = 32;

-- ---------------------------------------------------------------------------
-- PART D — Verify shared data, then create the shared index and view once
-- ---------------------------------------------------------------------------
SELECT student_id, student_number, display_name FROM project_students ORDER BY student_id;
SELECT added_by_student_id, COUNT(*) AS contributed_soldiers
FROM soldiers
WHERE added_by_student_id IS NOT NULL
GROUP BY added_by_student_id
ORDER BY added_by_student_id;
SELECT COUNT(*) AS total_soldiers FROM soldiers;

-- D1: execution plan before the index.
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';
CREATE INDEX idx_soldiers_last_name ON soldiers (last_name);
-- D1: execution plan after the index. The optimizer may still choose a table scan
-- for a small table; report the actual EXPLAIN output rather than assuming ref.
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

-- D2: one shared profile view for every student.
CREATE VIEW v_soldier_profile AS
SELECT s.soldier_id,
       CONCAT(s.first_name, ' ', s.last_name) AS full_name,
       r.rank_name,
       u.unit_name,
       u.unit_location AS location,
       s.status,
       ps.student_number AS added_by_student_number,
       ps.display_name AS added_by_student_name,
       s.student_record_no
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
LEFT JOIN project_students ps ON ps.student_id = s.added_by_student_id;

-- Final verification: one database, one set of tables, all nine contributed rows.
SHOW TABLES;
SELECT soldier_id, service_number, first_name, last_name,
       added_by_student_id, student_record_no
FROM soldiers
WHERE added_by_student_id IS NOT NULL
ORDER BY added_by_student_id, student_record_no;

-- Setup complete. Do not run student query files until this script finishes.
