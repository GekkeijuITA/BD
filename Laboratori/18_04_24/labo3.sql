SELECT corsi.id, corsi.denominazione, professori.nome, professori.cognome FROM corsi 
    LEFT JOIN professori ON professore = professori.id ORDER BY corsi.denominazione ASC

SELECT studenti.cognome,studenti.nome, professori.nome, professori.cognome FROM studenti 
	JOIN corsidilaurea ON studenti.corsodilaurea = corsidilaurea.id AND denominazione = 'Matematica' 
	JOIN professori ON studenti.relatore = professori.id ORDER BY studenti.cognome ASC, studenti.nome ASC

SELECT MIN(voto),MAX(voto),AVG(voto) FROM corsidilaurea 
	JOIN corsi ON corsidilaurea.denominazione = 'Informatica' AND corsi.corsodilaurea = corsidilaurea.id 
	JOIN esami ON esami.corso = corsi.id

SELECT nome, cognome, COUNT(corsi) FROM professori JOIN 
	corsi ON corsi.professore = professori.id  AND corsi.attivato IS TRUE
	GROUP BY(professori.nome, professori.cognome) 
	HAVING COUNT(corsi) > 2
	ORDER BY cognome ASC, nome ASC

SELECT corsidilaurea.denominazione, COUNT(*) AS iscritti FROM corsidilaurea 
	JOIN studenti ON studenti.corsodilaurea = corsidilaurea.id
	WHERE iscrizione = 2010
	GROUP BY(corsidilaurea.denominazione)
	HAVING COUNT(*) < (
	SELECT COUNT(*) FROM corsidilaurea 
		JOIN studenti ON studenti.corsodilaurea = corsidilaurea.id 
		WHERE iscrizione = 2010 AND denominazione='Informatica'
	)
