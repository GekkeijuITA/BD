set search_path to "UniGeSocialSport2.0"

/*
	Definizione di una vista "Programma" che per ogni impianto
	e mese riassume tornei e eventi che si svolgono in tale impianto,
	evidenziando in particolare per ogni categoria il numero di tornei,
	il numero di eventi, il numero di partecipanti coinvolti e di quanti
	diversi corsi di studio, la durata totale (in termini di minuti) di
	utilizzo e la percentuale di utilizzo rispetto alla disponibilità
	complessiva (minuti totali nel mese in cui l'impianto è utilizzabile)
*/
DROP VIEW programma
	
CREATE OR REPLACE VIEW programma AS (SELECT 
	E.impianto, 
	C.denominazione AS categoria, 
	COUNT(DISTINCT E.id) AS eventi, 
	COUNT(DISTINCT E.torneo) AS tornei, 
	COUNT(utente) AS partecipanti, 
	COUNT(DISTINCT corsodistudio) AS corsi_di_studio,
	--TO_CHAR(E.data_svolgimento, 'Month') AS mese_svolgimento,
	EXTRACT('MONTH' FROM E.data_svolgimento) AS mese_svolgimento,
	SUM(EXTRACT('HOUR' FROM E.durata) * 60 + EXTRACT('MINUTE' FROM E.durata)) AS utilizzo_minuti,
	(EXTRACT('HOUR' FROM I.fine_disponibilita) * 60 + EXTRACT('MINUTE' FROM I.fine_disponibilita) - 
		EXTRACT('HOUR' FROM I.inizio_disponibilita) * 60 + EXTRACT('MINUTE' FROM I.inizio_disponibilita)) * (EXTRACT('DAY' FROM (date_trunc('month', now()) + interval '1 month - 1 day')::date)) AS disponibilita_minuti,
	ROUND((SUM(EXTRACT('HOUR' FROM E.durata) * 60 + EXTRACT('MINUTE' FROM E.durata)) / ((EXTRACT('HOUR' FROM I.fine_disponibilita) * 60 + EXTRACT('MINUTE' FROM I.fine_disponibilita) - 
		EXTRACT('HOUR' FROM I.inizio_disponibilita) * 60 + EXTRACT('MINUTE' FROM I.inizio_disponibilita)) * (EXTRACT('DAY' FROM (date_trunc('month', now()) + interval '1 month - 1 day')::date)))) * 100, 2) AS perc_utilizzo
	
FROM evento E JOIN categoria C ON E.categoria = C.id 
	JOIN utentegiocaevento UE ON E.id = UE.evento
	JOIN utente U ON U.username = UE.utente
	JOIN impianto I ON E.impianto = I.nome
GROUP BY E.impianto,C.denominazione, mese_svolgimento, I.inizio_disponibilita, I.fine_disponibilita
ORDER BY E.impianto, mese_svolgimento)

SELECT * FROM programma