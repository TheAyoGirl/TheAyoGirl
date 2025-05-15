create database HumanResource;
use humanresource;
select * from hr;
-- Data cleaning
-- a. changing the id column name
alter table hr
change column ï»¿id emp_id varchar(20) null;
-- b. Descriptive statistics
describe hr;
-- c. convert birthdate type from text to date
alter table hr
modify column birthdate date;
select birthdate from hr;
set sql_safe_updates=0;
update hr
set birthdate = case
when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
else null
end;
-- d. convert hire_date type from text to date
update hr
set hire_date = case
when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
else null
end;
alter table hr
modify column hire_date date;
-- d. convert term_date type from text to date
UPDATE hr SET termdate = NULL WHERE termdate = '';
update hr set termdate = date(str_to_date(termdate, '%Y-%m-%d'))
where termdate is not null and termdate <> '';
alter table hr
modify column termdate date;
select termdate from hr;

-- adding a age column
alter table hr add column age int;
update hr set age = timestampdiff(Year,birthdate, curdate());
select birthdate, age from hr;
-- finding outliers in our data
select min(age) as youngest, max(age) as oldest from hr;
select count(*) from hr where age < 18;

-- QUESTIONS
-- 1. wHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN THE COMPANY?
select gender, count(*) as count from hr
where age >=18 and termdate is null
group by gender;
-- 2. wHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY
select race, count(*) as count from hr
where age >= 18 and termdate is null
group by race
order by count desc;
-- 3. What is the age distribution of employees in the company 
select min(age) as youngest, max(age) as oldest from hr
where age >= 18 and termdate is null;
select 
case 
	when age >= 18 and age <= 24 then '18-24'
    when age >= 25 and age <= 34 then '25-34'
    when age >= 35 and age <= 44 then '35-44'
    when age >= 45 and age <= 54 then '45-54'
    when age >= 55 and age <= 64 then '55-64'
    else '65+'
    end as age_group,
count(*) as count from hr
where age >= 18 and termdate is null
group by age_group
order by age_group;
-- q3 continued...
select 
case 
	when age >= 18 and age <= 24 then '18-24'
    when age >= 25 and age <= 34 then '25-34'
    when age >= 35 and age <= 44 then '35-44'
    when age >= 45 and age <= 54 then '45-54'
    when age >= 55 and age <= 64 then '55-64'
    else '65+'
    end as age_group,
gender, count(*) as count from hr
where age >= 18 and termdate is null
group by age_group, gender
order by age_group, gender;
-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count from hr
where age >= 18 and termdate is null
group by location;
-- 5. what is the average length of employment for employees who have bem terminated
select round(avg(datediff(termdate, hire_date))/365,0) as avg_employment from hr
where termdate <= curdate() and termdate is not null and age >= 18;
-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count from hr
where age >= 18 and termdate is null
group by department, gender
order by department;
-- 7. What is the distribution of job title across the company
select jobtitle, count(*) as count from hr
where age >= 18 and termdate is null
group by jobtitle
order by jobtitle desc;
-- 8. Which department has the highest turnover rate?(how long employees stay before they leave the company)
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from(
select department, count(*) as total_count,
sum(case when termdate is not null and termdate <=curdate() then 1 else 0 end) as terminated_count
from hr
where age >= 18
group by department) as subquery
order by termination_rate;
-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as count from hr
where age >= 18 and termdate is null
group by location_state
order by count desc;
-- 10. How has the company's employee count changed over time based on hire and term dates?
select year, hires, termination, 
	hires- termination as net_change, 
	round((hires - termination)/hires * 100,2) as net_change_percent
from(
select YEAR(hire_date) as year,
count(*) as hires,
sum(case when termdate is not null and termdate<= curdate() then 1 else 0 end) as termination
from hr
where age >= 18
group by year
) as subquery
order by year asc;

-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date))/365,0) as avg_tenure
from hr
where termdate <= curdate() and termdate is not null and age >= 18
group by department;