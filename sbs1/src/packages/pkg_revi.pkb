CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_revi
IS
    bdebug                                  BOOLEAN;
    cnotbilledbysbs                         VARCHAR2 (1) := '0'; -- 028SO
    monthtodo                               PLS_INTEGER := -1; -- -1 = last month, 0 = this month for tests
    monthtostore                            PLS_INTEGER := -1; -- -1 = last month, 0 = this month for tests    -- 023SO
    rconfig                                 revi_config%ROWTYPE;
    vmepkg                                  VARCHAR2 (30) := 'PKG_REVI';

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN revi_config%ROWTYPE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_content_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2); -- 016SO

    PROCEDURE revi_index_mms_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2); -- 016SO

    PROCEDURE revi_index_sms_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2); -- 016SO

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2)
    IS -- 016SO
        CURSOR cbiheader IS
            SELECT bih_id,
                   bih_srctype,
                   bih_mapid,
                   bih_filename,
                   bih_reccount,
                   bih_esid
            FROM   biheader
            WHERE  bih_id = p_bih_id;

        cbiheaderrow                            cbiheader%ROWTYPE;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_file'),
            sbsdb_logger_lib.log_param ('p_bih_id', p_bih_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));

        rconfig := pkg_revi.getconfig;

        IF rconfig.revic_exec = 1
        THEN
           <<loop_cbiheader>>
            FOR cbiheaderrow IN cbiheader
            LOOP
                IF cbiheaderrow.bih_reccount > 0
                THEN
                    IF cbiheaderrow.bih_srctype = 'ISRV'
                    THEN
                        revi_index_content_file (p_bih_id, p_boh_id);
                    ELSIF cbiheaderrow.bih_srctype IN ('SMSC',
                                                       'SMSN')
                    THEN -- 044SO
                        revi_index_sms_file (p_bih_id, p_boh_id);
                    ELSIF cbiheaderrow.bih_srctype = 'MMSC'
                    THEN
                        revi_index_mms_file (p_bih_id, p_boh_id);
                    END IF;
                END IF;
            END LOOP loop_cbiheader;
        END IF;

        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_file'));
    END revi_index_file;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revicd (
        p_pac_id                                IN     VARCHAR2, -- 'REVICD' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    -- find and index SMS and MMS transport delivery CDRs for chargeable content CDRs for last period
    IS
        me                                      VARCHAR2 (40) := 'REVI_INDEX_CONTENT_DEL';

        CURSOR cmaster IS
            SELECT /*+ NO_INDEX(BDETAIL) */
                   ROWID,
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_a,
                   bd_msisdn_b, -- 043SO
                   bd_shortid,
                   bd_service,
                   bd_transportmedium,
                   bd_requestid, -- 033SO -- 026SO
                   bd_msgid,
                   bd_counttr
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 033SO -- 026SO
                   AND bd_mapsid = 'R'
                   AND bd_demo = 0
                   AND bd_billed <> cnotbilledbysbs -- 028SO IN (cBilledBySbs,cZeroChargeIgnore,cIgnoreSubscriber) -- 018SO
                   AND bd_datetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND bd_datetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1) -- AND BD_SHORTID not in ('333','888')         -- 014SO -- 013SO   $$$$$$$ to be removed
                                                                                          -- AND  LENGTH(BD_SERVICE) >= 10                                        -- 008SO
                                                                                          -- AND      (BD_SERVICE NOT LIKE '%-DEL-%'                                  -- 015SO -- 009SO (to be removed)
                                                                                          -- OR BD_TRANSPORTMEDIUM <> 'SMS')                                      -- 015SO -- 009SO (to be removed)
                                                                                          -- AND  BD_DATETIME >= to_date('26.10.2007','dd.mm.yyyy')               -- 004SO
    ; -- 011SO

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR csmsdelivery (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_BILLID2) */
                   ROWID
            FROM   bdetail2
            WHERE      bd_mapsid = 'R' -- 044SO
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_consolidation = cm.bd_shortid
                   AND bd_status = 0
                   AND bd_billid = cm.bd_requestid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') - 1.1 / 24 -- 045SO
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') + rconfig.revic_delay_sms_del / 86400.0 -- 045SO
                                                                                                                              ;

        CURSOR csmslongdelivery (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL2 IDX_BD_BILLID2) */
                   ROWID
            FROM   bdetail2
            WHERE      bd_mapsid = 'R' -- 044SO
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_consolidation = cm.bd_shortid
                   AND bd_status = 0
                   AND bd_billid = cm.bd_requestid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') - 1.1 / 24 -- 045SO
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') + rconfig.revic_delay_sms_del / 86400.0 -- 045SO
                                                                                                                              ; -- 040SO

        CURSOR cmmsdelivery (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_UMSGGRPID) */
                   ROWID
            FROM   bdetail6
            WHERE      bd_srctype = 'MMSC'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_msgtype = 0
                   AND bd_umsggrpid = cm.bd_msgid
                   AND bd_cdrrectype IN ('MMSRrecord',
                                         'MM4Rrecord') -- 005SO
                   AND bd_eventdisp = 1
                   AND bd_shortid = cm.bd_shortid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') - 1.1 / 24
                   AND bd_datetime < TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') + rconfig.revic_delay_mms_del / 86400.0; -- 011SO

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO

        l_matching_count                        PLS_INTEGER;

        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revicd'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVI_CONTENT_DEL TRUNCATE PARTITION INFO' || l_sepid_to_store; -- 007SO

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

            IF     cmasterrow.bd_transportmedium = 'SMS'
               AND cmasterrow.bd_counttr <= 1
            THEN -- 028SO
                FOR csmsdeliveryrow IN csmsdelivery (cmasterrow)
                LOOP
                    INSERT INTO revi_content_del (
                                    revicd_sepid,
                                    revicd_shortid,
                                    revicd_rowid_master,
                                    revicd_count_expected,
                                    revicd_table_slave,
                                    revicd_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL2',
                        csmsdeliveryrow.ROWID);

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_del (
                                    revicd_sepid,
                                    revicd_shortid,
                                    revicd_rowid_master,
                                    revicd_count_expected,
                                    revicd_table_slave,
                                    revicd_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL2',
                        NULL);
                END IF;
            ELSIF     cmasterrow.bd_transportmedium = 'SMS'
                  AND cmasterrow.bd_counttr > 1
            THEN
                FOR csmslongdeliveryrow IN csmslongdelivery (cmasterrow)
                LOOP
                    INSERT INTO revi_content_del (
                                    revicd_sepid,
                                    revicd_shortid,
                                    revicd_rowid_master,
                                    revicd_count_expected,
                                    revicd_table_slave,
                                    revicd_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL2',
                        csmslongdeliveryrow.ROWID);

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_del (
                                    revicd_sepid,
                                    revicd_shortid,
                                    revicd_rowid_master,
                                    revicd_count_expected,
                                    revicd_table_slave,
                                    revicd_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL2',
                        NULL);
                END IF;
            ELSIF     cmasterrow.bd_transportmedium = 'SMS'
                  AND cmasterrow.bd_counttr IS NULL
            THEN
                NULL; -- cannot index this SMS content (
            ELSIF cmasterrow.bd_transportmedium = 'MMS'
            THEN
                FOR cmmsdeliveryrow IN cmmsdelivery (cmasterrow)
                LOOP
                    INSERT INTO revi_content_del (
                                    revicd_sepid,
                                    revicd_shortid,
                                    revicd_rowid_master,
                                    revicd_count_expected,
                                    revicd_table_slave,
                                    revicd_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        NVL (cmasterrow.bd_counttr, 1),
                        'BDETAIL6',
                        cmmsdeliveryrow.ROWID);

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_del (
                                    revicd_sepid,
                                    revicd_shortid,
                                    revicd_rowid_master,
                                    revicd_count_expected,
                                    revicd_table_slave,
                                    revicd_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        NVL (cmasterrow.bd_counttr, 1),
                        'BDETAIL6',
                        NULL);
                END IF;
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revicd'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            returnstatus := 0;
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; -- 041SO
            recordsaffected := 0;

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                || sbsdb_logger_lib.json_other_add ('topic', 'PLSQL-ERROR')
                || sbsdb_logger_lib.json_other_add ('bih_id', p_boh_id)
                || sbsdb_logger_lib.json_other_add ('boh_id')
                || sbsdb_logger_lib.json_other_add ('bd_id')
                || sbsdb_logger_lib.json_other_last ('short_id'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revicd'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus)); -- 042SO -- 039SO
    END sp_cons_revicd;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revics (
        p_pac_id                                IN     VARCHAR2, -- 'REVICS' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    -- find and index SMS and MMS transport submits for chargeable content CDRs for last period
    IS
        CURSOR cmaster IS
            SELECT /*+ NO_INDEX(BDETAIL) */
                   ROWID,
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_a,
                   bd_msisdn_b, -- 043SO
                   bd_shortid,
                   bd_service,
                   bd_transportmedium,
                   bd_requestid, -- 033SO -- 026SO
                   bd_msgid,
                   bd_counttr
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 033SO -- 026SO
                   AND bd_mapsid = 'R'
                   AND bd_demo = 0
                   AND bd_billed <> cnotbilledbysbs -- 026SO IN (cBilledBySbs,cZeroChargeIgnore,cIgnoreSubscriber) -- 018SO
                   AND bd_datetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND bd_datetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1) -- AND  LENGTH(BD_SERVICE) >= 10                                        -- 008SO
                                                                                          -- AND BD_SHORTID not in ('333','888')                                  -- 014SO -- 013SO
                                                                                          -- AND      (BD_SERVICE NOT LIKE '%-DEL-%'                                  -- 015SO -- 009SO (to be removed)
                                                                                          -- OR BD_TRANSPORTMEDIUM <> 'SMS')                                      -- 015SO -- 009SO (to be removed)
                                                                                          -- AND  BD_DATETIME >= to_date('26.10.2007','dd.mm.yyyy')               -- 004SO
    ; -- 011SO

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR csmssubmit (cm IN cmaster%ROWTYPE)
        IS -- 001SO
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BILLID1) */
                   ROWID
            FROM   bdetail1
            WHERE      bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_consolidation = cm.bd_shortid
                   AND bd_status = 4
                   AND bd_billid = cm.bd_requestid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') - 1.1 / 24 -- 045SO
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') + rconfig.revic_delay_sms_sub / 86400.0 -- 045SO
                                                                                                                              ; -- 044SO

        CURSOR csmslongsubmit (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BILLID1) */
                   ROWID
            FROM   bdetail1
            WHERE      bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_consolidation = cm.bd_shortid
                   AND bd_status = 4
                   AND bd_billid = cm.bd_requestid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') - 1.1 / 24 -- 045SO
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') + rconfig.revic_delay_sms_sub / 86400.0 -- 045SO
                                                                                                                              ;

        CURSOR cmmssubmit (cm IN cmaster%ROWTYPE)
        IS -- 001SO
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_UMSGGRPID) */
                   ROWID
            FROM   bdetail6
            WHERE      bd_srctype = 'MMSC'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_msgtype = 0
                   AND bd_umsggrpid = cm.bd_msgid
                   AND bd_cdrrectype = 'MM7Orecord'
                   AND bd_eventdisp = 2
                   AND bd_shortid = cm.bd_shortid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') - 1.1 / 24
                   AND bd_datetime < TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') + rconfig.revic_delay_mms_sub / 86400.0; -- 011SO

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO

        l_matching_count                        PLS_INTEGER;

        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revics'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVI_CONTENT_SUB TRUNCATE PARTITION INFO' || l_sepid_to_store; -- 007SO

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

            IF     cmasterrow.bd_transportmedium = 'SMS'
               AND cmasterrow.bd_counttr <= 1
            THEN -- 027SO
                FOR csmssubmitrow IN csmssubmit (cmasterrow)
                LOOP
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL1',
                        csmssubmitrow.ROWID);

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL1',
                        NULL);
                END IF;
            ELSIF     cmasterrow.bd_transportmedium = 'SMS'
                  AND cmasterrow.bd_counttr > 1
            THEN
                FOR csmslongsubmitrow IN csmslongsubmit (cmasterrow)
                LOOP
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL1',
                        csmslongsubmitrow.ROWID);

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL1',
                        NULL);
                END IF;
            ELSIF     cmasterrow.bd_transportmedium = 'SMS'
                  AND cmasterrow.bd_counttr IS NULL
            THEN
                NULL; -- cannot index this SMS content (
            ELSIF cmasterrow.bd_transportmedium = 'MMS'
            THEN
                FOR cmmssubmitrow IN cmmssubmit (cmasterrow)
                LOOP
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        NVL (cmasterrow.bd_counttr, 1),
                        'BDETAIL6',
                        cmmssubmitrow.ROWID);

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        NVL (cmasterrow.bd_counttr, 1),
                        'BDETAIL6',
                        NULL);
                END IF;
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revics'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            --                    rollback;
            --                    ReturnStatus := 0;
            --                    ErrorCode := SQLCODE;
            --                    ErrorMsg  := PKG_COMMON.getHardErrorDesc;                       -- 041SO
            --                    RecordsAffected := 0;
            --                    pkg_bdetail_common.INSERT_WARNING (vMePkg, Me, 'PLSQL-ERROR', ErrorMsg , ErrorCode);

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (pkg_common.getharderrordesc))
                || sbsdb_logger_lib.json_other_last ('topic', 'PLSQL-ERROR'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revics'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

            RAISE;
    END sp_cons_revics;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revim (
        p_pac_id                                IN     VARCHAR2, -- 'REVIM' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        CURSOR cmaster IS
            SELECT /*+ NO_INDEX(BDETAIL6) */
                   ROWID,
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_b,
                   bd_shortid,
                   bd_umsggrpid
            FROM   bdetail6
            WHERE      bd_srctype = 'MMSC'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msgtype = 0
                   AND bd_cdrrectype = 'MM7Orecord'
                   AND bd_tarid IN ('S',
                                    'P',
                                    'T') -- 036SO -- 006SO
                   AND bd_eventdisp = 2
                   AND bd_datetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND bd_datetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1) -- AND BD_SHORTID not in ('333','888')                                  -- 014SO -- 013SO
                                                                                          -- AND  BD_DATETIME >= to_date('26.10.2007','dd.mm.yyyy')                   -- 004SO
    ; -- 011SO

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR ccontent (cm IN cmaster%ROWTYPE)
        IS -- 001SO
            SELECT /*+ INDEX(BDETAIL IDX_BD_MSGID) */
                   ROWID
            FROM   bdetail
            WHERE      bd_srctype = 'ISRV'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_shortid = cm.bd_shortid
                   AND bd_msgid = cm.bd_umsggrpid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') - rconfig.revic_delay_mms_sub / 86400.0
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') + 1.1 / 24; -- 011SO

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO
        l_matching_count                        PLS_INTEGER;

        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revim'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVI_MMS TRUNCATE PARTITION INFO' || l_sepid_to_store; -- 007SO

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

           <<loop_ccontent>>
            FOR ccontentrow IN ccontent (cmasterrow)
            LOOP
                INSERT INTO revi_mms (
                                revim_sepid,
                                revim_shortid,
                                revim_rowid6,
                                revim_rowid)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.bd_shortid,
                    cmasterrow.ROWID,
                    ccontentrow.ROWID);

                l_matching_count := l_matching_count + 1;
            END LOOP loop_ccontent;

            IF l_matching_count = 0
            THEN
                -- Insert index row for missing content CDR
                INSERT INTO revi_mms (
                                revim_sepid,
                                revim_shortid,
                                revim_rowid6,
                                revim_rowid)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.bd_shortid,
                    cmasterrow.ROWID,
                    NULL);
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revim'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            --                    rollback;
            --                    ReturnStatus := 0;
            --                    ErrorCode := SQLCODE;
            --                    ErrorMsg  := := PKG_COMMON.getHardErrorDesc;                    -- 041SO
            --                    RecordsAffected := 0;
            --                    pkg_bdetail_common.INSERT_WARNING (vMePkg, Me, 'PLSQL-ERROR', ErrorMsg , ErrorCode);

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (pkg_common.getharderrordesc))
                || sbsdb_logger_lib.json_other_last ('topic', 'PLSQL-ERROR'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revim'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

            RAISE;
    END sp_cons_revim;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revipre (
        p_pac_id                                IN     VARCHAR2, -- 'REVIPRE' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    -- 020SO
    -- find and index prepaid charges on DSS for chargeable content CDRs for last period
    IS
        CURSOR cmaster IS
            SELECT /*+ NO_INDEX(BDETAIL) */
                   ROWID,
                   bd_datetime,
                   bd_msisdn_a,
                   bd_shortid,
                   bd_service,
                   bd_transportmedium,
                   bd_requestid -- 033SO  -- 026SO
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 033SO -- 026SO
                   AND bd_mapsid = 'R'
                   AND bd_demo = 0
                   AND bd_prepaid = 'Y'
                   -- AND (BD_AMOUNTCU <> 0.00 OR BD_ONLINECHARGE is not NULL)             -- 028SO
                   AND bd_billed <> cnotbilledbysbs -- 028SO IN (cBilledBySbs)
                   AND bd_datetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND bd_datetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1) -- AND BD_ONLINECHARGE IS NOT NULL   -- 025SO    -- $$$$$$$$$$$ to be removed after VASOL migration
                                                                                         ;

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR cdsscdrsms (cm IN cmaster%ROWTYPE)
        IS
            SELECT rowid_ppb,
                   0.001 * unit     AS charged_amount
            FROM   cdrsms -- @DSS
            WHERE      calltype IN (120,
                                    20) -- 026SO
                   -- AND TRANSPORT_MEDIUM = 'SMS'                                         -- 046SO
                   AND request_id = cm.bd_requestid || '_' || cm.bd_msisdn_a; -- 024SO -- 021SO

        CURSOR cdsscdrmms (cm IN cmaster%ROWTYPE)
        IS
            SELECT rowid_ppb,
                   0.001 * unit     AS charged_amount
            FROM   cdrmms -- @DSS
            WHERE      calltype = 121
                   -- AND TRANSPORT_MEDIUM = 'MMS'                                         -- 046SO
                   AND request_id = cm.bd_requestid || '_' || cm.bd_msisdn_a; -- 024SO -- 024SO -- 021SO

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO
        l_matching_count                        PLS_INTEGER;
        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revipre'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVI_PRE TRUNCATE PARTITION INFO' || l_sepid_to_store;

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

            IF cmasterrow.bd_transportmedium = 'SMS'
            THEN
               <<loop_cdsscdrsms>>
                FOR cdsscdrsmsrow IN cdsscdrsms (cmasterrow)
                LOOP
                    INSERT INTO revi_pre (
                                    revipre_sepid,
                                    revipre_shortid,
                                    revipre_rowid_master,
                                    revipre_table_slave,
                                    revipre_rowid_slave,
                                    revipre_charged_amount)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        'CDR' || cmasterrow.bd_transportmedium,
                        cdsscdrsmsrow.rowid_ppb,
                        cdsscdrsmsrow.charged_amount); -- 024SO

                    l_matching_count := l_matching_count + 1;
                END LOOP loop_cdsscdrsms;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing charge record
                    INSERT INTO revi_pre (
                                    revipre_sepid,
                                    revipre_shortid,
                                    revipre_rowid_master,
                                    revipre_table_slave,
                                    revipre_rowid_slave,
                                    revipre_charged_amount)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        'CDR' || cmasterrow.bd_transportmedium,
                        NULL,
                        NULL);
                END IF;
            ELSIF cmasterrow.bd_transportmedium = 'MMS'
            THEN
               <<loop_cdsscdrmms>>
                FOR cdsscdrmmsrow IN cdsscdrmms (cmasterrow)
                LOOP
                    INSERT INTO revi_pre (
                                    revipre_sepid,
                                    revipre_shortid,
                                    revipre_rowid_master,
                                    revipre_table_slave,
                                    revipre_rowid_slave,
                                    revipre_charged_amount)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        'CDR' || cmasterrow.bd_transportmedium,
                        cdsscdrmmsrow.rowid_ppb,
                        cdsscdrmmsrow.charged_amount); -- 024SO

                    l_matching_count := l_matching_count + 1;
                END LOOP loop_cdsscdrmms;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing charge record
                    INSERT INTO revi_pre (
                                    revipre_sepid,
                                    revipre_shortid,
                                    revipre_rowid_master,
                                    revipre_table_slave,
                                    revipre_rowid_slave,
                                    revipre_charged_amount)
                    VALUES      (
                        l_sepid_to_store,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        'CDR' || cmasterrow.bd_transportmedium,
                        NULL,
                        NULL);
                END IF;
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revim'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            --                    rollback;
            --                    ReturnStatus := 0;
            --                    ErrorCode := SQLCODE;
            --                    ErrorMsg  := PKG_COMMON.getHardErrorDesc;                       -- 041SO
            --                    RecordsAffected := 0;
            --                    pkg_bdetail_common.INSERT_WARNING (vMePkg, Me, 'PLSQL-ERROR', ErrorMsg , ErrorCode);

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (pkg_common.getharderrordesc))
                || sbsdb_logger_lib.json_other_last ('topic', 'PLSQL-ERROR'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revipre'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

            RAISE;
    END sp_cons_revipre;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_reviprm (
        p_pac_id                                IN     VARCHAR2, -- 'REVIPRM' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    -- 020SO
    -- find and index content CDRs for MMS prepaid charges on DSS for last period
    IS
        CURSOR cmaster IS
            SELECT rowid_ppb,
                   startdatetime                                           AS startdatetime,
                   SUBSTR (called_nr, 3)                                   AS called_nr,
                   short_id                                                AS short_id,
                   SUBSTR (request_id, 1, INSTR (request_id, '_') - 1)     AS request_id,
                   0.001 * unit                                            AS charged_amount
            FROM   cdrmms -- @DSS
            WHERE      calltype = 121
                   -- AND TRANSPORT_MEDIUM = 'MMS'                                         -- 046SO
                   AND startdatetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND startdatetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1); -- 024SO -- 021SO

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR ccontent (cm IN cmaster%ROWTYPE)
        IS -- 001SO
            SELECT /*+ INDEX(BDETAIL IDX_BD_REQUESTID) */
                   ROWID
            FROM   bdetail
            WHERE      bd_srctype = 'ISRV'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_a = cm.called_nr
                   AND bd_shortid = cm.short_id
                   AND bd_requestid = cm.request_id
                   AND bd_datetime >= cm.startdatetime - 1.1 / 24
                   AND bd_datetime <= cm.startdatetime + 1.1 / 24;

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO
        l_matching_count                        PLS_INTEGER;

        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_reviprm'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVIPRE_MMS TRUNCATE PARTITION INFO' || l_sepid_to_store;

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

           <<loop_ccontent>>
            FOR ccontentrow IN ccontent (cmasterrow)
            LOOP
                INSERT INTO revipre_mms (
                                reviprem_sepid,
                                reviprem_shortid,
                                reviprem_rowids,
                                reviprem_rowid,
                                reviprem_charged_amount)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.short_id,
                    cmasterrow.rowid_ppb,
                    ccontentrow.ROWID,
                    cmasterrow.charged_amount); -- 024SO

                l_matching_count := l_matching_count + 1;
            END LOOP loop_ccontent;

            IF l_matching_count = 0
            THEN
                -- Insert index row for missing content CDR
                INSERT INTO revipre_mms (
                                reviprem_sepid,
                                reviprem_shortid,
                                reviprem_rowids,
                                reviprem_rowid,
                                reviprem_charged_amount)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.short_id,
                    cmasterrow.rowid_ppb,
                    NULL,
                    cmasterrow.charged_amount); -- 024SO
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_reviprm'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            --                    rollback;
            --                    ReturnStatus := 0;
            --                    ErrorCode := SQLCODE;
            --                    ErrorMsg  := := PKG_COMMON.getHardErrorDesc;                    -- 041SO
            --                    RecordsAffected := 0;
            --                    pkg_bdetail_common.INSERT_WARNING (vMePkg, Me, 'PLSQL-ERROR', ErrorMsg , ErrorCode);

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (pkg_common.getharderrordesc))
                || sbsdb_logger_lib.json_other_last ('topic', 'PLSQL-ERROR'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_reviprm'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

            RAISE;
    END sp_cons_reviprm;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_reviprs (
        p_pac_id                                IN     VARCHAR2, -- 'REVIPRS' -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    -- 020SO
    -- find and index content CDRs for SMS prepaid charges on DSS for last period
    IS
        CURSOR cmaster IS
            SELECT rowid_ppb,
                   startdatetime                                           AS startdatetime,
                   SUBSTR (called_nr, 3)                                   AS called_nr,
                   NVL (short_id, '800')                                   AS short_id, -- 030SO
                   SUBSTR (request_id, 1, INSTR (request_id, '_') - 1)     AS request_id,
                   0.001 * unit                                            AS charged_amount
            FROM   cdrsms -- @DSS
            WHERE      calltype IN (120,
                                    20) -- 026SO
                   -- AND TRANSPORT_MEDIUM = 'SMS'                                         -- 046SO
                   AND startdatetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND startdatetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1); -- 024SO -- 021SO

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR ccontent (cm IN cmaster%ROWTYPE)
        IS -- 001SO
            SELECT /*+ INDEX(BDETAIL IDX_BD_REQUESTID) */
                   ROWID
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 031SO
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_a = cm.called_nr
                   AND bd_shortid = cm.short_id
                   AND cm.short_id <> '800' -- 031SO
                   AND bd_requestid = cm.request_id
                   AND bd_datetime >= cm.startdatetime - 1.1 / 24
                   AND bd_datetime <= cm.startdatetime + 1.1 / 24; -- 033SO

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO
        l_matching_count                        PLS_INTEGER;

        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_reviprs'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVIPRE_SMS TRUNCATE PARTITION INFO' || l_sepid_to_store;

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

           <<loop_ccontent>>
            FOR ccontentrow IN ccontent (cmasterrow)
            LOOP
                INSERT INTO revipre_sms (
                                revipres_sepid,
                                revipres_shortid,
                                revipres_rowids,
                                revipres_rowid,
                                revipres_charged_amount)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.short_id,
                    cmasterrow.rowid_ppb,
                    ccontentrow.ROWID,
                    cmasterrow.charged_amount); -- 024SO

                l_matching_count := l_matching_count + 1;
            END LOOP loop_ccontent;

            IF l_matching_count = 0
            THEN
                -- Insert index row for missing content CDR
                INSERT INTO revipre_sms (
                                revipres_sepid,
                                revipres_shortid,
                                revipres_rowids,
                                revipres_rowid,
                                revipres_charged_amount)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.short_id,
                    cmasterrow.rowid_ppb,
                    NULL,
                    cmasterrow.charged_amount); -- 024SO
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_reviprs'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            --                    rollback;
            --                    ReturnStatus := 0;
            --                    ErrorCode := SQLCODE;
            --                    ErrorMsg  := := PKG_COMMON.getHardErrorDesc;                    -- 041SO
            --                    RecordsAffected := 0;
            --                    pkg_bdetail_common.INSERT_WARNING (vMePkg, Me, 'PLSQL-ERROR', ErrorMsg , ErrorCode);

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (pkg_common.getharderrordesc))
                || sbsdb_logger_lib.json_other_last ('topic', 'PLSQL-ERROR'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_reviprs'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

            RAISE;
    END sp_cons_reviprs;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revis (
        p_pac_id                                IN     VARCHAR2, -- 'REVIS' -- TODO unused parameter? (wwe)
        p_boh_id                                IN OUT VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        CURSOR cmaster IS
            SELECT /*+ NO_INDEX(BDETAIL1) */
                   ROWID,
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_b,
                   bd_consolidation,
                   bd_billid
            FROM   bdetail1
            WHERE      bd_mapsid = 'R' -- 044SO
                   AND bd_consolidation IS NOT NULL
                   AND bd_tarid IN ('S',
                                    'P',
                                    'T') -- 036SO -- 006SO
                   AND bd_npi_b = '1' -- 006SO
                   AND bd_pid_b = '0' -- 006SO
                   AND bd_datetime >= ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo)
                   AND bd_datetime < ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo + 1) -- AND  BD_BILLID IS NOT NULL                                           -- 015SO -- 010SO (to be removed)
                                                                                          -- AND BD_CONSOLIDATION not in ('333','888')                            -- 014SO -- 013SO
                                                                                          -- AND  BD_DATETIME >= to_date('26.10.2007','dd.mm.yyyy')               -- 004SO
    ; -- 011SO

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR ccontent (cm IN cmaster%ROWTYPE)
        IS -- 001SO
            SELECT /*+ INDEX(BDETAIL IDX_BD_REQUESTID) */
                   ROWID
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 033SO -- 026SO will never match, no BILLID
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_shortid = cm.bd_consolidation
                   AND bd_requestid = cm.bd_billid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') - rconfig.revic_delay_sms_sub / 86400.0
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') + 1.1 / 24; -- 011SO

        l_sepid_to_do                           VARCHAR2 (6); -- 023SO
        l_sepid_to_store                        VARCHAR2 (6); -- 023SO
        l_matching_count                        PLS_INTEGER;

        no_bohid                                EXCEPTION;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revis'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        --Initialize Variables
        recordsaffected := 0;
        returnstatus := 0;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_revi.getconfig;

        l_sepid_to_do := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtodo), 'YYYYMM'); -- 023SO
        l_sepid_to_store := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), monthtostore), 'YYYYMM'); -- 023SO

        EXECUTE IMMEDIATE 'ALTER TABLE REVI_SMS TRUNCATE PARTITION INFO' || l_sepid_to_store; -- 007SO

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            recordsaffected := recordsaffected + 1;
            l_matching_count := 0;

           <<loop_ccontent>>
            FOR ccontentrow IN ccontent (cmasterrow)
            LOOP
                INSERT INTO revi_sms (
                                revis_sepid,
                                revis_shortid,
                                revis_rowid1,
                                revis_rowid)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.bd_consolidation,
                    cmasterrow.ROWID,
                    ccontentrow.ROWID);

                l_matching_count := l_matching_count + 1;
            END LOOP loop_ccontent;

            IF l_matching_count = 0
            THEN
                -- Insert index row for missing content CDR
                INSERT INTO revi_sms (
                                revis_sepid,
                                revis_shortid,
                                revis_rowid1,
                                revis_rowid)
                VALUES      (
                    l_sepid_to_store,
                    cmasterrow.bd_consolidation,
                    cmasterrow.ROWID,
                    NULL);
            END IF;
        END LOOP loop_cmaster;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revis'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            --                    rollback;
            --                    ReturnStatus := 0;
            --                    ErrorCode := SQLCODE;
            --                    ErrorMsg  := := PKG_COMMON.getHardErrorDesc;                    -- 041SO
            --                    RecordsAffected := 0;
            --                    pkg_bdetail_common.INSERT_WARNING (vMePkg, Me, 'PLSQL-ERROR', ErrorMsg , ErrorCode);

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (pkg_common.getharderrordesc))
                || sbsdb_logger_lib.json_other_last ('topic', 'PLSQL-ERROR'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_cons_revis'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

            RAISE;
    END sp_cons_revis;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN revi_config%ROWTYPE
    IS
        vconfig                                 revi_config%ROWTYPE;
    BEGIN
        SELECT *
        INTO   vconfig
        FROM   revi_config
        WHERE  revic_id = 'DEFAULT';

        IF vconfig.revic_debugmode = 1 -- TODO looks very odd (wwe)
        THEN
            bdebug := TRUE;
        ELSE
            bdebug := FALSE;
        END IF;

        RETURN vconfig;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN vconfig;
    END getconfig;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_content_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2)
    -- find and index SMS and MMS transport submits for chargeable content CDRs of the given file
    IS -- 016SO
        me                                      VARCHAR2 (40) := 'REVI_INDEX_CONTENT_FILE';

        CURSOR cmaster IS
            SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                   ROWID,
                   bd_datetime, -- 022SO
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_a,
                   bd_msisdn_b, -- 043SO
                   bd_shortid,
                   bd_service,
                   bd_transportmedium,
                   bd_requestid, -- 033SO -- 026SO
                   bd_msgid,
                   bd_counttr,
                   bd_billed, -- 021SO
                   bd_amountcu, -- 021SO
                   bd_onlinecharge, -- 021SO
                   bd_prepaid, -- 028SO
                   bd_srctype -- 029SO
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 033SO -- 026SO
                   AND bd_bihid = p_bih_id
                   AND bd_mapsid = 'R'
                   AND bd_demo = 0
                   AND bd_billed <> cnotbilledbysbs -- 028SO IN (cBilledBySbs,cZeroChargeIgnore,cIgnoreSubscriber) -- 018SO
                   AND bd_datetime >= SYSDATE - 30
                   AND bd_datetime < SYSDATE + 1; -- 034SO -- 022SO -- 016SO  -- compare to similar conditions in REVI_INDEX_CONTENT_SUB

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR csmssubmit (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BILLID1) */
                   ROWID
            FROM   bdetail1
            WHERE      bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_consolidation = cm.bd_shortid
                   AND bd_status = 4
                   AND bd_billid = cm.bd_requestid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') - 1.1 / 24 -- 045SO
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') + rconfig.revic_delay_sms_sub / 86400.0 -- 045SO
                                                                                                                              ; -- 016SO  -- compare to similar conditions in REVI_INDEX_CONTENT_SUB

        CURSOR csmslongsubmit (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BILLID1) */
                   ROWID
            FROM   bdetail1
            WHERE      bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_consolidation = cm.bd_shortid
                   AND bd_status = 4
                   AND bd_billid = cm.bd_requestid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') - 1.1 / 24 -- 045SO
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'YYYYMMDDHH24MISS') + rconfig.revic_delay_sms_sub / 86400.0 -- 045SO
                                                                                                                              ; -- 016SO  -- compare to similar conditions in REVI_INDEX_CONTENT_SUB

        CURSOR cmmssubmit (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_UMSGGRPID) */
                   ROWID
            FROM   bdetail6
            WHERE      bd_srctype = 'MMSC'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_msgtype = 0
                   AND bd_umsggrpid = cm.bd_msgid
                   AND bd_cdrrectype = 'MM7Orecord'
                   AND bd_eventdisp = 2
                   AND bd_shortid = cm.bd_shortid
                   AND bd_datetime >= cm.bd_datetime - 1.1 / 24
                   AND bd_datetime < cm.bd_datetime + rconfig.revic_delay_mms_sub / 86400.0; -- 022SO -- 016SO  -- compare to similar conditions in REVI_INDEX_CONTENT_SUB

        CURSOR cdsscdrsms (cm IN cmaster%ROWTYPE)
        IS
            SELECT rowid_ppb,
                   0.001 * unit     charged_amount
            FROM   cdrsms -- @DSS
            WHERE      calltype IN (120,
                                    20) -- 026SO
                   -- AND NVL(TRANSPORT_MEDIUM,'SMS') = 'SMS'                              -- 046SO
                   AND request_id = cm.bd_requestid || '_' || cm.bd_msisdn_a; -- 024SO -- 022SO -- 021SO

        CURSOR cdsscdrmms (cm IN cmaster%ROWTYPE)
        IS
            SELECT rowid_ppb,
                   0.001 * unit     charged_amount
            FROM   cdrmms -- @DSS
            WHERE      calltype = 121
                   -- AND NVL(TRANSPORT_MEDIUM,'MMS') = 'MMS'                              -- 046SO
                   AND request_id = cm.bd_requestid || '_' || cm.bd_msisdn_a; -- 024SO -- 022SO -- 021SO

        l_sepid                                 VARCHAR2 (6);
        l_matching_count                        PLS_INTEGER;
        l_update_count                          PLS_INTEGER; -- 022SO
        l_amount_charged                        FLOAT; -- 022SO
    BEGIN
        rconfig := pkg_revi.getconfig;

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            l_sepid := TO_CHAR (cmasterrow.bd_datetime, 'YYYYMM');
            -- Search for transport submit
            l_matching_count := 0;

            IF     cmasterrow.bd_transportmedium = 'SMS'
               AND cmasterrow.bd_counttr <= 1
            THEN -- 028SO
                FOR csmssubmitrow IN csmssubmit (cmasterrow)
                LOOP
                    l_update_count := 0;

                    IF l_matching_count = 0
                    THEN
                        -- must check if orphan entry needs update
                        UPDATE revi_content_sub
                        SET    revics_rowid_slave = csmssubmitrow.ROWID,
                               revics_count_expected = cmasterrow.bd_counttr
                        WHERE      revics_sepid = l_sepid
                               AND revics_shortid = cmasterrow.bd_shortid
                               AND revics_table_slave = 'BDETAIL1'
                               AND revics_rowid_master = cmasterrow.ROWID;

                        l_update_count := SQL%ROWCOUNT;
                    END IF;

                    IF l_update_count = 0
                    THEN
                        INSERT INTO revi_content_sub (
                                        revics_sepid,
                                        revics_shortid,
                                        revics_rowid_master,
                                        revics_count_expected,
                                        revics_table_slave,
                                        revics_rowid_slave)
                        VALUES      (
                            l_sepid,
                            cmasterrow.bd_shortid,
                            cmasterrow.ROWID,
                            cmasterrow.bd_counttr,
                            'BDETAIL1',
                            csmssubmitrow.ROWID);
                    END IF;

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL1',
                        NULL);

                    IF cmasterrow.bd_counttr > 0
                    THEN -- 033SO -- 029SO
                        sbsdb_error_lib.LOG (
                            0,
                               sbsdb_logger_lib.json_other_first ('errormsg', 'Missing SMS Submit CDR for Content CDR')
                            || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                            || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                            || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                            || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                            || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_shortid),
                            sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_content_file'),
                            sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                            sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
                    END IF;
                END IF;
            ELSIF     cmasterrow.bd_transportmedium = 'SMS'
                  AND cmasterrow.bd_counttr > 1
            THEN
                FOR csmslongsubmitrow IN csmslongsubmit (cmasterrow)
                LOOP
                    l_update_count := 0;

                    IF l_matching_count = 0
                    THEN
                        -- must check if orphan entry needs update
                        UPDATE revi_content_sub
                        SET    revics_rowid_slave = csmslongsubmitrow.ROWID,
                               revics_count_expected = cmasterrow.bd_counttr
                        WHERE      revics_sepid = l_sepid
                               AND revics_shortid = cmasterrow.bd_shortid
                               AND revics_table_slave = 'BDETAIL1'
                               AND revics_rowid_master = cmasterrow.ROWID;

                        l_update_count := SQL%ROWCOUNT;
                    END IF;

                    IF l_update_count = 0
                    THEN
                        INSERT INTO revi_content_sub (
                                        revics_sepid,
                                        revics_shortid,
                                        revics_rowid_master,
                                        revics_count_expected,
                                        revics_table_slave,
                                        revics_rowid_slave)
                        VALUES      (
                            l_sepid,
                            cmasterrow.bd_shortid,
                            cmasterrow.ROWID,
                            cmasterrow.bd_counttr,
                            'BDETAIL1',
                            csmslongsubmitrow.ROWID);
                    END IF;

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        cmasterrow.bd_counttr,
                        'BDETAIL1',
                        NULL);

                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_first ('errormsg', 'Missing SMS Submit CDR for Content CDR')
                        || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                        || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                        || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_shortid),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_content_file'),
                        sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                        sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
                END IF;
            ELSIF     cmasterrow.bd_transportmedium = 'SMS'
                  AND cmasterrow.bd_counttr IS NULL
            THEN
                NULL; -- cannot index this SMS content (
            ELSIF cmasterrow.bd_transportmedium = 'MMS'
            THEN
                FOR cmmssubmitrow IN cmmssubmit (cmasterrow)
                LOOP
                    l_update_count := 0;

                    IF l_matching_count = 0
                    THEN
                        -- must check if orphan entry needs update
                        UPDATE revi_content_sub
                        SET    revics_rowid_slave = cmmssubmitrow.ROWID,
                               revics_count_expected = NVL (cmasterrow.bd_counttr, 1)
                        WHERE      revics_sepid = l_sepid
                               AND revics_shortid = cmasterrow.bd_shortid
                               AND revics_table_slave = 'BDETAIL6'
                               AND revics_rowid_master = cmasterrow.ROWID;

                        l_update_count := SQL%ROWCOUNT;
                    END IF;

                    IF l_update_count = 0
                    THEN
                        INSERT INTO revi_content_sub (
                                        revics_sepid,
                                        revics_shortid,
                                        revics_rowid_master,
                                        revics_count_expected,
                                        revics_table_slave,
                                        revics_rowid_slave)
                        VALUES      (
                            l_sepid,
                            cmasterrow.bd_shortid,
                            cmasterrow.ROWID,
                            NVL (cmasterrow.bd_counttr, 1),
                            'BDETAIL6',
                            cmmssubmitrow.ROWID);
                    END IF;

                    l_matching_count := l_matching_count + 1;
                END LOOP;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing transport CDR
                    INSERT INTO revi_content_sub (
                                    revics_sepid,
                                    revics_shortid,
                                    revics_rowid_master,
                                    revics_count_expected,
                                    revics_table_slave,
                                    revics_rowid_slave)
                    VALUES      (
                        l_sepid,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        NVL (cmasterrow.bd_counttr, 1),
                        'BDETAIL6',
                        NULL);

                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_first ('errormsg', 'Missing MMS Submit CDR for Content CDR')
                        || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                        || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                        || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_shortid),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_content_file'),
                        sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                        sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
                END IF;
            END IF; -- Search for transport submit

            -- Search for prepaid charging records
            IF cmasterrow.bd_prepaid = 'Y'
            THEN -- 028SO (cMasterRow.BD_AMOUNTCU <> 0.00 OR cMasterRow.BD_ONLINECHARGE IS NOT NULL) then
                -- if cMasterRow.BD_ONLINECHARGE IS NOT NULL then  -- 025SO   -- $$$$$$$$$ remove after VASOL migration
                -- can only find charge if online billed (missing RequestID otherwise)
                l_matching_count := 0;
                l_amount_charged := 0.00;

                IF cmasterrow.bd_transportmedium = 'SMS'
                THEN
                    FOR cdsscdrsmsrow IN cdsscdrsms (cmasterrow)
                    LOOP
                        l_update_count := 0;

                        IF l_matching_count = 0
                        THEN
                            -- must check if orphan entry needs update
                            UPDATE revi_pre
                            SET    revipre_rowid_slave = cdsscdrsmsrow.rowid_ppb,
                                   revipre_charged_amount = cdsscdrsmsrow.charged_amount
                            WHERE      revipre_sepid = l_sepid
                                   AND revipre_shortid = cmasterrow.bd_shortid
                                   AND revipre_table_slave = 'CDR' || cmasterrow.bd_transportmedium
                                   AND revipre_rowid_master = cmasterrow.ROWID; -- 024SO

                            l_update_count := SQL%ROWCOUNT;
                        END IF;

                        IF l_update_count = 0
                        THEN
                            INSERT INTO revi_pre (
                                            revipre_sepid,
                                            revipre_shortid,
                                            revipre_rowid_master,
                                            revipre_table_slave,
                                            revipre_rowid_slave,
                                            revipre_charged_amount)
                            VALUES      (
                                l_sepid,
                                cmasterrow.bd_shortid,
                                cmasterrow.ROWID,
                                'CDR' || cmasterrow.bd_transportmedium,
                                cdsscdrsmsrow.rowid_ppb,
                                cdsscdrsmsrow.charged_amount); -- 024SO
                        END IF;

                        l_matching_count := l_matching_count + 1;
                        l_amount_charged := l_amount_charged + cdsscdrsmsrow.charged_amount;
                    END LOOP;
                ELSIF cmasterrow.bd_transportmedium = 'MMS'
                THEN
                    FOR cdsscdrmmsrow IN cdsscdrmms (cmasterrow)
                    LOOP
                        l_update_count := 0;

                        IF l_matching_count = 0
                        THEN
                            -- must check if orphan entry needs update
                            UPDATE revi_pre
                            SET    revipre_rowid_slave = cdsscdrmmsrow.rowid_ppb,
                                   revipre_charged_amount = cdsscdrmmsrow.charged_amount
                            WHERE      revipre_sepid = l_sepid
                                   AND revipre_shortid = cmasterrow.bd_shortid
                                   AND revipre_table_slave = 'CDR' || cmasterrow.bd_transportmedium
                                   AND revipre_rowid_master = cmasterrow.ROWID; -- 024SO

                            l_update_count := SQL%ROWCOUNT;
                        END IF;

                        IF l_update_count = 0
                        THEN
                            INSERT INTO revi_pre (
                                            revipre_sepid,
                                            revipre_shortid,
                                            revipre_rowid_master,
                                            revipre_table_slave,
                                            revipre_rowid_slave,
                                            revipre_charged_amount)
                            VALUES      (
                                l_sepid,
                                cmasterrow.bd_shortid,
                                cmasterrow.ROWID,
                                'CDR' || cmasterrow.bd_transportmedium,
                                cdsscdrmmsrow.rowid_ppb,
                                cdsscdrmmsrow.charged_amount); -- 024SO
                        END IF;

                        l_matching_count := l_matching_count + 1;
                        l_amount_charged := l_amount_charged + cdsscdrmmsrow.charged_amount;
                    END LOOP;
                END IF;

                IF l_matching_count = 0
                THEN
                    -- Insert index row for missing charge record
                    INSERT INTO revi_pre (
                                    revipre_sepid,
                                    revipre_shortid,
                                    revipre_rowid_master,
                                    revipre_table_slave,
                                    revipre_rowid_slave,
                                    revipre_charged_amount)
                    VALUES      (
                        l_sepid,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        'CDR' || cmasterrow.bd_transportmedium,
                        NULL,
                        NULL);
                END IF;

                IF l_amount_charged < cmasterrow.bd_amountcu
                THEN
                    -- underbilling (code opposite to other warnings in this procedure)
                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_add (
                               'errormsg',
                               'Rated amount: ' || TO_CHAR (cmasterrow.bd_amountcu) || ' Online charged: ' || TO_CHAR (l_amount_charged) || ' in ' || TO_CHAR (l_matching_count) || ' records')
                        || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                        || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                        || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_shortid),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_content_file'),
                        sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                        sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
                ELSIF l_amount_charged > cmasterrow.bd_amountcu
                THEN
                    -- overbilling (code similar to other warnings in this procedure)
                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_add (
                               'errormsg',
                               'Rated amount: ' || TO_CHAR (cmasterrow.bd_amountcu) || ' Online charged: ' || TO_CHAR (l_amount_charged) || ' in ' || TO_CHAR (l_matching_count) || ' records')
                        || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                        || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                        || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_shortid),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_content_file'),
                        sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                        sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
                END IF;
            -- end if;   -- 025SO     -- $$$$$$$$$ remove after VASOL migration
            END IF;
        END LOOP loop_cmaster;
    --    EXCEPTION
    --            when Others then
    --                    l_ErrorCode := SQLCODE;
    --                    l_ErrorMsg := PKG_COMMON.getHardErrorDesc;                      -- 041SO
    --                    PKG_COMMON.INSERT_WARNING (
    --                        vMePkg,
    --                        Me,
    --                        'PLSQL-ERROR',
    --                        l_ErrorMsg ,
    --                        p_BIH_ID,
    --                        p_BOH_ID,
    --                        NULL,
    --                        NULL,
    --                        l_ErrorCode
    --                    );  -- 042SO -- 039SO
    --        RAISE;
    END revi_index_content_file;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_mms_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2)
    IS -- 016SO
        me                                      VARCHAR2 (40) := 'REVI_INDEX_MMS_FILE';

        CURSOR cmaster IS
            SELECT /*+ INDEX(BDETAIL6 IDX_BD_BIHID6) */
                   ROWID,
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_b,
                   bd_shortid,
                   bd_umsggrpid
            FROM   bdetail6
            WHERE      bd_srctype = 'MMSC'
                   AND bd_bihid = p_bih_id
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msgtype = 0
                   AND bd_cdrrectype = 'MM7Orecord'
                   AND bd_tarid IN ('S',
                                    'P',
                                    'T') -- 036SO
                   AND bd_eventdisp = 2
                   AND bd_datetime >= SYSDATE - 30
                   AND bd_datetime < SYSDATE + 1; -- 034SO -- 016SO  -- compare to similar conditions in REVI_INDEX_MMS

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR ccontent (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL IDX_BD_MSGID) */
                   ROWID
            FROM   bdetail
            WHERE      bd_srctype = 'ISRV'
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_shortid = cm.bd_shortid
                   AND bd_msgid = cm.bd_umsggrpid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') - rconfig.revic_delay_mms_sub / 86400.0
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') + 1.1 / 24; -- 016SO  -- compare to similar conditions in REVI_INDEX_MMS

        l_sepid                                 VARCHAR2 (6);
        l_matching_count                        PLS_INTEGER;
        l_update_count                          PLS_INTEGER;
        l_errorcode                             NUMBER;
        l_errormsg                              VARCHAR2 (2000);
    BEGIN
        rconfig := pkg_revi.getconfig;

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            l_sepid := SUBSTR (cmasterrow.bd_datetime_str, 1, 6);
            l_matching_count := 0;

           <<loop_ccontent>>
            FOR ccontentrow IN ccontent (cmasterrow)
            LOOP
                l_update_count := 0;

                IF l_matching_count = 0
                THEN
                    -- must check if orphan entry needs update
                    UPDATE revi_mms
                    SET    revim_rowid = ccontentrow.ROWID
                    WHERE      revim_sepid = l_sepid
                           AND revim_shortid = cmasterrow.bd_shortid
                           AND revim_rowid6 = cmasterrow.ROWID;

                    l_update_count := SQL%ROWCOUNT;
                END IF;

                IF l_update_count = 0
                THEN
                    INSERT INTO revi_mms (
                                    revim_sepid,
                                    revim_shortid,
                                    revim_rowid6,
                                    revim_rowid)
                    VALUES      (
                        l_sepid,
                        cmasterrow.bd_shortid,
                        cmasterrow.ROWID,
                        ccontentrow.ROWID);
                END IF;

                l_matching_count := l_matching_count + 1;
            END LOOP loop_ccontent;

            IF l_matching_count = 0
            THEN
                -- Insert index row for missing transport CDR
                INSERT INTO revi_mms (
                                revim_sepid,
                                revim_shortid,
                                revim_rowid6,
                                revim_rowid)
                VALUES      (
                    l_sepid,
                    cmasterrow.bd_shortid,
                    cmasterrow.ROWID,
                    NULL);

                sbsdb_error_lib.LOG (
                    0,
                       sbsdb_logger_lib.json_other_first ('errormsg', 'Missing Content CDR for MMS submit')
                    || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                    || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                    || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                    || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                    || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_shortid),
                    sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_mms_file'),
                    sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                    sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
            END IF;
        END LOOP loop_cmaster;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_errorcode := SQLCODE;
            l_errormsg := pkg_common.getharderrordesc; -- 041SO
            sbsdb_error_lib.LOG (
                l_errorcode,
                   sbsdb_logger_lib.json_other_first ('errormsg', l_errormsg)
                || sbsdb_logger_lib.json_other_add ('topic', 'PLSQL-ERROR')
                || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                || sbsdb_logger_lib.json_other_add ('bd_id')
                || sbsdb_logger_lib.json_other_last ('short_id'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_mms_file'),
                sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 042SO-- 039SO
            RAISE;
    END revi_index_mms_file;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_sms_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2)
    IS -- 016SO
        me                                      VARCHAR2 (40) := 'REVI_INDEX_SMS_FILE';

        CURSOR cmaster IS
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BIHID1) */
                   ROWID,
                   TO_CHAR (bd_datetime, 'yyyymmddhh24miss')     AS bd_datetime_str,
                   bd_msisdn_b,
                   bd_consolidation,
                   bd_billid
            FROM   bdetail1
            WHERE      bd_mapsid = 'R' -- 044SO
                   AND bd_bihid = p_bih_id
                   AND bd_consolidation IS NOT NULL
                   AND bd_tarid IN ('S',
                                    'P',
                                    'T') -- 036SO
                   AND bd_demo = 0
                   AND bd_npi_b = '1'
                   AND bd_pid_b = '0'
                   AND bd_datetime >= SYSDATE - 30
                   AND bd_datetime < SYSDATE + 1; -- 034SO -- 016SO  -- compare to similar conditions in REVI_INDEX_SMS

        cmasterrow                              cmaster%ROWTYPE;

        CURSOR ccontent (cm IN cmaster%ROWTYPE)
        IS
            SELECT /*+ INDEX(BDETAIL IDX_BD_REQUESTID) */
                   ROWID
            FROM   bdetail
            WHERE      bd_srctype IN ('ISRV') -- 033SO  -- 026SO OTA will not match, wrong requestID
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_msisdn_b = cm.bd_msisdn_b -- 043SO
                   AND bd_shortid = cm.bd_consolidation
                   AND bd_requestid = cm.bd_billid
                   AND bd_datetime >= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') - rconfig.revic_delay_sms_sub / 86400.0
                   AND bd_datetime <= TO_DATE (cm.bd_datetime_str, 'yyyymmddhh24miss') + 1.1 / 24; -- 016SO  -- compare to similar conditions in REVI_INDEX_SMS

        l_sepid                                 VARCHAR2 (6);
        l_matching_count                        PLS_INTEGER;
        l_update_count                          PLS_INTEGER;
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (2000);
    BEGIN
        rconfig := pkg_revi.getconfig;

       <<loop_cmaster>>
        FOR cmasterrow IN cmaster
        LOOP
            -- Analyze master CDR
            l_sepid := SUBSTR (cmasterrow.bd_datetime_str, 1, 6);
            l_matching_count := 0;

           <<loop_ccontent>>
            FOR ccontentrow IN ccontent (cmasterrow)
            LOOP
                l_update_count := 0;

                IF l_matching_count = 0
                THEN
                    -- must check if orphan entry needs update
                    UPDATE revi_sms
                    SET    revis_rowid = ccontentrow.ROWID
                    WHERE      revis_sepid = l_sepid
                           AND revis_shortid = cmasterrow.bd_consolidation
                           AND revis_rowid1 = cmasterrow.ROWID;

                    l_update_count := SQL%ROWCOUNT;
                END IF;

                IF l_update_count = 0
                THEN
                    INSERT INTO revi_sms (
                                    revis_sepid,
                                    revis_shortid,
                                    revis_rowid1,
                                    revis_rowid)
                    VALUES      (
                        l_sepid,
                        cmasterrow.bd_consolidation,
                        cmasterrow.ROWID,
                        ccontentrow.ROWID);
                END IF;

                l_matching_count := l_matching_count + 1;
            END LOOP loop_ccontent;

            IF l_matching_count = 0
            THEN
                -- Insert index row for missing transport CDR
                INSERT INTO revi_sms (
                                revis_sepid,
                                revis_shortid,
                                revis_rowid1,
                                revis_rowid)
                VALUES      (
                    l_sepid,
                    cmasterrow.bd_consolidation,
                    cmasterrow.ROWID,
                    NULL);

                IF cmasterrow.bd_consolidation <> '800'
                THEN -- 029SO
                    sbsdb_error_lib.LOG (
                        0,
                           sbsdb_logger_lib.json_other_first ('errormsg', 'Missing Content CDR for SMS submit')
                        || sbsdb_logger_lib.json_other_add ('topic', cmasterrow.bd_datetime_str)
                        || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id', TO_CHAR (cmasterrow.ROWID))
                        || sbsdb_logger_lib.json_other_last ('short_id', cmasterrow.bd_consolidation),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_sms_file'),
                        sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                        sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 039SO
                END IF;
            END IF;
        END LOOP loop_cmaster;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_errorcode := SQLCODE;
            l_errormsg := pkg_common.getharderrordesc; -- 041SO
            sbsdb_error_lib.LOG (
                l_errorcode,
                   sbsdb_logger_lib.json_other_first ('errormsg', l_errormsg)
                || sbsdb_logger_lib.json_other_add ('topic', 'PLSQL-ERROR')
                || sbsdb_logger_lib.json_other_add ('bih_id', p_bih_id)
                || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                || sbsdb_logger_lib.json_other_add ('bd_id')
                || sbsdb_logger_lib.json_other_last ('short_id'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'revi_index_sms_file'),
                sbsdb_logger_lib.log_param ('bih_id', p_bih_id),
                sbsdb_logger_lib.log_param ('boh_id', p_boh_id)); -- 042SO-- 039SO
            RAISE;
    END revi_index_sms_file;
END pkg_revi;
/