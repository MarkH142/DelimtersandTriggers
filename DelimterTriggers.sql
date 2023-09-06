-- Make the following triggers from these relations:

-- Product (maker, model, type)
-- PC (model, speed, ram, hd, price)
-- Laptop (model, speed, ram, hd, screen, price)
-- Printer (model, color, type, price)

CREATE DATABASE computers;
USE computers;

-- Add TABLEs and INSERTs to test with (you may use the same ones from a previous assignment)
DROP DATABASE computers;
CREATE DATABASE computers;
USE computers;
CREATE TABLE Product (maker CHAR(30), model INT, type CHAR(7));
CREATE TABLE PC (model INT, speed FLOAT, ram INT, hd INT, price DECIMAL(6, 2));
CREATE TABLE Laptop (model INT, speed INT, ram INT, hd INT, screen INT, price DECIMAL(6, 2));
CREATE TABLE Printer (model INT, color BOOLEAN, type CHAR(30), price DECIMAL(5, 2));

-- Add TABLEs and INSERTs to test with
INSERT INTO Product(maker, model, type) VALUES ('manufactuer A', '1100', 'PC');
INSERT INTO Product(maker, model, type) VALUES ('manufactuer B', '1101', 'PC');
INSERT INTO Product(maker, model, type) VALUES ('manufactuer C', '1102', 'PC');

INSERT INTO Product(maker, model, type) VALUES ('manufactuer B', '1200', 'Laptop');
INSERT INTO Product(maker, model, type) VALUES ('manufactuer A', '1201', 'Laptop');
INSERT INTO Product(maker, model, type) VALUES ('manufactuer C', '1202', 'Laptop');

INSERT INTO Product(maker, model, type) VALUES ('manufactuer A', '1300', 'Printer');
INSERT INTO Product(maker, model, type) VALUES ('manufactuer A', '1301', 'Printer');
INSERT INTO Product(maker, model, type) VALUES ('manufactuer A', '1302', 'Printer');

INSERT INTO PC(model, speed, ram, hd, price) VALUES ('1100', 3.2 , 8, 1024, 659.00);
INSERT INTO PC(model, speed, ram, hd, price) VALUES ('1101', 3.6, 8, 526, 299.00);
INSERT INTO PC(model, speed, ram, hd, price) VALUES ('1102', 3.4, 1024, 180, 499.00);
INSERT INTO PC(model, speed, ram, hd, price) VALUES ('1102', 3.2, 1024, 180, 499.00);

INSERT INTO Laptop(model, speed, ram, hd, screen, price) VALUES ('1200', 3.2, 6, 256, 12, 499.00);
INSERT INTO Laptop(model, speed, ram, hd, screen, price) VALUES ('1201', 4.2, 8, 512, 11, 199.00);
INSERT INTO Laptop(model, speed, ram, hd, screen, price) VALUES ('1202', 4.6, 12, 1024, 14, 599.00);

INSERT INTO Printer(model, color, type, price) VALUES ('1300', true, 'laser', 129.00);
INSERT INTO Printer(model, color, type, price) VALUES ('1301', false, 'inkjet', 79.00);
INSERT INTO Printer(model, color, type, price) VALUES ( 1302, true, 'laser', 99.00);
-- #1 Write the SQL to declare these triggers to disallow the modifications:

-- a) When updating the price of a PC, check that there is no lower priced PC with the same speed
DROP TRIGGER LowerPricedPC
DELIMITER //
CREATE TRIGGER LowerPricedPC
  BEFORE UPDATE ON PC FOR EACH ROW
BEGIN
	IF (NEW.price < (SELECT MIN(price) FROM PC WHERE NEW.speed = speed)) THEN
      SET NEW.price = OLD.price;
	END IF;
END //
DELIMITER ;
UPDATE PC SET Price = 999.00 WHERE speed = 3.2;



-- b) When updating a new printer, check that the model number exists in Product
DELIMITER //
CREATE TRIGGER ModelNumCheck
  BEFORE UPDATE ON Printer FOR EACH ROW
BEGIN  
IF NEW.model NOT IN (SELECT Product.model FROM Product WHERE model = Product.model) THEN
	DELETE FROM PRINTER WHERE model = NEW.model;
  END IF;
END //
DELIMITER ;

-- c) When updating the Laptop relation, check that the average price of laptops for each manufacturer is at least $1500.

DROP TRIGGER LaptopAvg;
DELIMITER // 
CREATE TRIGGER LaptopAvg 
  BEFORE UPDATE ON Laptop FOR EACH ROW
BEGIN
  SELECT avg(price) as price, manufacturer from Laptop
  CHECK @avg = SELECT price from Laptop if(avg<1500)
