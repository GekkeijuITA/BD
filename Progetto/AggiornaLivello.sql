set search_path to "UniGeSocialSport2.0"

/*
	Funzione che dato un giocatore ne calcoli il livello (se si è deciso
	di memorizzare il livello, definire il trigger che mantenga aggiornato
	il valore dell'attributo livello come trigger E.b. e definire invece
	la funzione corrispondente alla seguente query parametrica: data
	una categoria e un corso di studi, determinare la frazione di 
	partecipanti a eventi di quella categoria di genere femminile sul 
	totale dei partecipanti provenienti da quel corso di studi)
*/

CREATE OR REPLACE FUNCTION aggiornalivellovalutazione() RETURNS trigger AS
	$aggiornalivellovalutazione$
		DECLARE
			 new_valutaz RECORD;
			 old_livello NUMERIC;
			 new_livello NUMERIC;
			 categoria_evento NUMERIC;
		BEGIN
			SELECT * INTO new_valutaz FROM utentevalutautente WHERE utente_valutato = NEW.utente_valutato;
			categoria_evento := (SELECT categoria FROM evento WHERE id = new_valutaz.evento);
			old_livello := (SELECT punteggio FROM livello WHERE utente = new_valutaz.utente AND categoria = categoria_evento);
			UPDATE livello SET punteggio = (old_livello + new_valutaz.media) WHERE utente = new_valutaz.utente AND categoria = categoria_evento;
			RETURN NEW;
		END;
	$aggiornalivellovalutazione$
LANGUAGE plpgsql;

CREATE TRIGGER aggiornalivellovalutazione
AFTER INSERT OR UPDATE ON utentevalutautente
FOR EACH ROW
EXECUTE FUNCTION aggiornalivellovalutazione();

CREATE OR REPLACE FUNCTION aggiornalivelloeventochiuso() RETURNS trigger AS
	$aggiornalivelloeventochiuso$
		DECLARE
			new_evento RECORD;
			utente_id VARCHAR(30);
			ritardo BOOLEAN;
			no_show BOOLEAN;
			squadra_temp NUMERIC;
			punti_giocatore NUMERIC;
			cartellino VARCHAR(255);
			squadra_vincente NUMERIC;
			utente_partecipa_evento CURSOR FOR 
				SELECT utente, ritardo, no_show, squadra_temp, punti_giocatore, cartellino 
				FROM utentegiocaevento 
				WHERE evento = NEW.id AND stato = 'accettato';
			old_livello NUMERIC;
			new_livello NUMERIC;
		BEGIN
			IF NEW.stato != 'CHIUSO' THEN
				RETURN NEW;
			END IF;

			SELECT * INTO new_evento FROM evento WHERE id = NEW.id;

			-- Squadra vincente (se esiste)
			IF new_evento.punti_sq1 IS NOT NULL AND new_evento.punti_sq2 IS NOT NULL THEN
				IF new_evento.punti_sq1 > new_evento.punti_sq2 THEN
					squadra_vincente = 1;
				ELSIF new_evento.punti_sq2 > new_evento.punti_sq1 THEN
					squadra_vincente = 2;
				ELSE
					squadra_vincente = 0; -- Pareggio
				END IF;
			END IF; 

			OPEN utente_partecipa_evento;
			FETCH utente_partecipa_evento INTO utente_id, ritardo, no_show, squadra_temp, punti_giocatore, cartellino;
			WHILE FOUND LOOP
					old_livello := (SELECT punteggio FROM livello WHERE utente = utente_id AND categoria = new_evento.categoria);
					new_livello := old_livello;

					IF ritardo IS TRUE THEN
						new_livello := new_livello - 1;
					END IF;

					IF no_show IS TRUE THEN
						new_livello := new_livello - 5;
					ELSE
						IF squadra_temp == squadra_vincente THEN
							new_livello := new_livello + 10;
						ELSIF squadra_vincente != 0 THEN
									new_livello := new_livello - 7;
						END IF;

						IF punti_giocatore IS NOT NULL THEN
							new_livello := new_livello + (punti_giocatore * 0.5);
						END IF;
		
						IF cartellino IS NOT NULL THEN
							IF cartellino = 'giallo' THEN
								new_livello := new_livello - 2;
							ELSIF cartellino = 'rosso' THEN
								new_livello := new_livello - 4;
							END IF;
						END IF;

					END IF;

					UPDATE livello SET punteggio = new_livello WHERE utente = utente_id AND categoria = new_evento.categoria;

					FETCH utente_partecipa_evento INTO utente_id, ritardo, no_show, squadra_temp, punti_giocatore, cartellino;
			END LOOP;
			CLOSE utente_partecipa_evento;
			RETURN NEW;
		END;
	$aggiornalivelloeventochiuso$
LANGUAGE plpgsql;
	
CREATE TRIGGER aggiornalivelloeventochiuso
AFTER INSERT OR UPDATE ON evento
FOR EACH ROW
EXECUTE FUNCTION aggiornalivelloeventochiuso()