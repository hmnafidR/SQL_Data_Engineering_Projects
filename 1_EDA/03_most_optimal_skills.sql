/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer and analyst positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
*/

/*
This query:
1. Finds all remote Data Engineer and analyst jobs.
2. Removes jobs without salary information.
3. Groups the remaining jobs by skill.
4. Keeps skills appearing in more than 100 postings with salary information.
5. Calculates median salary and demand count.
*/
select
sd.skills,
ROUND(median(jpf.salary_year_avg),0) as median_salary, --ignores NULL values but includes 0 values
count (jpf.*) as demand_Count, -- counts non-NULL values, including 0 values
-- using natural log transformation to balance demand and salary, giving more weight to skills that are both in high demand and offer competitive salaries
ROUND((median(jpf.salary_year_avg) * ln(count (jpf.*)))/1_000_000,2) as weighted_score --weighted score to balance demand and salary
from job_postings_fact jpf
inner join skills_job_dim sjd
on jpf.job_id = sjd.job_id
inner join skills_dim sd
on sjd.skill_id = sd.skill_id
where (job_title_short = 'Data Engineer'
or job_title_short = 'Data Analyst')
and jpf.job_work_from_home = True
AND jpf.salary_year_avg IS NOT NULL

--and job_country = 'Canada'
group by sd.skills
having count (jpf.*)  > 100
order by weighted_score desc
limit 25;

/*

Key findings
- Terraform leads overall (0.97): Highest median salary at $184K, but relatively limited demand (195 postings). Strong salary opportunity, though less broadly requested.
- Python and SQL dominate demand: SQL leads with 1,911 postings, followed by Python (1,627). These are foundational skills with the widest job opportunities.
- AWS offers an excellent balance: $134K median salary, 871 postings, and a 0.91 score. It combines strong demand with competitive compensation.
- Spark and Airflow are valuable specializations: Both score 0.88, with median salaries of $140K and $146.5K respectively. They indicate the value of distributed processing and workflow orchestration.
- Cloud and modern data platforms perform well: Snowflake (0.81), Azure (0.79), Databricks (0.74), and GCP (0.73) all appear among the top 25, supporting the importance of cloud-based data engineering.
- Kubernetes and Kafka offer higher salary potential but narrower demand: Their median salaries are $150K and $145K, respectively, compared with SQL's $115K.

The strongest learning strategy is to combine high-demand foundational skills (SQL and Python) with cloud infrastructure (AWS or Azure), data processing (Spark), and orchestration (Airflow). Terraform is a particularly attractive specialization based on its high salary and weighted score.
┌────────────┬───────────────┬──────────────┬────────────────┐
│   skills   │ median_salary │ demand_Count │ weighted_score │
│  varchar   │    double     │    int64     │     double     │
├────────────┼───────────────┼──────────────┼────────────────┤
│ terraform  │      184000.0 │          195 │           0.97 │
│ python     │      122500.0 │         1627 │           0.91 │
│ aws        │      134415.0 │          871 │           0.91 │
│ spark      │      140000.0 │          526 │           0.88 │
│ airflow    │      146500.0 │          406 │           0.88 │
│ sql        │      115000.0 │         1911 │           0.87 │
│ kafka      │      145000.0 │          293 │           0.82 │
│ snowflake  │      130000.0 │          521 │           0.81 │
│ azure      │      125000.0 │          551 │           0.79 │
│ java       │      131500.0 │          330 │           0.76 │
│ scala      │      136645.0 │          256 │           0.76 │
│ kubernetes │      150000.0 │          153 │           0.75 │
│ databricks │      130000.0 │          297 │           0.74 │
│ git        │      135750.0 │          228 │           0.74 │
│ gcp        │      135000.0 │          222 │           0.73 │
│ redshift   │      123350.0 │          332 │           0.72 │
│ pyspark    │      140000.0 │          156 │           0.71 │
│ hadoop     │      131000.0 │          223 │           0.71 │
│ nosql      │      130000.0 │          215 │            0.7 │
│ docker     │      134888.0 │          150 │           0.68 │
│ mongodb    │      135250.0 │          144 │           0.67 │
│ pandas     │      135500.0 │          132 │           0.66 │
│ github     │      130250.0 │          142 │           0.65 │
│ tableau    │      100000.0 │          669 │           0.65 │
│ go         │      127000.0 │          160 │           0.64 │
└────────────┴───────────────┴──────────────┴────────────────┘

*/