END;
DELIMITER ;
#Had issues executing this code ^
-- d) When updating the RAM or hard disk of any PC, check that the updated PC has at least 100 times as much hard disk as RAM.
DROP TRIGGER HDtoRAM;
DELIMITER //
CREATE TRIGGER HDtoRAM 
  BEFORE UPDATE ON PC FOR EACH ROW
BEGIN
  IF NEW.hd >= 100*(NEW.ram) THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'hd should be at least 100 times greater than ram.';
  END IF;
  END;
DELIMTER ;

UPDATE PC SET hd = 10 WHERE model = 1100;
-- Make the following triggers from these relations:

-- Classes (class, type, country, numGuns, bore, displacement)
-- Ships (name, class, launched)
-- Battles (name, date)
-- Outcomes (ship, battle, result)

CREATE DATABASE ships;
USE ships;

-- Add TABLEs and INSERTs to test with (you may use the same ones from a previous assignment)
CREATE DATABASE ships;
USE ships;
INSERT INTO Classes(class, type, country, numGuns, bore, displacement) VALUES('Thomas', 'aa' , 'American', 50, 10, 36000);
INSERT INTO Classes(class, type, country, numGuns, bore, displacement) VALUES('Victoria', 'bb' , 'French', 9, 16, 18000);
INSERT INTO Classes(class, type, country, numGuns, bore, displacement) VALUES('George', 'cc' , 'Italian', 25, 8, 22000);
INSERT INTO Classes(class, type, country, numGuns, bore, displacement) VALUES('Kongo', 'ff' , 'Dutch', 15, 10, 20000);

INSERT INTO Ships(name, class, launched) VALUES('Thomas', 'Thomas', '1903');
INSERT INTO Ships(name, class, launched) VALUES('Roberts', 'George', '1953');
INSERT INTO Ships(name, class, launched) VALUES('Victoria', 'Victoria', '1964');
INSERT INTO Ships(name, class, launched) VALUES('Kongo', 'Kongo', '1955');

INSERT INTO Battles(name, date) Values('Pacfic', '1965-04-12');
INSERT INTO Battles(name, date) Values('Cape North', '1966-02-01');
INSERT INTO Battles(name, date) Values('Cape Stone', '1970-10-06');

INSERT INTO Outcomes(ship, battle, result) VALUES('Thomas', 'Pacific', 'sunk');
INSERT INTO Outcomes(ship, battle, result) VALUES('Roberts', 'Guadalcanal', 'fled');
INSERT INTO Outcomes(ship, battle, result) Values('Victoria', 'Cape Stone', 'won');
INSERT INTO Outcomes(ship, battle, result) Values('Kongo', 'Cape Stone', 'sunk');
-- #2 Write the SQL to declare these triggers:


#Kept Getting syntax errors for many of the triggers
-- a) When a new class is inserted into C lasses, also insert a ship with the name of that class and a NULL launch date.
DELIMITER //
CREATE TRIGGER newClass
  AFTER INSERT ON Classes
  FOR EACH ROW
  WHEN (TRUE)
    BEGIN
	  INSERT INTO Ships
	  VALUES (NEW.class, NEW.class, NULL);
  END;
DELIMITER ;
-- b) When a new class is inserted with a displacement greater than 35,000 tons, allow the insertion, but change the displacement to 35,000.
DELIMITER //
CREATE TRIGGER UpdateDisplacement
BEFORE INSERT ON Classes FOR EACH ROW 
IF (new.displacement > 3500) THEN
BEGIN
  INSERT INTO Classes
	SET class = NEW.class, name = NEW.name, country = NEW.country,
    numGuns = NEW.numGuns, bore = NEW.bore
	displacement = 35000;
END;
END IF;
DELIMITER ;


-- c) If a tuple is inserted into Outcomes, check that the ship and battle are listed in Ships and Battles, respectively, and if not, insert tuples into one or both of these relations, with NULL components where necessary.



-- Make the following triggers from these relations:

