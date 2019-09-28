CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_common
IS
    cmaxtries                               PLS_INTEGER := 3; -- Procedure SP_INSERT_BIHEADER_MEC (for same FileName and FileDate)
    cstrcr                                  VARCHAR2 (1) := CHR (13);
    cstrlf                                  VARCHAR2 (1) := CHR (10);
    cstrmecdatetimeformat                   VARCHAR2 (20) := 'YYYYMMDDHH24MISS'; --032SO
    cstrtab                                 VARCHAR2 (1) := CHR (9);

    /* =========================================================================
      Private Function Declaration.
      ---------------------------------------------------------------------- */

    FUNCTION getheaderfield (
        p_headerdata                            IN VARCHAR2,
        p_token                                 IN VARCHAR2)
        RETURN VARCHAR2;

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION cutfirstitem (
        p_itemlist                              IN OUT VARCHAR2,
        p_separator                             IN     VARCHAR2,
        p_trimitem                              IN     BOOLEAN := TRUE)
        RETURN VARCHAR2
    IS --006SO
        l_retval                                VARCHAR2 (16000); --022SO
        l_pos                                   PLS_INTEGER;
    BEGIN
        l_pos := INSTR (p_itemlist, p_separator);

        IF l_pos > 0
        THEN
            IF p_trimitem
            THEN
                l_retval := RTRIM (SUBSTR (p_itemlist, 1, l_pos - 1));
            ELSE
                l_retval := SUBSTR (p_itemlist, 1, l_pos - 1);
            END IF;

            IF LENGTH (p_itemlist) > l_pos
            THEN
                p_itemlist := RTRIM (SUBSTR (p_itemlist, l_pos + LENGTH (p_separator)));
            ELSE
                p_itemlist := NULL; -- List ends with separator
            END IF;
        ELSE
            IF p_trimitem
            THEN
                l_retval := RTRIM (p_itemlist);
            ELSE
                l_retval := p_itemlist;
            END IF;

            p_itemlist := NULL;
        END IF;

        RETURN l_retval;
    END cutfirstitem;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION duration (p_time_diff IN NUMBER)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (100);
        l_seconds                               NUMBER;
    BEGIN
        l_seconds := p_time_diff * 3600 * 24;

        IF p_time_diff IS NULL
        THEN
            l_retval := NULL;
        ELSIF l_seconds < 60
        THEN
            l_retval := TRIM (TO_CHAR (ROUND (l_seconds, 0))) || ' sec';
        ELSIF l_seconds < 3600
        THEN
            l_retval := TRIM (TO_CHAR (ROUND (l_seconds / 60, 2))) || ' min';
        ELSIF p_time_diff < 1.0
        THEN
            l_retval := TRIM (TO_CHAR (ROUND (l_seconds / 3600, 2))) || ' hrs';
        ELSE
            l_retval := TRIM (TO_CHAR (ROUND (p_time_diff, 2))) || ' days';
        END IF;

        RETURN REPLACE (l_retval, ',', '.');
    END duration;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION generateuniquekey (identifier IN CHAR)
        RETURN VARCHAR2
    IS
        cuniquekey                              VARCHAR2 (10);
    BEGIN
        IF identifier = 'B'
        THEN
            cuniquekey := LPAD (bdetail_seq.NEXTVAL, 10, '0');
        ELSE
            cuniquekey := LPAD (general_seq.NEXTVAL, 10, '0');
        END IF;

        RETURN cuniquekey;
    END generateuniquekey;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION getharderrordesc
        RETURN VARCHAR2
    IS --005SO
        l_error_code                            PLS_INTEGER;
        l_error_desc                            VARCHAR2 (32000);
        l_show_stack                            BOOLEAN := TRUE;
    BEGIN
        l_error_code := SQLCODE;

        IF l_error_code = -14400
        THEN
            l_error_desc := 'ORA' || TO_CHAR (l_error_code) || ' NO_PARTITION';
        ELSIF l_show_stack
        THEN
            l_error_desc := DBMS_UTILITY.format_error_backtrace; --018SO--016SO
        ELSE
            l_error_desc := SQLERRM;
        END IF;

        RETURN l_error_desc;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'CANNOT RESOLVE ERROR MESSAGE';
    END getharderrordesc;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION getrequiredheaderfield (
        p_headerdata                            IN VARCHAR2,
        p_token                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS --007SO
        l_retval                                VARCHAR2 (100);
    BEGIN
        l_retval := getheaderfield (p_headerdata, p_token);

        IF l_retval IS NULL
        THEN
            RAISE excp_missing_header_fld;
        END IF;

        RETURN l_retval;
    END getrequiredheaderfield;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION is_alphanumeric (p_inputvalue IN VARCHAR2)
        RETURN NUMBER
    IS
        l_len                                   NUMBER;
        l_char                                  VARCHAR2 (1);
        l_retval                                NUMBER;
    BEGIN
        l_retval := 1;
        l_len := LENGTH (p_inputvalue);

        FOR i IN 1 .. l_len
        LOOP
            l_char := SUBSTR (p_inputvalue, i, 1);

            IF    (    UPPER (l_char) >= 'A'
                   AND UPPER (l_char) <= 'Z')
               OR (    UPPER (l_char) >= '0'
                   AND UPPER (l_char) <= '9')
               OR (l_char = '_')
            THEN
                NULL; -- still alphanumeric, do nothing
            ELSE
                l_retval := 0; -- exit with error (return value = 0)
            END IF;
        END LOOP;

        RETURN l_retval;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0;
    END is_alphanumeric;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION is_integer (
        p_inputvalue                            IN VARCHAR2,
        p_minvalue                              IN NUMBER DEFAULT NULL,
        p_maxvalue                              IN NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_dummy                                 NUMBER;
    BEGIN
        IF p_inputvalue IS NOT NULL
        THEN
            l_dummy := TO_NUMBER (p_inputvalue); -- will raise an exception if non-numeric

            IF l_dummy < p_minvalue
            THEN
                RETURN 0;
            ELSIF l_dummy > p_maxvalue
            THEN
                RETURN 0;
            ELSIF TRUNC (l_dummy) = l_dummy
            THEN
                IF INSTR (p_inputvalue, '.') > 0
                THEN
                    RETURN 0;
                ELSIF INSTR (UPPER (p_inputvalue), 'E') > 0
                THEN
                    RETURN 0;
                ELSE
                    RETURN 1;
                END IF;
            ELSE
                RETURN 0;
            END IF;
        ELSE
            RETURN 0; --007AA return 0 if null value
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0; -- it is not a number  --002SO
    END is_integer;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION is_numeric (
        p_inputvalue                            IN VARCHAR2,
        p_minvalue                              IN NUMBER DEFAULT NULL,
        p_maxvalue                              IN NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_dummy                                 NUMBER;
    BEGIN
        IF p_inputvalue IS NOT NULL
        THEN
            l_dummy := TO_NUMBER (p_inputvalue); -- will raise an exception if non-numeric

            IF l_dummy < p_minvalue
            THEN
                RETURN 0;
            ELSIF l_dummy > p_maxvalue
            THEN
                RETURN 0;
            ELSE
                RETURN 1;
            END IF;
        ELSE
            RETURN 0; --007AA return 0 if null value
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0; -- it is not a number  --002SO
    END is_numeric;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION isdoneinperiod (
        p_period_id                             IN VARCHAR2,
        p_datedone                              IN DATE)
        RETURN BOOLEAN
    IS --009SO
        bdone                                   BOOLEAN;
        l_last_date                             DATE;
        l_scheduled_date                        DATE;
    BEGIN
        bdone := FALSE;

        IF NVL (p_period_id, 'NONE') <> 'NONE'
        THEN
            -- Check if this processing was alredy done in the current period
            l_last_date := NVL (p_datedone, SYSDATE - 400); -- more than one year back

            IF p_period_id = 'YEARLY'
            THEN
                l_scheduled_date := TRUNC (SYSDATE, 'YEAR');
            ELSIF p_period_id = 'MONTHLY'
            THEN
                l_scheduled_date := TRUNC (SYSDATE, 'MONTH');
            ELSIF p_period_id = 'WEEKLY'
            THEN
                l_scheduled_date := TRUNC (SYSDATE, 'day');
            ELSIF p_period_id = 'DAILY'
            THEN
                l_scheduled_date := TRUNC (SYSDATE);
            ELSIF p_period_id = 'HOURLY'
            THEN
                l_scheduled_date := TRUNC (SYSDATE, 'HH24');
            ELSE
                RETURN bdone;
            END IF;

            bdone := (l_last_date >= l_scheduled_date);
        END IF;

        RETURN bdone;
    END isdoneinperiod;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION istimeforprocess (
        p_period_id                             IN VARCHAR2,
        p_startday                              IN INTEGER,
        p_starthour                             IN INTEGER,
        p_startminute                           IN INTEGER,
        p_endclearance                          IN INTEGER, --010SO
        p_datedone                              IN DATE)
        RETURN BOOLEAN
    IS --008SO
        bgo                                     BOOLEAN;
        l_period_start                          DATE; --010SO
        l_period_end                            DATE; --010SO
        l_last_date                             DATE;
        l_scheduled_date                        DATE;
    BEGIN
        bgo := TRUE;

        -- Check if this is a convenient time for processing according to the schedule
        IF NVL (p_period_id, 'NONE') <> 'NONE'
        THEN
            l_last_date := NVL (p_datedone, SYSDATE - 400); -- more than one year back
            l_period_start := SYSDATE; -- modified below

            IF p_period_id = 'YEARLY'
            THEN
                l_period_start := TRUNC (l_period_start, 'YEAR'); --010SO
                l_period_end := ADD_MONTHS (l_period_start, 12); --010SO
                l_scheduled_date := l_period_start + NVL (p_startday, 1) - 1 + NVL (p_starthour, 0) / 24 + NVL (p_startminute, 0) / 24 / 60;
            ELSIF p_period_id = 'MONTHLY'
            THEN
                l_period_start := TRUNC (l_period_start, 'MONTH'); --010SO
                l_period_end := ADD_MONTHS (l_period_start, 1); --010SO
                l_scheduled_date := l_period_start + NVL (p_startday, 1) - 1 + NVL (p_starthour, 0) / 24 + NVL (p_startminute, 0) / 24 / 60;
            ELSIF p_period_id = 'WEEKLY'
            THEN
                l_period_start := TRUNC (l_period_start, 'day'); --010SO
                l_period_end := l_period_start + 7; --010SO
                l_scheduled_date := l_period_start + NVL (p_startday, 1) - 1 + NVL (p_starthour, 0) / 24 + NVL (p_startminute, 0) / 24 / 60;
            ELSIF p_period_id = 'DAILY'
            THEN
                l_period_start := TRUNC (l_period_start); --010SO
                l_period_end := l_period_start + 1; --010SO
                l_scheduled_date := TRUNC (SYSDATE) + NVL (p_starthour, 0) / 24 + NVL (p_startminute, 0) / 24 / 60;
            ELSIF p_period_id = 'HOURLY'
            THEN
                l_period_start := TRUNC (l_period_start, 'HH24'); --010SO
                l_period_end := l_period_start + 1 / 24; --010SO
                l_scheduled_date := TRUNC (SYSDATE, 'HH24') + NVL (p_startminute, 0) / 24 / 60;
            ELSE
                RETURN bgo;
            END IF;

            bgo :=
                    (l_last_date < l_period_start)
                AND (SYSDATE >= l_scheduled_date)
                AND (SYSDATE < l_period_end - NVL (p_endclearance, 0) / 24 / 3600); --019SO was l_scheduled_date --014SO  --010SO
        END IF;

        RETURN bgo;
    END istimeforprocess;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION sp_is_numeric (p_inputvalue IN VARCHAR2)
        RETURN NUMBER
    IS
        l_dummy                                 PLS_INTEGER;
    BEGIN
        IF p_inputvalue IS NOT NULL
        THEN
            l_dummy := TO_NUMBER (p_inputvalue); -- will raise an exception if non-numeric
            RETURN 1; -- it is a number
        ELSE
            RETURN 0; --007AA return 0 if null value
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0; -- it is not a number  --002SO
    END sp_is_numeric;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION speed (
        bih_reccount                            IN NUMBER,
        bih_start                               IN DATE,
        bih_end                                 IN DATE)
        RETURN NUMBER
    IS
    BEGIN
        IF bih_end IS NULL
        THEN
            RETURN NULL;
        ELSIF bih_start IS NULL
        THEN
            RETURN NULL;
        ELSIF bih_end = bih_start
        THEN
            RETURN TRUNC (bih_reccount);
        ELSE
            RETURN TRUNC (bih_reccount / ((bih_end - bih_start) * 24 * 3600));
        END IF;
    END speed;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    PROCEDURE compile_all
    IS --003SO
        CURSOR invalid_objects (code_owner IN VARCHAR2)
        IS
            SELECT   DECODE (
                         object_type,
                         'PACKAGE BODY', 'alter package ' || owner || '.' || object_name || ' compile body',
                         'alter ' || object_type || ' ' || owner || '.' || object_name || ' compile')    AS compile_sql
            FROM     all_objects               a,
                     order_object_by_dependency b
            WHERE        a.object_id = b.object_id(+)
                     AND a.status = 'INVALID'
                     AND a.owner IN (code_owner,
                                     USER)
                     -- AND    A.object_name not like 'SIS_SUBSCRIBER%'
                     -- AND    A.object_name not like 'SIS_MSISDN%'
                     AND a.object_type IN ('PACKAGE BODY',
                                           'PACKAGE',
                                           'FUNCTION',
                                           'PROCEDURE',
                                           'TRIGGER',
                                           'VIEW')
            ORDER BY b.dlevel DESC,
                     a.object_type ASC,
                     a.object_name ASC; --024SO

        --020SO

        v_ddl                                   VARCHAR2 (4000);
        v_code_owner                            VARCHAR2 (32);
    BEGIN
        SELECT owner
        INTO   v_code_owner
        FROM   all_objects
        WHERE      object_name = 'PKG_COMMON'
               AND object_type = 'PACKAGE BODY';

        FOR io_row IN invalid_objects (v_code_owner)
        LOOP
            BEGIN
                v_ddl := io_row.compile_sql;

                EXECUTE IMMEDIATE v_ddl;
            EXCEPTION
                WHEN OTHERS
                THEN
                    sbsdb_error_lib.LOG (SQLCODE, 'CANNOT EXECUTE', '(ORA' || TO_CHAR (SQLCODE) || ')  **** ' || v_ddl, sbsdb_logger_lib.scope ($$plsql_unit, 'compile_all'));
                    sys.DBMS_LOCK.sleep (10);
            END;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (SQLCODE, 'CANNOT QUERY INVALID_OBJECTS: ' || SQLERRM, sbsdb_logger_lib.scope ($$plsql_unit, 'compile_all'));
    END compile_all;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    PROCEDURE getdatesforperiod (
        p_period_id                             IN     VARCHAR2,
        p_period_start                             OUT DATE,
        p_period_end                               OUT DATE)
    IS --015SO
    BEGIN
        IF NVL (p_period_id, 'NONE') <> 'NONE'
        THEN
            p_period_end := SYSDATE; -- modified below                        --017SO

            IF p_period_id = 'YEARLY'
            THEN
                p_period_end := TRUNC (p_period_end, 'YEAR'); --017SO
                p_period_start := ADD_MONTHS (p_period_end, -12); --017SO
            ELSIF p_period_id = 'MONTHLY'
            THEN
                p_period_end := TRUNC (p_period_end, 'MONTH'); --017SO
                p_period_start := ADD_MONTHS (p_period_end, -1); --017SO
            ELSIF p_period_id = 'WEEKLY'
            THEN
                p_period_end := TRUNC (p_period_end, 'day'); --017SO
                p_period_start := p_period_end - 7; --017SO
            ELSIF p_period_id = 'DAILY'
            THEN
                p_period_end := TRUNC (p_period_end); --017SO
                p_period_start := p_period_end - 1; --017SO
            ELSIF p_period_id = 'HOURLY'
            THEN
                p_period_end := TRUNC (p_period_end, 'HH24'); --017SO
                p_period_start := p_period_end - 1 / 24; --017SO
            ELSE
                p_period_end := NULL;
            END IF;
        END IF;
    END getdatesforperiod;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    PROCEDURE insert_warning (
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_bihid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN VARCHAR2 DEFAULT NULL,
        p_w_usererrcode                         IN VARCHAR2 DEFAULT NULL --002SO
                                                                        )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO warning (
                        w_id,
                        w_datetime,
                        w_applic,
                        w_topic,
                        w_procedure,
                        w_message,
                        w_errortime,
                        w_bihid,
                        w_bohid,
                        w_bdid,
                        w_shortid,
                        w_errorcode)
        VALUES      (
            generateuniquekey ('G'),
            SYSDATE,
            p_w_applic,
            p_w_topic,
            p_w_procedure,
            SUBSTR (p_w_message, 1, 4000),
            SYSDATE,
            p_w_bihid,
            p_w_bohid,
            p_w_bdid,
            p_w_shortid,
            p_w_usererrcode);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END insert_warning;

    /* =========================================================================
       Log event to LOG_DEBUG table.
       ---------------------------------------------------------------------- */

    PROCEDURE l (
        logline                                 IN VARCHAR2,
        hint                                    IN VARCHAR2 DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO log_debug (
                        ldb_linecnt,
                        ldb_time,
                        ldb_debugstr,
                        ldb_hint)
        VALUES      (
            test_seq.NEXTVAL,
            SYSDATE,
            logline,
            hint);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END l;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    PROCEDURE lb (
        logline                                 IN VARCHAR2,
        hint                                    IN BOOLEAN)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_result                                VARCHAR2 (10);
    BEGIN
        IF hint IS NULL
        THEN
            l_result := NULL;
        ELSIF hint
        THEN
            l_result := 'TRUE';
        ELSE
            l_result := 'FALSE';
        END IF;

        INSERT INTO log_debug (
                        ldb_linecnt,
                        ldb_time,
                        ldb_debugstr,
                        ldb_hint)
        VALUES      (
            test_seq.NEXTVAL,
            SYSDATE,
            logline,
            l_result);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END lb;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    PROCEDURE sp_db_sleep (
        p_pac_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN OUT VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --013SO
    BEGIN
        DBMS_LOCK.sleep (10);

        recordsaffected := 0;
        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            recordsaffected := 0;
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_db_sleep;

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_warning (
        p_w_applic                              IN     VARCHAR2,
        p_w_procedure                           IN     VARCHAR2,
        p_w_topic                               IN     VARCHAR2,
        p_w_message                             IN     VARCHAR2,
        p_w_bihid                               IN     VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN     VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN     VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN     VARCHAR2 DEFAULT NULL,
        p_w_usererrcode                         IN     VARCHAR2 DEFAULT NULL, --002SO
        p_errorcode                                OUT NUMBER,
        p_errormsg                                 OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
    BEGIN
        insert_warning (
            p_w_applic,
            p_w_procedure,
            p_w_topic,
            p_w_message,
            p_w_bihid,
            p_w_bohid,
            p_w_bdid,
            p_w_shortid,
            p_w_usererrcode --002SO
                           );
        p_errorcode := NULL;
        p_errormsg := NULL;
        p_returnstatus := return_status_ok;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errormsg := SQLERRM;
            p_returnstatus := return_status_failure;
    END sp_insert_warning;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO
       ---------------------------------------------------------------------- */

    FUNCTION getheaderfield (
        p_headerdata                            IN VARCHAR2,
        p_token                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS --007SO
        l_retval                                VARCHAR2 (100);
        l_headerdata                            VARCHAR2 (4000);
        l_headerline                            VARCHAR2 (4000);
    BEGIN
        l_retval := NULL;
        l_headerdata := p_headerdata;

        LOOP
            l_headerline := pkg_common.cutfirstitem (l_headerdata, '<br>', TRUE);

            IF l_headerline LIKE p_token || cstrtab || '%'
            THEN
                l_retval := SUBSTR (l_headerline, LENGTH (p_token) + 2);
                EXIT;
            END IF;

            EXIT WHEN l_headerdata IS NULL;
        END LOOP;

        RETURN l_retval;
    END getheaderfield;
END pkg_common;
/