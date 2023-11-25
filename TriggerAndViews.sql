-- -------------------------------------------------------------------------------------------------
-- 1: Trigger to check the age of the person before a new card is inserted. The person must over 18 to create a credit card...
DELIMITER //
CREATE TRIGGER CheckAgeBeforeCardInsert
BEFORE INSERT ON Card
FOR EACH ROW
BEGIN
    DECLARE person_birthdate DATE;
    DECLARE current_age INT;

    SELECT birthday INTO person_birthdate
    FROM Person
    WHERE id = NEW.personID;

    SET current_age = TIMESTAMPDIFF(YEAR, person_birthdate, CURDATE());

    IF current_age < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person must be at least 18 years old to own a credit card';
    END IF;
END//
DELIMITER ;


-- Use this insert to test( the person is younger than 18)
insert into `person` (`birthday`, `firstname`, `gender`, `id`, `image`, `lastname`, `website`) values ('2020-03-16', 'Shabia', 'female', 3976, 'http://placeimg.com/640/480/shabia', 'Saeed', 'http://on.com');
insert into `email` (`emailAddress`, `id`, `personID`) values ('shabia-ab@hotmail.com', 3976, 3976);
insert into `phonenumber` (`id`, `personID`, `phoneNumber`) values (3972, 3976, '+6823451522023');
insert into `card` (`expiration`, `id`, `number`, `personID`, `type`) values ('2021-04-01', 4025, '2716210382080946', 3976, 'Discover Card');

-- use this to remove these values
DELETE FROM Card WHERE id = 4025;
DELETE FROM PhoneNumber WHERE id = 3972;
DELETE FROM Email WHERE id = 3976;
DELETE FROM Person WHERE id = 3976;
-- -------------------------------------------------------------------------------------------------
-- 2: View to display person details with their email, phone number, and address
CREATE VIEW PersonContactDetails AS
SELECT
    Person.id,
    CONCAT(Person.firstname, ' ', Person.lastname) AS FullName,
    Person.birthday,
    Person.gender,
    Person.website,
    Email.emailAddress,
    PhoneNumber.phoneNumber,
    CONCAT(Address.streetName, ', ', Address.buildingNumber, ', ', Address.city, ', ', Address.zipcode, ', ', Address.country) AS FullAddress
FROM Person
LEFT JOIN Email ON Person.id = Email.personID
LEFT JOIN PhoneNumber ON Person.id = PhoneNumber.personID
LEFT JOIN LivesAtAddress ON Person.id = LivesAtAddress.personID
LEFT JOIN Address ON LivesAtAddress.addressID = Address.id
ORDER BY Person.id;

SELECT *
FROM PersonContactDetails;

-- -------------------------------------------------------------------------------------------------
-- 3: View to display credit card details along with the owner's name
CREATE VIEW PersonCreditCardDetails AS
SELECT
    Person.firstname,
    Person.lastname,
    Card.number AS CardNumber,
    Card.expiration,
    CreditCard.creditLimit,
    CreditCard.availableCredit
FROM Person
JOIN Card ON Person.id = Card.personID
JOIN CreditCard ON Card.id = CreditCard.cardID;

SELECT *
FROM PersonCreditCardDetails;

-- -------------------------------------------------------------------------------------------------
-- 4: View to display the balance for each debit card along with the owners name
CREATE VIEW PersonDebitCardBalances AS
SELECT
    Person.firstname,
    Person.lastname,
    Card.number AS CardNumber,
    DebitCard.balance
FROM Person
JOIN Card ON Person.id = Card.personID
JOIN DebitCard ON Card.id = DebitCard.cardID;

SELECT *
FROM PersonDebitCardBalances;









