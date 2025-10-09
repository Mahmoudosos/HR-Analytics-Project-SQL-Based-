/*
CONTACTS:

1. Clean the tables:
2. Add the data to the lookup_tables
3. Replace the columns in the main tables with ID's columns
4. Make sure that there's no employee on the training_and_development table and engagement_survey is not on the employees table
5. add age column to employees table
*/


-- # 1. Clean the tables:

-- A function to see the duplicated rows:

CREATE FUNCTION see_duplicates (schema_name TEXT,table_name TEXT,column_name TEXT)
RETURNS SETOF RECORD
AS $$ 
	DECLARE r TEXT;
	BEGIN
		r := FORMAT('select %I from(select *, ROW_NUMBER() over (partition by %I) as n_duplicated from %I.%I) where n_duplicated>1'
		,column_name,column_name,schema_name,table_name);
	RETURN QUERY EXECUTE r;
	END;
$$LANGUAGE plpgsql;

-- A function to remove the duplicated rows:

CREATE or REPLACE FUNCTION delete_duplicated (schema_name TEXT,table_name TEXT,column_name TEXT)
RETURNS int
AS $$
	DECLARE r TEXT;
			deleted_count int;
	BEGIN
	r:= format(
		'WITH cte_1 AS (SELECT ctid,ROW_NUMBER() OVER (PARTITION BY %I) as row_number FROM %I.%I) 
		DELETE FROM %I.%I
		USING cte_1
		WHERE cte_1.ctid = %I.%I.ctid AND cte_1.row_number>1;',column_name,schema_name,table_name,schema_name,table_name,schema_name,table_name);
	EXECUTE r;
	GET DIAGNOSTICS deleted_count = ROW_COUNT;
	RETURN deleted_count ;
	END;
$$ LANGUAGE plpgsql;

/*
## For employees:
 		1. Start date can't be more than the exit date
		2. Update any employee that have 60 years or more and is still active to 'Voluntarily Terminated'
 		3. Review the duplicated data, then decide if deleting each of:
			- empid
			- ademail
*/

--1:

delete from hr_department.employees where startdate > exitdate;

--2:

UPDATE hr_department.employees SET employeestatus = 'Voluntarily Terminated' WHERE EXTRACT(YEAR FROM AGE(dob))>=60 AND employeestatus = 'Active';

--3:
-- for empid:
SELECT * FROM see_duplicates('hr_department','employees','empid') as t(empid int);
	-- Since there are no duplicates, there's no need to call the remove function

-- for ademail

SELECT * from see_duplicates ('hr_department','employees','ademail') as t(ademail text);
-- there are just 2 duplicated e-mails, therefore we can delete it.
SELECT delete_duplicated('hr_department','employees','ademail');




/*
## For recruitment_data table:
 		1. review the duplicated data then decide if deleting each of:
			- applicant_id
			- phone_number
			- email
*/

-- 1. 
	-- for applicant_id
SELECT * FROM see_duplicates ('hr_department','recruitment_data','applicant_id') as t(applicant_id int);
	-- there are no duplicates

-- 2. 
	-- for phone_number
SELECT * FROM see_duplicates ('hr_department','recruitment_data','phone_number') AS t(phone_number text);
	--since the duplicated data is a set of '####'. Then we should reassign these '####' into NULL (These are placeholder invalid values, so we treat them as missing data (NULL).) 
Update hr_department.recruitment_data SET phone_number = NULL 
	WHERE phone_number = '###############################################################################################################################################################################################################################################################';

-- 3.
	--for email
SELECT * FROM see_duplicates ('hr_department','recruitment_data','email') as t(email text);
	-- There are no duplicates

/*
## For engagement_survey table:
 		1. Review the duplicated data, then decide if deleting each of:
			- employee_id
*/

-- 1.
	-- for employee_id
SELECT * FROM see_duplicates ('hr_department','engagement_survey','employee_id') AS t(employee_id integer);
	-- There are no duplicates

/*
## For training_and_development table:
 		1. Review the duplicated data, then decide if deleting each of:
			- employee_id
*/

-- 1.
	-- for employee_id
SELECT * FROM see_duplicates ('hr_department','training_and_development','employee_id') AS t(employee_id integer);
	-- There are no duplicates



-- # 2. Add the data to the lookup_tables

-- for department_type
insert into hr_department.department_type(department_name) select distinct DepartmentType From hr_department.employees on conflict (department_name) do nothing;

-- for performance
insert into hr_department.performance(performance_score) select distinct performance_score from hr_department.employees on conflict (performance_score) do nothing;

-- for payzone_name
insert into hr_department.payzone_name(payzone_name) select distinct payzone from hr_department.employees on conflict (payzone_name) do nothing;

-- for termination_type
insert into hr_department.termination_type(termination_type) select distinct terminationtype from hr_department.employees on conflict (termination_type) do nothing;

-- for employee_status
insert into hr_department.employee_status(employee_status_type) select distinct employeestatus from hr_department.employees on conflict (employee_status_type) do nothing;

-- for employee_type
insert into hr_department.employee_type(employee_type) select distinct employeetype from hr_department.employees on conflict (employee_type) do nothing;

-- for training_program_name
insert into hr_department.training_program_name(training_program_name) select distinct training_program_name from hr_department.training_and_development on conflict (training_program_name) do nothing;



-- # 3. Replace the columns in the main tables with ID' columns

-- Build a function to do so:
CREATE or REPLACE FUNCTION give_id_and_remove_names(schema_main_name text,main_table text,main_column text,schema_look_name text,look_table text,look_column text,look_id text)
	RETURNS void
	AS $$
	Declare 
	column_name text;
	add_column_name text;
	i text;
	update_statement text;

	BEGIN
		-- add the column_id
	column_name:= Format('%I_id',look_table);
	add_column_name:= FORMAT ('alter table %I.%I add column if not exists %I integer',schema_main_name,main_table,column_name);
	EXECUTE add_column_name;

		-- insert ids inside the column_id
	update_statement := format('Update %I.%I as main set %I = look.%I from %I.%I as look where main.%I = look.%I;',schema_main_name,main_table,column_name,look_id,schema_look_name,look_table,main_column,look_column);
	Execute update_statement;

		-- drop the name_column in the main_table 
EXECUTE FORMAT('alter table %I.%I drop column if exists %I',schema_main_name,main_table,main_column);
	end;
		$$ language plpgsql;

-- # Start applying the function on the lookup_tables:

--1. For department_type table
SELECT give_id_and_remove_names('hr_department','employees','departmenttype','hr_department','department_type','department_name','department_id');

--2. For performance table
SELECT give_id_and_remove_names('hr_department','employees','performance_score','hr_department','performance','performance_score','performance_id');

--3. For payzone_name table
SELECT give_id_and_remove_names('hr_department','employees','payzone','hr_department','payzone_name','payzone_name','payzone_id');

--4. For termination_type table
SELECT give_id_and_remove_names('hr_department','employees','terminationtype','hr_department','termination_type','termination_type','termination_type_id');

--5. For employee_status table
SELECT give_id_and_remove_names('hr_department','employees','employeestatus','hr_department','employee_status','employee_status_type','employee_status_id');

--6. For employee_type table
SELECT give_id_and_remove_names('hr_department','employees','employeetype','hr_department','employee_type','employee_type','employee_type_id');


--7. For training_program_name table
SELECT give_id_and_remove_names('hr_department','training_and_development','training_program_name','hr_department','training_program_name','training_program_name','training_program_id');


	
-- ## 4.
		--1. Delete any employee_id in the training_and_development table and not in the employees table:
delete from hr_department.training_and_development as t where not exists (
	select * from hr_department.employees e
	where t.employee_id = e.empid);

		--2. Delete any employee_id in the engagement_survey table and not in the employees table:
delete from hr_department.engagement_survey as s where not exists (
	select * from hr_department.employees e
	where s.employee_id = e.empid
);

-- # 5- Add the age column
alter table hr_department.employees add column age integer;
update hr_department.employees set age = extract(year from age(dob));












