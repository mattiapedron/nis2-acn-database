# Data dictionary

## azienda

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo tecnico |
| codice_acn | VARCHAR(50) | NOT NULL, UNIQUE | Codice dell'organizzazione |
| ragione_sociale | VARCHAR(200) | NOT NULL | Denominazione |
| partita_iva | VARCHAR(20) | UNIQUE | Identificativo fiscale |
| settore | VARCHAR(120) | NOT NULL | Settore di attività |
| tipologia_soggetto | VARCHAR(20) | CHECK | ESSENZIALE o IMPORTANTE |
| pec | VARCHAR(254) | — | Indirizzo PEC |
| attiva | BOOLEAN | DEFAULT TRUE | Stato dell'organizzazione |
| created_at | TIMESTAMPTZ | NOT NULL | Data di creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Data di aggiornamento |

## sede

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo tecnico |
| azienda_id | BIGINT | FK, NOT NULL | Azienda di appartenenza |
| codice | VARCHAR(30) | NOT NULL | Codice interno |
| denominazione | VARCHAR(150) | NOT NULL | Nome della sede |
| tipo_sede | VARCHAR(20) | CHECK | LEGALE, OPERATIVA, DATACENTER o ALTRO |
| indirizzo | VARCHAR(200) | — | Indirizzo |
| comune | VARCHAR(100) | — | Comune |
| provincia | VARCHAR(2) | — | Sigla provincia |
| nazione | CHAR(2) | DEFAULT IT | Codice paese |
| created_at | TIMESTAMPTZ | NOT NULL | Data di creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Data di aggiornamento |

## tipo_asset

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | SMALLINT | PK, identity | Identificativo |
| codice | VARCHAR(30) | NOT NULL, UNIQUE | Codice della tipologia |
| descrizione | VARCHAR(150) | NOT NULL | Descrizione |

## asset

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo tecnico |
| azienda_id | BIGINT | FK, NOT NULL | Azienda proprietaria |
| sede_id | BIGINT | FK | Sede di collocazione |
| tipo_asset_id | SMALLINT | FK, NOT NULL | Tipologia |
| codice | VARCHAR(50) | NOT NULL | Codice interno |
| nome | VARCHAR(150) | NOT NULL | Denominazione |
| descrizione | TEXT | — | Descrizione |
| livello_criticita | VARCHAR(10) | CHECK | BASSA, MEDIA, ALTA o CRITICA |
| stato | VARCHAR(20) | CHECK | ATTIVO, MANUTENZIONE o DISMESSO |
| data_inizio_validita | DATE | NOT NULL | Inizio validità |
| data_fine_validita | DATE | CHECK | Fine validità |
| versione | INTEGER | CHECK > 0 | Numero di versione |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## servizio

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo tecnico |
| azienda_id | BIGINT | FK, NOT NULL | Azienda |
| codice | VARCHAR(50) | NOT NULL | Codice del servizio |
| nome | VARCHAR(150) | NOT NULL | Denominazione |
| descrizione | TEXT | — | Descrizione |
| livello_criticita | VARCHAR(10) | CHECK | Livello di criticità: BASSA, MEDIA, ALTA, CRITICA |
| rto_minuti | INTEGER | CHECK >= 0 | Tempo massimo di ripristino |
| rpo_minuti | INTEGER | CHECK >= 0 | Perdita massima di dati ammessa |
| stato | VARCHAR(20) | CHECK | ATTIVO, SOSPESO o DISMESSO |
| versione | INTEGER | CHECK > 0 | Numero di versione |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## asset_servizio

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| azienda_id | BIGINT | PK, FK | Azienda comune alle due entità |
| asset_id | BIGINT | PK, FK | Asset |
| servizio_id | BIGINT | PK, FK | Servizio |
| ruolo_supporto | VARCHAR(20) | CHECK | PRIMARIO, SECONDARIO o BACKUP |
| livello_dipendenza | VARCHAR(10) | CHECK | Criticità della dipendenza: BASSA, MEDIA, ALTA, CRITICA |
| note | TEXT | — | Informazioni aggiuntive |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |

