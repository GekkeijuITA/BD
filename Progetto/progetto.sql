set search_path to "UniGeSocialSport";
	
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
	email VARCHAR(255) NOT NULL,
	telefono CHAR(10) NOT NULL UNIQUE,
	longitudine REAL NOT NULL,
	latitudine REAL NOT NULL,
	via VARCHAR(255) NOT NULL,
	civico NUMERIC NOT NULL,
	interno NUMERIC NOT NULL,
	cap CHAR(5) NOT NULL
);

CREATE TABLE Sponsor(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL
);

CREATE TABLE Premio(
	id NUMERIC PRIMARY KEY,
	descrizione VARCHAR(255) NOT NULL	
);

CREATE TABLE Torneo(
	id NUMERIC PRIMARY KEY,
	descrizione VARCHAR(255) NOT NULL,
	restrizione VARCHAR(255) 
);

CREATE TABLE Utente(
	username VARCHAR(30) PRIMARY KEY,
	numero_matricola NUMERIC UNIQUE NOT NULL,
	nome VARCHAR(255) NOT NULL,
	cognome VARCHAR(255) NOT NULL,
	anno_nascita INTEGER NOT NULL,
	foto VARCHAR(255) NOT NULL,
	telefono CHAR(10) UNIQUE NOT NULL,
	affidabile BOOLEAN DEFAULT false,
	premium BOOLEAN DEFAULT false,
	corsodistudio NUMERIC REFERENCES CorsoDiStudio(id) ON DELETE NO ACTION
);

CREATE TABLE Sostituzione(
	id NUMERIC PRIMARY KEY,
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
	categoria NUMERIC REFERENCES Categoria(id) ON DELETE SET NULL,
	impianto VARCHAR(255) REFERENCES Impianto(nome) ON DELETE SET NULL,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE CASCADE
);

CREATE TABLE Squadra(
	nome VARCHAR(255) PRIMARY KEY,
	colore_maglia VARCHAR(255),
	descrizione VARCHAR(255),
	note VARCHAR(255),
	num_max_giocatori NUMERIC NOT NULL,
	num_min_giocatori NUMERIC NOT NULL,
	creatore VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
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

CREATE TABLE UtenteFaParteSquadra(
	utente VARCHAR(30) REFERENCES Utente(username) ON DELETE CASCADE ON UPDATE CASCADE,
	squadra VARCHAR(255) REFERENCES Squadra(nome) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(utente,squadra),
	stato VARCHAR(10) DEFAULT 'In corso' 
);

CREATE TABLE UtenteValutaUtente(
	utente_valutante VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	utente_valutato VARCHAR(30) REFERENCES Utente(username) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(utente_valutante,utente_valutato),
	data_valutazione DATE NOT NULL,
	punteggio NUMERIC,
	CONSTRAINT punteggio0_10 CHECK (punteggio >= 0 AND punteggio <= 10),
	commento VARCHAR(255)
);

CREATE TABLE UtenteIscriveEvento(
	utente VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	evento NUMERIC REFERENCES Evento(id) ON DELETE CASCADE,
	PRIMARY KEY(utente,evento),
	data_iscrizione DATE NOT NULL,
	ruolo VARCHAR(255) DEFAULT 'giocatore',
	ritardo BOOLEAN DEFAULT false,
	no_show BOOLEAN DEFAULT false,
	stato VARCHAR(255)
);