-- Movies (title, year, length, genre, studioName, producerC)
-- Starsln (movieTitle, movieYear, starName)
-- MovieStar (name, address, gender, birthdate)
-- MovieExec (name, address, cert#, netWorth)
-- Studio (name, address, presC)

CREATE DATABASE moviesdatabase;
USE moviesdatabase;

CREATE TABLE Movies (title CHAR(100), year INT, length INT, genre CHAR(10), studioName CHAR(30), producerC INT, PRIMARY KEY (title, year));
CREATE TABLE MovieStar (name CHAR(30) PRIMARY KEY, address VARCHAR(255), gender CHAR(1), birthdate DATE);
CREATE TABLE StarsIn (movieTitle CHAR(100), movieYear INT, starName CHAR(30), PRIMARY KEY (movieTitle, movieYear, starName));
CREATE TABLE MovieExec (name CHAR(30), address VARCHAR(255), cert INT PRIMARY KEY, netWorth INT);
CREATE TABLE Studio (name CHAR(30) PRIMARY KEY, address VARCHAR(255), presC INT);

INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Gone with the wind", 1939, 231, "drama", "MGM", 34567);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Star Wars", 1977, 124, "sciFi", "Fox", 23456);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Empire Strikes Back", 1980, 127, "sciFi", "Fox", 23456);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Return of the Jedi", 1983, 136, "sciFi", "Fox", 23456);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Wayne’s World", 1992, 95, "comedy", "Paramount", 45678);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("The Rescuers Down Under", 1990, 77, "adventure", "Disney", 56789);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("DuckTales", 1990, 74, "comedy", "Disney", 67890);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Beauty and the Beast", 1991, 84, "fantasy", "Disney", 78901);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Tomorrow Never Dies", 1997, 119, "action", "MGM", 89012);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Stargate", 1994, 130, "sciFi", "MGM", 901234);
INSERT INTO Movies(title, year, length, genre, studioName, producerC) VALUES ("Galaxy Quest", 1999, 104, "comedy", "DreamWorks", 01234);
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Carrie Fisher', '123 Maple St., Hollywood', 'F', '1999-09-09');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Mark Hamill', '456 Oak Rd., Brentwood', 'M', '1988-08-08');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Harrison Ford', '789 Palm Dr.,Beverly Hills', 'M', '1977-07-07');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Vivien Leigh', '125 Maple St., Hollywood', 'F', '1955-05-05');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Dana Carvey', '458 Oak Rd., Brentwood', 'M', '1944-04-04');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Sandra Bullock', '12 Cherry Ln., Malibu', 'F', '1911-11-11');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Mike Meyers', '791 Palm Dr.,Beverly Hills', 'M', '1933-03-03');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Mary Tyler Moore', '125 Maple St., Hollywood', 'F', '1999-09-09');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Tom Hanks', '10 Cherry Ln., Malibu', 'M', '1988-08-08');
INSERT INTO MovieStar(name, address, gender, birthdate) VALUES ('Jane Fonda', '11 Cherry Ln., Malibu', 'F', '1912-12-12');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Star Wars', 1977, 'Carrie Fisher');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Star Wars', 1977, 'Mark Hamill');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Star Wars', 1977, 'Harrison Ford');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Raiders of the Lost Ark', 1981, 'Harrison Ford');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('The Fugitive', 1993, 'Harrison Ford');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Gone with the wind', 1939, 'Vivien Leigh');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Wayne’s World', 1992, 'Dana Carvey');
INSERT INTO StarsIn(movieTitle, movieYear, starName) VALUES ('Wayne’s World', 1992, 'Mike Meyers');
INSERT INTO MovieExec(name, address, cert, netWorth) VALUES ('Mary Tyler Moore', 'Maple St. ', 12345, 100000000);
INSERT INTO MovieExec(name, address, cert, netWorth) VALUES ('George Lucas', 'Oak Rd.', 23456, 200000000);
INSERT INTO MovieExec(name, address, cert, netWorth) VALUES ('Ted Turner', '11 Cherry Ln., Malibu', 34567, 300000000);
INSERT INTO Studio(name, address, presC) VALUES ('MGM', 'Whatever St.', 34567);
INSERT INTO Studio(name, address, presC) VALUES ('Disney', 'Disney St.', 45678);

-- #3 Write the SQL to declare these triggers to update other relations when these are updated:

-- a) Assure that after updating, any star appearing in Stars ln also appears in MovieStar
DELIMITER //
CREATE TRIGGER StarInsert
 AFTER INSERT ON StarsIn
 BEGIN
 SELECT mv.name
   FROM MovieStar as mv
   INNER JOIN StarsIn as st
   ON st.starName = mv.name;
 END;
DELIMITER ;
-- b) Assure that at all times every movie executive appears as either a studio president, a producer of a movie, or both
DELIMITER //
CREATE TRIGGER ExecCheck
  AFTER INSERT ON MovieExec
  BEGIN
    SELECT me.name
    FROM MovieExec AS me
    LEFT JOIN Studio AS st
    ON st.presC# = m.name
    LEFT JOIN Movies as mv
    mv.producerC# = m.name
  END;
  DELIMITER ;

#Having Issues where a lot of the triggers are not being executed when I try to run them, so unable to check for potential errors, When I highlight some triggers
#And then hit execute the selected portion of the code, nothing happens