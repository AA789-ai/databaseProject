CREATE TABLE Person ( 
    id INT PRIMARY KEY AUTO_INCREMENT,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    birthday DATE,
    gender VARCHAR(10),
    website VARCHAR(255),
    image VARCHAR(255),
		UNIQUE (firstname, lastname, birthday, gender, website, image) 
);

-- Subtype of Person
CREATE TABLE Email (
    id INT PRIMARY KEY AUTO_INCREMENT,
    personID INT,
    emailAddress VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (personID) REFERENCES Person(id) 
);

-- Subtype of Person
CREATE TABLE PhoneNumber (
    id INT PRIMARY KEY AUTO_INCREMENT,
    personID INT,
    phoneNumber VARCHAR(20) NOT NULL CHECK (phoneNumber LIKE '+%') UNIQUE,
    FOREIGN KEY (personID) REFERENCES Person(id) ON DELETE CASCADE
);

CREATE TABLE Card ( 
  	id INT PRIMARY KEY AUTO_INCREMENT,
  	personID INT NOT NULL,
    number VARCHAR(20) NOT NULL,
  	expiration DATE NOT NULL, 
    type VARCHAR(50) NOT NULL,
    UNIQUE (number),
    FOREIGN KEY (personID) REFERENCES Person(id) ON DELETE CASCADE
);

-- Subtype of Card
CREATE TABLE CreditCard ( 
    id INT PRIMARY KEY AUTO_INCREMENT,
    cardID INT NOT NULL UNIQUE,
    creditLimit DECIMAL(10, 2), 
  	availableCredit DECIMAL(10, 2), 
    FOREIGN KEY (cardID) REFERENCES Card(id) ON DELETE CASCADE
);

-- Subtype of Card
CREATE TABLE DebitCard (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cardID INT NOT NULL UNIQUE,
    balance DECIMAL(10, 2),
    FOREIGN KEY (cardID) REFERENCES Card(id) ON DELETE CASCADE
);

CREATE TABLE Address ( 
    id INT PRIMARY KEY AUTO_INCREMENT,
    streetName VARCHAR(255) NOT NULL,
    buildingNumber VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    zipcode VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    countyCode VARCHAR(10) NOT NULL,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

CREATE TABLE LivesAtAddress ( 
    id int primary key auto_increment,
  	personID INT,
    addressID INT,
    Unique (personID),
    FOREIGN KEY (personID) REFERENCES Person(id),
    FOREIGN KEY (addressID) REFERENCES Address(id)
);

CREATE TABLE BuildingOwner ( 
  	id int primary key auto_increment,
    personID INT,
    addressID INT,
    unique (personID, addressID),
    FOREIGN KEY (personID) REFERENCES Person(id),
    FOREIGN KEY (addressID) REFERENCES Address(id)
);


CREATE TABLE TextMessages ( 
    id INT primary key auto_increment,
  	phoneNumberID1 INT,
    phoneNumberID2 INT,
    time TIMESTAMP NOT NULL default current_timestamp, 
    messageContent TEXT,
  	unique (phoneNumberID1, phoneNumberID2, time),
    FOREIGN KEY (phoneNumberID1) REFERENCES PhoneNumber(id),
    FOREIGN KEY (phoneNumberID2) REFERENCES PhoneNumber(id)
);
