/*
Question: What are the highest-paying skills for data engineers and Analysts?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development priorities
*/

select
sd.skills,
ROUND(median(jpf.salary_year_avg),0) as median_salary,
count (jpf.*) as demand_Count
from job_postings_fact jpf
inner join skills_job_dim sjd
on jpf.job_id = sjd.job_id
inner join skills_dim sd
on sjd.skill_id = sd.skill_id
where (job_title_short = 'Data Engineer' 
or job_title_short = 'Data Analyst')
and jpf.job_work_from_home = True
--and job_country = 'Canada'
group by sd.skills
having count (jpf.*)  > 100
order by median_salary desc
limit 25;

--Alternative approach to calculating median salary using window functions

WITH ranked_salaries AS (
    SELECT
        sd.skills,
        jpf.salary_year_avg,
        ROW_NUMBER() OVER (
            PARTITION BY sd.skills
            ORDER BY jpf.salary_year_avg IS NULL, jpf.salary_year_avg
        ) AS salary_rank,
        COUNT(jpf.salary_year_avg) OVER (
            PARTITION BY sd.skills
        ) AS salary_count
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short IN ('Data Engineer', 'Data Analyst')
      AND jpf.job_work_from_home = TRUE
      -- AND jpf.job_country = 'Canada'
)
SELECT
    skills,
    ROUND(AVG(
        CASE
            WHEN salary_rank BETWEEN (salary_count + 1) // 2
                                 AND (salary_count + 2) // 2
            THEN salary_year_avg
        END
    ), 0) AS median_salary,
    COUNT(*) AS demand_Count
FROM ranked_salaries
GROUP BY skills
HAVING COUNT(*) > 100
ORDER BY median_salary DESC
LIMIT 25;

/*

Key takeaways:

1. Rust tops the salary list. Postings that mention Rust have a median salary of 200,000, the highest in the table, but Rust appears in only 245 postings.
2. Terraform stands out for both pay and demand. It shares a median salary of 184,000 with Go, and it appears in more than three times as many postings.
3. Airflow is the most frequently requested skill in this table. It appears in over 10,000 postings and has a median salary of 146,500. Kafka comes second by demand, with a similar median salary.
4. Kubernetes is another widely requested skill. It ranks third by demand in the table, behind Airflow and Kafka, with a median salary of 150,000.
5. These salaries describe the jobs that mention each skill. A posting can ask for several skills, and its pay can also reflect the role, seniority, and location.


┌───────────────┬───────────────┬──────────────┐
│    skills     │ median_salary │ demand_Count │
│    varchar    │    double     │    int64     │
├───────────────┼───────────────┼──────────────┤
│ rust          │      200000.0 │          245 │
│ golang        │      184000.0 │          924 │
│ terraform     │      184000.0 │         3300 │
│ bitbucket     │      180000.0 │          545 │
│ graphql       │      170938.0 │          534 │
│ neo4j         │      170000.0 │          289 │
│ mongo         │      162250.0 │          302 │
│ gdpr          │      158731.0 │         1091 │
│ fastapi       │      157500.0 │          209 │
│ vue           │      156000.0 │          107 │
│ atlassian     │      155500.0 │          328 │
│ django        │      155000.0 │          290 │
│ typescript    │      152500.0 │          520 │
│ ruby          │      150000.0 │          972 │
│ ruby on rails │      150000.0 │          122 │
│ css           │      150000.0 │          442 │
│ node          │      150000.0 │          209 │
│ kubernetes    │      150000.0 │         4296 │
│ redis         │      149000.0 │          626 │
│ ansible       │      148798.0 │          492 │
│ vmware        │      148798.0 │          144 │
│ airflow       │      146500.0 │        10548 │
│ kafka         │      145000.0 │         6556 │
│ zoom          │      145000.0 │          344 │
│ swift         │      140500.0 │          200 │
└───────────────┴───────────────┴──────────────┘


*/