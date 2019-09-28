CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_common_stats
IS
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

    rconfig                                 sta_config%ROWTYPE;
    vdummy                                  VARCHAR2 (100);
    vsysinfo                                VARCHAR2 (4000);

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getconfig
        RETURN sta_config%ROWTYPE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_job_scheduled (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajltvalue                           IN     sta_job.staj_ltvalue%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE);

    PROCEDURE new_sta_param (
        p_stajp_jobid                           IN VARCHAR2,
        p_stajp_name                            IN VARCHAR2,
        p_stajp_value                           IN VARCHAR2);

    PROCEDURE update_sta_job (
        p_stajid                                IN sta_job.staj_id%TYPE,
        p_stajesid                              IN sta_job.staj_esid%TYPE);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_sta_job_error_count (
        p_stajpacid                             IN sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN sta_job.staj_periodid%TYPE)
        RETURN INTEGER
    IS -- 005SO Get scheduled Job count with expired retries
        CURSOR cfailedlooperjobcount IS
            SELECT COUNT (*)
            FROM   sta_job,
                   sta_config
            WHERE      staj_pacid = p_stajpacid
                   AND stac_id = 'DEFAULT'
                   AND staj_esid IN (rstajesid.scheduled,
                                     rstajesid.working,
                                     rstajesid.active) -- 011SO
                   AND NVL (staj_nooftrials, 0) >= stac_nooftrials -- 008SO
                   AND staj_datesta >= SYSDATE - stac_execsched / 24 -- 012SO
                   AND staj_datesta >=
                       DECODE (
                           p_stajperiodid, -- 012SO
                           'DAILY', TRUNC (SYSDATE),
                           'WEEKLY', TRUNC (SYSDATE, 'day'),
                           'MONTHLY', TRUNC (SYSDATE, 'MONTH'),
                           'YEARLY', TRUNC (SYSDATE, 'YEAR'),
                           'HOURLY', TRUNC (SYSDATE, 'HH24'),
                           SYSDATE - stac_execsched / 24); -- keep this in sync with cJobCandidate in GET_STA_JOB_WORKING

        l_job_count                             PLS_INTEGER;
    BEGIN
        OPEN cfailedlooperjobcount;

        FETCH cfailedlooperjobcount INTO l_job_count;

        CLOSE cfailedlooperjobcount;

        RETURN l_job_count;
    END get_sta_job_error_count;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_sta_job_scheduled_count (
        p_stajpacid                             IN sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN sta_job.staj_periodid%TYPE)
        RETURN INTEGER
    IS -- 005SO Get scheduled and executable Job count
        CURSOR cexecutablelooperjobcount IS
            SELECT COUNT (*)
            FROM   sta_job,
                   sta_config
            WHERE      staj_pacid = p_stajpacid
                   AND stac_id = 'DEFAULT'
                   AND staj_esid IN (rstajesid.scheduled,
                                     rstajesid.working,
                                     rstajesid.active) -- 011SO
                   AND NVL (staj_nooftrials, 0) <= stac_nooftrials
                   AND staj_datesta >= SYSDATE - stac_execsched / 24 -- 012SO
                   AND staj_datesta >=
                       DECODE (
                           p_stajperiodid, -- 012SO
                           'DAILY', TRUNC (SYSDATE),
                           'WEEKLY', TRUNC (SYSDATE, 'day'),
                           'MONTHLY', TRUNC (SYSDATE, 'MONTH'),
                           'YEARLY', TRUNC (SYSDATE, 'YEAR'),
                           'HOURLY', TRUNC (SYSDATE, 'HH24'),
                           SYSDATE - stac_execsched / 24); -- keep this in sync with cJobCandidate in GET_STA_JOB_WORKING

        l_job_count                             PLS_INTEGER;
    BEGIN
        OPEN cexecutablelooperjobcount;

        FETCH cexecutablelooperjobcount INTO l_job_count;

        CLOSE cexecutablelooperjobcount;

        RETURN l_job_count;
    END get_sta_job_scheduled_count;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE get_sta_job_working (
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE)
    IS -- 003SO Get next scheduled Job and set to working state
        CURSOR cjobcandidate IS
            SELECT   staj_id
            FROM     sta_job,
                     sta_config
            WHERE        staj_pacid = p_stajpacid
                     AND stac_id = 'DEFAULT'
                     AND staj_esid IN (rstajesid.scheduled,
                                       rstajesid.working,
                                       rstajesid.active) -- 009SO
                     AND NVL (staj_nooftrials, 0) <= stac_nooftrials
                     AND staj_datesta >= SYSDATE - stac_execsched / 24 -- 012SO
                     AND staj_datesta >=
                         DECODE (
                             p_stajperiodid, -- 012SO
                             'DAILY', TRUNC (SYSDATE),
                             'WEEKLY', TRUNC (SYSDATE, 'day'),
                             'MONTHLY', TRUNC (SYSDATE, 'MONTH'),
                             'YEARLY', TRUNC (SYSDATE, 'YEAR'),
                             'HOURLY', TRUNC (SYSDATE, 'HH24'),
                             SYSDATE - stac_execsched / 24)
            ORDER BY staj_esid ASC,
                     staj_nooftrials ASC,
                     staj_datetry ASC; -- 004SO
    BEGIN
        OPEN cjobcandidate;

        FETCH cjobcandidate INTO p_stajid;

        IF cjobcandidate%FOUND
        THEN
            update_sta_job_working (p_stajid, p_boheaderid);
        END IF;

        CLOSE cjobcandidate;
    END get_sta_job_working;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_job_working (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajltvalue                           IN     sta_job.staj_ltvalue%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE)
    IS -- 015SO Create Job in Working state
        l_period_start                          DATE; -- 006SO
        l_period_end                            DATE; -- 006SO
    BEGIN
        -- Get a new Job Id
        p_stajid := pkg_common.generateuniquekey ('G');

        INSERT INTO sta_job (
                        staj_id,
                        staj_pacid,
                        staj_parentid,
                        staj_esid,
                        staj_etid,
                        staj_acidcre,
                        staj_datecre,
                        staj_dateexe,
                        staj_datesta,
                        staj_datetry,
                        staj_bohidsched,
                        staj_nooftrials,
                        staj_bohidexec,
                        staj_ltvalue,
                        staj_sysinfo,
                        staj_periodid,
                        staj_chngcnt)
        VALUES      (
            p_stajid,
            p_stajpacid,
            p_stajparentid,
            rstajesid.working,
            'SIMPLE',
            'SYSTEM',
            SYSDATE,
            SYSDATE,
            SYSDATE,
            SYSDATE,
            p_boheaderid,
            1,
            p_boheaderid,
            p_stajltvalue,
            'Processing started at ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS'),
            p_stajperiodid,
            0);

        pkg_common.getdatesforperiod (p_stajperiodid, l_period_start, l_period_end); -- 006SO
        new_sta_param (p_stajid, '[DATEFROM]', TO_CHAR (l_period_start, 'dd.mm.yyyy hh24:mi:ss')); -- 007SO -- 006SO
        new_sta_param (p_stajid, '[DATETO]', TO_CHAR (l_period_end, 'dd.mm.yyyy hh24:mi:ss')); -- 006SO
    END new_sta_job_working;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_jobs_loopers (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_createdjobcount                          OUT NUMBER)
    IS -- 002SO  Create all looper jobs in Scheduled state
        CURSOR citeratorsql IS
            SELECT paci_sql
            FROM   paciterator,
                   packing
            WHERE      paci_id = pac_itid
                   AND pac_id = p_stajpacid;

        TYPE trefcursor IS REF CURSOR;

        citerator                               trefcursor;

        CURSOR cperiodicity IS
            SELECT period_value2,
                   period_value3
            FROM   periodicity
            WHERE  period_id = p_stajperiodid;

        l_iteratorsql                           VARCHAR2 (2000);
        l_iteratoritem                          VARCHAR2 (10);
        l_stajid                                VARCHAR2 (10);
    BEGIN
        p_createdjobcount := 0;

       <<loop_citeratorsql>>
        FOR citeratorsqlrow IN citeratorsql
        LOOP
            l_iteratorsql := citeratorsqlrow.paci_sql;

           <<loop_cperiodicity>>
            FOR cperiodicityrow IN cperiodicity
            LOOP
                l_iteratorsql := REPLACE (l_iteratorsql, '''<DATEFROM>''', cperiodicityrow.period_value2);
                l_iteratorsql := REPLACE (l_iteratorsql, '''<DATETO>''', cperiodicityrow.period_value3);
                l_iteratorsql := REPLACE (l_iteratorsql, '<DATEFROM>', cperiodicityrow.period_value2);
                l_iteratorsql := REPLACE (l_iteratorsql, '<DATETO>', cperiodicityrow.period_value3);
            END LOOP loop_cperiodicity;

            OPEN citerator FOR l_iteratorsql;

           <<loop_citerator>>
            LOOP
                FETCH citerator INTO l_iteratoritem;

                EXIT WHEN citerator%NOTFOUND;
                new_sta_job_scheduled (
                    p_stajparentid,
                    p_stajpacid,
                    l_iteratoritem,
                    p_stajperiodid,
                    p_boheaderid,
                    l_stajid);
                p_createdjobcount := p_createdjobcount + 1;
            END LOOP loop_citerator;

            CLOSE citerator;
        END LOOP loop_citeratorsql;
    END new_sta_jobs_loopers;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job_success (p_stajid IN sta_job.staj_id%TYPE)
    IS -- 015SO
    BEGIN
        update_sta_job (p_stajid, rstajesid.okay);
    END update_sta_job_success;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job_working (
        p_stajid                                IN sta_job.staj_id%TYPE,
        p_boheaderid                            IN boheader.boh_id%TYPE)
    IS
    BEGIN
        update_sta_job (p_stajid, rstajesid.working);

        UPDATE sta_job
        SET    staj_bohidexec = p_boheaderid,
               staj_datetry = SYSDATE,
               staj_nooftrials = NVL (staj_nooftrials, 0) + 1
        WHERE  staj_id = p_stajid;
    END update_sta_job_working;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE watchpackagestatechanges (
        vpacid                                  IN packing.pac_id%TYPE,
        voldpacesid                             IN packing.pac_esid%TYPE,
        vnewpacesid                             IN packing.pac_esid%TYPE,
        voldpacltid                             IN packing.pac_ltid%TYPE, -- TODO unused parameter? (wwe)
        vnewpacltid                             IN packing.pac_ltid%TYPE) -- TODO unused parameter? (wwe)
    IS -- 010SO
    BEGIN
        rconfig := getconfig;

        --Lock jobs when
        --Inactive (Old: Active, Scheduled)
        --Locked (Old: Active, Scheduled)

        IF     voldpacesid IN (rpacesid.active,
                               rpacesid.scheduled)
           AND vnewpacesid IN (rpacesid.inactive,
                               rpacesid.locked)
        THEN
            UPDATE sta_job
            SET    staj_esid = rstajesid.locked,
                   staj_datesta = SYSDATE,
                   staj_chngcnt = NVL (staj_chngcnt, 0) + 1,
                   staj_sysinfo = SUBSTR ('Job locked at ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi:ss') || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
            WHERE      staj_pacid = vpacid
                   AND staj_esid IN (rstajesid.scheduled,
                                     rstajesid.active,
                                     rstajesid.working);
        END IF;

        --Unlock jobs when
        --Active (Old: Inactive, Locked)
        IF     vnewpacesid = rpacesid.active
           AND voldpacesid IN (rpacesid.inactive,
                               rpacesid.locked)
        THEN
            UPDATE sta_job
            SET    staj_esid = rstajesid.active,
                   staj_datesta = SYSDATE,
                   staj_chngcnt = NVL (staj_chngcnt, 0) + 1,
                   staj_nooftrials = 1, -- 022SO
                   staj_sysinfo = SUBSTR ('Job unlocked/re-activated at ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi:ss') || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999)
            WHERE      staj_pacid = vpacid
                   AND staj_esid = rstajesid.locked;
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
            UPDATE sta_job
            SET    staj_esid = rstajesid.deleted,
                   staj_datesta = SYSDATE,
                   staj_chngcnt = NVL (staj_chngcnt, 0) + 1,
                   staj_sysinfo =
                       SUBSTR (
                              'Packing was changed at '
                           || TO_CHAR (SYSDATE, 'DD.MM.YYYY hh24:mi:ss')
                           || ' The job cannot be executed anymore. Please define new Job.'
                           || CHR (10)
                           || SUBSTR (staj_sysinfo, 1, 3000),
                           1,
                           3999)
            WHERE      staj_pacid = vpacid
                   AND staj_esid IN (rstajesid.scheduled,
                                     rstajesid.active,
                                     rstajesid.locked,
                                     rstajesid.working);
        END IF;
    /*
    exception
         when Others then
            if rConfig.stac_syslogger > 0 then L('watchPackageStateChanges(' || vPacId || ')', SQLERRM); end if;
    */

    END watchpackagestatechanges;

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
    END getconfig;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_job_scheduled (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajltvalue                           IN     sta_job.staj_ltvalue%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE)
    IS -- 001SO  Create Job in Scheduled state
        l_period_start                          DATE; -- 006SO
        l_period_end                            DATE; -- 006SO
    BEGIN
        -- Get a new Job Id
        p_stajid := pkg_common.generateuniquekey ('G');

        INSERT INTO sta_job (
                        staj_id,
                        staj_pacid,
                        staj_parentid,
                        staj_esid,
                        staj_etid,
                        staj_acidcre,
                        staj_datecre,
                        staj_dateexe,
                        staj_datesta,
                        staj_datetry,
                        staj_bohidsched,
                        staj_nooftrials,
                        staj_bohidexec,
                        staj_ltvalue,
                        staj_sysinfo,
                        staj_periodid,
                        staj_chngcnt)
        VALUES      (
            p_stajid,
            p_stajpacid,
            p_stajparentid,
            rstajesid.scheduled,
            'SCHEDULED',
            'SYSTEM',
            SYSDATE,
            SYSDATE,
            SYSDATE,
            NULL,
            p_boheaderid,
            0,
            NULL,
            p_stajltvalue,
            'Scheduled at ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS'),
            p_stajperiodid,
            0);

        pkg_common.getdatesforperiod (p_stajperiodid, l_period_start, l_period_end); -- 006SO
        new_sta_param (p_stajid, '[DATEFROM]', TO_CHAR (l_period_start, 'dd.mm.yyyy hh24:mi:ss')); -- 007SO -- 006SO
        new_sta_param (p_stajid, '[DATETO]', TO_CHAR (l_period_end, 'dd.mm.yyyy hh24:mi:ss')); -- 006SO
    END new_sta_job_scheduled;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_param (
        p_stajp_jobid                           IN VARCHAR2,
        p_stajp_name                            IN VARCHAR2,
        p_stajp_value                           IN VARCHAR2)
    IS -- 006SO
    BEGIN
        INSERT INTO sta_jobparam (
                        stajp_id,
                        stajp_jobid,
                        stajp_name,
                        stajp_value)
        VALUES      (
            pkg_common.generateuniquekey ('G'),
            p_stajp_jobid,
            p_stajp_name,
            p_stajp_value);
    END new_sta_param;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job (
        p_stajid                                IN sta_job.staj_id%TYPE,
        p_stajesid                              IN sta_job.staj_esid%TYPE)
    IS
        l_state_text                            sta_jobstate.stajs_lang01%TYPE;
    BEGIN
        SELECT stajs_lang01
        INTO   l_state_text
        FROM   sta_jobstate
        WHERE  stajs_id = p_stajesid;

        UPDATE sta_job
        SET    staj_esid = p_stajesid,
               staj_datesta = SYSDATE,
               staj_sysinfo = SUBSTR ('Processing ' || l_state_text || ' at ' || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS') || CHR (10) || SUBSTR (staj_sysinfo, 1, 3000), 1, 3999),
               staj_chngcnt = staj_chngcnt + 1
        WHERE  staj_id = p_stajid;
    END update_sta_job;
END pkg_common_stats;
/