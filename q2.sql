-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_winningvotes CASCADE;
DROP VIEW IF EXISTS winningparties CASCADE;
DROP VIEW IF EXISTS wincount CASCADE;
DROP VIEW IF EXISTS dominant_parties CASCADE;
DROP VIEW IF EXISTS most_recent_won_elec CASCADE;

-- Define views for your intermediate steps here.

-- schema instance notes (debugging purposes):
-- 215 parties
-- 158 elections

CREATE VIEW election_winningvotes AS
SELECT election_id, max(votes) maxvotes
FROM election_result 
GROUP BY election_id;
-- returns the number of votes scored by winning party for each election and the corresponding election id

CREATE VIEW winningparties AS
SELECT election_winningvotes.election_id, party_id, election.e_date
FROM election_winningvotes 
inner join election_result 
on election_winningvotes.election_id = election_result.election_id 
and election_winningvotes.maxvotes = election_result.votes

inner join election
on election_winningvotes.election_id = election.id
ORDER BY election_winningvotes.election_id;
-- returns party id and election id, election date for every election it has won
-- the above two views can be combined using subquery. This is a "greatest-n-per-group" problem
-- The row with the greatest value of a certain attribute (votes) and more than one non aggregated attribute is needed.

CREATE VIEW wincount as
SELECT party_id, count(party_id) wincount
FROM winningparties
GROUP BY party_id;
-- returns party_ids and their respective number of election wins
-- select sum(wincount) from wincount; should return total number of elections

CREATE VIEW dominant_parties as
SELECT c1.name cname, wc1.party_id, p1.name pname, party_family.family, coalesce(wc1.wincount, 0) wincount
FROM wincount wc1
right join party p1
on wc1.party_id = p1.id 

left join party_family 
on p1.id = party_family.party_id

inner join country c1
on p1.country_id = c1.id 

WHERE wc1.wincount >	
		(
		SELECT 3*AVG(coalesce(wincount.wincount, 0)) 
		FROM wincount right join party on wincount.party_id = party.id inner join country on party.country_id = country.id	
		-- above: we want to include parties that never won as well, so we include right join on party and                    --coalesce all NULL values for wincount
		WHERE c1.id = country.id
		GROUP BY country.id
		);
-- returns country, party name, party family and number of election wins for all
-- parties that have won more than 3 times the average won number of elections for their respective countries.

CREATE VIEW most_recent_won_elec as
SELECT wp1.party_id, wp1.election_id, extract(year FROM wp1.e_date)::int yr
FROM winningparties wp1
	inner join(
	SELECT party_id, max(e_date) most_recent_date
	FROM winningparties	
	GROUP BY party_id 
	)  wp2
	on wp1.party_id = wp2.party_id and wp1.e_date = wp2.most_recent_date;
-- returns the most recently won election and year out of parties who have won elections
-- another "greatest-n-per-group" where election id is also needed on top of the grouped by party_id and aggregated date

-- the answer to the query
INSERT into q2 (countryName,partyName,partyFamily,wonElections,mostRecentlyWonElectionId,mostRecentlyWonElectionYear)
	SELECT dp.cname countryName, dp.pname partyName, dp.family partyFamily, dp.wincount wonElections, mrwe.election_id mostRecentlyWonElectionId, mrwe.yr mostRecentlyWonElectionYear  
	FROM most_recent_won_elec mrwe
	inner join
	dominant_parties dp
	on mrwe.party_id = dp.party_id;





