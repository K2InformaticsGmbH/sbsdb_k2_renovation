CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_bdetail_msc
AS
    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_msccu_update (
        batchsize                               IN     INTEGER,
        p_bd_srctype                            IN     VARCHAR2,
        p_bd_demo                               IN     NUMBER,
        p_bd_pacsid                             IN     VARCHAR2,
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                         IN OUT NUMBER);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION add_smsc_code_to_unknown_toc (
        p_smsc_code                             IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_smsc_id                               VARCHAR2 (10);
        l_con_opkey_of_unknowntoc               VARCHAR2 (10);
    BEGIN
        l_con_opkey_of_unknowntoc := '0';

        SELECT generateuniquekey ('G') INTO l_smsc_id FROM DUAL;

        INSERT INTO smsc (
                        smsc_id,
                        smsc_conopkey,
                        smsc_code,
                        smsc_datecre,
                        smsc_acidcre,
                        smsc_chngcnt)
        VALUES      (
            l_smsc_id,
            l_con_opkey_of_unknowntoc,
            p_smsc_code,
            SYSDATE,
            'ADMIN',
            0);

        returnstatus := 1;
        RETURN l_smsc_id;
    -- Commit; -- $$
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SUBSTR (SQLERRM, 1, 50);
            returnstatus := 0;
            RETURN '';
    --RollBack;
    END add_smsc_code_to_unknown_toc;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION get_smsc_id (
        p_bd_sca                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_smsc_code                             VARCHAR2 (20);
        l_smsc_id                               VARCHAR2 (10);

        CURSOR c1 (a_smsc_code IN VARCHAR2)
        IS
            SELECT smsc_id
            FROM   smsc
            WHERE  smsc_code = a_smsc_code;
    BEGIN
        l_smsc_code := p_bd_sca;

        OPEN c1 (l_smsc_code);

        FETCH c1 INTO l_smsc_id;

        IF c1%FOUND
        THEN
            -- Smsc Id for given Code found, do nothing, just return the Smsc Id
            NULL;
        ELSE
            -- Smsc Id for given Code not found, do something, add the given Code
            -- to the dummy Operator Contract 'UNKNOWNTOC'. And then returnt the
            -- Smsc Id of the newly added Smsc Code
            l_smsc_id := add_smsc_code_to_unknown_toc (l_smsc_code, errorcode, errormsg, returnstatus);
        END IF;

        CLOSE c1;

        returnstatus := 1;
        RETURN l_smsc_id;
    -- Commit; -- $$
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SUBSTR (SQLERRM, 1, 50);
            returnstatus := 0;
            RETURN '';
    --RollBack;
    END get_smsc_id;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_try_msccu (
        p_pac_id                                IN     VARCHAR2, -- 'MSCCU'
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --  008SO
        CURSOR ccheckcandidate (max_age IN PLS_INTEGER)
        IS
            SELECT /*+ INDEX(BDETAIL4 IDX_BD_PACSID14) */
                   'dummy'
            FROM   bdetail4
            WHERE      bd_demo = 0
                   AND bd_srctype = 'MSC'
                   AND bd_mapsid = 'R'
                   AND ROWNUM <= 1
                   AND bd_cdrtid = 'MSC-MT'
                   AND bd_imsi LIKE '22801%'
                   AND bd_pacsid1 = 'S'
                   AND bd_datetime > SYSDATE - max_age
                   AND bd_datetime < SYSDATE + 3 / 24;

        l_max_age                               PLS_INTEGER;
        l_batch_count                           PLS_INTEGER;
        l_marked_count                          PLS_INTEGER;
        l_dummy                                 VARCHAR2 (10);
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_msccu'),
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
            UPDATE /*+ INDEX(BDETAIL4 IDX_BD_PACSID14) */
                   bdetail4
            SET    bd_bohid1 = p_boh_id,
                   bd_pacsid1 = 'P'
            WHERE      bd_demo = 0
                   AND bd_srctype = 'MSC'
                   AND bd_mapsid = 'R'
                   AND ROWNUM <= l_batch_count
                   AND bd_cdrtid = 'MSC-MT'
                   AND bd_imsi LIKE '22801%'
                   AND bd_pacsid1 = 'S'
                   AND bd_datetime > SYSDATE - l_max_age
                   AND bd_datetime < SYSDATE + 3 / 24;

            l_marked_count := SQL%ROWCOUNT;

            IF l_marked_count > 0
            THEN
                sp_msccu_update (
                    l_marked_count,
                    'MSC',
                    0,
                    NULL,
                    p_boh_id,
                    l_max_age,
                    errorcode,
                    errormsg,
                    recordsaffected);

                IF recordsaffected = l_marked_count
                THEN
                    -- mark rows as processed                                       --  009SO
                    UPDATE /*+ INDEX(BDETAIL4 IDX_BD_BOHID14) */
                           bdetail4
                    SET    bd_pacsid1 = 'D'
                    WHERE      bd_bohid1 = p_boh_id
                           AND bd_pacsid1 = 'P';

                    l_marked_count := SQL%ROWCOUNT;
                ELSE
                    ROLLBACK;
                    sbsdb_error_lib.LOG (
                        SQLCODE,
                           sbsdb_logger_lib.json_other_first ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('errormsg', 'Mismatch in marked/processed SMS CDR counts (' || l_marked_count || '/' || recordsaffected || ')')
                        || sbsdb_logger_lib.json_other_last ('topic', 'PROCESSING ERROR'),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_msccu'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id));
                    returnstatus := pkg_common.return_status_failure;
                END IF;
            END IF;
        END IF;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_msccu'),
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
    END sp_try_msccu;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_msccu_update (
        batchsize                               IN     INTEGER, -- TODO unused parameter? (wwe)
        p_bd_srctype                            IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_bd_demo                               IN     NUMBER, -- TODO unused parameter? (wwe)
        p_bd_pacsid                             IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_bd_bohid                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                         IN OUT NUMBER)
    IS
        l_bd_smscid                             VARCHAR2 (10);

        CURSOR c1 (
            a_boh_id                                IN VARCHAR2,
            a_maxage                                IN NUMBER)
        IS
            SELECT /*+ INDEX(BDETAIL4 IDX_BD_BOHID14) */
                   bdetail4.ROWID,
                   bd_smscid,
                   bd_datetime
            FROM   bdetail4
            WHERE      bd_bohid1 = a_boh_id
                   AND bd_datetime > SYSDATE - a_maxage
                   AND bd_datetime < SYSDATE + 3 / 24;
    BEGIN
        recordsaffected := 0;

        FOR c1_rec IN c1 (p_bd_bohid, p_maxage)
        LOOP
            BEGIN
                l_bd_smscid := c1_rec.bd_smscid;

                -- Increment the counter by 1 when updating the count for an existing SMSC ID
                UPDATE iwtcounter
                SET    iwtc_count = iwtc_count + 1
                WHERE      iwtc_smscid = l_bd_smscid
                       AND iwtc_date = TRUNC (c1_rec.bd_datetime)
                       AND iwtc_esid = 'A';

                IF SQL%NOTFOUND
                THEN
                    -- If the counter does not exist, insert a new one
                    -- Initialise the counter with 1 when inserting the count for a new SMSC ID,
                    -- set the Counter state to 'A'ccumulating
                    INSERT INTO iwtcounter (
                                    iwtc_date,
                                    iwtc_smscid,
                                    iwtc_count,
                                    iwtc_esid)
                    VALUES      (
                        TRUNC (c1_rec.bd_datetime),
                        l_bd_smscid,
                        1,
                        'A');

                    recordsaffected := recordsaffected + 1;
                ELSE
                    -- Counter was updated, ,increment the record count by the rows updated
                    recordsaffected := recordsaffected + SQL%ROWCOUNT;
                END IF;
            END;
        END LOOP;

        -- commit; -- $$
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            recordsaffected := 0;
    END sp_msccu_update;
END pkg_bdetail_msc;
/