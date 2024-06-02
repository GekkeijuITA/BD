set search_path to "UniGeSocialSport"

SELECT * FROM utenteiscriveevento ORDER BY evento;

SELECT U.utente FROM utenteiscriveevento U JOIN 
	evento E ON U.evento = E.id AND E.stato = 'CHIUSO'
	WHERE U.stato = 'accettato' AND U.no_show = false
	GROUP BY U.utente
	HAVING COUNT(DISTINCT evento) = 
		(SELECT COUNT(DISTINCT categoria) FROM evento WHERE stato = 'CHIUSO')

