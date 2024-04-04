set search_path to "corsi";

CREATE TABLE professori(
	n_id DECIMAL(5) PRIMARY KEY,
	cognome VARCHAR(30) NOT NULL,
	nome VARCHAR(30) NOT NULL,
	stipendio NUMERIC(8,2) DEFAULT 15000.00,
	incongedo BOOL DEFAULT false,
	UNIQUE(cognome,nome)
); 

CREATE TABLE corsi(
	n_id CHAR(10) PRIMARY KEY,
	corso_di_laurea VARCHAR(30) NOT NULL,
	nome_corso VARCHAR(60) NOT NULL,
	attivato BOOL DEFAULT false,
	professore DECIMAL(5) REFERENCES professori(n_id)
	ON UPDATE CASCADE 
	ON DELETE RESTRICT
);

INSERT INTO professori VALUES(12345,'odone','francesca',123456.78,FALSE);
INSERT INTO professori VALUES(67890,'bruno','tommaso',789012.78,FALSE);
INSERT INTO professori VALUES(12367,'caminata','alessio',999999.78,FALSE);

INSERT INTO corsi VALUES('aD4FgHjK7l','Informatica','Introduzione alla Programmazione',TRUE,12345);
INSERT INTO corsi VALUES('9pQ2wErT5y','Informatica','Calculus',TRUE,67890);
INSERT INTO corsi VALUES('6zX8cVbN3m','Informatica','Algebra',TRUE,12367);