select *
from [HR Data]
where new_termdate is not null


update [HR Data]
set termdate = FORMAT(convert(Datetime, left(termdate, 19), 120), 'yyyy-mm-dd')

UPDATE [HR Data]
SET termdate = 
  CASE 
    WHEN ISDATE(termdate) = 1 THEN CONVERT(VARCHAR(50), CONVERT(DATETIME, termdate, 23), 120)
    ELSE NULL
  END;


alter table [hr Data]
add new_termdate DATE

update [HR Data]
set new_termdate = case
when termdate is not null and isdate(termdate)=1 then cast(termdate as datetime) else null end;

--create new column 'age'
alter table [HR Data]
add age varchar(50)

--fill the new column with the ages from the birthdate column
update [HR Data]
set age = datediff(year, birthdate, getdate())

--calculating the age distribution
select Min(age) as youngest, 
Max(age) as oldest
from [HR Data]

--calculating age brackets by counts
select age_group,
count(*) as count
from
(select
case
	when age>=21 and age<=30 then '21 to 30'
	when age>=31 and age<=40 then '31 to 40'
	when age>=41 and age<=50 then '41 to 50'
	else '50+'
	end as age_group
from [HR Data]
where new_termdate is null
) as subquery
group by age_group
order by age_group;



--age groups by gender
SELECT 
    age_group,
    gender,
    COUNT(*) AS count
FROM
    (SELECT
        CASE
            WHEN age >= 21 AND age <= 30 THEN '21 to 30'
            WHEN age >= 31 AND age <= 40 THEN '31 to 40'
            WHEN age >= 41 AND age <= 50 THEN '41 to 50'
            ELSE '50+'
        END AS age_group,
        gender
    FROM [HR Data]
    WHERE new_termdate IS NULL) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;

--whats the gender breakdown in the company
select
	gender,
	count(gender) as count
from [HR Data]
where new_termdate is null
group by gender
order by count desc;

--how does gender vary accross departments and job titles?
--by department
select
	gender,
	department,
	count(gender) as count
from [HR Data]
where new_termdate is null
group by department, gender
order by department, gender desc;

--by job title
select
	gender,
	jobtitle,
	count(gender) as count
from [HR Data]
where new_termdate is null
group by jobtitle, gender
order by jobtitle, gender desc;

--race distribution in the company
select 
	race,
	count(*) as count
from [HR Data]
where new_termdate is null
group by race
order by count desc;

--average length of employment in the company
select 
(datediff(year, hire_date, new_termdate)) as tenure
from [HR Data]
where new_termdate is not null and new_termdate<=getdate();

-- which department has the highest turnover rate?
-- get the total count
--get the terminated count
--terminated count/total count


SELECT
	department,
	total_count,
	terminated_count,
	ROUND((CAST(terminated_count AS FLOAT) / total_count) * 100, 2) AS turnover_rate
FROM
	(SELECT
		department,
		COUNT(*) AS total_count,
		SUM(CASE
				WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1
				ELSE 0
			END) AS terminated_count
	FROM [HR Data]
	GROUP BY department
	) AS subquery
ORDER BY turnover_rate DESC;

-- tenure distribution for each department
 select 
	 department,
	avg(datediff(year, hire_date, new_termdate)) as tenure
from [HR Data]
where new_termdate is not null and new_termdate<=getdate()
group by department
order by tenure desc

-- how many employees work remotely for each department
select 
	location, 
	count(*) as count
from [HR Data]
where new_termdate is null and location = 'Remote'
group by location;

-- what is the distribution of employees accross different states?
select 
	location_state, 
	count(*) as count
from [HR Data]
where new_termdate is null
group by location_state
order by count desc;

-- job titles distributions in the company
select 
	jobtitle, 
	count(*) as count
from [HR Data]
where new_termdate is null
group by jobtitle
order by count desc;

-- how have employee hire counts varied over time?
--calculate hires
--calculate terminations
--(hires-terminations)/hires

SELECT
	hire_year,
	hires,
	terminations,
	hires - terminations AS net_change,
	round((CAST(hires - terminations AS FLOAT) / hires) *100, 2) AS percent_hire_change
FROM
	(SELECT
		YEAR(hire_date) AS hire_year,
		COUNT(*) AS hires,
		SUM(CASE
				WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() then 1
			END) AS terminations
	FROM [HR Data]
	GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY hires DESC;

