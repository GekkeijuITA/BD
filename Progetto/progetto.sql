create schema "UniGeSocialSport";

set search_path to "UniGeSocialSport";
	
CREATE TABLE CorsoDiStudio(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL
);

INSERT INTO CorsoDiStudio VALUES (1, 'Ingegneria Informatica');
INSERT INTO CorsoDiStudio VALUES (2, 'Medicina e Chirurgia');
INSERT INTO CorsoDiStudio VALUES (3, 'Economia e Commercio');
INSERT INTO CorsoDiStudio VALUES (4, 'Giurisprudenza');
INSERT INTO CorsoDiStudio VALUES (5, 'Lettere Moderne');
INSERT INTO CorsoDiStudio VALUES (6, 'Scienze Biologiche');
INSERT INTO CorsoDiStudio VALUES (7, 'Ingegneria Meccanica');
INSERT INTO CorsoDiStudio VALUES (8, 'Scienze Politiche');
INSERT INTO CorsoDiStudio VALUES (9, 'Architettura');
INSERT INTO CorsoDiStudio VALUES (10, 'Psicologia');

CREATE TABLE Categoria(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL,
	num_giocatori NUMERIC NOT NULL,
	regolamento VARCHAR(255) NOT NULL,
	foto VARCHAR(255) NOT NULL
);

INSERT INTO Categoria VALUES (1, 'Calcio', 11, 'Regolamento FIFA', 'calcio.jpg');
INSERT INTO Categoria VALUES (2, 'Basket', 5, 'Regolamento FIBA', 'basket.jpg');
INSERT INTO Categoria VALUES (3, 'Pallavolo', 6, 'Regolamento FIVB', 'pallavolo.jpg');
INSERT INTO Categoria VALUES (4, 'Tennis', 1, 'Regolamento ITF', 'tennis.jpg');
INSERT INTO Categoria VALUES (5, 'Rugby', 15, 'Regolamento World Rugby', 'rugby.jpg');
INSERT INTO Categoria VALUES (6, 'Hockey su prato', 11, 'Regolamento FIH', 'hockey_prato.jpg');
INSERT INTO Categoria VALUES (7, 'Pallanuoto', 7, 'Regolamento FINA', 'pallanuoto.jpg');
INSERT INTO Categoria VALUES (8, 'Baseball', 9, 'Regolamento WBSC', 'baseball.jpg');
INSERT INTO Categoria VALUES (9, 'Cricket', 11, 'Regolamento ICC', 'cricket.jpg');
INSERT INTO Categoria VALUES (10, 'Golf', 1, 'Regolamento R&A', 'golf.jpg');


CREATE TABLE Impianto(
	nome VARCHAR(255) PRIMARY KEY,
	email VARCHAR(255) NOT NULL UNIQUE,
	telefono CHAR(10) NOT NULL UNIQUE,
	longitudine REAL NOT NULL,
	latitudine REAL NOT NULL,
	via VARCHAR(255) NOT NULL,
	civico NUMERIC NOT NULL,
	interno NUMERIC NOT NULL,
	cap CHAR(5) NOT NULL
);

INSERT INTO Impianto VALUES 
('Palasport di Genova', 'info@palasportgenova.it', '0101234567', 8.939, 44.407, 'Piazzale delle Feste', 1, 0, '16128');
INSERT INTO Impianto VALUES 
('Stadio Luigi Ferraris', 'info@luigiferraris.it', '0102345678', 8.952, 44.416, 'Via Giovanni De Prà', 2, 0, '16139');
INSERT INTO Impianto VALUES 
('Piscina Sciorba', 'info@piscinasciorba.it', '0103456789', 8.951, 44.429, 'Via Gelasio Adamoli', 3, 0, '16141');
INSERT INTO Impianto VALUES 
('RDS Stadium', 'info@rdsstadiumgenova.it', '0104567890', 8.914, 44.398, 'Lungomare Canepa', 4, 0, '16149');
INSERT INTO Impianto VALUES 
('Palazzetto dello Sport', 'info@palazzettosportgenova.it', '0105678901', 8.950, 44.424, 'Corso Sardegna', 5, 0, '16142');
INSERT INTO Impianto VALUES 
('Complesso Polisportivo', 'info@complessopolisportivogenova.it', '0106789012', 8.940, 44.403, 'Via San Vincenzo', 6, 0, '16121');
INSERT INTO Impianto VALUES 
('Arena Albaro Village', 'info@arenaalbarovillage.it', '0107890123', 8.976, 44.391, 'Via dei Mille', 7, 0, '16147');
INSERT INTO Impianto VALUES 
('Campo Sportivo Carlini', 'info@carlini.it', '0108901234', 8.970, 44.410, 'Via Vernazza', 8, 0, '16138');
INSERT INTO Impianto VALUES 
('Palazzo Ducale', 'info@palazzoducale.it', '0109012345', 8.934, 44.407, 'Piazza Matteotti', 9, 0, '16123');
INSERT INTO Impianto VALUES 
('Teatro Carlo Felice', 'info@teatrocarlofelice.it', '0100123456', 8.933, 44.407, 'Passo Eugenio Montale', 10, 0, '16121');

