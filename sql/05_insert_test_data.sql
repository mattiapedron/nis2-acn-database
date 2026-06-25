BEGIN;

SET search_path TO nis2, public;

INSERT INTO azienda (
    codice_acn,
    ragione_sociale,
    partita_iva,
    settore,
    tipologia_soggetto,
    pec
)
VALUES
    (
        'ACN-ORG-001',
        'Digital Service S.p.A.',
        'IT00000000001',
        'Servizi digitali',
        'ESSENZIALE',
        'digitalservice@pec.example'
    ),
    (
        'ACN-ORG-002',
        'Logistic Network S.r.l.',
        'IT00000000002',
        'Trasporti e logistica',
        'IMPORTANTE',
        'logisticnetwork@pec.example'
    );

INSERT INTO sede (
    azienda_id,
    codice,
    denominazione,
    tipo_sede,
    indirizzo,
    comune,
    provincia
)
SELECT
    a.id,
    v.codice,
    v.denominazione,
    v.tipo_sede,
    v.indirizzo,
    v.comune,
    v.provincia
FROM (
    VALUES
        ('ACN-ORG-001', 'DS-MI', 'Sede legale Milano', 'LEGALE', 'Via Esempio 10', 'Milano', 'MI'),
        ('ACN-ORG-001', 'DS-DC', 'Data center Milano', 'DATACENTER', 'Via Tecnologica 25', 'Milano', 'MI'),
        ('ACN-ORG-002', 'LN-BO', 'Sede legale Bologna', 'LEGALE', 'Via Logistica 8', 'Bologna', 'BO'),
        ('ACN-ORG-002', 'LN-HUB', 'Hub operativo', 'OPERATIVA', 'Via Interporto 42', 'Bologna', 'BO')
) AS v(codice_acn, codice, denominazione, tipo_sede, indirizzo, comune, provincia)
JOIN azienda a
    ON a.codice_acn = v.codice_acn;

INSERT INTO tipo_asset (codice, descrizione)
VALUES
    ('SERVER', 'Server fisico o virtuale'),
    ('DATABASE', 'Database aziendale'),
    ('APPLICATION', 'Applicazione aziendale'),
    ('NETWORK', 'Dispositivo o infrastruttura di rete'),
    ('CLOUD', 'Servizio o infrastruttura cloud'),
    ('BACKUP', 'Sistema di backup e ripristino');

INSERT INTO asset (
    azienda_id,
    sede_id,
    tipo_asset_id,
    codice,
    nome,
    descrizione,
    livello_criticita,
    stato,
    data_inizio_validita
)
SELECT
    az.id,
    se.id,
    ta.id,
    v.codice_asset,
    v.nome_asset,
    v.descrizione,
    v.criticita,
    'ATTIVO',
    DATE '2025-01-01'
FROM (
    VALUES
        ('ACN-ORG-001', 'DS-DC', 'DATABASE',    'DB-ORD-01',   'Database gestione ordini',        'Database principale degli ordini',                'CRITICA'),
        ('ACN-ORG-001', 'DS-DC', 'SERVER',      'SRV-APP-01',  'Server applicativo principale',   'Nodo primario del servizio ordini',               'CRITICA'),
        ('ACN-ORG-001', 'DS-DC', 'SERVER',      'SRV-APP-02',  'Server applicativo secondario',   'Nodo secondario del servizio ordini',             'ALTA'),
        ('ACN-ORG-001', 'DS-DC', 'NETWORK',     'FW-01',       'Firewall perimetrale',             'Protezione degli accessi esterni',                 'ALTA'),
        ('ACN-ORG-001', 'DS-MI', 'CLOUD',       'CLD-CRM-01',  'Piattaforma CRM cloud',            'Servizio CRM erogato in cloud',                    'MEDIA'),
        ('ACN-ORG-001', 'DS-DC', 'BACKUP',      'BCK-01',      'Sistema di backup centrale',       'Backup di database e applicazioni',                'CRITICA'),
        ('ACN-ORG-001', 'DS-DC', 'APPLICATION', 'APP-PORT-01', 'Portale clienti',                  'Applicazione web per i clienti',                   'ALTA'),
        ('ACN-ORG-001', 'DS-DC', 'DATABASE',    'DB-CRM-01',   'Database CRM locale',              'Replica locale dei dati CRM',                     'MEDIA'),
        ('ACN-ORG-001', 'DS-MI', 'APPLICATION', 'SW-MAIL-01',  'Piattaforma di posta elettronica', 'Servizio di posta e collaborazione',               'BASSA'),

        ('ACN-ORG-002', 'LN-HUB', 'SERVER',      'SRV-WMS-01',   'Server WMS',                       'Server del sistema di gestione magazzino',        'CRITICA'),
        ('ACN-ORG-002', 'LN-HUB', 'APPLICATION', 'APP-WMS-01',   'Applicazione WMS',                 'Software di gestione del magazzino',              'CRITICA'),
        ('ACN-ORG-002', 'LN-HUB', 'NETWORK',     'NET-HUB-01',   'Rete hub logistico',               'Infrastruttura di rete dell hub',                  'ALTA'),
        ('ACN-ORG-002', 'LN-BO',  'CLOUD',       'CLD-TRACK-01', 'Piattaforma tracking cloud',       'Servizio cloud per il tracciamento spedizioni',   'MEDIA'),
        ('ACN-ORG-002', 'LN-HUB', 'BACKUP',      'BCK-WMS-01',   'Backup WMS',                       'Sistema di backup del WMS',                       'MEDIA'),
        ('ACN-ORG-002', 'LN-HUB', 'SERVER',      'SRV-EDI-01',   'Server EDI',                       'Scambio dati elettronico con i partner',          'BASSA')
) AS v(
    codice_acn,
    codice_sede,
    codice_tipo,
    codice_asset,
    nome_asset,
    descrizione,
    criticita
)
JOIN azienda az
    ON az.codice_acn = v.codice_acn
