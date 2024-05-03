SELECT matricola,nome,cognome FROM studenti WHERE iscrizione < 2007 AND relatore IS NULL;
SELECT * FROM corsidilaurea WHERE attivazione NOT BETWEEN '2006/2007' AND '2009/2010' ORDER BY facolta ASC,denominazione ASC;
SELECT matricola,nome,cognome FROM studenti WHERE cognome NOT IN('Serra','Melogno','Giunchi') OR residenza IN ('Genova','La Spezia','Savona') ORDER BY matricola DESC;
SELECT matricola FROM studenti WHERE laurea < '2009-01-09' AND (corsodilaurea = (SELECT id FROM corsidilaurea WHERE denominazione = 'Informatica'))
SELECT studenti.cognome,studenti.nome,professori.cognome FROM studenti JOIN professori ON studenti.relatore = professori.id ORDER BY studenti.cognome ASC;
SELECT DISTINCT matricola, cognome, nome 
	FROM (studenti 
    JOIN corsidilaurea 
	ON corsidilaurea.denominazione = 'Informatica' 
        AND studenti.corsodilaurea = corsidilaurea.id 

	JOIN pianidistudio 
    ON anno = 5 AND annoaccademico = 2011 
        AND pianidistudio.studente = studenti.matricola) 

	ORDER BY cognome DESC;

SELECT nome, cognome, 'professore' FROM professori UNION SELECT nome, cognome, 'studente' FROM studenti;

SELECT * FROM esami WHERE 
	data BETWEEN '2010-06-01' 
	AND '2010-06-30' 
	AND voto >= 18
	AND studente IN(SELECT matricola FROM studenti JOIN corsidilaurea ON 
	denominazione = 'Informatica' WHERE corsodilaurea = id)
	AND corso IN(SELECT id FROM corsi WHERE denominazione = 'Basi Di Dati 1' OR denominazione = 'Interfacce Grafiche')