## fornitore

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo tecnico |
| codice | VARCHAR(40) | NOT NULL, UNIQUE | Codice del fornitore |
| ragione_sociale | VARCHAR(200) | NOT NULL | Denominazione |
| identificativo_fiscale | VARCHAR(30) | UNIQUE | Identificativo fiscale |
| paese | CHAR(2) | NOT NULL | Paese |
| email | VARCHAR(254) | — | E-mail |
| telefono | VARCHAR(30) | — | Telefono |
| attivo | BOOLEAN | DEFAULT TRUE | Stato |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## dipendenza_fornitore

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo |
| azienda_id | BIGINT | FK, NOT NULL | Azienda |
| fornitore_id | BIGINT | FK, NOT NULL | Fornitore |
| asset_id | BIGINT | FK | Asset dipendente |
| servizio_id | BIGINT | FK | Servizio dipendente |
| tipo_dipendenza | VARCHAR(30) | CHECK | CLOUD, SOFTWARE, BACKUP o ALTRO (altre categorie) |
| livello_criticita | VARCHAR(10) | CHECK | Criticità: BASSA, MEDIA, ALTA, CRITICA |
| riferimento_contratto | VARCHAR(100) | — | Contratto |
| data_inizio | DATE | NOT NULL | Inizio validità |
| data_fine | DATE | CHECK | Fine validità |
| note | TEXT | — | Informazioni aggiuntive |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## persona

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo |
| azienda_id | BIGINT | FK, NOT NULL | Azienda |
| nome | VARCHAR(80) | NOT NULL | Nome |
| cognome | VARCHAR(80) | NOT NULL | Cognome |
| email | VARCHAR(254) | NOT NULL | E-mail |
| telefono | VARCHAR(30) | — | Telefono |
| attiva | BOOLEAN | DEFAULT TRUE | Stato |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## ruolo

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | SMALLINT | PK, identity | Identificativo |
| codice | VARCHAR(40) | NOT NULL, UNIQUE | Codice del ruolo |
| descrizione | VARCHAR(150) | NOT NULL | Descrizione |

## responsabilita

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo |
| azienda_id | BIGINT | FK, NOT NULL | Azienda |
| persona_id | BIGINT | FK, NOT NULL | Persona |
| ruolo_id | SMALLINT | FK, NOT NULL | Ruolo |
| asset_id | BIGINT | FK | Asset specifico |
| servizio_id | BIGINT | FK | Servizio specifico |
| principale | BOOLEAN | DEFAULT FALSE | Indicatore di responsabilità principale |
| data_inizio | DATE | NOT NULL | Inizio incarico |
| data_fine | DATE | CHECK | Fine incarico |
| note | TEXT | — | Note |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## punto_contatto

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo |
| azienda_id | BIGINT | FK, NOT NULL | Azienda |
| persona_id | BIGINT | FK, NOT NULL | Persona |
| ambito | VARCHAR(30) | CHECK | NIS2, INCIDENT_RESPONSE, TECNICO, AMMINISTRATIVO o ALTRO |
| principale | BOOLEAN | DEFAULT FALSE | Contatto principale |
| canale_preferito | VARCHAR(10) | CHECK DEFAULT EMAIL | EMAIL, TELEFONO o PEC |
| note | TEXT | — | Note |
| created_at | TIMESTAMPTZ | NOT NULL | Creazione |
| updated_at | TIMESTAMPTZ | NOT NULL | Ultimo aggiornamento |

## audit_log

| Campo | Tipo | Vincoli | Descrizione |
|---|---|---|---|
| id | BIGINT | PK, identity | Identificativo |
| tabella | VARCHAR(63) | NOT NULL | Tabella modificata |
| record_id | BIGINT | — | Record coinvolto |
| operazione | CHAR(1) | NOT NULL, CHECK | I, U o D |
| dati_precedenti | JSONB | — | Valori prima della modifica |
| dati_successivi | JSONB | — | Valori dopo la modifica |
| modificato_il | TIMESTAMPTZ | NOT NULL | Data e ora |
| modificato_da | TEXT | NOT NULL | Utente database |
