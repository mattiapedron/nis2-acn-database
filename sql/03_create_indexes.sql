BEGIN;

SET search_path TO nis2, public;

CREATE INDEX idx_sede_azienda
    ON sede (azienda_id);

CREATE INDEX idx_asset_azienda_criticita
    ON asset (azienda_id, livello_criticita);

CREATE INDEX idx_asset_tipo
    ON asset (tipo_asset_id);

CREATE INDEX idx_asset_sede
    ON asset (sede_id);

CREATE INDEX idx_servizio_azienda_criticita
    ON servizio (azienda_id, livello_criticita);

CREATE INDEX idx_asset_servizio_servizio
    ON asset_servizio (servizio_id);

CREATE INDEX idx_df_azienda_fornitore
    ON dipendenza_fornitore (azienda_id, fornitore_id);

CREATE INDEX idx_df_asset
    ON dipendenza_fornitore (asset_id)
    WHERE asset_id IS NOT NULL;

CREATE INDEX idx_df_servizio
    ON dipendenza_fornitore (servizio_id)
    WHERE servizio_id IS NOT NULL;

CREATE INDEX idx_persona_azienda
    ON persona (azienda_id);

CREATE INDEX idx_resp_attive
    ON responsabilita (azienda_id, ruolo_id)
    WHERE data_fine IS NULL;

CREATE INDEX idx_resp_asset
    ON responsabilita (asset_id)
    WHERE asset_id IS NOT NULL;

CREATE INDEX idx_resp_servizio
    ON responsabilita (servizio_id)
    WHERE servizio_id IS NOT NULL;

CREATE INDEX idx_pc_azienda_ambito
    ON punto_contatto (azienda_id, ambito);

CREATE UNIQUE INDEX uq_pc_principale
    ON punto_contatto (azienda_id, ambito)
    WHERE principale = TRUE;

CREATE INDEX idx_audit_tabella_record
    ON audit_log (tabella, record_id, modificato_il DESC);

COMMIT;
