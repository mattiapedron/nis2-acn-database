BEGIN;

SET search_path TO nis2, public;

CREATE OR REPLACE VIEW vw_asset_critici AS
SELECT
    az.id AS azienda_id,
    az.codice_acn,
    az.ragione_sociale,
    a.id AS asset_id,
    a.codice AS codice_asset,
    a.nome AS asset,
    ta.codice AS tipo_asset,
    a.livello_criticita,
    a.stato,
    se.denominazione AS sede,
    a.versione,
    a.updated_at
FROM azienda az
JOIN asset a
    ON a.azienda_id = az.id
JOIN tipo_asset ta
    ON ta.id = a.tipo_asset_id
LEFT JOIN sede se
    ON se.id = a.sede_id
WHERE az.attiva = TRUE
  AND a.stato <> 'DISMESSO'
  AND a.livello_criticita IN ('ALTA', 'CRITICA');

CREATE OR REPLACE VIEW vw_servizi_asset AS
SELECT
    az.id AS azienda_id,
    az.codice_acn,
    az.ragione_sociale,
    s.id AS servizio_id,
    s.codice AS codice_servizio,
    s.nome AS servizio,
    s.livello_criticita AS criticita_servizio,
    s.rto_minuti,
    s.rpo_minuti,
    a.id AS asset_id,
    a.codice AS codice_asset,
    a.nome AS asset,
    ta.codice AS tipo_asset,
    a.livello_criticita AS criticita_asset,
    ass.ruolo_supporto,
    ass.livello_dipendenza
FROM azienda az
JOIN servizio s
    ON s.azienda_id = az.id
JOIN asset_servizio ass
    ON ass.servizio_id = s.id
   AND ass.azienda_id = az.id
JOIN asset a
    ON a.id = ass.asset_id
   AND a.azienda_id = az.id
JOIN tipo_asset ta
    ON ta.id = a.tipo_asset_id
WHERE az.attiva = TRUE
  AND s.stato = 'ATTIVO'
  AND a.stato <> 'DISMESSO';

CREATE OR REPLACE VIEW vw_dipendenze_terze_parti AS
SELECT
    az.id AS azienda_id,
    az.codice_acn,
    az.ragione_sociale,
    f.codice AS codice_fornitore,
    f.ragione_sociale AS fornitore,
    df.tipo_dipendenza,
    df.livello_criticita,
    a.codice AS codice_asset,
    a.nome AS asset,
    s.codice AS codice_servizio,
    s.nome AS servizio,
    df.riferimento_contratto,
    df.data_inizio,
    df.data_fine
FROM dipendenza_fornitore df
JOIN azienda az
    ON az.id = df.azienda_id
JOIN fornitore f
    ON f.id = df.fornitore_id
LEFT JOIN asset a
    ON a.id = df.asset_id
   AND a.azienda_id = df.azienda_id
LEFT JOIN servizio s
    ON s.id = df.servizio_id
   AND s.azienda_id = df.azienda_id
WHERE az.attiva = TRUE
  AND f.attivo = TRUE
  AND df.data_inizio <= CURRENT_DATE
  AND (
      df.data_fine IS NULL
      OR df.data_fine >= CURRENT_DATE
  );

CREATE OR REPLACE VIEW vw_punti_contatto AS
SELECT
    az.id AS azienda_id,
    az.codice_acn,
    az.ragione_sociale,
    pc.ambito,
    pc.principale,
    pc.canale_preferito,
    p.nome,
    p.cognome,
    p.email,
    p.telefono
FROM punto_contatto pc
JOIN azienda az
    ON az.id = pc.azienda_id
JOIN persona p
    ON p.id = pc.persona_id
   AND p.azienda_id = pc.azienda_id
WHERE az.attiva = TRUE
  AND p.attiva = TRUE;

