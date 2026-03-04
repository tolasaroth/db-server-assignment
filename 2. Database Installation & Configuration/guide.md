# Employee Management Database — `employee_db`

A PostgreSQL database for managing employee records, departments, job positions, salary history, and payroll. Designed with role-based access control (RBAC) to ensure each user only accesses data relevant to their responsibilities.

---

## Table of Contents

- [Database Setup](#database-setup)
- [Schema Overview](#schema-overview)
- [Tables](#tables)
- [Roles & Permissions](#roles--permissions)
- [Users](#users)
- [Testing Permissions](#testing-permissions)

---

## Database Setup

```sql
CREATE DATABASE employee_db
    WITH OWNER = slsusr
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
```

| Setting | Value | Description |
|---|---|---|
| Owner | `slsusr` | The PostgreSQL user who owns this database |
| Encoding | `UTF8` | Supports all languages and characters |
| LC_COLLATE | `en_US.utf8` | Controls text sorting order |
| LC_CTYPE | `en_US.utf8` | Controls character classification |
| Connection Limit | `-1` | Unlimited simultaneous connections |

> Make sure the user `slsusr` exists before running this command.

---


## Tables

### 1. `departments`

| Column | Type | Description |
|---|---|---|
| `department_id` | SERIAL PK | Auto-generated ID |
| `department_name` | VARCHAR(100) | Name of the department |
| `location` | VARCHAR(100) | Physical location |
| `created_at` | TIMESTAMP | Record creation time |

### 2. `positions`

| Column | Type | Description |
|---|---|---|
| `position_id` | SERIAL PK | Auto-generated ID |
| `title` | VARCHAR(100) | Job title |
| `min_salary` | NUMERIC(10,2) | Minimum salary for the role |
| `max_salary` | NUMERIC(10,2) | Maximum salary for the role |
| `department_id` | INT FK | References `departments` |

### 3. `employees`

| Column | Type | Description |
|---|---|---|
| `employee_id` | SERIAL PK | Auto-generated ID |
| `first_name` | VARCHAR(50) | Employee first name |
| `last_name` | VARCHAR(50) | Employee last name |
| `email` | VARCHAR(100) UNIQUE | Work email address |
| `phone` | VARCHAR(20) | Contact number |
| `hire_date` | DATE | Date of hiring |
| `birth_date` | DATE | Date of birth |
| `gender` | CHAR(1) | M, F, or O |
| `address` | TEXT | Home address |
| `status` | VARCHAR(20) | active, inactive, or terminated |
| `department_id` | INT FK | References `departments` |
| `position_id` | INT FK | References `positions` |
| `manager_id` | INT FK | Self-reference to `employees` |
| `created_at` | TIMESTAMP | Record creation time |

### 4. `salary_history`

| Column | Type | Description |
|---|---|---|
| `salary_id` | SERIAL PK | Auto-generated ID |
| `employee_id` | INT FK | References `employees` |
| `old_salary` | NUMERIC(10,2) | Previous salary |
| `new_salary` | NUMERIC(10,2) | Updated salary |
| `change_date` | DATE | Date the change was made |
| `reason` | TEXT | Reason for salary change |

### 5. `payroll`

| Column | Type | Description |
|---|---|---|
| `payroll_id` | SERIAL PK | Auto-generated ID |
| `employee_id` | INT FK | References `employees` |
| `pay_period_start` | DATE | Start of pay period |
| `pay_period_end` | DATE | End of pay period |
| `basic_salary` | NUMERIC(10,2) | Base salary |
| `bonuses` | NUMERIC(10,2) | Bonus amount (default 0) |
| `deductions` | NUMERIC(10,2) | Deductions (default 0) |
| `net_pay` | NUMERIC(10,2) | Final pay after bonuses/deductions |
| `paid_at` | TIMESTAMP | When payment was processed |

---

### 6. `attendance`


| Column          | Type          | Description                        |
|-----------------|---------------|------------------------------------|
| `attendance_id` | SERIAL PK     | Auto-generated ID                  |
| `employee_id`   | INT FK        | References `employees`             |
| `work_date`     | DATE          | data work                          |
| `check_in`      | time          | chech in time                      |
| `check_out`     | time          | Check out time                     |
| `status `       | VARCHAR(20)    | Status of attendance               |



### 7. `leave_types`

| Column          | Type          | Description       |
|-----------------|---------------|-------------------|
| `leave_type_id` | SERIAL PK     | Auto-generated ID |
| `type_name`     | INT FK        | Name of leave     |
| `max_days`      | DATE          | Maximum days      |


# 7. leave_requests
| Column | Type | Description |
|--------|------|-------------|
| `leave_id` | SERIAL PK | Auto-generated unique leave request ID |
| `employee_id` | INT FK | References the employee submitting the request |
| `leave_type_id` | INT FK | References the type of leave being requested |
| `start_date` | DATE | Start date of the leave |
| `end_date` | DATE | End date of the leave |
| `reason` | TEXT | Reason provided by the employee |
| `status` | VARCHAR(20) | Current status of the request (default: `'pending'`) |
| `approved_by` | INT FK | References the approver (manager/admin) |

---


## Roles & Permissions

| Role | departments | positions | employees | salary_history | payroll |
|---|---|---|---|---|---|
| `hr_manager` | ALL | ALL | ALL | ALL | ALL |
| `hr_staff` | SELECT/INSERT/UPDATE | SELECT/INSERT/UPDATE | SELECT/INSERT/UPDATE | No Access | No Access |
| `payroll_officer` | No Access | No Access | SELECT only | SELECT/INSERT/UPDATE | SELECT/INSERT/UPDATE |
| `readonly_viewer` | SELECT only | SELECT only | SELECT only | SELECT only | SELECT only |

```sql
-- Create roles
CREATE ROLE hr_manager;
CREATE ROLE hr_staff;
CREATE ROLE payroll_officer;
CREATE ROLE readonly_viewer;

-- HR Manager
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hr_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hr_manager;

-- HR Staff
GRANT SELECT, INSERT, UPDATE ON TABLE departments, positions, employees TO hr_staff;
REVOKE ALL ON TABLE salary_history, payroll FROM hr_staff;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hr_staff;

-- Payroll Officer
GRANT SELECT, INSERT, UPDATE ON TABLE salary_history, payroll TO payroll_officer;
GRANT SELECT ON TABLE employees TO payroll_officer;
REVOKE ALL ON TABLE departments, positions FROM payroll_officer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO payroll_officer;

-- Read-only Viewer
GRANT SELECT ON TABLE departments, positions, employees, salary_history, payroll TO readonly_viewer;
```

> Note: `GRANT USAGE, SELECT ON SEQUENCES` is required for INSERT to work — SERIAL columns rely on sequences to auto-generate IDs.

---

## Users

| Username | Role | Password |
|---|---|---|
| `slsusr` | `hr_manager` | *(set at DB creation)* |
| `john_manager` | `hr_manager` | `Manager@123` |
| `sarah_staff` | `hr_staff` | `Staff@123` |
| `mike_payroll` | `payroll_officer` | `Payroll@123` |
| `lisa_viewer` | `readonly_viewer` | `Viewer@123` |

```sql
CREATE USER john_manager  WITH PASSWORD 'Manager@123';
CREATE USER sarah_staff   WITH PASSWORD 'Staff@123';
CREATE USER mike_payroll  WITH PASSWORD 'Payroll@123';
CREATE USER lisa_viewer   WITH PASSWORD 'Viewer@123';

GRANT hr_manager      TO john_manager;
GRANT hr_staff        TO sarah_staff;
GRANT payroll_officer TO mike_payroll;
GRANT readonly_viewer TO lisa_viewer;
GRANT hr_manager      TO slsusr;
```

---

## Testing Permissions

### Verify Users

```sql
SELECT usename AS username, usesuper AS is_superuser, usecreatedb AS can_create_db
FROM pg_user
WHERE usename IN ('john_manager', 'sarah_staff', 'mike_payroll', 'lisa_viewer', 'slsusr');
```

### Verify Role Assignments

```sql
SELECT r.rolname AS role_name, m.rolname AS assigned_to_user
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.roleid
JOIN pg_roles m ON am.member = m.oid
WHERE r.rolname IN ('hr_manager', 'hr_staff', 'payroll_officer', 'readonly_viewer');
```

### Test HR Manager (john_manager)

```sql
SET ROLE john_manager;
INSERT INTO departments (department_name, location) VALUES ('Engineering', 'Building A'); -- should work
SELECT * FROM departments;                                                                 -- should work
DELETE FROM departments WHERE department_name = 'Engineering';                             -- should work
RESET ROLE;
```

### Test HR Staff (sarah_staff)

```sql
SET ROLE sarah_staff;
INSERT INTO departments (department_name, location) VALUES ('Marketing', 'Building B');   -- should work
SELECT * FROM payroll;                                                                     -- should FAIL
RESET ROLE;
```

### Test Payroll Officer (mike_payroll)

```sql
SET ROLE mike_payroll;
SELECT * FROM employees;                                                                   -- should work
INSERT INTO payroll (employee_id, pay_period_start, pay_period_end, basic_salary, net_pay)
VALUES (1, '2025-01-01', '2025-01-31', 1500.00, 1350.00);                                -- should work
SELECT * FROM departments;                                                                 -- should FAIL
RESET ROLE;
```

### Test Read-only Viewer (lisa_viewer)

```sql
SET ROLE lisa_viewer;
SELECT * FROM employees;                                                                   -- should work
INSERT INTO departments (department_name) VALUES ('Finance');                              -- should FAIL
DELETE FROM employees WHERE employee_id = 1;                                               -- should FAIL
RESET ROLE;
```
