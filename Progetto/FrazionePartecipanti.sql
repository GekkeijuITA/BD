/*
	Data una categoria e un corso di studi, determinare la frazione
	di partecipanti a eventi di quella categoria di genere
	femminile sul totale dei partecipanti provenienti da quel 
	corso di studi
*/

CREATE OR REPLACE FUNCTION frazionepartecipanti(cat VARCHAR, cds VARCHAR) RETURNS NUMERIC AS
	$$
		DECLARE
			tot_utenti_cds NUMERIC;
			tot_utenti_f_cds NUMERIC;
			cat_des NUMERIC;
			corso_di_studio NUMERIC;
		BEGIN
			cat_des := (SELECT id FROM categoria WHERE denominazione ILIKE cat);
			IF cat_des IS NULL THEN
				RAISE EXCEPTION 'La categoria inserita non esiste';
			END IF;

			corso_di_studio := (SELECT id FROM corsodistudio WHERE denominazione ILIKE cds);
			IF corso_di_studio IS NULL THEN
				RAISE EXCEPTION 'Il corso di studio inserito non esiste';
			END IF;

			tot_utenti_cds := (
				SELECT COUNT(DISTINCT utente) FROM utentegiocaevento 
					JOIN evento E ON evento = E.id 
					JOIN utente U ON utente = U.username
					WHERE E.categoria = cat_des AND U.corsodistudio = corso_di_studio
				);

			IF tot_utenti_cds = 0 THEN
				RETURN 0;
			END IF;

			tot_utenti_f_cds := (
				SELECT COUNT(DISTINCT utente) FROM utentegiocaevento 
					JOIN evento E ON evento = E.id 
					JOIN utente U ON utente = U.username
					WHERE E.categoria = cat_des AND U.corsodistudio = corso_di_studio AND U.genere = 'F'
				);

			RETURN ROUND(tot_utenti_f_cds/tot_utenti_cds, 2);
		END;
	$$
LANGUAGE plpgsql;
	
SELECT frazionepartecipanti('Rugby', 'ingegneria informatica')