set search_path to "UniGeSocialSport2.0";
	
CREATE TABLE CorsoDiStudio(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL
);

CREATE TABLE Categoria(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL,
	num_giocatori NUMERIC NOT NULL,
	regolamento VARCHAR(255) NOT NULL,
	foto VARCHAR(255) NOT NULL
);

CREATE TABLE Impianto(
	nome VARCHAR(255) PRIMARY KEY,
	email VARCHAR(255) NOT NULL UNIQUE,
	telefono CHAR(10) NOT NULL UNIQUE,
	longitudine REAL NOT NULL,
	latitudine REAL NOT NULL,
	via VARCHAR(255) NOT NULL,
	civico NUMERIC NOT NULL,
	interno NUMERIC NOT NULL,
	cap CHAR(5) NOT NULL,
	inizio_disponibilita TIME,
	fine_disponibilita TIME
);

CREATE TABLE Sponsor(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL
);

CREATE TABLE Squadra(
	nome VARCHAR(255) PRIMARY KEY,
	colore_maglia VARCHAR(255),
	descrizione VARCHAR(255),
	note VARCHAR(255),
	num_max_giocatori NUMERIC NOT NULL CHECK (num_max_giocatori >= num_min_giocatori),
	num_min_giocatori NUMERIC NOT NULL CHECK (num_min_giocatori <= num_max_giocatori),
	creatore VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Utente(
	username VARCHAR(30) PRIMARY KEY,
	numero_matricola NUMERIC UNIQUE NOT NULL,
	nome VARCHAR(255) NOT NULL,
	cognome VARCHAR(255) NOT NULL,
	anno_nascita INTEGER NOT NULL,
	foto VARCHAR(255) NOT NULL,
	telefono CHAR(10) UNIQUE NOT NULL,
	affidabile BOOLEAN DEFAULT true,
	premium BOOLEAN DEFAULT false,
	genere CHAR(1) NOT NULL, -- M,F,O
	corsodistudio NUMERIC REFERENCES CorsoDiStudio(id) ON DELETE NO ACTION,
	squadra VARCHAR(255) REFERENCES Squadra(nome) ON DELETE SET NULL ON UPDATE CASCADE,
	stato VARCHAR(255)
);

CREATE TABLE Torneo(
	id NUMERIC PRIMARY KEY,
	descrizione VARCHAR(255) NOT NULL,
	restrizione VARCHAR(255),
	creatore VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Premio(
	id NUMERIC PRIMARY KEY,
	descrizione VARCHAR(255) NOT NULL,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE CASCADE
);

CREATE TABLE Sostituzione(
	id NUMERIC PRIMARY KEY,
	data DATE NOT NULL,
	utente_richiedente VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	utente_sostitutivo VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Livello(
	utente VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	categoria NUMERIC REFERENCES Categoria(id) ON DELETE CASCADE,
	PRIMARY KEY(utente,categoria),
	punteggio INTEGER DEFAULT 0,
	CONSTRAINT livello0_100 CHECK (punteggio >= 0 AND punteggio <= 100)
);

CREATE TABLE Evento(
	id NUMERIC PRIMARY KEY,
	punti_sq1 NUMERIC,
	punti_sq2 NUMERIC,
	stato CHAR(6) DEFAULT 'APERTO',
	data_svolgimento DATE NOT NULL,
	durata TIME NOT NULL,
	categoria NUMERIC REFERENCES Categoria(id) ON DELETE SET NULL,
	impianto VARCHAR(255) REFERENCES Impianto(nome) ON DELETE SET NULL,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE CASCADE,
	organizzatore VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE SponsorFinanziaTorneo(
	sponsor NUMERIC REFERENCES Sponsor(id) ON DELETE NO ACTION,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE SET NULL,
	PRIMARY KEY(sponsor,torneo)
);

CREATE TABLE SquadraPartecipaTorneo(
	squadra VARCHAR(255) REFERENCES Squadra(nome) ON DELETE CASCADE ON UPDATE CASCADE,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE SET NULL,
	PRIMARY KEY(squadra,torneo)
);

CREATE TABLE UtenteValutaUtente(
	utente_valutante VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	utente_valutato VARCHAR(30) REFERENCES Utente(username) ON DELETE CASCADE ON UPDATE CASCADE,
	evento NUMERIC REFERENCES Evento(id) ON DELETE SET NULL,
	PRIMARY KEY(utente_valutante,utente_valutato,evento),
	data_valutazione DATE NOT NULL,
	punteggio NUMERIC,
	CONSTRAINT punteggio0_10 CHECK (punteggio >= 0 AND punteggio <= 10),
	commento VARCHAR(255)
);

CREATE TABLE UtenteGiocaEvento(
	utente VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	evento NUMERIC REFERENCES Evento(id) ON DELETE CASCADE,
	PRIMARY KEY(utente,evento),
	data_iscrizione DATE NOT NULL,
	ruolo VARCHAR(255) DEFAULT 'giocatore',
	ritardo BOOLEAN DEFAULT false,
	no_show BOOLEAN DEFAULT false,
	stato VARCHAR(255) DEFAULT 'in attesa',
	squadra_temp NUMERIC,
	punti_giocatore NUMERIC,
	titolare BOOLEAN DEFAULT false,
	cartellino VARCHAR(255)
);

CREATE OR REPLACE FUNCTION aggiungi_livelli_utenti()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Livello (utente, categoria)
    SELECT NEW.username, id 
    FROM Categoria;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION aggiungi_livelli_categoria()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Livello (utente, categoria)
    SELECT username, NEW.id 
    FROM Utente;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER aggiungi_livelli_utenti AFTER INSERT ON Utente 
	FOR EACH ROW
	EXECUTE FUNCTION  aggiungi_livelli_utenti();

CREATE TRIGGER aggiungi_livelli_categoria AFTER INSERT ON Categoria
	FOR EACH ROW
	EXECUTE FUNCTION aggiungi_livelli_categoria();

CREATE OR REPLACE FUNCTION iscrivi_utenti_a_eventi()
RETURNS TRIGGER AS $$
DECLARE
    evento RECORD;
    utente RECORD;
BEGIN
    -- Per ogni evento del torneo
    FOR evento IN
        SELECT id
        FROM Evento
        WHERE torneo = NEW.torneo
    LOOP
        -- Per ogni utente della squadra
        FOR utente IN
            SELECT username
            FROM Utente
            WHERE squadra = NEW.squadra
        LOOP
            -- Inserisce l'utente nell'evento
            INSERT INTO UtenteGiocaEvento (utente, evento, data_iscrizione)
            VALUES (utente.username, evento.id, CURRENT_DATE);
        END LOOP;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_iscrivi_utenti
AFTER INSERT ON SquadraPartecipaTorneo
FOR EACH ROW
EXECUTE FUNCTION iscrivi_utenti_a_eventi();
