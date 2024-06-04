set search_path to "UniGeSocialSport"

SELECT U.utente FROM utenteiscriveevento U JOIN 
	evento E ON U.evento = E.id AND E.stato = 'CHIUSO'
	WHERE U.stato = 'accettato' AND U.no_show = false
	GROUP BY U.utente
	HAVING COUNT(DISTINCT evento) = 
		(SELECT COUNT(DISTINCT categoria) FROM evento WHERE stato = 'CHIUSO')

--Ipotetica query se si aggiunge il campo 'durata' a evento
SELECT SUM(EXTRACT('MINUTE' FROM durata) + (EXTRACT('HOUR' FROM durata) * 60)) AS utilizzo FROM evento GROUP BY impianto

--Ipotetica query se si aggiunge il campo 'orari_disponibilità' a impianto (in un giorno)
SELECT SUM(EXTRACT('MINUTE' FROM I.orari_disponibilita) + (EXTRACT('HOUR' FROM I.orari_disponibilita) * 60)) AS disponibilita_minuti FROM impianto

--Ipotetica query per calcolare la disponibilità e l'utilizzo per mese
SELECT 
    EXTRACT(MONTH FROM E.data_svolgimento) AS mese,
    E.impianto, 
    SUM(EXTRACT('MINUTE' FROM E.durata) + (EXTRACT('HOUR' FROM E.durata) * 60)) AS utilizzo_eventi,
    SUM(EXTRACT('MINUTE' FROM I.orari_disponibilita) + (EXTRACT('HOUR' FROM I.orari_disponibilita) * 60)) AS disponibilita_minuti
FROM 
    evento E
JOIN
    impianti I ON E.impianto = I.id
GROUP BY 
    mese, E.impianto;

-- Conta quanti eventi (non di un torneo) ci sono in un impianto e di una categoria e conta anche i partecipanti
SELECT E.impianto, C.denominazione AS categoria, COUNT(E.id) AS eventi, partecipanti, corsi_Di_Studio_Partecipanti, torneo IS NOT NULL as torneo, EXTRACT('MONTH' FROM data_svolgimento) AS mese_svolgimento, 'durata' AS durata_in_minuti
	FROM evento E JOIN categoria C ON E.id = C.id
	LEFT JOIN (SELECT evento, COUNT(*) AS partecipanti FROM utenteiscriveevento GROUP BY evento) P ON C.id = P.evento 
	LEFT JOIN (
		SELECT evento, COUNT(denominazione) AS corsi_Di_Studio_Partecipanti FROM utenteiscriveevento JOIN
		utente U ON utente = U.username
		JOIN corsodistudio ON id = U.corsodistudio
		GROUP BY evento
	) CDS ON CDS.evento = E.id
	GROUP BY denominazione, impianto, partecipanti, EXTRACT('MONTH' FROM data_svolgimento), corsi_Di_Studio_Partecipanti, torneo	


-- Contare per evento gli studenti che partecipano a una categoria suddividendoli per cds
SELECT COUNT(*) AS partecipanti, categoria, denominazione FROM utenteiscriveevento 
	JOIN evento E ON evento = E.id
	JOIN utente U ON utente = U.username
	JOIN corsodistudio CDS ON CDS.id = U.corsodistudio
	GROUP BY categoria, denominazione

-- Selezionare il massimo dalla query prima
SELECT DISTINCT MAX(partecipanti) AS partecipanti_massimi, categoria FROM (
	SELECT COUNT(*) AS partecipanti, categoria FROM utenteiscriveevento 
	JOIN evento E ON evento = E.id
	JOIN utente U ON utente = U.username
	GROUP BY categoria
)
GROUP BY categoria
ORDER BY categoria


-- Selezionare i corsi di studio con il numero massimo di partecipanti per categoria
SELECT partecipanti_massimi, (SELECT denominazione FROM corsodistudio WHERE id = corsodistudio) FROM (
		SELECT DISTINCT MAX(partecipanti) AS partecipanti_massimi, categoria, corsodistudio FROM (
			SELECT COUNT(*) AS partecipanti, categoria FROM utenteiscriveevento 
			JOIN evento E ON evento = E.id
			JOIN utente U ON utente = U.username
			GROUP BY categoria
		)
		GROUP BY categoria
)










