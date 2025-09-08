-- Add primary key for the lookup tables:

--1. for department_type table
alter table hr_department.department_type 
	add constraint pk_depart_id primary key (department_id),
	add constraint uq_depart_name unique (department_name);

--2. for performance table
alter table hr_department.performance 
	add constraint pk_performance_id primary key (performance_id),
	add constraint uq_performance_score unique (performance_score);
--3. for payzone_name table
alter table hr_department.payzone_name 
	add constraint pk_payzone_id primary key (payzone_id),
	add constraint uq_payzone_name unique (payzone_name);

--4. for termination_type table
alter table hr_department.termination_type 
	add constraint pk_termination_t_id primary key (termination_type_id),
	add constraint uq_termination_t unique(termination_type);

--5. for employee_status table
alter table hr_department.employee_status 
	add constraint pk_emp_s_id primary key (employee_status_id),
	add constraint uq_emp_s_type unique (employee_status_type );

--6. for employee_type table
alter table hr_department.employee_type 
	add constraint pk_emp_t_id primary key (employee_type_id),
	add constraint uq_emp_t unique (employee_type);

--7. for training_program_name table
alter table hr_department.training_program_name  
	add constraint pk_training_pg_id primary key (training_program_id),
	add constraint uq_training_pg_n unique (training_program_name);


/* For employees table:
   1. startdate>=exitdata
   2. ademail to be unique
   3. empid primary key
   4. firstname not null
   5. gendercode('Male','Female','Other')
   6. racedesc ('Black','Hispanic','Asian','Other','White')
   7. maritaldesc('Widowed','Married','Divorced','Single')
   8. current_employee_rating (from 1 to 5)
   9. department_type_id needs forigen key references (department_type(department_id))
  10. performance_id needs forigen key references (performance(performance_id))
  11. termination_type_id needs forigen key references (termination_type(termination_type_id))
  12. employee_status_id needs forigen key references (employee_status(employee_status_id))
  13. employee_type_id needs forigen key references (employee_type(employee_type_id))
  14. payzone_name_id needs forigen key references (payzone_name(payzone_id))
*/



alter table  hr_department.employees 
	--1.
	add constraint ck_start_and_exit_date check (startdate <= exitdate),
	--2.
	add constraint uq_ademail unique (ademail),
	--3.
	add constraint pk_empid primary key (empid),
	--4.
	alter column firstname set not null,
	--5.
	add constraint ck_gendercode check (gendercode in ('Male','Female','Other')),
	--6.
	add constraint ck_racedesc check (racedesc in ('Black','Hispanic','Asian','Other','White')),
	--7.
	add constraint ck_martialdesc check (maritaldesc in ('Widowed','Married','Divorced','Single')),
	--8.
	add constraint ck_emp_rating check (current_employee_rating between 1 and 5),
	--9.
	add constraint fk_department_id foreign key (department_type_id) references hr_department.department_type(department_id),
	--10.
	add constraint fk_performance_id foreign key (performance_id) references  hr_department.performance(performance_id),
	--11.
	add constraint fk_termination_id foreign key (termination_type_id) references hr_department.termination_type(termination_type_id),
	--12.
	add constraint fk_employee_s_id foreign key (employee_status_id) references hr_department.employee_status(employee_status_id),
	--13.
	add constraint fk_employee_t_id foreign key (employee_type_id) references hr_department.employee_type(employee_type_id),
	--14.
	add constraint fk_payzone_id foreign key (payzone_name_id) references hr_department.payzone_name(payzone_id);
	

/*
For engagement_survey:
	1. putting for the employee_id a foreign key that references the empid in employees
	2. Limit engagement_score to the range 1 to 5
	3. Limit satisfaction_score to the range 1 to 5
	4. Limit work_life_balance_score to the range 1 to 5
*/


alter table hr_department.engagement_survey
	add constraint fk_employee_id_es foreign key (employee_id) references hr_department.employees(empid),
	add constraint ck_engagement_sc check (engagement_score between 1 and 5),
	add constraint ck_satisfaction_sc check (satisfaction_score between 1 and 5),
	add constraint ck_wlb_sc check (work_life_balance_score between 1 and 5);

/* 
	For the recruitment_data table:
	1. Making the applicant_id primary key
	2. first_name should not be null
	3. limit gender to the ('Male','Female','Other')
	4. phone_number should be unique
	5. Email should be unique
	6. limit education_level to the ('High School','Bachelor's Degree','Master's Degree','PhD') 
	7. Put a constraint that the number of years_of_experience can't be more than the age 
	8. limit status to the ('Rejected','Interviewing','Applied','In Review','Offered')
*/
alter table hr_department.recruitment_data
	--1.
	add constraint pk_applicant_id_rec primary key (applicant_id),
	--2.
	alter column first_name set not null,
	--3.
	add constraint ck_gender_rec check (gender in ('Male','Female','Other')),
	--4.
	add constraint uq_phone_n_rec unique (phone_number),
	--5.
	add constraint uq_email_rec unique (email),
	--6.
	add constraint ck_edu_level_rec check (education_level in ('High School','Bachelor''s Degree','Master''s Degree','PhD')),
	--7.
	add constraint ck_num_exp_rec check (extract(year from Age(date_of_birth)) - 16 > years_of_experience ),
	--8.
	add constraint ck_status_rec check (status in ('Rejected','Interviewing','Applied','In Review','Offered'));
 


/* for the training_and_development table:
	1. putting for the employee_id a foreign key that references the empid in employees
	2. putting  for the training_program_name_id a foreign key that references the training_program_id in training_program_name table
	3. Limit training_type to ('Internal','External')
	4. Limit training_outcome to ('Incomplete','Failed','Completed','Passed')
*/

alter table hr_department.training_and_development
	--1.
	add constraint fk_emp_id_tad foreign key (employee_id) references hr_department.employees(empid),
	--2.
	add constraint fk_program_name foreign key (training_program_name_id) references hr_department.training_program_name(training_program_id),
	--3.
	add constraint ck_training_type_tad check (training_type in ('Internal','External')),
	--4.
	add constraint ck_training_outcome_tad check (training_outcome in ('Incomplete','Failed','Completed','Passed'));

