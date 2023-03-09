CREATE DATABASE ExcelR;

USE ExcelR;

CREATE TABLE StudentTable(
	ID INT,
    Name CHAR(30),
    Age TINYINT,
    Gender VARCHAR(10)
);

INSERT INTO StudentTable
	(ID, Name, Age, Gender) 
VALUES 
	(1, "Abbili", 26, "Male"),
	(2, "Mutharasi", 24, "Female"),
    (3, "Vadde", 26, "Male"),
    (4, "Ediga", 24, "Male"),
    (5, "Rage", 22, "Female");

SELECT * FROM StudentTable;

DROP TABLE StudentTable;

SHOW tables;

DROP DATABASE ExcelR;

DELETE FROM StudentTable 
WHERE ID =1;

SET SQL_SAFE_UPDATES = 0;