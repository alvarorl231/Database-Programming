// USEFUL COMMANDS
// NEO4J

// CREATE A RECORD
CREATE (JFK:Airport { name:'JF Kennedy Airport', city:'New York' }) ,
       (AUS:Airport { name:'Austin-Bergstrom International', city:'Austin' })

CREATE (flight1:Flight { flight_number:'BG45',month:'August' })

// CREATE RELATIONSHIPS
MATCH (JFK:Airport { name:'JF Kennedy Airport'})
MATCH (AUS:Airport { name:'Austin-Bergstrom International'})
MATCH (flight1:Flight { flight_number:'BG45'})
CREATE (flight1)-[:ORIGIN]->(JFK),
       (flight1)-[:DESTINATION]->(AUS)

// DELETE ALL NODES FROM THE DATABASE
MATCH (n) DETACH DELETE n;

// RETRIEVE ALL NODES FROM THE DATABASE
MATCH (n) RETURN n;

// EXAMINE THE SCHEMA OF THE DATABSE
CALL db.schema.visualization();

// EXAMPLE: USING NEO4J and USER data
// Retrieve all User nodes
MATCH (u:User)
RETURN u;

// Retrieve all User nodes with City = Los Angeles
MATCH (u:User)
WHERE u.city = 'Los Angeles'
RETURN u;

// Give all Users that do not have a city property, returning their names
MATCH (u:User)
WHERE NOT exists(u.city)
RETURN u.name;

// Give the number of friends for User Bradley
MATCH (u:User)-[:FRIEND]->(ou:User) // Using the relationship: 'FRIEND', this will match users 'ou' that are friends of 'Bradley'
WHERE u.name = 'Bradley'
RETURN count(*) As NumberOfFriends;

// Give all (immediate) friends of User Lisa
MATCH (l:User)-[:FRIEND]->(ol:User)
WHERE l.name = 'Lisa'
RETURN ol;

// Give all friends of friends of User Lisa (= friends exactly 2 hops away)
MATCH (l:User)-[:FRIEND*2]->(ol:User) // Using '*2' will match the friends of friends of 'Lisa'
WHERE l.name = 'Lisa'
RETURN ol;

// Give all friends of friends of User Lisa (= friends exactly 2 hops away) that are not immediate friends of User Lisa
MATCH (l:User)-[:FRIEND*2]->(ol:User)
WHERE NOT ((l)-[:FRIEND]->(ol)) AND l.name = 'Lisa'
RETURN ol;

// Give all friends of friends of User Lisa (= friends exactly 2 hops away) that are not immediate friends of User Lisa and aren't User Lisa either
MATCH (l:User)-[:FRIEND*2]->(ol:User)
WHERE NOT ((l)-[:FRIEND]->(ol)) AND NOT ol = l AND l.name = 'Lisa'
RETURN ol;

// Find all the users reachable from Annie
MATCH (a:User)-[:FRIEND*..]->(f) // Using '*..' will select all hops away
WHERE a.name = 'Annie'
RETURN f;

// Find the mutual friends between Annie and Lisa
MATCH (a:User)-[:FRIEND]->(mf)<-[:FRIEND]-(l:User) //  (a)-[:relationship] -> (mutual) <- [:relationship]-(b)
where a.name = "Annie" AND l.name = "Lisa"
RETURN mf.name as MutualFriends;

// Find out which user shares the most common friends with Annie
MATCH (a:User)-[:FRIEND]->(f)<-[:FRIEND]-(ou:User)
WHERE a.name = 'Annie'
RETURN ou.name as Name, COUNT(f) as CommonFriends // Counts the mutual friends 'f', of 'ou' user with 'Annie'
ORDER BY COUNT(f) DESC
LIMIT 1; // Limit to the user who shares the most

// Give the mutual interests for User Bradley and User Lisa
MATCH (b:User)-[:INTEREST]->(i:Interest)<-[:INTEREST]-(l:User)
WHERE b.name = 'Bradley' AND l.name = 'Lisa'
RETURN i;

// Find 3 new friends for Bradley based on maximum number of common interests
MATCH (b:User)-[:INTEREST]->(stuff)<-[:INTEREST]-(new_friend)
WHERE b.name = 'Bradley'
    AND NOT (b)-[:FRIEND]-(new_friend) // This will NOT match all friends of 'Bradley'
RETURN new_friend.name as NewFriend, count(stuff) as CommonInterests
ORDER BY count(stuff) DESC
LIMIT 3;

// Find the status updates by users sharing interests with Bradley
MATCH (b:User)-[:INTEREST]->(i:Interest)<-[:INTEREST]-(ou:User)-[:STATUS]->(s:Status)
// Here we can see that we can make more Matches with differents relationships
WHERE b.name = 'Bradley'
RETURN DISTINCT ou.name as Name, s.text as interests


// FLIGHTS DATA
// Retrieve all flights that originate from any airport in Atlanta city that are destined from Dallas/Fort Worth
MATCH (o)<-[:ORIGIN]-(f)-[:DESTINATION]->(d) // Selection from differents relationships
WHERE o.city = "Atlanta" AND d.city = "Dallas/Fort Worth" 
RETURN o.name as OriginAirportName, f.flight_number as FlightNumber, d.name as DestinationAirportName


// Retrieve all flights that originate from any city, but not from Atlanta
MATCH (o)<-[:ORIGIN]-(f) 
WHERE NOT o.city = "Atlanta" 
RETURN o


// SIMPSONS DATA
// List all men over 40 along with their age. 
    // For the current year, use date().year. Sort descending by age.
MATCH (n:Male)
WHERE n.yearOfBirth <= date().year - 40
RETURN n.name As name, date().year - n.yearOfBirth As age
ORDER BY n.yearOfBirth DESC

// Give the average age of all mothers.
    //For the current year.
MATCH (f:Female)-[:MOTHER_OF]->(p:Person)
RETURN avg(date().year - f.yearOfBirth) As AverageAge // avg function

// List all women who are daughters (in the dataset) along with their age. 
    //For the current year, use date().year. Sort descending by age.
MATCH (n:Person)-[:MOTHER_OF]->(f:Female)
WITH DISTINCT(f) as daughters // Here we are telling that we only need the distinct ones, not duplicated
RETURN daughters.name As name, date().year - daughters.yearOfBirth As age
ORDER BY daughters.yearOfBirth DESC

// Give everyone who is simultaneously father and son (in the dataset)
MATCH (m:Male)-[:FATHER_OF]->(fs)-[:FATHER_OF]->(p:Person) //father -> father
RETURN DISTINCT fs.name as name

// Give all grandfather-grandchildren relationships
MATCH (m:Male)-[:FATHER_OF | MOTHER_OF*2]->(c:Person) // Using *2, we are taking out the step of Father -> children.
RETURN m.name as grandfather, c.name as grandchild

// Give all couples who have been together for over 50 years in the following way. 
    //For the current year, use date().year.
MATCH (m:Male)<-[t:TOGETHER_WITH]->(f:Female) 
WHERE date().year - t.since >= 50
RETURN DISTINCT m['name'] As Husband, f['name'] As Wife