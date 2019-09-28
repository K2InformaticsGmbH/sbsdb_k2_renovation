CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_stats
IS
    /* =========================================================================
       CALLER --getNextExecDate
       ---------------------------------------------------------------------- */

    TYPE t_caller IS RECORD
    (
        indiv VARCHAR2 (10) := 'INDIV',
        scheduler VARCHAR2 (10) := 'SCHED',
        SYSTEM VARCHAR2 (10) := 'SYSTEM'
    );

    rcaller                                 t_caller;

    /* =========================================================================
       NAMES : STA_JOBPARAM
       ---------------------------------------------------------------------- */

    TYPE t_jobparam IS RECORD
    (
        acid VARCHAR2 (20) := '[AC_ID]',
        conid VARCHAR2 (20) := '[CON_ID]',
        conname VARCHAR2 (20) := '[CON_NAME]',
        datefrom VARCHAR2 (20) := '[DATEFROM]',
        datetill VARCHAR2 (20) := '[DATETILL]',
        dateto VARCHAR2 (20) := '[DATETO]',
        keywords VARCHAR2 (20) := '[KEYWORDS]',
        msisdna VARCHAR2 (20) := '[MSISDN_A]',
        msisdnb VARCHAR2 (20) := '[MSISDN_B]',
        shortid VARCHAR2 (20) := '[SHORT_ID]',
        stajid VARCHAR2 (20) := '[STAJ_ID]'
    );

    rjobparam                               t_jobparam;

    /* =========================================================================
       Notifications.
       ---------------------------------------------------------------------- */

    TYPE t_noteesid IS RECORD
    (
        active notificationtempl.not_esid%TYPE := 'A',
        deleted notificationtempl.not_esid%TYPE := 'D',
        inactive notificationtempl.not_esid%TYPE := 'I'
    );

    rnoteesid                               t_noteesid;

    /* =========================================================================
       PACKING.
       ---------------------------------------------------------------------- */

    TYPE t_pacesid IS RECORD
    (
        active packing.pac_esid%TYPE := 'A',
        deleted packing.pac_esid%TYPE := 'D',
        draft packing.pac_esid%TYPE := 'R',
        inactive packing.pac_esid%TYPE := 'I',
        locked packing.pac_esid%TYPE := 'L',
        scheduled packing.pac_esid%TYPE := 'S'
    );

    rpacesid                                t_pacesid;

    /* =========================================================================
       PACKING.
       ---------------------------------------------------------------------- */

    TYPE t_pacetid IS RECORD
    (
        consol packing.pac_etid%TYPE := 'CONSOL',
        stat packing.pac_etid%TYPE := 'STAT',
        statind packing.pac_etid%TYPE := 'STATIND'
    );

    rpacetid                                t_pacetid;

    /* =========================================================================
       TOKENS : SQL Parameter to replace --scheduleStats
       ---------------------------------------------------------------------- */

    TYPE t_sqlparam IS RECORD
    (
        acid VARCHAR2 (20) := '<AC_ID>',
        archivedir VARCHAR2 (20) := '<ARCHIVEDIR>',
        conid VARCHAR2 (20) := '<CON_ID>',
        conname VARCHAR2 (20) := '<CON_NAME>',
        datefrom VARCHAR2 (20) := '<DATEFROM>',
        datetill VARCHAR2 (20) := '<DATETILL>',
        dateto VARCHAR2 (20) := '<DATETO>',
        filemask VARCHAR2 (20) := '<PAC_FILEMASK>',
        jobid VARCHAR2 (20) := '<STAJ_ID>',
        keyword VARCHAR2 (20) := '<BD_KEYWORD>',
        keywords VARCHAR2 (20) := '<KEYWORDS>',
        mover VARCHAR2 (20) := '<MOVER>',
        msisdna VARCHAR2 (20) := '<MSISDN_A>',
        msisdnb VARCHAR2 (20) := '<MSISDN_B>',
        nextseq VARCHAR2 (20) := '<PAC_NEXTSEQ>',
        noofsql VARCHAR2 (20) := '<NOOFSQL>',
        outdir VARCHAR2 (20) := '<PAC_OUTPUTDIR>',
        pacetid VARCHAR2 (20) := '<PAC_ETID>',
        pacid VARCHAR2 (20) := '<PAC_ID>',
        pacname VARCHAR2 (20) := '<PAC_NAME>',
        pactemp VARCHAR2 (20) := '<PAC_TEMPLATE>',
        pdfmask VARCHAR2 (20) := '<PDFMASK>',
        period VARCHAR2 (20) := '<PERIOD>',
        shortid VARCHAR2 (20) := '<SHORT_ID>',
        status VARCHAR2 (20) := '<PAC_ESID>'
    );

    rsqlparam                               t_sqlparam;

    /* =========================================================================
       JOBS.
       ---------------------------------------------------------------------- */

    TYPE t_stajesid IS RECORD
    (
        active sta_job.staj_esid%TYPE := 'A',
        deleted sta_job.staj_esid%TYPE := 'D',
        draft sta_job.staj_esid%TYPE := 'R',
        error sta_job.staj_esid%TYPE := 'E',
        locked sta_job.staj_esid%TYPE := 'L',
        okay sta_job.staj_esid%TYPE := 'O',
        scheduled sta_job.staj_esid%TYPE := 'S',
        working sta_job.staj_esid%TYPE := 'W'
    );

    rstajesid                               t_stajesid;

    /* =========================================================================
       JOB TYPES for WEB STUFF
       ---------------------------------------------------------------------- */

    TYPE t_stajtype IS RECORD
    ( -- Text from STAJT_LANG01
        pdf sta_jobotype.staot_id%TYPE := 'PDF',
        xls sta_jobotype.staot_id%TYPE := 'XLS'
    );

    rstajtype                               t_stajtype;

    /* =========================================================================
       STATES.
       ---------------------------------------------------------------------- */

    TYPE t_xpresid IS RECORD
    (
        active xproc.xpr_esid%TYPE := 'A',
        deleted xproc.xpr_esid%TYPE := 'D',
        inactive xproc.xpr_esid%TYPE := 'I'
    );

    rxpresid                                t_xpresid;

    /* =========================================================================
       GLOBALS.
       ---------------------------------------------------------------------- */

    --Debug mode on => Entries in tabel STA_DEBUG
    bdebug                                  BOOLEAN := FALSE;

    --user defined error - raised if we dont have a configurations set with id DEFAULT
    no_config_error                         EXCEPTION;

    rconfig                                 sta_config%ROWTYPE;
    rxproc                                  xproc%ROWTYPE;

    --SysInfo for STA_JOB.STAJ_SYSINFO
    vsysinfo                                VARCHAR2 (4000);

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN sta_config%ROWTYPE;

    FUNCTION getxproc (vxprocname IN xproc.xpr_id%TYPE)
        RETURN xproc%ROWTYPE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    -- Check if its worth to get a BOHEADER ID; with other words: do we have to work?
    PROCEDURE anythingtodo (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2);

    PROCEDURE checkdependencies (
        inpacid                                 IN     VARCHAR2,
        indatefrom                              IN     DATE,
        indateto                                IN     DATE,
        odepend                                 IN OUT BOOLEAN,
        odepinfo                                IN OUT tdepinfo,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2);

    ----------------------------------------------------------------------
    -- EXECUTER
    -- Called by XPIOC
    -- Procedures and functions for EXECUTER   ---------------------------

    -- Associative Array, some sort of:-)
    --  1:
    --  2:

    PROCEDURE updatejobonerror (
        pacid                                   IN packing.pac_id%TYPE,
        jobid                                   IN sta_job.staj_id%TYPE,
        p_boh_id                                IN VARCHAR2,
        reason                                  IN VARCHAR2);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Clean already scheduled jobs, which are not executed within
       allowed time frame.
       ---------------------------------------------------------------------- */

    FUNCTION cleanjobs (hrstoexec IN sta_config.stac_execsched%TYPE)
        RETURN NUMBER
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; -- $$$$ check necessity

        nc                                      NUMBER := 0;
    BEGIN
        rconfig := getconfig;

        IF rconfig.stac_id IS NULL
        THEN
            RAISE no_config_error;
        END IF;

        --Clean already scheduled jobs, which exceeded the allowed time frame between date of
        --scheduling/execution execSched (see sta_config)
        UPDATE sta_job
        SET    staj_esid = rstajesid.locked,
               staj_datesta = SYSDATE,
               staj_sysinfo = SUBSTR ('The job got locked by cleanJobs. The timeframe between scheduling and execution is too long.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
        WHERE      staj_esid = rstajesid.scheduled
               AND staj_dateexe < (SYSDATE - ((1 / 24) * hrstoexec));

        nc := SQL%ROWCOUNT;

        --System system locked jobs after 6*allowed time between execution and execSched (see sta_config)
        UPDATE sta_job
        SET    staj_esid = rstajesid.deleted,
               staj_datesta = SYSDATE,
               staj_sysinfo = SUBSTR ('The job got deleted by cleanJobs. The job was already locked for too long.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
        WHERE      staj_esid = rstajesid.locked
               AND staj_dateexe < (SYSDATE - (6 * (1 / 24) * hrstoexec));

        nc := nc + SQL%ROWCOUNT;

        --Set jobs to ERROR where total number of trials exceed maximum of allowed trials (see sta_config.stac_nooftrials)
        UPDATE sta_job
        SET    staj_esid = rstajesid.error,
               staj_datesta = SYSDATE,
               staj_sysinfo = SUBSTR ('Too many unsuccessful trials. Sorry about that.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
        WHERE      staj_esid IN (rstajesid.locked,
                                 rstajesid.scheduled)
               AND staj_nooftrials > rconfig.stac_nooftrials;

        nc := nc + SQL%ROWCOUNT;

        --Set "hanging" (working) back to scheduled if they "hang" longer than stac_waitforwork hours
        --but only for STAT and STATIND and NOT CONSOL
        UPDATE sta_job
        SET    staj_esid = rstajesid.scheduled,
               staj_datesta = SYSDATE,
               staj_sysinfo = SUBSTR ('Job status was set back to scheduled by cleanJobs.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
        WHERE      staj_esid = rstajesid.working
               AND SYSDATE > staj_datesta + (1 / 24 * rconfig.stac_waitforwork)
               AND staj_pacid IN (SELECT pac_id
                                  FROM   packing
                                  WHERE  pac_etid IN (rpacetid.stat,
                                                      rpacetid.statind));

        nc := nc + SQL%ROWCOUNT;

        COMMIT; -- $$$$ check necessity

        RETURN nc;
    EXCEPTION
        WHEN no_config_error
        THEN
            pkg_common.insert_warning ('PKG_STATS', 'cleanJobs', 'Error ', 'No configuration (DEFAULT) found. Check STA_CONFIG.'); -- 023SO
            ROLLBACK; -- $$$$ check necessity
            RETURN 0;
        WHEN OTHERS
        THEN
            ROLLBACK; -- $$$$ check necessity

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'cleanJobs',
                    SQLCODE,
                    SQLERRM,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'cleanJobs', 'Error', SQLCODE || ': ' || SQLERRM); -- 023SO
            END IF;

            RETURN 0;
    END cleanjobs;

    /* =========================================================================
       Evaluate next execution date for certain package.

       This procedure is used in two different ways and meanings:
       If the caller is SYSTEM, we try to figure out when the next execution date is
       If the caller is INDIV, we figure, when is the next exec date for the packing, so that
       the inRefDate is included! Big difference...
       ---------------------------------------------------------------------- */

    FUNCTION getnextexecdate (
        incaller                                IN VARCHAR2,
        inpacid                                 IN VARCHAR2,
        inrefdate                               IN DATE)
        RETURN DATE
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; -- $$$$ check necessity

        CURSOR cpacking (inpacid IN packing.pac_id%TYPE)
        IS
            SELECT   pac_id,
                     pac_name,
                     pac_periodid,
                     pac_datedone,
                     pac_esid,
                     NVL (pac_startday, 0)        AS pac_startday,
                     NVL (pac_starthour, 0)       AS pac_starthour,
                     NVL (pac_startminute, 0)     AS pac_startminute,
                     period_durseq
            FROM     packing,
                     periodicity
            WHERE        pac_periodid = period_id
                     AND pac_id = inpacid
            ORDER BY period_durseq DESC, -- $$$$ check ordering
                     pac_startday DESC,
                     pac_starthour DESC,
                     pac_startminute DESC;

        cpackingrow                             cpacking%ROWTYPE;
        ddatedone                               DATE;
        dnextexecdate                           DATE;
        vhour                                   VARCHAR2 (2) := 0;
    BEGIN
        SET TRANSACTION READ ONLY; -- $$$$ check necessity

        vhour := TO_CHAR (inrefdate, 'HH24');

       <<loop_cpacking>>
        FOR cpackingrow IN cpacking (inpacid)
        LOOP
            ddatedone := cpackingrow.pac_datedone;

            IF cpackingrow.pac_periodid = 'YEARLY'
            THEN
                --First: get allowed nextDate for reference Date,
                --considering earliest possible startday and time

                dnextexecdate :=
                    TRUNC (inrefdate, 'YEAR') + (NVL (cpackingrow.pac_startday, 1) - 1) + ((1 / 24) * NVL (cpackingrow.pac_starthour, 0)) + ((1 / 1440) * NVL (cpackingrow.pac_startminute, 0));

                --If caller is system, then we check when we have to execute next time
                --Type: STAT and CONSOL
                IF incaller = rcaller.SYSTEM
                THEN
                    --Was last dateDone after next proposed execution? then move next execution into next period or
                    --Last dateDone was whenever but already in the same period...
                    IF ddatedone >= TRUNC (inrefdate, 'YEAR')
                    THEN
                        dnextexecdate := ADD_MONTHS (dnextexecdate, 12); -- 014SO
                    END IF;
                END IF;
            END IF;

            IF cpackingrow.pac_periodid = 'MONTHLY'
            THEN
                --First: get allowed nextDate for reference Date,
                --considering earliest possible startday and time

                SELECT TRUNC (inrefdate, 'MONTH') + (NVL (cpackingrow.pac_startday, 1) - 1) + ((1 / 24) * NVL (cpackingrow.pac_starthour, 0)) + ((1 / 1440) * NVL (cpackingrow.pac_startminute, 0))
                INTO   dnextexecdate
                FROM   DUAL; -- 014SO

                --If caller is system, then we check when we have to execute next time
                --Type: STAT and CONSOL
                IF incaller = rcaller.SYSTEM
                THEN
                    --Was last dateDone after next proposed execution? then move next execution into next period or
                    --Last dateDone was whenever but already in the same period...
                    IF ddatedone >= TRUNC (inrefdate, 'MONTH')
                    THEN
                        dnextexecdate := ADD_MONTHS (dnextexecdate, 1); -- 014SO
                    END IF;
                END IF;
            END IF;

            IF cpackingrow.pac_periodid = 'WEEKLY'
            THEN
                --first possible execution date of the week
                --fetch monday's date of current week
                SELECT TRUNC (inrefdate, 'day') + (NVL (cpackingrow.pac_startday, 1) - 1) -- 014SO  -- 012SO
                                                                                          + ((1 / 24) * NVL (cpackingrow.pac_starthour, 0)) + ((1 / 1440) * NVL (cpackingrow.pac_startminute, 0))
                INTO   dnextexecdate
                FROM   DUAL;

                --If caller is system, then we check when we have to execute next time
                IF incaller = rcaller.SYSTEM
                THEN
                    IF ddatedone >= TRUNC (inrefdate, 'day')
                    THEN
                        dnextexecdate := dnextexecdate + 7;
                    END IF;
                END IF;
            END IF;

            IF cpackingrow.pac_periodid = 'DAILY'
            THEN
                --first possible execution date of that day
                dnextexecdate := TRUNC (inrefdate) + ((1 / 24) * NVL (cpackingrow.pac_starthour, 0)) + ((1 / 1440) * NVL (cpackingrow.pac_startminute, 0));

                --If caller is system, then we check when we have to execute next time
                IF incaller = rcaller.SYSTEM
                THEN
                    IF ddatedone >= TRUNC (inrefdate)
                    THEN
                        dnextexecdate := dnextexecdate + 1;
                    END IF;
                END IF;
            END IF;

            IF cpackingrow.pac_periodid = 'HOURLY'
            THEN
                --first possible execution date of that date
                dnextexecdate := TRUNC (inrefdate, 'hh24');

                --If caller is system, then we check when we have to execute next time
                IF incaller = rcaller.SYSTEM
                THEN
                    IF ddatedone >= TRUNC (inrefdate, 'hh24')
                    THEN
                        dnextexecdate := TRUNC (dnextexecdate, 'hh24') + 1 / 24;
                    END IF;
                END IF;
            END IF;
        END LOOP loop_cpacking;

        COMMIT; --end READ ONLY         -- $$$$ check necessity

        RETURN dnextexecdate;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'getNextExecDate',
                    SQLCODE,
                    SQLERRM,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'getNextExecDate',
                    'Error ' || inpacid,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    inpacid); -- 023SO
            END IF;

            COMMIT; --end READ ONLY           -- $$$$ check necessity
            RETURN NULL;
    END getnextexecdate;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Check possible dates of base table for offering to customer (web-gui).
       ---------------------------------------------------------------------- */

    PROCEDURE checkbasetabledata (
        inpacid                                 IN     VARCHAR2,
        outdatefrom                                OUT DATE,
        outdateto                                  OUT DATE,
        outdrop                                    OUT NUMBER,
        outdropperiod                              OUT VARCHAR2,
        outdatefromraw                             OUT DATE,
        outdatetoraw                               OUT DATE,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; -- $$$$ check necessity

        --Dynamic cursor: to bind run time
        TYPE tbasetable IS REF CURSOR;

        cvbasetable                             tbasetable;

        vbtconsol                               sta_pacparam.stap_value%TYPE;
        nbtdrop                                 sta_pacparam.stap_drop%TYPE;
        vbtdropperiodid                         sta_pacparam.stap_dropperiodid%TYPE;

        vbtraw                                  sta_pacparam.stap_value%TYPE;

        vselect                                 VARCHAR2 (2000) := 'select minDate, maxDate from sta_checkBT_';
    BEGIN
        SET TRANSACTION READ ONLY; -- $$$$ check necessity

        --Read BaseTable Name from sta_pacparam
        BEGIN
            SELECT stap_value,
                   stap_drop,
                   stap_dropperiodid
            INTO   vbtconsol,
                   nbtdrop,
                   vbtdropperiodid
            FROM   sta_pacparam
            WHERE      stap_pacid = inpacid
                   AND stap_name = '[BASE_TABLE]';
        EXCEPTION
            WHEN OTHERS
            THEN -- 008SO
                vbtconsol := NULL;
                nbtdrop := NULL;
                vbtdropperiodid := NULL;
        END;

        BEGIN
            SELECT stap_value
            INTO   vbtraw
            FROM   sta_pacparam
            WHERE      stap_pacid = inpacid
                   AND stap_name = '[BASE_TABLE_RAW]';
        EXCEPTION -- 008SO
            WHEN OTHERS
            THEN
                vbtraw := NULL;
        END;

        --If no baseTable is available return null
        IF     (   vbtconsol IS NULL
                OR vbtconsol = 'unknown')
           AND (   vbtraw IS NULL
                OR vbtraw = 'unknown')
        THEN
            recordsaffected := 0;
        ELSE
            --we have got the baseTable and try to get min(date) and max(date) -> use views:
            --get the BaseTable Consol dates
            IF     vbtconsol IS NOT NULL
               AND vbtconsol <> 'unknown'
            THEN
                vselect := vselect || vbtconsol;

                OPEN cvbasetable FOR vselect;

                LOOP
                    FETCH cvbasetable
                        INTO outdatefrom,
                             outdateto;

                    EXIT WHEN cvbasetable%NOTFOUND;
                    recordsaffected := 1;
                END LOOP;

                CLOSE cvbasetable;

                outdrop := nbtdrop;
                outdropperiod := vbtdropperiodid;
            END IF;

            --get the BaseTable Raw dates
            vselect := 'select minDate, maxDate from sta_checkBT_';

            IF     vbtraw IS NOT NULL
               AND vbtraw <> 'unknown'
            THEN
                vselect := vselect || vbtraw;

                OPEN cvbasetable FOR vselect;

                LOOP
                    FETCH cvbasetable
                        INTO outdatefromraw,
                             outdatetoraw;

                    EXIT WHEN cvbasetable%NOTFOUND;
                    recordsaffected := 1;
                END LOOP;

                CLOSE cvbasetable;
            END IF;
        END IF;

        returnstatus := 1;

        COMMIT; --End READ ONLY             -- $$$$ check necessity
    EXCEPTION
        WHEN OTHERS
        THEN
            outdatefrom := NULL;
            outdateto := NULL;
            outdrop := NULL;
            outdropperiod := NULL;

            outdatefromraw := NULL;
            outdatetoraw := NULL;
            recordsaffected := 0;

            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'checkBaseTableData',
                    SQLCODE,
                    SQLERRM,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'checkBaseTableData',
                    'Error ' || inpacid,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    inpacid); -- 023SO
            END IF;

            COMMIT; --end READ ONLY      -- $$$$ check necessity
    END checkbasetabledata;

    /* =========================================================================
       Executes next Job in Queue.
       ---------------------------------------------------------------------- */

    PROCEDURE getnextjob (
        p_pact_id                               IN     VARCHAR2 DEFAULT NULL,
        p_boh_id                                IN     VARCHAR2 DEFAULT NULL,
        arrkey                                     OUT tkey,
        arrvalue                                   OUT tvalue,
        arrnote                                    OUT tnote,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2)
    IS
        vxprocname                              xproc.xpr_id%TYPE := returnstatus;

        vjobid                                  sta_job.staj_id%TYPE;
        vjobpacid                               sta_job.staj_pacid%TYPE;

        ncount                                  NUMBER := 0;
        nreccount                               NUMBER := 0;
        ni                                      NUMBER := 1;
        nsql                                    NUMBER := 0;

        --Array for dependencies
        tdepi                                   pkg_stats.tdepinfo;

        bdepend                                 BOOLEAN;
        bgoahead                                BOOLEAN := FALSE;

        dfrom                                   DATE;
        dto                                     DATE;

        --Debug
        vp                                      VARCHAR2 (10);
        vpn                                     VARCHAR2 (100);
        vpe                                     DATE;

        --Version 1: get next jobs, ordered by dependencies and staj_dateexe, pac_datetry
        --sta_getnextjob = VIEW
        CURSOR cjob (vxproc IN xproc.xpr_id%TYPE)
        IS
            SELECT wicki,
                   staj_id,
                   staj_pacid,
                   staj_dateexe,
                   pac_datetry,
                   pac_datedone,
                   pac_outputdir,
                   staj_datesta,
                   dateexe,
                   staj_esid,
                   pac_esid,
                   staj_etid,
                   pac_etid,
                   pac_ltid,
                   staj_ltvalue,
                   pac_template,
                   pac_filemask,
                   pac_nextseq,
                   pac_id,
                   pac_name,
                   period,
                   pac_notification,
                   pac_notid,
                   staj_sysinfo,
                   pac_pdfmask,
                   pac_archivestatistic,
                   pac_archivedir,
                   staj_directoryid
            FROM   sta_getnextjob
            WHERE      pac_esid IN (rpacesid.active,
                                    rpacesid.scheduled)
                   AND SYSDATE >= staj_dateexe
                   AND SYSDATE < staj_dateexe + (1 / 24) * rconfig.stac_execsched -- 006SO
                   AND pac_xprocid = vxproc
                   --exclude the original jobs of repeat monkeys. only their children get executed
                   AND (   (    stajp_value = '01.01.2100 00:00:00'
                            AND staj_parentid = 0)
                        OR (    stajp_value <> '01.01.2100 00:00:00'
                            AND staj_parentid <> 0)) -- 006SO
                                                    ;

        cjobrow                                 cjob%ROWTYPE;

        --Fetch parameters for one JOB
        CURSOR cparam (vjob IN sta_job.staj_id%TYPE)
        IS
            SELECT stajp_name,
                   stajp_value
            FROM   sta_jobparam
            WHERE  stajp_jobid = vjob;

        cparamrow                               cparam%ROWTYPE;

        --Fetch sql-statements for one JOB
        CURSOR csql (vjob IN sta_job.staj_id%TYPE)
        IS
            SELECT stajq_queryname,
                   stajq_sql
            FROM   sta_jobsql
            WHERE  stajq_jobid = vjob;

        csqlrow                                 csql%ROWTYPE;

        --Notification details
        CURSOR cnote (vnotid IN VARCHAR2)
        IS
            SELECT *
            FROM   notificationtempl
            WHERE      UPPER (not_id) = UPPER (vnotid)
                   AND not_esid = rnoteesid.active;

        cnoterow                                cnote%ROWTYPE;

        CURSOR cnotparam (vnotid IN VARCHAR2)
        IS
            SELECT *
            FROM   not_param
            WHERE  UPPER (notp_notid) = UPPER (vnotid);

        cnotparamrow                            cnotparam%ROWTYPE;

        --Dynamic cursor: to bind run time
        TYPE tdyncursor IS REF CURSOR;

        cvcursor                                tdyncursor;

        vcursor                                 VARCHAR2 (4000);
        vcursorvalue                            VARCHAR2 (300);
        vtemp                                   VARCHAR2 (4000);
        vtempparam                              not_param.notp_name%TYPE;
        vmover                                  sta_directory.stad_mover%TYPE;

        no_directorypath                        EXCEPTION;
    BEGIN
        --Clear values
        arrkey.delete;
        arrvalue.delete;
        arrnote.delete;

        --Read the acual configuration settings
        rconfig := getconfig;

        IF rconfig.stac_id IS NULL
        THEN
            RAISE no_config_error;
        END IF;

        --First get rid of "old" jobs, that means jobs which are scheduled but
        --shouldnt be executed anymore, because the schedule time was too long
        --see sta_config (DEFAULT is 720 hrs = 1 Month)

        ncount := cleanjobs (rconfig.stac_execsched);

        --Initalize ReturnValues
        recordsaffected := 0;
        ncount := 0;
        nreccount := 0;

       --Check each dependencies of each scheduled JOB
       --if dependencies are okay: fetch parameters/sql statements and fill
       --return array

       <<loop_cjob>>
        FOR cjobrow IN cjob (vxprocname)
        LOOP
            --clear old values
            ni := 1;
            bdepend := FALSE;

            vjobid := cjobrow.staj_id;
            vjobpacid := cjobrow.staj_pacid;

           --Try to find parameter [DATEFROM] and [DATETO] for checking dependencies
           <<loop_cparam>>
            FOR cparamrow IN cparam (vjobid)
            LOOP
                IF cparamrow.stajp_name = rjobparam.datefrom
                THEN
                    dfrom := TO_DATE (cparamrow.stajp_value, 'DD.MM.YYYY HH24:MI:SS');
                END IF;

                IF cparamrow.stajp_name = rjobparam.dateto
                THEN
                    dto := TO_DATE (cparamrow.stajp_value, 'DD.MM.YYYY HH24:MI:SS');
                END IF;
            END LOOP loop_cparam;

            IF     dfrom IS NOT NULL
               AND dto IS NOT NULL
            THEN
                returnstatus := rcaller.indiv;
                pkg_stats.checkdependencies (
                    vjobpacid,
                    dfrom,
                    dto,
                    bdepend,
                    tdepi,
                    recordsaffected,
                    errorcode,
                    errormsg,
                    returnstatus);

                IF recordsaffected > 0
                THEN
                    vp := tdepi (1).deppacid;
                    vpn := tdepi (1).deppacname;
                    vpe := TO_DATE (tdepi (1).deppacexec);

                    IF vpe < SYSDATE
                    THEN
                        vpe := SYSDATE + 0.5 / 24; -- 007SO
                    END IF;

                    IF SUBSTR (cjobrow.staj_sysinfo, 1, 10) <> 'Dependency'
                    THEN
                        --Shift the execution date and note the dependency in sysinfo
                        UPDATE sta_job
                        SET    staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                               staj_dateexe = vpe,
                               staj_datetry = SYSDATE,
                               staj_bohidexec = p_boh_id,
                               staj_sysinfo =
                                   SUBSTR (
                                          'Dependency on '
                                       || tdepi (1).deppacid
                                       || ' (next execution after '
                                       || TO_CHAR (TO_DATE (tdepi (1).deppacexec) + 1)
                                       || ').'
                                       || CHR (10)
                                       || SUBSTR (staj_sysinfo, 1, 3000),
                                       1,
                                       3999)
                        WHERE  staj_id = vjobid;
                    ELSE
                        --Only shift the execution date. Do not note the dependency in sysinfo again    -- 007SO
                        UPDATE sta_job
                        SET    staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                               staj_dateexe = vpe,
                               staj_datetry = SYSDATE,
                               staj_bohidexec = p_boh_id
                        WHERE  staj_id = vjobid;
                    END IF;
                END IF;
            ELSE
                --Cant check dependencies because of missing parameters <DATEFROM> and <DATETO>
                UPDATE sta_job
                SET    staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                       staj_datetry = SYSDATE,
                       staj_nooftrials = DECODE (staj_nooftrials, NULL, 1, staj_nooftrials + 1),
                       staj_sysinfo =
                           SUBSTR (
                               'Couldnt execute job because of failing checkDependencies. Parameter [DATEFROM] and/or [DATETO] are missing.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000),
                               1,
                               3999)
                WHERE  staj_id = vjobid;
            END IF;

            --if we dont have open dependencies (bDepend is false) then send the information back to exececuter
            IF NOT bdepend
            THEN
                --Check job type (CONSOL or STAT(ind)) and cross-check CONFIGURATION -> STAC_EXECPROC STAC_EXECREP
                --if the flags are set to 0 = off; skip this job and try to fetch another one
                --Check type CONSOL
                IF cjobrow.pac_etid = rpacetid.consol
                THEN
                    IF rconfig.stac_execproc = 0
                    THEN
                        --The Procedure Module is deactivated! dont do anything...
                        IF rconfig.stac_syslogger = 1
                        THEN
                            writesyslog (
                                'anythingToDo',
                                777777,
                                'The STATS Procedure Module is deactivated. Controll the Configuration.',
                                p_pact_id,
                                SYSDATE);
                        END IF;
                    ELSE
                        bgoahead := TRUE;
                    END IF;
                END IF;

                --Check type STAT
                IF    cjobrow.pac_etid = rpacetid.stat
                   OR cjobrow.pac_etid = rpacetid.statind
                THEN
                    IF rconfig.stac_execrep = 0
                    THEN
                        --The Procedure Module is deactivated! dont do anything...
                        IF rconfig.stac_syslogger = 1
                        THEN
                            writesyslog (
                                'anythingToDo',
                                777777,
                                'The STATS Report Module is deactivated. Controll the Configuration.',
                                p_pact_id,
                                SYSDATE);
                        END IF;
                    ELSE
                        bgoahead := TRUE;
                    END IF;
                END IF;

                --shall we work with a "working state"?
                IF bgoahead
                THEN
                    --we found the next job to work on; send results back to XPIOC and wait till next time sunshine, babe!
                    --Fill information for VB-XPIOC-Executer into Array
                    --1
                    arrkey (ni) := rsqlparam.pacetid;
                    arrvalue (ni) := cjobrow.pac_etid;
                    ni := ni + 1;
                    --2
                    arrkey (ni) := rsqlparam.jobid;
                    arrvalue (ni) := vjobid;
                    ni := ni + 1;
                    --3
                    arrkey (ni) := '<' || cjobrow.pac_ltid || '>';
                    arrvalue (ni) := cjobrow.staj_ltvalue;
                    ni := ni + 1;
                    --4
                    arrkey (ni) := rsqlparam.pactemp;
                    arrvalue (ni) := cjobrow.pac_template;
                    ni := ni + 1;

                    --5
                    arrkey (ni) := rsqlparam.outdir;
                    arrvalue (ni) := cjobrow.pac_outputdir;
                    ni := ni + 1;

                    --6
                    arrkey (ni) := rsqlparam.status;
                    arrvalue (ni) := cjobrow.pac_esid;
                    ni := ni + 1;

                    --7
                    arrkey (ni) := rsqlparam.filemask;
                    arrvalue (ni) := cjobrow.pac_filemask;
                    ni := ni + 1;

                    --8
                    arrkey (ni) := rsqlparam.nextseq;
                    arrvalue (ni) := cjobrow.pac_nextseq;
                    ni := ni + 1;

                    --9
                    arrkey (ni) := rsqlparam.pacid;
                    arrvalue (ni) := cjobrow.pac_id;
                    ni := ni + 1;

                    --10
                    arrkey (ni) := rsqlparam.pacname;
                    arrvalue (ni) := cjobrow.pac_name;
                    ni := ni + 1;

                    --11
                    arrkey (ni) := rsqlparam.period;
                    arrvalue (ni) := cjobrow.period;
                    ni := ni + 1;

                    --12 No. of SQL statements
                    BEGIN
                        SELECT COUNT (*)
                        INTO   nsql
                        FROM   sta_jobsql
                        WHERE  stajq_jobid = vjobid;

                        IF nsql IS NULL
                        THEN
                            nsql := 0;
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            nsql := 0;
                        WHEN OTHERS
                        THEN
                            nsql := 0;
                    END;

                    arrkey (ni) := rsqlparam.noofsql;
                    arrvalue (ni) := nsql;
                    ni := ni + 1;

                    --001AH Add PDFMASK Parameter if STAC_CONFIG.STAC_EXECPDF is set to 1
                    --13 PDF MASK
                    arrkey (ni) := rsqlparam.pdfmask;

                    IF rconfig.stac_execpdf = 1
                    THEN
                        arrvalue (ni) := cjobrow.pac_pdfmask;
                    ELSE
                        arrvalue (ni) := NULL;
                    END IF;

                    ni := ni + 1;

                    --002AH Add ARCHIVE DIR Parameter if PAC_ARCHIVESTATISTIC=1
                    --14 ARCHIVE DIR
                    arrkey (ni) := rsqlparam.archivedir;
                    arrvalue (ni) := NULL;

                    IF rpacetid.stat = cjobrow.pac_etid
                    THEN
                        IF cjobrow.pac_archivestatistic = 1
                        THEN
                            arrvalue (ni) := cjobrow.pac_archivedir;
                        ELSE
                            arrvalue (ni) := NULL;
                        END IF;
                    END IF;

                    ni := ni + 1;

                    --15 User defined OUTPUT DIR from staj_directoryid -> sta_directory
                    arrkey (ni) := rsqlparam.mover;

                    IF cjobrow.staj_directoryid IS NOT NULL
                    THEN --OH, we have to fetch a user defined output dir
                        BEGIN
                            SELECT stad_mover
                            INTO   vmover
                            FROM   sta_directory
                            WHERE  stad_id = cjobrow.staj_directoryid;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                RAISE no_directorypath;
                        END;

                        arrvalue (ni) := vmover;
                    ELSE
                        arrvalue (ni) := NULL;
                    END IF;

                    ni := ni + 1;

                    --Fetch parameter for this job
                    --Start with 20
                    ni := 20;

                   --Fetch SQL Definitions from sta_jobsql

                   <<loop_csql>>
                    FOR csqlrow IN csql (vjobid)
                    LOOP
                        arrkey (ni) := csqlrow.stajq_queryname;
                        arrvalue (ni) := csqlrow.stajq_sql;
                        ni := ni + 1;
                    END LOOP loop_csql;

                    --writeSysLog('getNextJob', 0, 'afterSqlRow', arrValue(nI-1), sysdate);
                    --Check if we have to send notifications around the world
                    --if yes, collect notification info, recipient list, and replace params in body of notification
                    --and send the whole package back to xpioc for delivery
                    IF cjobrow.pac_notification = 1
                    THEN
                       <<loop_cnote>>
                        FOR cnoterow IN cnote (cjobrow.pac_notid)
                        LOOP
                            --fetch data into vector

                            arrnote (1) := 1; --1= send notification; 0=dont send
                            arrnote (2) := cnoterow.not_id;
                            arrnote (3) := cnoterow.not_subject;
                            arrnote (4) := cnoterow.not_body;
                            vtemp := cnoterow.not_body;
                            arrnote (5) := cnoterow.not_senderdisp;
                            arrnote (6) := cnoterow.not_sendertxt;
                            arrnote (7) := cnoterow.not_recdisp;
                            arrnote (8) := cnoterow.not_adrfrom;
                            arrnote (9) := cnoterow.not_adrto;
                            arrnote (10) := cnoterow.not_adrcc;
                            arrnote (11) := cnoterow.not_adrbcc;
                            arrnote (12) := cnoterow.not_attfile;
                            arrnote (13) := cnoterow.not_etid;

                            --get recipients
                            IF LOWER (SUBSTR (arrnote (8), 1, 6)) = 'select'
                            THEN
                                vcursor := arrnote (8);

                                OPEN cvcursor FOR vcursor;

                                arrnote (8) := NULL;

                                LOOP
                                    --loop value, e.g. con_id, ac_id or something equal
                                    FETCH cvcursor INTO vcursorvalue;

                                    EXIT WHEN cvcursor%NOTFOUND;
                                    arrnote (8) := arrnote (8) || rconfig.stac_separator || vcursorvalue;
                                END LOOP;

                                CLOSE cvcursor;

                                --check if we found some recipients
                                IF arrnote (8) IS NULL
                                THEN
                                    arrnote (1) := 0;

                                    --write warning
                                    IF rconfig.stac_logwarning = 1
                                    THEN
                                        pkg_common.insert_warning (
                                            'PKG_STATS',
                                            'getNextJob',
                                            'Error ' || p_boh_id,
                                            'Couldnt find any recipient with the not_adrto select statement (' || vjobpacid || '). No notification was sent.',
                                            NULL,
                                            p_boh_id); -- 023SO
                                    END IF;
                                END IF;
                            END IF;

                            --HACK: Replace all know parameters
                            vtemp := REPLACE (vtemp, '<Recipients>', arrnote (9));
                            vtemp := REPLACE (vtemp, '<ReceiptDate>', SYSDATE);
                            vtemp := REPLACE (vtemp, '<FileCreationDate>', SYSDATE);
                            vtemp := REPLACE (vtemp, '<PackingName>', cjobrow.pac_name);
                            vtemp := REPLACE (vtemp, '<PackingId>', vjobpacid);
                            vtemp := REPLACE (vtemp, '<SenderEmail>', arrnote (8));
                            vtemp := REPLACE (vtemp, '<FileType>', 'Excel');

                            IF vjobpacid = 'SR033a'
                            THEN
                                SELECT COUNT (*) INTO nreccount FROM sr033a_details;

                                vtemp := REPLACE (vtemp, '<RecordCount>', nreccount);
                            END IF;

                           --replace already known params
                           <<loop_cnotparam>>
                            FOR cnotparamrow IN cnotparam (cjobrow.pac_notid)
                            LOOP
                                vtempparam := cnotparamrow.notp_name;

                                IF vtempparam = '<Recipients>'
                                THEN
                                    vtemp := REPLACE (vtemp, vtempparam, arrnote (9));
                                END IF;

                                IF    vtempparam = '<ReceiptDate>'
                                   OR vtempparam = '<FileCreationDate>'
                                THEN
                                    vtemp := REPLACE (vtemp, vtempparam, SYSDATE);
                                END IF;

                                IF vtempparam = '<PackingName>'
                                THEN
                                    vtemp := REPLACE (vtemp, vtempparam, cjobrow.pac_name);
                                --writeSysLog('getNextJob', 99, vTempParam, vTemp, sysdate);
                                END IF;

                                IF vtempparam = '<PackingId>'
                                THEN
                                    vtemp := REPLACE (vtemp, vtempparam, vjobpacid);
                                --writeSysLog('getNextJob', 99, vTempParam, vTemp, sysdate);
                                END IF;

                                IF vtempparam = '<SenderEmail>'
                                THEN
                                    vtemp := REPLACE (vtemp, vtempparam, arrnote (8));
                                --writeSysLog('getNextJob', 99, vTempParam, vTemp, sysdate);
                                END IF;
                            END LOOP loop_cnotparam;

                            arrnote (4) := vtemp;
                        END LOOP loop_cnote;

                        --for debugging
                        --writeSysLog('getNextJob', 0, 'gotcha', vTemp, sysdate);

                        --Check if we could find the proper notification; if not write warning
                        IF arrnote.COUNT = 0
                        THEN
                            IF rconfig.stac_logwarning = 1
                            THEN
                                pkg_common.insert_warning (
                                    'PKG_STATS',
                                    'getNextJob',
                                    'Error ' || p_boh_id,
                                    'Couldnt find proper notification template for packing ' || vjobpacid || '. No notification was sent.',
                                    NULL,
                                    p_boh_id); -- 023SO
                            END IF;
                        END IF;
                    END IF; --Notification

                    --set status to "working", update no of trials and datetry...
                    UPDATE sta_job
                    SET    staj_esid = rstajesid.working,
                           staj_datesta = SYSDATE,
                           staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                           staj_datetry = SYSDATE,
                           staj_nooftrials = staj_nooftrials + 1,
                           staj_bohidexec = p_boh_id,
                           staj_sysinfo = SUBSTR ('Processing started at ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS') || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
                    WHERE  staj_id = vjobid;

                    ncount := 1;
                    --we are done: exit loop
                    EXIT;
                END IF; --end bGoAhead
            END IF; --end bDepend
        END LOOP;

        COMMIT; -- $$$$ check necessity
        returnstatus := 1;
        recordsaffected := ncount;
    EXCEPTION
        WHEN no_directorypath
        THEN
            pkg_common.insert_warning ('PKG_STATS', 'getNextJob', 'Error ', 'No user defined directory path found. Check STA_DIRECTORY.'); -- 023SO

            recordsaffected := 0;
            returnstatus := 0;
        WHEN no_config_error
        THEN
            pkg_common.insert_warning ('PKG_STATS', 'getNextJob', 'Error ', 'No configuration (DEFAULT) found. Check STA_CONFIG.'); -- 023SO

            recordsaffected := 0;
            returnstatus := 0;
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'getNextJob',
                    SQLCODE,
                    SQLERRM,
                    'vJobId: ' || vjobid || ', vJobPacId: ' || vjobpacid,
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'getNextJob',
                    'Error ' || p_boh_id,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    p_boh_id); -- 023SO
            END IF;
    END getnextjob;

    /* =========================================================================
       Schedule standard periodical stats and consolidation and individual
       stats.
       ---------------------------------------------------------------------- */

    PROCEDURE schedulestats (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2)
    IS
        vxprocname                              xproc.xpr_id%TYPE := returnstatus;

        vpacid                                  packing.pac_id%TYPE;
        vpacltid                                packing.pac_ltid%TYPE;
        vpacitid                                packing.pac_itid%TYPE;

        vltid                                   packing.pac_ltid%TYPE;
        vstajpvalue                             sta_jobparam.stajp_name%TYPE;

        vsql                                    sta_jobsql.stajq_sql%TYPE;
        vqname                                  sta_sqldef.staq_queryname%TYPE;

        viterator                               VARCHAR2 (4000) := 'select ''TwoFlowers'' objectID from dual';
        viteratorvalue                          VARCHAR2 (10);

        ddatefrom                               DATE;
        ddateto                                 DATE;
        ddatetill                               DATE := TO_DATE ('01.01.2100', 'DD.MM.YYYY');
        ddateexec                               DATE;

        vjobid                                  sta_job.staj_id%TYPE;
        vnewjobid                               sta_job.staj_id%TYPE;
        vperiod                                 sta_job.staj_periodid%TYPE;

        dfrom                                   DATE;
        dto                                     DATE;
        dtoto                                   DATE;
        dtill                                   DATE;
        vtill                                   sta_jobparam.stajp_value%TYPE;

        dnextexecdate                           DATE;
        ncount                                  NUMBER := 0;
        nsqldef                                 NUMBER := 0;

        brepeat                                 BOOLEAN := FALSE;
        bgo                                     BOOLEAN := FALSE;
        blooped                                 BOOLEAN := FALSE;

        vgo                                     VARCHAR2 (4000);

        nsql                                    NUMBER;
        vtempstring                             sta_pacparam.stap_name%TYPE;

        --Cursor for iterating throu packing table -> XPIOC
        CURSOR cpacking (vxproc IN xproc.xpr_id%TYPE)
        IS
            SELECT   pac_id,
                     pac_ltid,
                     pac_name,
                     pac_periodid,
                     pac_datedone,
                     NVL (pac_startday, 0)        AS pac_startday,
                     NVL (pac_starthour, 0)       AS pac_starthour,
                     NVL (pac_startminute, 0)     AS pac_startminute,
                     period_durseq,
                     pac_datetry,
                     pac_itid,
                     pac_etid,
                     pac_conditionalexec,
                     pac_directoryid,
                     pac_execdelay
            FROM     packing,
                     periodicity
            WHERE        pac_periodid = period_id
                     AND pac_esid = rpacesid.active
                     AND pac_etid IN (rpacetid.stat,
                                      rpacetid.consol)
                     AND pac_xprocid = vxproc
            ORDER BY period_durseq DESC, -- $$$$ check ordering
                     pac_startday DESC,
                     pac_starthour DESC,
                     pac_startminute DESC,
                     pac_datetry ASC;

        CURSOR csqldef (vpac IN packing.pac_id%TYPE)
        IS
            SELECT *
            FROM   sta_sqldef
            WHERE  staq_pacid = vpac;

        csqlrow                                 csqldef%ROWTYPE;

        CURSOR cpacparam (vpacid IN packing.pac_id%TYPE)
        IS
            SELECT *
            FROM   sta_pacparam
            WHERE      stap_abs = 1
                   AND stap_pacid = vpacid;

        cpacparamrow                            cpacparam%ROWTYPE;

        CURSOR cjob (vxproc IN xproc.xpr_id%TYPE)
        IS
            SELECT   staj_id,
                     staj_ltvalue,
                     staj_periodid,
                     pac_ltid,
                     pac_id,
                     pac_name,
                     pac_periodid,
                     pac_datedone,
                     pac_esid,
                     pac_itid,
                     NVL (pac_startday, 0)        AS pac_startday,
                     NVL (pac_starthour, 0)       AS pac_starthour,
                     NVL (pac_startminute, 0)     AS pac_startminute,
                     period_durseq,
                     pac_execdelay
            FROM     sta_job,
                     packing,
                     periodicity
            WHERE        staj_pacid = pac_id
                     AND pac_periodid = period_id
                     AND pac_etid IN (rpacetid.consol,
                                      rpacetid.stat,
                                      rpacetid.statind)
                     AND pac_xprocid = vxproc
                     AND staj_esid = rstajesid.active
            ORDER BY period_durseq DESC, -- $$$$ check ordering
                     pac_startday DESC,
                     pac_starthour DESC,
                     pac_startminute DESC;

        cjobrow                                 cjob%ROWTYPE;

        --SQL Definitions for individual jobs
        CURSOR cjobsql (vjob IN sta_job.staj_id%TYPE)
        IS
            SELECT     *
            FROM       sta_jobsql
            WHERE      stajq_jobid = vjob
            FOR UPDATE OF stajq_sql;

        cjobsqlrow                              cjobsql%ROWTYPE;

        CURSOR cpacit (vitid IN paciterator.paci_id%TYPE)
        IS
            SELECT paci_sql
            FROM   paciterator
            WHERE  paci_id = vitid;

        --Dynamic cursor: to bind run time
        TYPE titerator IS REF CURSOR;

        cviterator                              titerator;

        --Parameter for "repeat untils..."
        CURSOR cparam (vjid IN sta_job.staj_id%TYPE)
        IS
            SELECT *
            FROM   sta_jobparam
            WHERE  stajp_jobid = vjid;

        cparamrow                               cparam%ROWTYPE;

        CURSOR cstajobparam (
            a_stajid                                IN sta_job.staj_id%TYPE,
            a_stajpname                             IN sta_jobparam.stajp_name%TYPE)
        IS
            SELECT stajp_value
            FROM   sta_jobparam
            WHERE      stajp_jobid = a_stajid
                   AND stajp_name = a_stajpname;

        --Conditional EXEC dynamic cursor
        TYPE tcurdef IS REF CURSOR;

        cvcurvar                                tcurdef;

        --user defined exceptions
        nopaciterator                           EXCEPTION;
        nodatefrom                              EXCEPTION;
        nodateto                                EXCEPTION;
        nodatetoanduntil                        EXCEPTION;
        nosqldef                                EXCEPTION;
    BEGIN
        --SysInfo
        vsysinfo := 'Scheduled on ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS');

        --Initialize ReturnValues
        returnstatus := 1;
        recordsaffected := 0;

        --Read configuration
        rconfig := getconfig;

        IF rconfig.stac_id IS NULL
        THEN
            RAISE no_config_error;
        END IF;

        --First schedule the SYSTEM STATS and CONSOL (table packing)----------------
        --Loop throu all active, not yet scheduled packings
        FOR cpackingrow IN cpacking (vxprocname)
        LOOP
            vpacid := cpackingrow.pac_id;
            nsqldef := 0;
            blooped := FALSE;

            --Conditional Execution: If pac_conditionalexec is not empty,
            -- execute SQL statement: If DATA FOUND = schedule; else Exit
            bgo := TRUE;

            IF cpackingrow.pac_conditionalexec IS NOT NULL
            THEN
                OPEN cvcurvar FOR cpackingrow.pac_conditionalexec;

                FETCH cvcurvar INTO vgo;

                bgo := cvcurvar%FOUND;

                CLOSE cvcurvar;
            END IF;

            IF bgo
            THEN
                --get next possible exec-date depending on periodicity,systime and pac_dateDone
                dnextexecdate := getnextexecdate (rcaller.SYSTEM, cpackingrow.pac_id, SYSDATE);

                --Check its time for scheduling...
                IF SYSDATE >= (dnextexecdate - ((1 / 24) * NVL (rconfig.stac_schedinadv, 1)))
                THEN
                    --If procedure is called from anythingToDo just answer with YES, but dont do anything
                    IF p_pact_id = 'ANYTHING'
                    THEN
                        ncount := 1;
                        EXIT;
                    END IF;

                    --Do what we have to do for each job, no regarding what kind of stats he represents...
                    --make sure, that we dont schedule the jobs again if somebody changes the packing.pac_esid=active although it was scheduled!
                    --staj_dateexe=dNextExecDate);

                    DELETE FROM sta_jobparam
                    WHERE       stajp_jobid IN (SELECT staj_id
                                                FROM   sta_job
                                                WHERE      staj_pacid = cpackingrow.pac_id
                                                       AND staj_esid = rstajesid.scheduled);

                    nsql := SQL%ROWCOUNT;

                    DELETE FROM sta_joboutput
                    WHERE       stajo_jobid IN (SELECT staj_id
                                                FROM   sta_job
                                                WHERE      staj_pacid = cpackingrow.pac_id
                                                       AND staj_esid = rstajesid.scheduled);

                    nsql := SQL%ROWCOUNT;

                    DELETE FROM sta_jobsql
                    WHERE       stajq_jobid IN (SELECT staj_id
                                                FROM   sta_job
                                                WHERE      staj_pacid = cpackingrow.pac_id
                                                       AND staj_esid = rstajesid.scheduled);

                    nsql := SQL%ROWCOUNT;

                    DELETE FROM sta_job
                    WHERE           staj_pacid = cpackingrow.pac_id
                                AND staj_esid = rstajesid.scheduled;

                    nsql := SQL%ROWCOUNT;

                    COMMIT; -- $$$$ check necessity

                    --STAT Type II: Fetch iterator condition (select statement from paciterator if looping type not NONE
                    viterator := 'select ''TwoFlowers'' objectID from dual';

                    IF     cpackingrow.pac_ltid IS NOT NULL
                       AND cpackingrow.pac_ltid <> 'NONE'
                    THEN
                        vpacltid := cpackingrow.pac_ltid;
                        vpacitid := cpackingrow.pac_itid;

                        OPEN cpacit (vpacitid);

                        FETCH cpacit INTO viterator;

                        CLOSE cpacit;

                        IF viterator IS NULL
                        THEN
                            --Set Status of packing to inactive because of major error
                            updatejobonerror (cpackingrow.pac_id, NULL, p_boh_id, cpackingrow.pac_id || ': noPacIterator');
                            RAISE nopaciterator;
                        END IF;

                        blooped := FALSE;
                    END IF;

                    --Collect the dates, valid for all jobs
                    --Define the parameters: here only <DATEFROM> <DATETO>
                    IF cpackingrow.pac_periodid = 'YEARLY'
                    THEN
                        ddatefrom := ADD_MONTHS (TRUNC (dnextexecdate, 'YEAR'), -12);
                        ddateto := TRUNC (dnextexecdate, 'YEAR');
                    END IF;

                    IF cpackingrow.pac_periodid = 'MONTHLY'
                    THEN
                        ddatefrom := ADD_MONTHS (TRUNC (dnextexecdate, 'MONTH'), -1);
                        ddateto := TRUNC (dnextexecdate, 'MONTH');
                    END IF;

                    IF cpackingrow.pac_periodid = 'WEEKLY'
                    THEN
                        ddatefrom := TRUNC (dnextexecdate) - 7;
                        ddateto := TRUNC (dnextexecdate);
                    END IF;

                    IF cpackingrow.pac_periodid = 'DAILY'
                    THEN
                        ddatefrom := TRUNC (dnextexecdate) - 1;
                        ddateto := TRUNC (dnextexecdate);
                    END IF;

                    IF cpackingrow.pac_periodid = 'HOURLY'
                    THEN
                        ddatefrom := dnextexecdate - 1 / 24;
                        ddateto := dnextexecdate;
                    END IF;

                    --Calculate execution date
                    --Note: No execution delay for STATS and CONSOL
                    IF SYSDATE > dnextexecdate
                    THEN
                        ddateexec := SYSDATE; --Execute immediately
                    ELSE
                        ddateexec := dnextexecdate;
                    END IF;

                    IF cpackingrow.pac_etid <> rpacetid.consol
                    THEN
                        vpacltid := '<' || cpackingrow.pac_ltid || '>';
                        vltid := cpackingrow.pac_ltid;
                        --Replace the parameters within the Iterator Select Statement
                        viterator := REPLACE (viterator, '''' || rsqlparam.datefrom || '''', 'to_date(''' || TO_CHAR (ddatefrom, 'DD.MM.YYYY HH24:MI:SS') || ''',''DD.MM.YYYY HH24:MI:SS'')');
                        viterator := REPLACE (viterator, '''' || rsqlparam.dateto || '''', 'to_date(''' || TO_CHAR (ddateto, 'DD.MM.YYYY HH24:MI:SS') || ''',''DD.MM.YYYY HH24:MI:SS'')');
                    END IF;

                    ----Loop for each iterator row!!
                    OPEN cviterator FOR viterator;

                   <<loop_cviterator>>
                    LOOP
                        --loop value, e.g. con_id, ac_id or something equal
                        FETCH cviterator INTO viteratorvalue;

                        EXIT WHEN cviterator%NOTFOUND;

                        vjobid := pkg_common.generateuniquekey ('G');
                        blooped := TRUE;

                        --insert the request into job-table
                        INSERT INTO sta_job (
                                        staj_id,
                                        staj_pacid,
                                        staj_parentid,
                                        staj_esid,
                                        staj_etid,
                                        staj_dateexe,
                                        staj_datesta,
                                        staj_datecre,
                                        staj_bohidsched,
                                        staj_nooftrials,
                                        staj_ltvalue,
                                        staj_sysinfo,
                                        staj_periodid,
                                        staj_directoryid)
                        VALUES      (
                                        vjobid,
                                        cpackingrow.pac_id,
                                        0,
                                        rstajesid.scheduled,
                                        'XLS',
                                        ddateexec,
                                        SYSDATE,
                                        SYSDATE,
                                        p_boh_id,
                                        0,
                                        DECODE (viteratorvalue, 'TwoFlowers', '', viteratorvalue),
                                        vsysinfo,
                                        cpackingrow.pac_periodid,
                                        cpackingrow.pac_directoryid);

                        --insert dates [DATEFROM] and [DATETO]
                        INSERT INTO sta_jobparam (
                                        stajp_id,
                                        stajp_jobid,
                                        stajp_name,
                                        stajp_value)
                        VALUES      (
                                        pkg_common.generateuniquekey ('G'),
                                        vjobid,
                                        rjobparam.datefrom,
                                        TO_CHAR (ddatefrom, 'DD.MM.YYYY HH24:MI:SS'));

                        INSERT INTO sta_jobparam (
                                        stajp_id,
                                        stajp_jobid,
                                        stajp_name,
                                        stajp_value)
                        VALUES      (
                                        pkg_common.generateuniquekey ('G'),
                                        vjobid,
                                        rjobparam.dateto,
                                        TO_CHAR (ddateto, 'DD.MM.YYYY HH24:MI:SS'));

                        --Fake the param [DATETILL]
                        INSERT INTO sta_jobparam (
                                        stajp_id,
                                        stajp_jobid,
                                        stajp_name,
                                        stajp_value)
                        VALUES      (
                                        pkg_common.generateuniquekey ('G'),
                                        vjobid,
                                        rjobparam.datetill,
                                        TO_CHAR (ddatetill, 'DD.MM.YYYY HH24:MI:SS'));

                       --Insert individual absolute job paramaters
                       <<loop_cpacparam>>
                        FOR cpacparamrow IN cpacparam (cpackingrow.pac_id)
                        LOOP
                            INSERT INTO sta_jobparam (
                                            stajp_id,
                                            stajp_jobid,
                                            stajp_name,
                                            stajp_value)
                            VALUES      (
                                            pkg_common.generateuniquekey ('G'),
                                            vjobid,
                                            cpacparamrow.stap_name,
                                            cpacparamrow.stap_value);
                        END LOOP loop_cpacparam;

                        IF cpackingrow.pac_etid <> rpacetid.consol
                        THEN
                           --Replace the parameters within the SQL statements
                           <<loop_csqldef>>
                            FOR csqlrow IN csqldef (vpacid)
                            LOOP
                                nsqldef := 1;

                                vsql := REPLACE (csqlrow.staq_sql, '''' || vpacltid || '''', '''' || viteratorvalue || '''');
                                vsql := REPLACE (vsql, '''' || rsqlparam.jobid || '''', '''' || vjobid || '''');

                                --Check and replace absolute values in PacParam
                                -- 1.Replace DATEFROM job parameter
                                OPEN cstajobparam (vjobid, rjobparam.datefrom);

                                FETCH cstajobparam INTO vstajpvalue;

                                IF cstajobparam%FOUND
                                THEN
                                    vsql := REPLACE (vsql, '''' || rsqlparam.datefrom || '''', 'to_date(''' || vstajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
                                ELSE
                                    --Set Status of packing to inactive because of major error
                                    updatejobonerror (cpackingrow.pac_id, NULL, p_boh_id, cpackingrow.pac_id || ': noDateFrom');

                                    CLOSE cstajobparam;

                                    RAISE nodatefrom;
                                END IF;

                                CLOSE cstajobparam;

                                -- 2.Replace DATETO job parameter
                                OPEN cstajobparam (vjobid, rjobparam.dateto);

                                FETCH cstajobparam INTO vstajpvalue;

                                IF cstajobparam%FOUND
                                THEN
                                    vsql := REPLACE (vsql, '''' || rsqlparam.dateto || '''', 'to_date(''' || vstajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
                                ELSE
                                    --Set Status of packing to inactive because of major error
                                    updatejobonerror (cpackingrow.pac_id, NULL, p_boh_id, cpackingrow.pac_id || ': noDateTo');

                                    CLOSE cstajobparam;

                                    RAISE nodateto;
                                END IF;

                                CLOSE cstajobparam;

                                -- 3.Replace DATETILL job parameter
                                OPEN cstajobparam (vjobid, rjobparam.datetill);

                                FETCH cstajobparam INTO vstajpvalue;

                                IF cstajobparam%FOUND
                                THEN
                                    vsql := REPLACE (vsql, '''' || rsqlparam.datetill || '''', 'to_date(''' || vstajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
                                ELSE
                                    --Set Status of packing to inactive because of major error
                                    updatejobonerror (cpackingrow.pac_id, NULL, p_boh_id, cpackingrow.pac_id || ': noDateToAndUntil');

                                    CLOSE cstajobparam;

                                    RAISE nodatetoanduntil;
                                END IF;

                                CLOSE cstajobparam;

                                -- 4.Replace KEYWORDS job parameter
                                OPEN cstajobparam (vjobid, rjobparam.keywords);

                                FETCH cstajobparam INTO vstajpvalue;

                                IF cstajobparam%FOUND
                                THEN
                                    IF LENGTH (vstajpvalue) > 0
                                    THEN
                                        vsql := REPLACE (vsql, rsqlparam.keywords, ' AND BD_KEYWORD IN (' || vstajpvalue || ')');
                                    ELSE
                                        vsql := REPLACE (vsql, rsqlparam.keywords, '');
                                    END IF;
                                ELSE
                                    vsql := REPLACE (vsql, rsqlparam.keywords, '');
                                END IF;

                                CLOSE cstajobparam;

                               -- 5.Replace other individual pacparams which are not mandatory like e.g. pmnid of sr022a

                               <<loop_cpacparam>>
                                FOR cpacparamrow IN cpacparam (cpackingrow.pac_id)
                                LOOP
                                    vtempstring := NULL;
                                    vtempstring := '<' || vtempstring || SUBSTR (cpacparamrow.stap_name, 2, (LENGTH (cpacparamrow.stap_name) - 2)) || '>';
                                    --vSql := Replace(upper(vSql), upper(vTempString), cPacParamRow.stap_value);
                                    vsql := REPLACE (vsql, vtempstring, cpacparamrow.stap_value);
                                END LOOP loop_cpacparam;

                                INSERT INTO sta_jobsql (
                                                stajq_jobid,
                                                stajq_queryname,
                                                stajq_sql)
                                VALUES      (
                                                vjobid,
                                                csqlrow.staq_queryname,
                                                vsql);
                            END LOOP loop_csqldef;

                            --check if we found a SQL Definition; if nSqlDef=0 -> we didnt; raise error!
                            IF nsqldef = 0
                            THEN
                                --Set Status of packing to inactive because of major error
                                updatejobonerror (cpackingrow.pac_id, NULL, p_boh_id, cpackingrow.pac_id || ': noSqlDef');
                                RAISE nosqldef;
                            END IF;
                        END IF;

                        ncount := ncount + 1;
                    END LOOP loop_cviterator; ---end loop for each iterator row!!!

                    CLOSE cviterator;

                    IF blooped
                    THEN
                        UPDATE packing
                        SET    pac_esid = rpacesid.scheduled,
                               pac_datesta = SYSDATE
                        WHERE  pac_id = cpackingrow.pac_id;
                    ELSE
                        UPDATE packing
                        SET    pac_esid = rpacesid.active,
                               pac_datesta = SYSDATE,
                               pac_datedone = SYSDATE
                        WHERE  pac_id = cpackingrow.pac_id;
                    END IF;
                END IF; --end if packing.dateDone is null
            END IF; --bGo
        END LOOP;

        --Second schedule the USER STATS (table sta_job)----------------------------
        --INDIVIDUAL STATS Type III

        dnextexecdate := NULL;

       <<loop_cjob>>
        FOR cjobrow IN cjob (vxprocname)
        LOOP
            --initialize variables
            nsqldef := 0;
            dfrom := NULL;
            dto := NULL;
            dtill := NULL;
            vtill := NULL;
            vperiod := NULL;
            brepeat := FALSE;

            --read cursor variables
            vjobid := cjobrow.staj_id;
            vpacltid := '<' || cjobrow.pac_ltid || '>';
            vltid := cjobrow.pac_ltid;
            vpacid := cjobrow.pac_id;

            --read parameter "Date FROM"
            BEGIN
                SELECT TO_DATE (stajp_value, 'DD.MM.YYYY HH24:MI:SS')
                INTO   dfrom
                FROM   sta_jobparam
                WHERE      stajp_jobid = vjobid
                       AND stajp_name = rjobparam.datefrom;
            EXCEPTION
                WHEN OTHERS
                THEN
                    RAISE nodatefrom;
            END;

            --try to fetch parameter "Date To"
            BEGIN
                SELECT TO_DATE (stajp_value, 'DD.MM.YYYY HH24:MI:SS')
                INTO   dto
                FROM   sta_jobparam
                WHERE      stajp_jobid = vjobid
                       AND stajp_name = rjobparam.dateto;
            EXCEPTION
                WHEN OTHERS
                THEN
                    dto := dfrom;
            END;

            --read parameter "Repeat until"
            BEGIN
                SELECT stajp_value
                INTO   vtill
                FROM   sta_jobparam
                WHERE      stajp_jobid = vjobid
                       AND stajp_name = rjobparam.datetill;

                IF SUBSTR (vtill, 1, 10) = '01.01.2100'
                THEN
                    dtill := NULL;
                ELSE
                    dtill := TO_DATE (vtill, 'DD.MM.YYYY HH24:MI:SS');

                    --check if we still have to repeat this monkey
                    IF    dtill >= dto
                       OR dto IS NULL
                    THEN
                        brepeat := TRUE;

                        --calulate new Date To
                        IF cjobrow.staj_periodid = 'YEARLY'
                        THEN
                            dto := ADD_MONTHS (dfrom, 12);
                            dtoto := ADD_MONTHS (dto, 12);
                        END IF;

                        IF cjobrow.staj_periodid = 'MONTHLY'
                        THEN
                            dto := ADD_MONTHS (dfrom, 1);
                            dtoto := ADD_MONTHS (dto, 1);
                        END IF;

                        IF cjobrow.staj_periodid = 'WEEKLY'
                        THEN
                            dto := dfrom + 7;
                            dtoto := dto + 7;
                        END IF;

                        IF cjobrow.staj_periodid = 'DAILY'
                        THEN
                            dto := dfrom + 1;
                            dtoto := dto + 1;
                        END IF;

                        IF cjobrow.staj_periodid = 'HOURLY'
                        THEN
                            dto := dfrom + ((1 / 24) * 1); -- TODO looks very odd (wwe)
                            dtoto := dto + ((1 / 24) * 1); -- TODO looks very odd (wwe)
                        END IF;
                    END IF;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    vtill := NULL;
                    dtill := NULL;
            END;

            --if Date To is null AND repeat until is null -> we cant calculate period, therefore raise error
            IF     dto IS NULL
               AND dtill IS NULL
            THEN
                --Set Status of job to draft because of major error
                updatejobonerror (NULL, cjobrow.staj_id, p_boh_id, cjobrow.staj_id || ': noDateToAndUntil');
                RAISE nodatetoanduntil;
            END IF;

            IF dto IS NOT NULL
            THEN
                --dNextExecDate := getNextExecDate(rCaller.indiv, cJobRow.pac_id, trunc(dTo));
                --Individuals doesnt take care about any definition, no start-day, nothing
                --therefore, the next possible execution day is an hour later...

                dnextexecdate := SYSDATE;

                IF dto >= dnextexecdate
                THEN
                    dnextexecdate := dto + 1 / 24;
                END IF;

                IF SYSDATE >= (dnextexecdate - ((1 / 24) * NVL (rconfig.stac_schedinadv, 1)))
                THEN
                    --If procedure is called from anythingToDo (XPIOC) just answer with YES, but dont do anything
                    IF p_pact_id = 'ANYTHING'
                    THEN
                        ncount := 1;
                        EXIT;
                    END IF;

                    --If statistic template has an individual execution delay (pac_exec_delay) then take this
                    --otherwise the standard from config
                    ddateexec := TRUNC (dnextexecdate + NVL (cjobrow.pac_execdelay, rconfig.stac_execdelay)); -- 003SO

                    IF     NOT brepeat
                       AND dtill IS NULL
                    THEN
                        --its not a repeat monkey, so just update the original job row
                        UPDATE sta_job
                        SET    staj_esid = rstajesid.scheduled,
                               staj_datesta = SYSDATE,
                               staj_chngcnt = staj_chngcnt + 1,
                               staj_dateexe = ddateexec,
                               staj_bohidsched = p_boh_id,
                               staj_nooftrials = 0,
                               staj_sysinfo = SUBSTR (vsysinfo || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
                        WHERE  staj_id = cjobrow.staj_id;

                       --update the job-sqls: replace the remaining parameters (ltid-value and stajid)
                       <<loop_cjobsql>>
                        FOR cjobsqlrow IN cjobsql (vjobid)
                        LOOP
                            vsql := cjobsqlrow.stajq_sql;

                            IF cjobrow.staj_ltvalue IS NULL
                            THEN
                                vsql := REPLACE (vsql, vpacltid, NULL);
                            ELSE
                                vsql := REPLACE (vsql, vpacltid, ' AND ' || vltid || ' = ''' || cjobrow.staj_ltvalue || '''');
                            END IF;

                            vsql := REPLACE (vsql, '''' || rsqlparam.jobid || '''', '''' || vjobid || '''');

                            --update sta_jobsql table with new sql-definition for this job
                            UPDATE sta_jobsql
                            SET    stajq_sql = vsql
                            WHERE  CURRENT OF cjobsql;
                        END LOOP loop_cjobsql;

                        ncount := ncount + 1;
                    ELSE
                        --REPEAT MONKEY
                        --now we have to copy the job-row itself, and update the original job-row
                        --first create a new instance, a child of original job
                        vnewjobid := pkg_common.generateuniquekey ('G');

                        --the CHILD is born...his status set to SCHEDULED
                        INSERT INTO sta_job (
                                        staj_id,
                                        staj_pacid,
                                        staj_parentid,
                                        staj_esid,
                                        staj_etid,
                                        staj_dateexe,
                                        staj_datesta,
                                        staj_datecre,
                                        staj_chngcnt,
                                        staj_bohidsched,
                                        staj_nooftrials,
                                        staj_sysinfo,
                                        staj_ltvalue,
                                        staj_periodid)
                        VALUES      (
                                        vnewjobid,
                                        cjobrow.pac_id,
                                        vjobid,
                                        rstajesid.scheduled,
                                        'XLS',
                                        ddateexec,
                                        SYSDATE,
                                        SYSDATE,
                                        0,
                                        p_boh_id,
                                        0,
                                        'Child of ' || vjobid || 'created on ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS'),
                                        cjobrow.staj_ltvalue,
                                        cjobrow.staj_periodid);

                       --now copy all parameters
                       <<loop_cparam>>
                        FOR cparamrow IN cparam (vjobid)
                        LOOP
                            --Workaround for nice decode function which is here not running
                            --another reason for updating to version 9i:-))
                            IF cparamrow.stajp_name = rjobparam.datefrom
                            THEN
                                INSERT INTO sta_jobparam (
                                                stajp_id,
                                                stajp_jobid,
                                                stajp_name,
                                                stajp_value)
                                VALUES      (
                                                pkg_common.generateuniquekey ('G'),
                                                vnewjobid,
                                                cparamrow.stajp_name,
                                                TO_CHAR (dfrom, 'DD.MM.YYYY HH24:MI:SS'));
                            ELSE
                                IF cparamrow.stajp_name = rjobparam.dateto
                                THEN
                                    INSERT INTO sta_jobparam (
                                                    stajp_id,
                                                    stajp_jobid,
                                                    stajp_name,
                                                    stajp_value)
                                    VALUES      (
                                                    pkg_common.generateuniquekey ('G'),
                                                    vnewjobid,
                                                    cparamrow.stajp_name,
                                                    TO_CHAR (dto, 'DD.MM.YYYY HH24:MI:SS'));
                                ELSE
                                    IF cparamrow.stajp_name = rjobparam.datetill
                                    THEN
                                        INSERT INTO sta_jobparam (
                                                        stajp_id,
                                                        stajp_jobid,
                                                        stajp_name,
                                                        stajp_value)
                                        VALUES      (
                                                        pkg_common.generateuniquekey ('G'),
                                                        vnewjobid,
                                                        cparamrow.stajp_name,
                                                        TO_CHAR (dtill, 'DD.MM.YYYY HH24:MI:SS'));
                                    ELSE
                                        INSERT INTO sta_jobparam (
                                                        stajp_id,
                                                        stajp_jobid,
                                                        stajp_name,
                                                        stajp_value)
                                        VALUES      (
                                                        pkg_common.generateuniquekey ('G'),
                                                        vnewjobid,
                                                        cparamrow.stajp_name,
                                                        cparamrow.stajp_value);
                                    END IF;
                                END IF;
                            END IF;
                        END LOOP loop_cparam;

                       --now create all SQL statements
                       <<loop_csqldef>>
                        FOR csqlrow IN csqldef (vpacid)
                        LOOP
                            nsqldef := 1;
                            vsql := csqlrow.staq_sql;
                            vqname := csqlrow.staq_queryname;

                            --replace the standard parameters staj_id and lt-value
                            IF cjobrow.staj_ltvalue IS NULL
                            THEN
                                vsql := REPLACE (vsql, vpacltid, NULL);
                            ELSE
                                vsql := REPLACE (vsql, vpacltid, ' AND ' || vltid || ' = ''' || cjobrow.staj_ltvalue || '''');
                            END IF;

                            vsql := REPLACE (vsql, '''' || rsqlparam.jobid || '''', '''' || vnewjobid || '''');

                            -- 1.Replace DATEFROM job parameter
                            OPEN cstajobparam (vjobid, rjobparam.datefrom);

                            FETCH cstajobparam INTO vstajpvalue;

                            IF cstajobparam%FOUND
                            THEN
                                vsql := REPLACE (vsql, '''' || rsqlparam.datefrom || '''', 'to_date(''' || vstajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
                            ELSE
                                --Set Status of job to draft because of major error
                                updatejobonerror (NULL, cjobrow.staj_id, p_boh_id, cjobrow.staj_id || ': noDateFrom');

                                CLOSE cstajobparam;

                                RAISE nodatefrom;
                            END IF;

                            CLOSE cstajobparam;

                            -- 2.Replace DATETO job parameter
                            OPEN cstajobparam (vjobid, rjobparam.dateto);

                            FETCH cstajobparam INTO vstajpvalue;

                            IF cstajobparam%FOUND
                            THEN
                                vsql := REPLACE (vsql, '''' || rsqlparam.dateto || '''', 'to_date(''' || vstajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
                            ELSE
                                --Set Status of job to draft because of major error
                                updatejobonerror (NULL, cjobrow.staj_id, p_boh_id, cjobrow.staj_id || ': noDateTo');

                                CLOSE cstajobparam;

                                RAISE nodateto;
                            END IF;

                            CLOSE cstajobparam;

                            -- 3.Replace DATETILL job parameter
                            OPEN cstajobparam (vjobid, rjobparam.dateto);

                            FETCH cstajobparam INTO vstajpvalue;

                            IF cstajobparam%FOUND
                            THEN
                                vsql := REPLACE (vsql, '''' || rsqlparam.datetill || '''', 'to_date(''' || vstajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
                            ELSE
                                --Set Status of job to draft because of major error
                                updatejobonerror (NULL, cjobrow.staj_id, p_boh_id, cjobrow.staj_id || ': noDateToAndUntil');

                                CLOSE cstajobparam;

                                RAISE nodatetoanduntil;
                            END IF;

                            CLOSE cstajobparam;

                            -- 4.Replace KEYWORDS job parameter
                            OPEN cstajobparam (vjobid, rjobparam.keywords);

                            FETCH cstajobparam INTO vstajpvalue;

                            IF cstajobparam%FOUND
                            THEN
                                IF LENGTH (vstajpvalue) > 0
                                THEN
                                    vsql := REPLACE (vsql, rsqlparam.keywords, ' AND BD_KEYWORD IN (' || vstajpvalue || ')');
                                ELSE
                                    vsql := REPLACE (vsql, rsqlparam.keywords, '');
                                END IF;
                            ELSE
                                vsql := REPLACE (vsql, rsqlparam.keywords, '');
                            END IF;

                            CLOSE cstajobparam;

                            -- 5.Replace MSISDN A job parameter
                            OPEN cstajobparam (vjobid, rjobparam.msisdna);

                            FETCH cstajobparam INTO vstajpvalue;

                            IF cstajobparam%FOUND
                            THEN
                                IF LENGTH (vstajpvalue) > 0
                                THEN
                                    vstajpvalue := REPLACE (vstajpvalue, '*', '%');
                                    vstajpvalue := REPLACE (vstajpvalue, '?', '_');

                                    IF    (INSTR (vstajpvalue, '%') > 0)
                                       OR (INSTR (vstajpvalue, '_') > 0)
                                    THEN
                                        vsql := REPLACE (vsql, rsqlparam.msisdna, ' AND SENDER LIKE ''' || vstajpvalue || '''');
                                    ELSE
                                        vsql := REPLACE (vsql, rsqlparam.msisdna, ' AND SENDER IN (''' || vstajpvalue || ''')');
                                    END IF;
                                ELSE
                                    vsql := REPLACE (vsql, rsqlparam.msisdna, '');
                                END IF;
                            ELSE
                                vsql := REPLACE (vsql, rsqlparam.msisdna, '');
                            END IF;

                            CLOSE cstajobparam;

                            -- 6.Replace MSISDN B job parameter
                            OPEN cstajobparam (vjobid, rjobparam.msisdnb);

                            FETCH cstajobparam INTO vstajpvalue;

                            IF cstajobparam%FOUND
                            THEN
                                IF LENGTH (vstajpvalue) > 0
                                THEN
                                    vstajpvalue := REPLACE (vstajpvalue, '*', '%');
                                    vstajpvalue := REPLACE (vstajpvalue, '?', '_');

                                    IF    INSTR (vstajpvalue, '%') > 0
                                       OR INSTR (vstajpvalue, '_') > 0
                                    THEN
                                        vsql := REPLACE (vsql, rsqlparam.msisdnb, ' AND RECEIVER LIKE ''' || vstajpvalue || '''');
                                    ELSE
                                        vsql := REPLACE (vsql, rsqlparam.msisdnb, ' AND RECEIVER IN (''' || vstajpvalue || ''')');
                                    END IF;
                                ELSE
                                    vsql := REPLACE (vsql, rsqlparam.msisdnb, '');
                                END IF;
                            ELSE
                                vsql := REPLACE (vsql, rsqlparam.msisdnb, '');
                            END IF;

                            CLOSE cstajobparam;

                            --finally insert the new sql-statement for this child-process into table
                            INSERT INTO sta_jobsql (
                                            stajq_jobid,
                                            stajq_queryname,
                                            stajq_sql)
                            VALUES      (
                                            vnewjobid,
                                            vqname,
                                            vsql);
                        END LOOP loop_csqldef;

                        --check if we found a SQL DEFINITION, if not raise error
                        IF nsqldef = 0
                        THEN
                            --Set Status of job to draft because of major error
                            updatejobonerror (NULL, cjobrow.staj_id, p_boh_id, cjobrow.staj_id || ': noSqlDef');
                            RAISE nosqldef;
                        END IF;

                        --finally update the parent, the original job row (preparation for next repeat until)
                        --check if this job is the parent row and if we are done
                        IF dtill <= dtoto
                        THEN
                            --we are done: delete the original job because we dont need it anymore
                            UPDATE sta_job
                            SET    staj_esid = rstajesid.deleted,
                                   staj_datesta = SYSDATE,
                                   staj_chngcnt = staj_chngcnt + 1,
                                   staj_bohidsched = p_boh_id,
                                   staj_sysinfo =
                                       SUBSTR (
                                              'Parent Row: All children born. Deleted by system on '
                                           || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi:ss')
                                           || CHR (10)
                                           || 'Parent of child '
                                           || vnewjobid
                                           || ' scheduled on '
                                           || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi:ss')
                                           || CHR (10)
                                           || SUBSTR (staj_sysinfo, 1, 3000),
                                           1,
                                           3999)
                            WHERE  staj_id = cjobrow.staj_id;
                        ELSE
                            UPDATE sta_job
                            SET    staj_esid = rstajesid.active,
                                   staj_datesta = SYSDATE,
                                   staj_chngcnt = staj_chngcnt + 1,
                                   staj_dateexe = ddateexec,
                                   staj_bohidsched = p_boh_id,
                                   staj_nooftrials = 0,
                                   staj_sysinfo =
                                       SUBSTR (
                                           'Parent of child ' || vnewjobid || ' scheduled on ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi:ss') || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000),
                                           1,
                                           3999)
                            WHERE  staj_id = cjobrow.staj_id;

                            UPDATE sta_jobparam
                            SET    stajp_value = TO_CHAR (dto, 'DD.MM.YYYY hh24:mi:ss')
                            WHERE      stajp_name = rjobparam.datefrom
                                   AND stajp_jobid = cjobrow.staj_id;

                            UPDATE sta_jobparam
                            SET    stajp_value = TO_CHAR (dtoto, 'DD.MM.YYYY hh24:mi:ss')
                            WHERE      stajp_name = rjobparam.dateto
                                   AND stajp_jobid = cjobrow.staj_id;
                        END IF;
                    END IF;
                END IF;
            ELSE
                --should never happen, because the Web Interface is verifiying the correct entries of dates
                UPDATE sta_job
                SET    staj_esid = rstajesid.draft,
                       staj_datesta = SYSDATE,
                       staj_chngcnt = staj_chngcnt + 1,
                       staj_bohidsched = p_boh_id,
                       staj_nooftrials = 0,
                       staj_sysinfo = SUBSTR ('Sorry, cannot schedule the job because of missing parameter <DATETO>.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
                WHERE  staj_id = cjobrow.staj_id;
            END IF;
        END LOOP loop_cjob;

        recordsaffected := ncount;

        COMMIT; -- $$$$ check necessity
    EXCEPTION
        WHEN no_config_error
        THEN
            pkg_common.insert_warning ('PKG_STATS', 'scheduleStats', 'Error ', 'No configuration (DEFAULT) found. Check STA_CONFIG.'); -- 023SO
            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity
        WHEN nopaciterator
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'scheduleStats',
                    SQLCODE,
                    SQLERRM || '(no PacIterator SQL for looping type: ' || vpacltid,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'scheduleStats',
                    'Error ' || p_boh_id,
                    'There is no iterator condition for this packing type. Please check table PACITERATOR',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;

            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity
        WHEN nodatefrom
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'scheduleStats',
                    SQLCODE,
                    SQLERRM || '(no parameter Date From for user defined Job ' || vjobid,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'scheduleStats',
                    'Error ' || p_boh_id,
                    'No parameter Date From for user defined Job ' || vjobid || ' found. Please check table STA_JOB',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;

            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity
        WHEN nodateto
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'scheduleStats',
                    SQLCODE,
                    SQLERRM || '(no parameter Date From for user defined Job ' || vjobid,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'scheduleStats',
                    'Error ' || p_boh_id,
                    'No parameter Date From for user defined Job ' || vjobid || ' found. Please check table STA_JOB',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;

            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity
        WHEN nodatetoanduntil
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'scheduleStats',
                    SQLCODE,
                    SQLERRM || '(Missing Date To and Date Until for user defined Job ' || vjobid,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'scheduleStats',
                    'Error ' || p_boh_id,
                    'Missing Date To and Date Until for user defined Job ' || vjobid || ' found. Please check table STA_JOB',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;

            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity
        WHEN nosqldef
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'scheduleStats',
                    SQLCODE,
                    SQLERRM || '(no SQL Definition found for ' || vpacltid,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'scheduleStats',
                    'Error ' || p_boh_id,
                    'There is no SQL Definition for this packing type. Please check table STA_SQLDEF',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;

            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
            recordsaffected := 0;

            ROLLBACK; -- $$$$ check necessity

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'scheduleStats',
                    SQLCODE,
                    SQLERRM,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'scheduleStats',
                    'Error ' || p_boh_id,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    p_boh_id); -- 023SO
            END IF;
    END schedulestats;

    /* =========================================================================
       Create a new Stats Job record and return the Job Id in the output
       parameter.
       Overloaded procedure version of SP_NEW_STA_JOB procedure with extra
       Job Notification parameters.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_new_sta_job (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajinfo                              IN     sta_job.staj_info%TYPE,
        p_stajltvalue                           IN     sta_job.staj_ltvalue%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_acidcre                               IN     account.ac_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE,
        p_stajnotification                      IN     sta_job.staj_notification%TYPE, -- 010AA
        p_stajnotid                             IN     sta_job.staj_notid%TYPE, -- 010AA
        p_stajnotemailsuccess                   IN     sta_job.staj_notemailsuccess%TYPE, -- 010AA
        p_stajnotemailfailure                   IN     sta_job.staj_notemailfailure%TYPE, -- 010AA
        p_stajnotsendattachment                 IN     sta_job.staj_notsendatt%TYPE, -- 010AA
        p_recordsaffected                          OUT NUMBER,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER)
    IS
        l_stajid                                VARCHAR2 (10);
    BEGIN
        -- Get a new Job Id
        SELECT pkg_common.generateuniquekey ('G') INTO l_stajid FROM DUAL;

        INSERT INTO sta_job (
                        staj_id,
                        staj_pacid,
                        staj_parentid,
                        staj_esid,
                        staj_etid,
                        staj_info,
                        staj_notification, -- 010AA
                        staj_notid, -- 010AA
                        staj_notemailsuccess, -- 010AA
                        staj_notemailfailure, -- 010AA
                        staj_notsendatt, -- 010AA
                        staj_dateexe,
                        staj_datesta,
                        staj_datecre,
                        staj_acidcre,
                        staj_datemod,
                        staj_acidmod,
                        staj_chngcnt,
                        staj_bohidsched,
                        staj_bohidexec,
                        staj_ltvalue,
                        staj_periodid)
        VALUES      (
                        l_stajid,
                        p_stajpacid,
                        p_stajparentid,
                        rstajesid.draft,
                        rstajtype.xls,
                        p_stajinfo,
                        p_stajnotification, -- 010AA
                        p_stajnotid, -- 010AA
                        p_stajnotemailsuccess, -- 010AA
                        p_stajnotemailfailure, -- 010AA
                        p_stajnotsendattachment, -- 010AA
                        NULL,
                        SYSDATE,
                        SYSDATE,
                        p_acidcre,
                        NULL,
                        NULL,
                        0,
                        NULL,
                        NULL,
                        p_stajltvalue,
                        p_stajperiodid);

        p_stajid := l_stajid;
        p_recordsaffected := SQL%ROWCOUNT;
        p_returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_errnumber := SQLCODE;
            p_errdesc := SQLERRM;
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_job', 'Error', SQLCODE || ': ' || SQLERRM); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
    END sp_new_sta_job;

    /* =========================================================================
       Create a new Stats Job Parameter for the given StatJob Id.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_new_sta_jobparam (
        p_stajid                                IN     sta_job.staj_id%TYPE,
        p_stajpname                             IN     sta_jobparam.stajp_name%TYPE,
        p_stajpvalue                            IN     sta_jobparam.stajp_value%TYPE,
        p_recordsaffected                          OUT NUMBER,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER)
    IS
    BEGIN
        INSERT INTO sta_jobparam (
                        stajp_id,
                        stajp_jobid,
                        stajp_name,
                        stajp_value)
        VALUES      (
                        pkg_common.generateuniquekey ('G'),
                        p_stajid,
                        p_stajpname,
                        p_stajpvalue);

        p_recordsaffected := SQL%ROWCOUNT;
        p_returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_errnumber := SQLCODE;
            p_errdesc := SQLERRM;
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_jobparam', 'Error', SQLCODE || ': ' || SQLERRM); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
    END sp_new_sta_jobparam;

    /* =========================================================================
       Re-create new SQL Statments for the given Stats Job Id.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_new_sta_jobsqls (
        p_stajid                                IN     sta_job.staj_id%TYPE,
        p_recordsaffected                          OUT NUMBER,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER) -- TODO looks very odd (wwe)
    IS
        -- Get all the Sql Definitions for this Stat Job's Packing Id
        CURSOR c1_stasqldef (a_stajpacid IN VARCHAR2)
        IS
            SELECT staq_queryname,
                   staq_version,
                   staq_sql
            FROM   sta_sqldef
            WHERE  staq_pacid = a_stajpacid;

        -- Get all the Job Parameters name-value pairs for this Stat Job
        CURSOR c2_stajobparam (
            a_stajid                                IN VARCHAR2,
            a_stajpname                             IN VARCHAR2)
        IS
            SELECT stajp_value
            FROM   sta_jobparam
            WHERE      stajp_jobid = a_stajid
                   AND stajp_name = a_stajpname;

        CURSOR c3_getaccountdet (a_stajid IN VARCHAR2)
        IS
            SELECT NVL (ac_id, '<Error>'),
                   NVL (ac_name, '<Error>')
            FROM   account,
                   sta_job
            WHERE      1 = 1 -- TODO looks very odd (wwe)
                   AND ac_id = staj_ltvalue(+)
                   AND staj_id = a_stajid;

        CURSOR c4_getcontractdet (a_stajid IN VARCHAR2)
        IS
            SELECT NVL (con_id, '<Error>'),
                   NVL (con_name, '<Error>')
            FROM   contract,
                   sta_job
            WHERE      1 = 1 -- TODO looks very odd (wwe)
                   AND con_id = staj_ltvalue(+)
                   AND staj_id = a_stajid;

        -- Cursor to check if Period Id is given for the Job
        CURSOR c5_getstajperiodid (a_stajid IN VARCHAR2)
        IS
            SELECT staj_periodid
            FROM   sta_job
            WHERE  staj_id = a_stajid;

        l_staqqueryname                         sta_sqldef.staq_queryname%TYPE;
        l_staqsql                               sta_jobsql.stajq_sql%TYPE;
        l_stajpacid                             sta_job.staj_pacid%TYPE;
        l_pacltid                               packing.pac_ltid%TYPE;
        l_conid                                 contract.con_id%TYPE;
        l_conname                               contract.con_name%TYPE;
        l_acid                                  account.ac_id%TYPE;
        l_acname                                account.ac_name%TYPE;
        l_stajpvalue                            sta_jobparam.stajp_value%TYPE;
        l_stajperiodid                          sta_job.staj_periodid%TYPE;
        l_stajpvalue_datetill                   sta_jobparam.stajp_value%TYPE;
        boodatetooptional                       BOOLEAN := FALSE;

        param_notfound_datefrom                 EXCEPTION;
        param_notfound_dateto                   EXCEPTION;
        param_notfound_datetill                 EXCEPTION;
        no_datetill_with_period                 EXCEPTION;
        no_period_with_datetill                 EXCEPTION;
    BEGIN
        p_recordsaffected := 0;

        DELETE FROM sta_jobsql
        WHERE       stajq_jobid = p_stajid;

        -- Get query tokens values other than those in Job Parameters:
        -- for Packing Id, STAJ_PACID
        SELECT staj_pacid,
               NVL (pac_ltid, '-')     AS pac_ltid
        INTO   l_stajpacid,
               l_pacltid
        FROM   sta_job,
               packing
        WHERE      staj_pacid = pac_id
               AND staj_id = p_stajid;

        IF l_pacltid = 'CON_ID'
        THEN
            -- for CON_ID, CON_NAME
            OPEN c4_getcontractdet (p_stajid);

            FETCH c4_getcontractdet
                INTO l_conid,
                     l_conname;

            IF c4_getcontractdet%NOTFOUND
            THEN
                l_conid := NULL;
                l_conname := NULL;
            END IF;

            CLOSE c4_getcontractdet;
        ELSIF l_pacltid = 'AC_ID'
        THEN
            -- for AC_ID, AC_NAME
            OPEN c3_getaccountdet (p_stajid);

            FETCH c3_getaccountdet
                INTO l_acid,
                     l_acname;

            IF c3_getaccountdet%NOTFOUND
            THEN
                l_acid := NULL;
                l_acname := NULL;
            END IF;

            CLOSE c3_getaccountdet;
        ELSE
            l_conid := NULL;
            l_conname := NULL;
            l_acid := NULL;
            l_acname := NULL;
        END IF;

        OPEN c5_getstajperiodid (p_stajid);

        FETCH c5_getstajperiodid INTO l_stajperiodid;

        IF c5_getstajperiodid%NOTFOUND
        THEN
            l_stajperiodid := NULL;
        END IF;

        CLOSE c5_getstajperiodid;

        -- Loop all the Sql definitions for this Packing Id
        FOR c1row_stasqldef IN c1_stasqldef (l_stajpacid)
        LOOP
            l_staqqueryname := c1row_stasqldef.staq_queryname;
            l_staqsql := c1row_stasqldef.staq_sql;

            -- replace the DATEFROM parameter in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.datefrom);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                l_staqsql := REPLACE (l_staqsql, '''' || rsqlparam.datefrom || '''', 'to_date(''' || l_stajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
            ELSE
                CLOSE c2_stajobparam;

                RAISE param_notfound_datefrom;
            END IF;

            CLOSE c2_stajobparam;

            -- replace the DATETILL parameter in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.datetill);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                l_staqsql := REPLACE (l_staqsql, '''' || rsqlparam.datetill || '''', 'to_date(''' || l_stajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');

                IF LENGTH (l_stajperiodid) > 0
                THEN
                    boodatetooptional := TRUE;
                ELSE
                    IF     (l_stajpvalue <> '01.01.2100')
                       AND (l_stajpvalue <> '01.01.2100 00:00:00')
                    THEN
                        l_stajpvalue_datetill := l_stajpvalue;

                        CLOSE c2_stajobparam;

                        RAISE no_period_with_datetill;
                    END IF;
                END IF;
            ELSE
                -- DateTill parameter not found, check if the Period is given
                -- if Yes then raise error. If Period not given then DateTill is optional (provided DateTo is given)
                IF LENGTH (l_stajperiodid) > 0
                THEN
                    CLOSE c2_stajobparam;

                    RAISE no_datetill_with_period;
                ELSE
                    boodatetooptional := TRUE;
                END IF;
            END IF;

            CLOSE c2_stajobparam;

            -- replace the DATETO parameter in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.dateto);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                l_staqsql := REPLACE (l_staqsql, '''' || rsqlparam.dateto || '''', 'to_date(''' || l_stajpvalue || ''',''dd.mm.yyyy hh24:mi:ss'')');
            ELSE
                IF NOT boodatetooptional
                THEN
                    CLOSE c2_stajobparam;

                    RAISE param_notfound_dateto;
                END IF;
            END IF;

            CLOSE c2_stajobparam;

            -- replace the KEYWORDS parameter in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.keywords);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                IF LENGTH (l_stajpvalue) > 0
                THEN
                    l_staqsql := REPLACE (l_staqsql, rsqlparam.keywords, ' AND BD_KEYWORD IN (' || l_stajpvalue || ')');
                ELSE
                    l_staqsql := REPLACE (l_staqsql, rsqlparam.keywords, '');
                END IF;
            ELSE
                l_staqsql := REPLACE (l_staqsql, rsqlparam.keywords, '');
            END IF;

            CLOSE c2_stajobparam;

            -- replace the SHORTID token in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.shortid);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                IF LENGTH (l_stajpvalue) > 0
                THEN
                    l_staqsql := REPLACE (l_staqsql, rsqlparam.shortid, ' AND SHORTID IN (''' || l_stajpvalue || ''')');
                ELSE
                    l_staqsql := REPLACE (l_staqsql, rsqlparam.shortid, '');
                END IF;
            ELSE
                l_staqsql := REPLACE (l_staqsql, rsqlparam.shortid, '');
            END IF;

            CLOSE c2_stajobparam;

            -- replace the MSISDNA token in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.msisdna);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                IF LENGTH (l_stajpvalue) > 0
                THEN
                    l_stajpvalue := REPLACE (l_stajpvalue, '*', '%');
                    l_stajpvalue := REPLACE (l_stajpvalue, '?', '_');

                    IF    (INSTR (l_stajpvalue, '%') > 0)
                       OR (INSTR (l_stajpvalue, '_') > 0)
                    THEN
                        l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdna, ' AND SENDER LIKE ''' || l_stajpvalue || '''');
                    ELSE
                        l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdna, ' AND SENDER IN (''' || l_stajpvalue || ''')');
                    END IF;
                ELSE
                    l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdna, '');
                END IF;
            ELSE
                l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdna, '');
            END IF;

            CLOSE c2_stajobparam;

            -- replace the MSISDNB token in the SqlDef query
            OPEN c2_stajobparam (p_stajid, rjobparam.msisdnb);

            FETCH c2_stajobparam INTO l_stajpvalue;

            IF c2_stajobparam%FOUND
            THEN
                IF LENGTH (l_stajpvalue) > 0
                THEN
                    l_stajpvalue := REPLACE (l_stajpvalue, '*', '%');
                    l_stajpvalue := REPLACE (l_stajpvalue, '?', '_');

                    IF    (INSTR (l_stajpvalue, '%') > 0)
                       OR (INSTR (l_stajpvalue, '_') > 0)
                    THEN
                        l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdnb, ' AND RECEIVER LIKE ''' || l_stajpvalue || '''');
                    ELSE
                        l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdnb, ' AND RECEIVER IN (''' || l_stajpvalue || ''')');
                    END IF;
                ELSE
                    l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdnb, '');
                END IF;
            ELSE
                l_staqsql := REPLACE (l_staqsql, rsqlparam.msisdnb, '');
            END IF;

            CLOSE c2_stajobparam;

            -- Replace other query tokens, JOB_ID, CON_ID, CON_NAME
            l_staqsql := REPLACE (l_staqsql, '<STAJ_ID>', p_stajid);

            -- Replace the Clause-Token with clause and value if value is found
            -- Else remove the Clause-Token
            IF LENGTH (l_conid) > 0
            THEN
                l_staqsql := REPLACE (l_staqsql, '<CON_ID>', ' AND CON_ID = ''' || l_conid || '''');
            ELSE
                l_staqsql := REPLACE (l_staqsql, '<CON_ID>', '');
            END IF;

            l_staqsql := REPLACE (l_staqsql, '<CON_NAME>', l_conname);

            -- Replace the Clause-Token with clause and value if value is found
            -- Else remove the Clause-Token
            IF LENGTH (l_acid) > 0
            THEN
                l_staqsql := REPLACE (l_staqsql, '<AC_ID>', ' AND AC_ID = ''' || l_acid || '''');
            ELSE
                l_staqsql := REPLACE (l_staqsql, '<AC_ID>', '');
            END IF;

            l_staqsql := REPLACE (l_staqsql, '<AC_NAME>', l_acname);

            -- Create a new SQL statement for this Stats Job
            INSERT INTO sta_jobsql (
                            stajq_jobid,
                            stajq_staqid,
                            stajq_queryname,
                            stajq_sql)
            VALUES      (
                            p_stajid,
                            'STAQ_ID',
                            l_staqqueryname,
                            l_staqsql);

            p_recordsaffected := p_recordsaffected + SQL%ROWCOUNT;
        END LOOP;

        p_returnstatus := 1;
        -- Commit or Rollback done by the calling routine
        -- Commit;
        RETURN;
    EXCEPTION
        WHEN param_notfound_datefrom
        THEN
            p_errnumber := 1001;
            p_errdesc := 'Job Parameter DateFrom not found for replacement';
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_jobsqls', 'Error', p_errnumber || ': ' || p_errdesc); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
        WHEN no_datetill_with_period
        THEN
            p_errnumber := 1002;
            p_errdesc := 'Job Parameter DateTill not found for replacement (Period=' || l_stajperiodid || ')';
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_jobsqls', 'Error', p_errnumber || ': ' || p_errdesc); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
        WHEN no_period_with_datetill
        THEN
            p_errnumber := 1002;
            p_errdesc := 'Job Parameter Period not given with Repeat Date (' || l_stajpvalue_datetill || ')';
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_jobsqls', 'Error', p_errnumber || ': ' || p_errdesc); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
        WHEN param_notfound_dateto
        THEN
            p_errnumber := 1003;
            p_errdesc := 'Job Parameter DateTo not found for replacement';
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_jobsqls', 'Error', p_errnumber || ': ' || p_errdesc); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
        WHEN OTHERS
        THEN
            -- Commit or Rollback done by the calling routine
            -- RollBack;
            p_errnumber := SQLCODE;
            p_errdesc := SQLERRM;
            p_recordsaffected := 0;
            p_returnstatus := 0;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning ('PKG_STATS', 'sp_new_sta_jobsqls', 'Error', p_errnumber || ': ' || p_errdesc); -- 023SO
            END IF;

            ROLLBACK; -- $$$$ check necessity
    END sp_new_sta_jobsqls;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE watchpackagestatechanges (
        vpacid                                  IN packing.pac_id%TYPE,
        voldpacesid                             IN packing.pac_esid%TYPE,
        vnewpacesid                             IN packing.pac_esid%TYPE,
        voldpacltid                             IN packing.pac_ltid%TYPE,
        vnewpacltid                             IN packing.pac_ltid%TYPE)
    IS
        ncount                                  NUMBER;

        vstajltvalue                            sta_job.staj_ltvalue%TYPE := 'NO';

        TYPE tjobcursor IS REF CURSOR;

        cvcurvarjob                             tjobcursor;

        rjob                                    sta_job%ROWTYPE;

        vselect                                 VARCHAR2 (4000);
    BEGIN
        rconfig := getconfig;

        IF rconfig.stac_id IS NULL
        THEN
            RAISE no_config_error;
        END IF;

        IF voldpacltid <> vnewpacltid
        THEN
            vstajltvalue := NULL;
        END IF;

        --Lock jobs when
        --Inactive (Old: Active, Scheduled)
        --Locked (Old: Active, Scheduled)

        IF    (    vnewpacesid = rpacesid.inactive
               AND (   voldpacesid = rpacesid.active
                    OR voldpacesid = rpacesid.scheduled))
           OR (    vnewpacesid = rpacesid.locked
               AND (   voldpacesid = rpacesid.active
                    OR voldpacesid = rpacesid.scheduled))
        THEN
            vselect :=
                   'select * from sta_job where staj_pacid='''
                || vpacid
                || ''' and staj_esid in ('''
                || rstajesid.scheduled
                || ''','''
                || rstajesid.active
                || ''','''
                || rstajesid.working
                || ''') for update nowait'; -- 021SO

            OPEN cvcurvarjob FOR vselect;

            LOOP
                FETCH cvcurvarjob INTO rjob;

                EXIT WHEN cvcurvarjob%NOTFOUND;

                UPDATE sta_job
                SET    staj_esid = rstajesid.locked,
                       staj_datesta = SYSDATE,
                       staj_ltvalue = DECODE (vstajltvalue, 'NO', staj_ltvalue, vstajltvalue),
                       staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                       staj_sysinfo = SUBSTR ('The state of parent package class was changed. The job cannot be done right now.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
                WHERE  staj_id = rjob.staj_id;
            END LOOP;

            CLOSE cvcurvarjob;

            ncount := SQL%ROWCOUNT;
        END IF;

        --Unlock jobs when
        --Active (Old: Inactive, Locked)
        IF     vnewpacesid = rpacesid.active
           AND (   voldpacesid = rpacesid.inactive
                OR voldpacesid = rpacesid.locked)
        THEN
            vselect := 'select * from sta_job where staj_pacid=''' || vpacid || ''' and staj_esid in (''' || rstajesid.locked || ''') for update nowait';

            OPEN cvcurvarjob FOR vselect;

            LOOP
                FETCH cvcurvarjob INTO rjob;

                EXIT WHEN cvcurvarjob%NOTFOUND;

                UPDATE sta_job
                SET    staj_esid = rstajesid.active,
                       staj_datesta = SYSDATE,
                       staj_ltvalue = DECODE (vstajltvalue, 'NO', staj_ltvalue, vstajltvalue),
                       staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                       staj_nooftrials = 1, -- 022SO
                       staj_sysinfo = SUBSTR ('Unlocked/activated Job (' || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi') || ')' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
                WHERE  staj_id = rjob.staj_id;
            END LOOP;

            CLOSE cvcurvarjob;

            ncount := SQL%ROWCOUNT;
        END IF;

        --Delete jobs when
        --Draft (Old: working, Scheduled, Locked)
        --Deleted (Old: Active, Inactive, Scheduled, Locked, Deleted)

        IF    (    vnewpacesid = rpacesid.draft
               AND (voldpacesid = rpacesid.locked))
           OR (    vnewpacesid = rpacesid.deleted
               AND (   voldpacesid = rpacesid.active
                    OR voldpacesid = rpacesid.inactive
                    OR voldpacesid = rpacesid.scheduled
                    OR voldpacesid = rpacesid.locked))
        THEN
            vselect :=
                   'select * from sta_job where staj_pacid='''
                || vpacid
                || ''' and staj_esid in ('''
                || rstajesid.scheduled
                || ''','''
                || rstajesid.active
                || ''','''
                || rstajesid.locked
                || ''','''
                || rstajesid.working
                || ''') for update nowait';

            OPEN cvcurvarjob FOR vselect;

            LOOP
                FETCH cvcurvarjob INTO rjob;

                EXIT WHEN cvcurvarjob%NOTFOUND;

                UPDATE sta_job
                SET    staj_esid = rstajesid.deleted,
                       staj_datesta = SYSDATE,
                       staj_ltvalue = DECODE (vstajltvalue, 'NO', staj_ltvalue, vstajltvalue),
                       staj_chngcnt = DECODE (staj_chngcnt, NULL, 1, staj_chngcnt + 1),
                       staj_sysinfo =
                           SUBSTR ('The state of parent package class was changed. The job cannot be executed anymore. Please define new Job.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
                WHERE  staj_id = rjob.staj_id;
            END LOOP;

            CLOSE cvcurvarjob;

            ncount := SQL%ROWCOUNT;
        END IF;

        COMMIT; -- $$$$ check necessity
    EXCEPTION
        WHEN no_config_error
        THEN
            pkg_common.insert_warning ('PKG_STATS', 'watchPackageStateChanges', 'Error', 'No configuration (DEFAULT) found. Check STA_CONFIG.'); -- 023SO
        WHEN OTHERS
        THEN
            COMMIT; -- $$$$ check necessity

            --Check if one of those dynamic little bastards is still open...
            IF cvcurvarjob%ISOPEN
            THEN
                CLOSE cvcurvarjob;
            END IF;

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'watchPackageStateChanges',
                    SQLCODE,
                    SQLERRM,
                    'PacId: ' || vpacid,
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'watchPackageStateChanges',
                    'Error ' || voldpacesid || '-' || vnewpacesid || ':' || vpacid,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    vpacid); -- 023SO
            END IF;
    END watchpackagestatechanges;

    /* =========================================================================
       Keeping track of all System Messages.
       Only if STAC_CONFIG.stac_syslogger = 1.
       ---------------------------------------------------------------------- */

    PROCEDURE writesyslog (
        pmethod                                 IN VARCHAR2,
        psqlcode                                IN NUMBER,
        psqlerrm                                IN VARCHAR2,
        pparameter                              IN VARCHAR2,
        ploggedon                               IN DATE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO sta_syslog (
                        stas_method,
                        stas_sqlcode,
                        stas_sqlerrm,
                        stas_parameter,
                        stas_datelog)
        VALUES      (
                        pmethod,
                        psqlcode,
                        psqlerrm,
                        pparameter,
                        ploggedon);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'writeSysLog',
                    SQLCODE,
                    SQLERRM,
                    '',
                    SYSDATE);
            END IF;
    END writesyslog;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN sta_config%ROWTYPE
    IS
        vconfig                                 sta_config%ROWTYPE;
    BEGIN
        SELECT *
        INTO   vconfig
        FROM   sta_config
        WHERE  stac_id = 'DEFAULT';

        RETURN vconfig;
    EXCEPTION
        WHEN OTHERS
        THEN
            writesyslog (
                'getConfig',
                SQLCODE,
                SQLERRM,
                'stac_id = DEFAULT',
                SYSDATE);
            pkg_common.insert_warning ('PKG_STATS', 'getConfig', 'Error ', 'No configuration (DEFAULT) found. Check STA_CONFIG.'); -- 023SO
            RETURN vconfig;
    END getconfig;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION getxproc (vxprocname IN xproc.xpr_id%TYPE)
        RETURN xproc%ROWTYPE
    IS
        vxproc                                  xproc%ROWTYPE;
    BEGIN
        SELECT *
        INTO   vxproc
        FROM   xproc
        WHERE  xpr_id = vxprocname;

        RETURN vxproc;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'getXproc',
                    SQLCODE,
                    SQLERRM,
                    NULL,
                    SYSDATE);
            END IF;

            RETURN vxproc;
    END getxproc;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Checks if there is anything to do; return value <> 0 yep, 0 = no.
       ---------------------------------------------------------------------- */

    PROCEDURE anythingtodo (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; -- $$$$ check necessity

        vxprocname                              xproc.xpr_id%TYPE := returnstatus;

        ncount                                  NUMBER := 0;
        ncount1                                 NUMBER := 0;
    BEGIN
        --Get default configuration settings
        rconfig := getconfig;

        IF rconfig.stac_id IS NULL
        THEN
            RAISE no_config_error;
        END IF;

        rxproc := getxproc (vxprocname);

        --Check if calling XPIOC is valid at all
        IF rxproc.xpr_id IS NULL
        THEN
            recordsaffected := 0;
            returnstatus := 0;

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'anythingToDo',
                    777777,
                    'Calling XPIOC ' || vxprocname || ' is unknown. Check table XPROC.',
                    p_pact_id,
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'anythingToDo',
                    'XPROC',
                    'Calling XPIOC ' || vxprocname || ' is unknown. Check table XPROC.',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;
        --Check if calling XPIOC is active
        ELSIF    rxproc.xpr_esid = rxpresid.inactive
              OR rxproc.xpr_esid = rxpresid.deleted
        THEN
            recordsaffected := 0;
            returnstatus := 0;

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'anythingToDo',
                    777777,
                    'Calling XPIOC ' || vxprocname || ' is not active (Status= ' || rxproc.xpr_esid || '). Check table XPROC.',
                    p_pact_id,
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'anythingToDo',
                    'XPROC',
                    'Calling XPIOC ' || vxprocname || ' is not active (Status= ' || rxproc.xpr_esid || '). Check table XPROC.',
                    NULL,
                    p_boh_id); -- 023SO
            END IF;
        ELSE
            --Check Configuration States STAC_EXECSTAT, STAC_EXECREP and STAC_EXECPROC
            --Check if the main STATISTIC MODULE flag is set to NO/OFF = 0
            IF rconfig.stac_execstat = 0
            THEN
                --The Stats Module is deactivated! dont do anything...
                IF rconfig.stac_syslogger = 1
                THEN
                    writesyslog (
                        'anythingToDo',
                        777777,
                        'The STATS Module is deactivated. Controll the Configuration.',
                        p_pact_id,
                        SYSDATE);
                END IF;

                recordsaffected := 0;
                returnstatus := 0;
            ELSE
                --Initialize variable
                recordsaffected := 0;
                returnstatus := 1;

                --Is the GENERATOR asking for work?
                IF p_pact_id = 'STATSCHED'
                THEN
                    pkg_stats.schedulestats (
                        'ANYTHING',
                        p_boh_id,
                        recordsaffected,
                        errorcode,
                        errormsg,
                        vxprocname);
                    returnstatus := vxprocname;
                END IF;

                IF p_pact_id = 'STATEXEC'
                THEN
                    --Count first the possible scheduled CONSOL-jobs
                    --Start read-only session ...
                    SET TRANSACTION READ ONLY; -- $$$$ check necessity

                    --Now check, if flag in configuration for executing procedures is on
                    IF rconfig.stac_execproc = 0
                    THEN
                        ncount := 0;
                    ELSE
                        SELECT COUNT (*)
                        INTO   ncount
                        FROM   sta_job,
                               packing
                        WHERE      staj_pacid = pac_id
                               AND pac_esid IN (rpacesid.active,
                                                rpacesid.scheduled)
                               AND staj_esid = rstajesid.scheduled
                               AND pac_etid = rpacetid.consol
                               AND SYSDATE >= staj_dateexe
                               AND SYSDATE <= (staj_dateexe + ((1 / 24) * rconfig.stac_execsched))
                               AND pac_xprocid = vxprocname;
                    END IF;

                    --Count the possible scheduled statistic-jobs STAT, STATIND
                    --Now check, if flag in configuration for executing stats is on
                    IF rconfig.stac_execrep = 0
                    THEN
                        ncount1 := 0;
                    ELSE
                        SELECT COUNT (*)
                        INTO   ncount1
                        FROM   sta_job,
                               packing
                        WHERE      staj_pacid = pac_id
                               AND pac_esid IN (rpacesid.active,
                                                rpacesid.scheduled)
                               AND staj_esid = rstajesid.scheduled
                               AND pac_etid IN (rpacetid.stat,
                                                rpacetid.statind)
                               AND SYSDATE >= staj_dateexe
                               AND SYSDATE <= (staj_dateexe + ((1 / 24) * rconfig.stac_execsched))
                               AND pac_xprocid = vxprocname;
                    END IF;

                    COMMIT; --end read only session calculateOpenJobs       -- $$$$ check necessity
                    recordsaffected := ncount + ncount1;
                END IF;
            END IF;
        END IF;

        IF recordsaffected > 0
        THEN
            --fetch BOH_ID key and give it back to caller
            p_boh_id := pkg_common.generateuniquekey ('G');

            IF p_pact_id = 'STATEXEC'
            THEN
                recordsaffected := 1;
            END IF;

            --insert row into boheader
            INSERT INTO boheader (
                            boh_id,
                            boh_demo,
                            boh_fileseq,
                            boh_datetime,
                            boh_filename,
                            boh_filedate,
                            boh_reccount,
                            boh_packid,
                            boh_start,
                            boh_esid)
            VALUES      (
                            p_boh_id,
                            0,
                            '0001',
                            SYSDATE,
                            'PKG_STATS.anythingToDo',
                            SYSDATE,
                            recordsaffected,
                            p_pact_id,
                            SYSDATE,
                            'PAC');

            COMMIT; -- $$$$ check necessity
        END IF;
    EXCEPTION
        WHEN no_config_error
        THEN
            pkg_common.insert_warning ('PKG_STATS', 'anythingToDo', 'Error ', 'No configuration (DEFAULT) found. Check STA_CONFIG.'); -- 023SO
            recordsaffected := 0;
            returnstatus := 0;
        WHEN NO_DATA_FOUND
        THEN
            recordsaffected := 0;
            returnstatus := 0;

            COMMIT; --end Read-Only Transaction         -- $$$$ check necessity
        WHEN OTHERS
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'anythingToDo',
                    SQLCODE,
                    SQLERRM,
                    p_pact_id,
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'anythingToDo',
                    'Error ' || p_pact_id,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    p_boh_id); -- 023SO
            END IF;

            recordsaffected := 0;
            returnstatus := 0;

            COMMIT; --end Read-Only Transaction         -- $$$$ check necessity
    END anythingtodo;

    /* =========================================================================
       Check which procedures or other reports has to be done, before a certain
       report can be executed.
       ---------------------------------------------------------------------- */

    PROCEDURE checkdependencies (
        inpacid                                 IN     VARCHAR2,
        indatefrom                              IN     DATE, -- TODO unused parameter? (wwe)
        indateto                                IN     DATE,
        odepend                                 IN OUT BOOLEAN, -- TODO looks very odd (wwe)
        odepinfo                                IN OUT tdepinfo,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2 --also for CALLER
                                                               )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; -- $$$$ check necessity

        CURSOR cpacking (inpacid IN packing.pac_id%TYPE)
        IS -- 004SO
            SELECT pac_id,
                   pac_name,
                   pac_periodid,
                   pac_datedone,
                   pac_esid,
                   NVL (pac_startday, 0)        AS pac_startday,
                   NVL (pac_starthour, 0)       AS pac_starthour,
                   NVL (pac_startminute, 0)     AS pac_startminute,
                   period_durseq
            FROM   packing,
                   periodicity
            WHERE      pac_periodid = period_id
                   AND pac_id = inpacid;

        cpackingrow                             cpacking%ROWTYPE; -- 004SO

        CURSOR cforerunnerpacking (inpacid IN packing.pac_id%TYPE)
        IS -- 004SO
            SELECT   pac_id,
                     pac_name,
                     pac_periodid,
                     pac_datedone,
                     pac_esid,
                     NVL (pac_startday, 0)        AS pac_startday,
                     NVL (pac_starthour, 0)       AS pac_starthour,
                     NVL (pac_startminute, 0)     AS pac_startminute,
                     period_durseq
            FROM     packing,
                     periodicity
            WHERE        pac_periodid = period_id
                     AND pac_id IN (SELECT pacpac_pacid1
                                    FROM   pacpacdep
                                    WHERE  pacpac_pacid2 = inpacid)
            -- and pac_esid in (rPacEsid.active, rPacEsid.scheduled, rPacEsid.locked)   -- 013SO
            ORDER BY period_durseq DESC, -- $$$$ check ordering
                     pac_startday DESC,
                     pac_starthour DESC,
                     pac_startminute DESC;

        cforerunnerpackingrow                   cforerunnerpacking%ROWTYPE; -- 004SO

        dcanbedoneafter                         DATE; -- 004SO
        dmustbedoneafter                        DATE;

        vcaller                                 VARCHAR2 (30);
    BEGIN
        vcaller := returnstatus;

        --Clear "old" values
        odepinfo := tdepinfo (NULL, NULL, NULL);
        odepinfo.delete;

        --Set return values in case we dont have dependencies
        odepend := FALSE;

        SET TRANSACTION READ ONLY; -- $$$$ check necessity

       <<loop_cpacking>>
        FOR cpackingrow IN cpacking (inpacid)
        LOOP
           -- get the context for the job to be scheduled (no looping here, only one row returned)

           --Loop through eventually existing dependencies:
           <<loop_cforerunnerpacking>>
            FOR cforerunnerpackingrow IN cforerunnerpacking (inpacid)
            LOOP
                --Check the periodid and the pac_datedone!
                --Calculate next possible execution date depending on periodid
                dcanbedoneafter := getnextexecdate (vcaller, cforerunnerpackingrow.pac_id, indateto);

                IF cpackingrow.pac_periodid = 'HOURLY'
                THEN
                    dmustbedoneafter := TRUNC (dcanbedoneafter, 'hh24');
                ELSIF cpackingrow.pac_periodid = 'DAILY'
                THEN
                    dmustbedoneafter := TRUNC (dcanbedoneafter);
                ELSIF cpackingrow.pac_periodid = 'WEEKLY'
                THEN
                    dmustbedoneafter := TRUNC (dcanbedoneafter, 'day'); -- will be the last monday
                ELSIF cpackingrow.pac_periodid = 'MONTHLY'
                THEN
                    dmustbedoneafter := TRUNC (dcanbedoneafter, 'MONTH');
                ELSIF cpackingrow.pac_periodid = 'YEARLY'
                THEN
                    dmustbedoneafter := TRUNC (dcanbedoneafter, 'YEAR');
                END IF;

                IF    (cforerunnerpackingrow.pac_datedone IS NULL)
                   OR (cforerunnerpackingrow.pac_datedone < dmustbedoneafter)
                   OR (cforerunnerpackingrow.pac_esid NOT IN (rpacesid.active,
                                                              rpacesid.draft))
                THEN -- 013SO -- 011SO
                    odepend := TRUE; -- 004SO logic reversed
                    odepinfo.EXTEND; -- initalize one null-value element             -- 004SO moved here
                    odepinfo (odepinfo.COUNT).deppacid := cforerunnerpackingrow.pac_id; -- 004SO fill new element
                    odepinfo (odepinfo.COUNT).deppacname := cforerunnerpackingrow.pac_name; -- 004SO fill new element
                    odepinfo (odepinfo.COUNT).deppacexec := dcanbedoneafter; -- 004SO fill new element
                END IF;
            -- exit;   -- 004SO
            END LOOP loop_cforerunnerpacking;
        END LOOP loop_cpacking;

        COMMIT; --End READ ONLY         -- $$$$ check necessity

        returnstatus := 1;
        recordsaffected := odepinfo.COUNT;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
            recordsaffected := 0;

            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'checkDependencies',
                    SQLCODE,
                    SQLERRM,
                    '',
                    SYSDATE);
            END IF;

            IF rconfig.stac_logwarning = 1
            THEN
                pkg_common.insert_warning (
                    'PKG_STATS',
                    'checkDependencies',
                    'Error ' || inpacid,
                    SQLCODE || ': ' || SQLERRM,
                    NULL,
                    inpacid); -- 023SO
            END IF;
    END checkdependencies;

    /* =========================================================================
       Set active Jobs back in case of major user defined error.
       ---------------------------------------------------------------------- */

    PROCEDURE updatejobonerror (
        pacid                                   IN packing.pac_id%TYPE,
        jobid                                   IN sta_job.staj_id%TYPE,
        p_boh_id                                IN VARCHAR2,
        reason                                  IN VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF pacid IS NOT NULL
        THEN
            UPDATE packing
            SET    pac_esid = 'I',
                   pac_datemod = SYSDATE,
                   pac_chngcnt = pac_chngcnt + 1,
                   pac_info = SUBSTR ('updateJobOnError: ' || reason || '. Please contact administrator.' || CHR (10) || SUBSTR (pac_info, 1, 900), 1, 999)
            WHERE  pac_id = pacid;
        ELSIF jobid IS NOT NULL
        THEN
            UPDATE sta_job
            SET    staj_datetry = SYSDATE,
                   staj_nooftrials = 1,
                   staj_esid = rstajesid.draft,
                   staj_datesta = SYSDATE,
                   staj_sysinfo = SUBSTR ('Raised Error: ' || reason || '. Please contact administrator.' || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999),
                   staj_chngcnt = staj_chngcnt + 1,
                   staj_bohidexec = p_boh_id
            WHERE  staj_id = jobid;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF rconfig.stac_syslogger = 1
            THEN
                writesyslog (
                    'getXproc',
                    SQLCODE,
                    SQLERRM,
                    NULL,
                    SYSDATE);
            END IF;
    END updatejobonerror;
END pkg_stats;
/
