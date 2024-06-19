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
  Grade varchar (255) NULL,
  Arrived BOOLEAN NOT NULL DEFAULT FALSE
);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Arndt', 'First Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Gertner', 'Second Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Wagner', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Iacovetti', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. LoGreco', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Palmer', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Williams', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Carlson', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. M. Edinger', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Buchanan', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Roths', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Mr. A. Ricketts', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Muñoz', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Forker', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. L. Ricketts', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Shell', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Leir Orlando', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Dimke', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Mr. J. Edinger', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Yackus', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Peters', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Rozinski', 'Third Grade', FALSE);
INSERT INTO Teachers (Name, Grade, Arrived) VALUES ('Ms. Lakin', 'Third Grade', FALSE);
