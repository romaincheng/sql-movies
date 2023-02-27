CREATE SCHEMA assign4;
USE assign4;

#Load the IMDB dataset in MYSQL, please ensure that PK/FK are mapped correctly
DROP TABLE IF EXISTS title_basics;
DROP TABLE IF EXISTS title_akas;
DROP TABLE IF EXISTS title_crew;
DROP TABLE IF EXISTS name_basics;
DROP TABLE IF EXISTS title_principals;
DROP TABLE IF EXISTS title_ratings;
DROP TABLE IF EXISTS title_episodes;

CREATE TABLE title_basics(
	tconst VARCHAR(50),
    titleType VARCHAR(50),
    primaryTitle VARCHAR (500),
    originalTitle VARCHAR(500),
    isAdult SMALLINT(2),
    startYear SMALLINT(4),
    endYear SMALLINT(4),
    runtimeMinutes SMALLINT(10),
    genres VARCHAR(50),
    PRIMARY KEY (tconst));

LOAD DATA INFILE 
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_titlebasics.csv' 
    INTO TABLE title_basics
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres); 
    
CREATE TABLE title_akas(
	tconst VARCHAR(50),
    ordering INT(50),
    title VARCHAR(5000),
    region VARCHAR (10),
    language VARCHAR(50),
    types VARCHAR(50),
	attributes VARCHAR(5000),
	isOriginalTitle INT(2),
    PRIMARY KEY (tconst, ordering),
	CONSTRAINT fk_is_in_basics FOREIGN KEY (tconst)
    REFERENCES title_basics(tconst));
    
LOAD DATA INFILE 
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_titleakas.csv' 
    INTO TABLE title_akas
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (tconst, ordering, title, region, language, types, attributes, isOriginalTitle); 

CREATE TABLE title_episodes(
	tconst VARCHAR(50),
    parentTconst VARCHAR(50),
    seasonNumber SMALLINT(5),
    episodeNumber SMALLINT(5),
    PRIMARY KEY (tconst),
	CONSTRAINT fk_is_in_basics_episodes FOREIGN KEY (tconst)
    REFERENCES title_basics(tconst),
    CONSTRAINT fk_is_in_basics_parentepisodes FOREIGN KEY (parentTconst)
    REFERENCES title_basics(tconst));
    
LOAD DATA INFILE 
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_titleepisode.csv' 
    INTO TABLE title_episodes
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (tconst, parentTconst, seasonNumber, episodeNumber); 

CREATE TABLE title_crew(
	tconst VARCHAR(50),
    directors VARCHAR(5000),
    writers VARCHAR(5000),
    PRIMARY KEY (tconst),
	CONSTRAINT fk_is_in_basics_crew FOREIGN KEY (tconst)
    REFERENCES title_basics(tconst));
    
LOAD DATA INFILE 
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_titlecrew.csv' 
    INTO TABLE title_crew
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (tconst, directors, writers); 

CREATE TABLE title_principals(
	tconst VARCHAR(50),
    ordering SMALLINT(50),
    nconst VARCHAR(50),
    category VARCHAR(50),
    job VARCHAR(500),
    characters VARCHAR(500),
    PRIMARY KEY (tconst, ordering),
	CONSTRAINT fk_is_in_namebasics FOREIGN KEY (nconst)
    REFERENCES name_basics(nconst),
    CONSTRAINT fk_is_in_basics_principals FOREIGN KEY (tconst)
    REFERENCES title_basics(tconst));
    
LOAD DATA INFILE
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_titleprincipals.csv' 
    INTO TABLE title_principals
    FIELDS TERMINATED BY ',' 
	OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (tconst, ordering, nconst, category, job, characters); 

CREATE TABLE title_ratings(
	tconst VARCHAR(50),
    averageRating SMALLINT(50),
    numVotes INT(255),
    PRIMARY KEY (tconst),
	CONSTRAINT fk_is_in_basics_ratings FOREIGN KEY (tconst)
    REFERENCES title_basics(tconst));

LOAD DATA INFILE 
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_titleratings.csv' 
    INTO TABLE title_ratings
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (tconst, averageRating, numVotes); 

CREATE TABLE name_basics(
	nconst VARCHAR(50),
    primaryName VARCHAR(500),
    birthyear SMALLINT(4),
    deathyear SMALLINT(4),
    primaryProfession VARCHAR(500),
    knownForTitles VARCHAR(5000),
    PRIMARY KEY (nconst));
    
LOAD DATA INFILE 
    'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data_namebasics.csv' 
    INTO TABLE name_basics
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (nconst, primaryName, birthyear, deathyear, primaryProfession, knownForTitles); 
    
#Please use the ALTER, UPDATE, CREATE, DROP, SELECT commands to edit the structure of the tables to ensure that each table is in 3NF. 
#Normalize name_basics
CREATE TABLE name_primary_profession (
nconst VARCHAR (50),
primaryProfession VARCHAR(500),
PRIMARY KEY (nconst, primaryProfession),
FOREIGN KEY (nconst) REFERENCES name_basics(nconst));

INSERT INTO name_primary_profession (nconst, primaryProfession)
(SELECT nconst, substring_index(primaryProfession,',',1) values_split FROM name_basics
UNION 
SELECT nconst, substring_index(substring_index(primaryProfession,',',2),',',-1) values_split2 FROM name_basics
UNION
SELECT nconst, substring_index(primaryProfession,',',-1) values_split3 FROM name_basics
ORDER BY nconst);

