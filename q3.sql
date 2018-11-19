-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS elections_in_range_unaveraged CASCADE;
DROP VIEW IF EXISTS ptcp_ratios CASCADE;
DROP VIEW IF EXISTS disobeying_countries CASCADE;
DROP VIEW IF EXISTS obeying_countries CASCADE;


-- Define views for your intermediate steps here.

CREATE VIEW elections_in_range_unaveraged AS
SELECT id election_id, country_id, extract(year FROM e_date)::int yr, CAST(votes_cast AS float) / CAST(electorate AS float) ptcp_ratio
FROM election e1
WHERE extract(year FROM e_date)::int >= 2001 AND extract(year FROM e_date)::int <= 2016;

-- returns elections between 2001 and 2016 inclusive and their corresponding countries as well as their participation ratio

CREATE VIEW ptcp_ratios AS
	SELECT country_id, yr, AVG(ptcp_ratio) avg_ptcp 
	FROM elections_in_range_unaveraged 
	GROUP BY country_id, yr
	HAVING AVG(ptcp_ratio) IS NOT NULL
	ORDER BY country_id;
-- returns average participation ratios for years between 2001-2016 for countries who have had at least one election for years that the countries had an election

CREATE VIEW disobeying_countries AS
	SELECT DISTINCT pr1.country_id
	FROM ptcp_ratios pr1 cross join ptcp_ratios pr2
	WHERE pr1.country_id = pr2.country_id AND pr1.yr < pr2.yr AND pr1.avg_ptcp > pr2.avg_ptcp;
-- returns country ids of countries that do not obey to ascending ratio by year rule

CREATE VIEW obeying_countries AS
	SELECT  country_id
	FROM (
		SELECT DISTINCT pr.country_id
		FROM ptcp_ratios pr
	) all_cid
	EXCEPT
	(
		SELECT dc.country_id
		FROM disobeying_countries dc
	);
-- returns country ids of countries that obey ascending ratio by year rule

CREATE TABLE years_in_range(
	year INT PRIMARY KEY
	);

INSERT INTO years_in_range(year) VALUES (2001);
INSERT INTO years_in_range(year) VALUES (2002);
INSERT INTO years_in_range(year) VALUES (2003);
INSERT INTO years_in_range(year) VALUES (2004);
INSERT INTO years_in_range(year) VALUES (2005);
INSERT INTO years_in_range(year) VALUES (2006);
INSERT INTO years_in_range(year) VALUES (2007);
INSERT INTO years_in_range(year) VALUES (2008);
INSERT INTO years_in_range(year) VALUES (2009);
INSERT INTO years_in_range(year) VALUES (2010);
INSERT INTO years_in_range(year) VALUES (2011);
INSERT INTO years_in_range(year) VALUES (2012);
INSERT INTO years_in_range(year) VALUES (2013);
INSERT INTO years_in_range(year) VALUES (2014);
INSERT INTO years_in_range(year) VALUES (2015);
INSERT INTO years_in_range(year) VALUES (2016);



-- the answer to the query 
CREATE VIEW country_year_combos_ptcp AS
SELECT sq1.name, sq1.id, sq1.year, ptcp_ratios.avg_ptcp
FROM ptcp_ratios
inner join country 
on country.id = ptcp_ratios.country_id

right join (SELECT country.name, years_in_range.year, country.id FROM years_in_range CROSS JOIN country) sq1 
on sq1.year = ptcp_ratios.yr AND sq1.name = country.name 
ORDER BY sq1.name, sq1.year;
-- returns participation ratio of all countries for all years between 2001 and 2016

INSERT INTO q3 (countryName , year, participationRatio) 
SELECT r1.name, r1.year, r1.avg_ptcp
FROM country_year_combos_ptcp r1 inner join obeying_countries on r1.id = obeying_countries.country_id;
-- filters out disobeying countries from country_year_combos_ptcp
