/*
	Verifica del vincolo che non è possibile iscriversi a eventi chiusi e che lo
	stato di un evento sportivo diventa CHIUSO quando si raggiunge un numero di 
	giocatori pari a quelli previsto dalla categoria
*/
set search_path to "UniGeSocialSport2.0"

CREATE OR REPLACE FUNCTION check_iscrizione() RETURNS trigger AS
	$check_iscrizione$
		DECLARE
			num_max NUMERIC;
			iscritti NUMERIC;
			Ev RECORD;
		BEGIN
			SELECT * INTO Ev FROM evento WHERE id = NEW.evento;
			IF Ev.stato = 'CHIUSO' THEN
				RAISE EXCEPTION 'L''evento è chiuso, non sono ammesse iscrizioni';
			END IF;
			num_max := (
				SELECT C.num_giocatori FROM evento E
					JOIN categoria C ON C.id = E.categoria
					WHERE E.id = NEW.evento				
			);
			iscritti := (
				SELECT COUNT(*) AS partecipanti FROM utentegiocaevento 
					WHERE evento = NEW.evento
			);
				
			IF iscritti > num_max THEN
				UPDATE evento SET stato = 'CHIUSO' WHERE id = NEW.evento;
				RAISE EXCEPTION 'Numero di giocatori massimi raggiunto';
			END IF;
			RETURN NEW;
		END;
	$check_iscrizione$
LANGUAGE plpgsql
	
CREATE OR REPLACE TRIGGER chiusura_evento
BEFORE INSERT ON utentegiocaevento
FOR EACH ROW
EXECUTE FUNCTION check_iscrizione()


INSERT INTO utentegiocaevento VALUES (
	'alandini1',
	5,
	DATE('2024-03-10'),
	'giocatore',
	FALSE,
	FALSE,
	'in attesa',
	NULL,
	NULL	,
	true,
	NULL
)