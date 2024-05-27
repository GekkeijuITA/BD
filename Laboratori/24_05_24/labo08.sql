CREATE FUNCTION AggiornaStip(soglia NUMERIC) RETURNS INTEGER AS 
	$$
		DECLARE
			mediaStip NUMERIC;
			totStip NUMERIC;
			totStip2 NUMERIC;
		BEGIN
			mediaStip:= 
				(SELECT AVG(p.stipendio) FROM 
					professori p JOIN corsi c 
					ON p.id = c.professore 
					WHERE c.attivato = TRUE);
	
			totStip:=
				(SELECT SUM(stipendio) FROM 
					professori);
			IF mediaStip < soglia THEN
				-- aumento 10%
				UPDATE professori SET stipendio=stipendio * (1+0.10) WHERE id IN (
					SELECT p.id FROM 
								professori p JOIN corsi c 
								ON p.id = c.professore 
								WHERE c.attivato = TRUE
				);
				RAISE NOTICE 'Aumento del 10 per cento applicato';
			ELSE
				-- aumento 5%
				UPDATE professori SET stipendio=stipendio * (1+0.05) WHERE id IN (
				SELECT p.id FROM 
							professori p JOIN corsi c 
							ON p.id = c.professore 
							WHERE c.attivato = TRUE
				);
				RAISE NOTICE 'Aumento del 5 per cento applicato';
			END IF;
	
			totStip2:=
				(SELECT SUM(stipendio) FROM 
					professori);
	
			RETURN totStip2 - totStip;
		END
	$$
	LANGUAGE plpgsql;


SELECT AggiornaStip(150000) AS totale_Aumenti;

CREATE OR REPLACE FUNCTION aggiornastip2(soglia NUMERIC,perc NUMERIC) RETURNS void AS
$$
	DECLARE
		mediaStip NUMERIC;
		professore CURSOR FOR SELECT DISTINCT p.nome,p.cognome,p.stipendio FROM professori p JOIN corsi c ON p.id = c.professore GROUP BY p.id HAVING COUNT(*)<=1 ;
		nomeP VARCHAR(30);
		cognomeP VARCHAR(30);
		stipendioP NUMERIC;
	BEGIN
		mediaStip := (SELECT AVG(p.stipendio) AS stipendio_medio FROM professori p WHERE p.id IN (
						SELECT DISTINCT p.id FROM professori p JOIN corsi c ON p.id = c.professore GROUP BY p.id HAVING COUNT(*)<=1
					  )); -- al più un corso
		IF (soglia > 1000 AND (perc >= 0 AND perc <= 100)) THEN
			RAISE NOTICE 'Parametri corretti';
			IF mediaStip < soglia THEN
				OPEN professore;
				FETCH professore INTO nomeP,cognomeP,stipendioP;
				WHILE FOUND LOOP
					BEGIN
						RAISE NOTICE 'Nome: %', nomeP;
						RAISE NOTICE 'Cognome: %', cognomeP;
						RAISE NOTICE 'Scarto: %', stipendioP - soglia;
						IF stipendioP - soglia < 0 THEN
							RAISE NOTICE 'Scarto negativo!';
						END IF;
						FETCH professore INTO nomeP,cognomeP,stipendioP;
					END;
				END LOOP;
				CLOSE professore;
			END IF;
		ELSE
			RAISE NOTICE 'Paramentri non corretti';
		END IF;
	END;
$$
LANGUAGE plpgsql;


SELECT aggiornastip2(100000,2);



