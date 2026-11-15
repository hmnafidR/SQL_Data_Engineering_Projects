-- Job postings information
select
    job_id,
    job_title_short,
    salary_year_avg,
    company_id
from job_postings_fact
limit 10;

-- Company information
select
    company_id, --primary key
    name
from company_dim
limit 10;

-- Bridge table to connect job postings and companies
select
*    
from skills_job_dim
limit 5;

--Information schema

select * from skills_dim limit 5;

select * from information_schema.tables WHERE TABLE_CATALOG = 'data_jobs'; 

PRAGMA show_tables;

PRAGMA show_tables_expanded;

--specific to duckdb to describe the table structure
DESCRIBE job_postings_fact;