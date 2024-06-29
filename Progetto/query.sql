set search_path to "UniGeSocialSport"

-- Utenti che hanno partecipato agli eventi di ogni categoria
SELECT U.utente FROM utenteiscriveevento U JOIN 
	evento E ON U.evento = E.id AND E.stato = 'CHIUSO'
	WHERE U.stato = 'accettato' AND U.no_show = false
	GROUP BY U.utente
	HAVING COUNT(DISTINCT evento) = 
		(SELECT COUNT(DISTINCT categoria) FROM evento WHERE stato = 'CHIUSO')

--Ipotetica query se si aggiunge il campo 'durata' a evento
SELECT impianto, SUM(EXTRACT('MINUTE' FROM durata) + (EXTRACT('HOUR' FROM durata) * 60)) AS utilizzo 
	FROM evento 
	GROUP BY impianto

-- Disponibilità giornaliera per impianto (in minuti)
SELECT 
	nome, SUM((EXTRACT('MINUTE' FROM I.fine_disponibilita) - EXTRACT('MINUTE' FROM I.inizio_disponibilita)) + ((EXTRACT('HOUR' FROM I.fine_disponibilita) * 60)-(EXTRACT('HOUR' FROM I.inizio_disponibilita) * 60))) AS disponibilita_minuti 
	FROM impianto I
	GROUP BY nome

--Ipotetica query per calcolare la disponibilità e l'utilizzo per mese
SELECT 
    EXTRACT(MONTH FROM E.data_svolgimento) AS mese,
    E.impianto, 
    SUM(EXTRACT('MINUTE' FROM E.durata) + (EXTRACT('HOUR' FROM E.durata) * 60)) AS utilizzo_eventi,
    SUM((EXTRACT('MINUTE' FROM I.fine_disponibilita) - EXTRACT('MINUTE' FROM I.inizio_disponibilita)) + ((EXTRACT('HOUR' FROM I.fine_disponibilita) - EXTRACT('HOUR' FROM I.inizio_disponibilita))*60)) AS disponibilita_minuti
FROM 
    evento E
JOIN
    impianto I ON E.impianto = I.nome
GROUP BY 
    mese, E.impianto
ORDER BY mese

-- Conta quanti eventi (non di un torneo) ci sono in un impianto e di una categoria e conta anche i partecipanti
SELECT 
	E.impianto, C.denominazione AS categoria, COUNT(E.id) AS eventi, partecipanti, corsi_Di_Studio_Partecipanti, 
	torneo IS NOT NULL as torneo, EXTRACT('MONTH' FROM data_svolgimento) AS mese_svolgimento 
	FROM evento E JOIN categoria C ON E.id = C.id
	LEFT JOIN (SELECT evento, COUNT(*) AS partecipanti FROM utenteiscriveevento GROUP BY evento) P ON C.id = P.evento 
	LEFT JOIN (
		SELECT evento, COUNT(denominazione) AS corsi_Di_Studio_Partecipanti FROM utenteiscriveevento JOIN
		utente U ON utente = U.username
		JOIN corsodistudio ON id = U.corsodistudio
		GROUP BY evento
	) CDS ON CDS.evento = E.id
	GROUP BY denominazione, impianto, partecipanti, mese_svolgimento, corsi_Di_Studio_Partecipanti, torneo	


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
		SELECT DISTINCT MAX(partecipanti) AS partecipanti_massimi, categoria FROM (
			SELECT COUNT(*) AS partecipanti, categoria FROM utenteiscriveevento 
			JOIN evento E ON evento = E.id
			JOIN utente U ON utente = U.username
			GROUP BY categoria
		)
		GROUP BY categoria
)

-- Funzione che effettua la conferma di un giocatore quale componente di una squadra, realizzando gli opportuni controlli
CREATE OR REPLACE FUNCTION in_squadra(nome_giocatore VARCHAR, nome_squadra VARCHAR) RETURNS BOOLEAN AS
$$
	DECLARE
		componenti_squadra CURSOR FOR SELECT DISTINCT utente FROM utentefapartesquadra WHERE squadra = nome_squadra AND stato = 'Accettato';
		utente VARCHAR;
	BEGIN
		OPEN componenti_squadra;
		FETCH componenti_squadra INTO utente;
		WHILE FOUND LOOP
			BEGIN
				IF utente = nome_giocatore THEN
					RAISE NOTICE 'Fa parte della squadra';
					CLOSE componenti_squadra;
					RETURN true;
				END IF;
				FETCH componenti_squadra INTO utente;
			END;
		END LOOP;
		RAISE NOTICE 'Non fa parte della squadra';
		CLOSE componenti_squadra;
		RETURN false;
	END;
$$
LANGUAGE plpgsql;

SELECT in_squadra('anna_neri', 'Squadra Blu')

-- Si parte dal livello corrente del giocatore, 
	--una valutazione positiva +0.5, 
	--una valutazione negativa -0.75, 
	--una vittoria +1, 
	--una sconfitta -1.5, 
	--ritardo -0.3, 
	--no_show -2
CREATE OR REPLACE FUNCTION aggiorna_livello_fun(nome_giocatore VARCHAR, categoria NUMERIC) RETURN VOID AS
	$$
		DECLARE
		BEGIN
		END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER aggiorna_livello 
	AFTER INSERT 
	ON
	WHEN 
	EXECUTE FUNCTION

