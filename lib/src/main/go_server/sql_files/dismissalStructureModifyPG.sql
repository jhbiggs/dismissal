CREATE SCHEMA IF NOT EXISTS dismissal_schema;

SET search_path TO dismissal_schema;

DROP TABLE IF EXISTS Buses;
CREATE TABLE Buses (
  BusID SERIAL PRIMARY KEY,
	Name varchar (255) NOT NULL,
  Animal varchar (255) NOT NULL,
  Arrived BOOLEAN NOT NULL
);

INSERT INTO Buses (Name, Animal, Arrived) VALUES ('Bus 1', 'Dog', FALSE);
INSERT INTO Buses (Name, Animal, Arrived) VALUES ('Bus 2', 'Cat', FALSE);
INSERT INTO Buses (Name, Animal, Arrived) VALUES ('Bus 3', 'Bird', FALSE);

DROP TABLE IF EXISTS Teachers;
CREATE TABLE Teachers (
  TeacherID SERIAL PRIMARY KEY,
  Name varchar (255) NULL,
  Grade varchar (255) NULL
);
INSERT INTO Teachers (Name, Grade) VALUES ('Teacher 1', 'First Grade');
INSERT INTO Teachers (Name, Grade) VALUES ('Teacher 2', 'Second Grade');