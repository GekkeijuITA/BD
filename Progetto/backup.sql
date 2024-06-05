--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-06-05 10:12:44

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
-- TOC entry 6 (class 2615 OID 16399)
-- Name: UniGeSocialSport; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "UniGeSocialSport";


ALTER SCHEMA "UniGeSocialSport" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16407)
-- Name: categoria; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".categoria (
    id numeric NOT NULL,
    denominazione character varying(255) NOT NULL,
    num_giocatori numeric NOT NULL,
    regolamento character varying(255) NOT NULL,
    foto character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport".categoria OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16400)
-- Name: corsodistudio; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".corsodistudio (
    id numeric NOT NULL,
    denominazione character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport".corsodistudio OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16500)
-- Name: evento; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".evento (
    id numeric NOT NULL,
    punti_sq1 numeric,
    punti_sq2 numeric,
    stato character(6) DEFAULT 'APERTO'::bpchar,
    data_svolgimento date NOT NULL,
    categoria numeric,
    impianto character varying(255),
    torneo numeric,
    durata interval NOT NULL
);


ALTER TABLE "UniGeSocialSport".evento OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16414)
-- Name: impianto; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".impianto (
    nome character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    telefono character(10) NOT NULL,
    longitudine real NOT NULL,
    latitudine real NOT NULL,
    via character varying(255) NOT NULL,
    civico numeric NOT NULL,
    interno numeric NOT NULL,
    cap character(5) NOT NULL,
    inizio_disponibilita time without time zone NOT NULL,
    fine_disponibilita time without time zone NOT NULL
);


ALTER TABLE "UniGeSocialSport".impianto OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16481)
-- Name: livello; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".livello (
    utente character varying(30) NOT NULL,
    categoria numeric NOT NULL,
    punteggio integer DEFAULT 0,
    CONSTRAINT livello0_100 CHECK (((punteggio >= 0) AND (punteggio <= 100)))
);


ALTER TABLE "UniGeSocialSport".livello OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16432)
-- Name: premio; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".premio (
    id numeric NOT NULL,
    descrizione character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport".premio OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16464)
-- Name: sostituzione; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".sostituzione (
    id numeric NOT NULL,
    utente_richiedente character varying(30),
    utente_sostitutivo character varying(30)
);


ALTER TABLE "UniGeSocialSport".sostituzione OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16425)
-- Name: sponsor; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".sponsor (
    id numeric NOT NULL,
    denominazione character varying(255) NOT NULL
);


ALTER TABLE "UniGeSocialSport".sponsor OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16535)
-- Name: sponsorfinanziatorneo; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".sponsorfinanziatorneo (
    sponsor numeric NOT NULL,
    torneo numeric NOT NULL
);


ALTER TABLE "UniGeSocialSport".sponsorfinanziatorneo OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16523)
-- Name: squadra; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".squadra (
    nome character varying(255) NOT NULL,
    colore_maglia character varying(255),
    descrizione character varying(255),
    note character varying(255),
    num_max_giocatori numeric NOT NULL,
    num_min_giocatori numeric NOT NULL,
    creatore character varying(30)
);


ALTER TABLE "UniGeSocialSport".squadra OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16552)
-- Name: squadrapartecipatorneo; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".squadrapartecipatorneo (
    squadra character varying(255) NOT NULL,
    torneo numeric NOT NULL
);


ALTER TABLE "UniGeSocialSport".squadrapartecipatorneo OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16439)
-- Name: torneo; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".torneo (
    id numeric NOT NULL,
    descrizione character varying(255) NOT NULL,
    restrizione character varying(255)
);


ALTER TABLE "UniGeSocialSport".torneo OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16446)
-- Name: utente; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".utente (
    username character varying(30) NOT NULL,
    numero_matricola numeric NOT NULL,
    nome character varying(255) NOT NULL,
    cognome character varying(255) NOT NULL,
    anno_nascita integer NOT NULL,
    foto character varying(255) NOT NULL,
    telefono character(10) NOT NULL,
    affidabile boolean DEFAULT false,
    premium boolean DEFAULT false,
    corsodistudio numeric
);


ALTER TABLE "UniGeSocialSport".utente OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16569)
-- Name: utentefapartesquadra; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".utentefapartesquadra (
    utente character varying(30) NOT NULL,
    squadra character varying(255) NOT NULL,
    stato character varying(10) DEFAULT 'In corso'::character varying
);


ALTER TABLE "UniGeSocialSport".utentefapartesquadra OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16608)
-- Name: utenteiscriveevento; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".utenteiscriveevento (
    utente character varying(30) NOT NULL,
    evento numeric NOT NULL,
    data_iscrizione date NOT NULL,
    ruolo character varying(255) DEFAULT 'giocatore'::character varying,
    ritardo boolean DEFAULT false,
    no_show boolean DEFAULT false,
    stato character varying(255)
);


