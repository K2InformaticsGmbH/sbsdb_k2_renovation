CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_common_mapping
IS
    /* =========================================================================
        (Billing/Handler) Input Header States.
        ---------------------------------------------------------------------- */

    TYPE tihesid IS RECORD
    (
        errorinfile bihstate.bihs_id%TYPE := 'ERF',
        errorinrec bihstate.bihs_id%TYPE := 'ERR',
        indexed bihstate.bihs_id%TYPE := 'IDX',
        mapping bihstate.bihs_id%TYPE := 'MAP',
        ready bihstate.bihs_id%TYPE := 'RDY'
    );

    cfiletimetolerance                      PLS_INTEGER := 10; --011SO --008SO tolerance in duplicate file check
    cmaxtries                               PLS_INTEGER := 3; -- Procedure SP_INSERT_BIHEADER_MEC (for same FileName and FileDate)
    cstrmecdatetimeformat                   VARCHAR2 (20) := 'YYYYMMDDHH24MISS'; --002SO
    rinputheaderstate                       tihesid; --002SO

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getsrctypeformapping (p_bih_mapid IN VARCHAR2)
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION getsrctypeforbiheader (p_bih_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (10);
    BEGIN
        SELECT bih_srctype
        INTO   l_result
        FROM   biheader
        WHERE  bih_id = p_bih_id;

        RETURN l_result;
    END getsrctypeforbiheader;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION gettypeformapping (p_bih_mapid IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (10);
    BEGIN
        SELECT map_etid
        INTO   l_result
        FROM   mapping
        WHERE  map_id = p_bih_mapid;

        RETURN l_result;
    END gettypeformapping;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION istimeformapping (p_bih_mapid IN VARCHAR2)
        RETURN INTEGER
    IS
        CURSOR cinconvenienttime IS
            SELECT map_execute,
                   map_conditionalexec,
                   map_periodid,
                   map_startday,
                   map_starthour,
                   map_startminute,
                   map_endclearance, --005SO
                   map_datetry,
                   map_datedone
            FROM   mapping
            WHERE  map_id = p_bih_mapid;

        cinconvenienttimerow                    cinconvenienttime%ROWTYPE;

        TYPE tcurdef IS REF CURSOR;

        cvcurvar                                tcurdef;
        l_sql                                   VARCHAR2 (4000);
        bgo                                     BOOLEAN;
        vgo                                     VARCHAR2 (4000);
    BEGIN
        bgo := FALSE;

       -- Check if this is a convenient time for processing
       <<loop_cinconvenienttime>>
        FOR cinconvenienttimerow IN cinconvenienttime
        LOOP
            IF cinconvenienttimerow.map_execute = 1
            THEN
                IF cinconvenienttimerow.map_conditionalexec IS NULL
                THEN
                    bgo := TRUE;
                ELSE
                    IF SUBSTR (UPPER (cinconvenienttimerow.map_conditionalexec), 1, 6) = 'SELECT'
                    THEN
                        -- must check a condition sql
                        l_sql := cinconvenienttimerow.map_conditionalexec;
                    ELSE
                        -- condition view or table name given
                        l_sql := 'SELECT  * FROM ' || cinconvenienttimerow.map_conditionalexec;
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
                        END IF;
                    END IF;

                    CLOSE cvcurvar;
                END IF;

                IF bgo
                THEN
                    bgo :=
                        pkg_common.istimeforprocess (
                            cinconvenienttimerow.map_periodid,
                            cinconvenienttimerow.map_startday,
                            cinconvenienttimerow.map_starthour,
                            cinconvenienttimerow.map_startminute,
                            cinconvenienttimerow.map_endclearance, --005SO
                            cinconvenienttimerow.map_datedone); --004SO
                END IF;
            END IF;
        END LOOP loop_cinconvenienttime;

        IF bgo
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END istimeformapping;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE insert_biheader (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER, --006SO was p_JobId
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2) -- TODO unused parameter? (wwe)
    IS
        CURSOR cheaderdup (
            p_filename                              IN VARCHAR2,
            filecredate                             IN DATE)
        IS
            SELECT SUM (DECODE (UPPER (bih_esid), rinputheaderstate.mapping, 0, 1))     AS donecount,
                   SUM (DECODE (UPPER (bih_esid), rinputheaderstate.mapping, 1, 0))     AS notdonecount
            FROM   biheader
            WHERE      bih_filename = p_filename
                   AND bih_filedate >= filecredate - cfiletimetolerance --011SO --008SO
                   AND bih_filedate <= filecredate + cfiletimetolerance --011SO --008SO
                   AND UPPER (bih_esid) IN (rinputheaderstate.ready,
                                            rinputheaderstate.errorinrec,
                                            rinputheaderstate.mapping); --002SO

        --002SO all below
        l_countdone                             PLS_INTEGER;
        l_countnotdone                          PLS_INTEGER;

        l_filedate                              DATE;
    BEGIN
        IF istimeformapping (p_bih_mapid) = 0
        THEN
            RAISE pkg_common.excp_inconvenient_time;
        END IF;

        IF p_bih_id IS NULL
        THEN
            p_bih_id := pkg_common.generateuniquekey ('G');
        END IF;

        -- Check to see if this file (with same timestamp) was entered in the table before
        -- If yes and has state READY or ERROR, then do not process again
        -- If yes and state was left on MAP or set to ERF, then retry once again (i.e., generate Header Id and continue as normal)
        l_filedate := TO_DATE (p_bih_filedate, cstrmecdatetimeformat);

        OPEN cheaderdup (p_bih_filename, l_filedate);

        FETCH cheaderdup
            INTO l_countdone,
                 l_countnotdone;

        CLOSE cheaderdup;

        IF l_countdone > 0
        THEN
            RAISE pkg_common.excp_rdy_err_header_found; --002SO
        ELSIF l_countnotdone >= cmaxtries
        THEN
            RAISE pkg_common.excp_rdy_err_many_retries; --002SO
        ELSE
            -- No READY or excess ERROR states found for this filename (and file timestamp)
            -- Driver may process this file
            INSERT INTO biheader (
                            bih_id,
                            bih_srctype,
                            bih_demo,
                            bih_fileseq,
                            bih_datetime,
                            bih_filename,
                            bih_filedate,
                            bih_mapid,
                            bih_exe,
                            bih_version,
                            bih_thread,
                            bih_job,
                            bih_host,
                            bih_start,
                            bih_esid)
                (SELECT p_bih_id,
                        map_srctid,
                        p_bih_demo,
                        p_bih_fileseq,
                        SYSDATE,
                        p_bih_filename,
                        TO_DATE (p_bih_filedate, 'YYYY-MM-DD HH24:MI:SS'),
                        p_bih_mapid,
                        p_appname,
                        p_appver,
                        p_thread,
                        p_taskid,
                        p_hostname,
                        SYSDATE,
                        'MAP'
                 FROM   mapping
                 WHERE  map_id = p_bih_mapid);

            UPDATE mapping
            SET    map_datetry = SYSDATE --003SO
            WHERE  map_id = p_bih_mapid;
        END IF;

        RETURN;
    END insert_biheader;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS --009SO
    BEGIN
        insert_biheader (
            p_bih_id,
            p_bih_demo,
            p_bih_fileseq,
            p_bih_filename,
            p_bih_filedate,
            p_bih_mapid,
            p_appname,
            p_appver,
            p_thread,
            p_jobid,
            p_hostname,
            p_status);

        p_returnstatus := pkg_common.return_status_ok;
    EXCEPTION
        WHEN pkg_common.excp_rdy_err_header_found
        THEN
            p_errorcode := pkg_common.eno_rdy_err_header_found;
            p_errordesc := pkg_common.edesc_rdy_err_header_found;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_rdy_err_many_retries
        THEN
            p_errorcode := pkg_common.eno_rdy_err_many_retries;
            p_errordesc := pkg_common.edesc_rdy_err_many_retries;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_inconvenient_time
        THEN
            p_errorcode := pkg_common.eno_inconvenient_time;
            p_errordesc := pkg_common.edesc_inconvenient_time;
            p_returnstatus := pkg_common.return_status_suspended;
    /*
        When others then
            p_ErrorCode := SqlCode;
            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    */
    END sp_insert_header;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION getsrctypeformapping (p_bih_mapid IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (10);
    BEGIN
        SELECT map_srctid
        INTO   l_result
        FROM   mapping
        WHERE  map_id = p_bih_mapid;

        RETURN l_result;
    END getsrctypeformapping;
/* =========================================================================
   Private Procedure Implementation.
   ---------------------------------------------------------------------- */

END pkg_common_mapping;
/