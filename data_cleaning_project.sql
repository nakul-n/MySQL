-- data cleaning 


create table layoffs_staging
like layoffs;

insert layoffs_staging
select *
from layoffs;

-- identify duplicates

select * ,
row_number() over(
partition by company,industry,total_laid_off,percentage_laid_off,'date') as row_num
from layoffs_staging;

with duplicate_cte as
(
select * ,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num>1;

-- creating new table to delete the duplicates, copy table create statement 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select * ,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging;

select *
from layoffs_staging2;

delete 
from layoffs_staging2
where row_num>1;


-- standardizing data 

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct(country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- changing date column from text to time series

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select *
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` DATE;


-- null and blank values

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';


select *
from layoffs_staging2
where company = 'Airbnb';

update layoffs_staging2
set industry = 'Travel'
where company = 'Airbnb' ;

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
    and t1.location=t2.location
where (t1.industry is null or t1.industry='')
and t2.industry is not null ;

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry=t2.industry
where (t1.industry is null or t1.industry='')
and t2.industry is not null ;

-- remove columns or rows that are not needed

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- drop column
alter table layoffs_staging2
drop column row_num;

select*
from layoffs_staging2;

-- remove duplicates
-- standardise data
-- null values and blank valus\
-- remove rows and columns