ALTER TABLE "UniGeSocialSport".utenteiscriveevento OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16585)
-- Name: utentevalutautente; Type: TABLE; Schema: UniGeSocialSport; Owner: postgres
--

CREATE TABLE "UniGeSocialSport".utentevalutautente (
    utente_valutante character varying(30) NOT NULL,
    utente_valutato character varying(30) NOT NULL,
    evento numeric NOT NULL,
    data_valutazione date NOT NULL,
    punteggio numeric,
    commento character varying(255),
    CONSTRAINT punteggio0_10 CHECK (((punteggio >= (0)::numeric) AND (punteggio <= (10)::numeric)))
);


ALTER TABLE "UniGeSocialSport".utentevalutautente OWNER TO postgres;

--
-- TOC entry 4962 (class 0 OID 16407)
-- Dependencies: 217
-- Data for Name: categoria; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (1, 'Calcio', 11, 'Regolamento FIFA', 'calcio.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (2, 'Basket', 5, 'Regolamento FIBA', 'basket.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (3, 'Pallavolo', 6, 'Regolamento FIVB', 'pallavolo.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (4, 'Tennis', 1, 'Regolamento ITF', 'tennis.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (5, 'Rugby', 15, 'Regolamento World Rugby', 'rugby.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (6, 'Hockey su prato', 11, 'Regolamento FIH', 'hockey_prato.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (7, 'Pallanuoto', 7, 'Regolamento FINA', 'pallanuoto.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (8, 'Baseball', 9, 'Regolamento WBSC', 'baseball.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (9, 'Cricket', 11, 'Regolamento ICC', 'cricket.jpg');
INSERT INTO "UniGeSocialSport".categoria (id, denominazione, num_giocatori, regolamento, foto) VALUES (10, 'Golf', 1, 'Regolamento R&A', 'golf.jpg');


--
-- TOC entry 4961 (class 0 OID 16400)
-- Dependencies: 216
-- Data for Name: corsodistudio; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (1, 'Ingegneria Informatica');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (2, 'Medicina e Chirurgia');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (3, 'Economia e Commercio');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (4, 'Giurisprudenza');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (5, 'Lettere Moderne');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (6, 'Scienze Biologiche');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (7, 'Ingegneria Meccanica');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (8, 'Scienze Politiche');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (9, 'Architettura');
INSERT INTO "UniGeSocialSport".corsodistudio (id, denominazione) VALUES (10, 'Psicologia');


--
-- TOC entry 4970 (class 0 OID 16500)
-- Dependencies: 225
-- Data for Name: evento; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (4, 35, 30, 'CHIUSO', '2024-06-18', 4, NULL, 4, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (9, 25, 20, 'APERTO', '2024-07-04', 4, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (14, 40, 35, 'CHIUSO', '2024-07-19', 4, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (19, 45, 40, 'APERTO', '2024-08-03', 4, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (24, 50, 45, 'CHIUSO', '2024-08-19', 4, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (29, 55, 50, 'APERTO', '2024-09-03', 4, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (5, 2, 1, 'CHIUSO', '2024-06-20', 5, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (10, 4, 2, 'APERTO', '2024-07-07', 5, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (15, 6, 3, 'CHIUSO', '2024-07-22', 5, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (20, 8, 5, 'APERTO', '2024-08-06', 5, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (25, 12, 8, 'CHIUSO', '2024-08-22', 5, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (30, 14, 9, 'APERTO', '2024-09-06', 5, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (3, 3, 0, 'CHIUSO', '2024-06-15', 3, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (8, 5, 3, 'APERTO', '2024-07-01', 3, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (13, 7, 4, 'CHIUSO', '2024-07-16', 3, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (18, 9, 7, 'APERTO', '2024-07-31', 3, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (23, 11, 9, 'CHIUSO', '2024-08-16', 3, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (28, 13, 10, 'APERTO', '2024-08-31', 3, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (1, 20, 18, 'CHIUSO', '2024-06-10', 1, NULL, 1, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (6, 10, 5, 'APERTO', '2024-06-25', 1, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (11, 18, 16, 'CHIUSO', '2024-07-10', 1, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (16, 22, 20, 'APERTO', '2024-07-25', 1, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (21, 24, 22, 'CHIUSO', '2024-08-10', 1, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (26, 28, 25, 'APERTO', '2024-08-25', 1, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (2, 25, 22, 'CHIUSO', '2024-06-12', 2, NULL, 2, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (7, 15, 12, 'APERTO', '2024-06-28', 2, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (12, 30, 27, 'CHIUSO', '2024-07-13', 2, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (17, 33, 30, 'APERTO', '2024-07-28', 2, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (22, 38, 35, 'CHIUSO', '2024-08-13', 2, NULL, NULL, '02:00:00');
INSERT INTO "UniGeSocialSport".evento (id, punti_sq1, punti_sq2, stato, data_svolgimento, categoria, impianto, torneo, durata) VALUES (27, 42, 40, 'APERTO', '2024-08-28', 2, NULL, NULL, '02:00:00');


--
-- TOC entry 4963 (class 0 OID 16414)
-- Dependencies: 218
-- Data for Name: impianto; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Palasport di Genova', 'info@palasportgenova.it', '0101234567', 8.939, 44.407, 'Piazzale delle Feste', 1, 0, '16128', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Stadio Luigi Ferraris', 'info@luigiferraris.it', '0102345678', 8.952, 44.416, 'Via Giovanni De Prà', 2, 0, '16139', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Piscina Sciorba', 'info@piscinasciorba.it', '0103456789', 8.951, 44.429, 'Via Gelasio Adamoli', 3, 0, '16141', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('RDS Stadium', 'info@rdsstadiumgenova.it', '0104567890', 8.914, 44.398, 'Lungomare Canepa', 4, 0, '16149', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Palazzetto dello Sport', 'info@palazzettosportgenova.it', '0105678901', 8.95, 44.424, 'Corso Sardegna', 5, 0, '16142', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Complesso Polisportivo', 'info@complessopolisportivogenova.it', '0106789012', 8.94, 44.403, 'Via San Vincenzo', 6, 0, '16121', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Arena Albaro Village', 'info@arenaalbarovillage.it', '0107890123', 8.976, 44.391, 'Via dei Mille', 7, 0, '16147', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Campo Sportivo Carlini', 'info@carlini.it', '0108901234', 8.97, 44.41, 'Via Vernazza', 8, 0, '16138', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Palazzo Ducale', 'info@palazzoducale.it', '0109012345', 8.934, 44.407, 'Piazza Matteotti', 9, 0, '16123', '09:00:00', '18:00:00');
INSERT INTO "UniGeSocialSport".impianto (nome, email, telefono, longitudine, latitudine, via, civico, interno, cap, inizio_disponibilita, fine_disponibilita) VALUES ('Teatro Carlo Felice', 'info@teatrocarlofelice.it', '0100123456', 8.933, 44.407, 'Passo Eugenio Montale', 10, 0, '16121', '09:00:00', '18:00:00');


--
-- TOC entry 4969 (class 0 OID 16481)
-- Dependencies: 224
-- Data for Name: livello; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 1, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 2, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 3, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 4, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 5, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 6, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 7, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 8, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 9, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('mario88', 10, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 1, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 2, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 3, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 4, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 5, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 6, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 7, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 8, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 9, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('laura_b', 10, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 1, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 2, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 3, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 4, 95);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 5, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 6, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 7, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 8, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 9, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('luigi_v', 10, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 1, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 2, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 3, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 4, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 5, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 6, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 7, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 8, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 9, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('anna_neri', 10, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 1, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 2, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 3, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 4, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 5, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 6, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 7, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 8, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 9, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('chiara_rosa', 10, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 1, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 2, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 3, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 4, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 5, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 6, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 7, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 8, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 9, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('giovanniG', 10, 70);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 1, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 2, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 3, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 4, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 5, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 6, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 7, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 8, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 9, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('francesca_blu', 10, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 1, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 2, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 3, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 4, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 5, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 6, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 7, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 8, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 9, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('paoloA', 10, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 1, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 2, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 3, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 4, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 5, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 6, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 7, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 8, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 9, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('eleonora_v', 10, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 1, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 2, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 3, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 4, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 5, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 6, 80);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 7, 85);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 8, 90);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 9, 75);
INSERT INTO "UniGeSocialSport".livello (utente, categoria, punteggio) VALUES ('rick_marr', 10, 80);


--
-- TOC entry 4965 (class 0 OID 16432)
-- Dependencies: 220
-- Data for Name: premio; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (1, 'Medaglia d''Oro');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (2, 'Medaglia d''Argento');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (3, 'Medaglia di Bronzo');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (4, 'Trofeo del Campione');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (5, 'Coppa della Vittoria');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (6, 'Premio Miglior Giocatore');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (7, 'Premio Fair Play');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (8, 'Premio della Critica');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (9, 'Targa di Riconoscimento');
INSERT INTO "UniGeSocialSport".premio (id, descrizione) VALUES (10, 'Premio alla Carriera');


--
-- TOC entry 4968 (class 0 OID 16464)
-- Dependencies: 223
-- Data for Name: sostituzione; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (1, 'mario88', 'laura_b');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (2, 'luigi_v', 'anna_neri');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (3, 'chiara_rosa', 'giovanniG');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (4, 'francesca_blu', 'paoloA');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (5, 'mario88', 'paoloA');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (6, 'eleonora_v', 'rick_marr');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (7, 'rick_marr', 'mario88');
INSERT INTO "UniGeSocialSport".sostituzione (id, utente_richiedente, utente_sostitutivo) VALUES (8, 'laura_b', 'luigi_v');


--
-- TOC entry 4964 (class 0 OID 16425)
-- Dependencies: 219
-- Data for Name: sponsor; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (1, 'Nike');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (2, 'Adidas');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (3, 'Puma');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (4, 'Reebok');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (5, 'Under Armour');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (6, 'New Balance');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (7, 'Asics');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (8, 'Fila');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (9, 'Converse');
INSERT INTO "UniGeSocialSport".sponsor (id, denominazione) VALUES (10, 'Lotto');


--
-- TOC entry 4972 (class 0 OID 16535)
-- Dependencies: 227
-- Data for Name: sponsorfinanziatorneo; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".sponsorfinanziatorneo (sponsor, torneo) VALUES (1, 3);
INSERT INTO "UniGeSocialSport".sponsorfinanziatorneo (sponsor, torneo) VALUES (2, 1);
INSERT INTO "UniGeSocialSport".sponsorfinanziatorneo (sponsor, torneo) VALUES (3, 4);
INSERT INTO "UniGeSocialSport".sponsorfinanziatorneo (sponsor, torneo) VALUES (4, 5);


--
-- TOC entry 4971 (class 0 OID 16523)
-- Dependencies: 226
-- Data for Name: squadra; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".squadra (nome, colore_maglia, descrizione, note, num_max_giocatori, num_min_giocatori, creatore) VALUES ('Squadra Rossa', 'Rosso', 'Passione e determinazione sul campo!', NULL, 15, 8, 'mario88');
INSERT INTO "UniGeSocialSport".squadra (nome, colore_maglia, descrizione, note, num_max_giocatori, num_min_giocatori, creatore) VALUES ('Squadra Blu', 'Blu', 'Unisciti a noi e vola alto nello sport!', 'Squadra per principianti', 12, 5, 'laura_b');


--
-- TOC entry 4973 (class 0 OID 16552)
-- Dependencies: 228
-- Data for Name: squadrapartecipatorneo; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra Rossa', 1);
INSERT INTO "UniGeSocialSport".squadrapartecipatorneo (squadra, torneo) VALUES ('Squadra Blu', 1);


--
-- TOC entry 4966 (class 0 OID 16439)
-- Dependencies: 221
-- Data for Name: torneo; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (1, 'Torneo Universitario di Calcio', 'Corso di Studio: Giurisprudenza');
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (2, 'Torneo di Basket per Studenti', 'Età: Under 25');
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (3, 'Torneo Open di Tennis', NULL);
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (4, 'Torneo di Rugby Interfacoltà', NULL);
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (5, 'Torneo di Pallavolo Misto', NULL);
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (6, 'Torneo di Scacchi per Appassionati', NULL);
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (7, 'Torneo di Nuoto Universitario', NULL);
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (8, 'Torneo di Atletica Leggera per Studenti', 'Età: Under 30');
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (9, 'Torneo di Golf per Principianti', 'Corso di Studio: Psicologia');
INSERT INTO "UniGeSocialSport".torneo (id, descrizione, restrizione) VALUES (10, 'Torneo di Ping Pong Libero', NULL);


--
-- TOC entry 4967 (class 0 OID 16446)
-- Dependencies: 222
-- Data for Name: utente; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('mario88', 123456, 'Mario', 'Rossi', 1995, 'mario.jpg', '0123456789', true, false, 1);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('laura_b', 234567, 'Laura', 'Bianchi', 1998, 'laura.jpg', '0234567890', true, true, 2);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('luigi_v', 345678, 'Luigi', 'Verdi', 1997, 'luigi.jpg', '0345678901', false, false, 3);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('anna_neri', 456789, 'Anna', 'Neri', 1996, 'anna.jpg', '0456789012', true, false, 4);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('chiara_rosa', 567890, 'Chiara', 'Rosa', 1999, 'chiara.jpg', '0567890123', true, true, 5);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('giovanniG', 678901, 'Giovanni', 'Gialli', 1994, 'giovanni.jpg', '0678901234', true, false, 6);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('francesca_blu', 789012, 'Francesca', 'Blu', 1993, 'francesca.jpg', '0789012345', false, false, 7);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('paoloA', 890123, 'Paolo', 'Arancioni', 2000, 'paolo.jpg', '0890123456', true, true, 8);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('eleonora_v', 901234, 'Eleonora', 'Viola', 1992, 'eleonora.jpg', '0901234567', false, false, 9);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('rick_marr', 12345, 'Riccardo', 'Marrone', 1991, 'riccardo.jpg', '0012345678', true, true, 10);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('marco_blu', 987654, 'Marco', 'Blu', 1997, 'marco.jpg', '3401122334', true, false, 7);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('giovanna_v', 876543, 'Giovanna', 'Verdi', 1996, 'giovanna.jpg', '3401122335', true, true, 6);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('paoloN', 765432, 'Paolo', 'Neri', 1999, 'paolo.jpg', '3401122336', true, false, 1);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('annaG', 654321, 'Anna', 'Gialli', 1995, 'anna.jpg', '3401122337', true, false, 5);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('luca_r', 543210, 'Luca', 'Rossi', 1998, 'luca.jpg', '3401122338', true, true, 3);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('giulia_m', 432109, 'Giulia', 'Marrone', 1994, 'giulia.jpg', '3401122339', false, false, 10);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('andrea_v', 321098, 'Andrea', 'Verdi', 2000, 'andrea.jpg', '3401122340', true, true, 8);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('elenaB', 210987, 'Elena', 'Bianchi', 1993, 'elena.jpg', '3401122341', false, false, 2);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('riccardoR', 109876, 'Riccardo', 'Rossi', 1992, 'riccardo.jpg', '3401122342', true, false, 9);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('chiaraV', 98765, 'Chiara', 'Verdi', 1991, 'chiara.jpg', '3401122343', false, true, 4);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('andreaN', 87654, 'Andrea', 'Neri', 2001, 'andrea.jpg', '3401122344', true, false, 7);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('saraR', 76543, 'Sara', 'Rossi', 1990, 'sara.jpg', '3401122345', true, true, 6);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('marcoM', 65432, 'Marco', 'Marrone', 1999, 'marco.jpg', '3401122346', false, false, 1);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('silviaG', 54321, 'Silvia', 'Gialli', 1998, 'silvia.jpg', '3401122347', true, false, 5);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('alessandroB', 43210, 'Alessandro', 'Bianchi', 1997, 'alessandro.jpg', '3401122348', true, true, 3);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('federicaR', 32109, 'Federica', 'Rossi', 1996, 'federica.jpg', '3401122349', true, false, 10);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('simoneN', 21098, 'Simone', 'Neri', 1995, 'simone.jpg', '3401122350', false, true, 8);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('lauraG', 10987, 'Laura', 'Gialli', 1994, 'laura.jpg', '3401122351', true, false, 2);
INSERT INTO "UniGeSocialSport".utente (username, numero_matricola, nome, cognome, anno_nascita, foto, telefono, affidabile, premium, corsodistudio) VALUES ('gabrieleV', 9876, 'Gabriele', 'Verdi', 1993, 'gabriele.jpg', '3401122352', true, true, 9);


--
-- TOC entry 4974 (class 0 OID 16569)
-- Dependencies: 229
-- Data for Name: utentefapartesquadra; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".utentefapartesquadra (utente, squadra, stato) VALUES ('mario88', 'Squadra Rossa', 'Accettato');
INSERT INTO "UniGeSocialSport".utentefapartesquadra (utente, squadra, stato) VALUES ('laura_b', 'Squadra Blu', 'Accettato');
INSERT INTO "UniGeSocialSport".utentefapartesquadra (utente, squadra, stato) VALUES ('luigi_v', 'Squadra Rossa', 'Accettato');
INSERT INTO "UniGeSocialSport".utentefapartesquadra (utente, squadra, stato) VALUES ('anna_neri', 'Squadra Blu', 'Accettato');
INSERT INTO "UniGeSocialSport".utentefapartesquadra (utente, squadra, stato) VALUES ('giovanniG', 'Squadra Rossa', 'Accettato');
INSERT INTO "UniGeSocialSport".utentefapartesquadra (utente, squadra, stato) VALUES ('francesca_blu', 'Squadra Blu', 'Accettato');


--
-- TOC entry 4976 (class 0 OID 16608)
-- Dependencies: 231
-- Data for Name: utenteiscriveevento; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('mario88', 1, '2024-06-10', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('laura_b', 1, '2024-06-10', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luigi_v', 2, '2024-06-11', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('anna_neri', 2, '2024-06-11', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giovanniG', 3, '2024-06-12', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('mario88', 4, '2024-06-13', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('laura_b', 4, '2024-06-13', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('anna_neri', 5, '2024-06-14', 'giocatore', false, false, 'rifiutato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giovanniG', 1, '2024-06-10', 'giocatore', false, false, 'rifiutato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('mario88', 2, '2024-06-11', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('laura_b', 2, '2024-06-11', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luigi_v', 3, '2024-06-12', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('anna_neri', 3, '2024-06-12', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giovanniG', 4, '2024-06-13', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luigi_v', 1, '2024-06-01', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luigi_v', 4, '2024-05-23', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luigi_v', 5, '2024-06-14', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('marco_blu', 1, '2024-06-08', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giovanna_v', 2, '2024-06-09', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('paoloN', 3, '2024-06-10', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('annaG', 4, '2024-06-11', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luca_r', 5, '2024-06-12', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giulia_m', 6, '2024-06-13', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('andrea_v', 7, '2024-06-14', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('elenaB', 8, '2024-06-15', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('riccardoR', 9, '2024-06-16', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('chiaraV', 10, '2024-06-17', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('andreaN', 11, '2024-06-18', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('saraR', 12, '2024-06-19', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('marcoM', 13, '2024-06-20', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('silviaG', 14, '2024-06-21', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('alessandroB', 15, '2024-06-22', 'giocatore', true, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('federicaR', 16, '2024-06-23', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('simoneN', 17, '2024-06-24', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('lauraG', 18, '2024-06-25', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('gabrieleV', 19, '2024-06-26', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('andrea_v', 20, '2024-06-27', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('marco_blu', 21, '2024-06-28', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giovanna_v', 22, '2024-06-29', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('paoloN', 23, '2024-06-30', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('annaG', 24, '2024-07-01', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('luca_r', 25, '2024-07-02', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('giulia_m', 26, '2024-07-03', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('andrea_v', 27, '2024-07-04', 'giocatore', false, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('elenaB', 28, '2024-07-05', 'giocatore', true, false, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('riccardoR', 29, '2024-07-06', 'giocatore', false, true, 'accettato');
INSERT INTO "UniGeSocialSport".utenteiscriveevento (utente, evento, data_iscrizione, ruolo, ritardo, no_show, stato) VALUES ('chiaraV', 30, '2024-07-07', 'giocatore', true, false, 'accettato');


--
-- TOC entry 4975 (class 0 OID 16585)
-- Dependencies: 230
-- Data for Name: utentevalutautente; Type: TABLE DATA; Schema: UniGeSocialSport; Owner: postgres
--

INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('laura_b', 'mario88', 1, '2024-06-11', 7, 'Buon compagno di squadra');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('luigi_v', 'mario88', 1, '2024-06-12', 4, 'Poco collaborativo');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mario88', 'laura_b', 2, '2024-06-13', 9, 'Eccellente performance');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('luigi_v', 'laura_b', 2, '2024-06-14', 3, 'Non molto partecipe');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mario88', 'luigi_v', 3, '2024-06-15', 8, 'Ottimo coordinatore');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('laura_b', 'luigi_v', 3, '2024-06-16', 5, 'Ha bisogno di migliorare la comunicazione');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mario88', 'anna_neri', 4, '2024-06-17', 6, 'Partecipativa ma può fare meglio');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('laura_b', 'anna_neri', 4, '2024-06-18', 8, 'Grande giocatrice, molto collaborativa');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mario88', 'giovanniG', 5, '2024-06-19', 4, 'Mancanza di impegno');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('laura_b', 'giovanniG', 5, '2024-06-20', 7, 'Buona prestazione generale');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('mario88', 'francesca_blu', 3, '2024-06-21', 8, 'Eccellente giocatrice, molto motivata');
INSERT INTO "UniGeSocialSport".utentevalutautente (utente_valutante, utente_valutato, evento, data_valutazione, punteggio, commento) VALUES ('laura_b', 'francesca_blu', 3, '2024-06-22', 6, 'Buona prestazione ma può migliorare');


--
-- TOC entry 4761 (class 2606 OID 16413)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 4759 (class 2606 OID 16406)
-- Name: corsodistudio corsodistudio_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".corsodistudio
    ADD CONSTRAINT corsodistudio_pkey PRIMARY KEY (id);


--
-- TOC entry 4785 (class 2606 OID 16507)
-- Name: evento evento_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id);


--
-- TOC entry 4763 (class 2606 OID 16422)
-- Name: impianto impianto_email_key; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".impianto
    ADD CONSTRAINT impianto_email_key UNIQUE (email);


--
-- TOC entry 4765 (class 2606 OID 16420)
-- Name: impianto impianto_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".impianto
    ADD CONSTRAINT impianto_pkey PRIMARY KEY (nome);


--
-- TOC entry 4767 (class 2606 OID 16424)
-- Name: impianto impianto_telefono_key; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".impianto
    ADD CONSTRAINT impianto_telefono_key UNIQUE (telefono);


--
-- TOC entry 4783 (class 2606 OID 16489)
-- Name: livello livello_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".livello
    ADD CONSTRAINT livello_pkey PRIMARY KEY (utente, categoria);


--
-- TOC entry 4771 (class 2606 OID 16438)
-- Name: premio premio_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".premio
    ADD CONSTRAINT premio_pkey PRIMARY KEY (id);


--
-- TOC entry 4781 (class 2606 OID 16470)
-- Name: sostituzione sostituzione_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sostituzione
    ADD CONSTRAINT sostituzione_pkey PRIMARY KEY (id);


--
-- TOC entry 4769 (class 2606 OID 16431)
-- Name: sponsor sponsor_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sponsor
    ADD CONSTRAINT sponsor_pkey PRIMARY KEY (id);


--
-- TOC entry 4789 (class 2606 OID 16541)
-- Name: sponsorfinanziatorneo sponsorfinanziatorneo_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sponsorfinanziatorneo
    ADD CONSTRAINT sponsorfinanziatorneo_pkey PRIMARY KEY (sponsor, torneo);


--
-- TOC entry 4787 (class 2606 OID 16529)
-- Name: squadra squadra_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".squadra
    ADD CONSTRAINT squadra_pkey PRIMARY KEY (nome);


--
-- TOC entry 4791 (class 2606 OID 16558)
-- Name: squadrapartecipatorneo squadrapartecipatorneo_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".squadrapartecipatorneo
    ADD CONSTRAINT squadrapartecipatorneo_pkey PRIMARY KEY (squadra, torneo);


--
-- TOC entry 4773 (class 2606 OID 16445)
-- Name: torneo torneo_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".torneo
    ADD CONSTRAINT torneo_pkey PRIMARY KEY (id);


--
-- TOC entry 4775 (class 2606 OID 16456)
-- Name: utente utente_numero_matricola_key; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utente
    ADD CONSTRAINT utente_numero_matricola_key UNIQUE (numero_matricola);


--
-- TOC entry 4777 (class 2606 OID 16454)
-- Name: utente utente_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utente
    ADD CONSTRAINT utente_pkey PRIMARY KEY (username);


--
-- TOC entry 4779 (class 2606 OID 16458)
-- Name: utente utente_telefono_key; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utente
    ADD CONSTRAINT utente_telefono_key UNIQUE (telefono);


--
-- TOC entry 4793 (class 2606 OID 16574)
-- Name: utentefapartesquadra utentefapartesquadra_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentefapartesquadra
    ADD CONSTRAINT utentefapartesquadra_pkey PRIMARY KEY (utente, squadra);


--
-- TOC entry 4797 (class 2606 OID 16617)
-- Name: utenteiscriveevento utenteiscriveevento_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utenteiscriveevento
    ADD CONSTRAINT utenteiscriveevento_pkey PRIMARY KEY (utente, evento);


--
-- TOC entry 4795 (class 2606 OID 16592)
-- Name: utentevalutautente utentevalutautente_pkey; Type: CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentevalutautente
    ADD CONSTRAINT utentevalutautente_pkey PRIMARY KEY (utente_valutante, utente_valutato, evento);


--
-- TOC entry 4803 (class 2606 OID 16508)
-- Name: evento evento_categoria_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".evento
    ADD CONSTRAINT evento_categoria_fkey FOREIGN KEY (categoria) REFERENCES "UniGeSocialSport".categoria(id) ON DELETE SET NULL;


--
-- TOC entry 4804 (class 2606 OID 16513)
-- Name: evento evento_impianto_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".evento
    ADD CONSTRAINT evento_impianto_fkey FOREIGN KEY (impianto) REFERENCES "UniGeSocialSport".impianto(nome) ON DELETE SET NULL;


--
-- TOC entry 4805 (class 2606 OID 16518)
-- Name: evento evento_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".evento
    ADD CONSTRAINT evento_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport".torneo(id) ON DELETE CASCADE;


--
-- TOC entry 4801 (class 2606 OID 16495)
-- Name: livello livello_categoria_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".livello
    ADD CONSTRAINT livello_categoria_fkey FOREIGN KEY (categoria) REFERENCES "UniGeSocialSport".categoria(id) ON DELETE CASCADE;


--
-- TOC entry 4802 (class 2606 OID 16490)
-- Name: livello livello_utente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".livello
    ADD CONSTRAINT livello_utente_fkey FOREIGN KEY (utente) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4799 (class 2606 OID 16471)
-- Name: sostituzione sostituzione_utente_richiedente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sostituzione
    ADD CONSTRAINT sostituzione_utente_richiedente_fkey FOREIGN KEY (utente_richiedente) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4800 (class 2606 OID 16476)
-- Name: sostituzione sostituzione_utente_sostitutivo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sostituzione
    ADD CONSTRAINT sostituzione_utente_sostitutivo_fkey FOREIGN KEY (utente_sostitutivo) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4807 (class 2606 OID 16542)
-- Name: sponsorfinanziatorneo sponsorfinanziatorneo_sponsor_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sponsorfinanziatorneo
    ADD CONSTRAINT sponsorfinanziatorneo_sponsor_fkey FOREIGN KEY (sponsor) REFERENCES "UniGeSocialSport".sponsor(id);


--
-- TOC entry 4808 (class 2606 OID 16547)
-- Name: sponsorfinanziatorneo sponsorfinanziatorneo_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".sponsorfinanziatorneo
    ADD CONSTRAINT sponsorfinanziatorneo_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport".torneo(id) ON DELETE SET NULL;


--
-- TOC entry 4806 (class 2606 OID 16530)
-- Name: squadra squadra_creatore_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".squadra
    ADD CONSTRAINT squadra_creatore_fkey FOREIGN KEY (creatore) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4809 (class 2606 OID 16559)
-- Name: squadrapartecipatorneo squadrapartecipatorneo_squadra_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".squadrapartecipatorneo
    ADD CONSTRAINT squadrapartecipatorneo_squadra_fkey FOREIGN KEY (squadra) REFERENCES "UniGeSocialSport".squadra(nome) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4810 (class 2606 OID 16564)
-- Name: squadrapartecipatorneo squadrapartecipatorneo_torneo_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".squadrapartecipatorneo
    ADD CONSTRAINT squadrapartecipatorneo_torneo_fkey FOREIGN KEY (torneo) REFERENCES "UniGeSocialSport".torneo(id) ON DELETE SET NULL;


--
-- TOC entry 4798 (class 2606 OID 16459)
-- Name: utente utente_corsodistudio_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utente
    ADD CONSTRAINT utente_corsodistudio_fkey FOREIGN KEY (corsodistudio) REFERENCES "UniGeSocialSport".corsodistudio(id);


--
-- TOC entry 4811 (class 2606 OID 16580)
-- Name: utentefapartesquadra utentefapartesquadra_squadra_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentefapartesquadra
    ADD CONSTRAINT utentefapartesquadra_squadra_fkey FOREIGN KEY (squadra) REFERENCES "UniGeSocialSport".squadra(nome) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4812 (class 2606 OID 16575)
-- Name: utentefapartesquadra utentefapartesquadra_utente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentefapartesquadra
    ADD CONSTRAINT utentefapartesquadra_utente_fkey FOREIGN KEY (utente) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4816 (class 2606 OID 16623)
-- Name: utenteiscriveevento utenteiscriveevento_evento_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utenteiscriveevento
    ADD CONSTRAINT utenteiscriveevento_evento_fkey FOREIGN KEY (evento) REFERENCES "UniGeSocialSport".evento(id) ON DELETE CASCADE;


--
-- TOC entry 4817 (class 2606 OID 16618)
-- Name: utenteiscriveevento utenteiscriveevento_utente_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utenteiscriveevento
    ADD CONSTRAINT utenteiscriveevento_utente_fkey FOREIGN KEY (utente) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4813 (class 2606 OID 16603)
-- Name: utentevalutautente utentevalutautente_evento_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentevalutautente
    ADD CONSTRAINT utentevalutautente_evento_fkey FOREIGN KEY (evento) REFERENCES "UniGeSocialSport".evento(id) ON DELETE SET NULL;


--
-- TOC entry 4814 (class 2606 OID 16593)
-- Name: utentevalutautente utentevalutautente_utente_valutante_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentevalutautente
    ADD CONSTRAINT utentevalutautente_utente_valutante_fkey FOREIGN KEY (utente_valutante) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4815 (class 2606 OID 16598)
-- Name: utentevalutautente utentevalutautente_utente_valutato_fkey; Type: FK CONSTRAINT; Schema: UniGeSocialSport; Owner: postgres
--

ALTER TABLE ONLY "UniGeSocialSport".utentevalutautente
    ADD CONSTRAINT utentevalutautente_utente_valutato_fkey FOREIGN KEY (utente_valutato) REFERENCES "UniGeSocialSport".utente(username) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2024-06-05 10:12:45

--
-- PostgreSQL database dump complete
--