CREATE OR REPLACE VIEW vw_profilo_acn AS
SELECT
    az.id AS azienda_id,
    az.codice_acn,
    az.ragione_sociale,
    az.settore,
    az.tipologia_soggetto,

    s.id AS servizio_id,
    s.codice AS codice_servizio,
    s.nome AS servizio,
    s.livello_criticita AS criticita_servizio,
    s.rto_minuti,
    s.rpo_minuti,

    a.id AS asset_id,
    a.codice AS codice_asset,
    a.nome AS asset,
    ta.codice AS tipo_asset,
    a.livello_criticita AS criticita_asset,
    ass.ruolo_supporto,
    ass.livello_dipendenza,

    dep.fornitori_terzi,
    resp.responsabili,
    cont.punti_contatto,

    GREATEST(
        s.updated_at,
        COALESCE(a.updated_at, s.updated_at)
    ) AS ultimo_aggiornamento
FROM azienda az
JOIN servizio s
    ON s.azienda_id = az.id
LEFT JOIN asset_servizio ass
    ON ass.azienda_id = az.id
   AND ass.servizio_id = s.id
LEFT JOIN asset a
    ON a.azienda_id = az.id
   AND a.id = ass.asset_id
LEFT JOIN tipo_asset ta
    ON ta.id = a.tipo_asset_id

LEFT JOIN LATERAL (
    SELECT
        STRING_AGG(
            DISTINCT f.ragione_sociale
            || ' ['
            || df.tipo_dipendenza
            || ']',
            '; '
            ORDER BY f.ragione_sociale
            || ' ['
            || df.tipo_dipendenza
            || ']'
        ) AS fornitori_terzi
    FROM dipendenza_fornitore df
    JOIN fornitore f
        ON f.id = df.fornitore_id
    WHERE df.azienda_id = az.id
      AND f.attivo = TRUE
      AND df.data_inizio <= CURRENT_DATE
      AND (
          df.data_fine IS NULL
          OR df.data_fine >= CURRENT_DATE
      )
      AND (
          df.servizio_id = s.id
          OR (
              a.id IS NOT NULL
              AND df.asset_id = a.id
          )
      )
) dep ON TRUE

LEFT JOIN LATERAL (
    SELECT
        STRING_AGG(
            DISTINCT p.nome
            || ' '
            || p.cognome
            || ' ('
            || r.codice
            || ')',
            '; '
            ORDER BY p.nome
            || ' '
            || p.cognome
            || ' ('
            || r.codice
            || ')'
        ) AS responsabili
    FROM responsabilita rs
    JOIN persona p
        ON p.id = rs.persona_id
       AND p.azienda_id = rs.azienda_id
    JOIN ruolo r
        ON r.id = rs.ruolo_id
    WHERE rs.azienda_id = az.id
      AND p.attiva = TRUE
      AND rs.data_inizio <= CURRENT_DATE
      AND (
          rs.data_fine IS NULL
          OR rs.data_fine >= CURRENT_DATE
      )
      AND (
          rs.servizio_id = s.id
          OR (
              a.id IS NOT NULL
              AND rs.asset_id = a.id
          )
          OR (
              rs.servizio_id IS NULL
              AND rs.asset_id IS NULL
          )
      )
) resp ON TRUE

LEFT JOIN LATERAL (
    SELECT
        STRING_AGG(
            DISTINCT pc.ambito
            || ': '
            || p.email,
            '; '
            ORDER BY pc.ambito
            || ': '
            || p.email
        ) AS punti_contatto
    FROM punto_contatto pc
    JOIN persona p
        ON p.id = pc.persona_id
       AND p.azienda_id = pc.azienda_id
    WHERE pc.azienda_id = az.id
      AND p.attiva = TRUE
) cont ON TRUE

WHERE az.attiva = TRUE
  AND s.stato = 'ATTIVO'
  AND (
      a.id IS NULL
      OR a.stato <> 'DISMESSO'
  );

CREATE OR REPLACE FUNCTION nis2.fn_profilo_acn(p_azienda_id BIGINT)
RETURNS SETOF nis2.vw_profilo_acn
LANGUAGE sql
STABLE
AS $$
    SELECT *
    FROM nis2.vw_profilo_acn
    WHERE azienda_id = p_azienda_id
    ORDER BY servizio, asset NULLS LAST;
$$;

COMMIT;
