CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_reva
IS
    /* =========================================================================
       REVA States.
       ---------------------------------------------------------------------- */

    TYPE t_revaesid IS RECORD
    (
        active reva_state.revas_id%TYPE := 'A',
        inactive reva_state.revas_id%TYPE := 'I',
        deleted reva_state.revas_id%TYPE := 'D',
        scheduled reva_state.revas_id%TYPE := 'S',
        done reva_state.revas_id%TYPE := 'O',
        error reva_state.revas_id%TYPE := 'E',
        suspended reva_state.revas_id%TYPE := 'U'
    );

    rrevaesid                               t_revaesid;

    /* =========================================================================
       Globals.
       ---------------------------------------------------------------------- */

    bdebug                                  BOOLEAN;
    rconfig                                 reva_config%ROWTYPE;
    vmepkg                                  VARCHAR2 (30) := 'PKG_REVA';

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN reva_config%ROWTYPE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE reva_recent (
        p_pac_id                                IN     VARCHAR2, -- 023SO
        p_desc                                  IN     VARCHAR2, -- 012SO
        p_sqlstmsrctype                         IN     VARCHAR2, -- 014SO
        p_sqlstmmapid                           IN     VARCHAR2, -- 027SO
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    ----------------------------------------------------------------------
    -- Stubs for different XPIOCs
    ----------------------------------------------------------------------

    PROCEDURE sp_try_reva_recent_msc (
        p_pac_id                                IN     VARCHAR2, -- 023SO
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_reva_recent_msc'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        reva_recent (
            p_pac_id,
            'REVA-MSC',
            '''MSC''', -- 027SO 'SELECT SRCT_ID FROM SRCTYPE WHERE SRCT_ID = ''MSC'' MINUS SELECT DISTINCT REVAH_SRCTYPE FROM REVA_HEADER WHERE REVAH_ESID = ''U''',
            NULL, -- 027SO
            p_boh_id,
            recordsaffected,
            errorcode,
            errormsg,
            returnstatus);

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_reva_recent_msc'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    END sp_try_reva_recent_msc;

    PROCEDURE sp_try_reva_recent_others (
        p_pac_id                                IN     VARCHAR2, -- 023SO
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_reva_recent_others'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        -- vHeaderAllStm := 'select * from reva_header where revah_esid = '''||rRevaEsid.active||''' and revah_srctype not like ''MSC''';  -- 010SO
        -- vSrctypeStm := 'select srct_id from srctype where srct_id not like ''MSC''';
        reva_recent (
            p_pac_id,
            'REVA-OTHERS',
            '''ISRV'',''MMSC'',''STAN''', -- 029SO  'SELECT SRCT_ID FROM SRCTYPE WHERE SRCT_ID not in (''MSC'',''SMSC'') MINUS SELECT DISTINCT REVAH_SRCTYPE FROM REVA_HEADER WHERE REVAH_ESID = ''U''',
            NULL, -- 027SO
            p_boh_id,
            recordsaffected,
            errorcode,
            errormsg,
            returnstatus); -- 026SO -- 023SO

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_reva_recent_others'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    END sp_try_reva_recent_others;

    PROCEDURE sp_try_reva_recent_smsc (
        p_pac_id                                IN     VARCHAR2, -- 023SO
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_reva_recent_smsc'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));

        reva_recent (
            p_pac_id,
            'REVA-SMSC',
            '''SMSC'',''SMSN''', -- 036SO -- 027SO 'SELECT SRCT_ID FROM SRCTYPE WHERE SRCT_ID = ''SMSC'' MINUS SELECT DISTINCT REVAH_SRCTYPE FROM REVA_HEADER WHERE REVAH_ESID = ''U''',
            NULL, -- 028SO '''' || SUBSTR(p_PAC_ID,5) || '''', -- 027SO
            p_boh_id,
            recordsaffected,
            errorcode,
            errormsg,
            returnstatus); -- 023SO

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_try_reva_recent_smsc'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    END sp_try_reva_recent_smsc;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN reva_config%ROWTYPE
    IS
        vconfig                                 reva_config%ROWTYPE;
    BEGIN
        SELECT *
        INTO   vconfig
        FROM   reva_config
        WHERE  revac_id = 'DEFAULT';

        IF vconfig.revac_debugmode = 1
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

    ----------------------------------------------------------------------
    -- Main analysis logic
    ----------------------------------------------------------------------

    PROCEDURE reva_recent (
        p_pac_id                                IN     VARCHAR2, -- 023SO
        p_desc                                  IN     VARCHAR2, -- 012SO -- TODO unused parameter? (wwe)
        p_sqlstmsrctype                         IN     VARCHAR2, -- 014SO
        p_sqlstmmapid                           IN     VARCHAR2, -- 027SO
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        me                                      VARCHAR2 (15) := 'REVA_RECENT';

        TYPE t_filedetails IS RECORD
        ( --Biheader file details
            bih_reccount biheader.bih_reccount%TYPE,
            bih_esid biheader.bih_esid%TYPE,
            bih_datetime biheader.bih_datetime%TYPE
        );

        rfiledetailsrow                         t_filedetails;

        TYPE t_knownsignature IS RECORD
        ( --Signature details
            bd_datetime DATE, -- 004SO
            revasm_id reva_sigmask.revasm_id%TYPE,
            incount NUMBER,
            outcount NUMBER
        );

        rknownsignature                         t_knownsignature;

        TYPE t_unknownsignature IS RECORD
        ( --Signature details for unknown Signatures
            bd_datetime DATE, -- 004SO
            revasm_code reva_sigmask.revasm_code%TYPE,
            incount NUMBER,
            outcount NUMBER
        );

        runknownsignature                       t_unknownsignature;

        TYPE trefcur IS REF CURSOR; --Dynamic Cursor Variables

        cvcurvar                                trefcur;
        cvcurvarbi                              trefcur;

        CURSOR cmatchingrevaheader (currentbihid IN VARCHAR2)
        IS -- 010SO
            SELECT revah_id,
                   revah_srctype,
                   revah_pacid,
                   revah_billingtype,
                   revah_billeditem,
                   revah_sql,
                   revah_esid,
                   revah_insql,
                   revah_newsigsql
            FROM   reva_header,
                   biheader
            WHERE      revah_esid = rrevaesid.active
                   AND revah_srctype = bih_srctype
                   AND bih_id = currentbihid;

        cmatchingrevaheaderrow                  cmatchingrevaheader%ROWTYPE;

        CURSOR csigmaskid (
            revah_id                                IN VARCHAR2,
            revasm_code                             IN VARCHAR2)
        IS -- 038SO
            SELECT revasm_id
            FROM   reva_sigmask
            WHERE      revasm_revahid = revah_id
                   AND revasm_code = revasm_code -- TODO looks very odd (wwe)
                   AND revasm_esid = 'A';

        bihrevasid                              biheader.bih_revasid%TYPE;

        currentbihid                            biheader.bih_id%TYPE;

        starttime                               DATE;

        incount                                 NUMBER;
        partialincount                          NUMBER; -- 018SO
        incountanalyzed                         NUMBER;
        reccountdone                            NUMBER;

        cachedsqlstmincount                     VARCHAR2 (4000);
        cachedincount                           NUMBER;

        sqlstm                                  VARCHAR2 (4000);
        sqlstmbiheader                          VARCHAR2 (4000); -- 013SO

        newsigmaskid                            reva_sigmask.revasm_id%TYPE; -- 020SO

        no_bohid                                EXCEPTION;
    BEGIN
        --Initialize Variables
        starttime := SYSDATE;
        recordsaffected := 0;
        returnstatus := 0;
        reccountdone := 0;
        incount := 0;
        sqlstm := NULL;
        cachedsqlstmincount := NULL;
        newsigmaskid := NULL;

        --Read Config-Table of REVA_CONFIG
        rconfig := pkg_reva.getconfig;

        --We would like to analyze a certain amount of reccords (see reva_config.revac_batchnorecords
        --Analyze all not-yet analyzed biheader files for all possible input - output pairs -> reva_sigmask
        --Therefore get the latest, not yet Analyzed BIHEADER file for specific CALLER (e.g. MSC or others)
        --Prepare dynamic Cursor Statement
        sqlstmbiheader := 'select /*+ INDEX (BIHEADER IDX_BIH_REVASID) */ BIH_ID
            FROM    BIHEADER
            WHERE   BIH_DATETIME >= sysdate - ' || rconfig.revac_file_max_age || '/24/3600
            AND     BIH_DATETIME <= sysdate - ' || rconfig.revac_file_min_age || '/24/3600
            AND     BIH_SRCTYPE IN (' || p_sqlstmsrctype || ')
            AND     BIH_ESID in (''RDY'',''ERR'', ''IDX'', ''IDE'', ''idx'', ''ide'')
            AND     BIH_REVASID=''S''
            AND     ROWNUM <= 1'; -- 026SO -- 025SO -- 021SO -- 019SO -- 014SO -- 011SO -- 006SO

        IF p_sqlstmmapid IS NOT NULL
        THEN
            sqlstmbiheader := sqlstmbiheader || ' AND BIH_MAPID in (' || p_sqlstmmapid || ')'; -- 027SO
        END IF;

       <<loop_while>>
        WHILE     (reccountdone < rconfig.revac_batchnorecords)
              AND (SYSDATE < starttime + rconfig.revac_runtimelimit / 24 / 3600)
        LOOP
            --Try to analyze another file
            --Repeat unless we analyzed a certain amount of CDRs -> see REVA_CONFIG

            --open dynamic select for last BIHEADER file
            currentbihid := NULL; -- 030SO

            OPEN cvcurvarbi FOR sqlstmbiheader;

            FETCH cvcurvarbi INTO currentbihid;

            CLOSE cvcurvarbi;

            EXIT WHEN currentbihid IS NULL; -- no more file to be analyzed. Analyze is up to date (no backlog)

            --Initialize Variables for this file
            bihrevasid := rrevaesid.done; -- if we have a file without active REVA HEADERs, we are done with the file
            cachedsqlstmincount := NULL;
            incount := 0;
            incountanalyzed := 0;

            --Now fetch fileDetails for this biheader id
            SELECT bih_reccount,
                   bih_esid,
                   bih_datetime
            INTO   rfiledetailsrow
            FROM   biheader
            WHERE  bih_id = currentbihid;

            --Fetch a NEW BOHEADER ID if not already done
            pkg_common_packing.insert_boheader_sptry (p_pac_id, p_boh_id); -- 024SO

            --Fetch and process all matching active REVA HEADERS (depending on SourceType)
            OPEN cmatchingrevaheader (currentbihid);

           <<loop_cmatchingrevaheader>>
            LOOP
                FETCH cmatchingrevaheader INTO cmatchingrevaheaderrow;

                EXIT WHEN cmatchingrevaheader%NOTFOUND; -- no more REVA HEADER for this file

                -- Perform analysis for this file and current REVA HEADER

                IF bdebug
                THEN
                    sbsdb_logger_lib.log_debug (
                           sbsdb_logger_lib.json_other_first ('bih_id', currentbihid)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('revah_id', cmatchingrevaheaderrow.revah_id)
                        || sbsdb_logger_lib.json_other_add ('reccount', 0)
                        || sbsdb_logger_lib.json_other_add ('what', 'START')
                        || sbsdb_logger_lib.json_other_last ('hint', 'Reva From=>To: ' || cmatchingrevaheaderrow.revah_srctype || '=>' || cmatchingrevaheaderrow.revah_pacid),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_desc', p_desc),
                        sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                        sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                        sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
                END IF;

                --1. Count all incoming records of current BIH_ID
                sqlstm := cmatchingrevaheaderrow.revah_insql;
                sqlstm := REPLACE (sqlstm, '<MINDATE>', rconfig.revac_file_max_age / 24 / 3600); -- 021SO
                sqlstm := REPLACE (sqlstm, '<REVAH_ID>', cmatchingrevaheaderrow.revah_id); -- 008SO
                sqlstm := REPLACE (sqlstm, '<REVAH_SRCTYPE>', cmatchingrevaheaderrow.revah_srctype); -- 008SO
                sqlstm := REPLACE (sqlstm, '<REVAH_PACID>', cmatchingrevaheaderrow.revah_pacid); -- 008SO

                --InSql Statements are COUNT(*) on BDETAIL* tables and may return more than one row (to be added)
                --If the new SqlStm is equal to the "old" CachedSqlStmInCount, dont Count again
                IF sqlstm = cachedsqlstmincount
                THEN
                    incount := cachedincount; --Reuse InCount from last loop
                ELSE
                    incount := 0; --InCount = All CDRs for this BDETAIL* file

                    IF INSTR (sqlstm, ':2') > 0
                    THEN
                        OPEN cvcurvar FOR sqlstm USING currentbihid, currentbihid; -- 037SO
                    ELSE
                        OPEN cvcurvar FOR sqlstm USING currentbihid; -- 037SO
                    END IF;

                    LOOP -- 018SO
                        FETCH cvcurvar INTO partialincount; -- 018SO

                        EXIT WHEN cvcurvar%NOTFOUND; -- 018SO
                        incount := incount + partialincount; -- 018SO
                    END LOOP; -- 018SO

                    CLOSE cvcurvar;

                    cachedsqlstmincount := sqlstm; --Remember SqlStm for next loop
                    cachedincount := incount; --Remember InCount for next loop
                END IF;

                incountanalyzed := 0; -- 007SO

                -- Fetch signature sql statement and replace the tokenized parameters
                sqlstm := cmatchingrevaheaderrow.revah_sql;
                sqlstm := REPLACE (sqlstm, '<MINDATE>', rconfig.revac_file_max_age / 24 / 3600); -- 021SO
                sqlstm := REPLACE (sqlstm, '<REVAH_ID>', cmatchingrevaheaderrow.revah_id); -- 008SO
                sqlstm := REPLACE (sqlstm, '<REVAH_SRCTYPE>', cmatchingrevaheaderrow.revah_srctype); -- 008SO
                sqlstm := REPLACE (sqlstm, '<REVAH_PACID>', cmatchingrevaheaderrow.revah_pacid); -- 008SO

                --2. Analyze all known Signatures and update existing counters: Count OUT
                IF INSTR (sqlstm, ':2') > 0
                THEN
                    OPEN cvcurvar FOR sqlstm USING currentbihid, currentbihid; -- 037SO
                ELSE
                    OPEN cvcurvar FOR sqlstm USING currentbihid; -- 037SO
                END IF;

               <<loop_cvcurvar>>
                LOOP
                    FETCH cvcurvar INTO rknownsignature;

                    EXIT WHEN cvcurvar%NOTFOUND;

                    BEGIN
                        UPDATE reva_counter
                        SET    revac_in = revac_in + rknownsignature.incount,
                               revac_out = revac_out + rknownsignature.outcount
                        WHERE      revac_revasmid = rknownsignature.revasm_id
                               AND revac_date = rknownsignature.bd_datetime;

                        IF SQL%ROWCOUNT = 0
                        THEN
                            --New SIGMASK for DATE -> create NEW SIG COUNTER
                            INSERT INTO reva_counter (
                                            revac_date,
                                            revac_revasmid,
                                            revac_in,
                                            revac_out)
                            VALUES      (
                                rknownsignature.bd_datetime,
                                rknownsignature.revasm_id,
                                rknownsignature.incount,
                                rknownsignature.outcount);
                        END IF;

                        --Count analyzed in CDRs for later comparing between InCount and InCountSigMasks
                        incountanalyzed := incountanalyzed + rknownsignature.incount;
                    END;
                END LOOP loop_cvcurvar; --cvCurVar

                CLOSE cvcurvar;

                IF incount < incountanalyzed
                THEN
                    --Here is definitely something wrong: more CDRs analyzed than existing. Cannot continue.
                    bihrevasid := rrevaesid.error;
                    errormsg := pkg_admin_common.geterrordesc ('INCOUNT_ERROR');
                    errormsg := errormsg || ' (Incount = ' || incount || ', InCountAnalyzed = ' || incountanalyzed || ').';
                    sbsdb_error_lib.LOG (
                        errorcode,
                           sbsdb_logger_lib.json_other_first ('errcode', 1000000028)
                        || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                        || sbsdb_logger_lib.json_other_add ('topic', 'REVA-ERROR')
                        || sbsdb_logger_lib.json_other_add ('bih_id', currentbihid)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id')
                        || sbsdb_logger_lib.json_other_last ('short_id'),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_desc', p_desc),
                        sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                        sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                        sbsdb_logger_lib.log_param ('returnstatus', returnstatus)); -- 035SO -- 033SO -- 001SO
                    ROLLBACK;
                    EXIT; --leave loop, terminate processing of this file
                END IF;

                IF NOT (incount = incountanalyzed)
                THEN
                    --We could not match all CDRs to known signatur masks -> write warning
                    IF incountanalyzed < incount - 5
                    THEN -- 041SO
                        errormsg := 'Missing ' || cmatchingrevaheaderrow.revah_id || ' Signature Masks for analyzed file (Incount = ' || incount || ', MatchCount = ' || incountanalyzed || ' )'; -- 040SO
                        sbsdb_error_lib.LOG (
                            errorcode,
                               sbsdb_logger_lib.json_other_first ('errcode', 1000000029)
                            || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                            || sbsdb_logger_lib.json_other_add ('topic', 'REVA-WARNING')
                            || sbsdb_logger_lib.json_other_add ('bih_id', currentbihid)
                            || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                            || sbsdb_logger_lib.json_other_add ('bd_id')
                            || sbsdb_logger_lib.json_other_last ('short_id'),
                            sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                            sbsdb_logger_lib.log_param ('p_desc', p_desc),
                            sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                            sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                            sbsdb_logger_lib.log_param ('returnstatus', returnstatus)); -- 035SO -- 033SO -- 001SO
                    END IF;

                    -- Create missing signatures and increment counters for them
                    sqlstm := cmatchingrevaheaderrow.revah_newsigsql;
                    sqlstm := REPLACE (sqlstm, '<MINDATE>', rconfig.revac_file_max_age / 24 / 3600); -- 021SO
                    sqlstm := REPLACE (sqlstm, '<REVAH_ID>', cmatchingrevaheaderrow.revah_id); -- 008SO
                    sqlstm := REPLACE (sqlstm, '<REVAH_SRCTYPE>', cmatchingrevaheaderrow.revah_srctype); -- 008SO
                    sqlstm := REPLACE (sqlstm, '<REVAH_PACID>', cmatchingrevaheaderrow.revah_pacid); -- 008SO

                    --3. Analyze all unknow Signatures and create new Counters
                    IF INSTR (sqlstm, ':2') > 0
                    THEN
                        OPEN cvcurvar FOR sqlstm USING currentbihid, currentbihid; -- 037SO
                    ELSE
                        OPEN cvcurvar FOR sqlstm USING currentbihid; -- 037SO
                    END IF;

                    LOOP
                        FETCH cvcurvar INTO runknownsignature;

                        EXIT WHEN cvcurvar%NOTFOUND;

                        BEGIN
                            -- create signature if not already done for other day in same file
                            BEGIN
                                SELECT revasm_id
                                INTO   newsigmaskid
                                FROM   reva_sigmask
                                WHERE      revasm_revahid = cmatchingrevaheaderrow.revah_id
                                       AND revasm_code = runknownsignature.revasm_code
                                       AND revasm_esid = 'A';
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    newsigmaskid := pkg_common.generateuniquekey ('G');

                                    --Insert new Signature mask
                                    INSERT INTO reva_sigmask (
                                                    revasm_id,
                                                    revasm_code,
                                                    revasm_revahid,
                                                    revasm_esid,
                                                    revasm_etid,
                                                    revasm_order,
                                                    revasm_desc)
                                    VALUES      (
                                        newsigmaskid,
                                        runknownsignature.revasm_code,
                                        cmatchingrevaheaderrow.revah_id,
                                        rrevaesid.active,
                                        'ERROR',
                                        999.9999,
                                        'Unknown Signature ' || runknownsignature.revasm_code); -- 009SO

                                    errormsg := 'Added Signature ' || runknownsignature.revasm_code || ' as ' || newsigmaskid || ' to ' || cmatchingrevaheaderrow.revah_id; -- 040SO
                                    sbsdb_error_lib.LOG (
                                        errorcode,
                                           sbsdb_logger_lib.json_other_first ('errcode', 1000000029)
                                        || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                                        || sbsdb_logger_lib.json_other_add ('topic', 'REVA-WARNING')
                                        || sbsdb_logger_lib.json_other_add ('bih_id', currentbihid)
                                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                                        || sbsdb_logger_lib.json_other_add ('bd_id')
                                        || sbsdb_logger_lib.json_other_last ('short_id'),
                                        sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                                        sbsdb_logger_lib.log_param ('p_desc', p_desc),
                                        sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                                        sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                                        sbsdb_logger_lib.log_param ('returnstatus', returnstatus)); -- 039SO
                            END;

                            -- update or insert counter
                            UPDATE reva_counter
                            SET    revac_in = revac_in + runknownsignature.incount,
                                   revac_out = revac_out + runknownsignature.outcount
                            WHERE      revac_revasmid = newsigmaskid
                                   AND revac_date = runknownsignature.bd_datetime;

                            IF SQL%ROWCOUNT = 0
                            THEN
                                --Create new Counter
                                INSERT INTO reva_counter (
                                                revac_date,
                                                revac_revasmid,
                                                revac_in,
                                                revac_out)
                                VALUES      (
                                    runknownsignature.bd_datetime,
                                    newsigmaskid,
                                    runknownsignature.incount,
                                    runknownsignature.outcount);
                            END IF;

                            --Count analyzed in CDRs for later comparing between InCount and InCountSigMasks
                            incountanalyzed := incountanalyzed + runknownsignature.incount;
                        END;
                    END LOOP; --cvCurVar

                    CLOSE cvcurvar;
                END IF; --(InCount <> InCountAnalyzed)

                IF bdebug
                THEN
                    pkg_debug.debug_reva (
                        currentbihid,
                        p_boh_id,
                        cmatchingrevaheaderrow.revah_id,
                        TO_NUMBER (incount),
                        'END',
                        'Reva From=>To: ' || cmatchingrevaheaderrow.revah_srctype || '=>' || cmatchingrevaheaderrow.revah_pacid);
                    sbsdb_logger_lib.log_debug (
                           sbsdb_logger_lib.json_other_first ('bih_id', currentbihid)
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('revah_id', cmatchingrevaheaderrow.revah_id)
                        || sbsdb_logger_lib.json_other_add ('reccount', incount)
                        || sbsdb_logger_lib.json_other_add ('what', 'END')
                        || sbsdb_logger_lib.json_other_last ('hint', 'Reva From=>To: ' || cmatchingrevaheaderrow.revah_srctype || '=>' || cmatchingrevaheaderrow.revah_pacid),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_desc', p_desc),
                        sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                        sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                        sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
                END IF;
            END LOOP loop_cmatchingrevaheader; -- loop for cMatchingRevaHeader

            CLOSE cmatchingrevaheader;

            --Check finally analyzed input CDR count ---------------------------------------------------------------------
            IF incount <> incountanalyzed
            THEN
                --Its not possible to analyze all CDRs properly, last shot missed -> rollback for this file (BIH_ID)
                ROLLBACK;
                bihrevasid := rrevaesid.error;
                errormsg := pkg_admin_common.geterrordesc ('NO_MATCHINGINCOUNT');
                errormsg := errormsg || ' (Incount = ' || incount || ', InCountAnalyzed = ' || incountanalyzed || ').';
                sbsdb_error_lib.LOG (
                    errorcode,
                       sbsdb_logger_lib.json_other_first ('errcode', 1000000027)
                    || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                    || sbsdb_logger_lib.json_other_add ('topic', 'REVA-ERROR')
                    || sbsdb_logger_lib.json_other_add ('bih_id', currentbihid)
                    || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                    || sbsdb_logger_lib.json_other_add ('bd_id')
                    || sbsdb_logger_lib.json_other_last ('short_id'),
                    sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                    sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                    sbsdb_logger_lib.log_param ('p_desc', p_desc),
                    sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                    sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                    sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                    sbsdb_logger_lib.log_param ('returnstatus', returnstatus)); -- 035SO -- 033SO -- 001SO
            ELSE
                bihrevasid := rrevaesid.done;
            END IF;

            -- Set bih_etid flag to new state -------------------------------------------------------------------
            UPDATE biheader
            SET    bih_revasid = bihrevasid,
                   bih_dateanalyzed = SYSDATE
            WHERE  bih_id = currentbihid;

            reccountdone := reccountdone + incountanalyzed;

            pkg_revi.revi_index_file (currentbihid, p_boh_id); -- 022SO

            COMMIT;
        END LOOP loop_while; --Repeat unless we analyzed a certain amount of CDRs -> see REVA_CONFIG

        recordsaffected := reccountdone; -- 003SO
        errorcode := 0; -- 005SO    only show error if exception is raised
        errormsg := NULL; -- 005SO    only show error if exception is raised
        returnstatus := 1;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            errorcode := pkg_common.eno_inconvenient_time;
            errormsg := pkg_common.edesc_inconvenient_time;
            returnstatus := pkg_common.return_status_suspended;
        WHEN pkg_common_packing.excp_statistics_failure
        THEN
            errorcode := pkg_common_packing.eno_statistics_failure;
            errormsg := pkg_common_packing.edesc_statistics_failure;
            returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common_packing.excp_workflow_abort
        THEN
            errorcode := pkg_common_packing.eno_workflow_abort;
            errormsg := pkg_common_packing.edesc_workflow_abort;
            returnstatus := pkg_common.return_status_failure;
        WHEN no_bohid
        THEN
            errorcode := 1000000026;
            errormsg := pkg_admin_common.geterrordesc ('NO_BOHID');
            recordsaffected := reccountdone; -- 003SO
            returnstatus := pkg_common.return_status_failure; -- 034SO
        WHEN OTHERS
        THEN
            ROLLBACK;
            returnstatus := 0;
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; -- 034SO
            recordsaffected := reccountdone; -- 003SO
            sbsdb_error_lib.LOG (
                errorcode,
                   sbsdb_logger_lib.json_other_first ('errcode', errorcode)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                || sbsdb_logger_lib.json_other_add ('topic', 'PLSQL-ERROR')
                || sbsdb_logger_lib.json_other_add ('bih_id', currentbihid)
                || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                || sbsdb_logger_lib.json_other_add ('bd_id')
                || sbsdb_logger_lib.json_other_last ('short_id'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'reva_recent'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_desc', p_desc),
                sbsdb_logger_lib.log_param ('p_sqlstmsrctype', p_sqlstmsrctype),
                sbsdb_logger_lib.log_param ('p_sqlstmmapid', p_sqlstmmapid),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus)); -- 035SO-- 033SO
    END reva_recent;
END pkg_reva;
/