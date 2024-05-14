--1.1
    ALTER TABLE esami ADD CONSTRAINT data_cur CHECK (data <= current_date)
--1.2--
    ALTER TABLE esami ADD CONSTRAINT data_inf CHECK (data < DATE '2014-01-01')
--1.3--
    ALTER TABLE studenti ADD CONSTRAINT relatore_tesi CHECK (
        NOT(
            laurea IS NOT NULL AND 
            relatore IS NULL
        )
    )
--2.1--
INSERT INTO professori VALUES(38,'Prini','Gian Franco', 50000);
INSERT INTO professori VALUES(39,'Bandini', 'Stefania');
INSERT INTO professori VALUES(40,'Rosti'); -- Non funziona perchè nome è NOT NULL
--2.2--
UPDATE professori 
	SET stipendio=stipendio+5000
	WHERE stipendio < 15000
--2.3--
ALTER TABLE esami ALTER COLUMN voto DROP NOT NULL
INSERT INTO corsi VALUES('labinfo',9,'Laboratorio di Informatica')

INSERT INTO esami (studente, corso, data)
	SELECT s.matricola, c.id, CURRENT_DATE FROM studenti s
		JOIN corsidilaurea cdl ON s.corsodilaurea = cdl.id
		JOIN corsi c ON c.corsodilaurea = cdl.id
		WHERE c.denominazione = 'Laboratorio di Informatica' AND s.laurea IS NULL 

--3.1--
CREATE VIEW StudentiNonInTesi AS
    SELECT * FROM studenti WHERE
    relatore IS NULL
--3.2--
SELECT * FROM StudentiNonInTesi WHERE
	luogonascita = 'Genova' AND
	residenza = 'Genova'
--3.3--
CREATE VIEW StudentiMate AS
	SELECT matricola, COUNT(distinct e.data) AS num_esami, AVG(e.voto) AS media FROM studenti s
	JOIN corsidilaurea cl ON s.corsodilaurea = cl.id
	LEFT JOIN esami e ON e.studente = s.matricola
	WHERE denominazione = 'Matematica' AND
	s.laurea IS NULL
	GROUP BY matricola
--3.4--
SELECT SUM(num_esami) FROM studentimate
--3.5--
--3.6--