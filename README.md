# SQL Queries on the “studentdb” database
## Data Science exercise
### Author Viktorija S 2023

For this exercise, an existing database “studentdb” was used to run various queries. The database contains data about university applications in the UK from a sample year, including their socio-demographic information.<br>

Spatial and non-spatial data was examined. As initial _university_applicants_ table in the database did not have a geometry type (which was needed in order to answer all necessary queries in relation to their location), so a new column was added. A “Point” was created using applicants’ data from _Easting and Northing_ columns. <br>

### Example of queries
select (select count(SEX) from university_applicants where SEX = 'F' <br>
and PostConfActualQual =  'A/AS level' group by SEX) <br>
as Female_A_Level; <br>
RESULT: 6079 female applicants with A level <br> <br>
select k.geo_label, k.geom, COUNT(u.geom) as total_applicants <br>
FROM university_applicants as u <br>
join uk_lad as k <br>
On ST_Contains(k.geom,u.geom) <br>
GROUP BY k.geom,k.geo_label <br>
having count(u.geom) > 500 <br>
order by total_applicants desc; <br>
RESULT: Table returned with all LAD’s that had more than 500 applicants in 19 LADs in total, with Greenwich, Newham and Lewisham at the top.  <br> <br>

### The results of queries:
There were 39,240 applicants in this sample database, 23,559 female and 15,669 male (more female applicants across all locations in the UK). Majority of the applicants (38,500) paid “home fees” and got via the Main Cycle of applications (38,108), and went to study full-time (36,331). <br>
Students’ ethnicity was mostly undisclosed (Not Known - 59 %). However, it can be assumed that majority of applicants were White - 18 % of disclosed data, Black - 10 %, and Asian - 7 %.  According to the ethnic table, UK population is 55,845,312, where 48,209,395 are White, 1,864,890 are Black, 3,820,390 are Asian, making them the top three ethnicities. These ethnicities are represented similarly in the university_applicants, with the difference of more applicants from Black ethnicities in comparison to Asian ethnicities.<br>
Majority of applicants were from London region (24,936), followed by South East (7,085) and East of England (3,276), with the top LAD’s as Greenwich (2243), Newham (1953), Lewisham (1659), Bexley (1452), and Tower Hamlets (1414).<br>

