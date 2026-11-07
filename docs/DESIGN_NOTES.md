# Design notes — One shared Soldier Management database

## Architecture decision

All three students use one database: `soldier_management_db`. The schema and common reference data are created once. No student-specific database is created.

## Tables and rules

| Table | Purpose | Main constraints |
|---|---|---|
| `project_students` | Identifies DOURAH, ANAS and ATEM | PK `student_id`; unique `student_number` |
| `ranks` | Shared rank catalogue | PK; unique name; `rank_level` CHECK 1–6 |
| `units` | Shared unit catalogue | PK; unique name; required location |
| `missions` | Shared mission catalogue | PK; unique name; end date NULL for ongoing; date CHECK |
| `soldiers` | One global list of base and contributed soldiers | AUTO_INCREMENT PK; unique service number; rank/unit FKs; enlistment date CHECK; optional student ownership FK |
| `soldier_missions` | Soldier-to-mission many-to-many relation | Composite PK `(soldier_id, mission_id)`; both FKs; required role |

## How student ownership works

Two nullable columns are added to `soldiers` after the teacher's seed file has loaded:

- `added_by_student_id`: FK to `project_students.student_id`; NULL for the common instructor-provided base soldiers.
- `student_record_no`: preserves the original per-student record number 31, 32 or 33.

A unique key on `(added_by_student_id, student_record_no)` prevents one student from contributing the same local record number twice. The globally generated `soldier_id` is unique across the entire database, so the three former local IDs 31–33 no longer collide.

The six student-to-mission assignments from the original scripts are retained. For each student, local records 31 and 32 are assigned to their personalized mission M; local record 33 remains unassigned.

## Relationships

- `project_students` 1 — N `soldiers` (a contributor may add many soldier records; base seed records have no contributor).
- `ranks` 1 — N `soldiers`.
- `units` 1 — N `soldiers`.
- `soldiers` N — N `missions`, resolved by `soldier_missions`.

## Student parameters preserved

| Student | Student number | P | U | M | Rank of local soldier 32 | Unit of local soldier 33 |
|---|---:|---:|---:|---:|---:|---:|
| DOURAH | 202612707 | 7 | 2 | 3 | 2 | 3 |
| ANAS | 202512831 | 1 | 2 | 2 | 2 | 3 |
| ATEM | 202511479 | 9 | 2 | 5 | 4 | 3 |

## Execution workflow

1. Obtain the instructor's `soldiers_seed.sql` and put it in `sql/`.
2. Run `sql/Soldier_Management_Three_Students_MySQL8.sql` once. It creates the single database, shared tables/reference data, loads the teacher's common seed once, adds the nine contributed soldiers, creates the shared index and view, and performs verification queries.
3. Each student runs only their query workbook in `students/`. These workbooks use the same database and do not contain destructive DDL.

## Query notes

The C1/C2 newest-ten queries are team-wide because the database is shared. C3/C4/C5/C6/C7/C8/C9/C10 operate on the global shared dataset, with C4/C7/C8 using the student's preserved P/U/M parameters. A final ownership query in each workbook shows only that student's three contributed rows.

## Index and view

`idx_soldiers_last_name` and `v_soldier_profile` are created once by the central setup script. They are not recreated in each student's query workbook.

## External seed dependency

`soldiers_seed.sql` was referenced by the original scripts but was not included in the ZIP uploaded for this restructuring. The central setup retains this dependency rather than fabricating the instructor's 30 base soldier records. The expected total is 39 soldiers only if that seed imports exactly 30.
