-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
-- DROP PROCEDURE leftrighttCount IF EXISTS CASCADE;
DROP TYPE IF EXISTS country_count CASCADE;
DROP VIEW IF EXISTS r0_2 CASCADE;
DROP VIEW IF EXISTS r2_4 CASCADE;
DROP VIEW IF EXISTS r4_6 CASCADE;
DROP VIEW IF EXISTS r6_8 CASCADE;
DROP VIEW IF EXISTS r8_10 CASCADE;

/*CREATE TYPE country_count AS (countryName varchar(50), count int);
-- define composite type here for use in function output below
CREATE OR REPLACE FUNCTION "leftrightCount"(lower_bound REAL, upper_bound REAL) 
	RETURNS country_count  AS
	$$ BEGIN
	RETURN(
	SELECT (country.name, count(party.id))
	FROM
	country left join party
	on
	country.id = party.country_id	

	inner join party_position
	on
	party.id = party_position.party_id
	WHERE left_right >= lower_bound AND left_right < upper_bound
	GROUP BY country.name);
	END
	$$ LANGUAGE plpgsql;*/

CREATE VIEW r0_2 AS
	SELECT country.name, count(party.id)
        FROM
        country left join party
        on
        country.id = party.country_id   

        inner join party_position
        on
        party.id = party_position.party_id
        WHERE left_right >= 0.0 AND left_right < 2.0
        GROUP BY country.name;
CREATE VIEW r2_4 AS
        SELECT country.name, count(party.id) 
        FROM
        country left join party
        on
        country.id = party.country_id   

        inner join party_position
        on
        party.id = party_position.party_id
        WHERE left_right >= 2.0 AND left_right < 4.0
        GROUP BY country.name;
CREATE VIEW r4_6 AS
        SELECT country.name, count(party.id) 
        FROM
        country left join party
        on
        country.id = party.country_id   

        inner join party_position
        on
        party.id = party_position.party_id
        WHERE left_right >= 4.0 AND left_right < 6.0
        GROUP BY country.name;
CREATE VIEW r6_8 AS
        SELECT country.name, count(party.id) 
        FROM
        country left join party
        on
        country.id = party.country_id   

        inner join party_position
        on
        party.id = party_position.party_id
        WHERE left_right >= 6.0 AND left_right < 8.0
        GROUP BY country.name;
CREATE VIEW r8_10 AS
        SELECT country.name, count(party.id) 
        FROM
        country left join party
        on
        country.id = party.country_id   

        inner join party_position
        on
        party.id = party_position.party_id
        WHERE left_right >= 8.0 AND left_right < 10.0
        GROUP BY country.name;

-- returns countries and number of parties with left_right values between @lower_bound (inclusive) and @upper_bound (exclusive)

CREATE VIEW merged_views AS
	SELECT r0_2.name, r0_2.count count02, r2_4.count count24, r4_6.count count46, r6_8.count count68, r8_10.count count810
	FROM 
	r0_2 full join r2_4
	on r0_2.name = r2_4.name

	full join r4_6
	on r0_2.name = r4_6.name

	full join r6_8
	on r0_2.name = r6_8.name

	full join r8_10
	on r0_2.name = r8_10.name;

-- merges each of the previous views which contain counts for each individual bracket

-- the answer to the query 
--INSERT INTO q4 (countryName, r0_2) SELECT countryName, count from "leftrightCount"(0.0, 2.0);

INSERT INTO q4 (countryName, r0_2, r2_4, r4_6, r6_8, r8_10) SELECT * FROM merged_views;


