CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_bdetail_mmsc
AS
    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_laa_mmsc_accu (
        batchsize                               IN     INTEGER,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE sp_lia_mmsc_accu (
        batchsize                               IN     INTEGER,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER);

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lam_mms (
        p_pac_id                                IN     VARCHAR2, -- 'LATMCC_MMS'     MMS-LA MCC UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS -- 029SO
        l_gart                                  PLS_INTEGER;
    BEGIN
        l_gart := TO_NUMBER (pkg_common_packing.getpackingparameter (p_pac_id, 'GART'));

        pkg_bdetail_settlement.sp_lam_mcc (
            p_pac_id, -- IN varchar2,
            p_boh_id, -- IN varchar2,
            'MLA', --p_SET_ETID  -- IN varchar2,   -- SLA or MLA
            l_gart, --p_Gart      -- In Number,      --016SO
            recordsaffected, -- OUT number,
            errorcode, -- OUT number,
            errormsg, -- OUT varchar2,
            returnstatus -- OUT number
                        );
    END sp_cons_lam_mms;

    PROCEDURE sp_cons_lapmcc_mms (
        p_pact_id                               IN     VARCHAR2, -- 'LAPMCC_MMS' MMS-LA MCC Preparation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS -- 016SO
    -- get a list of MMS LA contracts which can have a minimum charge
    -- per pseudo call number, the contracts with the top overall min charge are choosen
    -- more than one contract can be returned, if they have equal weighted minimum charge
    -- this is taken care of in the processing of the result
    BEGIN
        pkg_bdetail_settlement.sp_lapmcc (
            p_pact_id, -- IN varchar2,
            p_boh_id, -- IN varchar2,
            'MLA', -- IN varchar2,   -- SLA or MLA
            recordsaffected, -- OUT number,
            errorcode, -- OUT number,
            errormsg, -- OUT varchar2,
            returnstatus -- IN OUT number
                        );
    END sp_cons_lapmcc_mms;

    PROCEDURE sp_cons_lat_mms (
        p_pac_id                                IN     VARCHAR2, -- 'LAT_MMS'    MMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  031SO Consolidate MMS-LA daily UFIH tickets from accumulated settlement details
        l_min_age                               PLS_INTEGER;
        l_max_age                               PLS_INTEGER;
        l_gart                                  PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_lat_mms'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));

        returnstatus := pkg_common.return_status_failure;
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

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
               AND sed_etid IN ('CDRA') -- 028SO
               AND sed_setid IN (SELECT set_id
                                 FROM   settling
                                 WHERE  set_etid IN ('MLA')) -- 028SO
                                                            ;

        l_marked_count := SQL%ROWCOUNT;

        IF l_marked_count > 0
        THEN
            pkg_bdetail_settlement.sp_lat_cdr (
                p_boh_id, -- p_BD_BOHID      In      Varchar2,
                'MLA', -- p_SET_ETID      IN      varchar2, -- 028SO
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
                WHERE  boh_id = p_boh_id; -- 028SO

                returnstatus := pkg_common.return_status_ok;
            ELSE -- RecordsAffected <> l_marked_count
                ROLLBACK;
                sbsdb_error_lib.LOG (
                    0,
                       sbsdb_logger_lib.json_other_first ('boh_id', p_boh_id)
                    || sbsdb_logger_lib.json_other_first ('errormsg', 'Mismatch in marked/processed MMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')')
                    || sbsdb_logger_lib.json_other_last ('topic', 'PROCESSING ERROR'),
                    sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_lat_mms'),
                    sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                    sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));
            END IF; -- RecordsAffected = l_marked_count
        END IF; -- l_marked_count > 0

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_lat_mms'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    END sp_cons_lat_mms;

    PROCEDURE sp_cons_lit_mms (
        p_pac_id                                IN     VARCHAR2, -- 'LIT_MMS'    MMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS -- 032SO Consolidate MMS-LA IW daily UFIH tickets from accumulated settlement details
        l_min_age                               PLS_INTEGER;
        l_max_age                               PLS_INTEGER;
        l_gart                                  PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_lit_mms'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));

        returnstatus := pkg_common.return_status_failure;
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

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
               AND sed_etid IN ('IOTLACA') -- 028SO
               AND sed_setid IN (SELECT set_id
                                 FROM   settling
                                 WHERE  set_etid IN ('MLA')) -- 028SO
                                                            ;

        l_marked_count := SQL%ROWCOUNT;

        IF l_marked_count > 0
        THEN
            pkg_bdetail_settlement.sp_lit_cdr (
                p_boh_id, -- p_BD_BOHID      In      Varchar2,
                'MLA', -- p_SET_ETID      IN      varchar2, -- 028SO
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
                WHERE  boh_id = p_boh_id; -- 028SO

                returnstatus := pkg_common.return_status_ok;
            ELSE -- RecordsAffected <> l_marked_count
                ROLLBACK;
                sbsdb_error_lib.LOG (
                    0,
                       sbsdb_logger_lib.json_other_first ('boh_id', p_boh_id)
                    || sbsdb_logger_lib.json_other_first ('errormsg', 'Mismatch in marked/processed MMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')')
                    || sbsdb_logger_lib.json_other_last ('topic', 'PROCESSING ERROR'),
                    sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_lit_mms'),
                    sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                    sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));
            END IF; -- RecordsAffected = l_marked_count
        END IF; -- l_marked_count > 0

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_lit_mms'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    END sp_cons_lit_mms;

    PROCEDURE sp_cons_mmsc (
        p_pact_id                               IN     VARCHAR2, -- 'MMSC'   MMSC Consolidation -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                               OUT NUMBER) -- 033SO
    IS
    -- 001SO
    BEGIN
        UPDATE mmsconsolidation
        SET    mmsc_esid = 'D'
        WHERE      mmsc_sepid = TO_CHAR (TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'), 'YYYYMM')
               AND mmsc_etid IN ('MMSC-RAW') -- 011SO
               AND mmsc_esid = 'R';

        recordsaffected := 0; -- 011SO

        INSERT INTO mmsconsolidation (
                        mmsc_id,
                        mmsc_etid,
                        mmsc_esid,
                        mmsc_date,
                        mmsc_sepid,
                        mmsc_fromdate,
                        mmsc_todate,
                        mmsc_prepaid,
                        mmsc_msgpriority,
                        mmsc_msgtype, -- 002GW
                        mmsc_msgclass,
                        mmsc_cdrrectype,
                        mmsc_fwdcopyind,
                        mmsc_eventdisp,
                        mmsc_legacyindicator,
                        mmsc_trclass,
                        mmsc_shortid,
                        mmsc_conid,
                        mmsc_tarid, -- 017SO
                        mmsc_pmvid,
                        mmsc_znid,
                        mmsc_count,
                        mmsc_numnotification,
                        mmsc_numhomerecip,
                        mmsc_numnonhomerecip,
                        mmsc_numintlrecip,
                        mmsc_numemailrecip,
                        mmsc_numscoderecip,
                        mmsc_amounttr,
                        mmsc_amountcu, -- 007SO
                        mmsc_retsharepv, -- 007SO Amount to be covered by Third Party (negative for Roaming Promotion events)
                        mmsc_retsharemo, -- 007SO
                        mmsc_tocid, -- 018SO
                        mmsc_int, -- 018SO
                        mmsc_iw, -- 018SO
                        mmsc_iot, -- 018SO
                        mmsc_iot_internal -- 036SO
                                         )
            SELECT /*+ NO_INDEX(BDETAIL6) */
                     pkg_common.generateuniquekey ('G'),
                     'MMSC-RAW',
                     'R',
                     SYSDATE,
                     sep_id,
                     MIN (bd_datetime),
                     MAX (bd_datetime),
                     bd_prepaid,
                     bd_msgpriority,
                     bd_msgtype, -- 002GW
                     bd_msgclass,
                     bd_cdrrectype,
                     bd_fwdcopyind,
                     bd_eventdisp,
                     bd_legacyindicator,
                     bd_trclass,
                     bd_shortid,
                     bd_conid,
                     bd_tarid, -- 013SO
                     bd_pmvid,
                     bd_znid,
                     COUNT (bdetail6.ROWID),
                     SUM (bd_numnotification / bd_recipcount), -- 004SO
                     SUM (bd_numhomerecip / bd_recipcount), -- 004SO
                     SUM (bd_numnonhomerecip / bd_recipcount), -- 004SO
                     SUM (bd_numintlrecip / bd_recipcount), -- 004SO
                     SUM (bd_numemailrecip / bd_recipcount), -- 004SO
                     SUM (bd_numscoderecip / bd_recipcount), -- 004SO
                     SUM (bd_amounttr),
                     SUM (bd_amountcu), -- 007SO
                     SUM (bd_retsharepv), -- 007SO Amount to be covered by Third Party (negative for Roaming Promotion events)
                     SUM (bd_retsharemo), -- 007SO
                     bd_tocid, -- 018SO
                     bd_int, -- 018SO
                     bd_iw, -- 018SO
                     SUM (bd_iot), -- 018SO
                     SUM (bd_iot_internal) -- 036SO
            FROM     bdetail6,
                     setperiod
            WHERE        bd_mapsid = 'R'
                     AND bd_datetime >= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH') -- +15           -- 004SO -- 003SO
                     AND bd_datetime < TRUNC (SYSDATE, 'MONTH')
                     AND sep_date1 = TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
            GROUP BY sep_id,
                     bd_prepaid,
                     bd_msgpriority,
                     bd_msgtype,
                     bd_msgclass,
                     bd_cdrrectype,
                     bd_fwdcopyind,
                     bd_eventdisp,
                     bd_legacyindicator,
                     bd_trclass,
                     bd_shortid,
                     bd_conid,
                     bd_tarid, -- 013SO
                     bd_pmvid,
                     bd_znid,
                     bd_tocid, -- 018SO
                     bd_int, -- 018SO
                     bd_iw -- 018SO
                          ;

        recordsaffected := SQL%ROWCOUNT;

        errorcode := 0;
        returnstatus := 1;
        RETURN;
    END sp_cons_mmsc;

    PROCEDURE sp_try_laa_mmsc (
        p_pac_id                                IN     VARCHAR2, -- 'LAA_MMSC'   MMS-LA Accumulation (MMSC)
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS -- 023SO        Accumulate MMSC-LA submit CDRs as a first step in MMS-LA settlement
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_PACSID36) */
                   'dummy'
            FROM   bdetail6
            WHERE      bd_demo = 0
                   AND bd_srctype = 'MMSC'
                   AND bd_pacsid3 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= 1;

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_laa_mmsc'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));

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
            UPDATE /*+ INDEX(BDETAIL6 IDX_BD_PACSID36) */
                   bdetail6
            SET    bd_bohid3 = p_boh_id,
                   bd_pacsid3 = 'P'
            WHERE      bd_demo = 0
                   AND bd_srctype = 'MMSC'
                   AND bd_pacsid3 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= l_batch_count;

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_laa_mmsc_accu (
                    l_marked_count,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected);

                IF recordsaffected = l_marked_count
                THEN
                    -- mark rows as processed
                    UPDATE bdetail6
                    SET    bd_pacsid3 = 'D'
                    WHERE      bd_bohid3 = p_boh_id
                           AND bd_pacsid3 = 'P'
                           AND bd_datetime > SYSDATE - l_max_age - 1 / 24 -- 034SO
                                                                         ;

                    l_marked_count := SQL%ROWCOUNT;

                    UPDATE boheader
                    SET    (
                               boh_datefc,
                               boh_datelc) =
                               (SELECT MIN (bd_datetime),
                                       MAX (bd_datetime)
                                FROM   bdetail6
                                WHERE      bd_bohid3 = p_boh_id
                                       AND bd_datetime > SYSDATE - l_max_age - 1 / 24 -- 034SO
                                                                                     )
                    WHERE  boh_id = p_boh_id;
                ELSE
                    ROLLBACK;
                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_first ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_first ('errormsg', 'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')')
                        || sbsdb_logger_lib.json_other_last ('topic', 'PROCESSING ERROR'),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_laa_mmsc'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_laa_mmsc'),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    END sp_try_laa_mmsc;

    PROCEDURE sp_try_lia_mmsc (
        p_pac_id                                IN     VARCHAR2, -- 'LIA_MMSC'   MMS-LA IW Accumulation (MMSC)
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS -- 031SO        Accumulate MMSC-LA IW CDRs as a first step in MMS-LA IW settlement
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_PACSID26) */
                   'dummy'
            FROM   bdetail6
            WHERE      bd_demo = 0
                   AND bd_srctype = 'MMSC'
                   AND bd_pacsid2 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= 1;

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_lia_mmsc'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));

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
            UPDATE /*+ INDEX(BDETAIL6 IDX_BD_PACSID26) */
                   bdetail6
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
                           NVL (
                               pkg_bdetail_common.contract_iot_chf (
                                   bd_tocid,
                                   'ORIG',
                                   'MMS',
                                   bd_datetime,
                                   bd_msgsize),
                               0.00)), -- 038SO -- 035SO
                   bd_iot_internal =
                       NVL (
                           pkg_bdetail_common.contract_iot_chf (
                               bd_tocid,
                               'ORIG',
                               'MMS',
                               bd_datetime,
                               bd_msgsize),
                           0.00) -- 035SO
            WHERE      bd_demo = 0
                   AND bd_srctype = 'MMSC'
                   AND bd_pacsid2 = 'S'
                   AND bd_mapsid = 'R'
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE
                   AND ROWNUM <= l_batch_count;

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_lia_mmsc_accu (
                    l_marked_count,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected);

                IF recordsaffected = l_marked_count
                THEN
                    -- mark rows as processed
                    UPDATE bdetail6
                    SET    bd_pacsid2 = 'D'
                    WHERE      bd_bohid2 = p_boh_id
                           AND bd_pacsid2 = 'P'
                           AND bd_datetime > SYSDATE - l_max_age - 1 / 24 -- 034SO
                                                                         ;

                    l_marked_count := SQL%ROWCOUNT;

                    UPDATE boheader
                    SET    (
                               boh_datefc,
                               boh_datelc) =
                               (SELECT MIN (bd_datetime),
                                       MAX (bd_datetime)
                                FROM   bdetail6
                                WHERE      bd_bohid2 = p_boh_id
                                       AND bd_datetime > SYSDATE - l_max_age - 1 / 24 -- 034SO
                                                                                     )
                    WHERE  boh_id = p_boh_id;
                ELSE
                    ROLLBACK;
                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_first ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_first ('errormsg', 'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')')
                        || sbsdb_logger_lib.json_other_last ('topic', 'PROCESSING ERROR'),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_lia_mmsc'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_lia_mmsc'),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    END sp_try_lia_mmsc;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_laa_mmsc_accu (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS -- 022SO
        CURSOR c1 (
            a_boh_id                                IN VARCHAR2,
            a_maxage                                IN NUMBER)
        IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_BOHID36) */
                     TRUNC (bd_datetime)                                         AS posdatetime,
                     con_pscall                                                  AS posmsisdn,
                     bd_conid                                                    AS posconid,
                     bd_shortid                                                  AS posconsolidation,
                     con_tarid                                                   AS postarid,
                     NVL (con_hdgroup, 0)                                        AS poshdgroup,
                     NVL (bd_int, '0')                                           AS posinternational,
                     'CDRA'                                                      AS possetdetailtype,
                     'U'                                                         AS posprepaid,
                     NULL                                                        AS poslongid,
                     COUNT (*)                                                   AS cdrcount,
                     SUM (DECODE (bd_cdrtid, 'MM7O', 0, 1))                      AS cdrcountmo,
                     SUM (DECODE (bd_cdrtid, 'MM7O', 1, 0))                      AS cdrcountmt,
                     SUM (NVL (bd_amounttr, 0.0 - NVL (bd_retsharepv, 0.0)))     AS price, -- Transport Charge to LA for these CDRs
                     SUM (NVL (bd_amountcu, 0.0))                                AS amountcu,
                     SUM (NVL (bd_retsharepv, 0.0))                              AS revenuesharela,
                     SUM (NVL (bd_retsharemo, 0.0))                              AS revenueshareop
            FROM     bdetail6,
                     contract
            WHERE        bd_conid = con_id
                     AND bd_bohid3 = a_boh_id
                     AND bd_datetime > SYSDATE - a_maxage - 3 / 24
                     AND bd_datetime < SYSDATE + 3 / 24
            GROUP BY TRUNC (bd_datetime), -- PosDATETIME  --  029SO
                     con_pscall, -- PosMSISDN
                     bd_conid, -- PosConId
                     bd_shortid, -- PosCONSOLIDATION
                     con_tarid, -- PosTarId
                     NVL (con_hdgroup, 0), -- PosHdGroup
                     NVL (bd_int, '0') -- PosInternational
            -- 'CDRA',                                                              -- PosSetDetailType
            -- 'U',                                                                 -- PosPrepaid 'U' = unknown/irrelevant
            -- NULL                                                                 -- PosLongId
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC,
                     poshdgroup ASC,
                     posinternational ASC;

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        recordsaffected := 0;

        FOR c1_rec IN c1 (p_bd_bohid, p_maxage)
        LOOP
            pkg_bdetail_settlement.sp_add_setdetail (
                'MLA', -- p_SET_ETID       IN varchar2,
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
                0, -- C1_Rec.PosGart,                      -- p_GART           IN varchar2,    -- 027SO
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            recordsaffected := recordsaffected + c1_rec.cdrcount;
        END LOOP;

        RETURN;
    END sp_laa_mmsc_accu;

    PROCEDURE sp_lia_mmsc_accu (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS -- 031SO
        CURSOR c1 (
            a_boh_id                                IN VARCHAR2,
            a_maxage                                IN NUMBER)
        IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_PACSID26) */
                     TRUNC (bd_datetime)                                       AS posdatetime,
                     con_pscall                                                AS posmsisdn,
                     bd_conid                                                  AS posconid,
                     bd_shortid                                                AS posconsolidation,
                     con_tarid                                                 AS postarid,
                     -- NULL                                                                    as PosHdGroup,
                     -- NULL                                                                    as PosInternational,
                     -- 'IOTLACA'                                                               as PosSetDetailType,
                     -- 'U'                                                                     as PosPrepaid,
                     -- NULL                                                                    as PosLongId,
                     COUNT (*)                                                 AS cdrcount,
                     0                                                         AS cdrcountmo,
                     SUM (DECODE (bd_iot_internal,  0.0, 0,  NULL, 0,  1))     AS cdrcountmt, -- 035SO -- count nonzero IOTs
                     SUM (NVL (bd_iot_internal, 0.00))                         AS price, -- 037SO -- 035SO -- IOT to LA for these CDRs
                     0.0                                                       AS amountcu,
                     0.0                                                       AS revenuesharela,
                     0.0                                                       AS revenueshareop
            FROM     bdetail6,
                     contract
            WHERE        bd_conid = con_id
                     AND bd_bohid2 = a_boh_id
                     AND bd_datetime > SYSDATE - a_maxage - 3 / 24
                     AND bd_datetime < SYSDATE + 3 / 24
            GROUP BY TRUNC (bd_datetime), -- PosDATETIME  --  029SO
                     con_pscall, -- PosMSISDN
                     bd_conid, -- PosConId
                     bd_shortid, -- PosCONSOLIDATION
                     con_tarid -- PosTarId
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC;

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        recordsaffected := 0;

        FOR c1_rec IN c1 (p_bd_bohid, p_maxage)
        LOOP
            pkg_bdetail_settlement.sp_add_setdetail (
                'MLA', -- p_SET_ETID       IN varchar2,
                'IOTLACA', -- C1_Rec.PosSetDetailType,         -- p_SED_ETID       IN varchar2,
                c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                c1_rec.posdatetime, -- p_Date           IN DATE,
                c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                NULL, -- C1_Rec.PosInternational,         -- p_SED_INT        IN varchar2,
                'U', -- C1_Rec.PosPrepaid,               -- p_SED_PREPAID    IN varchar2,
                c1_rec.price, -- p_SED_PRICE      IN float,       -- 035SO
                c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                NULL, -- C1_Rec.PosLongId,                -- p_SED_LONGID     IN varchar2,
                c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                'accumulating', -- p_SED_DESC       IN varchar2,
                0, -- C1_Rec.PosGart,                      -- p_GART           IN varchar2,    -- 027SO
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            recordsaffected := recordsaffected + c1_rec.cdrcount;
        END LOOP;

        RETURN;
    END sp_lia_mmsc_accu;
END pkg_bdetail_mmsc;
/
