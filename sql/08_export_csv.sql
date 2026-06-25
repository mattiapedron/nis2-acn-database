-- Script da eseguire con psql dalla cartella principale del repository.
-- Esempio:
-- psql -U postgres -d registro_nis2 -f sql/08_export_csv.sql
--
-- Il file viene creato nel percorso locale output/profilo_acn_azienda_1.csv.

\copy (SELECT codice_acn, ragione_sociale, settore, tipologia_soggetto, codice_servizio, servizio, criticita_servizio, rto_minuti, rpo_minuti, codice_asset, asset, tipo_asset, criticita_asset, ruolo_supporto, livello_dipendenza, fornitori_terzi, responsabili, punti_contatto, ultimo_aggiornamento FROM nis2.fn_profilo_acn(1)) TO 'output/profilo_acn_azienda_1.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', ENCODING 'UTF8', NULL '');