JOIN sede se
    ON se.azienda_id = az.id
   AND se.codice = v.codice_sede
JOIN tipo_asset ta
    ON ta.codice = v.codice_tipo;

INSERT INTO servizio (
    azienda_id,
    codice,
    nome,
    descrizione,
    livello_criticita,
    rto_minuti,
    rpo_minuti,
    stato
)
SELECT
    az.id,
    v.codice_servizio,
    v.nome_servizio,
    v.descrizione,
    v.criticita,
    v.rto,
    v.rpo,
    'ATTIVO'
FROM (
    VALUES
        ('ACN-ORG-001', 'SRV-ORD',    'Gestione ordini',       'Acquisizione ed elaborazione degli ordini',             'CRITICA', 120, 30),
        ('ACN-ORG-001', 'SRV-PORT',   'Portale clienti',       'Accesso dei clienti ai servizi digitali',                'ALTA',    240, 60),
        ('ACN-ORG-001', 'SRV-CRM',    'Gestione CRM',          'Gestione delle relazioni con i clienti',                 'MEDIA',   480, 120),
        ('ACN-ORG-001', 'SRV-MAIL',   'Posta elettronica',     'Comunicazione e collaborazione aziendale',               'MEDIA',   480, 120),
        ('ACN-ORG-001', 'SRV-BACKUP', 'Continuità e backup',   'Backup e ripristino dei dati critici',                   'CRITICA', 240, 30),

        ('ACN-ORG-002', 'SRV-WMS',    'Gestione magazzino',    'Gestione operativa del magazzino',                       'CRITICA', 120, 15),
        ('ACN-ORG-002', 'SRV-TRACK',  'Tracking spedizioni',   'Tracciamento dello stato delle spedizioni',              'ALTA',    240, 60),
        ('ACN-ORG-002', 'SRV-EDI',    'Scambio dati EDI',      'Scambio di documenti elettronici con clienti e partner', 'MEDIA',   480, 120)
) AS v(
    codice_acn,
    codice_servizio,
    nome_servizio,
    descrizione,
    criticita,
    rto,
    rpo
)
JOIN azienda az
    ON az.codice_acn = v.codice_acn;

INSERT INTO asset_servizio (
    azienda_id,
    asset_id,
    servizio_id,
    ruolo_supporto,
    livello_dipendenza,
    note
)
SELECT
    az.id,
    a.id,
    s.id,
    v.ruolo_supporto,
    v.livello_dipendenza,
    v.note
