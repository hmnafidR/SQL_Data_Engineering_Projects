/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers and analysts
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    providing insights into the most valuable skills for data engineers seeking remote work
*/


select
sd.skills,
count (jpf.*) as demand_Count
from job_postings_fact jpf
inner join skills_job_dim sjd
on jpf.job_id = sjd.job_id
inner join skills_dim sd
on sjd.skill_id = sd.skill_id
where (job_title_short = 'Data Engineer' or job_title_short = 'Data Analyst')
and jpf.job_work_from_home = 'Yes'
--and job_country = 'Canada'
group by sd.skills
order by demand_Count desc
limit 10;

/*

Here's the breakdown of the most demanded skills for data engineers:
SQL and Python are by far the most in-demand skills, with around 248,000 job postings each - nearly double the next closest skill.
Cloud platforms round out the top skills, with AWS leading at ~131,000 postings, followed by Azure at ~130,000.
Apache Spark completes the top 5 with nearly 107,000 postings, highlighting the importance of big data processing skills.

Key takeaways:
1. SQL and Python lead by a wide margin. SQL ranks first with about 45,000 mentions, followed by Python at about 39,000. Both appear roughly twice as often as the next skill.
2. AWS leads Azure among cloud platforms. They rank third and fourth, with AWS appearing in about 3,700 more postings.
3. Spark is the highest-ranked data processing tool. It comes in fifth, while Airflow and Snowflake also make the top 10, showing demand for tools that process, schedule, and store data.
4. Reporting and spreadsheet skills still feature prominently. Tableau leads the reporting tools shown, and Excel ranks seventh, ahead of Power BI.
5. Airflow and Power BI are effectively tied. Only two mentions separate them, even though they serve different purposes. Airflow schedules data workflows, while Power BI is used for reporting and dashboards.

┌───────────┬──────────────┐
│  skills   │ demand_Count │
│  varchar  │    int64     │
├───────────┼──────────────┤
│ sql       │        44514 │
│ python    │        38749 │
│ aws       │        19481 │
│ azure     │        15742 │
│ spark     │        13438 │
│ tableau   │        12615 │
│ excel     │        11589 │
│ airflow   │        10548 │
│ power bi  │        10546 │
│ snowflake │        10033 │
└───────────┴──────────────┘

*/

