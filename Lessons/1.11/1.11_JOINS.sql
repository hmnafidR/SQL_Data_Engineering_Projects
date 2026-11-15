select
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name as company_name,
    jpf.job_location   

 from
    job_postings_fact as jpf
left join
    company_dim as cd
    on jpf.company_id = cd.company_id
limit 10;

-- using skills table 

select * from skills_job_dim LIMIT 10;
select * from skills_dim LIMIT 10;

select
    jpf.job_id,
    jpf.job_title_short,
    Sd.skill_id,
    sd.skills 
from 
    job_postings_fact as jpf
left join
    skills_job_dim as sjd

    on jpf.job_id = sjd.job_id
left join
    skills_dim as sd
    on sjd.skill_id = sd.skill_id
limit 10;