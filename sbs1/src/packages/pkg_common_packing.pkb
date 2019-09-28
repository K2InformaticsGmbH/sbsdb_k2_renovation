CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_common_packing
IS
    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    cstrmecdatetimeformat                   VARCHAR2 (20) := 'YYYYMMDDHH24MISS';
    rheaderstate                            tboheaderesid;
    rpackingstate                           tpackingstateid;

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getjobcandidatefortype (
        p_packingtype                           IN VARCHAR2,
        p_thread                                IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION getnextpackingsequence (p_pacid IN VARCHAR2)
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE lock_packing (p_packingid IN VARCHAR2);

    PROCEDURE setpackingstatescheduled (p_pac_id IN VARCHAR2);

    PROCEDURE unlockpacking (p_pac_id IN VARCHAR2);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getpackingcandidatefortype (
        p_packingtype                           IN VARCHAR2,
        p_thread                                IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cpackingcandidates IS
            SELECT   pac_id
            FROM     packing,
                     periodicity
            WHERE        periodicity.period_id = NVL (pac_periodid, 'NONE')
                     AND pac_etid = p_packingtype
                     AND pac_esid IN (rpackingstate.active,
                                      rpackingstate.scheduled)
                     AND pac_execute = 1
                     AND (   pac_xprocid = p_thread
                          OR pac_xprocid IS NULL)
                     AND (   period_id = 'NONE'
                          OR NVL (pac_datedone, SYSDATE - 400) < TRUNC (SYSDATE, period_value1))
            ORDER BY pac_datetry ASC NULLS FIRST;

        l_result                                VARCHAR2 (10);
    BEGIN
        l_result := NULL;

        FOR cpackingcandidatesrow IN cpackingcandidates
        LOOP
            IF istimeforpacking (cpackingcandidatesrow.pac_id) = 1
            THEN
                l_result := cpackingcandidatesrow.pac_id;
            END IF;

            EXIT WHEN NOT (l_result IS NULL);
        END LOOP;

        RETURN l_result;
    END getpackingcandidatefortype;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getpackingparameter (
        p_pac_id                                IN VARCHAR2,
        p_name                                  IN sta_pacparam.stap_name%TYPE)
        RETURN sta_pacparam.stap_value%TYPE
    IS
        l_result                                sta_pacparam.stap_value%TYPE;
    BEGIN
        SELECT stap_value
        INTO   l_result
        FROM   sta_pacparam
        WHERE      stap_pacid = p_pac_id
               AND stap_name = '[' || p_name || ']';

        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE excp_missing_packing_par;
    END getpackingparameter;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION gettypeforpacking (p_bih_pacid IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (10);
    BEGIN
        SELECT pac_etid
        INTO   l_result
        FROM   packing
        WHERE  pac_id = p_bih_pacid;

        RETURN l_result;
    END gettypeforpacking;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION istimeforpacking (p_pac_id IN VARCHAR2)
        RETURN INTEGER
    IS
        CURSOR cpackingcandidate IS
            SELECT pac_esid,
                   pac_execute,
                   pac_conditionalexec,
                   pac_periodid,
                   pac_ltid,
                   pac_startday,
                   pac_starthour,
                   pac_startminute,
                   pac_endclearance, --005SO
                   pac_datetry,
                   pac_datedone
            FROM   packing,
                   sta_config
            WHERE      pac_id = p_pac_id
                   AND stac_id = 'DEFAULT'
                   AND stac_execstat = 1
                   AND (   stac_execrep = 1
                        OR pac_etid NOT IN ('STAT',
                                            'STATIND'))
                   AND (   stac_execproc = 1
                        OR pac_etid IN ('STAT',
                                        'STATIND'))
                   AND pac_esid IN (rpackingstate.active,
                                    rpackingstate.scheduled)
                   AND pac_execute = 1; --019SO --018SO

        CURSOR cdepencencypackings IS
            SELECT pac_id,
                   pac_esid,
                   pac_periodid,
                   pac_datedone
            FROM   pacpacdep,
                   packing
            WHERE      pacpacdep.pacpac_pacid1 = packing.pac_id
                   AND pacpac_pacid2 = p_pac_id;

        CURSOR cdepencencymappings IS
            SELECT map_id,
                   map_periodid,
                   map_datedone
            FROM   mappacdep,
                   mapping
            WHERE      mappacdep.mappac_mapid1 = mapping.map_id
                   AND mappac_pacid2 = p_pac_id;

        TYPE tcurdef IS REF CURSOR;

        cvcurvar                                tcurdef;
        l_sql                                   VARCHAR2 (4000);
        bgo                                     BOOLEAN;
        vgo                                     VARCHAR2 (4000);

        l_job_count                             PLS_INTEGER;

        l_debug                                 PLS_INTEGER;

        l_return                                PLS_INTEGER;
    BEGIN
        sbsdb_logger_lib.log_info ('Start', sbsdb_logger_lib.scope ($$plsql_unit, 'istimeforpacking'), sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id));

        bgo := FALSE;

        SELECT NVL (pac_debug, 0)
        INTO   l_debug
        FROM   packing
        WHERE  pac_id = p_pac_id;

        -- Check if this is a convenient time for processing
        FOR cpackingcandidaterow IN cpackingcandidate
        LOOP
            IF cpackingcandidaterow.pac_esid IN (rpackingstate.active,
                                                 rpackingstate.scheduled)
            THEN
                IF cpackingcandidaterow.pac_conditionalexec IS NULL
                THEN
                    bgo := TRUE;
                ELSE
                    IF SUBSTR (UPPER (cpackingcandidaterow.pac_conditionalexec), 1, 6) = 'SELECT'
                    THEN
                        -- must check a condition sql
                        l_sql := cpackingcandidaterow.pac_conditionalexec;
                    ELSE
                        -- condition view or table name given
                        l_sql := 'SELECT  * FROM ' || cpackingcandidaterow.pac_conditionalexec;
                    END IF;

                    OPEN cvcurvar FOR l_sql;

                    FETCH cvcurvar INTO vgo; -- ignore result

                    bgo := cvcurvar%FOUND; -- any result is a GO

                    IF bgo
                    THEN
                        IF UPPER (NVL (TRIM (vgo), 'FALSE')) IN ('FALSE',
                                                                 '0',
                                                                 'NO')
                        THEN
                            bgo := FALSE; -- execpt if it is 0 or false or no

                            IF l_debug >= 3
                            THEN --034SO
                                pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'false  because of CONDITIONALEXEC result in (FALSE/0/NO)');
                            END IF;
                        END IF;
                    ELSE
                        IF l_debug >= 3
                        THEN --034SO
                            pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'false  because of empty CONDITIONALEXEC result');
                        END IF;
                    END IF;

                    CLOSE cvcurvar;
                END IF;

                IF bgo
                THEN
                    bgo :=
                        pkg_common.istimeforprocess (
                            cpackingcandidaterow.pac_periodid,
                            cpackingcandidaterow.pac_startday,
                            cpackingcandidaterow.pac_starthour,
                            cpackingcandidaterow.pac_startminute,
                            cpackingcandidaterow.pac_endclearance, --005SO
                            cpackingcandidaterow.pac_datedone); --002SO

                    IF     l_debug >= 3
                       AND NOT bgo
                    THEN --034SO
                        pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'false because isTimeForProcess()=false');
                    END IF;
                END IF;

                IF bgo
                THEN
                    --004SO
                    FOR cdepencencypackingsrow IN cdepencencypackings
                    LOOP
                        IF cdepencencypackingsrow.pac_esid NOT IN (rpackingstate.active,
                                                                   rpackingstate.draft)
                        THEN
                            bgo := FALSE;
                        ELSIF NOT pkg_common.isdoneinperiod (cdepencencypackingsrow.pac_periodid, cdepencencypackingsrow.pac_datedone)
                        THEN --028SO
                            bgo := FALSE;

                            IF l_debug >= 3
                            THEN --034SO
                                pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'false because of PacPacDependency(' || cdepencencypackingsrow.pac_id || ')');
                            END IF;
                        END IF;

                        EXIT WHEN NOT bgo;
                    END LOOP;
                END IF;

                IF bgo
                THEN
                    --004SO
                    FOR cdepencencymappingsrow IN cdepencencymappings
                    LOOP
                        IF NOT pkg_common.isdoneinperiod (cdepencencymappingsrow.map_periodid, cdepencencymappingsrow.map_datedone)
                        THEN --028SO
                            bgo := FALSE;

                            IF l_debug >= 3
                            THEN --034SO
                                pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'false because of MapPacDependency(' || cdepencencymappingsrow.map_id || ')');
                            END IF;
                        END IF;

                        EXIT WHEN NOT bgo;
                    END LOOP;
                END IF;

                IF     bgo
                   AND cpackingcandidaterow.pac_ltid <> 'NONE' --024SO
                   AND cpackingcandidaterow.pac_esid = rpackingstate.scheduled
                THEN
                    -- 019SO  This is a sceduled looper
                    -- see if we have executable jobs left
                    l_job_count := pkg_common_stats.get_sta_job_scheduled_count (p_pac_id, cpackingcandidaterow.pac_periodid);
                    bgo := (l_job_count >= 1); --019SO

                    IF     l_debug >= 3
                       AND NOT bgo
                    THEN --034SO
                        pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'false because no looper jobs are left');
                    END IF;
                END IF;
            END IF;
        END LOOP;

        IF bgo
        THEN
            IF l_debug >= 5
            THEN --034SO
                pkg_common.l ('isTimeForPacking (' || p_pac_id || ') = ', 'true'); -- 030SO
            END IF;

            l_return := 1;
        ELSE
            l_return := 0; -- already logged above
        END IF;

        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'istimeforpacking'), sbsdb_logger_lib.log_param ('return', l_return));

        RETURN l_return;
    END istimeforpacking;

    /* =========================================================================
       TODO.

       --011DA
       ---------------------------------------------------------------------- */

    FUNCTION setstringtagstolowercase (p_string IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_posstart                              PLS_INTEGER;
        l_posend                                PLS_INTEGER;
        l_tag                                   VARCHAR2 (20);
        l_string                                VARCHAR2 (1000);
    BEGIN
        l_string := p_string;

        l_posstart := INSTR (l_string, '<', 1);

        WHILE l_posstart > 0
        LOOP
            l_posend := INSTR (l_string, '>', l_posstart + 1);

            IF l_posend > 0
            THEN
                l_tag := SUBSTR (l_string, l_posstart, l_posend - l_posstart + 1);
                l_string := REPLACE (l_string, l_tag, LOWER (l_tag));
            ELSE
                l_posend := l_posstart;
            END IF;

            l_posstart := INSTR (l_string, '<', l_posend + 1);
        END LOOP;

        RETURN l_string;
    END setstringtagstolowercase;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_boheader (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_headerid                              IN OUT VARCHAR2,
        p_jobid                                    OUT VARCHAR2,
        p_filename                                 OUT VARCHAR2, --003SO
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2)
    IS
        -- l_FILENAME          BOHEADER.BOH_FILENAME%type := 'NO NAME';             --026SO
        l_fileseq                               boheader.boh_fileseq%TYPE := 0;
        l_packingrow                            packing%ROWTYPE; --007SO
        l_jobscreated                           PLS_INTEGER; --007SO
        l_job_count                             PLS_INTEGER; --019SO
    BEGIN
        l_jobscreated := 0;

        IF p_packingid IS NOT NULL
        THEN
            -- specific packing is given
            IF istimeforpacking (p_packingid) = 0
            THEN
                RAISE pkg_common.excp_inconvenient_time;
            END IF;
        ELSIF p_packingtype = 'STATIND'
        THEN
            -- must search for active jobs of given packing type                    --029SO

            p_jobid := getjobcandidatefortype (p_packingtype, p_thread);

            IF p_jobid IS NULL
            THEN
                RAISE pkg_common.excp_inconvenient_time;
            ELSE
                SELECT staj_pacid
                INTO   p_packingid
                FROM   sta_job
                WHERE  staj_id = p_jobid;
            END IF;
        ELSE
            -- only packing type is given. must search a candidate first

            p_packingid := getpackingcandidatefortype (p_packingtype, p_thread);

            IF p_packingid IS NULL
            THEN
                RAISE pkg_common.excp_inconvenient_time;
            END IF;
        END IF;

        -- packing found, which can be executed

        SELECT *
        INTO   l_packingrow
        FROM   packing
        WHERE  pac_id = p_packingid; --022SO

        IF p_headerid IS NULL
        THEN
            p_headerid := pkg_common.generateuniquekey ('G');
        END IF;

        p_filename := NVL (l_packingrow.pac_filemask, l_packingrow.pac_name || '_<pac_nextseq>'); --022SO

        INSERT INTO boheader (
                        boh_id,
                        boh_demo,
                        boh_fileseq,
                        boh_datetime,
                        boh_filename,
                        boh_start,
                        boh_esid,
                        boh_filedate,
                        boh_packid,
                        boh_exe,
                        boh_version,
                        boh_thread,
                        boh_job,
                        boh_host)
        VALUES      (
            p_headerid,
            0,
            l_fileseq,
            SYSDATE,
            p_filename, --026SO was l_FILENAME,
            SYSDATE,
            'PAC',
            SYSDATE,
            p_packingid,
            p_appname,
            p_appver,
            p_thread,
            p_taskid,
            p_hostname);

        UPDATE packing
        SET    pac_datetry = SYSDATE,
               pac_datesta = SYSDATE
        WHERE  pac_id = p_packingid;

        IF p_packingtype = 'STATIND'
        THEN
            pkg_common_stats.update_sta_job_working (p_jobid, p_headerid);

            setpackingstatescheduled (p_packingid); --010SO
        ELSIF NVL (l_packingrow.pac_periodid, 'NONE') = 'NONE'
        THEN
            -- Signal to the driver to execute in any case
            p_jobid := 'NONE'; --033SO --032SO
        ELSIF l_packingrow.pac_ltid = 'NONE'
        THEN --024SO
            -- non-loopers are scheduled on the fly, but can be already registered
            -- try to recover an existing job
            pkg_common_stats.get_sta_job_working (p_packingid, NVL (l_packingrow.pac_periodid, 'NONE'), p_headerid, p_jobid); --030SO

            IF p_jobid IS NOT NULL
            THEN
                setpackingstatescheduled (p_packingid); --031SO
            ELSE
                -- no aborted job found which can be re-executed                --030SO
                l_job_count := pkg_common_stats.get_sta_job_error_count (p_packingid, l_packingrow.pac_periodid);

                IF l_job_count > 0
                THEN
                    -- at least one of the jobs expired unsuccessfully
                    -- must throw an exception and set the packing to locked state
                    lock_packing (p_packingid);
                    COMMIT; --035SO
                    RAISE excp_statistics_failure;
                ELSE
                    -- no expired job found, must create one
                    pkg_common_stats.new_sta_job_working ( --015DA
                        0, -- p_StajParentId
                        p_packingid,
                        NULL,
                        NVL (l_packingrow.pac_periodid, 'NONE'),
                        p_headerid,
                        p_jobid); --008SO --007SO
                    l_jobscreated := 1;
                    setpackingstatescheduled (p_packingid); --031SO
                END IF;
            END IF;
        ELSIF l_packingrow.pac_ltid <> 'NONE'
        THEN
            -- this is a looper job                                                       --016SO
            IF l_packingrow.pac_esid = rpackingstate.active
            THEN
                -- this is a looper job without scheduled jobs
                -- schedule the looper jobs
                pkg_common_stats.new_sta_jobs_loopers (
                    0, -- p_StajParentId
                    p_packingid,
                    NVL (l_packingrow.pac_periodid, 'NONE'),
                    p_headerid,
                    l_jobscreated);

                IF l_jobscreated > 0
                THEN
                    -- non-empty looper. One or more jobs scheduled.
                    setpackingstatescheduled (p_packingid); --031SO
                ELSE
                    UPDATE packing
                    SET    pac_datedone = SYSDATE,
                           pac_datesta = SYSDATE
                    WHERE      pac_id = p_packingid
                           AND pac_esid IN (rpackingstate.active); --032SO

                    -- Nothing to do, commit after UPDATE_HEADER will set DateDone
                    -- The execution for an empty JobID must fall through without error
                    -- in the DotNet driver.
                    RETURN; --032SO
                END IF;
            END IF;

            pkg_common_stats.get_sta_job_working ( --016SO
                                                  p_packingid, NVL (l_packingrow.pac_periodid, 'NONE'), --017SO
                                                                                                        p_headerid, p_jobid);

            IF p_jobid IS NULL
            THEN
                -- no jobs found which can be executed
                l_job_count := pkg_common_stats.get_sta_job_error_count (p_packingid, l_packingrow.pac_periodid); --019SO

                IF l_job_count > 0
                THEN
                    -- at least one of the jobs expired unsuccessfully
                    -- must throw an exception and set the packing to locked state
                    lock_packing (p_packingid);
                    COMMIT; --035SO
                    RAISE excp_statistics_failure;
                ELSE
                    unlockpacking (p_packingid); --041SO 008158 Workflow Logic Patch for Statistics Loopers
                    RAISE excp_workflow_abort; -- cannot continue here, must fail and retry
                END IF;
            END IF;
        END IF;

        RETURN;
    END insert_boheader;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_boheader_sptry (
        p_packingid                             IN     VARCHAR2,
        p_headerid                              IN OUT VARCHAR2)
    IS --021SO
        l_packingid                             VARCHAR2 (10);
        l_jobid                                 VARCHAR2 (10);
        l_filename                              VARCHAR2 (100);
    BEGIN
        l_packingid := p_packingid;

        IF p_headerid IS NULL
        THEN
            insert_boheader (
                'SPTRY',
                l_packingid,
                p_headerid,
                l_jobid,
                l_filename,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL);
        END IF;
    END insert_boheader_sptry;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE modify_boheader (
        p_headerid                              IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_filename                                 OUT VARCHAR2)
    IS --020SO
    BEGIN
        UPDATE boheader
        SET    boh_exe = p_appname,
               boh_version = p_appver,
               boh_thread = p_thread,
               boh_job = p_taskid,
               boh_host = p_hostname
        WHERE  boh_id = p_headerid;

        IF SQL%ROWCOUNT <> 1
        THEN
            RAISE pkg_common.excp_missing_header_fld;
        END IF;

        SELECT boh_filename
        INTO   p_filename
        FROM   boheader
        WHERE  boh_id = p_headerid;

        RETURN;
    END modify_boheader;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_next_pac_seq (
        p_pacid                                 IN     VARCHAR2,
        p_nextsequence                             OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errormsg                                 OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER) -- TODO looks very odd (wwe)
    IS
    BEGIN
        p_nextsequence := getnextpackingsequence (p_pacid);

        p_errorcode := NULL;
        p_errormsg := NULL;
        p_returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errormsg := SQLERRM;
            p_returnstatus := 0;
    END sp_get_next_pac_seq;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_headerid                                 OUT VARCHAR2,
        p_jobid                                    OUT VARCHAR2,
        p_filename                                 OUT VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS --039SO
    BEGIN
        p_headerid := NULL;

        insert_boheader (
            p_packingtype,
            p_packingid,
            p_headerid,
            p_jobid,
            p_filename,
            p_appname,
            p_appver,
            p_thread,
            p_taskid,
            p_hostname);

        p_returnstatus := pkg_common.return_status_ok;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            p_errorcode := pkg_common.eno_inconvenient_time;
            p_errordesc := pkg_common.edesc_inconvenient_time;
            p_returnstatus := pkg_common.return_status_suspended;
        WHEN pkg_common_packing.excp_statistics_failure
        THEN
            p_errorcode := pkg_common_packing.eno_statistics_failure;
            p_errordesc := pkg_common_packing.edesc_statistics_failure;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common_packing.excp_workflow_abort
        THEN
            p_errorcode := pkg_common_packing.eno_workflow_abort;
            p_errordesc := pkg_common_packing.edesc_workflow_abort;
            p_returnstatus := pkg_common.return_status_failure;
    --        When others then
    --            p_ErrorCode := SqlCode;
    --            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
    --            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    END sp_insert_header;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_boheader (
        p_headerid                              IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_filename                              IN OUT VARCHAR2,
        p_filedate                              IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_maxage                                IN     NUMBER, -- TODO unused parameter? (wwe)
        p_dataheader                            IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_reccount                              IN     NUMBER,
        p_errcount                              IN     NUMBER,
        p_datefc                                IN     VARCHAR2,
        p_datelc                                IN     VARCHAR2)
    IS
        -- finalizes a successful packing (except soft errors) on DB
        -- only to be called if operation is completed successfully .

        CURSOR cpackinginfo IS
            SELECT pac_id,
                   pac_name,
                   pac_etid,
                   pac_ltid,
                   pac_itid,
                   pac_periodid,
                   pac_nextseq,
                   TRIM (TO_CHAR (pac_nextseq, REPLACE (pac_fileseqmax, '9', '0')))     AS pac_nextseq_str --027SO
            FROM   boheader,
                   packing
            WHERE      pac_id = boh_packid
                   AND boh_id = p_headerid; --006SO

        CURSOR clooperinfocontract IS
            SELECT con_id,
                   con_name,
                   NULL     AS con_number, --047SO
                   con_pscall,
                   con_opkey,
                   NULL     AS con_custnumber, --047SO
                   con_consol,
                   con_shortid
            FROM   sta_job,
                   contract
            WHERE      staj_id = p_jobid
                   AND con_id = staj_ltvalue; --006SO

        CURSOR clooperinfoaccount IS
            SELECT ac_id,
                   ac_name,
                   ac_number,
                   ac_mbunit,
                   ac_tpid
            FROM   sta_job,
                   account
            WHERE      staj_id = p_jobid
                   AND ac_id = staj_ltvalue;

        CURSOR clooperinfo IS
            SELECT staj_ltvalue
            FROM   sta_job
            WHERE  staj_id = p_jobid; --044SO

        CURSOR cjobparameter IS
            SELECT stajp_name,
                   stajp_value
            FROM   sta_jobparam
            WHERE  stajp_jobid = p_jobid; --045SO --044SO

        x_packid                                VARCHAR2 (10);
        x_nextseq                               NUMBER;
        l_time                                  DATE;
        l_debug                                 PLS_INTEGER;
        l_loop_type                             VARCHAR2 (10); --031SO
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'update_boheader'),
            sbsdb_logger_lib.log_param ('p_headerid', p_headerid),
            sbsdb_logger_lib.log_param ('p_jobid', p_jobid),
            sbsdb_logger_lib.log_param ('p_filename', p_filename),
            sbsdb_logger_lib.log_param ('p_filedate', p_filedate),
            sbsdb_logger_lib.log_param ('p_maxage', p_maxage),
            sbsdb_logger_lib.log_param ('p_dataheader', p_dataheader),
            sbsdb_logger_lib.log_param ('p_reccount', p_reccount),
            sbsdb_logger_lib.log_param ('p_errcount', p_errcount),
            sbsdb_logger_lib.log_param ('p_datefc', p_datefc),
            sbsdb_logger_lib.log_param ('p_datelc', p_datelc));

        l_time := SYSDATE;

        SELECT boh_packid
        INTO   x_packid
        FROM   boheader
        WHERE  boh_id = p_headerid;

        SELECT NVL (pac_debug, 0),
               pac_ltid
        INTO   l_debug,
               l_loop_type --031SO
        FROM   packing
        WHERE  pac_id = x_packid;

        p_filename := setstringtagstolowercase (p_filename); --11DA

        --12DA: all tag names to be replaced changed to lower case

        IF p_filename LIKE '%<p%'
        THEN -- <pac_.. or <period>
            FOR cpackinginforow IN cpackinginfo
            LOOP
                p_filename := REPLACE (p_filename, '<pac_id>', cpackinginforow.pac_id);
                p_filename := REPLACE (p_filename, '<pac_name>', cpackinginforow.pac_name);
                p_filename := REPLACE (p_filename, '<pac_nextseq>', cpackinginforow.pac_nextseq_str); --027SO

                IF cpackinginforow.pac_periodid = 'YEARLY'
                THEN
                    p_filename := REPLACE (p_filename, '<period>', TO_CHAR (ADD_MONTHS (l_time, -12), 'YYYY'));
                ELSIF cpackinginforow.pac_periodid = 'MONTHLY'
                THEN
                    p_filename := REPLACE (p_filename, '<period>', TO_CHAR (ADD_MONTHS (l_time, -1), 'YYYYMM'));
                ELSIF cpackinginforow.pac_periodid = 'WEEKLY'
                THEN
                    p_filename := REPLACE (p_filename, '<period>', TO_CHAR (l_time - 7, 'YYYYWW'));
                ELSIF cpackinginforow.pac_periodid = 'DAILY'
                THEN
                    p_filename := REPLACE (p_filename, '<period>', TO_CHAR (l_time - 1, 'YYYYDD'));
                ELSIF cpackinginforow.pac_periodid = 'HOURLY'
                THEN
                    p_filename := REPLACE (p_filename, '<period>', TO_CHAR (l_time - 1 / 24, 'YYYYDDHH24'));
                ELSE
                    p_filename := REPLACE (p_filename, '<period>', NULL);
                END IF;
            END LOOP;
        END IF; --006SO

        IF p_filename LIKE '%<[%'
        THEN
            -- must replace job parameter tokens
            FOR cjobparameterrow IN cjobparameter
            LOOP --045SO
                p_filename := REPLACE (p_filename, '<' || LOWER (cjobparameterrow.stajp_name) || '>', cjobparameterrow.stajp_value);
            END LOOP;
        END IF; --044SO

        IF INSTR (p_filename, '<') > 0
        THEN
            -- must replace tokens
            p_filename := REPLACE (p_filename, '<staj_id>', p_jobid);
            p_filename := REPLACE (p_filename, '<yymmddhhmi>', TO_CHAR (l_time, 'YYMMDDHH24MI'));
            p_filename := REPLACE (p_filename, '<yyyymmdd>', TO_CHAR (l_time, 'YYYYMMDD'));
            p_filename := REPLACE (p_filename, '<yymmdd>', TO_CHAR (l_time, 'YYMMDD'));
            p_filename := REPLACE (p_filename, '<mmdd>', TO_CHAR (l_time, 'MMDD'));
            p_filename := REPLACE (p_filename, '<hhmmss>', TO_CHAR (l_time, 'hh24miss'));
            p_filename := REPLACE (p_filename, '<hhmi>', TO_CHAR (l_time, 'hh24mi'));
        END IF; --006SO

        IF INSTR (p_filename, '<') > 0
        THEN
            -- must replace tokens
            p_filename := REPLACE (p_filename, '<yyyy>', TO_CHAR (l_time, 'YYYY'));
            p_filename := REPLACE (p_filename, '<yy>', TO_CHAR (l_time, 'YY'));
            p_filename := REPLACE (p_filename, '<mm>', TO_CHAR (l_time, 'MM'));
            p_filename := REPLACE (p_filename, '<dd>', TO_CHAR (l_time, 'DD'));
            p_filename := REPLACE (p_filename, '<hh>', TO_CHAR (l_time, 'hh24'));
            p_filename := REPLACE (p_filename, '<mi>', TO_CHAR (l_time, 'mi'));
        END IF; --006SO

        IF INSTR (p_filename, '<ac_') > 0
        THEN
            FOR clooperinforow IN clooperinfoaccount
            LOOP
                p_filename := REPLACE (p_filename, '<ac_id>', clooperinforow.ac_id);
                p_filename := REPLACE (p_filename, '<ac_name>', SUBSTR (clooperinforow.ac_name, 1, 25)); --036SO
                p_filename := REPLACE (p_filename, '<ac_number>', clooperinforow.ac_number);
                p_filename := REPLACE (p_filename, '<ac_mbunit>', clooperinforow.ac_mbunit);
                p_filename := REPLACE (p_filename, '<ac_tpid>', clooperinforow.ac_tpid);
            END LOOP;
        END IF; --006SO

        IF INSTR (p_filename, '<con_') > 0
        THEN
            FOR clooperinforow IN clooperinfocontract
            LOOP
                p_filename := REPLACE (p_filename, '<con_id>', clooperinforow.con_id);
                p_filename := REPLACE (p_filename, '<con_name>', SUBSTR (clooperinforow.con_name, 1, 25)); --036SO
                p_filename := REPLACE (p_filename, '<con_number>', clooperinforow.con_number);
                p_filename := REPLACE (p_filename, '<con_pscall>', clooperinforow.con_pscall);
                p_filename := REPLACE (p_filename, '<con_opkey>', clooperinforow.con_opkey);
                p_filename := REPLACE (p_filename, '<con_consol>', clooperinforow.con_consol);
                p_filename := REPLACE (p_filename, '<con_shortid>', clooperinforow.con_shortid);
            END LOOP;
        END IF; --006SO

        IF    (INSTR (p_filename, '<set_id>') > 0)
           OR (INSTR (p_filename, '<loopvar>') > 0)
        THEN --044SO
            FOR clooperinforow IN clooperinfo
            LOOP --044SO
                p_filename := REPLACE (p_filename, '<set_id>', clooperinforow.staj_ltvalue);
                p_filename := REPLACE (p_filename, '<loopvar>', clooperinforow.staj_ltvalue); --044SO
            END LOOP;
        END IF; --006SO

        p_filename := TRANSLATE (p_filename, CHR (9) || CHR (10) || CHR (13) || ',\/:;*?|"''', '        '); --043SO--040SO--013DA --006SO

        IF l_debug >= 5
        THEN
            pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' final filename ', p_filename);
        END IF;

        IF p_filename IS NULL
        THEN --014DA
            UPDATE boheader
            SET    boh_reccount = p_reccount,
                   boh_errcount = p_errcount,
                   boh_datefc = NVL (TO_DATE (p_datefc, cstrmecdatetimeformat), boh_datefc), --042SO --009SO
                   boh_datelc = NVL (TO_DATE (p_datelc, cstrmecdatetimeformat), boh_datelc), --042SO --009SO
                   boh_end = l_time,
                   boh_esid = rheaderstate.ok
            WHERE  boh_id = p_headerid;
        ELSE
            UPDATE boheader
            SET    boh_filename = p_filename,
                   boh_reccount = p_reccount,
                   boh_errcount = p_errcount,
                   boh_datefc = NVL (TO_DATE (p_datefc, cstrmecdatetimeformat), boh_datefc), --042SO --009SO
                   boh_datelc = NVL (TO_DATE (p_datelc, cstrmecdatetimeformat), boh_datelc), --042SO --009SO
                   boh_end = l_time,
                   boh_esid = rheaderstate.ok
            WHERE  boh_id = p_headerid;
        END IF;

        x_nextseq := getnextpackingsequence (x_packid);

        IF UPPER (NVL (p_jobid, 'NONE')) = 'NONE'
        THEN --033SO
            -- simple packing without schedule. JobId can be
            --  NULL    for a looper with nothing to do
            -- 'none'   for an SPTRY defaulting
            -- 'NONE'   for simple workflows

            IF l_debug >= 5
            THEN --034SO
                pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' simple packing done ', p_filename);
            END IF;

            UPDATE packing
            SET    pac_datedone = SYSDATE,
                   pac_datesta = SYSDATE
            WHERE      pac_id = x_packid
                   AND pac_ltid = 'NONE'
                   AND pac_esid IN (rpackingstate.active);

            IF SQL%ROWCOUNT > 0
            THEN
                IF l_debug >= 5
                THEN --034SO
                    pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' DateDone set ', p_filename);
                END IF;
            ELSE --034SO
                IF l_debug > 0
                THEN
                    pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' DateDone not set (packing is not active)', p_filename);
                END IF;
            END IF;
        ELSE
            pkg_common_stats.update_sta_job_success (p_jobid); --015DA --008SO

            IF l_loop_type = 'NONE'
            THEN --031SO
                IF l_debug >= 5
                THEN --034SO
                    pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' non-looper packing done ', p_filename);
                END IF;

                UPDATE packing
                SET    pac_esid = rpackingstate.active, --010SO
                       pac_datedone = SYSDATE,
                       pac_datesta = SYSDATE
                WHERE      pac_id = x_packid
                       AND pac_ltid = 'NONE'
                       AND pac_esid IN (rpackingstate.scheduled); -- rPackingState.Active,

                IF SQL%ROWCOUNT > 0
                THEN
                    IF l_debug >= 5
                    THEN --034SO
                        pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' DateDone set ', p_filename);
                    END IF;
                ELSE
                    IF l_debug > 0
                    THEN
                        pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' DateDone not set (job is not scheduled any more)', p_filename);
                    END IF;
                END IF;
            ELSE
                -- it's a looper
                UPDATE packing
                SET    pac_esid = rpackingstate.active, --010SO
                       pac_datedone = SYSDATE,
                       pac_datesta = SYSDATE
                WHERE      pac_id = x_packid
                       AND pac_ltid <> 'NONE'
                       AND pac_esid IN (rpackingstate.scheduled) -- rPackingState.Active,
                       AND NOT EXISTS
                               (SELECT staj_id
                                FROM   sta_job,
                                       periodicity
                                WHERE      staj_pacid = x_packid
                                       AND period_id = staj_periodid
                                       AND staj_datesta >= TRUNC (SYSDATE, period_value1)
                                       AND staj_esid <> 'D'
                                       AND staj_esid <> 'O');

                IF SQL%ROWCOUNT > 0
                THEN
                    IF l_debug >= 5
                    THEN --034SO
                        pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' looper done, DateDone set ', p_filename);
                    END IF;
                ELSE --034SO
                    IF l_debug >= 3
                    THEN
                        pkg_common.l ('UPDATE_BOHEADER (' || p_headerid || ') Packing ' || x_packid || ' looper not finished yet, DateDone not set ', p_filename);
                    END IF;
                END IF;
            END IF;
        END IF;

        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'update_boheader'), sbsdb_logger_lib.log_param ('p_filename', p_filename));
    END update_boheader;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getjobcandidatefortype (
        p_packingtype                           IN VARCHAR2,
        p_thread                                IN VARCHAR2)
        RETURN VARCHAR2
    IS
        -- get candidate job id with prepared (active) jobs for given type
        -- only implemented now for p_PackingType = STATIND

        CURSOR cjobcandidates IS
            SELECT   pac_id,
                     staj_id
            FROM     packing,
                     periodicity,
                     sta_job,
                     sta_config
            WHERE        periodicity.period_id = NVL (pac_periodid, 'NONE')
                     AND staj_pacid = pac_id
                     AND staj_esid IN ('A',
                                       'S',
                                       'W') --037SO
                     AND stac_id = 'DEFAULT'
                     AND pac_etid = p_packingtype
                     AND pac_esid IN (rpackingstate.active,
                                      rpackingstate.scheduled)
                     AND pac_execute = 1
                     AND (   pac_xprocid = p_thread
                          OR pac_xprocid IS NULL)
                     AND (   period_id = 'NONE'
                          OR staj_datecre >= TRUNC (SYSDATE, period_value1))
                     AND staj_datecre > SYSDATE - stac_execsched
                     AND NVL (staj_nooftrials, 0) <= stac_nooftrials
            ORDER BY staj_datesta ASC NULLS FIRST;

        l_result                                VARCHAR2 (10);
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'getjobcandidatefortype'),
            sbsdb_logger_lib.log_param ('p_packingtype', p_packingtype),
            sbsdb_logger_lib.log_param ('p_thread', p_thread));

        l_result := NULL;

        FOR cjobcandidatesrow IN cjobcandidates
        LOOP
            IF istimeforpacking (cjobcandidatesrow.pac_id) = 1
            THEN
                l_result := cjobcandidatesrow.staj_id;
            END IF;

            EXIT WHEN NOT (l_result IS NULL);
        END LOOP;

        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'getjobcandidatefortype'), sbsdb_logger_lib.log_param ('return', l_result));

        RETURN l_result;
    END getjobcandidatefortype;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getnextpackingsequence (p_pacid IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cpackingsequence IS
            SELECT     pac_id,
                       pac_fileseqmax,
                       pac_nextseq
            FROM       packing
            WHERE      pac_id = p_pacid
            FOR UPDATE OF pac_nextseq;

        cpackingsequencerow                     cpackingsequence%ROWTYPE;

        l_nextsequence                          NUMBER;
        l_thissequence                          VARCHAR2 (10); --038SO
    BEGIN
        OPEN cpackingsequence;

        FETCH cpackingsequence INTO cpackingsequencerow;

        -- If cPackingSequence%Found Then
        l_nextsequence := cpackingsequencerow.pac_nextseq;
        l_nextsequence := MOD (l_nextsequence, cpackingsequencerow.pac_fileseqmax + 1);
        l_thissequence := TRIM (TO_CHAR (l_nextsequence, REPLACE (TRIM (TO_CHAR (cpackingsequencerow.pac_fileseqmax)), '9', '0')));
        l_nextsequence := l_nextsequence + 1;

        IF l_nextsequence > cpackingsequencerow.pac_fileseqmax
        THEN
            l_nextsequence := 1;
        END IF;

        UPDATE packing
        SET    pac_nextseq = l_nextsequence
        WHERE  CURRENT OF cpackingsequence;

        -- end if;
        CLOSE cpackingsequence;

        RETURN l_thissequence;
    END getnextpackingsequence;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE lock_packing (p_packingid IN VARCHAR2)
    IS
    BEGIN
        UPDATE packing
        SET    pac_esid = rpackingstate.locked
        WHERE  pac_id = p_packingid;
    -- this will fire the trigger STA_WATCHPACKINGSTATECHANGES and
    -- result in the locking of individual jobs. Currently done in PKG_STATS
    END lock_packing;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE setpackingstatescheduled (p_pac_id IN VARCHAR2)
    IS
    BEGIN
        UPDATE packing
        SET    pac_esid = rpackingstate.scheduled, --031SO --010SO
               pac_datesta = SYSDATE
        WHERE  pac_id = p_pac_id;
    END setpackingstatescheduled;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE unlockpacking (p_pac_id IN VARCHAR2)
    IS --041SO
    BEGIN
        UPDATE packing
        SET    pac_esid = rpackingstate.active,
               pac_datesta = SYSDATE
        WHERE      pac_id = p_pac_id
               AND pac_esid = rpackingstate.locked;
    END unlockpacking;
END pkg_common_packing;
/