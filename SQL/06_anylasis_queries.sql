/* this file includes a number of queries that include:
	1. Employee Demographics
	2. Compensation
	3. Performance & Engagement
	4. Turnover & Retention
	5. Training & Development 
*/

-- # 1. Employee Demographics


-- number of employees:
select count(empid) as "number of employees" 
	from hr_department.employees;

-- number of employees with respect to marital status
select count(*) as number,
	maritaldesc as "marital describe" 
	from hr_department.employees 
	group by maritaldesc;

-- number of employees with respect to race
select count(*) as number,
	racedesc as "race describe" 
	from hr_department.employees 
	group by racedesc;

-- number of employees with respect to the state
select count(*) as number, 
	state from hr_department.employees 
	group by state 
	order by number desc;

-- number of followers with respect to supervisor
select count(*) as number,
	supervisor 
	from hr_department.employees 
	group by supervisor 
	order by number desc;

-- Avg number of followers per supervisor
select round(avg(number),2) 
	from (select count(*) as number,supervisor from hr_department.employees group by supervisor);

-- employees per payzone
select count(*) as number 
	,payzone_name 
	from hr_department.employees 
	join hr_department.payzone_name 
	on payzone_name_id = payzone_id 
	group by payzone_name 
	order by number desc ;


-- number of people in 20s,30s, 40s and 50s
select count(*) as number, case
	when extract(year from Age(dob))<30 then '18-29'
	when 30<=extract(year from Age(dob)) and extract(year from Age(dob))<40 then '30s'
	when 40<=extract(year from Age(dob)) and extract(year from Age(dob)) <=60 then '40s-60s'
	else 'above 60s'
	end as Age
	from hr_department.employees group by Age order by number desc;

--  the number of employees at each department with respect to gender
select gendercode,count(gendercode),
	round(count(gendercode)*100/sum(count(gendercode)) over (partition by department_name),2) as percentage,
	department_name 
	from hr_department.employees s
	join hr_department.department_type d 
	on s.department_type_id = d.department_id
	group by department_name,gendercode
	order by department_name;

--  the number of active employees at each department with respect to gender
select gendercode,count(gendercode),
	round(count(gendercode)*100/sum(count(gendercode)) over (partition by department_name),2) as percentage,
	department_name 
	from hr_department.employees s
	join hr_department.department_type d 
	on s.department_type_id = d.department_id
	join hr_department.employee_status es
	on s.employee_status_id = es.employee_status_id
	where es.employee_status_type = 'Active'
	group by department_name,gendercode
	order by department_name;

-- number and percentage of employees classification types
select count(*)	as number , round(count(*)*100/sum(count(*)) over(),2) as percentage, employeeclassificationtype as "Classification Type"
	from hr_department.employees
	group by employeeclassificationtype;

-- number and percentage of employees classification types according to the gender code
select count(*)	as number,
	gendercode as "Gender",
	round(count(*)*100/sum(count(*)) over(partition by employeeclassificationtype),2) as percentage,
	employeeclassificationtype as "Classification Type"
	from hr_department.employees
	group by gendercode, employeeclassificationtype
	order by employeeclassificationtype, percentage desc ;

-- employee classification type according to the Age
select count(*),
	employeeclassificationtype as "Classification Type",
	Age
	from (select * ,case
	when extract(year from Age(dob))<30 then '18-29'
	when 30<=extract(year from Age(dob)) and extract(year from Age(dob))<40 then '30s'
	when 40<=extract(year from Age(dob)) and extract(year from Age(dob)) <=60 then '40s-60s'
	else 'above 60s'
	end as Age
	from hr_department.employees) group by employeeclassificationtype,Age
	order by Age; 
-- employee classification type according to the different departments
select count(*) as number,
	department_name as "Department",
	round(count(*)*100/sum(count(*)) over(partition by department_name),2) as percentage,
	employeeclassificationtype as "Classification Type"
	from hr_department.employees s
	join hr_department.department_type dt
	on s.department_type_id = dt.department_id
	group by employeeclassificationtype,department_name
	order by department_name , percentage desc ;

-- performance according to satisfaction
select count(*),
	round(count(*)*100.0/sum(count(*)) over(partition by performance_score),2) as percentage ,
	satisfaction_score ,
	performance_score from hr_department.employees s
	join hr_department.performance p
	on s.performance_id = p.performance_id
	join hr_department.engagement_survey es
	on s.empid = es.employee_id
	group by performance_score,satisfaction_score
	order by performance_score,satisfaction_score desc;
-- performance according to worklife_balance_score
select count(*),
	round(count(*)*100.0/sum(count(*)) over(partition by performance_score),2) as percentage ,
	work_life_balance_score as "Work-Life Balance score" ,
	performance_score from hr_department.employees s
	join hr_department.performance p
	on s.performance_id = p.performance_id
	join hr_department.engagement_survey es
	on s.empid = es.employee_id
	group by performance_score,work_life_balance_score
	order by performance_score,work_life_balance_score desc;

-- # 2. Compensation

-- the total and average training cost
select round(sum(training_cost)) as "Total Cost",round(avg(training_cost)) as "AVG Cost" 
	from hr_department.training_and_development;

-- the total and average training cost with respect to the department
select round(sum(training_cost)) as "Total Cost",
	round(avg(training_cost)) as "AVG Cost",
	training_program_name as "Program Name"
	from hr_department.training_and_development tad
	join hr_department.training_program_name tpn
	on tad.training_program_name_id = tpn.training_program_id
	group by training_program_name

