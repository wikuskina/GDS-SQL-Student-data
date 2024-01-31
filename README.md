# SQL Queries on the existing “studentdb” database

A database “studentdb” was used to run queries. It contains data about university applications from *** year, and socio-demographic information about the UK.<br>

To note, I needed to examine spatial and non-spatial data. As initial _university_applicants_ table in the database did not have a geometry type, a column was added. A “Point” was created using applicants’ data from _Easting and Northing_ columns. <br>

The results: There were 39,240 applicants in the past year, 23,559 female and 15,669 male. It is noticeable there were more female applicants across locations in the UK. Majority of the applicants (38,500) paid “home fees” and got via the Main Cycle of applications (38,108), and went to study full-time (36,331).
Students’ ethnicity was mostly undisclosed (Not Known - 59 %). However, it can be assumed that majority of applicants were White - 18 % of disclosed data, Black - 10 %, and Asian - 7 %.  According to the ethnic table, UK population is 55,845,312, where 48,209,395 are White, 1,864,890 are Black, 3,820,390 are Asian, making them the top three ethnicities. These ethnicities are represented similarly in the university_applicants, with the difference of more applicants from Black ethnicities in comparison to Asian ethnicities.<br>

Majority of applicants were from London region (24,936), followed by South East (7,085) and East of England (3,276), with the top LAD’s as Greenwich (2243), Newham (1953), Lewisham (1659), Bexley (1452), and Tower Hamlets (1414).<br>

