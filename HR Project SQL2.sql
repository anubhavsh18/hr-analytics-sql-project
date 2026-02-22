-- QUESTIONS

-- 1. What is the gender breakdown of active employees in the company?

SELECT gender,
       COUNT(*) AS total_active_employees
FROM employees
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race,
       COUNT(*) AS active_employees
FROM employees
WHERE termdate IS NULL
GROUP BY race
ORDER BY active_employees DESC;

-- 3. What is the age distribution of employees in the company?

SELECT 
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_employees
FROM employees
WHERE termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

-- -- 4. How many employees work at headquarters versus remote locations?

SELECT location,
       COUNT(*) AS active_employees
FROM employees
WHERE termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
    ROUND(AVG(DATEDIFF(termdate, hire_date)/365),2) AS avg_years_worked
FROM employees
WHERE termdate IS NOT NULL;

-- 6. How does the gender distribution vary across departments and job titles?

-- Gender distribution by Department

SELECT 
    department,
    gender,
    COUNT(*) AS total_employees
FROM employees
WHERE termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender;

-- Gender distribution by Job Title

SELECT 
    jobtitle,
    gender,
    COUNT(*) AS total_employees
FROM employees
WHERE termdate IS NULL
GROUP BY jobtitle, gender
ORDER BY jobtitle;

-- 7. What is the distribution of job titles across the company?

SELECT jobtitle,
       COUNT(*) AS active_employees
FROM employees
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY active_employees DESC;

-- 8. What is the distribution of employees across locations by city and state?

SELECT 
    location_state,
    location_city,
    COUNT(*) AS active_employees
FROM employees
WHERE termdate IS NULL
GROUP BY location_state, location_city
ORDER BY location_state, active_employees DESC;

-- 9. How has the company's employee count changed over time based on hire and term dates?

-- hiring trend

SELECT 
    YEAR(hire_date) AS year,
    COUNT(*) AS hires
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY year;

-- termination trend

SELECT 
    YEAR(termdate) AS year,
    COUNT(*) AS exits
FROM employees
WHERE termdate IS NOT NULL
GROUP BY YEAR(termdate)
ORDER BY year;

-- Net employee change per year

SELECT 
    year,
    SUM(hires) AS hires,
    SUM(exits) AS exits,
    SUM(hires - exits) AS net_change
FROM
(
    SELECT YEAR(hire_date) AS year, COUNT(*) AS hires, 0 AS exits
    FROM employees
    GROUP BY YEAR(hire_date)

    UNION ALL

    SELECT YEAR(termdate) AS year, 0 AS hires, COUNT(*) AS exits
    FROM employees
    WHERE termdate IS NOT NULL
    GROUP BY YEAR(termdate)
) t
GROUP BY year
ORDER BY year;

-- 10. What is the tenure distribution for each department?
-- Calculate tenure
SELECT 
    department,
    TIMESTAMPDIFF(YEAR, hire_date, 
        COALESCE(termdate, CURDATE())) AS tenure_years
FROM employees;

-- Tenure distribution by department

SELECT 
    department,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, hire_date, COALESCE(termdate, CURDATE())) < 1 THEN '<1 year'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, COALESCE(termdate, CURDATE())) BETWEEN 1 AND 3 THEN '1-3 years'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, COALESCE(termdate, CURDATE())) BETWEEN 4 AND 6 THEN '4-6 years'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, COALESCE(termdate, CURDATE())) BETWEEN 7 AND 10 THEN '7-10 years'
        ELSE '10+ years'
    END AS tenure_group,
    COUNT(*) AS employees
FROM employees
GROUP BY department, tenure_group
ORDER BY department, tenure_group;


-- 11. Which department has the highest turnover rate?

SELECT 
    department,
    COUNT(*) AS total_employees,

    SUM(CASE 
            WHEN termdate IS NOT NULL 
            THEN 1 ELSE 0 
        END) AS employees_left,

    ROUND(
        SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    ) AS turnover_rate

FROM employees
GROUP BY department
ORDER BY turnover_rate DESC
LIMIT 1;