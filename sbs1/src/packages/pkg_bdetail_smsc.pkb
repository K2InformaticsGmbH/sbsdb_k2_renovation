CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_bdetail_smsc
AS
    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_laa_sms_accu (
        batchsize                               IN     INTEGER,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE sp_lia_rsgr_accu (
        batchsize                               IN     INTEGER,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE sp_lia_sms_accu (
        batchsize                               IN     INTEGER,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE sp_smsccu_update (
        batchsize                               IN     INTEGER,
        p_bd_pacsid                             IN     VARCHAR2,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                         IN OUT NUMBER); --  055SO --  010SO duplicated from standard counter update based on MSC CDRs (in PKG_BDETAIL_MSC)

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_dgti (
        p_pac_id                                IN     VARCHAR2, -- 'DGTI'     DGTI consolidation -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                               OUT NUMBER) --  039SO
    IS
    BEGIN
        returnstatus := pkg_common.return_status_failure;

        UPDATE dgticonsol
        SET    dgtic_esid = 'D'
        WHERE      dgtic_sepid = TO_CHAR (TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'), 'YYYYMM')
               AND dgtic_etid = 'DELIVERY'
               AND dgtic_esid = 'R';

        INSERT INTO dgticonsol (
                        dgtic_id,
                        dgtic_etid,
                        dgtic_esid,
                        dgtic_sepid,
                        dgtic_dgti,
                        dgtic_date,
                        dgtic_fromdate,
                        dgtic_todate,
                        dgtic_status,
                        dgtic_conid,
                        dgtic_consolidation,
                        dgtic_prepaid,
                        dgtic_vsmscid,
                        dgtic_count)
            SELECT /*+ NO_INDEX(BDETAIL2) */
                     pkg_common.generateuniquekey ('G'),
                     'DELIVERY',
                     'R',
                     sep_id,
                     bd_dgti, --  026SO
                     SYSDATE,
                     MIN (bd_datetime),
                     MAX (bd_datetime),
                     bd_status,
                     bd_conid,
                     bd_consolidation,
                     bd_prepaid,
                     bd_vsmscid,
                     COUNT (bdetail2.ROWID)     AS dgtic_count
            FROM     bdetail2,
                     setperiod
            WHERE        bd_datetime >= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_datetime < TRUNC (SYSDATE, 'MONTH')
                     AND sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_mapsid = 'R'
            GROUP BY sep_id,
                     bd_dgti,
                     bd_status,
                     bd_conid,
                     bd_consolidation,
                     bd_prepaid,
                     bd_vsmscid;

        recordsaffected := SQL%ROWCOUNT;

        UPDATE dgticonsol
        SET    dgtic_opkey =
                   (SELECT nbr_conopkey
                    FROM   numberrange
                    WHERE      nbr_code <= dgtic_dgti
                           AND nbr_code LIKE SUBSTR (dgtic_dgti, 1, 3) || '%'
                           AND nbr_code = SUBSTR (dgtic_dgti, 1, LENGTH (nbr_code))
                           AND ROWNUM <= 1)
        WHERE      dgtic_etid = 'DELIVERY'
               AND dgtic_esid = 'R'
               AND dgtic_sepid = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYYMM')
               AND dgtic_dgti IS NOT NULL;

        errorcode := 0;
        returnstatus := pkg_common.return_status_ok;

        RETURN;
    --    Exception
    --    When Others then
    --       ErrorCode := SQLCODE;
    --       ErrorMsg  := SQLERRM;
    --       ReturnStatus := 0;
    --       RecordsAffected := 0;

    END sp_cons_dgti;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_iwt (
        p_pact_id                               IN     VARCHAR2, -- 'IWT'    IW Consolidation SC Outgoing -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                               OUT NUMBER) --  039SO
    IS
        l_recordsaffected                       NUMBER; --  053SO
    BEGIN
        returnstatus := pkg_common.return_status_failure;

        UPDATE roconsolidation
        SET    roc_esid = 'D'
        WHERE      roc_sepid = TO_CHAR (TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'), 'YYYYMM')
               AND roc_esid = 'R'; --  069SO --  053SO

        INSERT INTO roconsolidation (
                        roc_id,
                        roc_etid,
                        roc_esid,
                        roc_date,
                        roc_sepid,
                        roc_fromdate,
                        roc_todate,
                        roc_consolidation,
                        roc_conid,
                        roc_tocid,
                        roc_status,
                        roc_iw,
                        roc_count,
                        roc_iot_internal,
                        roc_iot) --  069SO --  046SO
            SELECT /*+ NO_INDEX(BDETAIL2) */
                     pkg_common.generateuniquekey ('G'),
                     CASE
                         WHEN bd_cdrtid IS NULL
                         THEN
                             'SMS-GEN'
                         WHEN INSTR (bd_cdrtid, '-') > 0
                         THEN
                             bd_cdrtid
                         WHEN bd_cdrtid LIKE '10%'
                         THEN
                             'SMS-MO'
                         ELSE
                             'SMS-AO'
                     END,
                     'R',
                     SYSDATE,
                     sep_id,
                     MIN (bd_datetime),
                     MAX (bd_datetime),
                     bd_consolidation,
                     bd_conid,
                     bd_tocid,
                     bd_status,
                     bd_iw,
                     COUNT (*),
                     SUM (bd_iot_internal),
                     SUM (bd_iot) --  069SO --  046SO
            FROM     bdetail2,
                     setperiod
            WHERE        bd_datetime >= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_datetime < TRUNC (ADD_MONTHS (SYSDATE, -0), 'MONTH')
                     AND sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_mapsid = 'R'
            -- AND BD_NPI_B = '1'
            -- AND BD_PID_B = '0'
            -- AND BD_GENERATED = 0                                                     --  056SO
            -- AND BD_CDRTID <> 'SMS-HR'                                                --  069SO --  058SO
            -- AND BD_CDRTID <> 'SMS-HRON'                                              --  069SO
            GROUP BY sep_id,
                     sep_date1,
                     sep_date2,
                     CASE
                         WHEN bd_cdrtid IS NULL
                         THEN
                             'SMS-GEN'
                         WHEN INSTR (bd_cdrtid, '-') > 0
                         THEN
                             bd_cdrtid
                         WHEN bd_cdrtid LIKE '10%'
                         THEN
                             'SMS-MO'
                         ELSE
                             'SMS-AO'
                     END,
                     bd_consolidation,
                     bd_conid,
                     bd_tocid,
                     bd_status,
                     bd_iw;

        l_recordsaffected := SQL%ROWCOUNT; --  053SO

        INSERT INTO roconsolidation (
                        roc_id,
                        roc_etid,
                        roc_esid,
                        roc_date,
                        roc_sepid,
                        roc_fromdate,
                        roc_todate,
                        roc_consolidation,
                        roc_conid,
                        roc_tocid,
                        roc_status,
                        roc_iw,
                        roc_count,
                        roc_iot_internal,
                        roc_iot)
            SELECT /*+ NO_INDEX(BDETAIL7) */
                     pkg_common.generateuniquekey ('G'),
                     'SMSC-M2M',
                     'R',
                     SYSDATE,
                     sep_id,
                     MIN (bd_datetime),
                     MAX (bd_datetime),
                     bd_shortid,
                     bd_conid,
                     bd_tocid,
                     bd_status,
                     bd_iw,
                     COUNT (*),
                     SUM (bd_iot_internal),
                     SUM (bd_iot)
            FROM     bdetail7,
                     setperiod
            WHERE        bd_datetime >= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_datetime < TRUNC (ADD_MONTHS (SYSDATE, -0), 'MONTH')
                     AND sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_mapsid = 'R'
                     AND bd_msgtype = 'M'
                     AND bd_sinktype = '2'
                     AND NVL (bd_iw_dir, 'O') <> 'I' --  056SO
            GROUP BY sep_id,
                     sep_date1,
                     sep_date2,
                     bd_shortid,
                     bd_conid,
                     bd_tocid,
                     bd_status,
                     bd_iw;

        recordsaffected := l_recordsaffected + SQL%ROWCOUNT;
        errorcode := 0;
        returnstatus := pkg_common.return_status_ok;

        RETURN;
    END sp_cons_iwt;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_laa_mfgr (
        p_pact_id                               IN     VARCHAR2, -- 'LAT_MFGR'   SMS-LA monthly UFIH Tickets GlobalReply -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) --  039SO
    IS --  012SO
       -- do SMS Global Reply settlement for last month
       -- clear all MFLID charges
       -- clear all MFGR  charges
       -- insert one MFLID charge per LongID range (individual charge)                 --  068SO
       -- insert one MFGR charge per ShortID if one or more LongId is registered for it
        CURSOR clongid IS
            SELECT   longid_min,
                     longid_max,
                     longid_cnt,
                     long_shortid,
                     price,
                     max_conid                         AS con_id,
                     pscall                            AS con_pscall,
                     (SELECT c1.con_tarid
                      FROM   contract c1
                      WHERE  c1.con_id = max_conid)    AS con_tarid
            FROM     (SELECT   MIN (longid)                AS longid_min,
                               MAX (longid)                AS longid_max,
                               COUNT (DISTINCT longid)     AS longid_cnt,
                               long_shortid,
                               price,
                               MAX (conid)                 AS max_conid,
                               pscall
                      FROM     (SELECT   long_id                                                                                             AS longid,
                                         long_shortid,
                                         MAX (DECODE (c0.con_tarid,  'S', 0.0,  'P', 0.0,  'T', 0.0,  'X', 0.0,  'V', 0.0,  long_price))     AS price,
                                         c0.con_id                                                                                           AS conid,
                                         c0.con_pscall                                                                                       AS pscall
                                FROM     longid,
                                         contract c0
                                WHERE        long_shortid = c0.con_consol
                                         AND long_esid = 'M'
                                         AND long_datestart < TRUNC (SYSDATE, 'MONTH')
                                         AND NVL (long_dateend, SYSDATE) > ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1)
                                         AND c0.con_esid IN ('A',
                                                             'I')
                                         AND c0.con_etid = 'LAC'
                                         AND c0.con_datestart < TRUNC (SYSDATE, 'MONTH')
                                         AND NVL (c0.con_dateend, SYSDATE) > ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1)
                                GROUP BY c0.con_pscall,
                                         long_shortid,
                                         long_id,
                                         c0.con_id)
                      GROUP BY long_shortid,
                               price,
                               pscall)
            ORDER BY long_shortid ASC,
                     price DESC,
                     pscall DESC; --  072SO --  067SO

        clongidrow                              clongid%ROWTYPE;

        CURSOR cshortid IS
            SELECT   long_shortid,
                     price,
                     max_conid                         AS con_id,
                     pscall                            AS con_pscall,
                     (SELECT c1.con_tarid
                      FROM   contract c1
                      WHERE  c1.con_id = max_conid)    AS con_tarid
            FROM     (SELECT   long_shortid,
                               MAX (DECODE (con_tarid,  'S', 0.0,  'P', 0.0,  'T', 0.0,  'X', 0.0,  'V', 0.0,  con_mfgr))     AS price,
                               MAX (con_id)                                                                                   AS max_conid,
                               c0.con_pscall                                                                                  AS pscall
                      FROM     longid,
                               contract c0
                      WHERE        long_shortid = c0.con_consol
                               AND long_esid <> 'F'
                               AND long_esid IN ('M')
                               AND long_datestart < TRUNC (SYSDATE, 'MONTH')
                               AND NVL (long_dateend, SYSDATE) > ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1)
                               AND c0.con_esid IN ('A',
                                                   'I')
                               AND c0.con_etid = 'LAC'
                               AND c0.con_datestart < TRUNC (SYSDATE, 'MONTH')
                               AND NVL (c0.con_dateend, SYSDATE) > ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1)
                      GROUP BY long_shortid,
                               c0.con_pscall)
            ORDER BY long_shortid ASC; --  072SO

        cshortidrow                             cshortid%ROWTYPE;

        period_already_settled                  EXCEPTION; --  017SO

        l_order_pattern                         VARCHAR2 (10);
        l_period_id                             VARCHAR2 (10);
        l_last_short_id                         VARCHAR2 (10);
        l_settlement_date                       DATE;
        l_order                                 VARCHAR2 (20);
        l_comment                               setdetail.sed_comment%TYPE;

        x_period_id                             VARCHAR2 (6);
        x_set_id                                VARCHAR2 (10);
        x_sed_id                                VARCHAR2 (10);
        x_sed_pos                               NUMBER;
        x_errorcode                             NUMBER;
        x_errormsg                              VARCHAR2 (2000);
        x_returnstatus                          NUMBER;
        x_cdrcount                              NUMBER;
    BEGIN
        l_order_pattern := TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM') || '%'; -- period order prefix
        l_period_id := TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYYMM'); -- period code
        l_settlement_date := TRUNC (SYSDATE, 'MONTH') - 1; -- last day of period

        recordsaffected := 0;
        returnstatus := pkg_common.return_status_failure;

        SELECT COUNT (*)
        INTO   x_cdrcount
        FROM   setdetail
        WHERE      sed_order LIKE l_order_pattern
               AND sed_etid IN ('MFGRA',
                                'MFLIDA',
                                'MFGR',
                                'MFLID') --  019SO --  017SO
               AND sed_esid IN ('V') --  017SO
                                    ;

        IF x_cdrcount > 0
        THEN
            RAISE period_already_settled; --  017SO
        END IF;

        SELECT COUNT (*)
        INTO   x_cdrcount
        FROM   setdetail
        WHERE      sed_order LIKE l_order_pattern
               AND sed_etid IN ('MFGR',
                                'MFLID') --  019SO
               AND sed_esid IN ('A') --  019SO
                                    ;

        IF x_cdrcount > 0
        THEN
            RAISE period_already_settled; --  017SO
        END IF;

        DELETE FROM setdetail
        WHERE           sed_order LIKE l_order_pattern
                    AND sed_etid IN ('MFGRA',
                                     'MFLIDA',
                                     'MFGR',
                                     'MFLID') --  017SO
                    AND sed_esid IN ('A') --  017SO
                                         ;

        l_comment := 'SMS LongID monthly lease fee';

       <<loop_clongidrow>>
        FOR clongidrow IN clongid
        LOOP
            l_order := pkg_bdetail_settlement.nextavailableorder (clongidrow.con_pscall, l_settlement_date); --  067SO
            x_returnstatus := 1;
            pkg_bdetail_settlement.sp_add_setdetail_by_date (
                l_order, -- p_Date           IN varchar2,
                clongidrow.con_id, -- p_SET_CONID      IN varchar2,
                'SLA', -- p_SET_ETID       IN varchar2,
                0, -- p_SET_DEMO       IN number,
                'CHF', -- p_SET_CURRENCY   IN varchar2,
                NULL, -- p_SET_COMMENT    IN varchar2,
                'MFLIDA', -- p_SED_ETID       IN varchar2,            --  017SO
                clongidrow.price, -- p_SED_PRICE      IN float,
                clongidrow.longid_cnt, -- p_SED_QUANTITY   IN float,
                0.0, -- p_SED_DISCOUNT   IN float,
                'NA', -- p_SED_VATID      IN varchar2,
                0.0, -- p_SED_VATRATE    IN float,
                'ID' || clongidrow.long_shortid || '/MFLID' || clongidrow.longid_cnt, -- p_SED_DESC --  067SO
                l_order, -- p_SED_ORDER      IN varchar2,
                1, -- p_SED_VISIBLE    IN number,
                l_comment, -- p_SED_COMMENT    IN varchar2,
                0, -- p_SED_COUNT1     IN number,
                0, -- p_SED_COUNT2     IN number,
                clongidrow.con_pscall, -- p_SED_CHARGE     IN varchar2,
                p_boh_id, -- p_SED_BOHID      IN varchar2,
                NULL, -- p_SED_PMVID      IN varchar2,
                clongidrow.con_tarid, -- p_SED_TARID      IN varchar2,
                'A', -- p_SED_ESID       IN varchar2,            --  017SO
                NULL, -- p_SED_INT        IN varchar2,
                'U', -- p_SED_PREPAID    IN varchar2,
                0.00, -- p_SED_AMOUNTCU   IN float,               --  018SO
                0.00, -- p_SED_RETSHAREPV IN float,               --  018SO
                0.00, -- p_SED_RETSHAREMO IN float,               --  018SO
                TO_CHAR (clongidrow.longid_min), -- p_SED_LONGID_1     IN varchar2,   --  067SO
                TO_CHAR (clongidrow.longid_max), -- p_SED_LONGID_2     IN varchar2,   --  067SO
                x_period_id, -- p_SEP_ID         OUT varchar2,
                x_set_id, -- p_SET_ID         OUT varchar2,
                x_sed_id, -- p_SED_ID         OUT varchar2,
                x_sed_pos, -- p_SED_POS        OUT number,
                x_errorcode, -- ErrorCode        OUT number,
                x_errormsg, -- ErrorMsg         OUT varchar2,
                x_returnstatus -- ReturnStatus     IN OUT number
                              );
            recordsaffected := recordsaffected + 1;
        END LOOP loop_clongidrow;

        l_last_short_id := 'none';
        l_comment := 'SMS Global Reply monthly fee';

       <<loop_cshortidrow>>
        FOR cshortidrow IN cshortid
        LOOP
            IF cshortidrow.long_shortid <> l_last_short_id
            THEN
                l_order := pkg_bdetail_settlement.nextavailableorder (cshortidrow.con_pscall, l_settlement_date);

                x_returnstatus := 1;
                pkg_bdetail_settlement.sp_add_setdetail_by_date (
                    l_order, -- p_Date           IN varchar2,
                    cshortidrow.con_id, -- p_SET_CONID      IN varchar2,
                    'SLA', -- p_SET_ETID       IN varchar2,
                    0, -- p_SET_DEMO       IN number,
                    'CHF', -- p_SET_CURRENCY   IN varchar2,
                    NULL, -- p_SET_COMMENT    IN varchar2,
                    'MFGRA', -- p_SED_ETID       IN varchar2,        --  017SO
                    cshortidrow.price, -- p_SED_PRICE      IN float,
                    1, -- p_SED_QUANTITY   IN float,
                    0.0, -- p_SED_DISCOUNT   IN float,
                    'NA', -- p_SED_VATID      IN varchar2,
                    0.0, -- p_SED_VATRATE    IN float,
                    'ID' || cshortidrow.long_shortid || '/MFGR', -- p_SED_DESC       IN varchar2,  --  020SO --  017SO --  015SO
                    l_order, -- p_SED_ORDER      IN varchar2,
                    1, -- p_SED_VISIBLE    IN number,
                    l_comment, -- p_SED_COMMENT    IN varchar2,
                    0, -- p_SED_COUNT1     IN number,
                    0, -- p_SED_COUNT2     IN number,
                    cshortidrow.con_pscall, -- p_SED_CHARGE     IN varchar2,
                    p_boh_id, -- p_SED_BOHID      IN varchar2,
                    NULL, -- p_SED_PMVID      IN varchar2,
                    cshortidrow.con_tarid, -- p_SED_TARID      IN varchar2,
                    'A', -- p_SED_ESID       IN varchar2,        --  017SO
                    NULL, -- p_SED_INT        IN varchar2,
                    'U', -- p_SED_PREPAID    IN varchar2,
                    0.00, -- p_SED_AMOUNTCU   IN float,           --  018SO
                    0.00, -- p_SED_RETSHAREPV IN float,           --  018SO
                    0.00, -- p_SED_RETSHAREMO IN float,           --  018SO
                    NULL, -- p_SED_LONGID_1   IN varchar2,        --  067SO
                    NULL, -- p_SED_LONGID_2   IN varchar2,        --  067SO
                    x_period_id, -- p_SEP_ID         OUT varchar2,
                    x_set_id, -- p_SET_ID         OUT varchar2,
                    x_sed_id, -- p_SED_ID         OUT varchar2,
                    x_sed_pos, -- p_SED_POS        OUT number,
                    x_errorcode, -- ErrorCode        OUT number,
                    x_errormsg, -- ErrorMsg         OUT varchar2,
                    x_returnstatus -- ReturnStatus     IN OUT number
                                  );
                l_last_short_id := cshortidrow.long_shortid; --  015SO
                recordsaffected := recordsaffected + 1;
            END IF;
        END LOOP loop_cshortidrow;

        UPDATE setdetail
        SET    sed_desc =
                   (SELECT 'ID' || con_consol || '/MO' || TO_CHAR (sed_count2) || '/FN'     AS VALUE
                    FROM   contract
                    WHERE  con_id IN (SELECT set_conid
                                      FROM   settling
                                      WHERE  set_id = sed_setid))
        WHERE      sed_order LIKE l_order_pattern
               AND sed_etid IN ('MOFNA')
               AND sed_esid IN ('A',
                                'V'); --  021SO

        UPDATE setdetail
        SET    sed_desc =
                   (SELECT 'ID' || con_consol || '/MO' || TO_CHAR (sed_count2) || '/IW'     AS VALUE
                    FROM   contract
                    WHERE  con_id IN (SELECT set_conid
                                      FROM   settling
                                      WHERE  set_id = sed_setid))
        WHERE      sed_order LIKE l_order_pattern
               AND sed_etid IN ('MOIWSA')
               AND sed_esid IN ('A',
                                'V'); --  022SO  --  021SO

        errorcode := 0;
        returnstatus := pkg_common.return_status_ok;

        RETURN;
    EXCEPTION
        WHEN period_already_settled
        THEN
            errorcode := 0;
            errormsg := 'Cannot do SMS Global Reply monthly settlement twice for the same period.';
            returnstatus := 0;
            recordsaffected := 0;
    --    --                                                                              --  039SO
    --    When Others then
    --       ErrorCode := SQLCODE;
    --       ErrorMsg  := SQLERRM;
    --       ReturnStatus := 0;
    --       RecordsAffected := 0;
    END sp_cons_laa_mfgr;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lam_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LATMCC_SMS'     SMS-LA MCC UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  033SO
        l_gart                                  PLS_INTEGER;
    BEGIN
        returnstatus := pkg_common.return_status_failure; --  040SO
        recordsaffected := 0; --  040SO

        l_gart := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'GART'));

        pkg_bdetail_settlement.sp_lam_mcc (
            p_pac_id, -- IN varchar2,
            p_boh_id, -- IN varchar2,
            'SLA', --p_SET_ETID  -- IN varchar2,   -- SLA or MLA
            l_gart, --p_Gart      -- In Number,      --016SO
            recordsaffected, -- OUT number,
            errorcode, -- OUT number,
            errormsg, -- OUT varchar2,
            returnstatus -- OUT number
                        );
    END sp_cons_lam_sms;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lapmcc_sms (
        p_pact_id                               IN     VARCHAR2, -- 'LAPMCC_SMS'     SMS-LA MCC Preparation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) --  039SO
    IS -- 016SO
    -- get a list of MMS LA contracts which can have a minimum charge
    -- per pseudo call number, the contracts with the top overall min charge are choosen
    -- more than one contract can be returned, if they have equal weighted minimum charge
    -- this is taken care of in the processing of the result
    BEGIN
        returnstatus := pkg_common.return_status_failure; --  040SO
        recordsaffected := 0; --  040SO

        pkg_bdetail_settlement.sp_lapmcc (
            p_pact_id, -- IN varchar2,
            p_boh_id, -- IN varchar2,
            'SLA', -- IN varchar2,   -- SLA or MLA                     --  051SOa
            recordsaffected, -- OUT number,
            errorcode, -- OUT number,
            errormsg, -- OUT varchar2,
            returnstatus -- IN OUT number
                        );
    END sp_cons_lapmcc_sms;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lat_mfgr (
        p_pac_id                                IN     VARCHAR2, -- 'LAT_MFGR'   SMS-LA monthly UFIH Tickets GlobalReply
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  034SO Consolidate SMS-Global reply monthly UFIH tickets from accumulated settlement details
        l_gart                                  PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
    BEGIN
        returnstatus := pkg_common.return_status_failure;
        recordsaffected := 0;

        l_gart := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'GART'));
        
        -- mark rows for processing
        UPDATE setdetail
        SET    sed_esid = 'P',
               sed_gohid = p_boh_id
        WHERE      sed_esid = 'A'
               AND sed_order > TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1), 'YYYY-MM-DD') --  034SO
               AND sed_order < TO_CHAR (TRUNC (SYSDATE, 'MONTH'), 'YYYY-MM-DD') --  034SO
               AND sed_etid IN ('MFGRA',
                                'MFLIDA') --  034SO
               AND sed_setid IN (SELECT set_id
                                 FROM   settling
                                 WHERE  set_etid IN ('SLA'));

        l_marked_count := SQL%ROWCOUNT;

        IF l_marked_count = 0
        THEN
            returnstatus := pkg_common.return_status_ok; --  040SO
        ELSE -- l_marked_count <> 0
            pkg_bdetail_settlement.sp_lat_cdr (
                p_boh_id, -- p_BD_BOHID      In      Varchar2,
                'SLA', -- p_SET_ETID      IN      varchar2,
                l_gart, -- p_Gart          In      Number,
                0, -- p_MinAge        In      Number,  --  034SO
                61, -- p_MaxAge        In      Number,  --  034SO
                errorcode, -- ErrorCode       Out     Number,
                errormsg, -- ErrorMsg        Out     Varchar2,
                recordsaffected -- RecordsAffected Out     Number
                               );

            IF recordsaffected = l_marked_count
            THEN
                -- set marked rows to valid
                UPDATE setdetail
                SET    sed_esid = 'V'
                WHERE      sed_esid = 'P'
                       AND sed_gohid = p_boh_id
                       AND sed_order > TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1), 'YYYY-MM-DD') --  034SO
                       AND sed_order < TO_CHAR (TRUNC (SYSDATE, 'MONTH'), 'YYYY-MM-DD') --  034SO
                                                                                       ;

                l_marked_count := SQL%ROWCOUNT;

                UPDATE boheader
                SET    (
                           boh_datefc,
                           boh_datelc) =
                           (SELECT MIN (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS')),
                                   MAX (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS'))
                            FROM   setdetail
                            WHERE      sed_esid = 'V'
                                   AND sed_gohid = p_boh_id
                                   AND sed_order > TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1), 'YYYY-MM-DD') --  034SO
                                   AND sed_order < TO_CHAR (TRUNC (SYSDATE, 'MONTH'), 'YYYY-MM-DD') --  034SO
                                                                                                   )
                WHERE  boh_id = p_boh_id;

                returnstatus := pkg_common.return_status_ok;
            ELSE -- RecordsAffected <> l_marked_count
                ROLLBACK;
                errormsg := 'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')'; --  044SO
                pkg_common.insert_warning (
                    'SMS-LA SETTLEMENT',
                    'PKG_BDETAIL_SETTLEMENT.SP_CONS_LAT_MFGR',
                    'PROCESSING ERROR',
                    errormsg,
                    NULL,
                    p_boh_id);
            END IF; -- RecordsAffected = l_marked_count
        END IF; -- l_marked_count > 0
    END sp_cons_lat_mfgr;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lat_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LAT_SMS'    SMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  031SO Consolidate SMS-LA daily UFIH tickets from accumulated settlement details
        l_min_age                               PLS_INTEGER;
        l_max_age                               PLS_INTEGER;
        l_gart                                  PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
    BEGIN
        returnstatus := pkg_common.return_status_failure;

        recordsaffected := 0;

        l_min_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MINAGE'));
        l_max_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MAXAGE'));
        l_gart := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'GART'));

        -- mark rows for processing
        UPDATE setdetail
        SET    sed_esid = 'P',
               sed_gohid = p_boh_id
        WHERE      sed_esid = 'A'
               AND sed_order > TO_CHAR (SYSDATE - l_max_age, 'YYYY-MM-DD')
               AND sed_order < TO_CHAR (SYSDATE - l_min_age, 'YYYY-MM-DD')
               AND sed_etid IN ('CDRA',
                                'PAGA',
                                'MOFNA') --  071SO --  060SO --  034SO remove 'MFGRA','MFLIDA'
               AND sed_setid IN (SELECT set_id
                                 FROM   settling
                                 WHERE  set_etid IN ('SLA'));

        l_marked_count := SQL%ROWCOUNT;

        IF l_marked_count = 0
        THEN
            returnstatus := pkg_common.return_status_ok; --  040SO
        ELSE -- l_marked_count <> 0
            pkg_bdetail_settlement.sp_lat_cdr (
                p_boh_id, -- p_BD_BOHID      In      Varchar2,
                'SLA', -- p_SET_ETID      IN      varchar2,
                l_gart, -- p_Gart          In      Number,
                l_min_age, -- p_MinAge        In      Number,
                l_max_age, -- p_MaxAge        In      Number,
                errorcode, -- ErrorCode       Out     Number,
                errormsg, -- ErrorMsg        Out     Varchar2,
                recordsaffected -- RecordsAffected Out     Number
                               );

            IF recordsaffected = l_marked_count
            THEN
                -- set marked rows to valid
                UPDATE setdetail
                SET    sed_esid = 'V'
                WHERE      sed_esid = 'P'
                       AND sed_gohid = p_boh_id
                       AND sed_order > TO_CHAR (SYSDATE - l_max_age, 'YYYY-MM-DD')
                       AND sed_order < TO_CHAR (SYSDATE - l_min_age, 'YYYY-MM-DD');

                l_marked_count := SQL%ROWCOUNT;

                UPDATE boheader
                SET    (
                           boh_datefc,
                           boh_datelc) =
                           (SELECT MIN (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS')),
                                   MAX (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS'))
                            FROM   setdetail
                            WHERE      sed_esid = 'V'
                                   AND sed_gohid = p_boh_id
                                   AND sed_order > TO_CHAR (SYSDATE - l_max_age, 'YYYY-MM-DD')
                                   AND sed_order < TO_CHAR (SYSDATE - l_min_age, 'YYYY-MM-DD'))
                WHERE  boh_id = p_boh_id;

                returnstatus := pkg_common.return_status_ok;
            ELSE -- RecordsAffected <> l_marked_count
                ROLLBACK;
                errormsg := 'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')'; --  044SO
                pkg_common.insert_warning (
                    'SMS-LA SETTLEMENT',
                    'PKG_BDETAIL_SETTLEMENT.SP_CONS_LAT_SMS',
                    'PROCESSING ERROR',
                    errormsg, --  044SO
                    NULL,
                    p_boh_id);
            END IF; -- RecordsAffected = l_marked_count
        END IF; -- l_marked_count <> 0
    END sp_cons_lat_sms;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lit_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LIT_SMS'    SMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  037SO Consolidate SMS-LA daily IW UFIH tickets from accumulated settlement details
        l_min_age                               PLS_INTEGER;
        l_max_age                               PLS_INTEGER;
        l_gart                                  PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
    BEGIN
        returnstatus := pkg_common.return_status_failure;
        recordsaffected := 0;

        l_min_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MINAGE'));
        l_max_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MAXAGE'));
        l_gart := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'GART'));

        -- mark rows for processing
        UPDATE setdetail
        SET    sed_esid = 'P',
               sed_gohid = p_boh_id
        WHERE      sed_esid = 'A'
               AND sed_order > TO_CHAR (SYSDATE - l_max_age, 'YYYY-MM-DD')
               AND sed_order < TO_CHAR (SYSDATE - l_min_age, 'YYYY-MM-DD')
               AND sed_etid IN ('IOTLACA',
                                'MOIWSA') --  042SO
               AND sed_setid IN (SELECT set_id
                                 FROM   settling
                                 WHERE  set_etid IN ('SLA'));

        l_marked_count := SQL%ROWCOUNT;

        IF l_marked_count = 0
        THEN
            returnstatus := pkg_common.return_status_ok; --  040SO
        ELSE
            pkg_bdetail_settlement.sp_lit_cdr (
                p_boh_id, -- p_BD_BOHID      In      Varchar2,
                'SLA', -- p_SET_ETID      IN      varchar2,
                l_gart, -- p_Gart          In      Number,
                l_min_age, -- p_MinAge        In      Number,
                l_max_age, -- p_MaxAge        In      Number,
                errorcode, -- ErrorCode       Out     Number,
                errormsg, -- ErrorMsg        Out     Varchar2,
                recordsaffected -- RecordsAffected Out     Number
                               );

            IF recordsaffected = l_marked_count
            THEN
                -- set marked rows to valid
                UPDATE setdetail
                SET    sed_esid = 'V'
                WHERE      sed_esid = 'P'
                       AND sed_gohid = p_boh_id
                       AND sed_order > TO_CHAR (SYSDATE - l_max_age, 'YYYY-MM-DD')
                       AND sed_order < TO_CHAR (SYSDATE - l_min_age, 'YYYY-MM-DD');

                l_marked_count := SQL%ROWCOUNT;

                UPDATE boheader
                SET    (
                           boh_datefc,
                           boh_datelc) =
                           (SELECT MIN (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS')),
                                   MAX (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS'))
                            FROM   setdetail
                            WHERE      sed_esid = 'V'
                                   AND sed_gohid = p_boh_id
                                   AND sed_order > TO_CHAR (SYSDATE - l_max_age, 'YYYY-MM-DD')
                                   AND sed_order < TO_CHAR (SYSDATE - l_min_age, 'YYYY-MM-DD'))
                WHERE  boh_id = p_boh_id;

                returnstatus := pkg_common.return_status_ok;
            ELSE -- RecordsAffected <> l_marked_count
                ROLLBACK;
                errormsg := 'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')'; --  044SO
                pkg_common.insert_warning (
                    'SMS-LA SETTLEMENT',
                    'PKG_BDETAIL_SETTLEMENT.SP_CONS_LIT_SMS',
                    'PROCESSING ERROR',
                    errormsg,
                    NULL,
                    p_boh_id);
            END IF; -- RecordsAffected = l_marked_count
        END IF; -- l_marked_count > 0
    END sp_cons_lit_sms;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_ogti (
        p_pact_id                               IN     VARCHAR2, -- 'OGTI'   OGTI consolidation -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                               OUT NUMBER) --  039SO
    IS
    BEGIN
        returnstatus := pkg_common.return_status_failure; --  040SO
        recordsaffected := 0; --  040SO

        UPDATE ogticonsol
        SET    ogtic_esid = 'D'
        WHERE      ogtic_sepid = TO_CHAR (TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'), 'YYYYMM')
               AND ogtic_etid = 'SUBMIT'
               AND ogtic_esid = 'R';

        INSERT INTO ogticonsol (
                        ogtic_id,
                        ogtic_etid,
                        ogtic_esid,
                        ogtic_sepid,
                        ogtic_ogti,
                        ogtic_date,
                        ogtic_fromdate,
                        ogtic_todate,
                        ogtic_status,
                        ogtic_conid,
                        ogtic_consolidation,
                        ogtic_prepaid,
                        ogtic_vsmscid,
                        ogtic_count)
            SELECT /*+ NO_INDEX(BDETAIL1) */
                     pkg_common.generateuniquekey ('G'),
                     'SUBMIT',
                     'R',
                     sep_id,
                     bd_ogti, --  026SO
                     SYSDATE,
                     MIN (bd_datetime),
                     MAX (bd_datetime),
                     bd_status,
                     bd_conid,
                     bd_consolidation,
                     bd_prepaid,
                     bd_vsmscid,
                     COUNT (bdetail1.ROWID)     AS ogtic_count
            FROM     bdetail1,
                     setperiod
            WHERE        bd_datetime >= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_datetime < TRUNC (SYSDATE, 'MONTH')
                     AND sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_mapsid = 'R'
            GROUP BY sep_id,
                     bd_ogti,
                     bd_status,
                     bd_conid,
                     bd_consolidation,
                     bd_prepaid,
                     bd_vsmscid;

        recordsaffected := SQL%ROWCOUNT;

        UPDATE ogticonsol
        SET    ogtic_opkey =
                   (SELECT nbr_conopkey
                    FROM   numberrange
                    WHERE      nbr_code <= ogtic_ogti
                           AND nbr_code LIKE SUBSTR (ogtic_ogti, 1, 3) || '%'
                           AND nbr_code = SUBSTR (ogtic_ogti, 1, LENGTH (nbr_code))
                           AND ROWNUM <= 1)
        WHERE      ogtic_etid = 'SUBMIT'
               AND ogtic_esid = 'R'
               AND ogtic_sepid = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYYMM')
               AND ogtic_ogti IS NOT NULL;

        errorcode := 0;
        returnstatus := pkg_common.return_status_ok; --  050SO --  040SO

        RETURN;
    --    Exception
    --    When Others then
    --       ErrorCode := SQLCODE;
    --       ErrorMsg  := SQLERRM;
    --       ReturnStatus := 0;
    --       RecordsAffected := 0;

    END sp_cons_ogti;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_smsc (
        p_pact_id                               IN     VARCHAR2, -- 'SMSC'   SMSC Consolidation -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                               OUT NUMBER) --  039SO
    IS
    BEGIN
        UPDATE bdconsolidation
        SET    bdc_esid = 'D'
        WHERE      bdc_sepid = TO_CHAR (TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'), 'YYYYMM')
               AND bdc_etid = 'SMSC-RAW'
               AND bdc_esid = 'R'; -- 001SO

        INSERT INTO bdconsolidation (
                        bdc_id,
                        bdc_etid,
                        bdc_esid,
                        bdc_date,
                        bdc_sepid,
                        bdc_fromdate,
                        bdc_todate,
                        bdc_consolidation,
                        bdc_conid,
                        bdc_tarid,
                        bdc_vsmscid,
                        bdc_npi_a,
                        bdc_pid_a,
                        bdc_ton_a,
                        bdc_npi_b,
                        bdc_pid_b,
                        bdc_ton_b,
                        bdc_prepaid,
                        bdc_count,
                        bdc_amountcu,
                        bdc_retsharepv,
                        bdc_retsharemo,
                        bdc_int)
            SELECT /*+ NO_INDEX(BDETAIL1) */
                     pkg_common.generateuniquekey ('G'),
                     'SMSC-RAW',
                     'R',
                     SYSDATE,
                     sep_id,
                     MIN (bd_datetime),
                     MAX (bd_datetime),
                     bd_consolidation,
                     bd_conid,
                     bd_tarid,
                     bd_vsmscid,
                     bd_npi_a,
                     bd_pid_a,
                     bd_ton_a,
                     bd_npi_b,
                     bd_pid_b,
                     bd_ton_b,
                     bd_prepaid,
                     COUNT (bdetail1.ROWID)     AS bdc_count,
                     SUM (bd_amountcu),
                     0.00,
                     0.00,
                     bd_int --  061SO
            FROM     bdetail1,
                     setperiod
            WHERE        bd_datetime >= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_datetime < TRUNC (SYSDATE, 'MONTH')
                     AND sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND bd_mapsid = 'R'
            GROUP BY sep_id,
                     sep_date1,
                     sep_date2,
                     bd_consolidation,
                     bd_conid,
                     bd_tarid,
                     bd_vsmscid,
                     bd_npi_a,
                     bd_ton_a,
                     bd_pid_a,
                     bd_ton_b,
                     bd_npi_b,
                     bd_pid_b,
                     bd_prepaid,
                     bd_int;

        recordsaffected := SQL%ROWCOUNT;
        errorcode := 0;
        returnstatus := 1;
        RETURN;
    --    Exception
    --    When Others then
    --       ErrorCode := SQLCODE;
    --       ErrorMsg  := SQLERRM;
    --       ReturnStatus := 0;
    --       RecordsAffected := 0;
    END sp_cons_smsc;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_laa_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LAA_SMS'    SMS-LA Accumulation
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  028SO        Accumulate SMS-LA submit CDRs as a first step in SMS-LA settlement
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_PACSID31) */
                   'dummy'
            FROM   bdetail1
            WHERE      bd_pacsid3 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= 1; --  055SO

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

        l_max_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MAXAGE'));
        l_batch_count := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'BATCHCOUNT'));

        l_dummy := NULL;

        OPEN ccheckcandidate (l_max_age);

        FETCH ccheckcandidate INTO l_dummy;

        CLOSE ccheckcandidate;

        IF l_dummy IS NOT NULL
        THEN
            pkg_common_packing.insert_boheader_sptry (p_pac_id, p_boh_id);

            -- mark rows for processing
            UPDATE /*+ INDEX(BDETAIL1 IDX_BD_PACSID31) */
                   bdetail1
            SET    bd_bohid3 = p_boh_id,
                   bd_pacsid3 = 'P'
            WHERE      bd_pacsid3 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= l_batch_count;

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_laa_sms_accu (
                    l_marked_count,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected);

                IF recordsaffected = l_marked_count
                THEN
                    -- mark rows as processed
                    UPDATE bdetail1
                    SET    bd_pacsid3 = 'D'
                    WHERE      bd_bohid3 = p_boh_id
                           AND bd_pacsid3 = 'P'
                           AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO --  041SO
                                                                         ;

                    l_marked_count := SQL%ROWCOUNT;

                    UPDATE boheader
                    SET    (
                               boh_datefc,
                               boh_datelc) =
                               (SELECT MIN (bd_datetime),
                                       MAX (bd_datetime)
                                FROM   bdetail1
                                WHERE      bd_bohid3 = p_boh_id
                                       AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO --  041SO
                                                                                     )
                    WHERE  boh_id = p_boh_id;
                ELSE
                    ROLLBACK;
                    pkg_common.insert_warning (
                        'SMS-LA SETTLEMENT',
                        'PKG_BDETAIL_SETTLEMENT.SP_TRY_LAA_SMS',
                        'PROCESSING ERROR',
                        'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')',
                        NULL,
                        p_boh_id);
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    --    --  --  032SO
    --        when PKG_COMMON_PACKING.EXCP_STATISTICS_FAILURE then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_STATISTICS_FAILURE;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_STATISTICS_FAILURE;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when PKG_COMMON_PACKING.EXCP_WORKFLOW_ABORT then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_WORKFLOW_ABORT;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_WORKFLOW_ABORT;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when Others then
    --            ErrorCode := SqlCode;
    --            ErrorMsg  := SqlErrM;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            RecordsAffected := 0;
    --            ROLLBACK;

    END sp_try_laa_sms;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_lia_rsgr (
        p_pac_id                                IN     VARCHAR2, -- 'LIA_RSGR'   SMS-LA IW Accumulation
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  038SO        Accumulate SMS-LA IW Revenue Share CDRs as a first step in SMS-LA IW settlement for these CDRs
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_PACSID32) */
                   'dummy'
            FROM   bdetail2
            WHERE      bd_pacsid3 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_cdrtid IN ('SMS-HR',
                                     'SMS-HRON') --  066SO
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= 1;

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

        l_max_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MAXAGE'));
        l_batch_count := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'BATCHCOUNT'));

        l_dummy := NULL;

        OPEN ccheckcandidate (l_max_age);

        FETCH ccheckcandidate INTO l_dummy;

        CLOSE ccheckcandidate;

        IF l_dummy IS NOT NULL
        THEN
            pkg_common_packing.insert_boheader_sptry (p_pac_id, p_boh_id);

            -- mark rows for processing
            UPDATE /*+ INDEX(BDETAIL2 IDX_BD_PACSID32) */
                   bdetail2
            SET    bd_bohid3 = p_boh_id,
                   bd_pacsid3 = 'P',
                   bd_iot =
                       DECODE (
                           bd_tarid,
                           'P', 0.0,
                           'Q', 0.0,
                           'R', 0.0,
                           'S', 0.0,
                           'T', 0.0,
                           'X', 0.0,
                           'V', 0.0,
                           'i', 0.0,
                           (SELECT 0.0 - NVL (con_iwrs, tar_iwrs_def) * NVL (pkg_bdetail_common.contract_iot_chf (bd_tocid, 'TERM', 'SMS', bd_datetime), 0.0) --  051SO
                            FROM   contract,
                                   tariff
                            WHERE      con_id = bd_conid --  048SO was BD_TOCID
                                   AND tar_id = con_tarid)), --  057SO
                   bd_iot_internal =
                       (SELECT 0.0 - NVL (con_iwrs, tar_iwrs_def) * NVL (pkg_bdetail_common.contract_iot_chf (bd_tocid, 'TERM', 'SMS', bd_datetime), 0.0)
                        FROM   contract,
                               tariff
                        WHERE      con_id = bd_conid --  048SO was BD_TOCID
                               AND tar_id = con_tarid)
            WHERE      bd_pacsid3 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_cdrtid IN ('SMS-HR',
                                     'SMS-HRON') --  066SO
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= l_batch_count;

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_lia_rsgr_accu (
                    l_marked_count,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected);

                IF recordsaffected >= l_marked_count
                THEN --  066SO exact records not available
                    -- mark rows as processed
                    UPDATE bdetail2
                    SET    bd_pacsid3 = 'D'
                    WHERE      bd_bohid3 = p_boh_id
                           AND bd_pacsid3 = 'P'
                           AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO --  041SO
                                                                         ;

                    l_marked_count := SQL%ROWCOUNT;

                    UPDATE boheader
                    SET    (
                               boh_datefc,
                               boh_datelc) =
                               (SELECT MIN (bd_datetime),
                                       MAX (bd_datetime)
                                FROM   bdetail2
                                WHERE      bd_bohid3 = p_boh_id
                                       AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO --  041SO
                                                                                     )
                    WHERE  boh_id = p_boh_id;
                ELSE
                    ROLLBACK;
                    pkg_common.insert_warning (
                        'SMS-LA IW SETTLEMENT',
                        'PKG_BDETAIL_SETTLEMENT.SP_TRY_LIA_RSGR',
                        'PROCESSING ERROR',
                        'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')',
                        NULL,
                        p_boh_id);
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    --    --  --  032SO
    --        when PKG_COMMON_PACKING.EXCP_STATISTICS_FAILURE then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_STATISTICS_FAILURE;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_STATISTICS_FAILURE;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when PKG_COMMON_PACKING.EXCP_WORKFLOW_ABORT then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_WORKFLOW_ABORT;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_WORKFLOW_ABORT;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when Others then
    --            ErrorCode := SqlCode;
    --            ErrorMsg  := SqlErrM;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            RecordsAffected := 0;
    --            ROLLBACK;

    END sp_try_lia_rsgr;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_lia_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LIA_SMS'    SMS-LA IW Accumulation
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  036SO        Accumulate SMS-LA IW outgoing CDRs as a first step in SMS-LA IW settlement
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_PACSID22) */
                   'dummy'
            FROM   bdetail2
            WHERE      bd_pacsid2 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= 1;

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

        l_max_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MAXAGE'));
        l_batch_count := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'BATCHCOUNT'));

        l_dummy := NULL;

        OPEN ccheckcandidate (l_max_age);

        FETCH ccheckcandidate INTO l_dummy;

        CLOSE ccheckcandidate;

        IF l_dummy IS NOT NULL
        THEN
            pkg_common_packing.insert_boheader_sptry (p_pac_id, p_boh_id);

            -- mark rows for processing
            UPDATE /*+ INDEX(BDETAIL2 IDX_BD_PACSID22) */
                   bdetail2
            SET    bd_bohid2 = p_boh_id,
                   bd_pacsid2 = 'P',
                   bd_iot =
                       DECODE (
                           bd_tarid,
                           'P', 0.0,
                           'Q', 0.0,
                           'R', 0.0,
                           'S', 0.0,
                           'T', 0.0,
                           'X', 0.0,
                           'V', 0.0,
                           'i', 0.0,
                           NVL (pkg_bdetail_common.contract_iot_chf (bd_tocid, 'ORIG', 'SMS', bd_datetime), 0.00)), --  057SO --  051SO --  045SO
                   bd_iot_internal = NVL (pkg_bdetail_common.contract_iot_chf (bd_tocid, 'ORIG', 'SMS', bd_datetime), 0.00) --  045SO
            WHERE      bd_pacsid2 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= l_batch_count;

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_lia_sms_accu (
                    l_marked_count,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected);

                IF recordsaffected = l_marked_count
                THEN
                    -- mark rows as processed
                    UPDATE bdetail2
                    SET    bd_pacsid2 = 'D'
                    WHERE      bd_bohid2 = p_boh_id
                           AND bd_pacsid2 = 'P'
                           AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO --  041SO
                                                                         ;

                    l_marked_count := SQL%ROWCOUNT;

                    UPDATE boheader
                    SET    (
                               boh_datefc,
                               boh_datelc) =
                               (SELECT MIN (bd_datetime),
                                       MAX (bd_datetime)
                                FROM   bdetail2
                                WHERE      bd_bohid2 = p_boh_id
                                       AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO --  041SO
                                                                                     )
                    WHERE  boh_id = p_boh_id;
                ELSE
                    ROLLBACK;
                    pkg_common.insert_warning (
                        'SMS-LA IW SETTLEMENT',
                        'PKG_BDETAIL_SETTLEMENT.SP_TRY_LIA_SMS',
                        'PROCESSING ERROR',
                        'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')',
                        NULL,
                        p_boh_id);
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    --    --  --  032SO
    --        when PKG_COMMON_PACKING.EXCP_STATISTICS_FAILURE then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_STATISTICS_FAILURE;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_STATISTICS_FAILURE;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when PKG_COMMON_PACKING.EXCP_WORKFLOW_ABORT then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_WORKFLOW_ABORT;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_WORKFLOW_ABORT;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when Others then
    --            ErrorCode := SqlCode;
    --            ErrorMsg  := SqlErrM;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            RecordsAffected := 0;
    --            ROLLBACK;

    END sp_try_lia_sms;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_smsccu (
        p_pac_id                                IN     VARCHAR2, -- 'SMSCCU'     SMSC COUNTER UPDATE
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  025SO
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_PACSID21) */
                   'dummy'
            FROM   bdetail2
            WHERE      bd_mapsid = 'R'
                   AND ROWNUM <= 1
                   AND bd_cdrtid = 'SMS-HR'
                   AND bd_pacsid1 = 'S'
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE + 3 / 24; --  055SO

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

        l_max_age := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'MAXAGE'));
        l_batch_count := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'BATCHCOUNT'));

        l_dummy := NULL;

        OPEN ccheckcandidate (l_max_age);

        FETCH ccheckcandidate INTO l_dummy;

        CLOSE ccheckcandidate;

        IF l_dummy IS NOT NULL
        THEN
            pkg_common_packing.insert_boheader_sptry (p_pac_id, p_boh_id);

            -- mark rows for processing
            UPDATE /*+ INDEX(BDETAIL2 IDX_BD_PACSID21) */
                   bdetail2
            SET    bd_bohid1 = p_boh_id,
                   bd_pacsid1 = 'P'
            WHERE      bd_mapsid = 'R'
                   AND ROWNUM <= l_batch_count
                   AND bd_cdrtid = 'SMS-HR'
                   AND bd_pacsid1 = 'S'
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE; --  055SO

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_smsccu_update (
                    l_marked_count,
                    NULL,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected); --  055SO

                IF recordsaffected = l_marked_count
                THEN
                    -- update state after successful counting                       --  027SO
                    UPDATE /*+ INDEX(BDETAIL2 IDX_BD_BOHID21) */
                           bdetail2
                    SET    bd_pacsid1 = 'D'
                    WHERE      bd_bohid1 = p_boh_id
                           AND bd_pacsid1 = 'P'
                           AND bd_datetime > SYSDATE - l_max_age - 1 / 24 --  043SO
                                                                         ;

                    l_marked_count := SQL%ROWCOUNT;
                ELSE
                    ROLLBACK;
                    pkg_common.insert_warning (
                        'SC TERMINATING SMS IW SETTLEMENT',
                        'PKG_BDETAIL_SMSC.SP_TRY_SMSCCU',
                        'PROCESSING ERROR',
                        'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')',
                        NULL,
                        p_boh_id);
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    --        when PKG_COMMON_PACKING.EXCP_STATISTICS_FAILURE then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_STATISTICS_FAILURE;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_STATISTICS_FAILURE;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when PKG_COMMON_PACKING.EXCP_WORKFLOW_ABORT then
    --            ErrorCode := PKG_COMMON_PACKING.ENO_WORKFLOW_ABORT;
    --            ErrorMsg := PKG_COMMON_PACKING.EDESC_WORKFLOW_ABORT;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            ROLLBACK;
    --        when Others then
    --            ErrorCode := SqlCode;
    --            ErrorMsg  := SqlErrM;
    --            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            RecordsAffected := 0;
    --            ROLLBACK;
    END sp_try_smsccu;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_laa_sms_accu (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS --  028SO
        CURSOR c1 IS --  042SO
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BOHID31) */
                     TRUNC (bd_datetime)                                                          AS posdatetime,
                     con_pscall                                                                   AS posmsisdn,
                     bd_conid                                                                     AS posconid,
                     bd_consolidation                                                             AS posconsolidation,
                     con_tarid                                                                    AS postarid,
                     NVL (con_hdgroup, 0)                                                         AS poshdgroup,
                     DECODE (bd_cdrtid,  'SMS-HR', '1',  'SMS-HRON', '0',  NVL (bd_int, '0'))     AS posinternational,
                     DECODE (bd_cdrtid,  'SMS-HR', 'MOFNA',  'PAGER-EXT', 'PAGA',  'CDRA')        AS possetdetailtype, --  070SO --  059SO
                     'U'                                                                          AS posprepaid, --  059SO
                     DECODE (bd_cdrtid, 'SMS-HR', bd_msisdn_b, NULL)                              AS poslongid,
                     COUNT (*)                                                                    AS cdrcount,
                     SUM (DECODE (bd_orig_esme_id, bd_consolidation, 0, 1))                       AS cdrcountmo, --  065SO
                     SUM (DECODE (bd_orig_esme_id, bd_consolidation, 1, 0))                       AS cdrcountmt, --  065SO
                     SUM (NVL (bd_amounttr, 0.0))                                                 AS price, --  061SO
                     SUM (NVL (bd_amountcu, 0.0))                                                 AS amountcu,
                     0.00                                                                         AS revenuesharela, --  061SO
                     0.00                                                                         AS revenueshareop --  061SO
            FROM     bdetail1,
                     contract
            WHERE        bd_conid = con_id
                     AND bd_bohid3 = p_bd_bohid --  042SO
                     AND bd_datetime > SYSDATE - p_maxage - 3 / 24 --  042SO
                     AND bd_datetime < SYSDATE + 3 / 24
            GROUP BY TRUNC (bd_datetime), -- PosDATETIME  --  029SO
                     con_pscall, -- PosMSISDN
                     bd_conid, -- PosConId
                     bd_consolidation, -- PosCONSOLIDATION
                     con_tarid, -- PosTarId
                     NVL (con_hdgroup, 0), -- PosHdGroup
                     DECODE (bd_cdrtid,  'SMS-HR', '1',  'SMS-HRON', '0',  NVL (bd_int, '0')), -- PosInternational --  063SO
                     DECODE (bd_cdrtid,  'SMS-HR', 'MOFNA',  'PAGER-EXT', 'PAGA',  'CDRA'), -- PosSetDetailType --  070SO --  059SO
                     DECODE (bd_cdrtid, 'SMS-HR', bd_msisdn_b, NULL) -- PosLongId
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC,
                     poshdgroup ASC,
                     posinternational ASC,
                     possetdetailtype ASC,
                     poslongid ASC;

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        recordsaffected := 0;

        FOR c1_rec IN c1
        LOOP --  042SO
            pkg_bdetail_settlement.sp_add_setdetail (
                'SLA', -- p_SET_ETID       IN varchar2,
                c1_rec.possetdetailtype, -- p_SED_ETID       IN varchar2,
                c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                c1_rec.posdatetime, -- p_Date           IN DATE,
                c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                c1_rec.posinternational, -- p_SED_INT        IN varchar2,
                c1_rec.posprepaid, -- p_SED_PREPAID    IN varchar2,
                c1_rec.price - c1_rec.revenuesharela, -- p_SED_PRICE      IN float,
                c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                c1_rec.poslongid, -- p_SED_LONGID     IN varchar2,
                c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                'accumulating', -- p_SED_DESC       IN varchar2,
                0, -- C1_Rec.PosGart,                      -- p_GART           IN varchar2,
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            IF l_returnstatus = 1
            THEN
                recordsaffected := recordsaffected + c1_rec.cdrcount; --  042SO
            END IF;
        END LOOP;

        RETURN;
    --    --  --  032SO
    --    Exception
    --      When Others Then
    --          ErrorCode := SqlCode;
    --          ErrorMsg  := SqlErrM;
    --          RecordsAffected := 0;

    END sp_laa_sms_accu;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_lia_rsgr_accu (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS --  038SO
        CURSOR c1 IS --  042SO
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_BOHID32) */
                     TRUNC (bd_datetime)                                       AS posdatetime,
                     con_pscall                                                AS posmsisdn,
                     bd_conid                                                  AS posconid,
                     bd_consolidation                                          AS posconsolidation,
                     con_tarid                                                 AS postarid,
                     bd_msisdn_b                                               AS poslongid,
                     COUNT (*)                                                 AS cdrcount,
                     SUM (DECODE (bd_iot_internal,  0.0, 0,  NULL, 0,  1))     AS cdrcountmo, --  049SO
                     0                                                         AS cdrcountmt, -- count nonzero IOTs
                     SUM (NVL (bd_iot, 0.00))                                  AS price, --  057SO --  047SO --  045SO -- IOT to LA for these CDRs
                     0.0                                                       AS amountcu,
                     0.0                                                       AS revenuesharela,
                     0.0                                                       AS revenueshareop
            FROM     bdetail2,
                     contract --  045SO      no TARFF needed any more
            WHERE        bd_conid = con_id
                     AND bd_bohid3 = p_bd_bohid --  042SO
                     AND bd_datetime > SYSDATE - p_maxage - 3 / 24 --  042SO
                     AND bd_datetime < SYSDATE + 3 / 24
                     AND bd_cdrtid = 'SMS-HR' --  066SO No Revenue Share for OnNet Home Routed
            GROUP BY TRUNC (bd_datetime), -- PosDATETIME  --  029SO
                     con_pscall, -- PosMSISDN
                     bd_conid, -- PosConId
                     bd_consolidation, -- PosCONSOLIDATION
                     con_tarid, -- PosTarId
                     bd_msisdn_b -- PosLongId
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC,
                     poslongid ASC;

        CURSOR c2 IS --  064SO
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_BOHID32) */
                     TRUNC (bd_datetime)                                 AS posdatetime,
                     con_pscall                                          AS posmsisdn,
                     bd_conid                                            AS posconid,
                     bd_consolidation                                    AS posconsolidation,
                     con_tarid                                           AS postarid,
                     NVL (con_hdgroup, 0)                                AS poshdgroup,
                     DECODE (bd_cdrtid, 'SMS-HR', '1', '0')              AS posinternational, -- 0 for 'SMS-HRON'
                     DECODE (bd_cdrtid, 'SMS-HR', 'MOFNA', 'CDRA')       AS possetdetailtype,
                     'U'                                                 AS posprepaid,
                     DECODE (bd_cdrtid, 'SMS-HR', bd_msisdn_b, NULL)     AS poslongid, -- NULL for 'SMS-HRON'
                     COUNT (*)                                           AS cdrcount,
                     COUNT (*)                                           AS cdrcountmo, --  064SO
                     0                                                   AS cdrcountmt, --  064SO
                     SUM (NVL (bd_amounttr, 0.0))                        AS price,
                     0.00                                                AS amountcu,
                     0.00                                                AS revenuesharela,
                     0.00                                                AS revenueshareop
            FROM     bdetail2,
                     contract --  066SO
            WHERE        bd_conid = con_id
                     AND bd_bohid3 = p_bd_bohid --  042SO
                     AND bd_datetime > SYSDATE - p_maxage - 3 / 24 --  042SO
                     AND bd_datetime < SYSDATE + 3 / 24
                     AND bd_cdrtid IN ('SMS-HR',
                                       'SMS-HRON') --  064SO only if Submit CDR is not available
            GROUP BY TRUNC (bd_datetime), -- PosDATETIME  --  029SO
                     con_pscall, -- PosMSISDN
                     bd_conid, -- PosConId
                     bd_consolidation, -- PosCONSOLIDATION
                     con_tarid, -- PosTarId
                     NVL (con_hdgroup, 0), -- PosHdGroup
                     DECODE (bd_cdrtid, 'SMS-HR', '1', '0'), -- PosInternational --  063SO
                     DECODE (bd_cdrtid, 'SMS-HR', 'MOFNA', 'CDRA'), -- PosSetDetailType --  059SO
                     DECODE (bd_cdrtid, 'SMS-HR', bd_msisdn_b, NULL) -- PosLongId
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC,
                     poshdgroup ASC,
                     posinternational ASC,
                     possetdetailtype ASC,
                     poslongid ASC;

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        recordsaffected := 0;

        FOR c1_rec IN c1
        LOOP --  042SO
            pkg_bdetail_settlement.sp_add_setdetail (
                'SLA', -- p_SET_ETID       IN varchar2,
                'MOIWSA', -- C1_Rec.PosSetDetailType,        -- p_SED_ETID       IN varchar2,
                c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                c1_rec.posdatetime, -- p_Date           IN DATE,
                c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                NULL, -- C1_Rec.PosInternational,         -- p_SED_INT        IN varchar2,
                'U', -- C1_Rec.PosPrepaid,               -- p_SED_PREPAID    IN varchar2,
                c1_rec.price, -- p_SED_PRICE      IN float,       --  045SO
                c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                c1_rec.poslongid, -- p_SED_LONGID     IN varchar2,
                c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                'accumulating', -- p_SED_DESC       IN varchar2,
                0, -- C1_Rec.PosGart,                  -- p_GART           IN varchar2,
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            IF l_returnstatus = 1
            THEN
                recordsaffected := recordsaffected + c1_rec.cdrcount; --  042SO
            END IF;
        END LOOP;

        FOR c1_rec IN c2
        LOOP --  064SO
            pkg_bdetail_settlement.sp_add_setdetail (
                'SLA', -- p_SET_ETID       IN varchar2,
                c1_rec.possetdetailtype, -- p_SED_ETID       IN varchar2,
                c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                c1_rec.posdatetime, -- p_Date           IN DATE,
                c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                c1_rec.posinternational, -- p_SED_INT        IN varchar2,
                c1_rec.posprepaid, -- p_SED_PREPAID    IN varchar2,
                c1_rec.price - c1_rec.revenuesharela, -- p_SED_PRICE      IN float,
                c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                c1_rec.poslongid, -- p_SED_LONGID     IN varchar2,
                c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                'accumulating', -- p_SED_DESC       IN varchar2,
                0, -- C1_Rec.PosGart,                      -- p_GART           IN varchar2,
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            IF l_returnstatus = 1
            THEN
                recordsaffected := recordsaffected + c1_rec.cdrcount;
            END IF;
        END LOOP;

        RETURN;
    END sp_lia_rsgr_accu;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_lia_sms_accu (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS --  036SO
        CURSOR c1 IS --  042SO
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_BOHID22) */
                     TRUNC (bd_datetime)                                       AS posdatetime,
                     con_pscall                                                AS posmsisdn,
                     bd_conid                                                  AS posconid,
                     bd_consolidation                                          AS posconsolidation,
                     con_tarid                                                 AS postarid,
                     COUNT (*)                                                 AS cdrcount,
                     0                                                         AS cdrcountmo,
                     SUM (DECODE (bd_iot_internal,  0.0, 0,  NULL, 0,  1))     AS cdrcountmt, --  045SO -- count nonzero IOTs
                     SUM (NVL (bd_iot, 0.00))                                  AS price, --  057SO --  047SO --  045SO -- IOT to LA for these CDRs
                     0.0                                                       AS amountcu,
                     0.0                                                       AS revenuesharela,
                     0.0                                                       AS revenueshareop
            FROM     bdetail2,
                     contract
            WHERE        bd_conid = con_id
                     AND bd_bohid2 = p_bd_bohid --  042SO
                     AND bd_datetime > SYSDATE - p_maxage - 3 / 24 --  042SO
                     AND bd_datetime < SYSDATE + 3 / 24
                     AND bd_npi_b = '1' -- Guard, CDR count will fail if not true for all CDRs
                     AND bd_pid_b = '0' -- Guard, CDR count will fail if not true for all CDRs
            GROUP BY TRUNC (bd_datetime), -- PosDATETIME  --  029SO
                     con_pscall, -- PosMSISDN
                     bd_conid, -- PosConId
                     bd_consolidation, -- PosCONSOLIDATION
                     con_tarid -- PosTarId
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC;

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        recordsaffected := 0; --  040SO

        FOR c1_rec IN c1
        LOOP --  042SO
            pkg_bdetail_settlement.sp_add_setdetail (
                'SLA', -- p_SET_ETID       IN varchar2,
                'IOTLACA', -- C1_Rec.PosSetDetailType,        -- p_SED_ETID       IN varchar2,
                c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                c1_rec.posdatetime, -- p_Date           IN DATE,
                c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                NULL, -- C1_Rec.PosInternational,         -- p_SED_INT        IN varchar2,
                'U', -- C1_Rec.PosPrepaid,               -- p_SED_PREPAID    IN varchar2,
                c1_rec.price, -- p_SED_PRICE      IN float,       --  045SO
                c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                NULL, -- C1_Rec.PosLongId,                -- p_SED_LONGID     IN varchar2,
                c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                'accumulating', -- p_SED_DESC       IN varchar2,
                0, -- C1_Rec.PosGart,                  -- p_GART           IN varchar2,
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            IF l_returnstatus = 1
            THEN
                recordsaffected := recordsaffected + c1_rec.cdrcount; --  042SO
            END IF;
        END LOOP;

        RETURN;
    --    --  --  032SO
    --    Exception
    --      When Others Then
    --          ErrorCode := SqlCode;
    --          ErrorMsg  := SqlErrM;
    --          RecordsAffected := 0;

    END sp_lia_sms_accu;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_smsccu_update (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_pacsid                             IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER, -- TODO unused parameter? (wwe)
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                         IN OUT NUMBER) --  055SO --  010SO duplicated from standard counter update based on MSC CDRs (in PKG_BDETAIL_MSC)
    IS
        l_bd_smscid                             VARCHAR2 (10);

        CURSOR c1 IS --  042SO
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_BOHID21) */
                   bdetail2.ROWID,
                   bd_smscid,
                   bd_datetime,
                   bd_iw_scenario --  054SO
            FROM   bdetail2
            WHERE      bd_bohid1 = p_bd_bohid
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + 3 / 24; --  013SO
    BEGIN
        recordsaffected := 0;

        FOR c1_rec IN c1
        LOOP --  042SO
            BEGIN
                l_bd_smscid := c1_rec.bd_smscid;

                -- Increment the counter by 1 when updating the count for an existing SMSC ID
                UPDATE iwtcounter
                SET    iwtc_count = iwtc_count + DECODE (c1_rec.bd_iw_scenario, '1', 1, 0), --  054SO
                       iwtc_hrr_count = NVL (iwtc_hrr_count, 0) + DECODE (c1_rec.bd_iw_scenario, '5', 1, 0) --  055SO --  054SO
                WHERE      iwtc_smscid = l_bd_smscid
                       AND iwtc_date = TRUNC (c1_rec.bd_datetime)
                       AND iwtc_esid = 'A';

                IF SQL%NOTFOUND
                THEN
                    -- If the counter does not exist, insert a new one
                    -- Initialise the counter with 1 when inserting the count for a new SMSC ID,
                    -- set the Counter state to 'A'ccumulating

                    IF LENGTH (l_bd_smscid) > 0
                    THEN --  023SO
                        INSERT INTO iwtcounter (
                                        iwtc_date,
                                        iwtc_smscid,
                                        iwtc_count,
                                        iwtc_hrr_count,
                                        iwtc_esid)
                        VALUES      (
                            TRUNC (c1_rec.bd_datetime),
                            l_bd_smscid,
                            DECODE (c1_rec.bd_iw_scenario, '1', 1, 0), --  054SO
                            DECODE (c1_rec.bd_iw_scenario, '5', 1, 0), --  054SO
                            'A');
                    END IF;

                    recordsaffected := recordsaffected + 1;
                ELSE
                    -- Counter was updated, ,increment the record count by the rows updated
                    recordsaffected := recordsaffected + SQL%ROWCOUNT;
                END IF;
            END;
        END LOOP;

        RETURN;
    --    Exception
    --      When Others Then
    --      ErrorCode := SqlCode;
    --      ErrorMsg  := SqlErrM;
    --      RecordsAffected := 0;
    END sp_smsccu_update;
END pkg_bdetail_smsc;
/