--1--
SELECT * FROM information_schema.table_privileges WHERE table_schema = 'unicorsi'
--2--
CREATE USER yoda PASSWORD 'yoda';
CREATE USER luke PASSWORD 'luke';
--3--
-- Collegati come yoda --
set search_path to unicorsi;
SELECT * FROM studenti; -- ERROR: relation "studenti" does not exist
-- Dà questo errore perchè non riesce a vedere la tabella in quanto non ne ha i privilegi.
--4--
SELECT * FROM information_schema.table_privileges WHERE grantee = 'yoda'; 
-- Eseguendo questa query non risulta nessun privilegio nella tabella per l'utente yoda.
--5--
-- Collegati come postgres
GRANT USAGE ON SCHEMA unicorsi TO yoda WITH GRANT OPTION;
--GRANT USAGE ON SCHEMA unicorsi TO luke WITH GRANT OPTION;--

set search_path to unicorsi;
GRANT SELECT ON esami,professori,studenti TO yoda;
GRANT SELECT ON corsi,corsidilaurea TO yoda WITH GRANT OPTION;
--6--
SET ROLE yoda;
--7--
SELECT * FROM studenti; -- Operazione eseguita con successo, restituisce tutta la tabella degli studenti perchè abbiamo il permesso di lettura--
--8--
SELECT * FROM information_schema.table_privileges WHERE grantee = 'yoda'; 
--9--
GRANT SELECT ON studenti TO luke; -- Non viene eseguita, perchè l'utente yoda non ha i permessi di delegazione su studenti--
--10--
GRANT SELECT ON corsi TO luke; -- Viene eseguito perchè yoda ha i permessi di delegazione su corsi--
--11--
SET ROLE postgres;
--12--
REVOKE SELECT
ON corsi
FROM yoda
RESTRICT -- Non viene eseguita perchè yoda ha concesso i privilegi a luke sulla stessa tabella --
--13--
SELECT * FROM information_schema.table_privileges WHERE grantee = 'luke';
--14--
REVOKE SELECT 
ON corsi
FROM yoda
CASCADE -- Viene eseguito perchè abbiamo tolto anche a luke il permesso --
--15--
SELECT * FROM information_schema.table_privileges WHERE grantee = 'yoda';
SELECT * FROM information_schema.table_privileges WHERE grantee = 'luke';
--16--
CREATE ROLE jedi;
CREATE ROLE maestrojedi;

REVOKE SELECT 
ON corsi, studenti
FROM yoda,luke

GRANT jedi TO maestrojedi;

GRANT ALL PRIVILEGES
ON studenti
TO jedi;

GRANT ALL PRIVILEGES
ON corsi
TO maestrojedi;

GRANT maestrojedi
TO yoda;

GRANT jedi
TO luke;

SELECT * FROM information_schema.table_privileges WHERE grantee = 'yoda';
-- Yoda e Luke hanno gli stessi privilegi, ma Luke non li può usare perchè non ha accesso a unicorsi
--17--
REVOKE SELECT 
ON corsi, studenti
FROM yoda,luke

GRANT SELECT
ON studentinonintesi
TO yoda

SELECT * FROM information_schema.table_privileges WHERE grantee = 'yoda';

GRANT ALL PRIVILEGES
ON studentinonintesi
TO yoda

SELECT * FROM information_schema.table_privileges WHERE grantee = 'yoda';
--18--
REVOKE SELECT 
ON corsi, studenti
FROM luke

CREATE VIEW num_nonintesi AS
SELECT COUNT(*) FROM studentinonintesi;

GRANT SELECT
ON num_nonintesi, corsi, studenti
TO luke;

SELECT * FROM information_schema.table_privileges WHERE grantee = 'luke';
--19--
GRANT SELECT
ON studentimate
TO luke;

SELECT * FROM information_schema.table_privileges WHERE grantee = 'luke';

GRANT ALL PRIVILEGES
ON studentimate
TO luke;

SELECT * FROM information_schema.table_privileges WHERE grantee = 'luke';