
--
-- @StudentID: *****
--
--
-- Designed for PostgreSQL with PostGIS

-- Enable PostGIS in the current DB
CREATE EXTENSION IF NOT EXISTS POSTGIS;

--------------------------------------------------------------------------------------
-- Existing 5 table samples limit 10, to explore data and columns
--------------------------------------------------------------------------------------

select * from university_applicants limit 10;

select * from ethnic limit 10;

select * from occupation_type limit 10;

select * from uk_lad limit 10;

select * from english_regions limit 10;

--------------------------------------------------------------------------------------
-- Creating spatial indexes for columns with spatial elements & data
--------------------------------------------------------------------------------------

create index PCODE_idx on university_applicants(PCODE);

create index Easting_idx on university_applicants(Easting);

create index Northing_idx on university_applicants(Northing);

create index GEO_CODE_idx on occupation_type(GEO_CODE);

create index GEO_LABEL_idx on occupation_type(GEO_LABEL);

create index GEO_CODE_idxx on ethnic(GEO_CODE);

create index GEO_LABEL_idxx on ethnic(GEO_LABEL);

create index LAD_boundaries_idx on uk_lad using GIST (geom); 

create index English_Regions_boundaries_idx on english_regions using GIST (geom); 

select * from pg_indexes where tablename not like 'pg%'; -- checking indexes exist once done

-------------------------------------------------------------------------------
-- What is the percentage of applicants by ethnic group--
--------------------------------------------------------------------------------
-- Preparing the query - calculating total and each ethnic group separately

select count(ethnicgroup) from university_applicants ; ----- 39,240 total

select count(ethnicgroup) as White from university_applicants ---- 7,248 total
where ethnicgroup = 'White'
group by ethnicgroup;

select count(ethnicgroup) as Mixed from university_applicants ---- 763 total
where ethnicgroup = 'Mixed'
group by ethnicgroup;

select count(ethnicgroup) as Asian_AsianBritish from university_applicants ---- 3,059 total
where ethnicgroup = 'AorAB'
group by ethnicgroup;

select count(ethnicgroup) as Black_BlackBritish from university_applicants ---- 4,076 total
where ethnicgroup = 'BorBB'
group by ethnicgroup;

select count(ethnicgroup) as Chinese_or_Other from university_applicants ---- 620 total
where ethnicgroup = 'CorOEB'
group by ethnicgroup;

select count(ethnicgroup) as NotKnown from university_applicants ---- 23,340 total
where ethnicgroup = 'NotKnown'
group by ethnicgroup;