CREATE TABLE Sponsor(
	id NUMERIC PRIMARY KEY,
	denominazione VARCHAR(255) NOT NULL
);

INSERT INTO Sponsor VALUES (1, 'Nike');
INSERT INTO Sponsor VALUES (2, 'Adidas');
INSERT INTO Sponsor VALUES (3, 'Puma');
INSERT INTO Sponsor VALUES (4, 'Reebok');
INSERT INTO Sponsor VALUES (5, 'Under Armour');
INSERT INTO Sponsor VALUES (6, 'New Balance');
INSERT INTO Sponsor VALUES (7, 'Asics');
INSERT INTO Sponsor VALUES (8, 'Fila');
INSERT INTO Sponsor VALUES (9, 'Converse');
INSERT INTO Sponsor VALUES (10, 'Lotto');

CREATE TABLE Premio(
	id NUMERIC PRIMARY KEY,
	descrizione VARCHAR(255) NOT NULL	
);

INSERT INTO Premio VALUES (1, 'Medaglia d''Oro');
INSERT INTO Premio VALUES (2, 'Medaglia d''Argento');
INSERT INTO Premio VALUES (3, 'Medaglia di Bronzo');
INSERT INTO Premio VALUES (4, 'Trofeo del Campione');
INSERT INTO Premio VALUES (5, 'Coppa della Vittoria');
INSERT INTO Premio VALUES (6, 'Premio Miglior Giocatore');
INSERT INTO Premio VALUES (7, 'Premio Fair Play');
INSERT INTO Premio VALUES (8, 'Premio della Critica');
INSERT INTO Premio VALUES (9, 'Targa di Riconoscimento');
INSERT INTO Premio VALUES (10, 'Premio alla Carriera');

CREATE TABLE Torneo(
	id NUMERIC PRIMARY KEY,
	descrizione VARCHAR(255) NOT NULL,
	restrizione VARCHAR(255) 
);

INSERT INTO Torneo VALUES (1, 'Torneo Universitario di Calcio', 'Corso di Studio: Giurisprudenza');
INSERT INTO Torneo VALUES (2, 'Torneo di Basket per Studenti', 'Età: Under 25');
INSERT INTO Torneo VALUES (3, 'Torneo Open di Tennis', NULL);
INSERT INTO Torneo VALUES (4, 'Torneo di Rugby Interfacoltà', NULL);
INSERT INTO Torneo VALUES (5, 'Torneo di Pallavolo Misto', NULL);
INSERT INTO Torneo VALUES (6, 'Torneo di Scacchi per Appassionati', NULL);
INSERT INTO Torneo VALUES (7, 'Torneo di Nuoto Universitario', NULL);
INSERT INTO Torneo VALUES (8, 'Torneo di Atletica Leggera per Studenti', 'Età: Under 30');
INSERT INTO Torneo VALUES (9, 'Torneo di Golf per Principianti', 'Corso di Studio: Psicologia');
INSERT INTO Torneo VALUES (10, 'Torneo di Ping Pong Libero', NULL);

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

INSERT INTO Utente VALUES ('mario88', 123456, 'Mario', 'Rossi', 1995, 'mario.jpg', '0123456789', true, false, 1);
INSERT INTO Utente VALUES ('laura_b', 234567, 'Laura', 'Bianchi', 1998, 'laura.jpg', '0234567890', true, true, 2);
INSERT INTO Utente VALUES ('luigi_v', 345678, 'Luigi', 'Verdi', 1997, 'luigi.jpg', '0345678901', false, false, 3);
INSERT INTO Utente VALUES ('anna_neri', 456789, 'Anna', 'Neri', 1996, 'anna.jpg', '0456789012', true, false, 4);
INSERT INTO Utente VALUES ('chiara_rosa', 567890, 'Chiara', 'Rosa', 1999, 'chiara.jpg', '0567890123', true, true, 5);
INSERT INTO Utente VALUES ('giovanniG', 678901, 'Giovanni', 'Gialli', 1994, 'giovanni.jpg', '0678901234', true, false, 6);
INSERT INTO Utente VALUES ('francesca_blu', 789012, 'Francesca', 'Blu', 1993, 'francesca.jpg', '0789012345', false, false, 7);
INSERT INTO Utente VALUES ('paoloA', 890123, 'Paolo', 'Arancioni', 2000, 'paolo.jpg', '0890123456', true, true, 8);
INSERT INTO Utente VALUES ('eleonora_v', 901234, 'Eleonora', 'Viola', 1992, 'eleonora.jpg', '0901234567', false, false, 9);
INSERT INTO Utente VALUES ('rick_marr', 012345, 'Riccardo', 'Marrone', 1991, 'riccardo.jpg', '0012345678', true, true, 10);

