--CREAZIONE SCHEMA DI ESEMPIO

create schema banca;
set search_path to banca;

CREATE TABLE ContoCorrente(
numero integer CONSTRAINT Pk PRIMARY KEY DEFERRABLE INITIALLY IMMEDIATE, -- Riga 291 spiegazione
	--capiremo dopo cosa significa
saldo integer not null
);

--TRANSAZIONE

--Una unità logica di elaborazione che corrisponde a una serie di operazioni fisiche elementari 
--(letture/scritture su tuple) sulla base di dati 
--a cui viene garantita un'esecuzione che soddisfa alcune buone proprieta'.

--Nel seguito STATO = ISTANZA della base di dati generata da una sequenza di operazioni

--OPERAZIONI PRELIMINARI

--Abilitate AUTO COMMIT per tutte le finestre di esecuzione comandi che utilizzerete 
--in questa esercitazione (da menu a destra al simbolo della freccia per l'esecuzione.


--TRANSAZIONI IMPLICITE

--Iniziamo ad inserire solo alcuni conti correnti nella tabella contoCorrente. 
--Come primo inserimento, inserire nella relazione una tupla con valori (5,0).

INSERT INTO ContoCorrente VALUES (5,0);

SELECT * FROM ContoCorrente;

--Consideriamo ora la seguente sequenza di inserimenti

INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
INSERT INTO ContoCorrente VALUES (5,10); -- Chiave duplicata
INSERT INTO ContoCorrente VALUES (6,0);

--ed eseguiamo ciascun comando di inserimento singolarmente,
--fermandoci nel caso si verifiche un errore.

--Quante e quali tuple vengono inserite nella relazione? 
--Guardiamo il contenuto della tabella:

SELECT * FROM ContoCorrente;

--Nel caso in cui i comandi vengano eseguiti singolarmente, 
--ogni comando viene interpretato come una singola transazione 
--(per default e' attiva l'opzione AUTOCOMMIT - guardarare il menu a fianco della freccia per l'esecuzione dei comandi)
--Quindi i primi 4 comandi vengono eseguiti con successo mentre il quinto non viene eseguito 
--in quanto porta alla violazione di un vincolo di integrita' (vincolo di chiave primaria).

--Cancellate adesso le tuple corrispondenti ai conti correnti numero 1,2,3,4. 
--Rieseguite i comandi per l'inserimento dei conti correnti 1,2,3,4,5,6, 
--selezionandoli ed eseguendoli tutti insieme.

DELETE FROM ContoCorrente
WHERE numero <= 4;

SELECT * FROM ContoCorrente;

INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
INSERT INTO ContoCorrente VALUES (5,10);
INSERT INTO ContoCorrente VALUES (6,0);

--Cosa cambia rispetto al caso precedente? Quante tuple vengono inserite nella relazione? Perche'? 
--Vediamo:

SELECT * FROM ContoCorrente;

--In questo caso, tutti i comandi vengono considerati come una singola unita' di elaborazione, 
--chiamata TRANSAZIONE, durante la cui esecuzione vengono garantite determinate proprieta'. 
--L'inizio e la fine della transazione in questo caso non corrispondono a comandi 
--ma sono definiti implicitamente dall'inizio e dalla fine della nostra selezione.

--La prima di queste proprieta' e' l'ATOMICITA': 
--se si verifica un errore 
--(in questo caso la violazione di un vincolo di integrita' di chiave primaria 
--ma potrebbe anche essere una caduta di corrente o un qualunque altro guasto di sistema), 
--la transazione viene ABORTITA e lo stato della base di dati viene riportato 
--a quello esistente prima della sua esecuzione (il sistema esegue una operazione di ROLLBACK). 
--Se non si verifica alcun errore, allora la transazione termina con successo 
--(il sistema esegue una operazione di COMMIT).

--Nel nostro esempio: se eseguiamo tutti i comandi insieme, 
--il sistema li esegue come una singola transazione, 
--quindi visto che dopo l'esecuzione del quinto comando viene violato un vincolo di integrita', 
--tutti i comandi eseguiti in precedenza vengono disfatti, i seguenti comandi non vengono eseguiti
--e lo stato viene riportato a quello esistente prima dell'inizio della transazione 
--(si dice che la transazione ABORTISCE).

--L'atomicita' vale anche quando piu' tuple vengono aggiornate nel contesto dello stesso comando. 
--Supponiamo che i numeri che identificano i conti correnti debbano essere cambiati: 
--i numeri inferiori o uguali a 3 devono essere moltiplicati per 2.
--I numeri di conto corrente devono diventare: 2, 4, 6, 4, 5

--Per prima cosa inseriamo nuovamente i conti correnti 1-4 
--(non inseriti dall'esercizio precedente per ABORT della transazione):

INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);

SELECT * FROM ContoCorrente;

--Adesso aggiorniamo come sopra descritto:

UPDATE ContoCorrente
SET numero = numero * 2
WHERE numero <= 3;

--E guardiamo il contenuto della tabella:

SELECT * FROM ContoCorrente;

--L'aggiornamento della tupla con numero 2 porta a una violazione di vincolo di integrita' 
--(crea una tupla con numero pari a 4 e un conto corrente con questo numero esiste gia') 
--mentre l'aggiornamento della tupla numero 3 no. 
--E' sufficiente l'errore su una singola tupla per riportare lo stato della base di dati 
--a quello esistente prima dell'esecuzione del comando di UPDATE: 
--tutte le tuple vengono aggiornate oppure nessuna (ATOMICITA', questa volta relativa a un singolo comando).

--In questo caso quindi, nessuna tupla viene aggiornata.

--TRANSAZIONI ESPLICITE

--L'esecuzione di un singolo comando e' sempre transazionale (se AUTOCOMMIT e' attivo)
--Per garantire che un insieme di comandi venga eseguito come una transazione, 
--senza necessita' di selezionare tutti i comandi insieme, 
--e'anche possibile utilizzare dei comandi espliciti:
--BEGIN; o START TRANSACTION; inizio transazione
--COMMIT; oppure ROLLBACK; fine transazione
--BEGIN setta AUTOCOMMIT a false e a questo punto la transazione corrisponde 
--a tutti i comandi fino al successivo COMMIT o ROLLBACK;

--Cancellate adesso le tuple corrispondenti ai conti correnti numero 1,2,3,4. 
--Rieseguite i comandi per l'inserimento dei conti correnti 1,2,3,4,5,6 
--all'interno di una transazione esplicita (quindi tra i comandi BEGIN; e COMMIT;) 
--ed eseguite la transazione.

DELETE FROM ContoCorrente
WHERE numero <= 4;

SELECT * FROM ContoCorrente;

--eseguite i comandi BEGIN e COMMIT da soli
--vedrete che viene disabilitata la possibilita' di scegliere AUTOCOMMIT fino a che la transazione non termina

BEGIN;
INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
INSERT INTO ContoCorrente VALUES (5,10);
INSERT INTO ContoCorrente VALUES (6,0);
COMMIT;

--dopo COMMIT vedrete che viene nuovamente abilitato AUTOCOMMIT

--Cosa cambia rispetto al caso precedente? Quante tuple vengono inserite nella relazione? Perche'? 

SELECT * FROM ContoCorrente;

--Non cambia niente rispetto al caso precedente, 
--abbiamo solo iniziato e terminato la transazione in modo esplicito.


--PROPRIETA' DELLE TRANSAZIONI:
--ACID:D-DURABILITA'/PERSISTENZA

--Cancellate le tuple corrispondenti ai conti correnti numero 1,2,3,4. 
--Rieseguite i comandi SQL per l'inserimento dei conti correnti 1,2,3,4, 
--all'interno di una transazione esplicita (quindi tra i comandi BEGIN e COMMIT) 

DELETE FROM ContoCorrente
WHERE numero <= 4;

--se avete fatto tutto correttamente il comando DELETE non serve

SELECT * FROM ContoCorrente;

--eseguite i comandi BEGIN e COMMIT da soli

BEGIN;
INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
COMMIT;

--Cosa cambia rispetto al caso precedente? Quante tuple vengono inserite nella relazione? Perche'?

SELECT * FROM ContoCorrente;

--In questo caso abbiamo iniziato e terminato in modo esplicito la transazione, 
--non vengono violati vincoli e quindi tutte le modifiche vengono rese persistenti.

--Questa rappresenta la proprieta' di D-DURABILITA'/PERSISTENZA: se la transazione termina correttamente, 
--TUTTE le modifiche richieste vengono rese persistenti, modificando in modo permanente la base di dati.

--TRANSAZIONI: ROLLBACK ESPLICITO

--Cancellate di nuovo le tuple corrispondenti ai conti correnti numero 1,2,3,4. 
--Rieseguita i comandi SQL per l'inserimento dei conti correnti 1,2,3,4, 
--all'interno di una transazione esplicita inserendo ROLLBACK al posto di COMMIT. 

DELETE FROM ContoCorrente
WHERE NUMERO <= 4;

SELECT * FROM ContoCorrente;

--eseguite i comandi BEGIN e COMMIT da soli

BEGIN;
INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
ROLLBACK;

--Cosa cambia rispetto al caso precedente? Quante tuple vengono inserite nella relazione? Perche'?

SELECT * FROM ContoCorrente;

--In questo caso, non si viola alcun vincolo ma la transazione esegue ROLLBACK, 
--quindi la transazione viene abortita per richiesta della transazione stessa.

--PROPRIETA' DELLE TRANSAZIONI:
--ACID:C-CONSISTENZA (ALTRI ESEMPI IMPORTANTI)

--Abbiamo gia' visto negli esempi precedenti che, per la proprieta' di CONSISTENZA, 
--se viene violato un vincolo di integrita' la transazione abortisce.

--Piu' in generale, per la proprieta' di CONSISTENZA lo stato iniziale e finale di una transazione 
--devono sempre soddisfare tutti i vincoli di integrita' esistenti. 
--Gli stati intermedi possono pero' violare la consistenza.

--Negli esempi precedenti, lo stato intermedio di una transazione 
--(quello ottenuto eseguendo l'i-esimo comando) portava a una violazione del vincolo 
--e anche alla fine dell'esecuzione di tutti i comandi lo stato generata continuava a violare il vincolo. 
--Questo ha portato il sistema ad abortire la transazione. 

--Ci sono pero' dei casi in cui uno stato intermedio della transazione viola un vincolo 
--ma poi lo stato finale lo soddisfa nuovamente:

--Cancellate le tuple corrispondenti ai conti correnti numero 1,2,3,4. 
--Rieseguite i comandi SQL per l'inserimento dei conti correnti 1,2,3,4,5,6 
--all'interno di una transazione esplicita che termina con COMMIT. 
--La transazione, dopo l'ultimo inserimento, esegue una cancellazione dei conti con saldo superiore o uguale a 10.

SELECT * FROM ContoCorrente;

--eseguite i comandi BEGIN e COMMIT da soli

BEGIN;
INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
INSERT INTO ContoCorrente VALUES (5,10);
INSERT INTO ContoCorrente VALUES (6,0);
DELETE FROM ContoCorrente
WHERE saldo >= 10;
COMMIT;

--In questo caso, viene prima inserita la tupla (5, 10), che viola il vincolo 
--ma successivamente la stessa tupla viene cancellata dal comando finale di DELETE. 
--Quindi lo stato finale non viola il vincolo.

--Ma la transazioni effettua il COMMIT o abortisce? Cosa cambia rispetto al caso precedente? 
--Quante tuple vengono inserite nella relazione? Perche'?

SELECT * FROM ContoCorrente;

--La transazione abortisce (non ci sono le tuple 1-4). 
--Questo perche' per default tutti i vincoli di integrita' vengono verificati 
--in modo IMMEDIATE dopo l'esecuzione di ciascun comando.

--E' pero' possibile modificare questo comportamento specificando al sistema 
--che vogliamo che la verifica dei vincoli venga effettuata SOLO sullo stato finale.

--In generale, i vincoli in PostgreSQL possono essere
--DEFERRABLE INITIALLY IMMEDIATE: 
--il vincolo viene considerato a valutazione immediata ma il tipo di valutazione può essere cambiata
--questo è il modo con cui abbiamo definito il nostro vincolo
--DEFERRABLE INITIALLY DEFERRED
--il vincolo viene considerato a valutazione dififerita ma il tipo di valutazione può essere cambiata
--NOT DEFERRABLE
--il vincolo viene considerato a valutazione immediata e il tipo di valutazione può essere cambiata (default)
--Solo i vincoli di tipo UNIQUE, PRIMARY KEY, e REFERENCES (foreign key) possono essere differiti. 
--I vincoli NOT NULL e CHECK non possono essere differiti.

--Quando il vincolo è DEFERRABLE, il tipo di valutazione può essere cambiata con il comando
--SET CONSTRAINTS { ALL |name[, ...] } { DEFERRED | IMMEDIATE },
--In PostgreSQL, tutti i vincoli per default si considerano non differibili a valutazione immediata. 

--Cancellate le tuple corrispondenti ai conti correnti numero 1,2,3,4. 
--Rieseguite i comandi SQL per l'inserimento dei conti correnti 1,2,3,4,5,6
--all'interno di una transazione esplicita che termina con COMMIT 
--e che setta la valutazione dei vincoli in modo differito. 
--La transazione, dopo l'ultimo inserimento, esegue una cancellazione dei conti con saldo superiore o uguale a 10. 

DELETE FROM ContoCorrente
WHERE numero <= 4;

SELECT * FROM ContoCorrente;

--eseguite i comandi BEGIN e COMMIT da soli

BEGIN;
SET CONSTRAINTS Pk DEFERRED;
INSERT INTO ContoCorrente VALUES (1,0);
INSERT INTO ContoCorrente VALUES (2,0);
INSERT INTO ContoCorrente VALUES (3,0);
INSERT INTO ContoCorrente VALUES (4,0);
INSERT INTO ContoCorrente VALUES (5,10);
INSERT INTO ContoCorrente VALUES (6,0);
DELETE FROM ContoCorrente
WHERE saldo >= 10;
COMMIT;

--Verifichiamo cosa è successo all'istanza della tabella

SELECT * FROM ContoCorrente;

--La transazione è terminata con successo: 
--il vincolo è stato violato in uno stato intermedio ma alla fine della transazione il vincolo era soddisfatto
--Poiché la modalità di valutazione era differita, la transazione è quindi terminata con successo 
--e le modifiche vengono rese persistenti

--Le transazioni che abbiamo utilizzato oggi si chiamano TRANSAZIONI FLAT. 
--In SQL e in PostgreSQL esistono altri tipi di transazioni che, in caso di errore, 
--permettono di non perdere tutto il lavoro fatto ma solo una parte specifica. 


--PROPRIETA' DELLE TRANSAZIONI:
--ACID: I-Isolamento

--Non la vediamo.