FROM (
    VALUES
        ('ACN-ORG-001', 'DB-ORD-01',   'SRV-ORD',    'PRIMARIO',   'CRITICA', 'Archivio principale degli ordini'),
        ('ACN-ORG-001', 'SRV-APP-01',  'SRV-ORD',    'PRIMARIO',   'CRITICA', 'Nodo applicativo principale'),
        ('ACN-ORG-001', 'SRV-APP-02',  'SRV-ORD',    'BACKUP',     'ALTA',    'Nodo applicativo di riserva'),
        ('ACN-ORG-001', 'APP-PORT-01', 'SRV-PORT',   'PRIMARIO',   'ALTA',    'Applicazione front-end'),
        ('ACN-ORG-001', 'FW-01',       'SRV-PORT',   'PRIMARIO',   'ALTA',    'Protezione del traffico esterno'),
        ('ACN-ORG-001', 'CLD-CRM-01',  'SRV-CRM',    'PRIMARIO',   'ALTA',    'Piattaforma CRM'),
        ('ACN-ORG-001', 'DB-CRM-01',   'SRV-CRM',    'SECONDARIO', 'MEDIA',   'Replica locale'),
        ('ACN-ORG-001', 'SW-MAIL-01',  'SRV-MAIL',   'PRIMARIO',   'MEDIA',   'Applicazione di posta'),
        ('ACN-ORG-001', 'FW-01',       'SRV-MAIL',   'SECONDARIO', 'MEDIA',   'Protezione accessi'),
        ('ACN-ORG-001', 'BCK-01',      'SRV-BACKUP', 'PRIMARIO',   'CRITICA', 'Sistema di backup'),
        ('ACN-ORG-001', 'DB-ORD-01',   'SRV-BACKUP', 'SECONDARIO', 'CRITICA', 'Dati sottoposti a backup'),

        ('ACN-ORG-002', 'SRV-WMS-01',   'SRV-WMS',   'PRIMARIO',   'CRITICA', 'Server applicativo'),
        ('ACN-ORG-002', 'APP-WMS-01',   'SRV-WMS',   'PRIMARIO',   'CRITICA', 'Applicazione WMS'),
        ('ACN-ORG-002', 'BCK-WMS-01',   'SRV-WMS',   'BACKUP',     'ALTA',    'Backup del WMS'),
        ('ACN-ORG-002', 'CLD-TRACK-01', 'SRV-TRACK', 'PRIMARIO',   'ALTA',    'Piattaforma di tracking'),
        ('ACN-ORG-002', 'NET-HUB-01',   'SRV-TRACK', 'SECONDARIO', 'ALTA',    'Connettività dell hub'),
        ('ACN-ORG-002', 'SRV-EDI-01',   'SRV-EDI',   'PRIMARIO',   'MEDIA',   'Server EDI'),
        ('ACN-ORG-002', 'NET-HUB-01',   'SRV-EDI',   'SECONDARIO', 'MEDIA',   'Connettività EDI')
) AS v(
    codice_acn,
    codice_asset,
    codice_servizio,
    ruolo_supporto,
    livello_dipendenza,
    note
)
JOIN azienda az
    ON az.codice_acn = v.codice_acn
JOIN asset a
    ON a.azienda_id = az.id
   AND a.codice = v.codice_asset
JOIN servizio s
    ON s.azienda_id = az.id
   AND s.codice = v.codice_servizio;

INSERT INTO fornitore (
    codice,
    ragione_sociale,
    identificativo_fiscale,
    paese,
    email,
    telefono
)
VALUES
    ('FOR-CLOUD',  'CloudSphere Europe S.r.l.', 'IT90000000001', 'IT', 'support@cloudsphere.example', '+39 02 0000001'),
    ('FOR-TELCO',  'NetWave Telecom S.p.A.',     'IT90000000002', 'IT', 'noc@netwave.example',         '+39 02 0000002'),
    ('FOR-SOFT',   'SecureSoft Italia S.r.l.',   'IT90000000003', 'IT', 'support@securesoft.example',   '+39 02 0000003'),
    ('FOR-BACKUP', 'DataSafe Backup S.p.A.',     'IT90000000004', 'IT', 'support@datasafe.example',     '+39 02 0000004'),
    ('FOR-MAINT',  'TechCare Services S.r.l.',   'IT90000000005', 'IT', 'service@techcare.example',     '+39 02 0000005');

INSERT INTO dipendenza_fornitore (
    azienda_id,
    fornitore_id,
    asset_id,
    servizio_id,
    tipo_dipendenza,
    livello_criticita,
    riferimento_contratto,
    data_inizio,
    note
)
SELECT
    az.id,
    f.id,
    a.id,
    s.id,
    v.tipo_dipendenza,
    v.criticita,
    v.contratto,
    DATE '2025-01-01',
    v.note
