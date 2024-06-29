--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-06-14 16:33:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 16866)
-- Name: UniGeSocialSport2.0; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "UniGeSocialSport2.0";


ALTER SCHEMA "UniGeSocialSport2.0" OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 17094)
-- Name: aggiungi_livelli_categoria(); Type: FUNCTION; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE FUNCTION "UniGeSocialSport2.0".aggiungi_livelli_categoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Livello (utente, categoria)
    SELECT username, NEW.id 
    FROM Utente;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "UniGeSocialSport2.0".aggiungi_livelli_categoria() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 17093)
-- Name: aggiungi_livelli_utenti(); Type: FUNCTION; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE FUNCTION "UniGeSocialSport2.0".aggiungi_livelli_utenti() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Livello (utente, categoria)
    SELECT NEW.username, id 
    FROM Categoria;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "UniGeSocialSport2.0".aggiungi_livelli_utenti() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 17099)
-- Name: iscrivi_utenti_a_eventi(); Type: FUNCTION; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE FUNCTION "UniGeSocialSport2.0".iscrivi_utenti_a_eventi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION "UniGeSocialSport2.0".iscrivi_utenti_a_eventi() OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 17098)
-- Name: iscrivi_utenti_agli_eventi(); Type: FUNCTION; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE FUNCTION "UniGeSocialSport2.0".iscrivi_utenti_agli_eventi() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    evento_record RECORD;
    utente_record RECORD;
    num_giocatori_categoria INTEGER;
    num_iscritti INTEGER;
    num_titolari INTEGER;
    num_arbitri INTEGER;
    num_iscritti_min INTEGER;
    num_iscritti_max INTEGER;
BEGIN
    -- Ciclo attraverso gli eventi
    FOR evento_record IN SELECT * FROM Evento LOOP
        -- Determina il numero di giocatori e arbitri per la categoria dell'evento
        SELECT num_giocatori, COUNT(*) INTO num_giocatori_categoria, num_arbitri
        FROM Utente
        WHERE corsodistudio = evento_record.categoria
        AND ruolo IN ('giocatore', 'arbitro')
        GROUP BY corsodistudio;

        -- Calcola il numero minimo e massimo di iscritti consentiti per l'evento
        num_iscritti_min := FLOOR(num_giocatori_categoria * 0.02);
        num_iscritti_max := num_giocatori_categoria * 2;

        -- Conta il numero di iscritti attuali all'evento
        SELECT COUNT(*) INTO num_iscritti FROM UtenteGiocaEvento WHERE evento = evento_record.id;

        -- Conta il numero di titolari già iscritti all'evento
        SELECT COUNT(*) INTO num_titolari FROM UtenteGiocaEvento WHERE evento = evento_record.id AND titolare = true;

        -- Conta il numero di arbitri già iscritti all'evento
        num_arbitri := num_arbitri - num_titolari;

        -- Controlla se è necessario aggiungere iscrizioni
        IF num_iscritti < num_iscritti_min THEN
            -- Aggiungi giocatori finché non raggiungi il numero minimo di iscritti
            FOR utente_record IN SELECT * FROM Utente WHERE corsodistudio = evento_record.categoria AND ruolo = 'giocatore' AND stato = 'accettato' LIMIT (num_iscritti_min - num_iscritti) LOOP
                INSERT INTO UtenteGiocaEvento (utente, evento, data_iscrizione, ruolo, ritardo, stato, squadra_temp)
                VALUES (utente_record.username, evento_record.id, evento_record.data_svolgimento, 'giocatore', (RANDOM() < 0.3), 'in attesa', CASE WHEN RANDOM() < 0.15 THEN 1 ELSE 2 END);
            END LOOP;
        END IF;

        -- Aggiungi arbitri se necessario
        IF num_arbitri > 0 THEN
            FOR utente_record IN SELECT * FROM Utente WHERE corsodistudio = evento_record.categoria AND ruolo = 'arbitro' AND stato = 'accettato' LIMIT num_arbitri LOOP
                INSERT INTO UtenteGiocaEvento (utente, evento, data_iscrizione, ruolo, stato, squadra_temp)
                VALUES (utente_record.username, evento_record.id, evento_record.data_svolgimento, 'arbitro', 'in attesa', NULL);
            END LOOP;
        END IF;

    END LOOP;
END;
$$;


ALTER FUNCTION "UniGeSocialSport2.0".iscrivi_utenti_agli_eventi() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 16874)
-- Name: categoria; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".categoria (
    id numeric NOT NULL,
    denominazione character varying(255) NOT NULL,
    num_giocatori numeric NOT NULL,
    regolamento character varying(255) NOT NULL,
    foto character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport2.0".categoria OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16867)
-- Name: corsodistudio; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".corsodistudio (
    id numeric NOT NULL,
    denominazione character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport2.0".corsodistudio OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16991)
-- Name: evento; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".evento (
    id numeric NOT NULL,
    punti_sq1 numeric,
    punti_sq2 numeric,
    stato character(6) DEFAULT 'APERTO'::bpchar,
    data_svolgimento date NOT NULL,
    categoria numeric,
    impianto character varying(255),
    torneo numeric
);


ALTER TABLE "UniGeSocialSport2.0".evento OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16881)
-- Name: impianto; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".impianto (
    nome character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    telefono character(10) NOT NULL,
    longitudine real NOT NULL,
    latitudine real NOT NULL,
    via character varying(255) NOT NULL,
    civico numeric NOT NULL,
    interno numeric NOT NULL,
    cap character(5) NOT NULL,
    inizio_disponibilita time without time zone,
    fine_disponibilita time without time zone
);


ALTER TABLE "UniGeSocialSport2.0".impianto OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16972)
-- Name: livello; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".livello (
    utente character varying(30) NOT NULL,
    categoria numeric NOT NULL,
    punteggio integer DEFAULT 0,
    CONSTRAINT livello0_100 CHECK (((punteggio >= 0) AND (punteggio <= 100)))
);


ALTER TABLE "UniGeSocialSport2.0".livello OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16899)
-- Name: premio; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".premio (
    id numeric NOT NULL,
    descrizione character varying(255) NOT NULL,
    torneo numeric
);


