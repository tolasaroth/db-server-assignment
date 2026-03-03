CREATE DATABASE employee_db WITH OWNER = slsusr ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8' TABLESPACE = pg_default CONNECTION
LIMIT = -1;


-- 1. Departments
CREATE TABLE departments (
                             department_id   SERIAL PRIMARY KEY,
                             department_name VARCHAR(100) NOT NULL,
                             location        VARCHAR(100),
                             created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Job Positions
CREATE TABLE positions (
                           position_id     SERIAL PRIMARY KEY,
                           title           VARCHAR(100) NOT NULL,
                           min_salary      NUMERIC(10,2),
                           max_salary      NUMERIC(10,2),
                           department_id   INT REFERENCES departments(department_id)
);

-- 3. Employees (core table)
CREATE TABLE employees (
                           employee_id     SERIAL PRIMARY KEY,
                           first_name      VARCHAR(50) NOT NULL,
                           last_name       VARCHAR(50) NOT NULL,
                           email           VARCHAR(100) UNIQUE NOT NULL,
                           phone           VARCHAR(20),
                           hire_date       DATE NOT NULL,
                           birth_date      DATE,
                           gender          CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
                           address         TEXT,
                           status          VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'terminated')),
                           department_id   INT REFERENCES departments(department_id),
                           position_id     INT REFERENCES positions(position_id),
                           manager_id      INT REFERENCES employees(employee_id), -- self-reference
                           created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Salary History
CREATE TABLE salary_history (
                                salary_id       SERIAL PRIMARY KEY,
                                employee_id     INT REFERENCES employees(employee_id),
                                old_salary      NUMERIC(10,2),
                                new_salary      NUMERIC(10,2),
                                change_date     DATE NOT NULL,
                                reason          TEXT
);

-- 5. Payroll
CREATE TABLE payroll (
                         payroll_id          SERIAL PRIMARY KEY,
                         employee_id         INT REFERENCES employees(employee_id),
                         pay_period_start    DATE NOT NULL,
                         pay_period_end      DATE NOT NULL,
                         basic_salary        NUMERIC(10,2),
                         bonuses             NUMERIC(10,2) DEFAULT 0,
                         deductions          NUMERIC(10,2) DEFAULT 0,
                         net_pay             NUMERIC(10,2),
                         paid_at             TIMESTAMP
);


-- setting up the user and permissions

-- =============================
-- STEP 1: Create Roles
-- =============================
CREATE ROLE hr_manager;
CREATE ROLE hr_staff;
CREATE ROLE payroll_officer;
CREATE ROLE readonly_viewer;


-- ✅ HR Manager: full access
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hr_manager;


-- ✅ HR Staff: manage core HR only, cannot touch payroll
GRANT SELECT, INSERT, UPDATE ON TABLE
    departments, positions, employees
    TO hr_staff;
REVOKE ALL ON TABLE salary_history, payroll FROM hr_staff;


-- ✅ Payroll Officer: payroll tables + read employees (needs to look up staff)
GRANT SELECT, INSERT, UPDATE ON TABLE
    salary_history, payroll
    TO payroll_officer;
GRANT SELECT ON TABLE employees TO payroll_officer;
REVOKE ALL ON TABLE departments, positions FROM payroll_officer;

-- ✅ Read-only Viewer: can only SELECT (for auditors/executives)
GRANT SELECT ON TABLE
    departments, positions, employees,
    salary_history, payroll
    TO readonly_viewer;



-- =============================
-- STEP 3: Grant Sequence Permissions
-- (needed for SERIAL/auto-increment columns to work)
-- =============================
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hr_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hr_staff;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO payroll_officer;


-- =============================
-- STEP 4: Assign itpusr
-- =============================
GRANT hr_manager TO slsusr;

SELECT * FROM departments;
INSERT INTO departments (department_name, location) VALUES ('Human Resources', 'New York');


-- User for Read-only Viewer
CREATE USER lisa_viewer WITH PASSWORD 'Viewer@123';

-- User for HR Manager
CREATE USER john_manager WITH PASSWORD 'Manager@123';

-- User for HR Staff
CREATE USER sarah_staff WITH PASSWORD 'Staff@123';

-- User for Payroll Officer
CREATE USER mike_payroll WITH PASSWORD 'Payroll@123';


-- Granting roles to users
GRANT readonly_viewer to lisa_viewer;
GRANT hr_manager     TO john_manager;
GRANT hr_staff       TO sarah_staff;
GRANT payroll_officer TO mike_payroll;

SELECT usename AS username,
       usesuper AS is_superuser,
       usecreatedb AS can_create_db
FROM pg_user
WHERE usename IN ('john_manager', 'sarah_staff', 'mike_payroll', 'lisa_viewer','slsusr');


-- Check who has which role
SELECT
    r.rolname AS role_name,
    m.rolname AS assigned_to_user
FROM pg_roles r
         JOIN pg_auth_members am ON r.oid = am.roleid
         JOIN pg_roles m ON am.member = m.oid
WHERE r.rolname IN ('hr_manager', 'hr_staff','lisa_viewer')ើ

-- Connect as john_manager
SET ROLE john_manager;

INSERT INTO departments (department_name, location)
VALUES ('Engineering', 'Building A');

SELECT * FROM departments;
DELETE FROM departments WHERE department_name = 'Engineering';

-- Connect as sarah_staff
SET ROLE sarah_staff;
--  cannot select payroll
SELECT * FROM payroll;