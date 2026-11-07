-- ============================================================================
-- Soldier Management — shared-database query workbook
-- Student: DAUGLA DOURAH — 202612707
-- Database: soldier_management_db (created by the central setup script)
--
-- IMPORTANT: Run the central setup SQL once before running this file.
-- This file contains queries only. It does NOT create/drop databases or tables.
-- Run from the project root (or adjust the path to this file):
--   mysql -u <mysql_user> -p soldier_management_db < students/sms_202612707.sql
-- ============================================================================

USE soldier_management_db;

-- Resolve this student's shared-database identity and assignment parameters.
SET @student_id := 1;
SET @P := 7;
SET @U := 2;
SET @M := 3;

SELECT student_id, student_number, display_name
FROM project_students
WHERE student_id = @student_id;

-- C1 — Last 10 soldiers added to the shared database, newest first.
-- This is a team-wide query: all students see the same shared records.
SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;

-- C2 — The same latest 10 records, displayed from lowest ID to highest.
SELECT *
FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS latest_soldiers
ORDER BY soldier_id ASC;

-- C3 — Soldiers whose global ID is 10, 15 or 20.
SELECT * FROM soldiers WHERE soldier_id IN (10, 15, 20);

-- C4 — Personalized P formula: IDs 10+P, 15+P and 20+P.
SELECT * FROM soldiers
WHERE soldier_id IN (10 + @P, 15 + @P, 20 + @P);

-- C5 — Active soldiers whose global ID is between 10 and 20 inclusive.
SELECT * FROM soldiers
WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;

-- C6 — All soldiers with their rank, highest rank first.
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
ORDER BY r.rank_level DESC, s.last_name;

-- C7 — Active soldiers in this student's U unit, with rank and unit details.
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name,
       u.unit_name, u.unit_location
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
WHERE s.status = 'Active' AND s.unit_id = @U;

-- C8 — Everyone assigned to this student's personalized M mission.
SELECT m.mission_name, s.first_name, s.last_name,
       sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN missions m ON m.mission_id = sm.mission_id
JOIN soldiers s ON s.soldier_id = sm.soldier_id
JOIN units u ON u.unit_id = s.unit_id
WHERE sm.mission_id = @M;

-- C9 — Soldiers who have never been assigned to any mission.
SELECT s.soldier_id, s.first_name, s.last_name,
       ps.display_name AS added_by_student
FROM soldiers s
LEFT JOIN soldier_missions sm ON sm.soldier_id = s.soldier_id
LEFT JOIN project_students ps ON ps.student_id = s.added_by_student_id
WHERE sm.soldier_id IS NULL;

-- C10 — Number of soldiers per unit across the shared database.
SELECT u.unit_name, COUNT(s.soldier_id) AS nb_soldiers
FROM units u
LEFT JOIN soldiers s ON s.unit_id = u.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY nb_soldiers DESC;

-- D3 — Soldier profiles in this student's U unit using the shared view.
SELECT * FROM v_soldier_profile
WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = @U)
ORDER BY full_name;

-- Student-specific records (use this to see only the three records contributed
-- by this student; student_record_no preserves the old local IDs 31, 32 and 33).
SELECT soldier_id, student_record_no, service_number, first_name, last_name,
       rank_id, unit_id, status
FROM soldiers
WHERE added_by_student_id = @student_id
ORDER BY student_record_no;

-- End of query workbook. Shared schema/index/view are maintained centrally.