CREATE TABLE Sostituzione(
	id NUMERIC PRIMARY KEY,
	utente_richiedente VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	utente_sostitutivo VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO Sostituzione VALUES (1, 'mario88', 'laura_b');
INSERT INTO Sostituzione VALUES (2, 'luigi_v', 'anna_neri');
INSERT INTO Sostituzione VALUES (3, 'chiara_rosa', 'giovanniG');
INSERT INTO Sostituzione VALUES (4, 'francesca_blu', 'paoloA');
INSERT INTO Sostituzione VALUES (5, 'mario88', 'paoloA');
INSERT INTO Sostituzione VALUES (6, 'eleonora_v', 'rick_marr');
INSERT INTO Sostituzione VALUES (7, 'rick_marr', 'mario88');
INSERT INTO Sostituzione VALUES (8, 'laura_b', 'luigi_v');

CREATE TABLE Livello(
	utente VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE,
	categoria NUMERIC REFERENCES Categoria(id) ON DELETE CASCADE,
	PRIMARY KEY(utente,categoria),
	punteggio INTEGER DEFAULT 0,
	CONSTRAINT livello0_100 CHECK (punteggio >= 0 AND punteggio <= 100)
);

-- Utente: mario88
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 1, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 2, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 3, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 4, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 5, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 6, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 7, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 8, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 9, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('mario88', 10, 70);

-- Utente: laura_b
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 1, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 2, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 3, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 4, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 5, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 6, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 7, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 8, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 9, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('laura_b', 10, 70);

-- Utente: luigi_v
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 1, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 2, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 3, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 4, 95);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 5, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 6, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 7, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 8, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 9, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('luigi_v', 10, 85);

-- Utente: anna_neri
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 1, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 2, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 3, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 4, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 5, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 6, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 7, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 8, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 9, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('anna_neri', 10, 75);

-- Utente: chiara_rosa
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 1, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 2, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 3, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 4, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 5, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 6, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 7, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 8, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 9, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 10, 85);

-- Utente: giovanniG
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 1, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 2, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 3, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 4, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 5, 70);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 6, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 7, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 8, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 9, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('giovanniG', 10, 70);

-- Utente: francesca_blu
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 1, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 2, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 3, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 4, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 5, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 6, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 7, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 8, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 9, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('francesca_blu', 10, 90);

-- Utente: paoloA
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 1, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 2, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 3, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 4, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 5, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 6, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 7, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 8, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 9, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('paoloA', 10, 75);

-- Utente: eleonora_v
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 1, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 2, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 3, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 4, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 5, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 6, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 7, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 8, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 9, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('eleonora_v', 10, 90);

-- Utente: rick_marr
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 1, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 2, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 3, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 4, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 5, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 6, 80);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 7, 85);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 8, 90);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 9, 75);
INSERT INTO Livello (utente, categoria, punteggio) VALUES ('rick_marr', 10, 80);

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

INSERT INTO Evento VALUES 
(1, 20, 18, 'APERTO', '2024-06-10', 1, 'Arena Albaro Village', 1),
(2, 25, 22, 'APERTO', '2024-06-12', 2, 'Campo Sportivo Carlini', 2),
(3, 3, 0, 'APERTO', '2024-06-15', 3, 'Complesso Polisportivo', NULL),
(4, 35, 30, 'APERTO', '2024-06-18', 4, 'Palasport di Genova', 4),
(5, 2, 1, 'APERTO', '2024-06-20', 5, 'Palazzetto dello Sport', NULL);

