BEGIN;

SET search_path TO nis2, public;

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM azienda;
    IF v_count <> 2 THEN
        RAISE EXCEPTION 'T01 fallito: aziende attese 2, trovate %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM sede;
    IF v_count <> 4 THEN
        RAISE EXCEPTION 'T02 fallito: sedi attese 4, trovate %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM asset;
    IF v_count <> 15 THEN
        RAISE EXCEPTION 'T03 fallito: asset attesi 15, trovati %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM servizio;
    IF v_count <> 8 THEN
        RAISE EXCEPTION 'T04 fallito: servizi attesi 8, trovati %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM asset_servizio;
    IF v_count <> 18 THEN
        RAISE EXCEPTION 'T05 fallito: relazioni asset-servizio attese 18, trovate %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM dipendenza_fornitore;
    IF v_count <> 10 THEN
        RAISE EXCEPTION 'T06 fallito: dipendenze attese 10, trovate %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM responsabilita;
    IF v_count <> 12 THEN
        RAISE EXCEPTION 'T07 fallito: responsabilità attese 12, trovate %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM punto_contatto;
    IF v_count <> 6 THEN
        RAISE EXCEPTION 'T08 fallito: punti di contatto attesi 6, trovati %', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM asset
    WHERE livello_criticita = 'CRITICA';

    IF v_count <> 5 THEN
        RAISE EXCEPTION 'T09 fallito: asset critici attesi 5, trovati %', v_count;
    END IF;

    RAISE NOTICE 'Test conteggi superati.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO asset (
            azienda_id,
            sede_id,
            tipo_asset_id,
            codice,
            nome,
            livello_criticita,
            data_inizio_validita
        )
        SELECT
            a.azienda_id,
            a.sede_id,
            a.tipo_asset_id,
            a.codice,
            'Asset duplicato',
            'ALTA',
            CURRENT_DATE
        FROM asset a
        WHERE a.codice = 'DB-ORD-01';

        RAISE EXCEPTION 'T10 fallito: il codice asset duplicato è stato accettato.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'T10 superato: duplicazione asset correttamente rifiutata.';
    END;
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO asset (
            azienda_id,
            sede_id,
            tipo_asset_id,
            codice,
            nome,
            livello_criticita,
            data_inizio_validita
        )
        SELECT
            a.id,
            s.id,
            ta.id,
            'ASSET-INVALIDO',
            'Asset con criticità non valida',
            'MOLTO_ALTA',
            CURRENT_DATE
        FROM azienda a
        JOIN sede s
            ON s.azienda_id = a.id
        JOIN tipo_asset ta
            ON ta.codice = 'SERVER'
        WHERE a.codice_acn = 'ACN-ORG-001'
        LIMIT 1;

        RAISE EXCEPTION 'T11 fallito: criticità non valida accettata.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'T11 superato: criticità non valida correttamente rifiutata.';
    END;
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO responsabilita (
            azienda_id,
            persona_id,
            ruolo_id,
            data_inizio,
            data_fine
        )
        SELECT
            p.azienda_id,
            p.id,
            r.id,
            DATE '2026-06-01',
            DATE '2026-05-01'
        FROM persona p
        CROSS JOIN ruolo r
        WHERE p.email = 'laura.bianchi@digitalservice.example'
          AND r.codice = 'NIS_MANAGER';

        RAISE EXCEPTION 'T12 fallito: periodo temporale non valido accettato.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'T12 superato: periodo non valido correttamente rifiutato.';
    END;
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO asset_servizio (
            azienda_id,
            asset_id,
            servizio_id,
            ruolo_supporto,
            livello_dipendenza
        )
        SELECT
            az1.id,
            a.id,
            s.id,
            'PRIMARIO',
            'ALTA'
        FROM azienda az1
        JOIN asset a
            ON a.azienda_id = az1.id
           AND a.codice = 'DB-ORD-01'
        CROSS JOIN servizio s
        JOIN azienda az2
            ON az2.id = s.azienda_id
        WHERE az1.codice_acn = 'ACN-ORG-001'
          AND az2.codice_acn = 'ACN-ORG-002'
          AND s.codice = 'SRV-WMS';

        RAISE EXCEPTION 'T13 fallito: collegamento tra aziende diverse accettato.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'T13 superato: collegamento cross-company correttamente rifiutato.';
    END;
END;
$$;

DO $$
DECLARE
    v_asset_id BIGINT;
    v_versione_prima INTEGER;
    v_versione_dopo INTEGER;
    v_audit_count INTEGER;
BEGIN
    SELECT id, versione
    INTO v_asset_id, v_versione_prima
    FROM asset
    WHERE codice = 'SW-MAIL-01';

    UPDATE asset
    SET livello_criticita = 'MEDIA'
    WHERE id = v_asset_id;

    SELECT versione
    INTO v_versione_dopo
    FROM asset
    WHERE id = v_asset_id;

    IF v_versione_dopo <> v_versione_prima + 1 THEN
        RAISE EXCEPTION
            'T14 fallito: versione attesa %, trovata %',
            v_versione_prima + 1,
            v_versione_dopo;
    END IF;

    SELECT COUNT(*)
    INTO v_audit_count
    FROM audit_log
    WHERE tabella = 'asset'
      AND record_id = v_asset_id
      AND operazione = 'U';

    IF v_audit_count < 1 THEN
        RAISE EXCEPTION 'T15 fallito: aggiornamento non presente nell audit log.';
    END IF;

    RAISE NOTICE 'T14-T15 superati: versioning e audit funzionanti.';
END;
$$;

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM fn_profilo_acn(1);

    IF v_count < 1 THEN
        RAISE EXCEPTION 'T16 fallito: la funzione profilo ACN non restituisce righe.';
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM vw_asset_critici
    WHERE azienda_id = 1;

    IF v_count < 1 THEN
        RAISE EXCEPTION 'T17 fallito: la view degli asset critici non restituisce righe.';
    END IF;

    RAISE NOTICE 'T16-T17 superati: viste e funzione ACN funzionanti.';
END;
$$;

ROLLBACK;

-- In assenza di eccezioni non gestite, tutti i test risultano superati.
