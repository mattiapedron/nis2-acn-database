# Database relazionale per i profili ACN nell'ambito NIS2

Repository del project work dedicato alla progettazione e implementazione di una base dati PostgreSQL per catalogare:

- aziende e sedi;
- asset tecnologici;
- servizi erogati;
- relazioni tra asset e servizi;
- fornitori e dipendenze da terze parti;
- persone, ruoli e responsabilità;
- punti di contatto;
- versioning e storico delle modifiche;
- output CSV utile alla predisposizione dei profili ACN.

## Requisiti

- PostgreSQL 15 o versione successiva
- PostgreSQL Query Tool di pgAdmin 4 per gli script SQL puri
- client `psql` per lo script di esportazione CSV
- codifica UTF-8
- privilegi per creare schema, tabelle, viste, funzioni e trigger

Non sono richieste estensioni PostgreSQL aggiuntive.

Nota (Windows)
Per utilizzare da riga di comando gli strumenti PostgreSQL (psql, createdb, dropdb, ecc.), è consigliabile aggiungere la cartella bin dell'installazione di PostgreSQL alla variabile di ambiente PATH (ad esempio C:\Program Files\PostgreSQL\<versione>\bin). Dopo la modifica è necessario riaprire il terminale affinché la nuova configurazione venga applicata.

## Struttura del repository

```text
nis2-acn-database/
├── README.md
├── .gitignore
├── sql/
│   ├── 00_reset_schema.sql
│   ├── 01_create_schema.sql
│   ├── 02_create_tables.sql
│   ├── 03_create_indexes.sql
│   ├── 04_create_functions_triggers.sql
│   ├── 05_insert_test_data.sql
│   ├── 06_create_views_functions.sql
│   ├── 07_example_queries.sql
│   ├── 08_export_csv.sql
│   └── 09_test_database.sql
├── docs/
│   ├── data_dictionary.md
│   ├── deployment.md
│   ├── diagramma_er_nis2_acn.png
│   └── diagramma_er_nis2_acn.svg
└── output/
    └── .gitkeep
```

## Creazione del database

Esempio da terminale:

```bash
createdb -U postgres registro_nis2
```

In alternativa:

```bash
psql -U postgres -d postgres -c "CREATE DATABASE registro_nis2 WITH ENCODING 'UTF8';"
```

## Deployment

Eseguire gli script nell'ordine indicato:

```bash
psql -U postgres -d registro_nis2 -f sql/01_create_schema.sql
psql -U postgres -d registro_nis2 -f sql/02_create_tables.sql
psql -U postgres -d registro_nis2 -f sql/03_create_indexes.sql
psql -U postgres -d registro_nis2 -f sql/04_create_functions_triggers.sql
psql -U postgres -d registro_nis2 -f sql/05_insert_test_data.sql
psql -U postgres -d registro_nis2 -f sql/06_create_views_functions.sql
```

Per eseguire le query dimostrative:

```bash
psql -U postgres -d registro_nis2 -f sql/07_example_queries.sql
```

Per generare il file CSV:

```bash
psql -U postgres -d registro_nis2 -f sql/08_export_csv.sql
```

Per eseguire i test:

```bash
psql -U postgres -d registro_nis2 -f sql/09_test_database.sql
```

## Ripristino dello schema

Lo script seguente elimina completamente lo schema `nis2` e tutti gli oggetti contenuti:

```bash
psql -U postgres -d registro_nis2 -f sql/00_reset_schema.sql
```

Usarlo solo in ambiente di test.

## Dataset simulato

Il dataset contiene esclusivamente dati inventati:

- 2 aziende;
- 4 sedi;
- 6 tipologie di asset;
- 15 asset;
- 8 servizi;
- 18 relazioni asset-servizio;
- 5 fornitori;
- 10 dipendenze da terze parti;
- 8 persone;
- 6 ruoli;
- 12 responsabilità;
- 6 punti di contatto.

La distribuzione degli asset per criticità è:

- 5 critici;
- 4 alti;
- 4 medi;
- 2 bassi.

## Output CSV

Lo script `08_export_csv.sql`, da eseguire con `psql`, esporta il profilo dell'azienda con `id = 1` nel file:

```text
output/profilo_acn_azienda_1.csv
```

Il comando utilizza `\copy`, quindi il file viene creato sul computer dal quale viene eseguito `psql`.

## Note progettuali

Lo schema è normalizzato fino alla terza forma normale. Le relazioni molti-a-molti sono gestite mediante tabelle associative. I vincoli composti impediscono di collegare asset, servizi o persone appartenenti ad aziende differenti.

Il versioning di asset e servizi è gestito mediante trigger. Le modifiche alle entità principali vengono registrate nella tabella `audit_log` in formato JSONB.