/*
Alternative query to calculate the most optimal skills for data engineers, balancing both demand and salary. This query addresses several limitations of the above query:

1. Counts all job postings: Removes salary_year_avg IS NOT NULL, so jobs without salary information are included in demand.
2. Separates demand from salary availability: COUNT(*) measures total job postings, while salary_sample_count shows how many have valid salary information.
3. Excludes zero salaries: Uses NULLIF(salary_year_avg, 0) so both NULL and zero values are excluded from the median salary calculation.
4. Improves salary reliability: Requires at least 30 valid salary observations per skill, in addition to the existing requirement of more than 100 total postings.
5. Changes the weighted score calculation: Uses total job demand (COUNT(*)) instead of only postings with salary information, giving more weight to skills with broader market demand.

Bottom line: Your original query ranks skills based on salary and demand among jobs that report salaries. 
The revised query ranks skills based on overall job demand and median reported salary, making it more representative of market demand while maintaining a minimum salary sample size.
*/

SELECT
    sd.skills,
    ROUND(MEDIAN(NULLIF(jpf.salary_year_avg, 0)), 0) AS median_salary, --ignores NULL values
    COUNT(*) AS demand_count, --Measures actual demand, regardless of salary availability.
    COUNT(NULLIF(jpf.salary_year_avg, 0)) AS salary_sample_count, --Excludes zero salaries from the median, assuming zero represents missing or invalid salary data. Shows how many salary observations support the median.

    ROUND(
        (
            MEDIAN(NULLIF(jpf.salary_year_avg, 0))
            * LN(COUNT(*))
        ) / 1000000,
        2
    ) AS weighted_score

FROM job_postings_fact jpf

INNER JOIN skills_job_dim sjd
    ON jpf.job_id = sjd.job_id

INNER JOIN skills_dim sd
    ON sjd.skill_id = sd.skill_id

WHERE jpf.job_title_short IN ('Data Engineer', 'Data Analyst')
    AND jpf.job_work_from_home = TRUE

GROUP BY sd.skills

HAVING COUNT(*) > 100
    AND COUNT(NULLIF(jpf.salary_year_avg, 0)) >= 30

ORDER BY weighted_score DESC NULLS LAST
LIMIT 25;

/*

Your results suggest three distinct categories:
- Foundational skills: SQL and Python offer the broadest job opportunities.
- High-value engineering skills: AWS, Azure, Airflow, Spark, and Kafka offer a strong combination of demand and compensation.
- High-paying specializations: Terraform, Kubernetes, and Golang are associated with higher median salaries but smaller job markets.
For career development, the strongest practical combination is SQL + Python + cloud (AWS/Azure) + orchestration (Airflow) + distributed processing (Spark), with Terraform as a valuable additional specialization.


┌────────────┬───────────────┬──────────────┬─────────────────────┬────────────────┐
│   skills   │ median_salary │ demand_count │ salary_sample_count │ weighted_score │
│  varchar   │    double     │    int64     │        int64        │     double     │
├────────────┼───────────────┼──────────────┼─────────────────────┼────────────────┤
│ terraform  │      184000.0 │         3300 │                 195 │           1.49 │
│ airflow    │      146500.0 │        10548 │                 406 │           1.36 │
│ aws        │      134415.0 │        19481 │                 871 │           1.33 │
│ spark      │      140000.0 │        13438 │                 526 │           1.33 │
│ python     │      122500.0 │        38749 │                1627 │           1.29 │
│ kafka      │      145000.0 │         6556 │                 293 │           1.27 │
│ golang     │      184000.0 │          924 │                  41 │           1.26 │
│ kubernetes │      150000.0 │         4296 │                 153 │           1.25 │
│ sql        │      115000.0 │        44514 │                1911 │           1.23 │
│ azure      │      125000.0 │        15742 │                 551 │           1.21 │
│ scala      │      136645.0 │         6556 │                 256 │            1.2 │
│ gcp        │      135000.0 │         7101 │                 222 │            1.2 │
│ snowflake  │      130000.0 │        10033 │                 521 │            1.2 │
│ pyspark    │      140000.0 │         5171 │                 156 │            1.2 │
│ databricks │      130000.0 │         8959 │                 297 │           1.18 │
│ java       │      131500.0 │         7770 │                 330 │           1.18 │
│ git        │      135750.0 │         5351 │                 228 │           1.17 │
│ docker     │      134888.0 │         4549 │                 150 │           1.14 │
│ hadoop     │      131000.0 │         5921 │                 223 │           1.14 │
│ mongodb    │      135250.0 │         4044 │                 144 │           1.12 │
│ pandas     │      135500.0 │         3614 │                 132 │           1.11 │
│ nosql      │      130000.0 │         4872 │                 215 │            1.1 │
│ redshift   │      123350.0 │         6296 │                 332 │           1.08 │
│ graphql    │      170938.0 │          534 │                  30 │           1.07 │
│ go         │      127000.0 │         3711 │                 160 │           1.04 │
└────────────┴───────────────┴──────────────┴─────────────────────┴────────────────┘
*/