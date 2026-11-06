# Design notes

## Tables and rules enforced

| Table | Rule from the paper | How it is enforced |
|---|---|---|
| `ranks` | PK; name required and unique; level 1 to 6 | `PRIMARY KEY`, `NOT NULL` + `UNIQUE`, `CHECK (rank_level BETWEEN 1 AND 6)` |
| `units` | PK; name required and unique; location required | `PRIMARY KEY`, `NOT NULL` + `UNIQUE`, `NOT NULL` |
| `missions` | PK; name unique; ongoing = no end date; end not before start | `end_date` is `NULL` when ongoing; `CHECK (end_date IS NULL OR end_date >= start_date)` |
| `soldiers` | auto PK; unique service number; all required; status Active / On Leave / Retired, default Active; enlistment after birth; rank and unit must exist | `AUTO_INCREMENT`, `UNIQUE`, `NOT NULL`, `ENUM(...) DEFAULT 'Active'`, `CHECK (enlistment_date > date_of_birth)`, two `FOREIGN KEY` |
| `soldier_missions` | no duplicate soldier on a mission; both must exist; role required | composite `PRIMARY KEY (soldier_id, mission_id)`, two `FOREIGN KEY`, `NOT NULL` |

## Relationships

- `ranks` 1 — N `soldiers` (one rank can be held by many soldiers; each soldier has one rank).
- `units` 1 — N `soldiers` (one unit has many soldiers; each soldier belongs to one unit).
- `soldiers` N — N `missions`, resolved by `soldier_missions`, which also stores the role of the soldier on each mission.

## Queries (Part C) in short

| No. | Idea |
|---|---|
| C1 | `ORDER BY soldier_id DESC LIMIT 10` gives the newest 10 |
| C2 | wrap C1 in a subquery, then `ORDER BY soldier_id ASC` |
| C3, C4 | `IN (...)`; C4 uses `10 + P`, `15 + P`, `20 + P` |
| C5 | `status = 'Active' AND soldier_id BETWEEN 10 AND 20` |
| C6 | `JOIN ranks`, `ORDER BY rank_level DESC, last_name` |
| C7 | joins with `ranks` and `units`, filter on unit U and Active |
| C8 | joins `soldier_missions`, `missions`, `soldiers`, `units`, filter on mission M |
| C9 | `LEFT JOIN soldier_missions ... WHERE sm.soldier_id IS NULL` |
| C10 | `LEFT JOIN` + `GROUP BY` + `COUNT`, `ORDER BY` count descending |

## Index and view (Part D)

- `EXPLAIN` before the index is expected to show `type = ALL` and `key = NULL` (full table scan).
- After `CREATE INDEX idx_soldiers_last_name`, it is expected to show `type = ref` and `key = idx_soldiers_last_name`.
  On a very small table the optimizer may still choose `ALL`; the real output must be written in the comment.
- `v_soldier_profile` joins `soldiers`, `ranks` and `units` and builds `full_name` with `CONCAT(first_name, ' ', last_name)`.
