set search_path to "UniGeSocialSport2.0"

/*
	Funzione che effettua la conferma di un giocatore quale componente di
	una squadra, realizzando gli opportuni controlli;

	Quali potrebbero essere gli opportuni controlli:
	- Che l'utente esista (utente != null)
	- Che l'utente effettivamente abbia fatto richiesta (stato = 'In Attesa')
	- Che l'utente non faccia già parte della squadra o di altra squadra (squadra = squadra && stato = 'In Attesa')
	- Che l'utente1 sia creatore della squadra
*/

CREATE OR REPLACE FUNCTION conferma_squadra(utente1 VARCHAR, utente2 VARCHAR, nome_squadra VARCHAR)
	RETURNS VOID AS
	$$
		DECLARE
			utente_confermante RECORD;
			utente_da_confermare RECORD;
			sq RECORD;
			partecipanti_squadra INTEGER;
		BEGIN
			SELECT * INTO utente_confermante FROM utente WHERE username=utente1;
			SELECT * INTO utente_da_confermare FROM utente WHERE username=utente2;
			SELECT * INTO sq FROM squadra WHERE nome=nome_squadra;
			partecipanti_squadra := (SELECT COUNT(username) FROM utente WHERE squadra=nome_squadra AND stato='Accettato');
				
			IF utente_confermante IS NULL OR utente_da_confermare IS NULL OR sq IS NULL THEN
				RAISE NOTICE 'Errore, uno dei tre campi è nullo';
				RETURN;
			END IF;

			IF sq.creatore <> utente_confermante.username THEN
				RAISE NOTICE 'Non si ha i permessi necessari';
				RETURN;
			END IF;

			IF utente_da_confermare.stato = 'In Attesa' AND utente_da_confermare.squadra = sq.nome THEN
				IF partecipanti_squadra < sq.num_max_giocatori THEN
					UPDATE utente SET stato = 'Accettato' WHERE username = utente_da_confermare.username;
				ELSE
					RAISE NOTICE 'Numero massimo di giocatori raggiunto';
					RETURN;
				END IF;
			ELSE
				RAISE NOTICE 'L''utente non è in attesa per questa squadra';
			END IF;
			RAISE NOTICE 'Accettato con successo!';
		END;
	$$
LANGUAGE plpgsql;

--SELECT conferma_squadra('lbianchi1','cconti1','Squadra A');