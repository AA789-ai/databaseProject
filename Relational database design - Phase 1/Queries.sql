-- Finished
-- 1: Basic select with simple where clause

/* return the first name, last name, and birthday of those whose first 
name starts with a 'A', ordered by first name then last name 
alphabetically */
-- verified
SELECT firstname, lastname, birthday
FROM Person
WHERE firstname LIKE 'A%'
ORDER BY firstname, lastname;

-- -------------------------------------------------------------------------------------------------
-- Finished
-- 2: Basic select with simple group by clause (with and without having clause)

-- return the birth dates shared by exactly 3 people (with having clause)
-- verified
SELECT birthday
FROM Person
GROUP BY birthday
HAVING COUNT(*) = 3;

-- return the birth dates shared by exactly 3 people (without having clause)
-- verified
SELECT birthday
FROM Person
WHERE (SELECT COUNT(*)
       FROM Person AS sub
       WHERE sub.birthday = Person.birthday) = 3
GROUP BY birthday;

-- -------------------------------------------------------------------------------------------------
-- Finished
-- 3: A simple join select query using cartesian product and where clause vs a join query using on.

-- return the person id, first name, last name, and email of those whose email starts with a 'c' and ends with 'net' 
-- verified
SELECT Person.id, firstname, lastname, emailAddress
FROM Person, Email
WHERE Person.id = personID AND 
			emailAddress LIKE 'c%net'
ORDER BY Person.id;

-- The equivalent of the above query using inner join 
-- verified
SELECT Person.id, firstname, lastname, emailAddress
FROM Person
INNER JOIN Email ON Person.id = personID
WHERE emailAddress LIKE 'c%net'
ORDER BY Person.id;

-- -------------------------------------------------------------------------------------------------
-- Finished

/* 4: A few queries to demonstrate various join types on the same tables: inner vs 
    outer (left and right) vs full join. Use of null values in the database to 
    show the difference is required. */

-- We are displaying the persons id, firstname, lastname and the number of buidlings they own

-- verified
-- Inner join (returns persons who owns buildings and buildings who have an owner)
SELECT p.id, p.firstname, p.lastname, bo.addressID
FROM Person p
INNER JOIN BuildingOwner bo ON p.id = bo.personID
ORDER BY p.id ASC;

