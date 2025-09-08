create table hr_department.department_type(
	department_id serial,
	department_name varchar(50)
);

create table hr_department.performance(
	performance_id serial,
	performance_score varchar(50)
);

create table hr_department.payzone_name(
	payzone_id serial,
	payzone_name varchar(50)
);

create table hr_department.termination_type(
	termination_type_id serial,
	termination_type varchar(50)
);


create table hr_department.employee_status(
	employee_status_id serial,
	employee_status_type varchar(50)
);

create table hr_department.employee_type (
	employee_type_id serial,
	employee_type varchar(50)
);


create table hr_department.training_program_name(
	training_program_id serial,
	training_program_name varchar(100)
);