select (select count(ethnicgroup) from university_applicants ---- 7,248 total
where ethnicgroup = 'White'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as White_Percent;

-- Putting the query together to calculate percentages of each ethnic group in university_applications
-- Results: White 18 %, Mixed 1 %, Asian 7 %, Black 10 %, Chinese or Other 1 %, Not Known 59 %

select (select count(ethnicgroup) from university_applicants 
where ethnicgroup = 'White'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as White_Percent, (select count(ethnicgroup) from university_applicants 
where ethnicgroup = 'Mixed'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as Mixed_Percent,(select count(ethnicgroup) from university_applicants 
where ethnicgroup = 'AorAB'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as Asian_AsianBritish_Percent, (select count(ethnicgroup) from university_applicants 
where ethnicgroup = 'BorBB'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as Black_BlackBritish_Percent, (select count(ethnicgroup) from university_applicants 
where ethnicgroup = 'CorOEB'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as Chinese_or_Other_Percent, (select count(ethnicgroup) from university_applicants 
where ethnicgroup = 'NotKnown'
group by ethnicgroup) * 100 / (select count(ethnicgroup) from university_applicants)
as NotKnown_Percent
;

--------------------------------------------------------------------------------------
-- What is the number of female applicants with qualification "A / AS level"
--------------------------------------------------------------------------------------
-- Results were also calculated for male and total

select (select count(SEX) from university_applicants where SEX = 'F' --- 6079 female applicants with A level
and PostConfActualQual =  'A/AS level' group by SEX)
as Female_A_Level;

select (select count(SEX) from university_applicants where SEX = 'M' --- 4090 male applicants with A level
and PostConfActualQual =  'A/AS level' group by SEX)
as Male_A_Level;

select (select count(PostConfActualQual) from university_applicants  --- 10169 all applicants with A level
where PostConfActualQual= 'A/AS level' group by PostConfActualQual)
as All_A_Level;

--------------------------------------------------------------------------------------
-- What are the 10 LADs with highest number of applicants (include the region and limit to 10)
--------------------------------------------------------------------------------------
--- Results: 1.Greenwich (2243), 2.Newham (1953), 3.Lewisham (1659), 4.Bexley (1452), 5.Tower Hamlets (1414)
--- 6.Southwark (1314), 7.Croydon (1310), 8.Redbridge (1239), 9.Medway (1191), 10. Bromley (1098).


-- as initial uni applicants table does not have geometry type, adding a geom column
ALTER TABLE university_applicants ADD COLUMN geom geometry(POINT,27700); 


-- creating a point / location for applicants from Easting /  Northing columns
UPDATE university_applicants
set geom = ST_GeomFromText('POINT(' || university_applicants."easting" ||' '|| university_applicants."northing" || ')',27700);

--- calculate LADs and number of applicants in them limit to 10 highest
--- Top ten result: Greenwich, Newham, Lewisham, Bexley, Tower Hamlets,
--- and Southwark, Croydon, Redbridge, Medway Bromley

select k.geo_label, COUNT(u.geom) as total_applicants --- 1st version
FROM university_applicants as u, uk_lad as k
WHERE ST_Contains(k.geom,u.geom)
GROUP BY k.geom,k.geo_label
order by total_applicants desc
limit 10;

select k.geo_label, COUNT(u.geom) as total_applicants --- 2nd version with Join via Geometry
FROM university_applicants as u
join uk_lad as k
On ST_Contains(k.geom,u.geom)
GROUP BY k.geom,k.geo_label
order by total_applicants desc
limit 10;

--------------------------------------------------------------------------------------
-- Applications by gender in 9x English regions 
--------------------------------------------------------------------------------------
---- Results Table returned with all applications by gender in the regions, with London the highest in all – 24,936
--- with female applicants – 14,921, and male applicants – 10,006.
--- All regions have more female applicants.

SELECT e.geo_label as English_region, COUNT(e.geom) as all_applicants,
       COUNT(u.geom) FILTER (WHERE u.SEX LIKE '%F%') AS F_applicants,
       COUNT(u.geom) FILTER (WHERE u.SEX LIKE '%M%') AS M_applicants
FROM   university_applicants as u
join english_regions as e
ON ST_Contains(e.geom,u.geom)
GROUP BY e.geom, e.geo_label 
order by all_applicants;

--------------------------------------------------------------------------------------
-- LADs with more than 500 applicants 
--------------------------------------------------------------------------------------
-- 19 LADs with > 500 applicants.
-- Used same idea as in the question with 10 LADs with higheste number of applicants
-- Table returned with all LAD’s that had more than 500 applicants
-- in 19 LADs in total, with Greenwich, Newham and Lewisham at the top. 
-- In addition using COUNT function with HAVING clause

select k.geo_label, k.geom, COUNT(u.geom) as total_applicants
FROM university_applicants as u
join uk_lad as k
On ST_Contains(k.geom,u.geom)
GROUP BY k.geom,k.geo_label
having count(u.geom) > 500
order by total_applicants desc;

--------------------------------------------------------------------------------------
-- How many male applicants not from London region
--------------------------------------------------------------------------------------
-- Table returned with all male applicants in each region excluding London,
-- with South East (2638) and East of England (1323) at the top. 

SELECT e.geo_label as English_region,
       COUNT(u.geom) FILTER (WHERE u.SEX LIKE '%M%' and e.geo_label != 'London')
       AS M_applicants_except_LDN
       FROM   university_applicants as u
join english_regions as e
ON ST_Contains(e.geom,u.geom)
GROUP BY e.geo_label, e.geom
having count(u.geom) FILTER (WHERE u.SEX LIKE '%M%' and e.geo_label != 'London') > 0 --- hiding London row
order by M_applicants_except_LDN desc;

       
 -- End of File --