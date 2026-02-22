CREATE DATABASE hr;

USE hr;

select * from employees;

ALTER TABLE employees RENAME COLUMN `ï»¿id` TO emp_id;

-- check columns
DESCRIBE employees;

-- Clean Employee ID
UPDATE employees
SET emp_id = REPLACE(emp_id,'-','');

ALTER TABLE employees
MODIFY emp_id VARCHAR(20);

-- Clean Employee ID
UPDATE employees
SET gender = TRIM(LOWER(gender));

UPDATE employees
SET gender = CASE
    WHEN gender='male' THEN 'Male'
    WHEN gender='female' THEN 'Female'
    ELSE 'Other'
END;

-- Clean Birthdate
-- convert blanks to NULL

UPDATE employees
SET birthdate = NULL
WHERE TRIM(birthdate)='';

-- convert mixed formats

UPDATE employees
SET birthdate =
CASE
    WHEN birthdate LIKE '%/%'
        THEN STR_TO_DATE(birthdate,'%m/%d/%Y')
    WHEN birthdate LIKE '%-%' AND LENGTH(birthdate)=8
        THEN STR_TO_DATE(birthdate,'%m-%d-%y')
    WHEN birthdate LIKE '%-%' AND LENGTH(birthdate)=10
        THEN STR_TO_DATE(birthdate,'%Y-%m-%d')
END;

-- change datatype

ALTER TABLE employees
MODIFY birthdate DATE;

-- Clean Hire Date

UPDATE employees
SET hire_date =
CASE
    WHEN hire_date LIKE '%/%'
        THEN STR_TO_DATE(hire_date,'%m/%d/%Y')
    WHEN hire_date LIKE '%-%' AND LENGTH(hire_date)=8
        THEN STR_TO_DATE(hire_date,'%m-%d-%y')
    WHEN hire_date LIKE '%-%' AND LENGTH(hire_date)=10
        THEN STR_TO_DATE(hire_date,'%Y-%m-%d')
END;
SELECT emp_id, termdate
FROM employees
WHERE termdate > CURDATE();

UPDATE employees
SET termdate = NULL
WHERE termdate > CURDATE();

ALTER TABLE employees
MODIFY hire_date DATE;

-- Clean Termination Date

UPDATE employees
SET termdate=NULL
WHERE TRIM(termdate)='';

-- removed UTC

UPDATE employees
SET termdate =
STR_TO_DATE(REPLACE(termdate,' UTC',''), '%Y-%m-%d %H:%i:%s')
WHERE termdate IS NOT NULL; 

-- change datatype

ALTER TABLE employees
MODIFY termdate DATETIME;

-- Trim text columns

UPDATE employees
SET first_name=TRIM(first_name),
    last_name=TRIM(last_name),
    department=TRIM(department),
    jobtitle=TRIM(jobtitle),
    location=TRIM(location),
    location_city=TRIM(location_city),
    location_state=TRIM(location_state),
    race=TRIM(race);
    
-- Remove duplicates

DELETE e1
FROM employees e1
JOIN employees e2
ON e1.emp_id=e2.emp_id
AND e1.first_name=e2.first_name
AND e1.last_name=e2.last_name
AND e1.hire_date=e2.hire_date
AND e1.emp_id>e2.emp_id;

-- Create age column

ALTER TABLE employees ADD age INT;

UPDATE employees
SET age=TIMESTAMPDIFF(YEAR,birthdate,CURDATE());

-- Employment Status column

ALTER TABLE employees ADD employment_status VARCHAR(20);

UPDATE employees
SET employment_status=
CASE
    WHEN termdate IS NULL THEN 'Active'
    ELSE 'Terminated'
END;

-- Final Validation

SELECT COUNT(*) FROM employees WHERE birthdate IS NULL;
SELECT COUNT(*) FROM employees WHERE hire_date IS NULL;
SELECT COUNT(*) FROM employees WHERE emp_id IS NULL;