-- # 3. Performance & Engagement

-- the number and percentage of employees with respect to performance_score
select count(*)as number,round(count(*)*100.0 /(sum(count(*)) over ()),2) as percentage,performance_score as "performance score" from hr_department.employees s
	join hr_department.performance p
	on s.performance_id = p.performance_id
	group by performance_score
	order by number desc;


-- the number and percentage of employees with respect to engagement_score
select count(*) as "number of employees",
	round(count(*)*100.0/sum(count(*)) over (),2) as percentage,
	engagement_score as "Engagement score" 
	from hr_department.engagement_survey 
	group by engagement_score
	order by "number of employees" desc;

-- the number and percentage of employees with respect to satisfaction_score
select count(*) as "number of employees",
	round(count(*)*100.0/sum(count(*)) over (),2) as percentage,
	satisfaction_score as "Satisfaction score" 
	from hr_department.engagement_survey 
	group by satisfaction_score
	order by "number of employees" desc;
-- the number and percentage of employees with respect to work-life balance score
select count(*) as "number of employees",
	round(count(*)/sum(count(*)) over (),2) as percentage,
	work_life_balance_score as "work life balance score" 
	from hr_department.engagement_survey 
	group by work_life_balance_score
	order by "number of employees" desc;


-- Correlation coefficient between performance and engagement scores
select round(corr(s.performance_id, es.engagement_score)::numeric,2) from hr_department.employees s 
	join hr_department.engagement_survey es
	on s.empid = employee_id;

-- 4. Turnover & Retention

-- number and percentage of employees with respect to the type of termination
select count(*) as number,
	round(count(*)*100 / sum(count(*)) over() ,2)as percentage, 
	termination_type as "Termination Type"
	from hr_department.employees e
	join hr_department.termination_type tt
	on e.termination_type_id = tt.termination_type_id
	group by termination_type
	order by number desc ;

-- number and percentage of employees with respect to the type of termination in each department

select count(*) as number,
	round(count(*)*100 / sum(count(*) ) over(partition by department_name) ,2)as percentage,
	termination_type as "Termination Type",
	department_name as "Department"
	from hr_department.employees e
	join hr_department.termination_type tt
	on e.termination_type_id = tt.termination_type_id
	join hr_department. department_type dt
	on  dt.department_id = e.department_type_id
	group by termination_type,department_name
	order by department_name,percentage desc;


-- number and percentage of employees with respect to employee status
select count(*) as number,
	round(count(*)*100/sum(count(*)) over(),2) as percentage,
	employee_status_type as "Employee Status" 
	from hr_department.employees s
	join hr_department.employee_status es
	on es.employee_status_id = s.employee_status_id
	group by employee_status_type
	order by percentage desc;

-- 5. Training & Development 

-- number and percentage of employees according to training type
select count(*) as number,
	round(count(*)*100/sum(count(*)) over(),2) as percentage,
	training_type as "Training Type"
	from hr_department.training_and_development tad
	group by training_type
	order by number desc ;

-- number and percentage of employees according to the training_outcome
select count(*) as number,
	round(count(*)*100/sum(count(*)) over(),2) as percentage,
	training_outcome as "Training Outcome"
	from hr_department.training_and_development tad
	group by training_outcome
	order by number desc ;

-- number of training_type according to the training_outcome
select count(*) as number,
	round(count(*)/sum(count(*)) over(partition by training_outcome),2) as percentage,
	training_outcome as "Training Outcome",
	training_type as "Training Type"
	from hr_department.training_and_development tad
		group by training_outcome,training_type
		order by training_outcome desc;

-- Does the number of training days affect the training outcome
select count(*),
	training_duration_days as "Training Days",
	round(count(*)*100/sum(count(*)) over(partition by training_duration_days),2) as percentage , 
	training_outcome as "Training Outcome"
	from hr_department.training_and_development
	group by training_duration_days , training_outcome
	order by "Training Days", percentage desc;
-- number and percentage for training_program_name_id 
select count(*) as number,
	round(count(*)*100/sum(count(*)) over(),2) as percentage,
	training_program_name as "Program Name"
	from hr_department.training_program_name as tpn
	join hr_department.training_and_development as tad
	on tpn.training_program_id = tad.training_program_name_id
	group by  training_program_name
	order by number desc;

-- number and percentage for training_program_name_id in according with training_outcome
select count(*) as number,
	training_program_name as "Program Name",
	round(count(*)/sum(count(*)) over(partition by training_program_name),2) as percentage,
	training_outcome as "Training Outcome"
	from hr_department.training_program_name as tpn
	join hr_department.training_and_development as tad
	on tpn.training_program_id = tad.training_program_name_id
	group by  training_program_name, training_outcome
	order by "Program Name",percentage desc;


-- number and percentage for training_program_name_id in according with training_type
select count(*) as number,
	training_program_name as "Program Name",
	round(count(*)/sum(count(*)) over(partition by training_program_name),2) as percentage,
	training_type as "Training Type"
	from hr_department.training_program_name as tpn
	join hr_department.training_and_development as tad
	on tpn.training_program_id = tad.training_program_name_id
	group by  training_program_name, training_type
	order by "Program Name",percentage desc;


-- END of queries