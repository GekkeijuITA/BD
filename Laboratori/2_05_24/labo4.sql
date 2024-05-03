SELECT DISTINCT * FROM esami WHERE 
	data BETWEEN '2010-06-01' 
	AND '2010-06-30' 
	AND voto >= 18
	AND EXISTS 
	( SELECT * FROM studenti JOIN corsidilaurea 
		ON denominazione = 'Informatica' 
		WHERE corsodilaurea = id
		AND esami.studente = matricola )
	AND EXISTS (
	SELECT * FROM corsi WHERE 
		denominazione IN('Basi Di Dati 1','Interfacce Grafiche') 
		AND esami.corso = id 
	)

SELECT DISTINCT matricola 
	FROM studenti 
	JOIN corsidilaurea ON corsodilaurea = corsidilaurea.id 
	JOIN esami ON studente = matricola 
	JOIN corsi ON corso = corsi.id 
	WHERE corsidilaurea.denominazione = 'Informatica'
	AND corsi.denominazione = 'Basi Di Dati 1'
	AND voto >= (SELECT AVG(voto) FROM esami 
		JOIN corsi ON corso = id 
		WHERE denominazione = 'Basi Di Dati 1')
	
SELECT DISTINCT nome, cognome 
	FROM professori
	JOIN corsi ON corsi.professore = professori.id
	GROUP BY(nome,cognome)
	HAVING (COUNT(corsi.id) >= (
		SELECT COUNT(corsi.id)
		FROM corsi 
		JOIN professori ON corsi.professore = professori.id
		ORDER BY COUNT(corsi.id) DESC 
		LIMIT 1
	))
	