FROM (
    VALUES
        ('ACN-ORG-001', 'FOR-CLOUD',  'CLD-CRM-01',  'SRV-CRM',    'CLOUD',             'ALTA',    'CTR-DS-001', 'Erogazione piattaforma CRM'),
        ('ACN-ORG-001', 'FOR-TELCO',  'FW-01',       'SRV-PORT',   'TELECOMUNICAZIONI', 'ALTA',    'CTR-DS-002', 'Connettività internet primaria'),
        ('ACN-ORG-001', 'FOR-SOFT',   'APP-PORT-01', 'SRV-PORT',   'SOFTWARE',          'ALTA',    'CTR-DS-003', 'Manutenzione applicativa del portale'),
        ('ACN-ORG-001', 'FOR-BACKUP', 'BCK-01',      'SRV-BACKUP', 'BACKUP',            'CRITICA', 'CTR-DS-004', 'Conservazione copie di sicurezza'),
        ('ACN-ORG-001', 'FOR-MAINT',  'SRV-APP-01',  NULL,         'MANUTENZIONE',      'MEDIA',   'CTR-DS-005', 'Assistenza hardware'),

        ('ACN-ORG-002', 'FOR-CLOUD',  'CLD-TRACK-01', 'SRV-TRACK', 'CLOUD',             'ALTA',    'CTR-LN-001', 'Piattaforma tracking'),
        ('ACN-ORG-002', 'FOR-TELCO',  'NET-HUB-01',   'SRV-TRACK', 'TELECOMUNICAZIONI', 'ALTA',    'CTR-LN-002', 'Connettività hub logistico'),
        ('ACN-ORG-002', 'FOR-SOFT',   'APP-WMS-01',   'SRV-WMS',   'SOFTWARE',          'CRITICA', 'CTR-LN-003', 'Licenza e manutenzione WMS'),
        ('ACN-ORG-002', 'FOR-BACKUP', 'BCK-WMS-01',   'SRV-WMS',   'BACKUP',            'ALTA',    'CTR-LN-004', 'Backup del sistema WMS'),
        ('ACN-ORG-002', 'FOR-MAINT',  'SRV-EDI-01',   'SRV-EDI',   'MANUTENZIONE',      'MEDIA',   'CTR-LN-005', 'Assistenza tecnica EDI')
) AS v(
    codice_acn,
    codice_fornitore,
    codice_asset,
    codice_servizio,
    tipo_dipendenza,
    criticita,
    contratto,
    note
)
JOIN azienda az
    ON az.codice_acn = v.codice_acn
JOIN fornitore f
    ON f.codice = v.codice_fornitore
LEFT JOIN asset a
    ON a.azienda_id = az.id
   AND a.codice = v.codice_asset
LEFT JOIN servizio s
    ON s.azienda_id = az.id
   AND s.codice = v.codice_servizio;

INSERT INTO persona (
    azienda_id,
    nome,
    cognome,
    email,
    telefono
)
SELECT
    az.id,
    v.nome,
    v.cognome,
    v.email,
    v.telefono
FROM (
    VALUES
        ('ACN-ORG-001', 'Laura',   'Bianchi', 'laura.bianchi@digitalservice.example',   '+39 02 1000001'),
        ('ACN-ORG-001', 'Marco',   'Rossi',   'marco.rossi@digitalservice.example',     '+39 02 1000002'),
        ('ACN-ORG-001', 'Giulia',  'Verdi',   'giulia.verdi@digitalservice.example',   '+39 02 1000003'),
        ('ACN-ORG-001', 'Andrea',  'Neri',    'andrea.neri@digitalservice.example',    '+39 02 1000004'),

        ('ACN-ORG-002', 'Elena',   'Romano',  'elena.romano@logisticnetwork.example',  '+39 051 2000001'),
        ('ACN-ORG-002', 'Davide',  'Conti',   'davide.conti@logisticnetwork.example',  '+39 051 2000002'),
        ('ACN-ORG-002', 'Sara',    'Gallo',   'sara.gallo@logisticnetwork.example',    '+39 051 2000003'),
        ('ACN-ORG-002', 'Matteo',  'Ferrari', 'matteo.ferrari@logisticnetwork.example','+39 051 2000004')
) AS v(codice_acn, nome, cognome, email, telefono)
JOIN azienda az
    ON az.codice_acn = v.codice_acn;

INSERT INTO ruolo (codice, descrizione)
VALUES
    ('NIS_MANAGER',       'Responsabile del coordinamento NIS2'),
    ('ASSET_OWNER',       'Proprietario o responsabile di un asset'),
    ('SERVICE_OWNER',     'Responsabile di un servizio'),
    ('SECURITY_MANAGER',  'Responsabile della sicurezza informatica'),
    ('TECHNICAL_CONTACT', 'Referente tecnico'),
    ('INCIDENT_MANAGER',  'Responsabile della gestione degli incidenti');

INSERT INTO responsabilita (
    azienda_id,
    persona_id,
    ruolo_id,
    asset_id,
    servizio_id,
    principale,
    data_inizio,
    note
)
SELECT
    az.id,
    p.id,
    r.id,
    a.id,
    s.id,
    v.principale,
    DATE '2025-01-01',
    v.note
