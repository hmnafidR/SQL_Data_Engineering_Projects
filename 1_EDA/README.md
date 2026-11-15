# Exploratory Data Analysis with SQL: Remote Data Jobs

This SQL project analyzes the data engineer and analyst job market using real world job posting data. It demonstrates my ability to **write production-quality analytical SQL, design efficient queries, and turn business questions into data-driven insights**.


![Project overview showing how job posting data becomes skill demand and salary insights](../Images/1_1_Project1_EDA.png)

## Executive Summary

- **Scope:** Completed three analyses covering skill demand, median salaries, and the balance between demand and salary. The salary and combined-ranking scripts each include two approaches.
- **Data modeling:** Joined job postings to a skills catalog through a bridge table that links jobs and skills.
- **Analysis:** Used counts, median salaries, sample thresholds, and a weighted score to compare skills.
- **Findings:** SQL and Python have the widest demand in the saved results. Cloud and data processing tools also feature prominently, while Terraform leads the revised weighted ranking.

For a quick review, start with [the demand query](01_top_demanded_skills.sql) and [the combined ranking queries](03_most_optimal_skills.sql).

## Table of Contents

- [Problem and Context](#problem-and-context)
- [Data Model](#data-model)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Analysis and Findings](#analysis-and-findings)
- [How to Run the Queries](#how-to-run-the-queries)
- [SQL Skills Demonstrated](#sql-skills-demonstrated)
- [Limitations](#limitations)
- [Acknowledgments](#acknowledgments)

## Problem and Context

Choosing what to learn is easier when skill demand and salary are considered together. A widely requested skill may open more opportunities, while a specialized skill may be associated with higher pay. This project explores three questions:

1. Which skills appear most often in remote data job postings?
2. Which skills are associated with higher reported annual salaries?
3. Which skills offer a strong balance of demand and salary?

All three analyses are implemented in the SQL scripts linked below.

## Data Warehouse Schema


![Data warehouse schema showing job postings, companies, and the job-to-skill relationship](../Images/1_2_Data_Warehouse.png)

| Table | Role | Purpose |
| --- | --- | --- |
| `job_postings_fact` | Fact table | Central table containing job posting details (job titles, locations, salaries, dates, etc.) |
| `skills_dim` | Dimension table | Skills catalog with skill names and types |
| `skills_job_dim` | Bridge table | Resolves the many-to-many relationship between job postings and skills |
| `company_dim` | Dimension table | Company information linked to job postings |


By querying across these interconnected tables, I extracted insights about skill demand, salary patterns, and optimal skill combinations for data engineering roles.


## Tech Stack

- **Query Engine:** DuckDB for fast OLAP-style analytical queries  
- **Language:** SQL (ANSI-style with analytical functions)  
- **Data Model:** Star schema with fact + dimension + bridge tables  
- **Development:** VS Code for SQL editing + Terminal for DuckDB CLI  
- **Version Control:** Git/GitHub for versioned SQL scripts  


## Repository Structure

The main project files are:

```text

1_EDA/
├── 01_top_demanded_skills.sql    # Top 10 skills by remote posting count
├── 02_top_paying_skills.sql      # Salary analysis query
├── 03_optimal_skills.sql         # Two demand-and-salary ranking approaches
└── README.md                     # Project Documentation
```

## Analysis and Findings

### Analysis Overview

| Analysis | Method | Status |
| --- | --- | --- |
| [Most in-demand skills](01_top_demanded_skills.sql) | Rank skills by remote posting count and return the top 10. | Complete |
| [Highest-paying skills](02_top_paying_skills.sql) | Rank the top 25 skills by median salary, requiring more than 100 total postings per skill. | Complete |
| [Demand and salary balance](03_most_optimal_skills.sql) | Combine median salary and log-transformed demand; return the top 25 eligible skills per approach. | Complete |


### 1. Most In-Demand Skills

**Query:** [01_top_demanded_skills.sql](01_top_demanded_skills.sql)

This query counts the job-skill records for remote roles, groups them by skill, and returns the ten highest counts. Salary information is not required.

**What this shows:** SQL and Python lead the results by a wide margin. AWS and Azure show demand for cloud skills, while Spark, Airflow, and Snowflake highlight tools used to process, schedule, and store data. Reporting tools also appear because the analysis includes Data Analyst roles.

### 2. Highest-Paying Skills

**Query file:** [02_top_paying_skills.sql](02_top_paying_skills.sql)

This script ranks skills by median reported annual salary for remote Data Engineer and Data Analyst roles. It includes a direct `MEDIAN` calculation and an alternative using a common table expression, `ROW_NUMBER`, and windowed `COUNT` to identify the middle salary values.

Both approaches require more than 100 total postings per skill and return the top 25 skills. Demand includes postings without salaries, while the median uses non-null salary values. Unlike the revised combined ranking, this analysis does not exclude zero salaries or require a minimum number of salary observations.

Selected results from the saved output:

| Skill | Total posting count | Median annual salary |
| --- | ---: | ---: |
| Rust | 245 | $200,000 |
| Golang | 924 | $184,000 |
| Terraform | 3,300 | $184,000 |
| Bitbucket | 545 | $180,000 |
| GraphQL | 534 | $170,938 |
| Kubernetes | 4,296 | $150,000 |
| Airflow | 10,548 | $146,500 |
| Kafka | 6,556 | $145,000 |

**What this shows:** Rust has the highest median salary in the saved output, though it appears in relatively few postings. Terraform combines a high median salary with broader demand than Rust or Golang. Airflow and Kafka appear in more postings than the other skills shown here, with lower median salaries than the highest-ranked specializations.

### 3. Balancing Demand and Salary

**Queries:** [03_most_optimal_skills.sql](03_most_optimal_skills.sql)

This script contains two approaches:

- **Initial approach:** Measures both demand and median salary using only postings with non-null annual salaries. Skills must appear in more than 100 of those postings.
- **Revised approach:** Counts demand across all matching postings, excludes null and zero salary values from the salary calculation, and requires more than 100 postings and at least 30 valid salary observations per skill.

Both approaches use this score, with demand defined according to the approach:

```text
Weighted score = median annual salary × ln(posting count) / 1,000,000
```

The natural logarithm reduces the effect of very large posting counts. Dividing by one million makes the score easier to read without changing the ranking.

The following results use the **revised approach**:

| Skill | Total posting count | Salary observations | Median annual salary | Weighted score |
| --- | ---: | ---: | ---: | ---: |
| Terraform | 3,300 | 195 | $184,000 | 1.49 |
| Airflow | 10,548 | 406 | $146,500 | 1.36 |
| AWS | 19,481 | 871 | $134,415 | 1.33 |
| Spark | 13,438 | 526 | $140,000 | 1.33 |
| Python | 38,749 | 1,627 | $122,500 | 1.29 |
| Kafka | 6,556 | 293 | $145,000 | 1.27 |
| Golang | 924 | 41 | $184,000 | 1.26 |
| Kubernetes | 4,296 | 153 | $150,000 | 1.25 |
| SQL | 44,514 | 1,911 | $115,000 | 1.23 |
| Azure | 15,742 | 551 | $125,000 | 1.21 |

**What this shows:** Terraform ranks first under this scoring method, while Airflow, AWS, and Spark combine substantial demand with higher median salaries than SQL or Python. SQL and Python still offer the broadest reach in these results. Golang has a high median salary, but its smaller salary sample makes that figure less representative of a broad market.

These findings suggest a learning path that starts with SQL and Python, adds cloud skills such as AWS or Azure, and then develops processing and workflow skills such as Spark and Airflow. Terraform offers a further area of specialization.


## SQL Skills Demonstrated

### Query Design

- **Multi-table joins:** Use `INNER JOIN` to connect job postings, job-skill records, and skill names.
- **Targeted filtering:** Apply `WHERE` conditions for job titles, remote-work status, and salary availability.
- **Top-N results:** Combine `ORDER BY` and `LIMIT` to surface the highest-ranked skills.

### Analytical Techniques

- **Aggregation:** Use `COUNT` and `GROUP BY` to measure demand for each skill.
- **Salary summaries:** Calculate median reported annual salary with `MEDIAN` and format results with `ROUND`.
- **Missing-value handling:** Use `NULLIF` in the revised query to exclude zero salaries from salary calculations while retaining those postings in demand counts.
- **Sample thresholds:** Apply `HAVING` to require more than 100 postings and, in the revised approach, at least 30 valid salary observations.
- **Calculated rankings:** Use `LN` to reduce the influence of large demand counts when combining demand with median salary.

## Limitations

- These results describe the course dataset; they are not a live view of the job market. The queries do not apply a posting-date filter.
- Data Engineer and Data Analyst roles are combined, so the rankings reflect both job types.
- Many postings do not report salaries. Salary medians describe the available salary sample, which may differ from the wider set of postings.
- Salary figures summarize the `salary_year_avg` field associated with each skill. They do not show that learning a skill causes a salary increase.
- A posting can list several skills and contribute to several counts. The queries assume each job-skill pair appears once in the linking table.
- The weighted score is a project-specific comparison method. A different formula or sample threshold could change the rankings.


