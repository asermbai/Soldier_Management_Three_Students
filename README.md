# Soldier Management System

A MySQL 8.0 database project designed to manage soldier information and related military operations through a single centralized database shared by three students.

## Project Overview

The **Soldier Management System** is a relational database project developed to organize and manage information about soldiers, military ranks, units, missions, and soldier mission assignments.

The project uses **one centralized database** so that all three students work with the same database structure and common data. Individual student contributions can be identified through student-related records and attribution fields.

## Project Objectives

- Design a structured relational database for soldier management.
- Store and organize soldier information in one centralized database.
- Manage military ranks, units, and missions.
- Record assignments between soldiers and missions.
- Identify student contributions within the shared database.
- Apply relational database concepts, primary keys, foreign keys, and SQL queries.

## Team Members

This project is prepared collaboratively by:

- **DOURAH**
- **ANAS**
- **ATEM**

All three students use the same database rather than maintaining separate databases.

## Technologies Used

| Technology | Purpose |
|---|---|
| MySQL 8.0 | Relational database management system |
| SQL | Database creation, data manipulation, and queries |
| MySQL Workbench | Database administration and SQL execution |
| Git | Version control |
| GitHub | Project hosting and collaboration |
| Mermaid / Graphviz | Entity Relationship Diagram documentation |

## Database Architecture

**Database name:** `soldier_management_db`

The database is centralized and contains the main entities below:

| Table | Description |
|---|---|
| `project_students` | Identifies the students participating in the project |
| `ranks` | Stores military rank information |
| `units` | Stores military unit information |
| `missions` | Stores mission information |
| `soldiers` | Stores soldier records |
| `soldier_missions` | Associates soldiers with missions |

### Student Contribution Tracking

The shared database design supports identifying which student is associated with a record. Student attribution fields and student-specific record identifiers help distinguish contributions without creating separate databases.

### Entity Relationship Diagram

The database model is documented in the `er-diagram` directory:

- `er_diagram.png` — ER diagram image
- `er_diagram.svg` — scalable ER diagram
- `er_diagram.mmd` — Mermaid source
- `er_diagram.dot` — Graphviz source

## Repository Structure

```text
Soldier_Management_Three_Students/
│
├── README.md
│
├── docs/
│   └── DESIGN_NOTES.md
│
├── er-diagram/
│   ├── er_diagram.png
│   ├── er_diagram.svg
│   ├── er_diagram.mmd
│   └── er_diagram.dot
│
├── sql/
│   └── Soldier_Management_Three_Students_MySQL8.sql
│
└── students/
    ├── sms_202511479.sql
    ├── sms_202512831.sql
    └── sms_202612707.sql
```

## Installation and Setup

### Prerequisites

Before installing the database, make sure you have:

1. MySQL Server 8.0 installed and running.
2. MySQL Workbench installed, or another MySQL-compatible SQL client.
3. Access to the project files.

### Step 1 — Clone the repository

```bash
git clone https://github.com/asermbai/Soldier_Management_Three_Students.git
```

### Step 2 — Open the project

Open the downloaded `Soldier_Management_Three_Students` directory.

### Step 3 — Open the SQL script

Using MySQL Workbench:

1. Connect to your MySQL Server 8.0 instance.
2. Select **File → Open SQL Script**.
3. Open:

```text
sql/Soldier_Management_Three_Students_MySQL8.sql
```

### Step 4 — Execute the script

Execute the SQL script in MySQL Workbench.

The script is intended to create and configure the centralized project database. Review the script before execution, particularly if a database with the same name already exists, because setup scripts may recreate database objects.

### Step 5 — Verify the database

Run:

```sql
SHOW DATABASES;

USE soldier_management_db;

SHOW TABLES;
```

Confirm that the database and its expected tables have been created.

## Student SQL Work

The `students` directory contains individual SQL files for student-specific query work:

- `sms_202511479.sql`
- `sms_202512831.sql`
- `sms_202612707.sql`

These files are maintained separately to make individual SQL contributions easier to review while keeping the underlying database centralized.

## Documentation

Additional technical information is available in:

- `docs/DESIGN_NOTES.md` — database design notes and implementation decisions.
- `er-diagram/` — database entity relationship diagram and source files.
- `sql/` — database creation and setup script.
- `students/` — student-specific SQL work.

## Version Control and Collaboration

Git and GitHub are used to maintain the project history and share updates.

**GitHub repository:**  
https://github.com/asermbai/Soldier_Management_Three_Students

The `main` branch contains the consolidated project.

## Conclusion

The Soldier Management System provides a centralized relational database structure for organizing soldier-related information and military operations. By using a single database shared by DOURAH, ANAS, and ATEM, the project promotes consistency, reduces unnecessary duplication, and makes collaborative database development easier to manage.

---

**Project:** Soldier Management System  
**Database:** `soldier_management_db`  
**DBMS:** MySQL 8.0  
**Repository:** https://github.com/asermbai/Soldier_Management_Three_Students