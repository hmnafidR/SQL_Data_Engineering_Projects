/* 
Find the top 10 companies for posting jobs. 
They must have >300 Postings
Limit to only US jobs


*/  
EXPLAIN ANALYZE
Select 
 cd.name as company_name,
 count(jpf.job_id) as postings_count
from job_postings_fact jpf
left join company_dim cd on jpf.company_id = cd.company_id
where jpf.job_country = 'United States'
group by cd.name
having count(jpf.job_id) > 300
order by postings_count desc
limit 10;

