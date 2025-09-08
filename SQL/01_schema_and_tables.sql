-- 01. Create schema:

create schema hr_department;


-- 02. Create tables:
create table hr_department.employees (
  EmpID Serial,
  FirstName text,
  LastName text,
  StartDate Date,
  ExitDate Date,
  Title text,
  Supervisor text,
  ADEmail Text ,
  BusinessUnit text,
  EmployeeStatus text,
  EmployeeType text ,
  PayZone text, 
  EmployeeClassificationType text,  
  TerminationType text,
  TerminationDescription Text,
  DepartmentType text,
  Division text,
  DOB Date,
  State text,
  JobFunctionDescription text,
  GenderCode text ,
  LocationCode text,
  RaceDesc text ,
  MaritalDesc text ,
  Performance_Score text  ,
  Current_Employee_Rating int 
);


create table hr_department.engagement_survey(
  Employee_ID serial,
  Survey_Date date,
  Engagement_Score int,
  Satisfaction_Score int,
  Work_Life_Balance_Score float
);

create table hr_department.recruitment_data(
  Applicant_ID serial,
  Application_Date Date,
  First_Name text,
  Last_Name text,
  Gender text,
  Date_of_Birth date,
  Phone_Number text,
  Email text,
  Address text,
  City text ,
  State text,
  Zip_Code text ,
  Country text,
  Education_Level text,
  Years_of_Experience int,
  Desired_Salary float,
  Job_Title text,
  Status text
);

create table hr_department.training_and_development(
  Employee_ID serial,
  Training_Date date,
  Training_Program_Name text,
  Training_Type text ,
  Training_Outcome text,
  Location text,
  Trainer text,
  Training_Duration_Days int,
  Training_Cost float
);