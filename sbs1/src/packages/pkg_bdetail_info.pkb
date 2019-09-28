CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_bdetail_info
AS
    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_is (
        p_pac_id                                IN     VARCHAR2, -- 'IS' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
        -- procedure fills up consolidation table ISCONSOL (Info Service Consolidation) with data from bdetail
        v_sep_id                                VARCHAR2 (6); -- YYYYMM
    BEGIN
        v_sep_id := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1), 'YYYYMM'); --  027SO

        -- change states of old records
        UPDATE isconsol
        SET    isc_esid = 'D'
        WHERE      isc_sepid = v_sep_id
               AND isc_esid <> 'D'; --  027SO

        -- insert records into consolidation table
        INSERT INTO isconsol (
                        isc_id,
                        isc_date,
                        isc_sepid,
                        isc_esid,
                        isc_srctype,
                        isc_conid,
                        isc_constype,
                        isc_shortid,
                        isc_service,
                        isc_keyword, --  046SO --  044SO
                        isc_billtext,
                        isc_count,
                        isc_price,
                        isc_amountcu,
                        isc_retsharepv,
                        isc_retsharemo,
                        isc_prepaid,
                        isc_reqtype,
                        isc_billrate,
                        isc_stype,
                        isc_pmvid,
                        isc_billingdomain, --  038SO
                        isc_transportmedium, --  038SO
                        isc_category, --  038SO
                        isc_cdrtid, --  042SO
                        isc_vsprcid, --  047SO
                        isc_counttr, --  047SO
                        isc_amounttr, --  047SO
                        isc_billtext_agr, --  053SO
                        isc_gart, --  057SO
                        isc_show, --  058SO
                        isc_campaign) --  058SO
            SELECT /*+ NO_INDEX(BDETAIL) */
                     pkg_common.generateuniquekey ('G')               AS isc_id,
                     SYSDATE                                          AS isc_date,
                     sep_id                                           AS isc_sepid,
                     'R'                                              AS isc_esid,
                     bd_srctype                                       AS isc_srctype,
                     con_id                                           AS isc_conid,
                     con_estid                                        AS isc_constype, --  037SO
                     bd_shortid                                       AS isc_shortid,
                     bd_service                                       AS isc_service,
                     DECODE (bd_billrate, NULL, NULL, bd_keyword)     AS isc_keyword, --  046SO --  044SO
                     bd_billtext                                      AS isc_billtext,
                     COUNT (bdetail.ROWID)                            AS isc_count,
                     bd_amountcu                                      AS isc_price,
                     SUM (bd_amountcu)                                AS isc_amountcu,
                     SUM (bd_retsharepv)                              AS isc_retsharepv,
                     SUM (bd_retsharemo)                              AS isc_retsharemo,
                     bd_prepaid                                       AS isc_prepaid,
                     bd_reqtype                                       AS isc_reqtype,
                     bd_billrate                                      AS isc_billrate,
                     bd_stype                                         AS isc_stype,
                     bd_pmvid                                         AS isc_pmvid,
                     bd_billingdomain, --  038SO
                     bd_transportmedium, --  038SO
                     bd_category, --  038SO
                     NVL (bd_cdrtid, 'CTB-CO'), --  042SO normally CONTENT
                     bd_vsprcid, --  047SO
                     SUM (bd_counttr), --  047SO
                     SUM (bd_amounttr), --  047SO
                     0, --  053SO
                     bd_gart, --  057SO
                     bd_show, --  058SO
                     bd_campaign --  058SO
            FROM     bdetail,
                     contract,
                     setperiod
            WHERE        bdetail.bd_conid = contract.con_id
                     AND bd_datetime >= TO_DATE (v_sep_id, 'YYYYMM') --  030SO
                     AND bd_datetime < ADD_MONTHS (TO_DATE (v_sep_id, 'YYYYMM'), 1) --  030SO
                     AND sep_date1 = TO_DATE (v_sep_id, 'YYYYMM') --  030SO
                     AND bd_mapsid = 'R'
            GROUP BY sep_id,
                     bd_srctype,
                     con_id,
                     con_estid, --  037SO
                     bd_billingdomain, --  038SO
                     bd_transportmedium, --  038SO
                     bd_category, --  038SO
                     NVL (bd_cdrtid, 'CTB-CO'), --  042SO
                     bd_shortid,
                     bd_service,
                     DECODE (bd_billrate, NULL, NULL, bd_keyword), --  046SO --  044SO
                     bd_billtext,
                     bd_amountcu,
                     bd_prepaid,
                     bd_reqtype,
                     bd_billrate,
                     bd_stype,
                     bd_pmvid,
                     bd_vsprcid, --  047SO
                     bd_gart, --  057SO
                     bd_show, --  058SO
                     bd_campaign; --  058SO

        -- aggregate the entries with too many billtexts   --  027SO whole rest added

        -- clear list of bad contracts. needed if this runs more than once per period
        DELETE FROM isc_aggregation
        WHERE       isca_sepid = v_sep_id;

        -- populate list of bad contracts
        INSERT INTO isc_aggregation (
                        isca_id,
                        isca_sepid,
                        isca_conid,
                        isca_shortid,
                        isca_service,
                        isca_count)
            (SELECT   pkg_common.generateuniquekey ('G'),
                      v_sep_id,
                      isc_conid,
                      isc_shortid,
                      isc_service,
                      COUNT (*)
             FROM     isconsol
             WHERE        isc_sepid = v_sep_id
                      AND isc_esid = 'R'
                      AND isc_cdrtid = 'CTB-CO' --  042SO
             GROUP BY isc_conid,
                      isc_shortid,
                      isc_service
             HAVING   COUNT (*) > 2000);

        -- mark offending entries as 'aggregated'
        UPDATE isconsol
        SET    isc_billtext_agr = 1 --  053SO
        WHERE      isc_sepid = v_sep_id
               AND isc_esid = 'R' --  033SO
               AND isc_cdrtid = 'CTB-CO' --  042SO
               AND isc_conid IN (SELECT isca_conid
                                 FROM   isc_aggregation
                                 WHERE  isca_sepid = v_sep_id);

        recordsaffected := SQL%ROWCOUNT;
        errorcode := 0;
        returnstatus := 1;
        RETURN;
    END sp_cons_is;

    PROCEDURE sp_cons_ismsisdn (
        p_pac_id                                IN     VARCHAR2, -- 'ISMSISDN'   ISMSISDN Consolidation -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
        -- procedure fills up consolidation table ISMSTAT (Info Service Msisdn) with data from bdetail
        -- procedure fills up consolidation table TPMCONSOL (Third Party Msisdn) with data from bdetail
        x_tpid                                  VARCHAR2 (10);
        n_tpid                                  NUMBER;
        x_service                               VARCHAR2 (20); --  040SO
        x_billtext                              VARCHAR2 (80);

        x_msisdn                                VARCHAR2 (20);
        n_msisdn                                NUMBER;
        x_shortid                               VARCHAR2 (6);
        n_shortid                               NUMBER;
        x_keyword                               VARCHAR2 (80);
        x_consubtype                            VARCHAR2 (10);
        x_reqtype                               NUMBER;
        n_amountcu                              NUMBER (9, 4);
        n_pullinc                               NUMBER;
        n_pushinc                               NUMBER;

        CURSOR c1 (period_id IN VARCHAR2)
        IS
            SELECT /*+ FULL(BDETAIL) */
                   bd_msisdn_a,
                   NVL (con_estid, '-e-'), --  037SO
                   NVL (bd_shortid, '0'),
                   NVL (bd_keyword, '-empty-'),
                   bd_reqtype,
                   bd_amountcu,
                   bd_service,
                   NVL (bd_billtext, '-empty-'),
                   NVL (bd_tpid, '0')
            FROM   bdetail,
                   contract
            WHERE      bdetail.bd_conid = contract.con_id
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_cdrtid = 'CTB-CO' --  043SO
                   AND bd_datetime >= TO_DATE (period_id, 'YYYYMM') --  032SO
                   AND bd_datetime < ADD_MONTHS (TO_DATE (period_id, 'YYYYMM'), 1); --  032SO

        v_sep_id                                VARCHAR2 (6); -- YYYYMM                               --  029SO
    BEGIN
        v_sep_id := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1), 'YYYYMM'); --  029SO

        recordsaffected := 0;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ISMSTAT';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE TPMCONSOL';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE TPMCONSOL_BAD'; --  029SO

        OPEN c1 (v_sep_id);

        LOOP
            FETCH c1
                INTO x_msisdn,
                     x_consubtype,
                     x_shortid,
                     x_keyword,
                     x_reqtype,
                     n_amountcu,
                     x_service,
                     x_billtext,
                     x_tpid;

            EXIT WHEN c1%NOTFOUND;

            BEGIN
                n_msisdn := TO_NUMBER (SUBSTR (pkg_bdetail_common.normalizedmsisdn (x_msisdn), 1, 16)); -- internationalize MSISDN
                n_shortid := TO_NUMBER (x_shortid); -- convert to number
                x_keyword := SUBSTR (x_keyword, 1, 30); -- truncate keyword
                x_billtext := SUBSTR (x_billtext, 1, 30); -- truncate billtext
                n_tpid := TO_NUMBER (x_tpid); -- convert to number

                IF x_reqtype IN (0,
                                 501,
                                 603)
                THEN
                    -- considered pull
                    n_pullinc := 1;
                    n_pushinc := 0;
                ELSE
                    -- everything else considered push: check later for MMS
                    n_pullinc := 0;
                    n_pushinc := 1;
                END IF;

                UPDATE ismstat
                SET    ism_pullcount = ism_pullcount + n_pullinc,
                       ism_pushcount = ism_pushcount + n_pushinc,
                       ism_amountcu = ism_amountcu + n_amountcu
                WHERE      ism_msisdn = n_msisdn
                       AND ism_consub = x_consubtype
                       AND ism_shortid = n_shortid
                       AND ism_keyword = x_keyword;

                IF SQL%ROWCOUNT = 0
                THEN -- must insert this row
                    INSERT INTO ismstat (
                                    ism_msisdn,
                                    ism_consub,
                                    ism_shortid,
                                    ism_keyword,
                                    ism_pullcount,
                                    ism_pushcount,
                                    ism_amountcu)
                    VALUES      (
                        n_msisdn,
                        x_consubtype,
                        n_shortid,
                        x_keyword,
                        n_pullinc,
                        n_pushinc,
                        n_amountcu);

                    recordsaffected := recordsaffected + 1;
                END IF;

                UPDATE tpmconsol
                SET    tpmc_pullcount = tpmc_pullcount + n_pullinc,
                       tpmc_pushcount = tpmc_pushcount + n_pushinc,
                       tpmc_amountcu = tpmc_amountcu + n_amountcu
                WHERE      tpmc_msisdn = n_msisdn
                       AND tpmc_consub = x_consubtype
                       AND tpmc_tpid = n_tpid
                       AND tpmc_service = x_service
                       AND tpmc_billtext = x_billtext;

                IF SQL%ROWCOUNT = 0
                THEN -- must insert this row
                    INSERT INTO tpmconsol (
                                    tpmc_msisdn,
                                    tpmc_consub,
                                    tpmc_tpid,
                                    tpmc_service,
                                    tpmc_billtext,
                                    tpmc_pullcount,
                                    tpmc_pushcount,
                                    tpmc_amountcu,
                                    tpmc_billtext_agr --  053SO
                                                     )
                    VALUES      (
                        n_msisdn,
                        x_consubtype,
                        n_tpid,
                        x_service,
                        x_billtext,
                        n_pullinc,
                        n_pushinc,
                        n_amountcu,
                        0); --  053SO

                    recordsaffected := recordsaffected + 1;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    pkg_common.insert_warning (
                        'PKG_BDETAIL_INFO',
                        'SP_INSERT_ISMSTAT',
                        'Illegal values',
                        'MSISDN=' || x_msisdn || ' CONSUBTYPE=' || x_consubtype || ' TPID=' || x_tpid || ' SERVICE=' || x_service || ' SHORTID=' || x_shortid || ' KEYWORD=' || x_keyword,
                        NULL,
                        p_boh_id,
                        NULL,
                        x_shortid); --  064SO
            END;
        END LOOP;

        CLOSE c1;

        --  053SO --  029SO aggregate entries for short IDs which have too many BillTexts

        -- Mark the 'bad' entries
        UPDATE tpmconsol
        SET    tpmc_billtext_agr = 1 --  053SO
        WHERE  tpmc_service IN (SELECT isca_service
                                FROM   isc_aggregation
                                WHERE  isca_sepid = v_sep_id);

        errorcode := 0;
        returnstatus := 1;
        RETURN;
    END sp_cons_ismsisdn;

    PROCEDURE sp_cons_tr (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        UPDATE trconsol
        SET    trc_esid = 'D'
        WHERE  trc_sepid IN (SELECT sep_id
                             FROM   setperiod
                             WHERE      sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                                    AND trc_etid IN ('SMS',
                                                     'MMS')
                                    AND trc_esid = 'R');

        recordsaffected := 0;

        INSERT INTO trconsol (
                        trc_id,
                        trc_date,
                        trc_sepid,
                        trc_esid,
                        trc_etid,
                        trc_trdid,
                        trc_conid,
                        trc_shortid,
                        trc_service,
                        trc_trclass,
                        trc_price,
                        trc_count,
                        trc_amount,
                        trc_prepaid,
                        trc_gart, --  057SO
                        trc_show, --  058SO
                        trc_campaign) --  058SO
            SELECT   pkg_common.generateuniquekey ('G')                     AS trc_id,
                     SYSDATE                                                AS trc_date,
                     isc_sepid                                              AS trc_sepid,
                     'R'                                                    AS trc_esid,
                     'SMS'                                                  AS trc_etid,
                     'MO'                                                   AS trc_trdid,
                     isc_conid                                              AS trc_conid,
                     isc_shortid                                            AS trc_shortid,
                     isc_service                                            AS trc_service,
                     NULL                                                   AS trc_trclass,
                     SUM (isc_amounttr) / (SUM (isc_counttr) + 1.0E-10)     AS trc_price,
                     SUM (isc_counttr)                                      AS trc_count,
                     SUM (isc_amounttr)                                     AS trc_amount,
                     isc_prepaid                                            AS trc_prepaid,
                     isc_gart                                               AS trc_gart, --  057SO
                     isc_show                                               AS trc_show, --  058SO
                     isc_campaign                                           AS trc_campaign --  058SO
            FROM     isconsol,
                     contract,
                     setperiod
            WHERE        con_id = isc_conid --  050SO
                     AND con_srctype = 'ISRV'
                     AND sep_date2 = TRUNC (SYSDATE, 'MONTH')
                     AND isc_sepid = sep_id
                     AND isc_esid = 'R'
                     AND isc_cdrtid = 'CTB-MO'
                     AND isc_transportmedium = 'SMS'
            GROUP BY isc_sepid,
                     isc_conid,
                     isc_shortid,
                     isc_service,
                     isc_prepaid,
                     isc_gart, --  057SO
                     isc_show, --  058SO
                     isc_campaign --  058SO
            UNION ALL
            SELECT   pkg_common.generateuniquekey ('G')                     AS trc_id,
                     SYSDATE                                                AS trc_date,
                     isc_sepid                                              AS trc_sepid,
                     'R'                                                    AS trc_esid,
                     'SMS'                                                  AS trc_etid,
                     'MT'                                                   AS trc_trdid,
                     isc_conid                                              AS trc_conid,
                     isc_shortid                                            AS trc_shortid,
                     isc_service                                            AS trc_service,
                     NULL                                                   AS trc_trclass,
                     SUM (isc_amounttr) / (SUM (isc_counttr) + 1.0E-10)     AS trc_price,
                     SUM (isc_counttr)                                      AS trc_count,
                     SUM (isc_amounttr)                                     AS trc_amount,
                     isc_prepaid                                            AS trc_prepaid,
                     isc_gart                                               AS trc_gart, --  057SO
                     isc_show                                               AS trc_show, --  058SO
                     isc_campaign                                           AS trc_campaign --  058SO
            FROM     isconsol,
                     contract,
                     setperiod
            WHERE        con_id = isc_conid --  050SO
                     AND con_srctype = 'ISRV'
                     AND sep_date2 = TRUNC (SYSDATE, 'MONTH')
                     AND isc_sepid = sep_id
                     AND isc_esid = 'R'
                     AND isc_cdrtid = 'CTB-CO'
                     AND isc_transportmedium = 'SMS'
            GROUP BY isc_sepid,
                     isc_conid,
                     isc_shortid,
                     isc_service,
                     isc_prepaid,
                     isc_gart, --  057SO
                     isc_show, --  058SO
                     isc_campaign; --  058SO

        recordsaffected := recordsaffected + SQL%ROWCOUNT;

        INSERT INTO trconsol (
                        trc_id,
                        trc_date,
                        trc_sepid,
                        trc_esid,
                        trc_etid,
                        trc_trdid,
                        trc_conid,
                        trc_shortid,
                        trc_service,
                        trc_trclass,
                        trc_price,
                        trc_count,
                        trc_amount,
                        trc_prepaid,
                        trc_gart, --  057SO
                        trc_show, --  058SO
                        trc_campaign) --  058SO
            SELECT   pkg_common.generateuniquekey ('G')                     AS trc_id,
                     SYSDATE                                                AS trc_date,
                     sep_id                                                 AS trc_sepid,
                     'R'                                                    AS trc_esid,
                     'MMS'                                                  AS trc_etid,
                     'MO'                                                   AS trc_trdid,
                     isc_conid                                              AS trc_conid,
                     isc_shortid                                            AS trc_shortid,
                     isc_service                                            AS trc_service,
                     NULL                                                   AS trc_trclass,
                     SUM (isc_amounttr) / (SUM (isc_counttr) + 1.0E-10)     AS trc_price, --  049SO
                     SUM (isc_counttr)                                      AS trc_count,
                     SUM (isc_amounttr)                                     AS trc_amount,
                     isc_prepaid                                            AS trc_prepaid,
                     isc_gart                                               AS trc_gart, --  057SO
                     isc_show                                               AS trc_show, --  058SO
                     isc_campaign                                           AS trc_campaign --  058SO
            FROM     isconsol,
                     contract,
                     setperiod
            WHERE        sep_date2 = TRUNC (SYSDATE, 'MONTH')
                     AND isc_sepid = sep_id
                     AND isc_conid = con_id
                     AND isc_esid = 'R'
                     AND isc_cdrtid = 'CTB-MO'
                     AND isc_transportmedium = 'MMS'
                     AND con_srctype = 'ISRV'
            GROUP BY sep_id,
                     isc_conid,
                     isc_shortid,
                     isc_service,
                     isc_prepaid,
                     isc_gart, --  057SO
                     isc_show, --  058SO
                     isc_campaign --  058SO
            UNION ALL
            SELECT   pkg_common.generateuniquekey ('G')                     AS trc_id,
                     SYSDATE                                                AS trc_date,
                     sep_id                                                 AS trc_sepid,
                     'R'                                                    AS trc_esid,
                     'MMS'                                                  AS trc_etid,
                     'MT'                                                   AS trc_trdid,
                     isc_conid                                              AS trc_conid,
                     isc_shortid                                            AS trc_shortid,
                     isc_service                                            AS trc_service,
                     NULL                                                   AS trc_trclass,
                     SUM (isc_amounttr) / (SUM (isc_counttr) + 1.0E-10)     AS trc_price, --  049SO
                     SUM (isc_counttr)                                      AS trc_count,
                     SUM (isc_amounttr)                                     AS trc_amount,
                     isc_prepaid                                            AS trc_prepaid,
                     isc_gart                                               AS trc_gart, --  057SO
                     isc_show                                               AS trc_show, --  058SO
                     isc_campaign                                           AS trc_campaign --  058SO
            FROM     isconsol,
                     contract,
                     setperiod
            WHERE        sep_date2 = TRUNC (SYSDATE, 'MONTH')
                     AND isc_sepid = sep_id
                     AND isc_conid = con_id
                     AND isc_esid = 'R'
                     AND isc_cdrtid = 'CTB-CO'
                     AND isc_transportmedium = 'MMS'
                     AND con_srctype = 'ISRV'
            GROUP BY sep_id,
                     isc_conid,
                     isc_shortid,
                     isc_service,
                     isc_prepaid,
                     isc_gart, --  057SO
                     isc_show, --  058SO
                     isc_campaign; --  058SO
                                   --  048SO

        recordsaffected := recordsaffected + SQL%ROWCOUNT;

        errorcode := 0;
        returnstatus := 1;
        RETURN;
    END sp_cons_tr;
END pkg_bdetail_info;
/