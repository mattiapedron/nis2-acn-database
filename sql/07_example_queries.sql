SET search_path TO nis2, public;

-- Q1. Elenco degli asset critici per azienda
SELECT
    codice_acn,
    ragione_sociale,
    codice_asset,
    asset,
    tipo_asset,
    livello_criticita,
    stato
FROM vw_asset_critici
WHERE azienda_id = 1
ORDER BY
    CASE livello_criticita
        WHEN 'CRITICA' THEN 1
        WHEN 'ALTA' THEN 2
        ELSE 3
    END,
    asset;

-- Q2. Servizi erogati e numero di asset collegati
SELECT
    s.codice,
    s.nome AS servizio,
    s.livello_criticita,
    s.rto_minuti,
    s.rpo_minuti,
    COUNT(ass.asset_id) AS numero_asset
FROM servizio s
LEFT JOIN asset_servizio ass
    ON ass.servizio_id = s.id
   AND ass.azienda_id = s.azienda_id
WHERE s.azienda_id = 1
  AND s.stato = 'ATTIVO'
GROUP BY
    s.id,
    s.codice,
    s.nome,
    s.livello_criticita,
    s.rto_minuti,
    s.rpo_minuti
ORDER BY s.nome;

-- Q3. Dipendenze da fornitori terzi
SELECT
    codice_fornitore,
    fornitore,
    tipo_dipendenza,
    livello_criticita,
    codice_asset,
    asset,
    codice_servizio,
    servizio,
    riferimento_contratto
FROM vw_dipendenze_terze_parti
WHERE azienda_id = 1
ORDER BY
    CASE livello_criticita
        WHEN 'CRITICA' THEN 1
        WHEN 'ALTA' THEN 2
        WHEN 'MEDIA' THEN 3
        ELSE 4
    END,
    fornitore;

-- Q4. Punti di contatto
SELECT
    ambito,
    principale,
    canale_preferito,
    nome,
    cognome,
    email,
    telefono
FROM vw_punti_contatto
WHERE azienda_id = 1
ORDER BY principale DESC, ambito;

-- Q5. Output completo del profilo ACN
SELECT
    codice_acn,
    ragione_sociale,
    settore,
    tipologia_soggetto,
    codice_servizio,
    servizio,
    criticita_servizio,
    rto_minuti,
    rpo_minuti,
    codice_asset,
    asset,
    tipo_asset,
    criticita_asset,
    ruolo_supporto,
    livello_dipendenza,
    fornitori_terzi,
    responsabili,
    punti_contatto,
    ultimo_aggiornamento
FROM fn_profilo_acn(1);
