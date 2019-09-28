CREATE OR REPLACE PACKAGE BODY pkg_tpac_cpro
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_content_put (
        p_pme_pmvid                             IN VARCHAR2,
        p_pme_json                              IN VARCHAR2)
    IS
        pmv_count                               NUMBER;
        json_minus_table_count                  NUMBER;
        table_minus_json_count                  NUMBER;

        CURSOR content_cur (contents_in IN VARCHAR2)
        IS
            SELECT *
            FROM   JSON_TABLE (
                       contents_in,
                       '$[*]'
                       COLUMNS (
                           acu PATH '$.ACU',
                           br PATH '$.BR',
                           dsc PATH '$.DSC',
                           spo PATH '$.SPO',
                           chk PATH '$.CHK',
                           rev PATH '$.REV',
                           rem PATH '$.REM',
                           spr PATH '$.SPR'));
    BEGIN
        SELECT COUNT (*)
        INTO   pmv_count
        FROM   prmodelver
        WHERE  pmv_id = p_pme_pmvid;

        IF pmv_count = 1
        THEN --checking if the pmv_id exists if not integrity constraint error occurs
            SELECT COUNT (*)
            INTO   json_minus_table_count
            FROM   (SELECT acu,
                           br,
                           dsc,
                           spo,
                           chk,
                           rev,
                           rem,
                           spr
                    FROM   JSON_TABLE (
                               p_pme_json,
                               '$[*]'
                               COLUMNS (
                                   acu NUMBER PATH '$.ACU',
                                   br NUMBER PATH '$.BR',
                                   dsc PATH '$.DSC',
                                   spo NUMBER PATH '$.SPO',
                                   chk PATH '$.CHK',
                                   rev PATH '$.REV',
                                   rem PATH '$.REM',
                                   spr NUMBER PATH '$.SPR'))
                    MINUS
                    SELECT pme_amountcu,
                           pme_billrate,
                           pme_ratedesc,
                           pme_amountpv,
                           DECODE (pme_kw_check,  0, 'false',  1, 'true',  'false'),
                           DECODE (pme_kw_review,  0, 'false',  1, 'true',  'false'),
                           pme_comment,
                           pme_amountpv_pp
                    FROM   prmodelentry
                    WHERE  pme_pmvid = p_pme_pmvid);

            SELECT COUNT (*)
            INTO   table_minus_json_count
            FROM   (SELECT pme_amountcu,
                           pme_billrate,
                           pme_ratedesc,
                           pme_amountpv,
                           DECODE (pme_kw_check,  0, 'false',  1, 'true',  'false'),
                           DECODE (pme_kw_review,  0, 'false',  1, 'true',  'false'),
                           pme_comment,
                           pme_amountpv_pp
                    FROM   prmodelentry
                    WHERE  pme_pmvid = p_pme_pmvid
                    MINUS
                    SELECT acu,
                           br,
                           dsc,
                           spo,
                           chk,
                           rev,
                           rem,
                           spr
                    FROM   JSON_TABLE (
                               p_pme_json,
                               '$[*]'
                               COLUMNS (
                                   acu NUMBER PATH '$.ACU',
                                   br NUMBER PATH '$.BR',
                                   dsc PATH '$.DSC',
                                   spo NUMBER PATH '$.SPO',
                                   chk PATH '$.CHK',
                                   rev PATH '$.REV',
                                   rem PATH '$.REM',
                                   spr NUMBER PATH '$.SPR')));

            IF    json_minus_table_count <> 0
               OR table_minus_json_count <> 0
            THEN
                DELETE FROM prmodelentry
                WHERE       pme_pmvid = p_pme_pmvid;

                FOR cur IN content_cur (p_pme_json)
                LOOP
                    INSERT INTO prmodelentry (
                                    pme_id,
                                    pme_pmvid,
                                    pme_billrate,
                                    pme_amountcu,
                                    pme_ratedesc,
                                    pme_amountpv,
                                    pme_amountmo,
                                    pme_amountpv_pp,
                                    pme_amountmo_pp,
                                    pme_comment,
                                    pme_kw_check,
                                    pme_kw_review)
                    VALUES      (
                                    pkg_common.generateuniquekey ('G'),
                                    p_pme_pmvid,
                                    cur.br,
                                    cur.acu,
                                    NVL (cur.dsc, 'undefined rate'),
                                    cur.spo,
                                    cur.acu - cur.spo,
                                    cur.spr,
                                    cur.acu - cur.spr,
                                    cur.rem,
                                    DECODE (cur.chk,  'false', 0,  'true', 1,  0),
                                    DECODE (cur.rev,  'false', 0,  'true', 1,  0));
                END LOOP;
            END IF;
        END IF;
    END gpsh_price_content_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_model_put (
        p_pm_id                                 IN VARCHAR2,
        p_pm_json                               IN VARCHAR2)
    IS
        name                                    VARCHAR2 (50);
        comment                                 VARCHAR2 (4000);
        t_pm_id                                 VARCHAR2 (20);
    BEGIN
        SELECT pm_name,
               pm_comment
        INTO   name,
               comment
        FROM   JSON_TABLE (
                   p_pm_json,
                   '$'
                   COLUMNS (
                       pm_name PATH '$.NAME',
                       pm_comment PATH '$.COMMENT'));

        SELECT pm_id
        INTO   t_pm_id
        FROM   prmodel RIGHT JOIN DUAL ON pm_id = p_pm_id;

        IF t_pm_id IS NULL
        THEN
            INSERT INTO prmodel (
                            pm_id,
                            pm_pmsid,
                            pm_name,
                            pm_srctype,
                            pm_comment,
                            pm_datecre)
            VALUES      (
                            p_pm_id,
                            'A',
                            name,
                            'MBS',
                            comment,
                            SYSDATE);
        ELSE
            UPDATE prmodel
            SET    pm_pmsid = 'A',
                   pm_name = name,
                   pm_comment = comment,
                   pm_datemod = SYSDATE
            WHERE  pm_id = p_pm_id;
        END IF;
    END gpsh_price_model_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_transport_put (
        p_pmvt_pmvid                            IN VARCHAR2,
        p_pmvt_json                             IN VARCHAR2)
    IS
        pm_trans_count                          NUMBER;
        pmv_count                               NUMBER;

        CURSOR trans_cur (trans_json_in IN VARCHAR2)
        IS
            SELECT *
            FROM   JSON_TABLE (
                       trans_json_in,
                       '$[*]'
                       COLUMNS (
                           class PATH '$.CLASS',
                           medium PATH '$.MEDIUM',
                           pricemo PATH '$.PRICEMO',
                           pricemt PATH '$.PRICEMT',
                           remark PATH '$.REMARK'));
    BEGIN
        SELECT COUNT (*)
        INTO   pmv_count
        FROM   prmodelver
        WHERE  pmv_id = p_pmvt_pmvid;

        IF pmv_count = 1
        THEN --checking if the pmv_id exists if not integrity constraint error occurs
            SELECT COUNT (*)
            INTO   pm_trans_count
            FROM   (SELECT row_count
                    FROM   (SELECT COUNT (*)     AS row_count
                            FROM   prmodelvertrans
                            WHERE  pmvt_pmvid = p_pmvt_pmvid) a
                           INNER JOIN (SELECT COUNT (*) AS jrow_count FROM JSON_TABLE (p_pmvt_json, '$[*]' COLUMNS (class PATH '$.CLASS'))) b ON row_count = jrow_count);

            IF pm_trans_count <> 0
            THEN
                SELECT COUNT (*)
                INTO   pm_trans_count
                FROM   (SELECT COUNT (*)     AS row_count
                        FROM   prmodelvertrans  a
                               INNER JOIN (SELECT *
                                           FROM   JSON_TABLE (
                                                      p_pmvt_json,
                                                      '$[*]'
                                                      COLUMNS (
                                                          class PATH '$.CLASS',
                                                          medium PATH '$.MEDIUM',
                                                          pricemo PATH '$.PRICEMO',
                                                          pricemt PATH '$.PRICEMT',
                                                          remark PATH '$.REMARK'))) b
                                   ON     a.pmvt_pmvid = p_pmvt_pmvid
                                      AND a.pmvt_trclass = b.class
                                      AND a.pmvt_classtype = b.medium
                                      AND a.pmvt_amountmo = b.pricemo
                                      AND a.pmvt_amountmt = b.pricemt
                                      AND NVL (a.pmvt_comment, 'NA') = NVL (b.remark, 'NA'))
                WHERE  row_count = (SELECT COUNT (*) FROM JSON_TABLE (p_pmvt_json, '$[*]' COLUMNS (class PATH '$.CLASS')));
            END IF;

            IF pm_trans_count = 0
            THEN
                DELETE FROM prmodelvertrans
                WHERE       pmvt_pmvid = p_pmvt_pmvid;

                FOR cur IN trans_cur (p_pmvt_json)
                LOOP
                    INSERT INTO prmodelvertrans (
                                    pmvt_id,
                                    pmvt_pmvid,
                                    pmvt_trclass,
                                    pmvt_classtype,
                                    pmvt_amountmo,
                                    pmvt_amountmt,
                                    pmvt_comment)
                    VALUES      (
                                    pkg_common.generateuniquekey ('G'),
                                    p_pmvt_pmvid,
                                    cur.class,
                                    cur.medium,
                                    cur.pricemo,
                                    cur.pricemt,
                                    cur.remark);
                END LOOP;
            END IF;
        END IF;
    END gpsh_price_transport_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_version_del (p_pmv_id IN VARCHAR2)
    IS
    BEGIN
        UPDATE prmodelver
        SET    pmv_esid = 'D',
               pmv_datemod = SYSDATE
        WHERE  pmv_id = p_pmv_id;
    END gpsh_price_version_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_version_put (
        p_pmv_pmid                              IN VARCHAR2,
        p_pmv_id                                IN VARCHAR2,
        p_pmv_json                              IN VARCHAR2)
    IS
        name                                    VARCHAR2 (50);
        comment                                 VARCHAR2 (4000);
        startdate                               VARCHAR2 (50);
        enddate                                 VARCHAR2 (50);
        t_pmv_id                                VARCHAR2 (20);
        pm_count                                NUMBER;
    BEGIN
        SELECT COUNT (*)
        INTO   pm_count
        FROM   prmodel
        WHERE  pm_id = p_pmv_pmid;

        IF pm_count = 1
        THEN --checking if the pmv_id exists if not integrity constraint error occurs
            SELECT pmv_name,
                   pmv_end,
                   pmv_start,
                   pmv_comment
            INTO   name,
                   enddate,
                   startdate,
                   comment
            FROM   JSON_TABLE (
                       p_pmv_json,
                       '$'
                       COLUMNS (
                           pmv_name PATH '$.NAME',
                           pmv_end PATH '$.END',
                           pmv_start PATH '$.START',
                           pmv_comment PATH '$.COMMENT'));

            SELECT pmv_id
            INTO   t_pmv_id
            FROM   prmodelver RIGHT JOIN DUAL ON pmv_id = p_pmv_id;

            IF t_pmv_id IS NULL
            THEN
                INSERT INTO prmodelver (
                                pmv_id,
                                pmv_pmid,
                                pmv_esid,
                                pmv_name,
                                pmv_start,
                                pmv_end,
                                pmv_comment,
                                pmv_datecre)
                VALUES      (
                                p_pmv_id,
                                p_pmv_pmid,
                                'A',
                                name,
                                pkg_json.from_json_date (startdate),
                                NVL (pkg_json.from_json_date (enddate), TO_DATE ('01.01.2100', 'dd.mm.yyyy')),
                                comment,
                                SYSDATE); -- SO001
            ELSE
                UPDATE prmodelver
                SET    pmv_esid = 'A',
                       pmv_start = pkg_json.from_json_date (startdate),
                       pmv_end = NVL (pkg_json.from_json_date (enddate), TO_DATE ('01.01.2100', 'dd.mm.yyyy')), -- SO001
                       pmv_pmid = p_pmv_pmid,
                       pmv_name = name,
                       pmv_comment = comment,
                       pmv_datemod = SYSDATE
                WHERE  pmv_id = p_pmv_id;
            END IF;
        END IF;
    END gpsh_price_version_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_con_del (p_con_id IN VARCHAR2)
    IS
    BEGIN
        UPDATE contract
        SET    con_esid = 'D'
        WHERE  con_id = p_con_id;
    END gpsh_tpac_con_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_con_put (
        p_con_id                                IN VARCHAR2,
        p_con_json                              IN VARCHAR2)
    IS
        acid                                    VARCHAR2 (20);
        consol                                  VARCHAR2 (6);
        dateblock                               VARCHAR2 (25);
        dateend                                 VARCHAR2 (25);
        datestart                               VARCHAR2 (25);
        esid                                    VARCHAR2 (1);
        estid                                   VARCHAR2 (10);
        etid                                    VARCHAR2 (10);
        hdgroup                                 PLS_INTEGER;
        hotlinephone                            VARCHAR2 (100); -- 003SS
        hotlineemail                            VARCHAR2 (100); -- 003SS
        iwrs                                    NUMBER (7, 4);
        mfgr                                    NUMBER (10, 4);
        mincharge                               NUMBER (12, 4);
        moroamingprom                           PLS_INTEGER;
        mtroamingprom                           PLS_INTEGER;
        name                                    VARCHAR2 (100);
        pmid                                    VARCHAR2 (10);
        price                                   NUMBER (6, 4);
        pricehg                                 NUMBER (6, 4);
        priceint                                NUMBER (6, 4);
        pricemofn                               NUMBER (6, 4);
        pricepg                                 NUMBER (6, 4);
        providername                            VARCHAR2 (100); -- 003SS
        pscall                                  VARCHAR2 (20);
        rarr_allowed                            PLS_INTEGER;
        rarr_hidden                             PLS_INTEGER;
        rsid                                    VARCHAR2 (10);
        setopt                                  VARCHAR2 (10);
        shortid                                 VARCHAR2 (6);
        tarid                                   VARCHAR2 (1);
        througput                               NUMBER (9, 4);

        l_ac_id                                 VARCHAR2 (10);

        CURSOR cacc (con_acid_in IN VARCHAR2)
        IS
            SELECT ac_id
            FROM   account
            WHERE  ac_id = con_acid_in;
    BEGIN
        SELECT con_acid,
               con_consol,
               con_dateblock,
               con_dateend,
               con_datestart,
               con_esid,
               con_estid,
               con_etid,
               con_hdgroup,
               con_hotlinephone,
               con_hotlineemail,
               con_iwrs,
               con_mfgr,
               con_mincharge,
               con_moroamingprom,
               con_mtroamingprom,
               con_name,
               con_pmid,
               con_price,
               con_pricehg,
               con_priceint,
               con_pricemofn,
               con_pricepg,
               con_providername,
               con_pscall,
               con_rarr_allowed,
               con_rarr_hidden,
               con_rsid,
               con_setopt,
               con_shortid,
               con_tarid,
               con_througput
        INTO   acid,
               consol,
               dateblock,
               dateend,
               datestart,
               esid,
               estid,
               etid,
               hdgroup,
               hotlinephone,
               hotlineemail,
               iwrs,
               mfgr,
               mincharge,
               moroamingprom,
               mtroamingprom,
               name,
               pmid,
               price,
               pricehg,
               priceint,
               pricemofn,
               pricepg,
               providername,
               pscall,
               rarr_allowed,
               rarr_hidden,
               rsid,
               setopt,
               shortid,
               tarid,
               througput
        FROM   JSON_TABLE (
                   p_con_json,
                   '$'
                   COLUMNS (
                       con_acid PATH '$.CON_ACID',
                       con_code PATH '$.CON_CODE',
                       con_consol PATH '$.CON_CONSOL',
                       con_dateblock PATH '$.CON_DATEBLOCK',
                       con_dateend PATH '$.CON_DATEEND',
                       con_datestart PATH '$.CON_DATESTART',
                       con_esid PATH '$.CON_ESID',
                       con_estid PATH '$.CON_ESTID',
                       con_etid PATH '$.CON_ETID',
                       con_hdgroup NUMBER PATH '$.CON_HDGROUP',
                       con_hotlinephone PATH '$.CON_HOTLINEPHONE',
                       con_hotlineemail PATH '$.CON_HOTLINEEMAIL',
                       con_iwrs NUMBER PATH '$.CON_IWRS',
                       con_mfgr NUMBER PATH '$.CON_MFGR',
                       con_mincharge NUMBER PATH '$.CON_MINCHARGE',
                       con_moroamingprom NUMBER PATH '$.CON_MOROAMINGPROM',
                       con_mtroamingprom NUMBER PATH '$.CON_MTROAMINGPROM',
                       con_name PATH '$.CON_NAME',
                       con_pmid PATH '$.CON_PMID',
                       con_price NUMBER PATH '$.CON_PRICE',
                       con_pricehg NUMBER PATH '$.CON_PRICEHG',
                       con_priceint NUMBER PATH '$.CON_PRICEINT',
                       con_pricemofn NUMBER PATH '$.CON_PRICEMOFN',
                       con_pricepg NUMBER PATH '$.CON_PRICEPG',
                       con_providername PATH '$.CON_PROVIDERNAME',
                       con_pscall PATH '$.CON_PSCALL',
                       con_rarr_allowed NUMBER PATH '$.CON_RARR_ALLOWED',
                       con_rarr_hidden NUMBER PATH '$.CON_RARR_HIDDEN',
                       con_rsid PATH '$.CON_RSID',
                       con_setopt PATH '$.CON_SETOPT',
                       con_shortid PATH '$.CON_SHORTID',
                       con_tarid PATH '$.CON_TARID',
                       con_througput NUMBER PATH '$.CON_THROUGHPUT')); -- 003SS

        OPEN cacc (acid);

        FETCH cacc INTO l_ac_id;

        IF cacc%NOTFOUND
        THEN
            INSERT INTO account (
                            ac_id,
                            ac_etid,
                            ac_demo,
                            ac_short,
                            ac_name,
                            ac_logret,
                            ac_langid,
                            ac_vat,
                            ac_currency,
                            ac_esid,
                            ac_adrid_main,
                            ac_adrid_maincontact,
                            ac_datecre,
                            ac_chngcnt)
                SELECT acid, 'LA', 0, acid, acid, 0, 'de', 0, 'CHF', 'A', pkg_cpro.gpsh_tpac_new_adr_id (NULL), pkg_cpro.gpsh_tpac_new_adr_id (NULL), SYSDATE, 0 FROM DUAL;
        END IF;

        CLOSE cacc;

        UPDATE contract
        SET    con_acid = acid,
               con_consol = consol,
               con_dateblock = pkg_json.from_json_date (dateblock),
               con_dateend = pkg_json.from_json_date (dateend),
               con_datestart = pkg_json.from_json_date (datestart),
               con_esid = esid,
               con_estid = estid,
               con_etid = etid,
               con_hotlinephone = hotlinephone,
               con_hotlineemail = hotlineemail,
               con_hdgroup = hdgroup,
               con_iwrs = iwrs,
               con_mfgr = mfgr,
               con_mincharge = mincharge,
               con_moroamingprom = moroamingprom,
               con_mtroamingprom = mtroamingprom,
               con_name = name,
               con_pmid = pmid,
               con_price = price,
               con_pricehg = pricehg,
               con_priceint = priceint,
               con_pricemofn = pricemofn,
               con_pricepg = pricepg -- 002SS
                                    ,
               con_providername = providername,
               con_pscall = pscall,
               con_rarr_allowed = rarr_allowed,
               con_rarr_hidden = rarr_hidden,
               con_rsid = rsid,
               con_shortid = shortid,
               con_tarid = tarid,
               con_througput = througput,
               con_setopt = setopt,
               con_datemod = SYSDATE -- 001SO
        WHERE  con_id = p_con_id; -- 003SS

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO contract (
                            con_id,
                            con_acid,
                            con_consol,
                            con_dateblock,
                            con_dateend,
                            con_datestart,
                            con_esid,
                            con_estid,
                            con_etid,
                            con_hotlineemail,
                            con_hotlinephone,
                            con_hdgroup,
                            con_iwrs,
                            con_mfgr,
                            con_mincharge,
                            con_moroamingprom,
                            con_mtroamingprom,
                            con_name,
                            con_pmid,
                            con_price,
                            con_pricehg,
                            con_priceint,
                            con_pricemofn,
                            con_pricepg -- 002SS
                                       ,
                            con_providername,
                            con_pscall,
                            con_rarr_allowed,
                            con_rarr_hidden,
                            con_rsid,
                            con_shortid,
                            con_tarid,
                            con_througput,
                            con_srctype,
                            con_setopt,
                            con_datecre)
            VALUES      (
                            p_con_id,
                            acid,
                            consol,
                            pkg_json.from_json_date (dateblock),
                            pkg_json.from_json_date (dateend),
                            pkg_json.from_json_date (datestart),
                            esid,
                            estid,
                            etid,
                            hotlineemail,
                            hotlinephone,
                            hdgroup,
                            iwrs,
                            mfgr,
                            mincharge,
                            moroamingprom,
                            mtroamingprom,
                            name,
                            pmid,
                            price,
                            pricehg,
                            priceint,
                            pricemofn,
                            pricepg -- 002SS
                                   ,
                            providername,
                            pscall,
                            rarr_allowed,
                            rarr_hidden,
                            rsid,
                            shortid,
                            tarid,
                            througput,
                            DECODE (etid,  'LAC', 'SMSC',  'MLC', 'MMSC',  'ISRV'),
                            setopt,
                            SYSDATE);
        END IF; -- 003SO -- 001SO -- 003SS
    END gpsh_tpac_con_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_cs_del (p_cs_id IN VARCHAR2)
    IS
    BEGIN
        DELETE FROM contentservice
        WHERE       cs_id = p_cs_id;
    END gpsh_tpac_cs_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_cs_put (
        p_con_id                                IN VARCHAR2,
        p_cs_id                                 IN VARCHAR2,
        p_con_json                              IN VARCHAR2)
    IS
        etid                                    VARCHAR2 (10);
        name                                    VARCHAR2 (50);
        service                                 VARCHAR2 (50);
        gart                                    VARCHAR2 (10);
        esid                                    VARCHAR2 (10);
        duobill                                 VARCHAR2 (5);
        t_cs_id                                 VARCHAR2 (20);
    BEGIN
        SELECT cs_etid,
               cs_name,
               cs_service,
               cs_gart,
               cs_duobill,
               cs_esid
        INTO   etid,
               name,
               service,
               gart,
               duobill,
               esid
        FROM   JSON_TABLE (
                   p_con_json,
                   '$'
                   COLUMNS (
                       cs_etid PATH '$.CST.fk[1]',
                       cs_name PATH '$.NAME',
                       cs_service PATH '$.CODE',
                       cs_gart PATH '$.GART.fk[1]',
                       cs_duobill PATH '$.IGNORE_DUOBILL',
                       cs_esid PATH '$.CSSTATE.fk[1]'));

        SELECT cs_id
        INTO   t_cs_id
        FROM   contentservice RIGHT JOIN DUAL ON cs_id = p_cs_id;

        IF t_cs_id IS NULL
        THEN
            INSERT INTO contentservice (
                            cs_id,
                            cs_conid,
                            cs_etid,
                            cs_srctype,
                            cs_service,
                            cs_name,
                            cs_gart,
                            cs_ignore_duobill,
                            cs_esid,
                            cs_datecre)
            VALUES      (
                            p_cs_id,
                            p_con_id,
                            etid,
                            'ISRV',
                            service,
                            name,
                            gart,
                            pkg_json.from_json_boolean (duobill),
                            esid,
                            SYSDATE);
        ELSE
            SELECT cs_id
            INTO   t_cs_id
            FROM   contentservice
                   RIGHT JOIN DUAL
                       ON     cs_id = p_cs_id
                          AND cs_conid = p_con_id
                          AND cs_etid = etid
                          AND cs_name = name
                          AND cs_esid = esid -- added ESID Check for update
                          AND cs_srctype = 'ISRV'
                          AND cs_service = service
                          AND cs_gart = gart
                          AND cs_ignore_duobill = pkg_json.from_json_boolean (duobill);

            IF t_cs_id IS NULL
            THEN
                UPDATE contentservice
                SET    cs_etid = etid,
                       cs_name = name,
                       cs_conid = p_con_id,
                       cs_srctype = 'ISRV',
                       cs_service = service,
                       cs_gart = gart,
                       cs_ignore_duobill = pkg_json.from_json_boolean (duobill),
                       cs_esid = esid,
                       cs_datemod = SYSDATE
                WHERE  cs_id = p_cs_id;
            END IF;
        END IF;
    END gpsh_tpac_cs_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_del (p_ac_id IN VARCHAR2)
    IS
    BEGIN
        UPDATE account
        SET    ac_esid = 'D'
        WHERE  ac_id = p_ac_id;
    END gpsh_tpac_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_keyword_del (p_con_id IN VARCHAR2)
    IS
    BEGIN
        DELETE FROM keyword
        WHERE       key_conid = p_con_id;
    END gpsh_tpac_keyword_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_keyword_put (
        p_con_id                                IN VARCHAR2,
        p_key_json                              IN VARCHAR2)
    IS
        keywords_in_count                       NUMBER (5); -- SO002
        keywords_db_count                       NUMBER (5); -- SO002

        CURSOR keyword_cur (key_in IN VARCHAR2)
        IS
            SELECT j.keyword,
                   j.billrate,
                   j.allowed
            FROM   JSON_TABLE (
                       key_in,
                       '$[*]'
                       COLUMNS (
                           keyword PATH '$.KEYWORD',
                           billrate PATH '$.BILLRATE',
                           allowed PATH '$.ALLOWED')) AS j;
    BEGIN
        SELECT COUNT (*) INTO keywords_in_count FROM JSON_TABLE (p_key_json, '$[*]' COLUMNS (keyword PATH '$.KEYWORD'));

        SELECT COUNT (*)
        INTO   keywords_db_count
        FROM   keyword
        WHERE  key_conid = p_con_id;

        IF keywords_in_count = keywords_db_count
        THEN
            SELECT COUNT (*)
            INTO   keywords_db_count
            FROM   keyword  a
                   INNER JOIN (SELECT *
                               FROM   JSON_TABLE (
                                          p_key_json,
                                          '$[*]'
                                          COLUMNS (
                                              keyword PATH '$.KEYWORD',
                                              billrate PATH '$.BILLRATE',
                                              allowed PATH '$.ALLOWED'))) b
                       ON     a.key_keyword = b.keyword
                          AND a.key_billrate = b.billrate
                          AND a.key_allowed = pkg_json.from_json_boolean (b.allowed)
                          AND a.key_conid = p_con_id;
        END IF;

        IF keywords_in_count <> keywords_db_count
        THEN
            DELETE FROM keyword
            WHERE       key_conid = p_con_id;

            FOR cur IN keyword_cur (p_key_json)
            LOOP
                INSERT INTO keyword (
                                key_id,
                                key_conid,
                                key_keyword,
                                key_billrate,
                                key_allowed,
                                key_datecre)
                VALUES      (
                                pkg_common.generateuniquekey ('G'),
                                p_con_id,
                                cur.keyword,
                                cur.billrate,
                                pkg_json.from_json_boolean (cur.allowed),
                                SYSDATE);
            END LOOP;
        END IF;
    END gpsh_tpac_keyword_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_longid_map_del (
        p_longm_longid1                         IN VARCHAR2,
        p_longm_longid2                         IN VARCHAR2)
    IS
    BEGIN
        DELETE FROM longidmap
        WHERE           longm_longid2 >= p_longm_longid1
                    AND longm_longid1 <= p_longm_longid2;
    END gpsh_tpac_longid_map_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_longid_map_put (p_longid_json IN VARCHAR2)
    IS
        longid1                                 VARCHAR2 (15);
        longid2                                 VARCHAR2 (15);
        esid                                    VARCHAR2 (1);
        datestart                               VARCHAR2 (20);
        dateend                                 VARCHAR2 (20);
        shortid                                 VARCHAR2 (7);
        price                                   VARCHAR2 (10);
        occupied                                VARCHAR2 (6);
    BEGIN
        SELECT p_longid1,
               p_longid2,
               p_esid,
               p_datestart,
               p_dateend,
               p_shortid,
               p_price,
               p_occupied
        INTO   longid1,
               longid2,
               esid,
               datestart,
               dateend,
               shortid,
               price,
               occupied
        FROM   JSON_TABLE (
                   p_longid_json,
                   '$'
                   COLUMNS (
                       p_longid1 PATH '$.LONGID1',
                       p_longid2 PATH '$.LONGID2',
                       p_esid PATH '$.STATUS.fk[1]',
                       p_datestart PATH '$.DATESTART',
                       p_dateend PATH '$.DATEEND',
                       p_shortid PATH '$.SHORTID',
                       p_price PATH '$.PRICE',
                       p_occupied PATH '$.OCCUPIED'));

        UPDATE longidmap
        SET    longm_available = 0,
               longm_dateend = pkg_json.from_json_date (dateend),
               longm_datestart = pkg_json.from_json_date (datestart),
               longm_esid = esid,
               longm_occupied = occupied,
               longm_price = price,
               longm_shortid = shortid
        WHERE      longm_longid1 = longid1
               AND longm_longid2 = longid2;

        IF SQL%ROWCOUNT = 0
        THEN
            gpsh_tpac_longid_map_del (longid1, longid2);

            INSERT INTO longidmap (
                            longm_available,
                            longm_dateend,
                            longm_datestart,
                            longm_esid,
                            longm_longid1,
                            longm_longid2,
                            longm_occupied,
                            longm_price,
                            longm_shortid)
            VALUES      (
                            0,
                            pkg_json.from_json_date (dateend),
                            pkg_json.from_json_date (datestart),
                            esid,
                            TO_NUMBER (longid1),
                            TO_NUMBER (longid2),
                            occupied,
                            price,
                            shortid);
        END IF;
    END gpsh_tpac_longid_map_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_put (
        p_ac_id                                 IN VARCHAR2,
        p_ac_json                               IN VARCHAR2)
    IS
        name                                    VARCHAR2 (100);
        invoice_emails                          VARCHAR2 (4000);
        mbunit                                  VARCHAR2 (15);
        stats_emails                            VARCHAR2 (4000);
        t_ac_id                                 VARCHAR2 (20);
    BEGIN
        SELECT ac_name,
               ac_in_emails,
               ac_mbunit,
               ac_st_emails
        INTO   name,
               invoice_emails,
               mbunit,
               stats_emails
        FROM   JSON_TABLE (
                   p_ac_json,
                   '$'
                   COLUMNS (
                       ac_name PATH '$.NAME',
                       ac_in_emails PATH '$.INVOICE_EMAILIDS',
                       ac_mbunit PATH '$.MBUNIT',
                       ac_st_emails PATH '$.STATISTICS_EMAILIDS'));

        SELECT ac_id
        INTO   t_ac_id
        FROM   account RIGHT JOIN DUAL ON ac_id = p_ac_id;

        IF t_ac_id IS NULL
        THEN
            INSERT INTO account (
                            ac_id,
                            ac_etid,
                            ac_demo,
                            ac_short,
                            ac_name,
                            ac_logret,
                            ac_langid,
                            ac_vat,
                            ac_currency,
                            ac_esid,
                            ac_adrid_main,
                            ac_adrid_maincontact,
                            ac_datecre,
                            ac_chngcnt,
                            ac_la_invoice_emails,
                            ac_bn_stats_emails,
                            ac_mbunit)
                SELECT p_ac_id,
                       'LA',
                       0,
                       p_ac_id,
                       name,
                       0,
                       'de',
                       0,
                       'CHF',
                       'A',
                       pkg_cpro.gpsh_tpac_new_adr_id (NULL),
                       pkg_cpro.gpsh_tpac_new_adr_id (NULL),
                       SYSDATE,
                       0,
                       invoice_emails,
                       stats_emails,
                       mbunit
                FROM   DUAL;
        ELSE
            UPDATE account
            SET    ac_esid = 'A',
                   ac_name = name,
                   ac_la_invoice_emails = invoice_emails,
                   ac_bn_stats_emails = stats_emails,
                   ac_mbunit = mbunit,
                   ac_datemod = SYSDATE
            WHERE  ac_id = p_ac_id;
        END IF;
    END gpsh_tpac_put;
END pkg_tpac_cpro;
/