FROM (
    VALUES
        ('ACN-ORG-001', 'laura.bianchi@digitalservice.example',  'NIS_MANAGER',       NULL,         NULL,         TRUE,  'Responsabilità generale NIS2'),
        ('ACN-ORG-001', 'marco.rossi@digitalservice.example',    'SECURITY_MANAGER',  NULL,         NULL,         TRUE,  'Coordinamento della sicurezza'),
        ('ACN-ORG-001', 'giulia.verdi@digitalservice.example',   'SERVICE_OWNER',     NULL,         'SRV-ORD',    TRUE,  'Responsabile gestione ordini'),
        ('ACN-ORG-001', 'andrea.neri@digitalservice.example',    'ASSET_OWNER',       'DB-ORD-01',  NULL,         TRUE,  'Responsabile database ordini'),
        ('ACN-ORG-001', 'andrea.neri@digitalservice.example',    'TECHNICAL_CONTACT', 'SRV-APP-01', NULL,         TRUE,  'Referente tecnico server'),
        ('ACN-ORG-001', 'marco.rossi@digitalservice.example',    'INCIDENT_MANAGER',  NULL,         'SRV-PORT',   TRUE,  'Gestione incidenti portale'),

        ('ACN-ORG-002', 'elena.romano@logisticnetwork.example',  'NIS_MANAGER',       NULL,          NULL,        TRUE,  'Responsabilità generale NIS2'),
        ('ACN-ORG-002', 'davide.conti@logisticnetwork.example',  'SECURITY_MANAGER',  NULL,          NULL,        TRUE,  'Coordinamento della sicurezza'),
        ('ACN-ORG-002', 'sara.gallo@logisticnetwork.example',    'SERVICE_OWNER',     NULL,          'SRV-WMS',   TRUE,  'Responsabile servizio WMS'),
        ('ACN-ORG-002', 'matteo.ferrari@logisticnetwork.example','ASSET_OWNER',       'APP-WMS-01',  NULL,        TRUE,  'Responsabile applicazione WMS'),
        ('ACN-ORG-002', 'matteo.ferrari@logisticnetwork.example','TECHNICAL_CONTACT', 'NET-HUB-01',  NULL,        TRUE,  'Referente tecnico rete'),
        ('ACN-ORG-002', 'davide.conti@logisticnetwork.example',  'INCIDENT_MANAGER',  NULL,          'SRV-TRACK', TRUE,  'Gestione incidenti tracking')
) AS v(
    codice_acn,
    email_persona,
    codice_ruolo,
    codice_asset,
    codice_servizio,
    principale,
    note
)
JOIN azienda az
    ON az.codice_acn = v.codice_acn
JOIN persona p
    ON p.azienda_id = az.id
   AND p.email = v.email_persona
JOIN ruolo r
    ON r.codice = v.codice_ruolo
LEFT JOIN asset a
    ON a.azienda_id = az.id
   AND a.codice = v.codice_asset
LEFT JOIN servizio s
    ON s.azienda_id = az.id
   AND s.codice = v.codice_servizio;

INSERT INTO punto_contatto (
    azienda_id,
    persona_id,
    ambito,
    principale,
    canale_preferito,
    note
)
SELECT
    az.id,
    p.id,
    v.ambito,
    v.principale,
    v.canale,
    v.note
FROM (
    VALUES
        ('ACN-ORG-001', 'laura.bianchi@digitalservice.example', 'NIS2',              TRUE,  'PEC',      'Punto di contatto principale NIS2'),
        ('ACN-ORG-001', 'marco.rossi@digitalservice.example',   'INCIDENT_RESPONSE', TRUE,  'TELEFONO', 'Contatto per incidenti di sicurezza'),
        ('ACN-ORG-001', 'andrea.neri@digitalservice.example',   'TECNICO',           TRUE,  'EMAIL',    'Referente tecnico'),

        ('ACN-ORG-002', 'elena.romano@logisticnetwork.example', 'NIS2',              TRUE,  'PEC',      'Punto di contatto principale NIS2'),
        ('ACN-ORG-002', 'davide.conti@logisticnetwork.example', 'INCIDENT_RESPONSE', TRUE,  'TELEFONO', 'Contatto per incidenti di sicurezza'),
        ('ACN-ORG-002', 'matteo.ferrari@logisticnetwork.example','TECNICO',          TRUE,  'EMAIL',    'Referente tecnico')
) AS v(
    codice_acn,
    email_persona,
    ambito,
    principale,
    canale,
    note
)
JOIN azienda az
    ON az.codice_acn = v.codice_acn
JOIN persona p
    ON p.azienda_id = az.id
   AND p.email = v.email_persona;

COMMIT;
