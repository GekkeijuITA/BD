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

DROP FUNCTION aggiornalivellovalutazione

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
			utente_partecipa_evento CURSOR FOR SELECT utente, ritardo, no_show, squadra_temp, punti_giocatore, cartellino FROM utentegiocaevento WHERE evento = NEW.id AND stato = 'accettato';
			
		BEGIN
			SELECT * INTO new_evento FROM evento WHERE id = NEW.id AND stato = 'CHIUSO';
			OPEN utente_partecipa_evento;
			FETCH utente_partecipa_evento INTO utente_id, ritardo, no_show, squadra_temp, punti_giocatore, cartellino;
			WHILE FOUND LOOP
				-- Devo guardare se ritardo o no_show se è no_show non mi importa del resto altrimenti devo guardare la squadra_temp, se ha fatto punti e se ha preso cartellini
				BEGIN
					IF ritardo IS TRUE THEN
						
					END IF;
					FETCH utente_partecipa_evento INTO utente_id;
				END;
			END LOOP;
			CLOSE utente_partecipa_evento;

END;
	$aggiornalivelloeventochiuso$
LANGUAGE plpgsql;
	
CREATE TRIGGER aggiornalivelloeventochiuso
AFTER INSERT OR UPDATE ON eventi
FOR EACH ROW
EXECUTE FUNCTION aggiornalivelloeventochiuso()