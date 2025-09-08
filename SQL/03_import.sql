-- import the main CSV tables:

\copy hr_department.employees FROM '../Data/employee_data.csv' CSV HEADER;

\copy hr_department.engagement_survey FROM '../Data/employee_engagement_survey_data.csv' CSV HEADER;

\copy hr_department.recruitment_data FROM '../Data/recruitment_data.csv' CSV HEADER;

\copy hr_department.training_and_development FROM '../Data/training_and_development_data.csv' CSV HEADER;