ALTER TABLE "UniGeSocialSport2.0".premio OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16955)
-- Name: sostituzione; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".sostituzione (
    id numeric NOT NULL,
    data date NOT NULL,
    utente_richiedente character varying(30),
    utente_sostitutivo character varying(30)
);


ALTER TABLE "UniGeSocialSport2.0".sostituzione OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16892)
-- Name: sponsor; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".sponsor (
    id numeric NOT NULL,
    denominazione character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport2.0".sponsor OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17014)
-- Name: sponsorfinanziatorneo; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".sponsorfinanziatorneo (
    sponsor numeric NOT NULL,
    torneo numeric NOT NULL
);


ALTER TABLE "UniGeSocialSport2.0".sponsorfinanziatorneo OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16906)
-- Name: squadra; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".squadra (
    nome character varying(255) NOT NULL,
    colore_maglia character varying(255),
    descrizione character varying(255),
    note character varying(255),
    num_max_giocatori numeric NOT NULL,
    num_min_giocatori numeric NOT NULL,
    creatore character varying(30),
    CONSTRAINT squadra_check CHECK ((num_max_giocatori >= num_min_giocatori)),
    CONSTRAINT squadra_check1 CHECK ((num_min_giocatori <= num_max_giocatori))
);


ALTER TABLE "UniGeSocialSport2.0".squadra OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17031)
-- Name: squadrapartecipatorneo; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".squadrapartecipatorneo (
    squadra character varying(255) NOT NULL,
    torneo numeric NOT NULL
);


ALTER TABLE "UniGeSocialSport2.0".squadrapartecipatorneo OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16943)
-- Name: torneo; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".torneo (
    id numeric NOT NULL,
    descrizione character varying(255) NOT NULL,
    restrizione character varying(255),
    creatore character varying(30)
);


ALTER TABLE "UniGeSocialSport2.0".torneo OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16915)
-- Name: utente; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".utente (
    username character varying(30) NOT NULL,
    numero_matricola numeric NOT NULL,
    nome character varying(255) NOT NULL,
    cognome character varying(255) NOT NULL,
    anno_nascita integer NOT NULL,
    foto character varying(255) NOT NULL,
    telefono character(10) NOT NULL,
    affidabile boolean DEFAULT true,
    premium boolean DEFAULT false,
    corsodistudio numeric,
    squadra character varying(255),
    stato character varying(255)
);


ALTER TABLE "UniGeSocialSport2.0".utente OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17071)
-- Name: utentegiocaevento; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".utentegiocaevento (
    utente character varying(30) NOT NULL,
    evento numeric NOT NULL,
    data_iscrizione date NOT NULL,
    ruolo character varying(255) DEFAULT 'giocatore'::character varying,
    ritardo boolean DEFAULT false,
    no_show boolean DEFAULT false,
    stato character varying(255) DEFAULT 'in attesa'::character varying,
    squadra_temp numeric,
    punti_giocatore numeric,
    titolare boolean DEFAULT false,
    cartellino character varying(255)
);


ALTER TABLE "UniGeSocialSport2.0".utentegiocaevento OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17048)
-- Name: utentevalutautente; Type: TABLE; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TABLE "UniGeSocialSport2.0".utentevalutautente (
    utente_valutante character varying(30) NOT NULL,
    utente_valutato character varying(30) NOT NULL,
    evento numeric NOT NULL,
    data_valutazione date NOT NULL,
    punteggio numeric,
    commento character varying(255),
    CONSTRAINT punteggio0_10 CHECK (((punteggio >= (0)::numeric) AND (punteggio <= (10)::numeric)))
);


ALTER TABLE "UniGeSocialSport2.0".utentevalutautente OWNER TO postgres;