-- verified
-- Left join (returns persons and the building they own. If don't own it, it shows for addressID)
SELECT p.id, p.firstname, p.lastname, bo.addressID
FROM Person p
LEFT JOIN BuildingOwner bo ON p.id = bo.personID
ORDER BY p.id ASC;

-- verified
-- Right join (returns each building owner's id, firstname and lastname. If id, firstname, and lastname is NULL, it means it is an unclaimed building.)
SELECT p.id, p.firstname, p.lastname, bo.addressID
FROM Person p
RIGHT JOIN BuildingOwner bo ON p.id = bo.personID
ORDER BY p.id ASC;

-- verified
-- Full join. While outer join doesn't exist in mysql we can simulate it by using left and right join and getting their union
-- returns each building's owner and each owner's building
(SELECT p.id, p.firstname, p.lastname, bo.addressID
FROM Person p
LEFT JOIN BuildingOwner bo ON p.id = bo.personID)
	UNION
(SELECT p.id, p.firstname, p.lastname, bo.addressID
FROM Person p
RIGHT JOIN BuildingOwner bo ON p.id = bo.personID);


-- -------------------------------------------------------------------------------------------------
-- Finished
-- 5: A couple of examples to demonstrate correlated queries.

-- correlated query is a query where the inner subquery depends on the outer query and is executed repeatdly, once for each row processed by the other query.

-- The inner query needs Person.id (p.id) which is given by the outer query
-- It returns the the id, firstname and last name of people who own a building in singapore
-- verified
SELECT p.id, p.firstname, p.lastname
FROM Person p
WHERE EXISTS (
    SELECT 1
    FROM BuildingOwner bo
    JOIN Address a ON bo.addressID = a.id
    WHERE bo.personID = p.id AND a.country = 'Singapore'
);

-- The inner query needs Person.id (p.id) which is given by the outer query
-- It returns the the id, firstname and last name of people who do not own a building in singapore
-- verified
SELECT Person.id, firstname, lastname
FROM Person p, Address a, LivesAtAddress l
WHERE p.id = l.personID 
			AND a.id = l.addressID
      AND country = 'Singapore'
      AND NOT EXISTS (SELECT *
                      FROM BuildingOwner
                      WHERE l.personID = P.id);

-- The inner query needs Person.id (p.id) which is given by the outer query
-- It returns the id, firstname, lastname of people who don't any card at all
-- verified
SELECT p.id, p.firstname, p.lastname
FROM Person p
WHERE NOT EXISTS (
    SELECT 1
    FROM Card c
    WHERE c.personID = p.id
);


-- -------------------------------------------------------------------------------------------------
-- Finished
-- 6: One example per set operations: intersect, union, and difference vs their equivalences without using set operations.

-- -------------------------------------------------    
/* intersect query: return the person id, first name, and last name of those
    who own both a debit card and a credit card */
-- verified
SELECT * FROM (
    (SELECT p.id, p.firstname, p.lastname 
    FROM Person p
    JOIN Card c ON p.id = c.personID
    JOIN CreditCard cc ON c.id = cc.cardID)
    	INTERSECT
    (SELECT p.id, p.firstname, p.lastname
    FROM Person p
    JOIN Card c ON p.id = c.personID
    JOIN DebitCard dc ON c.id = dc.cardID)
) AS subqueryUsingIntersect
ORDER BY id ASC;



/* equivalent of above query without use of intersect */
-- verified
SELECT P.id, P.firstname, P.lastname
FROM Person P
WHERE EXISTS (
    SELECT 1
    FROM Card C
    JOIN CreditCard CC ON C.id = CC.cardID
    WHERE C.personID = P.id
) 
AND EXISTS (
    SELECT 1
    FROM Card C
    JOIN DebitCard DC ON C.id = DC.cardID
    WHERE C.personID = P.id
)
ORDER BY P.id ASC;
                                                   

-- -------------------------------------------------

/* union query: return the person id, first name, and last name of those
    who own either a debit card or a credit card */
-- verified
SELECT * FROM (
    (SELECT Person.id, firstname, lastname
    FROM Person, Card, CreditCard
    WHERE Person.id = personID AND Card.id = CreditCard.cardID)
    	UNION
    (SELECT Person.id, firstname, lastname
    FROM Person, Card, DebitCard
    WHERE Person.id = personID AND Card.id = DebitCard.cardID)
) AS subqueryUsingUnion
ORDER BY id ASC;



/* equivalent of above query without use of union */
-- verified
SELECT p.id, p.firstname, p.lastname
FROM Person p
WHERE EXISTS (
    SELECT 1
    FROM Card c
    JOIN CreditCard cc ON c.id = cc.cardID
    WHERE c.personID = p.id
)
OR EXISTS (
    SELECT 1
    FROM Card c
    JOIN DebitCard dc ON c.id = dc.cardID
    WHERE c.personID = p.id
)
ORDER BY p.id ASC;

-- -------------------------------------------------

/* difference query: return the person id, first name, and last name of those 
    who own a debit card, but not a credit card */
-- verified
SELECT * FROM (
    (SELECT p.id, p.firstname, p.lastname
     FROM Person p
     JOIN Card c ON p.id = c.personID
     JOIN DebitCard dc ON c.id = dc.cardID)
    EXCEPT
    (SELECT p.id, p.firstname, p.lastname
     FROM Person p
     JOIN Card c ON p.id = c.personID
     JOIN CreditCard cc ON c.id = cc.cardID)
) AS subqueryUsingExcept
ORDER BY id ASC;


/* equivalent of above query without use of EXCEPT */
-- verified
SELECT p.id, p.firstname, p.lastname
FROM Person p
JOIN Card c ON p.id = c.personID
JOIN DebitCard dc ON c.id = dc.cardID
WHERE NOT EXISTS (
    SELECT 1
    FROM Card c2
    JOIN CreditCard cc ON c2.id = cc.cardID
    WHERE c2.personID = p.id
)
ORDER BY p.id ASC;

-- -------------------------------------------------------------------------------------------------
-- Finished
/* 7: An example of a view that has a hard-coded criteria, by which the content of
    the view may change upon change upon changing the hard-coded value (see L09
    slide 24) */
    
-- create a view to return info on those living in the hard coded country. The hard coded value here is 'Canada'  
-- verified
CREATE VIEW countryResidents AS
    (SELECT personID, firstName, lastName, streetName, buildingNumber, city, country
    FROM Person p, Address a, LivesAtAddress l
    WHERE p.id = l.personID AND 
     			a.id = l.addressID AND 
     			a.country = 'Canada');

-- Use it to view
SELECT * FROM countryResidents;

-- Drop the view
DROP VIEW countryResidents;
-- -------------------------------------------------------------------------------------------------

/* 8: Two implementations of the division operator using a) a regular nested query 
    using NOT IN and b) a correlated nested query using NOT EXISTS and EXCEPT 
    (see |4|) */
    
-- Selects persons who have a credit card and a debit card and excluding those who have only one type of card.


-- a) a regular nested query using NOT IN
/* The query performs SQL division by ensuring that each person is included only if they have both credit and debit cards. 
	it excludes those with any card not falling into these two categories which divides the set of all cardholders by those holding each required card type.*/

SELECT DISTINCT P.id, P.firstname, P.lastname
FROM Person P
WHERE P.id IN (
    SELECT C.personID
    FROM Card C
    INNER JOIN CreditCard CC ON C.id = CC.cardID
)
AND P.id IN (
    SELECT C.personID
    FROM Card C
    INNER JOIN DebitCard DC ON C.id = DC.cardID
)
AND P.id NOT IN (
    SELECT C.personID
    FROM Card C
    WHERE C.id NOT IN (
        SELECT CC.cardID
        FROM CreditCard CC
    )
    AND C.id NOT IN (
        SELECT DC.cardID
        FROM DebitCard DC
    )
)
ORDER BY P.id, P.firstname, P.lastname;

-- b) a correlated nested query using NOT EXISTS and EXCEPT