CREATE TABLE Squadra(
	nome VARCHAR(255) PRIMARY KEY,
	colore_maglia VARCHAR(255),
	descrizione VARCHAR(255),
	note VARCHAR(255),
	num_max_giocatori NUMERIC NOT NULL,
	num_min_giocatori NUMERIC NOT NULL,
	creatore VARCHAR(30) REFERENCES Utente(username) ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO Squadra VALUES 
('Squadra Rossa', 'Rosso', 'Passione e determinazione sul campo!', NULL, 15, 8, 'mario88'),
('Squadra Blu', 'Blu', 'Unisciti a noi e vola alto nello sport!', 'Squadra per principianti', 12, 5, 'laura_b');

CREATE TABLE SponsorFinanziaTorneo(
	sponsor NUMERIC REFERENCES Sponsor(id) ON DELETE NO ACTION,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE SET NULL,
	PRIMARY KEY(sponsor,torneo)
);

INSERT INTO SponsorFinanziaTorneo VALUES (1, 3);
INSERT INTO SponsorFinanziaTorneo VALUES (2, 1);
INSERT INTO SponsorFinanziaTorneo VALUES (3, 4);
INSERT INTO SponsorFinanziaTorneo VALUES (4, 5);

CREATE TABLE SquadraPartecipaTorneo(
	squadra VARCHAR(255) REFERENCES Squadra(nome) ON DELETE CASCADE ON UPDATE CASCADE,
	torneo NUMERIC REFERENCES Torneo(id) ON DELETE SET NULL,
	PRIMARY KEY(squadra,torneo)
);

INSERT INTO SquadraPartecipaTorneo VALUES ('Squadra Rossa', 1);
INSERT INTO SquadraPartecipaTorneo VALUES ('Squadra Blu', 1);

CREATE TABLE UtenteFaParteSquadra(
	utente VARCHAR(30) REFERENCES Utente(username) ON DELETE CASCADE ON UPDATE CASCADE,
	squadra VARCHAR(255) REFERENCES Squadra(nome) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(utente,squadra),
	stato VARCHAR(10) DEFAULT 'In corso' 
);

INSERT INTO UtenteFaParteSquadra VALUES 
('mario88', 'Squadra Rossa', 'Accettato'),
('laura_b', 'Squadra Blu', 'Accettato'),
('luigi_v', 'Squadra Rossa', 'Accettato'),
('anna_neri', 'Squadra Blu', 'Accettato'),
('giovanniG', 'Squadra Rossa', 'Accettato'),
('francesca_blu', 'Squadra Blu', 'Accettato');

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

-- Recensioni per mario88
INSERT INTO UtenteValutaUtente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES 
('laura_b', 'mario88', 1, '2024-06-11', 7, 'Buon compagno di squadra'),
('luigi_v', 'mario88', 1, '2024-06-12', 4, 'Poco collaborativo');

-- Recensioni per laura_b
INSERT INTO UtenteValutaUtente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES 
('mario88', 'laura_b', 2, '2024-06-13', 9, 'Eccellente performance'),
('luigi_v', 'laura_b', 2, '2024-06-14', 3, 'Non molto partecipe');

-- Recensioni per luigi_v
INSERT INTO UtenteValutaUtente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES 
('mario88', 'luigi_v', 3, '2024-06-15', 8, 'Ottimo coordinatore'),
('laura_b', 'luigi_v', 3, '2024-06-16', 5, 'Ha bisogno di migliorare la comunicazione');

-- Recensioni per anna_neri
INSERT INTO UtenteValutaUtente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES 
('mario88', 'anna_neri', 4, '2024-06-17', 6, 'Partecipativa ma può fare meglio'),
('laura_b', 'anna_neri', 4, '2024-06-18', 8, 'Grande giocatrice, molto collaborativa');

-- Recensioni per giovanniG
INSERT INTO UtenteValutaUtente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES 
('mario88', 'giovanniG', 5, '2024-06-19', 4, 'Mancanza di impegno'),
('laura_b', 'giovanniG', 5, '2024-06-20', 7, 'Buona prestazione generale');

-- Recensioni per francesca_blu
INSERT INTO UtenteValutaUtente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES 
('mario88', 'francesca_blu', 3, '2024-06-21', 8, 'Eccellente giocatrice, molto motivata'),
('laura_b', 'francesca_blu', 3, '2024-06-22', 6, 'Buona prestazione ma può migliorare');

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

-- Utenti con ritardo
INSERT INTO UtenteIscriveEvento (utente, evento, data_iscrizione, ritardo, stato) VALUES 
('mario88', 1, '2024-06-10', true, 'accettato'),
('laura_b', 1, '2024-06-10', true, 'accettato'),
('luigi_v', 2, '2024-06-11', true, 'accettato'),
('anna_neri', 2, '2024-06-11', true, 'accettato'),
('giovanniG', 3, '2024-06-12', true, 'accettato');

-- Utenti con no show
INSERT INTO UtenteIscriveEvento (utente, evento, data_iscrizione, no_show, stato) VALUES 
('mario88', 4, '2024-06-13', true, 'accettato'),
('laura_b', 4, '2024-06-13', true, 'accettato'),
('luigi_v', 5, '2024-06-14', false, 'rifiutato'),
('anna_neri', 5, '2024-06-14', false, 'rifiutato'),
('giovanniG', 1, '2024-06-10', false, 'rifiutato');  -- Aggiunto un no show extra

-- Utenti senza ritardo o no show
INSERT INTO UtenteIscriveEvento (utente, evento, data_iscrizione, stato) VALUES 
('mario88', 2, '2024-06-11', 'accettato'),
('laura_b', 2, '2024-06-11', 'accettato'),
('luigi_v', 3, '2024-06-12', 'accettato'),
('anna_neri', 3, '2024-06-12', 'accettato'),
('giovanniG', 4, '2024-06-13', 'accettato');