--
-- TOC entry 5019 (class 0 OID 16874)
-- Dependencies: 234
-- Data for Name: categoria; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (1, 'Calcio', 22, 'Regolamento FIFA', 'calcio.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (2, 'Basket', 10, 'Regolamento FIBA', 'basket.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (3, 'Pallavolo', 12, 'Regolamento FIVB', 'pallavolo.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (4, 'Tennis', 2, 'Regolamento ITF', 'tennis.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (5, 'Rugby', 30, 'Regolamento World Rugby', 'rugby.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (6, 'Hockey su ghiaccio', 12, 'Regolamento IIHF', 'hockey_su_ghiaccio.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (7, 'Pallanuoto', 14, 'Regolamento FINA', 'pallanuoto.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (8, 'Atletica leggera', 1, 'Regolamento IAAF', 'atletica_leggera.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (9, 'Ciclismo su strada', 1, 'Regolamento UCI', 'ciclismo_su_strada.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (10, 'Golf', 4, 'Regolamento R&A', 'golf.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (11, 'Scherma', 2, 'Regolamento FIE', 'scherma.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (12, 'Pattinaggio artistico', 1, 'Regolamento ISU', 'pattinaggio_artistico.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (13, 'Baseball', 18, 'Regolamento WBSC', 'baseball.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (14, 'Pugilato', 2, 'Regolamento AIBA', 'pugilato.jpg');
INSERT INTO "UniGeSocialSport2.0".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (15, 'Judo', 2, 'Regolamento IJF', 'judo.jpg');


--
-- TOC entry 5018 (class 0 OID 16867)
-- Dependencies: 233
-- Data for Name: corsodistudio; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (1, 'Ingegneria Informatica');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (2, 'Economia e Commercio');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (3, 'Giurisprudenza');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (4, 'Medicina e Chirurgia');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (5, 'Architettura');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (6, 'Scienze Politiche');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (7, 'Biotecnologie');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (8, 'Chimica Industriale');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (9, 'Scienze della Comunicazione');
INSERT INTO "UniGeSocialSport2.0".corsodistudio (id, denominazione) VALUES (10, 'Ingegneria Meccanica');


--
-- TOC entry 5028 (class 0 OID 16991)
-- Dependencies: 243
-- Data for Name: evento; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (1, 3, 2, 'APERTO', '2024-06-20', 1, 'Campo Sportivo Begato', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (2, 75, 72, 'APERTO', '2024-06-22', 2, 'Campo Sportivo Caderissi', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (3, 6, 4, 'APERTO', '2024-06-25', 3, 'Campo Sportivo Carlini', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (6, 2, 1, 'APERTO', '2024-07-03', 1, 'Campo Sportivo San Gottardo', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (7, 70, 68, 'APERTO', '2024-07-06', 2, 'Campo Sportivo San Martino', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (8, 6, 3, 'APERTO', '2024-07-09', 3, 'Campo Sportivo Tre Pini', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (9, 18, 20, 'APERTO', '2024-07-12', 4, 'Impianto Polisportivo Crocera Stadium', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (11, 3, 4, 'APERTO', '2024-07-18', 1, 'PalaDonBosco', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (12, 72, 75, 'APERTO', '2024-07-21', 2, 'Palasport di Genova', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (13, 4, 6, 'APERTO', '2024-07-24', 3, 'Palasport RDS Stadium', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (14, 20, 22, 'APERTO', '2024-07-27', 4, 'Palazzetto dello Sport', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (16, 2, 3, 'APERTO', '2024-08-02', 1, 'Piscina Lago Figoi', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (17, 68, 70, 'APERTO', '2024-08-05', 2, 'Piscina Mameli', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (18, 3, 6, 'APERTO', '2024-08-08', 3, 'Piscina Pra', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (19, 20, 18, 'APERTO', '2024-08-11', 4, 'Piscina Sciorba', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (21, 1, 2, 'APERTO', '2024-06-20', 1, 'Campo Sportivo Begato', 1);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (22, 70, 68, 'APERTO', '2024-06-22', 2, 'Campo Sportivo Caderissi', 2);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (23, 6, 4, 'APERTO', '2024-06-25', 3, 'Campo Sportivo Carlini', 3);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (24, 18, 20, 'APERTO', '2024-06-28', 4, 'Campo Sportivo Cornigliano', 4);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (25, 90, 88, 'APERTO', '2024-07-01', 5, 'Campo Sportivo Molassana', 5);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (26, 2, 1, 'APERTO', '2024-07-03', 1, 'Campo Sportivo San Gottardo', 1);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (27, 72, 75, 'APERTO', '2024-07-06', 2, 'Campo Sportivo San Martino', 2);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (28, 4, 6, 'APERTO', '2024-07-09', 3, 'Campo Sportivo Tre Pini', 3);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (30, 88, 90, 'APERTO', '2024-07-15', 5, 'PalaCUS Genova', 5);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (4, 20, 18, 'CHIUSO', '2024-05-16', 4, 'Campo Sportivo Cornigliano', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (5, 90, 88, 'CHIUSO', '2024-04-14', 5, 'Campo Sportivo Molassana', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (10, 85, 82, 'CHIUSO', '2024-04-02', 5, 'PalaCUS Genova', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (15, 88, 90, 'CHIUSO', '2024-04-22', 5, 'Piscina Aquacenter I Delfini', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (20, 82, 85, 'CHIUSO', '2024-04-29', 5, 'Stadio Luigi Ferraris', NULL);
INSERT INTO "UniGeSocialSport2.0".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo) VALUES (29, 22, 20, 'CHIUSO', '2024-04-02', 4, 'Impianto Polisportivo Crocera Stadium', 4);


--
-- TOC entry 5020 (class 0 OID 16881)
-- Dependencies: 235
-- Data for Name: impianto; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Stadio Luigi Ferraris', 'info@stadioferraris.it', '0101234567', 8.952942, 44.4165, 'Via Giovanni De Prà', 1, 0, '16139', '08:00:00', '22:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Piscina Sciorba', 'info@piscinasciorba.it', '0102345678', 8.931998, 44.4185, 'Via Gelasio Adamoli', 57, 0, '16141', '06:00:00', '21:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Palasport di Genova', 'info@palasportgenova.it', '0103456789', 8.924067, 44.4034, 'Piazzale John Fitzgerald Kennedy', 1, 0, '16129', '09:00:00', '23:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('PalaDonBosco', 'info@paladonbosco.it', '0104567890', 8.950489, 44.4201, 'Via San Giovanni Bosco', 14, 0, '16144', '08:00:00', '20:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Carlini', 'info@campo-carlini.it', '0105678901', 8.962075, 44.4182, 'Via Vernazza', 22, 0, '16155', '07:00:00', '19:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Palasport RDS Stadium', 'info@rdsstadium.it', '0106789012', 8.909768, 44.4095, 'Lungomare Canepa', 155, 0, '16149', '10:00:00', '22:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Tre Pini', 'info@campotrepini.it', '0107890123', 8.978993, 44.4482, 'Via Montevideo', 27, 0, '16129', '08:00:00', '21:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Impianto Polisportivo Crocera Stadium', 'info@crocerastadium.it', '0108901234', 8.933767, 44.4203, 'Via Eridania', 3, 0, '16152', '06:00:00', '22:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Piscina Mameli', 'info@piscinamameli.it', '0109012345', 8.956848, 44.4209, 'Via Federico Delpino', 2, 0, '16144', '07:00:00', '20:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo San Martino', 'info@sanmartino.it', '0100123456', 8.958459, 44.4099, 'Corso Gastaldi', 77, 0, '16131', '09:00:00', '22:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Palazzetto dello Sport', 'info@palazzettodellosport.it', '0102233445', 8.950563, 44.4147, 'Via Armando Diaz', 11, 0, '16142', '08:00:00', '21:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Piscina Pra', 'info@piscinapra.it', '0103344556', 8.794572, 44.4226, 'Via Pra', 58, 0, '16157', '06:00:00', '20:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Caderissi', 'info@caderissi.it', '0104455667', 8.943479, 44.4119, 'Via Carlo Rolando', 32, 0, '16151', '07:00:00', '21:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('PalaCUS Genova', 'info@palacus.it', '0105566778', 8.946536, 44.416, 'Viale Gambaro', 56, 0, '16145', '08:00:00', '22:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo San Gottardo', 'info@sangottardo.it', '0106677889', 8.940112, 44.426, 'Via Mogadiscio', 21, 0, '16139', '09:00:00', '20:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Piscina Lago Figoi', 'info@figoi.it', '0107788990', 8.899701, 44.4287, 'Via Lago Figoi', 15, 0, '16158', '06:00:00', '21:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Molassana', 'info@molassana.it', '0108899001', 8.955332, 44.4345, 'Via di Pino', 4, 0, '16138', '08:00:00', '20:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Begato', 'info@begato.it', '0109900112', 8.961873, 44.4512, 'Via Maritano', 10, 0, '16159', '09:00:00', '19:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Cornigliano', 'info@cornigliano.it', '0100011223', 8.879438, 44.4254, 'Via Tonale', 8, 0, '16152', '08:00:00', '21:00:00');
INSERT INTO "UniGeSocialSport2.0".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Piscina Aquacenter I Delfini', 'info@aquacenteridelfini.it', '0101122334', 8.905149, 44.4265, 'Via Buozzi', 20, 0, '16126', '07:00:00', '22:00:00');


--
-- TOC entry 5027 (class 0 OID 16972)
-- Dependencies: 242
-- Data for Name: livello; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mrossi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('alandini1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fverdi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lbianchi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gneri1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mbruni1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lverdi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggalli1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmarini1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gbruno1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cconti1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('emanfredi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('tcolombo1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fsantoro1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('gpellegrini1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('elombardi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mcolombo1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fserra1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('trossi1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('cmarini1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lpellegrini1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fabate1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('lisabella1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ssilvestri1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mmonti1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbertini1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('sconte1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('ggallo1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('fbarbieri1', 15, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 1, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 2, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 3, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 4, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 5, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 6, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 7, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 8, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 9, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 10, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 11, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 12, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 13, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 14, 0);
INSERT INTO "UniGeSocialSport2.0".livello (utente, categoria, punteggio) VALUES ('mlongo1', 15, 0);


--
-- TOC entry 5022 (class 0 OID 16899)
-- Dependencies: 237
-- Data for Name: premio; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".premio (id, descrizione, torneo) VALUES (1, 'Trofeo Campioni Regionali', 1);
INSERT INTO "UniGeSocialSport2.0".premio (id, descrizione, torneo) VALUES (2, 'Medaglia d''Oro', 2);
INSERT INTO "UniGeSocialSport2.0".premio (id, descrizione, torneo) VALUES (3, 'Coppa della Vittoria', 3);
INSERT INTO "UniGeSocialSport2.0".premio (id, descrizione, torneo) VALUES (4, 'Premio Fair Play', 4);
INSERT INTO "UniGeSocialSport2.0".premio (id, descrizione, torneo) VALUES (5, 'Certificato di Partecipazione', 4);


--
-- TOC entry 5026 (class 0 OID 16955)
-- Dependencies: 241
-- Data for Name: sostituzione; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--



--
-- TOC entry 5021 (class 0 OID 16892)
-- Dependencies: 236
-- Data for Name: sponsor; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".sponsor (id, denominazione) VALUES (1, 'Eni');
INSERT INTO "UniGeSocialSport2.0".sponsor (id, denominazione) VALUES (2, 'Ferrero');
INSERT INTO "UniGeSocialSport2.0".sponsor (id, denominazione) VALUES (3, 'Fiat');
INSERT INTO "UniGeSocialSport2.0".sponsor (id, denominazione) VALUES (4, 'Luxottica');
INSERT INTO "UniGeSocialSport2.0".sponsor (id, denominazione) VALUES (5, 'Barilla');


--
-- TOC entry 5029 (class 0 OID 17014)
-- Dependencies: 244
-- Data for Name: sponsorfinanziatorneo; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".sponsorfinanziatorneo (sponsor, torneo) VALUES (1, 1);
INSERT INTO "UniGeSocialSport2.0".sponsorfinanziatorneo (sponsor, torneo) VALUES (2, 2);
INSERT INTO "UniGeSocialSport2.0".sponsorfinanziatorneo (sponsor, torneo) VALUES (3, 3);


--
-- TOC entry 5023 (class 0 OID 16906)
-- Dependencies: 238
-- Data for Name: squadra; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".squadra (nome, colore_maglia, descrizione, note, num_max_giocatori, num_min_giocatori, creatore) VALUES ('Squadra A', 'Rosso', 'Gruppo di Amici', 'Gruppo di amici che si riunisce per diverse attività', 10, 5, 'lbianchi1');
INSERT INTO "UniGeSocialSport2.0".squadra (nome, colore_maglia, descrizione, note, num_max_giocatori, num_min_giocatori, creatore) VALUES ('Squadra C', 'Verde', 'Team di Avventura', 'Gruppo di amici appassionati di avventura e esplorazione', 8, 4, 'gpellegrini1');
INSERT INTO "UniGeSocialSport2.0".squadra (nome, colore_maglia, descrizione, note, num_max_giocatori, num_min_giocatori, creatore) VALUES ('Squadra B', 'Blu', 'Club Ricreativo', 'Club ricreativo per attività all''aperto e serate sociali', 15, 8, 'lpellegrini1');


--
-- TOC entry 5030 (class 0 OID 17031)
-- Dependencies: 245
-- Data for Name: squadrapartecipatorneo; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra A', 1);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra A', 2);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra A', 3);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra A', 4);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra A', 5);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra B', 1);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra B', 2);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra B', 3);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra B', 4);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra B', 5);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra C', 1);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra C', 2);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra C', 3);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra C', 4);
INSERT INTO "UniGeSocialSport2.0".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra C', 5);


--
-- TOC entry 5025 (class 0 OID 16943)
-- Dependencies: 240
-- Data for Name: torneo; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".torneo (id, descrizione, restrizione, creatore) VALUES (1, 'Torneo di Calcetto', 'Solo per squadre di amici', 'lbianchi1');
INSERT INTO "UniGeSocialSport2.0".torneo (id, descrizione, restrizione, creatore) VALUES (2, 'Torneo di Basket', 'Per studenti universitari', 'tcolombo1');
INSERT INTO "UniGeSocialSport2.0".torneo (id, descrizione, restrizione, creatore) VALUES (3, 'Torneo di Tennis', 'Aperto a tutti i livelli', 'lpellegrini1');
INSERT INTO "UniGeSocialSport2.0".torneo (id, descrizione, restrizione, creatore) VALUES (4, 'Torneo di Pallavolo', 'Solo per appassionati', 'lbianchi1');
INSERT INTO "UniGeSocialSport2.0".torneo (id, descrizione, restrizione, creatore) VALUES (5, 'Torneo di Golf', 'Per gli appassionati del golf', 'tcolombo1');


--
-- TOC entry 5024 (class 0 OID 16915)
-- Dependencies: 239
-- Data for Name: utente; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('mrossi1', 1001, 'Mario', 'Rossi', 1995, 'mario_rossi.jpg', '3331234567', true, false, 1, 'Squadra A', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('alandini1', 1002, 'Alessandra', 'Landini', 1997, 'alessandra_landini.jpg', '3332345678', true, false, 2, 'Squadra B', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('fverdi1', 1003, 'Francesco', 'Verdi', 1998, 'francesco_verdi.jpg', '3333456789', true, false, 3, 'Squadra C', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('lbianchi1', 1004, 'Luca', 'Bianchi', 1994, 'luca_bianchi.jpg', '3334567890', true, true, 4, 'Squadra A', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('gneri1', 1005, 'Giulia', 'Neri', 1996, 'giulia_neri.jpg', '3335678901', true, false, 1, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('mbruni1', 1006, 'Marco', 'Bruni', 1995, 'marco_bruni.jpg', '3336789012', true, false, 2, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('lverdi1', 1007, 'Laura', 'Verdi', 1997, 'laura_verdi.jpg', '3337890123', true, false, 3, 'Squadra C', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('ggalli1', 1008, 'Giovanni', 'Galli', 1998, 'giovanni_galli.jpg', '3338901234', true, false, 1, 'Squadra B', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('mmarini1', 1009, 'Martina', 'Marini', 1995, 'martina_marini.jpg', '3339012345', true, false, 4, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('gbruno1', 1010, 'Giorgio', 'Bruno', 1997, 'giorgio_bruno.jpg', '3330123456', true, false, 3, 'Squadra A', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('cconti1', 1011, 'Chiara', 'Conti', 1998, 'chiara_conti.jpg', '3341234567', true, false, 2, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('emanfredi1', 1012, 'Elena', 'Manfredi', 1994, 'elena_manfredi.jpg', '3342345678', true, false, 1, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('tcolombo1', 1013, 'Tommaso', 'Colombo', 1996, 'tommaso_colombo.jpg', '3343456789', true, true, 4, 'Squadra C', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('fsantoro1', 1014, 'Federica', 'Santoro', 1997, 'federica_santoro.jpg', '3344567890', true, false, 3, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('gpellegrini1', 1015, 'Giacomo', 'Pellegrini', 1995, 'giacomo_pellegrini.jpg', '3345678901', true, false, 2, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('elombardi1', 1016, 'Elena', 'Lombardi', 1998, 'elena_lombardi.jpg', '3346789012', true, false, 1, 'Squadra B', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('mcolombo1', 1017, 'Marco', 'Colombo', 1994, 'marco_colombo.jpg', '3347890123', true, false, 4, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('fserra1', 1018, 'Francesca', 'Serra', 1996, 'francesca_serra.jpg', '3348901234', true, false, 3, 'Squadra A', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('trossi1', 1019, 'Tiziano', 'Rossi', 1997, 'tiziano_rossi.jpg', '3349012345', true, false, 2, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('cmarini1', 1020, 'Cristina', 'Marini', 1995, 'cristina_marini.jpg', '3350123456', true, false, 1, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('lpellegrini1', 1021, 'Luca', 'Pellegrini', 1998, 'luca_pellegrini.jpg', '3351234567', true, true, 4, 'Squadra C', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('fabate1', 1022, 'Fabio', 'Abate', 1996, 'fabio_abate.jpg', '3352345678', true, false, 3, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('lisabella1', 1023, 'Linda', 'Isabella', 1994, 'linda_isabella.jpg', '3335456789', true, false, 2, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('ssilvestri1', 1024, 'Simone', 'Silvestri', 1997, 'simone_silvestri.jpg', '3354567890', true, false, 1, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('mmonti1', 1025, 'Marta', 'Monti', 1998, 'marta_monti.jpg', '3355678901', true, false, 4, 'Squadra B', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('fbertini1', 1026, 'Federico', 'Bertini', 1995, 'federico_bertini.jpg', '3356789012', true, false, 3, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('sconte1', 1027, 'Sara', 'Conte', 1996, 'sara_conte.jpg', '3357890123', true, false, 2, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('ggallo1', 1028, 'Giulia', 'Gallo', 1997, 'giulia_gallo.jpg', '3358901234', true, false, 1, NULL, NULL);
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('fbarbieri1', 1029, 'Filippo', 'Barbieri', 1994, 'filippo_barbieri.jpg', '3359012345', true, true, 4, 'Squadra A', 'Accettato');
INSERT INTO "UniGeSocialSport2.0".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio, squadra, stato) VALUES ('mlongo1', 1030, 'Martina', 'Longo', 1998, 'martina_longo.jpg', '3360123456', true, false, 3, NULL, NULL);


--
-- TOC entry 5032 (class 0 OID 17071)
-- Dependencies: 247
-- Data for Name: utentegiocaevento; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 21, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 26, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 22, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 27, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 23, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 28, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 24, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 29, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 25, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 30, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 1, '2024-06-14', 'arbitro', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 6, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 11, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 16, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 2, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 7, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 12, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 17, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 9, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 14, '2024-06-14', 'arbitro', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 19, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 4, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 5, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 10, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 15, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 20, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 14, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 15, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 16, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 2, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 2, '2024-06-14', 'giocatore', false, false, 'in attesa', NULL, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 3, '2024-06-14', 'giocatore', false, true, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 4, '2024-06-14', 'giocatore', true, false, 'in attesa', NULL, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 18, '2024-06-14', 'giocatore', false, false, 'in attesa', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 4, '2024-06-14', 'giocatore', false, false, 'in attesa', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 6, '2024-06-14', 'giocatore', false, false, 'in attesa', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 7, '2024-06-14', 'giocatore', false, false, 'in attesa', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('elombardi1', 6, '2024-06-14', 'giocatore', false, false, 'in attesa', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 6, '2024-06-14', 'giocatore', false, false, 'in attesa', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 14, '2024-06-14', 'giocatore', false, false, 'in attesa', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fbarbieri1', 14, '2024-06-14', 'giocatore', false, false, 'in attesa', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 1, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 6, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 11, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 16, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 2, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 12, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 17, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 3, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 8, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 13, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lbianchi1', 18, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 9, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 14, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 19, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 4, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 5, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 10, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 15, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mmonti1', 20, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 10, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 20, '2024-06-14', 'giocatore', true, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 5, '2024-06-14', 'arbitro', true, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 9, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lpellegrini1', 12, '2024-06-14', 'giocatore', false, true, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 13, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, true, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fverdi1', 20, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('mrossi1', 7, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('alandini1', 10, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('lverdi1', 3, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('ggalli1', 3, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('gbruno1', 10, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('tcolombo1', 16, '2024-06-14', 'giocatore', false, false, 'accettato', 1, NULL, false, NULL);
INSERT INTO "UniGeSocialSport2.0".utentegiocaevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato, squadra_temp, punti_giocatore, titolare, cartellino) VALUES ('fserra1', 20, '2024-06-14', 'giocatore', false, false, 'accettato', 2, NULL, false, NULL);


--
-- TOC entry 5031 (class 0 OID 17048)
-- Dependencies: 246
-- Data for Name: utentevalutautente; Type: TABLE DATA; Schema: UniGeSocialSport2.0; Owner: postgres
--

INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'elombardi1', 4, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'alandini1', 4, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'gbruno1', 4, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'fserra1', 4, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'alandini1', 4, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'gbruno1', 4, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'fserra1', 4, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'elombardi1', 4, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'gbruno1', 4, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'fserra1', 4, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'elombardi1', 4, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'alandini1', 4, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mmonti1', 5, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'gbruno1', 5, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lpellegrini1', 5, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'gbruno1', 5, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'lpellegrini1', 5, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'mmonti1', 5, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mmonti1', 10, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mrossi1', 10, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'alandini1', 10, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'gbruno1', 10, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lpellegrini1', 10, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'mrossi1', 10, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'alandini1', 10, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'gbruno1', 10, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'lpellegrini1', 10, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'mmonti1', 10, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'alandini1', 10, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'gbruno1', 10, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'lpellegrini1', 10, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'mmonti1', 10, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'mrossi1', 10, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'gbruno1', 10, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'lpellegrini1', 10, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'mmonti1', 10, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'mrossi1', 10, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'alandini1', 10, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'lverdi1', 15, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mmonti1', 15, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'lpellegrini1', 15, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'mmonti1', 15, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lpellegrini1', 15, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lverdi1', 15, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mmonti1', 20, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'lverdi1', 20, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'fverdi1', 20, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'fserra1', 20, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lpellegrini1', 20, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lverdi1', 20, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'fverdi1', 20, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'fserra1', 20, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'lpellegrini1', 20, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'mmonti1', 20, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'fverdi1', 20, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'fserra1', 20, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'lpellegrini1', 20, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'mmonti1', 20, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'lverdi1', 20, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'fserra1', 20, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'lpellegrini1', 20, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'mmonti1', 20, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'lverdi1', 20, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'fverdi1', 20, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'lbianchi1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'gbruno1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'fserra1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'fbarbieri1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'alandini1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'ggalli1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'elombardi1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'mmonti1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'fverdi1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'lverdi1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'tcolombo1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mrossi1', 'lpellegrini1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'mrossi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'gbruno1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'fserra1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'fbarbieri1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'alandini1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'ggalli1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'elombardi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'mmonti1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'fverdi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'lverdi1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'tcolombo1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lbianchi1', 'lpellegrini1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'mrossi1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'lbianchi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'fserra1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'fbarbieri1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'alandini1', 29, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'ggalli1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'elombardi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'mmonti1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'fverdi1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'lverdi1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'tcolombo1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('gbruno1', 'lpellegrini1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'mrossi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'lbianchi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'gbruno1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'fbarbieri1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'alandini1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'ggalli1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'elombardi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'mmonti1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'fverdi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'lverdi1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'tcolombo1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fserra1', 'lpellegrini1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'mrossi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'lbianchi1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'gbruno1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'fserra1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'alandini1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'ggalli1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'elombardi1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'mmonti1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'fverdi1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'lverdi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'tcolombo1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fbarbieri1', 'lpellegrini1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'mrossi1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'lbianchi1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'gbruno1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'fserra1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'fbarbieri1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'ggalli1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'elombardi1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'mmonti1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'fverdi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'lverdi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'tcolombo1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('alandini1', 'lpellegrini1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'mrossi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'lbianchi1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'gbruno1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'fserra1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'fbarbieri1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'alandini1', 29, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'elombardi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'mmonti1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'fverdi1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'lverdi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'tcolombo1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('ggalli1', 'lpellegrini1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'mrossi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'lbianchi1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'gbruno1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'fserra1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'fbarbieri1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'alandini1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'ggalli1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'mmonti1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'fverdi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'lverdi1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'tcolombo1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('elombardi1', 'lpellegrini1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'mrossi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lbianchi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'gbruno1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'fserra1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'fbarbieri1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'alandini1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'ggalli1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'elombardi1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'fverdi1', 29, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lverdi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'tcolombo1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mmonti1', 'lpellegrini1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'mrossi1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'lbianchi1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'gbruno1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'fserra1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'fbarbieri1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'alandini1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'ggalli1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'elombardi1', 29, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'mmonti1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'lverdi1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'tcolombo1', 29, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('fverdi1', 'lpellegrini1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'mrossi1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'lbianchi1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'gbruno1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'fserra1', 29, '2024-06-14', 0, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'fbarbieri1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'alandini1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'ggalli1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'elombardi1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'mmonti1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'fverdi1', 29, '2024-06-14', 4, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'tcolombo1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lverdi1', 'lpellegrini1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'mrossi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'lbianchi1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'gbruno1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'fserra1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'fbarbieri1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'alandini1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'ggalli1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'elombardi1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'mmonti1', 29, '2024-06-14', 5, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'fverdi1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'lverdi1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('tcolombo1', 'lpellegrini1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mrossi1', 29, '2024-06-14', 10, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'lbianchi1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'gbruno1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'fserra1', 29, '2024-06-14', 6, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'fbarbieri1', 29, '2024-06-14', 2, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'alandini1', 29, '2024-06-14', 7, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'ggalli1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'elombardi1', 29, '2024-06-14', 8, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'mmonti1', 29, '2024-06-14', 1, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'fverdi1', 29, '2024-06-14', 3, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'lverdi1', 29, '2024-06-14', 9, 'Ottima prestazione!');
INSERT INTO "UniGeSocialSport2.0".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('lpellegrini1', 'tcolombo1', 29, '2024-06-14', 0, 'Ottima prestazione!');


--
-- TOC entry 4816 (class 2606 OID 16880)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 4814 (class 2606 OID 16873)
-- Name: corsodistudio corsodistudio_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".corsodistudio
    ADD CONSTRAINT corsodistudio_pkey PRIMARY KEY (id);


--
-- TOC entry 4842 (class 2606 OID 16998)
-- Name: evento evento_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id);


--
-- TOC entry 4818 (class 2606 OID 16889)
-- Name: impianto impianto_email_key; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".impianto
    ADD CONSTRAINT impianto_email_key UNIQUE (email);


--
-- TOC entry 4820 (class 2606 OID 16887)
-- Name: impianto impianto_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".impianto
    ADD CONSTRAINT impianto_pkey PRIMARY KEY (nome);


--
-- TOC entry 4822 (class 2606 OID 16891)
-- Name: impianto impianto_telefono_key; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".impianto
    ADD CONSTRAINT impianto_telefono_key UNIQUE (telefono);


--
-- TOC entry 4840 (class 2606 OID 16980)
-- Name: livello livello_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".livello
    ADD CONSTRAINT livello_pkey PRIMARY KEY (utente, categoria);


--
-- TOC entry 4826 (class 2606 OID 16905)
-- Name: premio premio_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".premio
    ADD CONSTRAINT premio_pkey PRIMARY KEY (id);


--
-- TOC entry 4838 (class 2606 OID 16961)
-- Name: sostituzione sostituzione_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sostituzione
    ADD CONSTRAINT sostituzione_pkey PRIMARY KEY (id);


--
-- TOC entry 4824 (class 2606 OID 16898)
-- Name: sponsor sponsor_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sponsor
    ADD CONSTRAINT sponsor_pkey PRIMARY KEY (id);


--
-- TOC entry 4844 (class 2606 OID 17020)
-- Name: sponsorfinanziatorneo sponsorfinanziatorneo_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sponsorfinanziatorneo
    ADD CONSTRAINT sponsorfinanziatorneo_pkey PRIMARY KEY (sponsor, torneo);


--
-- TOC entry 4828 (class 2606 OID 16914)
-- Name: squadra squadra_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".squadra
    ADD CONSTRAINT squadra_pkey PRIMARY KEY (nome);


--
-- TOC entry 4846 (class 2606 OID 17037)
-- Name: squadrapartecipatorneo squadrapartecipatorneo_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".squadrapartecipatorneo
    ADD CONSTRAINT squadrapartecipatorneo_pkey PRIMARY KEY (squadra, torneo);


--
-- TOC entry 4836 (class 2606 OID 16949)
-- Name: torneo torneo_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".torneo
    ADD CONSTRAINT torneo_pkey PRIMARY KEY (id);


--
-- TOC entry 4830 (class 2606 OID 16925)
-- Name: utente utente_numero_matricola_key; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utente
    ADD CONSTRAINT utente_numero_matricola_key UNIQUE (numero_matricola);


--
-- TOC entry 4832 (class 2606 OID 16923)
-- Name: utente utente_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utente
    ADD CONSTRAINT utente_pkey PRIMARY KEY (username);


--
-- TOC entry 4834 (class 2606 OID 16927)
-- Name: utente utente_telefono_key; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utente
    ADD CONSTRAINT utente_telefono_key UNIQUE (telefono);


--
-- TOC entry 4850 (class 2606 OID 17082)
-- Name: utentegiocaevento utentegiocaevento_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentegiocaevento
    ADD CONSTRAINT utentegiocaevento_pkey PRIMARY KEY (utente, evento);


--
-- TOC entry 4848 (class 2606 OID 17055)
-- Name: utentevalutautente utentevalutautente_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentevalutautente
    ADD CONSTRAINT utentevalutautente_pkey PRIMARY KEY (utente_valutante, utente_valutato, evento);


--
-- TOC entry 4872 (class 2620 OID 17096)
-- Name: categoria aggiungi_livelli_categoria; Type: TRIGGER; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TRIGGER aggiungi_livelli_categoria AFTER INSERT ON "UniGeSocialSport2.0".categoria FOR EACH ROW EXECUTE FUNCTION "UniGeSocialSport2.0".aggiungi_livelli_categoria();


--
-- TOC entry 4873 (class 2620 OID 17095)
-- Name: utente aggiungi_livelli_utenti; Type: TRIGGER; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TRIGGER aggiungi_livelli_utenti AFTER INSERT ON "UniGeSocialSport2.0".utente FOR EACH ROW EXECUTE FUNCTION "UniGeSocialSport2.0".aggiungi_livelli_utenti();


--
-- TOC entry 4874 (class 2620 OID 17100)
-- Name: squadrapartecipatorneo trigger_iscrivi_utenti; Type: TRIGGER; Schema: UniGeSocialSport2.0; Owner: postgres
--

CREATE TRIGGER trigger_iscrivi_utenti AFTER INSERT ON "UniGeSocialSport2.0".squadrapartecipatorneo FOR EACH ROW EXECUTE FUNCTION "UniGeSocialSport2.0".iscrivi_utenti_a_eventi();


--
-- TOC entry 4860 (class 2606 OID 16999)
-- Name: evento evento_categoria_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".evento
    ADD CONSTRAINT evento_categoria_fkey FOREIGN KEY (categoria) REFERENCES "UniGeSocialSport2.0".categoria(id) ON DELETE SET NULL;


--
-- TOC entry 4861 (class 2606 OID 17004)
-- Name: evento evento_impianto_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".evento
    ADD CONSTRAINT evento_impianto_fkey FOREIGN KEY (impianto) REFERENCES "UniGeSocialSport2.0".impianto(nome) ON DELETE SET NULL;


--
-- TOC entry 4862 (class 2606 OID 17009)
-- Name: evento evento_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".evento
    ADD CONSTRAINT evento_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport2.0".torneo(id) ON DELETE CASCADE;


--
-- TOC entry 4852 (class 2606 OID 16938)
-- Name: squadra fk_utente_creatore; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".squadra
    ADD CONSTRAINT fk_utente_creatore FOREIGN KEY (creatore) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4858 (class 2606 OID 16986)
-- Name: livello livello_categoria_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".livello
    ADD CONSTRAINT livello_categoria_fkey FOREIGN KEY (categoria) REFERENCES "UniGeSocialSport2.0".categoria(id) ON DELETE CASCADE;


--
-- TOC entry 4859 (class 2606 OID 16981)
-- Name: livello livello_utente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".livello
    ADD CONSTRAINT livello_utente_fkey FOREIGN KEY (utente) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4851 (class 2606 OID 17101)
-- Name: premio premio_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".premio
    ADD CONSTRAINT premio_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport2.0".torneo(id) ON DELETE CASCADE;


--
-- TOC entry 4856 (class 2606 OID 16962)
-- Name: sostituzione sostituzione_utente_richiedente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sostituzione
    ADD CONSTRAINT sostituzione_utente_richiedente_fkey FOREIGN KEY (utente_richiedente) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4857 (class 2606 OID 16967)
-- Name: sostituzione sostituzione_utente_sostitutivo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sostituzione
    ADD CONSTRAINT sostituzione_utente_sostitutivo_fkey FOREIGN KEY (utente_sostitutivo) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4863 (class 2606 OID 17021)
-- Name: sponsorfinanziatorneo sponsorfinanziatorneo_sponsor_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sponsorfinanziatorneo
    ADD CONSTRAINT sponsorfinanziatorneo_sponsor_fkey FOREIGN KEY (sponsor) REFERENCES "UniGeSocialSport2.0".sponsor(id);


--
-- TOC entry 4864 (class 2606 OID 17026)
-- Name: sponsorfinanziatorneo sponsorfinanziatorneo_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".sponsorfinanziatorneo
    ADD CONSTRAINT sponsorfinanziatorneo_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport2.0".torneo(id) ON DELETE SET NULL;


--
-- TOC entry 4865 (class 2606 OID 17038)
-- Name: squadrapartecipatorneo squadrapartecipatorneo_squadra_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".squadrapartecipatorneo
    ADD CONSTRAINT squadrapartecipatorneo_squadra_fkey FOREIGN KEY (squadra) REFERENCES "UniGeSocialSport2.0".squadra(nome) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4866 (class 2606 OID 17043)
-- Name: squadrapartecipatorneo squadrapartecipatorneo_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".squadrapartecipatorneo
    ADD CONSTRAINT squadrapartecipatorneo_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport2.0".torneo(id) ON DELETE SET NULL;


--
-- TOC entry 4855 (class 2606 OID 16950)
-- Name: torneo torneo_creatore_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".torneo
    ADD CONSTRAINT torneo_creatore_fkey FOREIGN KEY (creatore) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4853 (class 2606 OID 16928)
-- Name: utente utente_corsodistudio_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utente
    ADD CONSTRAINT utente_corsodistudio_fkey FOREIGN KEY (corsodistudio) REFERENCES "UniGeSocialSport2.0".corsodistudio(id);


--
-- TOC entry 4854 (class 2606 OID 16933)
-- Name: utente utente_squadra_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utente
    ADD CONSTRAINT utente_squadra_fkey FOREIGN KEY (squadra) REFERENCES "UniGeSocialSport2.0".squadra(nome) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4870 (class 2606 OID 17088)
-- Name: utentegiocaevento utentegiocaevento_evento_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentegiocaevento
    ADD CONSTRAINT utentegiocaevento_evento_fkey FOREIGN KEY (evento) REFERENCES "UniGeSocialSport2.0".evento(id) ON DELETE CASCADE;


--
-- TOC entry 4871 (class 2606 OID 17083)
-- Name: utentegiocaevento utentegiocaevento_utente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentegiocaevento
    ADD CONSTRAINT utentegiocaevento_utente_fkey FOREIGN KEY (utente) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4867 (class 2606 OID 17066)
-- Name: utentevalutautente utentevalutautente_evento_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentevalutautente
    ADD CONSTRAINT utentevalutautente_evento_fkey FOREIGN KEY (evento) REFERENCES "UniGeSocialSport2.0".evento(id) ON DELETE SET NULL;


--
-- TOC entry 4868 (class 2606 OID 17056)
-- Name: utentevalutautente utentevalutautente_utente_valutante_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentevalutautente
    ADD CONSTRAINT utentevalutautente_utente_valutante_fkey FOREIGN KEY (utente_valutante) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4869 (class 2606 OID 17061)
-- Name: utentevalutautente utentevalutautente_utente_valutato_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport2.0; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport2.0".utentevalutautente
    ADD CONSTRAINT utentevalutautente_utente_valutato_fkey FOREIGN KEY (utente_valutato) REFERENCES "UniGeSocialSport2.0".utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2024-06-14 16:33:23

--
-- PostgreSQL database dump complete
--