/* The query implements SQL division by ensuring that each person is associated with credit and debit using a combination of EXCEPT and NOT EXISTS to exclude those without both types.*/
SELECT P.id, P.firstname, P.lastname
FROM Person P
WHERE NOT EXISTS (
    SELECT 'Credit' AS cardType
    UNION ALL
    SELECT 'Debit'
    EXCEPT
    SELECT CASE 
               WHEN CC.cardID IS NOT NULL THEN 'Credit'
               WHEN DC.cardID IS NOT NULL THEN 'Debit'
           END AS cardType
    FROM Card C
    LEFT JOIN CreditCard CC ON C.id = CC.cardID
    LEFT JOIN DebitCard DC ON C.id = DC.cardID
    WHERE C.personID = P.id
)
ORDER BY P.id, P.firstname, P.lastname;



-- -------------------------------------------------------------------------------------------------
-- Finished
-- 9 : Provide queries that demonstrates the overlap and covering constraints.


-- Overlap Constraints: Determines if an instance of a parent class can belong to multiple child classes (overlapping) or is restricted to just one child class (non-overlapping).

/* Covering constraints: Determines if every instance of a parent class must also be an instance in at least one of its child classes (covering) or 
 if instances of the parent class can exist without corresponding instances in any of its child classes (non-covering).*/


-- Both creditcards and debitcards inherit from card entity. 

/* We can demonstrate that our design does not overlap by joining on cardID in both credit and debit card tables. If no tuples (count = 0) are returned it means 
  that our design doesn't overlap since it implies no 2 cards are both credit and debit card. */
    
-- verified
SELECT COUNT(*) as numberOfCardsThatAreBothCreditAndDebit
FROM CreditCard cc, DebitCard db, Card c
WHERE cc.cardID = c.id AND 
			db.cardID = c.id;

/* We can demonstrate that our design respect covering constraint by looking for number of cards that are neither in CreditCard table and neither DebitCard table. 
  If no tuples (count = 0) are returned it means that our design respect covering constraints since it implies each card must be credit or debit card.*/

-- verified
SELECT COUNT(*)
FROM Card
WHERE id NOT IN (SELECT cardID FROM CreditCard) AND 
			id NOT IN (SELECT cardID FROM DebitCard);


-- -------------------------------------------------------------------------------------------------







