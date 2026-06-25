# Istruzioni di deployment

## 1. Preparazione

Installare PostgreSQL e verificare che il comando `psql` sia disponibile.

```bash
psql --version
```

## 2. Creazione database

```bash
createdb -U postgres registro_nis2
```

## 3. Installazione dello schema

Dalla cartella principale del repository:

```bash
psql -U postgres -d registro_nis2 -f sql/01_create_schema.sql
psql -U postgres -d registro_nis2 -f sql/02_create_tables.sql
psql -U postgres -d registro_nis2 -f sql/03_create_indexes.sql
psql -U postgres -d registro_nis2 -f sql/04_create_functions_triggers.sql
psql -U postgres -d registro_nis2 -f sql/05_insert_test_data.sql
psql -U postgres -d registro_nis2 -f sql/06_create_views_functions.sql
```

## 4. Verifica

```bash
psql -U postgres -d registro_nis2 -f sql/09_test_database.sql
```

Lo script di test utilizza una transazione e termina con `ROLLBACK`, quindi non altera il dataset.

## 5. Generazione CSV

```bash
psql -U postgres -d registro_nis2 -f sql/08_export_csv.sql
```

Il file viene scritto nella cartella `output`.

## 6. Aggiornamenti futuri

Per modifiche successive si consiglia di aggiungere nuovi script numerati, ad esempio:

```text
10_add_new_field.sql
11_update_view_acn.sql
```

Gli script già pubblicati non dovrebbero essere modificati dopo il rilascio, così da mantenere una cronologia riproducibile delle migrazioni.
