BEGIN;

SET search_path TO nis2, public;

CREATE OR REPLACE FUNCTION fn_touch_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION fn_incrementa_versione()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.versione := OLD.versione + 1;
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_record_id BIGINT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_record_id := NULLIF(to_jsonb(NEW)->>'id', '')::BIGINT;

        INSERT INTO nis2.audit_log (
            tabella,
            record_id,
            operazione,
            dati_successivi
        )
        VALUES (
            TG_TABLE_NAME,
            v_record_id,
            'I',
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        v_record_id := NULLIF(to_jsonb(NEW)->>'id', '')::BIGINT;

        INSERT INTO nis2.audit_log (
            tabella,
            record_id,
            operazione,
            dati_precedenti,
            dati_successivi
        )
        VALUES (
            TG_TABLE_NAME,
            v_record_id,
            'U',
            to_jsonb(OLD),
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSE
        v_record_id := NULLIF(to_jsonb(OLD)->>'id', '')::BIGINT;

        INSERT INTO nis2.audit_log (
            tabella,
            record_id,
            operazione,
            dati_precedenti
        )
        VALUES (
            TG_TABLE_NAME,
            v_record_id,
            'D',
            to_jsonb(OLD)
        );

        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER trg_azienda_touch
BEFORE UPDATE ON azienda
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_sede_touch
BEFORE UPDATE ON sede
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_fornitore_touch
BEFORE UPDATE ON fornitore
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_dipendenza_touch
BEFORE UPDATE ON dipendenza_fornitore
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_persona_touch
BEFORE UPDATE ON persona
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_responsabilita_touch
BEFORE UPDATE ON responsabilita
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_punto_contatto_touch
BEFORE UPDATE ON punto_contatto
FOR EACH ROW
EXECUTE FUNCTION fn_touch_updated_at();

CREATE TRIGGER trg_asset_versione
BEFORE UPDATE ON asset
FOR EACH ROW
EXECUTE FUNCTION fn_incrementa_versione();

CREATE TRIGGER trg_servizio_versione
BEFORE UPDATE ON servizio
FOR EACH ROW
EXECUTE FUNCTION fn_incrementa_versione();

CREATE TRIGGER trg_audit_asset
AFTER INSERT OR UPDATE OR DELETE ON asset
FOR EACH ROW
EXECUTE FUNCTION fn_audit_log();

CREATE TRIGGER trg_audit_servizio
AFTER INSERT OR UPDATE OR DELETE ON servizio
FOR EACH ROW
EXECUTE FUNCTION fn_audit_log();

CREATE TRIGGER trg_audit_dipendenza
AFTER INSERT OR UPDATE OR DELETE ON dipendenza_fornitore
FOR EACH ROW
EXECUTE FUNCTION fn_audit_log();

CREATE TRIGGER trg_audit_responsabilita
AFTER INSERT OR UPDATE OR DELETE ON responsabilita
FOR EACH ROW
EXECUTE FUNCTION fn_audit_log();

CREATE TRIGGER trg_audit_punto_contatto
AFTER INSERT OR UPDATE OR DELETE ON punto_contatto
FOR EACH ROW
EXECUTE FUNCTION fn_audit_log();

COMMIT;
