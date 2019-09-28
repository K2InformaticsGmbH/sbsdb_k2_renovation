SET DEFINE OFF;

CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_bdetail_common
IS
    -- Source Type
    TYPE tsrctype IS RECORD
    (
        ccndc srctype.srct_id%TYPE := 'CCNDC', --013DA
        isrv srctype.srct_id%TYPE := 'ISRV',
        mca_aud srctype.srct_id%TYPE := 'MCA_AUD', --013DA
        mca_img srctype.srct_id%TYPE := 'MCA_IMG', --013DA
        mca_mm1 srctype.srct_id%TYPE := 'MCA_MM1', --013DA
        mca_mm3 srctype.srct_id%TYPE := 'MCA_MM3', --013DA
        mca_sti srctype.srct_id%TYPE := 'MCA_STI', --013DA
        mca_vid srctype.srct_id%TYPE := 'MCA_VID', --013DA
        mccmnc srctype.srct_id%TYPE := 'MCCMNC', --013DA
        mmsc srctype.srct_id%TYPE := 'MMSC',
        msc srctype.srct_id%TYPE := 'MSC',
        oper srctype.srct_id%TYPE := 'OPER', --013DA: OPER may be removed if checked
        pos srctype.srct_id%TYPE := 'POS',
        smsc srctype.srct_id%TYPE := 'SMSC',
        stan srctype.srct_id%TYPE := 'STAN', --012SO
        vasp srctype.srct_id%TYPE := 'VASP'
    );

    -- Mapping States
    TYPE tmapesid IS RECORD
    (
        error mapstate.maps_id%TYPE := 'E',
        ignore mapstate.maps_id%TYPE := 'I',
        mapnoset mapstate.maps_id%TYPE := 'm',
        mapping mapstate.maps_id%TYPE := 'M',
        ready mapstate.maps_id%TYPE := 'R'
    );

    -- (Billing/Handler) Input Header States
    TYPE tihesid IS RECORD
    (
        errorinfile bihstate.bihs_id%TYPE := 'ERF',
        errorinrec bihstate.bihs_id%TYPE := 'ERR',
        indexed bihstate.bihs_id%TYPE := 'IDX',
        mapping bihstate.bihs_id%TYPE := 'MAP',
        ready bihstate.bihs_id%TYPE := 'RDY'
    );

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Return IOT for a given
              - Telecom Operator Contract,
              - direction ('ORIG','TERM'),
              - transport medium ('SMS','MMS'), and
              - message size.
       ---------------------------------------------------------------------- */

    FUNCTION contract_iot_chf (
        p_con_id                                IN VARCHAR2,
        p_iwdid                                 IN coniot.ciot_iwdid%TYPE,
        p_trctid                                IN coniot.ciot_trctid%TYPE,
        p_date                                  IN DATE DEFAULT NULL,
        p_msgsize                               IN coniote.ciote_msgsize_max%TYPE DEFAULT 0)
        RETURN coniote.ciote_price%TYPE
    IS
        CURSOR csmsprice IS
            SELECT ciote_price * exr_value / cur_headval     AS price
            FROM   coniot,
                   coniote,
                   currency,
                   exchangerate
            WHERE      coniot.ciot_id = coniote.ciote_ciotid
                   AND ciot_trctid = p_trctid
                   AND ciot_iwdid = p_iwdid
                   AND ciot_conid = p_con_id
                   AND cur_id = NVL (ciot_curid, 'CHF')
                   AND exr_curid = cur_id
                   AND exr_start <= NVL (p_date, SYSDATE)
                   AND exr_end > NVL (p_date, SYSDATE); -- 002SO

        CURSOR cmmsprice IS
            SELECT   ciote_price * exr_value / cur_headval     AS price
            FROM     coniot,
                     coniote,
                     currency,
                     exchangerate
            WHERE        coniot.ciot_id = coniote.ciote_ciotid
                     AND ciot_trctid = p_trctid
                     AND ciot_iwdid = p_iwdid
                     AND ciot_conid = p_con_id
                     AND p_msgsize / 1024 < ciote_msgsize_max
                     AND cur_id = NVL (ciot_curid, 'CHF')
                     AND exr_curid = cur_id
                     AND exr_start <= NVL (p_date, SYSDATE)
                     AND exr_end > NVL (p_date, SYSDATE)
            ORDER BY ciote_msgsize_max ASC; -- 002SO

        l_price                                 NUMBER (10, 4);
    BEGIN
        l_price := NULL;

        IF p_trctid = 'SMS'
        THEN
            FOR crow IN csmsprice
            LOOP
                l_price := crow.price;
            END LOOP;
        ELSE
            FOR crow IN cmmsprice
            LOOP
                l_price := crow.price;
                EXIT; -- 002SO first price
            END LOOP;
        END IF;

        RETURN l_price;
    END contract_iot_chf;

    /* =========================================================================
       Gets end date of contract in last month.
       ---------------------------------------------------------------------- */

    FUNCTION contractperiodend (p_con_dateend IN DATE)
        RETURN DATE
    IS
        x_periodstartdate                       DATE;
        x_periodenddate                         DATE;
    BEGIN
        x_periodstartdate := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1);
        x_periodenddate := TRUNC (SYSDATE, 'MONTH');

        IF p_con_dateend IS NULL
        THEN
            RETURN x_periodenddate;
        ELSIF p_con_dateend <= x_periodstartdate
        THEN
            RETURN NULL;
        ELSIF p_con_dateend <= x_periodenddate
        THEN
            RETURN p_con_dateend;
        ELSE
            RETURN x_periodenddate;
        END IF;
    END contractperiodend;

    /* =========================================================================
       Gets start date of contract in last month.
       ---------------------------------------------------------------------- */

    FUNCTION contractperiodstart (p_con_datestart IN DATE)
        RETURN DATE
    IS
        x_periodstartdate                       DATE;
        x_periodenddate                         DATE;
    BEGIN
        x_periodstartdate := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1);
        x_periodenddate := TRUNC (SYSDATE, 'MONTH');

        IF p_con_datestart IS NULL
        THEN
            RETURN x_periodstartdate;
        ELSIF p_con_datestart < x_periodstartdate
        THEN
            RETURN x_periodstartdate;
        ELSIF p_con_datestart < x_periodenddate
        THEN
            RETURN p_con_datestart;
        ELSE
            RETURN NULL;
        END IF;
    END contractperiodstart;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION generatebase36kpikey
        RETURN VARCHAR2
    IS
        result                                  VARCHAR2 (10);
        charlist                                VARCHAR2 (36) DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        remainnum                               PLS_INTEGER;
    BEGIN
        remainnum := bdkpi_seq.NEXTVAL;

        WHILE remainnum != 0
        LOOP
            result := SUBSTR (charlist, MOD (remainnum, 36) + 1, 1) || result;
            remainnum := TRUNC (remainnum / 36);
        END LOOP;

        WHILE LENGTH (result) < 10
        LOOP
            result := '0' || result;
        END LOOP;

        RETURN result;
    END generatebase36kpikey;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION gettypeformapping (p_bih_mapid IN VARCHAR2)
        RETURN VARCHAR2
    IS --023SO
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

    FUNCTION gettypeforpacking (p_bih_pacid IN VARCHAR2)
        RETURN VARCHAR2
    IS --023SO
        l_result                                VARCHAR2 (10);
    BEGIN
        SELECT pac_etid
        INTO   l_result
        FROM   packing
        WHERE  pac_id = p_bih_pacid;

        RETURN l_result;
    END gettypeforpacking;

    /* =========================================================================
       Utility function to be used in SQL.
       ---------------------------------------------------------------------- */

    FUNCTION getufihfield (
        p_token                                 IN VARCHAR2,
        p_cdrtext                               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        pos1                                    PLS_INTEGER;
        pos2                                    PLS_INTEGER;
    BEGIN
        IF p_token IN ('F4',
                       'F8',
                       'F9',
                       'F13',
                       'F21',
                       'F22',
                       'F24',
                       'F28',
                       'F30',
                       'F32',
                       'F33',
                       'F58')
        THEN
            -- search for string field
            pos1 := INSTR (p_cdrtext, p_token || '='''); -- start of token

            IF pos1 > 0
            THEN
                pos1 := pos1 + LENGTH (p_token) + 2; -- start of value
                pos2 := INSTR (p_cdrtext, ''',', pos1); -- pos of ',

                IF pos2 > 0
                THEN
                    RETURN SUBSTR (p_cdrtext, pos1, pos2 - pos1);
                ELSE
                    pos2 := INSTR (p_cdrtext, '''}', pos1); -- pos of '}

                    IF pos2 > 0
                    THEN
                        RETURN SUBSTR (p_cdrtext, pos1, pos2 - pos1);
                    ELSE
                        RETURN NULL;
                    END IF;
                END IF;
            ELSE
                RETURN NULL;
            END IF;
        ELSE
            pos1 := INSTR (p_cdrtext, p_token || '='); -- start of token

            IF pos1 > 0
            THEN
                pos1 := pos1 + LENGTH (p_token) + 1; -- start of value
                pos2 := INSTR (p_cdrtext, ',', pos1); -- pos of ,

                IF pos2 > 0
                THEN
                    IF p_token IN ('F17',
                                   'F19',
                                   'F54',
                                   'F56')
                    THEN
                        RETURN REPLACE (SUBSTR (p_cdrtext, pos1, pos2 - pos1), '@', '');
                    ELSE
                        RETURN SUBSTR (p_cdrtext, pos1, pos2 - pos1);
                    END IF;
                ELSE
                    pos2 := INSTR (p_cdrtext, '}', pos1); -- pos of }

                    IF pos2 > 0
                    THEN
                        IF p_token IN ('F17',
                                       'F19',
                                       'F54',
                                       'F56')
                        THEN
                            RETURN REPLACE (SUBSTR (p_cdrtext, pos1, pos2 - pos1), '@', '');
                        ELSE
                            RETURN SUBSTR (p_cdrtext, pos1, pos2 - pos1);
                        END IF;
                    ELSE
                        RETURN NULL;
                    END IF;
                END IF;
            ELSE
                RETURN NULL;
            END IF;
        END IF;
    END getufihfield;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION istimeformapping (p_bih_mapid IN VARCHAR2)
        RETURN INTEGER
    IS --020SO
        CURSOR cinconvenienttime IS
            SELECT map_execute,
                   map_conditionalexec
            FROM   mapping
            WHERE  map_id = p_bih_mapid; --020SO

        cinconvenienttimerow                    cinconvenienttime%ROWTYPE;

        TYPE tcurdef IS REF CURSOR;

        cvcurvar                                tcurdef;
        l_sql                                   VARCHAR2 (4000);
        bgo                                     BOOLEAN;
        vgo                                     VARCHAR2 (4000);
    BEGIN
        bgo := FALSE;

        -- Check if this is a convenient time for processing
        FOR cinconvenienttimerow IN cinconvenienttime
        LOOP
            IF cinconvenienttimerow.map_execute = 1
            THEN
                IF cinconvenienttimerow.map_conditionalexec IS NULL
                THEN
                    bgo := TRUE; --024SO
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
                        THEN --022SO
                            bgo := FALSE; -- execpt if it is 0 or false or no
                        END IF;
                    END IF;

                    CLOSE cvcurvar;
                END IF;
            END IF;
        END LOOP;

        IF bgo
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END istimeformapping;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION istimeforpacking (p_bih_pacid IN VARCHAR2)
        RETURN INTEGER
    IS --020SO
        CURSOR cinconvenienttime IS
            SELECT pac_execute,
                   pac_conditionalexec
            FROM   packing
            WHERE  pac_id = p_bih_pacid; --020SO

        cinconvenienttimerow                    cinconvenienttime%ROWTYPE;

        TYPE tcurdef IS REF CURSOR;

        cvcurvar                                tcurdef;
        l_sql                                   VARCHAR2 (4000);
        bgo                                     BOOLEAN;
        vgo                                     VARCHAR2 (4000);
    BEGIN
        bgo := FALSE;

        -- Check if this is a convenient time for processing
        FOR cinconvenienttimerow IN cinconvenienttime
        LOOP
            IF cinconvenienttimerow.pac_execute = 1
            THEN
                IF cinconvenienttimerow.pac_conditionalexec IS NULL
                THEN
                    bgo := TRUE; --024SO
                ELSE
                    IF SUBSTR (UPPER (cinconvenienttimerow.pac_conditionalexec), 1, 6) = 'SELECT'
                    THEN
                        -- must check a condition sql
                        l_sql := cinconvenienttimerow.pac_conditionalexec;
                    ELSE
                        -- condition view or table name given
                        l_sql := 'SELECT  * FROM ' || cinconvenienttimerow.pac_conditionalexec;
                    END IF;

                    OPEN cvcurvar FOR l_sql;

                    FETCH cvcurvar INTO vgo; -- ignore result

                    bgo := cvcurvar%FOUND; -- any result is a GO

                    IF bgo
                    THEN
                        IF UPPER (NVL (TRIM (vgo), 'FALSE')) IN ('FALSE',
                                                                 '0',
                                                                 'NO')
                        THEN --022SO
                            bgo := FALSE; -- execpt if it is 0 or false or no
                        END IF;
                    END IF;

                    CLOSE cvcurvar;
                END IF;
            END IF;
        END LOOP;

        IF bgo
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END istimeforpacking;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION normalizedmsisdn (msisdn IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF msisdn LIKE '+%'
        THEN
            RETURN SUBSTR (msisdn, 2);
        ELSIF LENGTH (msisdn) < 9
        THEN
            RETURN msisdn;
        ELSIF LENGTH (msisdn) >= 19
        THEN
            RETURN msisdn;
        ELSIF INSTR (msisdn, 'A') > 0
        THEN
            RETURN msisdn;
        ELSIF INSTR (msisdn, 'B') > 0
        THEN
            RETURN msisdn;
        ELSIF INSTR (msisdn, 'C') > 0
        THEN
            RETURN msisdn;
        ELSIF INSTR (msisdn, 'D') > 0
        THEN
            RETURN msisdn;
        ELSIF INSTR (msisdn, 'E') > 0
        THEN
            RETURN msisdn;
        ELSIF INSTR (msisdn, 'F') > 0
        THEN
            RETURN msisdn;
        ELSIF msisdn LIKE '00%'
        THEN
            RETURN SUBSTR (msisdn, 3);
        ELSIF msisdn LIKE '0%'
        THEN
            RETURN '41' || SUBSTR (msisdn, 2);
        ELSIF     (pkg_common.sp_is_numeric (msisdn) = 1)
              AND (LENGTH (msisdn) = 9)
        THEN
            RETURN '41' || msisdn;
        ELSE
            RETURN msisdn;
        END IF; -- 001SO
    END normalizedmsisdn;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION simplehash (s IN VARCHAR2)
        RETURN NUMBER
    IS
        h                                       NUMBER;
        i                                       PLS_INTEGER;
    BEGIN
        h := 0;

        IF LENGTH (s) > 0
        THEN
           <<loop_length>>
            FOR i IN 1 .. LENGTH (s)
            LOOP
                h := h + i * ASCII (SUBSTR (s, i, 1));
            END LOOP loop_length;
        END IF;

        RETURN h;
    END simplehash;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_warning (
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_usererrcode                         IN VARCHAR2 DEFAULT NULL,
        p_w_bihid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN VARCHAR2 DEFAULT NULL)
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
                        p_w_message,
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
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_next_pac_seq (
        p_pacid                                 IN     VARCHAR2,
        p_nextsequence                             OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errormsg                                 OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER)
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
    BEGIN
        OPEN cpackingsequence;

        FETCH cpackingsequence INTO cpackingsequencerow;

        IF cpackingsequence%FOUND
        THEN
            l_nextsequence := cpackingsequencerow.pac_nextseq;
            l_nextsequence := MOD (l_nextsequence, cpackingsequencerow.pac_fileseqmax + 1);
            p_nextsequence := TRIM (TO_CHAR (l_nextsequence, REPLACE (TRIM (TO_CHAR (cpackingsequencerow.pac_fileseqmax)), '9', '0')));
            l_nextsequence := l_nextsequence + 1;

            IF l_nextsequence > cpackingsequencerow.pac_fileseqmax
            THEN
                l_nextsequence := 1;
            END IF;

            UPDATE packing
            SET    pac_nextseq = l_nextsequence
            WHERE  CURRENT OF cpackingsequence;
        END IF;

        CLOSE cpackingsequence;

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

    PROCEDURE sp_insert_biheader (
        p_bih_id                                IN     VARCHAR2,
        p_bih_srctype                           IN     VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_status                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --031SO
    BEGIN
        INSERT INTO biheader (
                        bih_id,
                        bih_srctype,
                        bih_demo,
                        bih_fileseq,
                        bih_datetime,
                        bih_filename,
                        bih_filedate,
                        bih_mapid,
                        bih_start,
                        bih_esid)
        VALUES      (
                        p_bih_id,
                        p_bih_srctype,
                        p_bih_demo,
                        p_bih_fileseq,
                        SYSDATE,
                        p_bih_filename,
                        TO_DATE (p_bih_filedate, 'YYYY-MM-DD HH24:MI:SS'),
                        p_bih_mapid,
                        SYSDATE,
                        'MAP');

        -- commit;    -- $$$
        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_biheader;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    --006AA
    PROCEDURE sp_insert_biheader (
        p_bih_id                                IN     VARCHAR2,
        p_bih_srctype                           IN     VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --031SO
    BEGIN
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
                        bih_job,
                        bih_host,
                        bih_start,
                        bih_esid)
        VALUES      (
                        p_bih_id,
                        p_bih_srctype,
                        p_bih_demo,
                        p_bih_fileseq,
                        SYSDATE,
                        p_bih_filename,
                        TO_DATE (p_bih_filedate, 'YYYY-MM-DD HH24:MI:SS'),
                        p_bih_mapid,
                        p_appname,
                        p_appver,
                        p_jobid,
                        p_hostname,
                        SYSDATE,
                        'MAP');

        -- commit;    -- $$$
        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_biheader;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_biheader_mec (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2, --025SO
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER --026SO
                                                             )
    IS --030SO
    BEGIN
        IF istimeformapping (p_bih_mapid) = 1
        THEN
            IF p_bih_id IS NULL
            THEN
                p_bih_id := generateuniquekey ('G'); --021SO
            END IF;

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
                            bih_thread, --025SO
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
                        p_appver, --025SO
                        p_thread,
                        p_jobid,
                        p_hostname,
                        SYSDATE,
                        'MAP'
                 FROM   mapping
                 WHERE  map_id = p_bih_mapid);

            returnstatus := 1;
        ELSE
            returnstatus := 2;
        END IF;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_biheader_mec;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    --006AA
    PROCEDURE sp_insert_boheader (
        p_boh_id                                IN     VARCHAR2,
        p_boh_demo                              IN     NUMBER,
        p_boh_fileseq                           IN     NUMBER,
        p_boh_filename                          IN     VARCHAR2,
        p_boh_packid                            IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
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
                        boh_job,
                        boh_host)
        VALUES      (
                        p_boh_id,
                        p_boh_demo,
                        p_boh_fileseq,
                        SYSDATE,
                        p_boh_filename,
                        SYSDATE,
                        'PAC',
                        SYSDATE,
                        p_boh_packid,
                        p_appname,
                        p_appver,
                        p_jobid,
                        p_hostname);

        -- commit; -- $$
        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_boheader;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_boheader (
        p_boh_id                                IN     VARCHAR2,
        p_boh_demo                              IN     NUMBER,
        p_boh_fileseq                           IN     NUMBER,
        p_boh_filename                          IN     VARCHAR2,
        p_boh_packid                            IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --031SO
    BEGIN
        INSERT INTO boheader (
                        boh_id,
                        boh_demo,
                        boh_fileseq,
                        boh_datetime,
                        boh_filename,
                        boh_start,
                        boh_esid,
                        boh_filedate,
                        boh_packid)
        VALUES      (
                        p_boh_id,
                        p_boh_demo,
                        p_boh_fileseq,
                        SYSDATE,
                        p_boh_filename,
                        SYSDATE,
                        'PAC',
                        SYSDATE,
                        p_boh_packid);

        -- commit; -- $$
        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_boheader;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_boheader_mec (
        p_boh_id                                IN OUT VARCHAR2,
        p_boh_demo                              IN     NUMBER,
        p_boh_fileseq                           IN     NUMBER,
        p_boh_filename                          IN     VARCHAR2,
        p_boh_packid                            IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2, --025SO
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER --026SO
                                                             )
    IS --030SO
    BEGIN
        IF istimeforpacking (p_boh_packid) = 1
        THEN
            IF p_boh_id IS NULL
            THEN
                p_boh_id := generateuniquekey ('G'); --021SO
            END IF;

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
                            boh_thread, --025SO
                            boh_job,
                            boh_host)
            VALUES      (
                            p_boh_id,
                            p_boh_demo,
                            p_boh_fileseq,
                            SYSDATE,
                            p_boh_filename,
                            SYSDATE,
                            'PAC',
                            SYSDATE,
                            p_boh_packid,
                            p_appname,
                            p_appver,
                            p_thread, --025SO
                            p_jobid,
                            p_hostname);

            returnstatus := 1;
        ELSE
            returnstatus := 2;
        END IF;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_boheader_mec;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_warning (
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_bihid                               IN VARCHAR2,
        p_w_bohid                               IN VARCHAR2,
        p_w_bdid                                IN VARCHAR2,
        p_w_shortid                             IN VARCHAR2)
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
                        w_shortid)
        VALUES      (
                        pkg_common.generateuniquekey ('G'),
                        SYSDATE,
                        p_w_applic,
                        p_w_topic,
                        p_w_procedure,
                        SUBSTR (p_w_message, 1, 4000), --017SO--019DA
                        SYSDATE,
                        p_w_bihid,
                        p_w_bohid,
                        p_w_bdid,
                        p_w_shortid);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END sp_insert_warning;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_warning (
        p_w_applic                              IN     VARCHAR2,
        p_w_procedure                           IN     VARCHAR2,
        p_w_topic                               IN     VARCHAR2,
        p_w_message                             IN     VARCHAR2,
        p_w_bihid                               IN     VARCHAR2,
        p_w_bohid                               IN     VARCHAR2,
        p_w_bdid                                IN     VARCHAR2,
        p_w_shortid                             IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
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
                        w_shortid)
        VALUES      (
                        generateuniquekey ('G'),
                        SYSDATE,
                        p_w_applic,
                        p_w_topic,
                        p_w_procedure,
                        SUBSTR (p_w_message, 1, 4000), --017SO--019DA
                        SYSDATE,
                        p_w_bihid,
                        p_w_bohid,
                        p_w_bdid,
                        p_w_shortid);

        COMMIT;

        returnstatus := 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_insert_warning;

    /* =========================================================================
       Update begin- and end-dates of daylight saving time (summer-time) in
       table SYSPARAMETERS.

       These dates are replicated to the instance and used there for
       calculating UTC offset values and for converting UTC time to local time.
       Based on Swiss federal Law SR 941.299.1 Art. 2 Beginn und Ende (Sommerzeitverordnung)
       ---------------------------------------------------------------------- */

    PROCEDURE sp_update_dls_dates (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        l_recordsaffected                       NUMBER;
        l_datestart                             DATE;
        l_dateend                               DATE;
        l_sundayweekdaycode                     CHAR (1) := '7'; --010SO
    BEGIN
        l_recordsaffected := 0;

        SELECT sys_dlsstart INTO l_datestart FROM sysparameters;

        -- Switch to summer time on last sunday in March 02:00
        -- New Year + 3 months - 1 day = 31 st of March                             --025SO
        l_datestart := ADD_MONTHS (TRUNC (SYSDATE, 'YEAR'), 3) - 1 + 2 / 24; --025SO

        WHILE TO_CHAR (l_datestart, 'D') <> l_sundayweekdaycode
        LOOP
            l_datestart := l_datestart - 1;
        END LOOP;

        -- Switch back to winter time on last sunday in october 03:00
        -- New Year + 10 months - 1 day = 31 st of October                          --025SO
        l_dateend := ADD_MONTHS (TRUNC (SYSDATE, 'YEAR'), 10) - 1 + 3 / 24; --025SO

        WHILE TO_CHAR (l_dateend, 'D') <> l_sundayweekdaycode
        LOOP
            l_dateend := l_dateend - 1;
        END LOOP;

        UPDATE sysparameters
        SET    sys_dlsstart = l_datestart,
               sys_dlsend = l_dateend;

        recordsaffected := 1;
        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
            recordsaffected := 0;
            ROLLBACK;
    END sp_update_dls_dates;
END pkg_bdetail_common;
/