CREATE TABLE n_known_for_titles (
nconst VARCHAR (50),
knownForTitles VARCHAR (500),
PRIMARY KEY (nconst, knownForTitles),
FOREIGN KEY (nconst) REFERENCES name_basics(nconst),
FOREIGN KEY (knownForTitles) REFERENCES title_basics(tconst));

UPDATE name_basics SET knownForTitles=0 WHERE knownForTitles IS NULL;

INSERT INTO n_known_for_titles (nconst, knownForTitles)
(SELECT nconst, substring_index(knownForTitles,',',1) values_split FROM name_basics
UNION 
SELECT nconst, substring_index(substring_index(knownForTitles,',',2),',',-1) values_split2 FROM name_basics
UNION
SELECT nconst, substring_index(knownForTitles,',',-1) values_split3 FROM name_basics
ORDER BY nconst);

ALTER TABLE name_basics DROP COLUMN `primaryProfession`;
ALTER TABLE name_basics DROP COLUMN `knownForTitles`;

#Normalize title_akas
CREATE TABLE title_akas_type (
tconst VARCHAR (50),
ordering VARCHAR (50),
types VARCHAR (50),
PRIMARY KEY (tconst, ordering),
FOREIGN KEY (tconst) REFERENCES title_akas(tconst));

INSERT INTO title_akas_type (tconst, ordering, types)
(SELECT tconst, ordering, substring_index(types,',',1) values_split FROM title_akas
UNION 
SELECT tconst, ordering, substring_index(substring_index(types,',',2),',',-1) values_split2 FROM title_akas
UNION
SELECT tconst, ordering, substring_index(types,',',-1) values_split3 FROM title_akas
ORDER BY tconst);

CREATE TABLE title_akas_attributes (
tconst VARCHAR (50),
ordering VARCHAR (50),
attributes VARCHAR (500),
PRIMARY KEY (tconst, ordering),
FOREIGN KEY (tconst) REFERENCES title_akas(tconst));

INSERT INTO title_akas_attributes (tconst, ordering, attributes)
(SELECT tconst, ordering, substring_index(attributes,',',1) values_split FROM title_akas
UNION 
SELECT tconst, ordering, substring_index(substring_index(attributes,',',2),',',-1) values_split2 FROM title_akas
UNION
SELECT tconst, ordering, substring_index(attributes,',',-1) values_split3 FROM title_akas
ORDER BY tconst);

ALTER TABLE title_akas DROP COLUMN types;
ALTER TABLE title_akas DROP COLUMN attributes;

#Normalize title_basics
CREATE TABLE title_genres (
tconst VARCHAR (50),
genres VARCHAR (50),
PRIMARY KEY (tconst, genres),
FOREIGN KEY (tconst) REFERENCES title_basics(tconst));

UPDATE title_basics SET genres=0 WHERE genres IS NULL;

INSERT INTO title_genres (tconst, genres)
(SELECT tconst, substring_index(genres,',',1) values_split FROM title_basics
UNION 
SELECT tconst, substring_index(substring_index(genres,',',2),',',-1) values_split2 FROM title_basics
UNION
SELECT tconst, substring_index(genres,',',-1) values_split3 FROM title_basics
ORDER BY tconst);

ALTER TABLE title_basics DROP COLUMN `genres`;

#Normalize title_crews
CREATE TABLE title_directors (
tconst VARCHAR (50),
directors VARCHAR (50),
PRIMARY KEY (tconst, directors), 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst),
FOREIGN KEY (directors) REFERENCES name_basics(nconst));

INSERT INTO title_directors (tconst, directors)
(SELECT tconst, substring_index(directors,',',1) values_split FROM title_directors
UNION 
SELECT tconst, substring_index(substring_index(directors,',',2),',',-1) values_split2 FROM title_directors
UNION
SELECT tconst, substring_index(directors,',',-1) values_split3 FROM title_directors
ORDER BY directors);

CREATE TABLE title_writers (
tconst VARCHAR (50),
writers VARCHAR (50),
PRIMARY KEY (tconst, writers), 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst),
FOREIGN KEY (writers) REFERENCES name_basics(nconst));

INSERT INTO title_writers (tconst, writers)
(SELECT tconst, substring_index(writers,',',1) values_split FROM title_writers
UNION 
SELECT tconst, substring_index(substring_index(writers,',',2),',',-1) values_split2 FROM title_writers
UNION
SELECT tconst, substring_index(writers,',',-1) values_split3 FROM title_writers
ORDER BY writers);

#Normalize title_principals
CREATE TABLE title_characters (
nconst VARCHAR (50),
tconst VARCHAR (50),
characters VARCHAR (50),
PRIMARY KEY (nconst, tconst, characters), 
FOREIGN KEY (nconst) REFERENCES name_basics(nconst),
FOREIGN KEY (tconst) REFERENCES title_basics(tconst));

INSERT INTO title_characters (nconst, tconst, characters)
(SELECT nconst, tconst, characters FROM title_characters
ORDER BY nconst);

ALTER TABLE title_principals DROP COLUMN `characters`;

#Please write a query that lists the title and runtime for the highest rated James Bond starring Sean Connery
SELECT N.nconst, N.primaryName, T.primaryTitle, T.runtimeMinutes, averageRating
FROM name_basics AS N, title_characters AS C, title_basics AS T,  title_ratings AS R
WHERE C.characters LIKE 'James Bond'
AND T.titleType LIKE 'movie'
AND N.primaryName LIKE 'Sean Connery'
AND T.tconst = C.tconst
AND N.nconst = C.nconst
AND T.tconst = R.tconst
ORDER BY averageRating DESC LIMIT 1;
