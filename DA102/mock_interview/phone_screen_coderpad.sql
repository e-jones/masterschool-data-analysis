/*
CoderPad provides a basic SQL sandbox with the following schema.
You can also use commands like '\dt;' and '\d employees;'

employees                             projects
+---------------+---------+           +---------------+---------+
| id            | int     |<----+  +->| id            | int     |
| first_name    | varchar |     |  |  | title         | varchar |
| last_name     | varchar |     |  |  | start_date    | date    |
| salary        | int     |     |  |  | end_date      | date    |
| department_id | int     |--+  |  |  | budget        | int     |
+---------------+---------+  |  |  |  +---------------+---------+
                             |  |  |
departments                  |  |  |  employees_projects
+---------------+---------+  |  |  |  +---------------+---------+
| id            | int     |<-+  |  +--| project_id    | int     |
| name          | varchar |     +-----| employee_id   | int     |
+---------------+---------+           +---------------+---------+
*/

-- How many employees do we have?

-- SELECT * FROM employees LIMIT 100

/*
SELECT 
  COUNT(id) AS count_of_employees 
FROM  employees
*/

-- How many employees do we have in each department?
-- SELECT 
--   COUNT(e.id) AS emp_count, 
--   name AS department_name
-- FROM employees AS e
--   JOIN departments AS d
--   ON e.department_id = d.id
-- GROUP BY department_name
-- ORDER BY emp_count DESC

-- What projects have the highest budget ?

-- SELECT 
--   title,
--   budget
-- FROM projects
-- ORDER BY budget DESC
-- LIMIT 1;

-- SELECT    title, MAX(budget) AS HIGHEST_BUDGET
-- FROM      PROJECTS
-- GROUP BY  TITLE
-- ORDER BY  HIGHEST_BUDGET DESC
-- LIMIT     1;


-- Which projects have the most employees working on them?
SELECT 
  p.title AS project_title,
  COUNT(e.employee_id) AS count_of_employees
FROM employees_projects AS e
  JOIN projects AS p
  ON p.id = e.project_id
GROUP BY project_title
ORDER BY count_of_employees DESC


-- BONUS: What is highest paid employee in each department?













