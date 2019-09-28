CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_mec_oc
IS
    cstrtab                                 VARCHAR2 (1) := CHR (9);
 
    cstrcomma                               VARCHAR2 (1) := ',';
    cstrcr                                  VARCHAR2 (1) := CHR (13);
    cstrfieldseparator                      VARCHAR2 (1) := cstrtab;
    cstrlf                                  VARCHAR2 (1) := CHR (10);
    cstrmecdatetimeformat                   VARCHAR2 (20) := 'YYYYMMDDHH24MISS';
    cstrsemicolon                           VARCHAR2 (1) := ';';
    rheaderstate                            pkg_common_packing.tboheaderesid;
    rpackingstate                           pkg_common_packing.tpackingstateid;
    rsourcetype                             pkg_common.tsrctype;

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Return concatenated eMail adresses for BN-Statistics for given AC_ID.
       ---------------------------------------------------------------------- */

    FUNCTION bn_stats_emails (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cemails IS
            SELECT ac_bn_stats_emails     AS adr_email
            FROM   account
            WHERE  ac_id = p_ac_id; -- 002SO

        l_retval                                VARCHAR2 (4000); -- 003SO
    BEGIN
        l_retval := NULL;

        OPEN cemails;

        FETCH cemails INTO l_retval;

        CLOSE cemails;

        RETURN l_retval;
    END bn_stats_emails;

    /* =========================================================================
       Used for evaluation of main eMail-Adress of Job.
       ---------------------------------------------------------------------- */

    FUNCTION job_adrid_main_email (p_job_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (100);
        l_looptype                              VARCHAR2 (10);
        l_loopvar                               VARCHAR2 (10);
    BEGIN
        l_retval := NULL;

        SELECT pac_ltid,
               staj_ltvalue
        INTO   l_looptype,
               l_loopvar
        FROM   sta_job,
               packing
        WHERE      sta_job.staj_pacid = packing.pac_id
               -- AND     STAJ_PACID = 'SL087a'
               AND staj_id = p_job_id;

        IF l_looptype = 'AC_ID'
        THEN
            SELECT adr_email
            INTO   l_retval
            FROM   account,
                   address
            WHERE      account.ac_adrid_main = address.adr_id
                   AND ac_id = l_loopvar;
        ELSIF l_looptype = 'CON_ID'
        THEN
            SELECT adr_email
            INTO   l_retval
            FROM   account,
                   address,
                   contract
            WHERE      account.ac_adrid_main = address.adr_id
                   AND ac_id = con_acid
                   AND con_id = l_loopvar;
        END IF;

        RETURN l_retval;
    END job_adrid_main_email;

    /* =========================================================================
       Return concatenated eMail adresses for BN-Statistics for given statistics
       job.
       ---------------------------------------------------------------------- */

    FUNCTION job_bn_stats_emails (p_job_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (1000);
        l_looptype                              VARCHAR2 (10);
        l_loopvar                               VARCHAR2 (10);
        l_acid                                  VARCHAR2 (10);
    BEGIN
        l_retval := NULL;

        SELECT pac_ltid,
               staj_ltvalue
        INTO   l_looptype,
               l_loopvar
        FROM   sta_job,
               packing
        WHERE      sta_job.staj_pacid = packing.pac_id
               AND staj_id = p_job_id;

        IF l_looptype = 'AC_ID'
        THEN
            l_retval := bn_stats_emails (l_loopvar);
        ELSIF l_looptype = 'CON_ID'
        THEN
            SELECT con_acid
            INTO   l_acid
            FROM   contract
            WHERE  con_id = l_loopvar;

            l_retval := bn_stats_emails (l_acid);
        END IF;

        RETURN l_retval;
    END job_bn_stats_emails;

    /* =========================================================================
       Used for evaluation of BOH_ID belonging to the statistic executor.
       ---------------------------------------------------------------------- */

    FUNCTION job_bohidexec (p_job_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (10);
    BEGIN
        SELECT staj_bohidexec
        INTO   l_retval
        FROM   sta_job
        WHERE  staj_id = p_job_id;

        RETURN l_retval;
    END job_bohidexec;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_datefrom (p_job_id IN VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (job_parameter (p_job_id, '[DATEFROM]'), 'dd.mm.yyyy hh24:mi:ss');
    END job_datefrom;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_datetill (p_job_id IN VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (job_parameter (p_job_id, '[DATETILL]'), 'dd.mm.yyyy hh24:mi:ss');
    END job_datetill;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_dateto (p_job_id IN VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (job_parameter (p_job_id, '[DATETO]'), 'dd.mm.yyyy hh24:mi:ss');
    END job_dateto;

    /* =========================================================================
       Used for evaluation of job sql.
       ---------------------------------------------------------------------- */

    FUNCTION job_expanded_sql (
        p_jobid                                 IN VARCHAR2,
        p_job_sql                               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (4000); --002SO
        l_pos_proc                              PLS_INTEGER;
        l_pos_end                               PLS_INTEGER;
        l_tail                                  VARCHAR2 (4000); --002SO
        l_cmd                                   VARCHAR2 (200); --002SO
        l_eval                                  VARCHAR2 (200); --002SO
    BEGIN
        l_retval := p_job_sql;
        l_retval := REPLACE (l_retval, '<STAJ_ID>', p_jobid);

        IF INSTR (l_retval, 'JOB_DATEFROM(') > 0
        THEN
            l_retval := REPLACE (l_retval, 'JOB_DATEFROM(''' || p_jobid || ''')', 'to_date(''' || job_parameter (p_jobid, '[DATEFROM]') || ''',''dd.mm.yyyy hh24:mi:ss'')');
        END IF;

        IF INSTR (l_retval, 'JOB_DATETO(') > 0
        THEN
            l_retval := REPLACE (l_retval, 'JOB_DATETO(''' || p_jobid || ''')', 'to_date(''' || job_parameter (p_jobid, '[DATETO]') || ''',''dd.mm.yyyy hh24:mi:ss'')');
        END IF;

        IF INSTR (l_retval, 'JOB_DATETILL(') > 0
        THEN
            l_retval := REPLACE (l_retval, 'JOB_DATETILL(''' || p_jobid || ''')', 'to_date(''' || job_parameter (p_jobid, '[DATETILL]') || ''',''dd.mm.yyyy hh24:mi:ss'')');
        END IF;

        IF INSTR (l_retval, 'JOB_LOOPVAR(') > 0
        THEN
            l_retval := REPLACE (l_retval, 'JOB_LOOPVAR(''' || p_jobid || ''')', '''' || job_loopvar (p_jobid) || '''');
        END IF;

        IF INSTR (l_retval, 'JOB_BOHIDEXEC(') > 0
        THEN
            l_retval := REPLACE (l_retval, 'JOB_BOHIDEXEC(''' || p_jobid || ''')', '''' || job_bohidexec (p_jobid) || '''');
        END IF; --001SO

        l_pos_proc := INSTR (l_retval, 'JOB_PARAMETER');

        WHILE l_pos_proc > 0
        LOOP
            l_tail := SUBSTR (l_retval, l_pos_proc); -- from proc
            l_pos_end := INSTR (l_tail, ')');
            l_cmd := 'SELECT ' || SUBSTR (l_tail, 1, l_pos_end) || ' FROM DUAL';

            EXECUTE IMMEDIATE l_cmd
                INTO                                     l_eval;

            l_retval := SUBSTR (l_retval, 1, l_pos_proc - 1) || '''' || l_eval || '''';

            IF LENGTH (l_tail) > l_pos_end
            THEN
                l_retval := l_retval || SUBSTR (l_tail, l_pos_end + 1);
            END IF;

            l_pos_proc := INSTR (l_retval, 'JOB_PARAMETER');
        END LOOP;

        l_pos_proc := INSTR (l_retval, 'JOB_SEARCH_PARAMETER');

        WHILE l_pos_proc > 0
        LOOP
            l_tail := SUBSTR (l_retval, l_pos_proc); -- from proc
            l_pos_end := INSTR (l_tail, ')');
            l_cmd := 'SELECT ' || SUBSTR (l_tail, 1, l_pos_end) || ' FROM DUAL';

            EXECUTE IMMEDIATE l_cmd
                INTO                                     l_eval;

            l_retval := SUBSTR (l_retval, 1, l_pos_proc - 1) || '''' || l_eval || '''';

            IF LENGTH (l_tail) > l_pos_end
            THEN
                l_retval := l_retval || SUBSTR (l_tail, l_pos_end + 1);
            END IF;

            l_pos_proc := INSTR (l_retval, 'JOB_SEARCH_PARAMETER');
        END LOOP;

        RETURN l_retval;
    END job_expanded_sql;

    /* =========================================================================
       Return concatenated eMail adresses for invoices for given statistics job.
       ---------------------------------------------------------------------- */

    FUNCTION job_la_invoice_emails (p_job_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (1000);
        l_looptype                              VARCHAR2 (10);
        l_loopvar                               VARCHAR2 (10);
        l_acid                                  VARCHAR2 (10);
    BEGIN
        l_retval := NULL;

        SELECT pac_ltid,
               staj_ltvalue
        INTO   l_looptype,
               l_loopvar
        FROM   sta_job,
               packing
        WHERE      sta_job.staj_pacid = packing.pac_id
               AND staj_id = p_job_id;

        IF l_looptype = 'AC_ID'
        THEN
            l_retval := la_invoice_emails (l_loopvar);
        ELSIF l_looptype = 'CON_ID'
        THEN
            SELECT con_acid
            INTO   l_acid
            FROM   contract
            WHERE  con_id = l_loopvar;

            l_retval := la_invoice_emails (l_acid);
        END IF;

        RETURN l_retval;
    END job_la_invoice_emails;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_loopvar (p_job_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (100);
    BEGIN
        SELECT staj_ltvalue
        INTO   l_retval
        FROM   sta_job
        WHERE  staj_id = p_job_id;

        RETURN l_retval;
    END job_loopvar;

    /* =========================================================================
       Used for evaluation of reporting parameters.
       ---------------------------------------------------------------------- */

    FUNCTION job_parameter (
        p_job_id                                IN VARCHAR2,
        p_par_name                              IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (100);
    BEGIN
        SELECT stajp_value
        INTO   l_retval
        FROM   sta_jobparam
        WHERE      stajp_name = p_par_name
               AND stajp_jobid = p_job_id;

        RETURN l_retval;
    END job_parameter;

    /* =========================================================================
       Used for evaluation of reporting parameters.
       ---------------------------------------------------------------------- */

    FUNCTION job_search_parameter (
        p_job_id                                IN VARCHAR2,
        p_par_name                              IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cparamvalue IS
            SELECT stajp_value
            FROM   sta_jobparam
            WHERE      stajp_name = p_par_name
                   AND stajp_jobid = p_job_id;

        l_retval                                VARCHAR2 (100);
    BEGIN
        OPEN cparamvalue;

        FETCH cparamvalue INTO l_retval;

        IF cparamvalue%FOUND
        THEN
            IF l_retval IS NULL
            THEN
                l_retval := '%';
            ELSE
                l_retval := REPLACE (l_retval, '*', '%');
                l_retval := REPLACE (l_retval, '?', '_');
            END IF;
        ELSE
            l_retval := '%';
        END IF;

        CLOSE cparamvalue;

        RETURN l_retval;
    END job_search_parameter;

    /* =========================================================================
       Return concatenated eMail adresses for invoices for given AC_ID.
       ---------------------------------------------------------------------- */

    FUNCTION la_invoice_emails (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cemails IS
            SELECT ac_la_invoice_emails     AS adr_email
            FROM   account
            WHERE  ac_id = p_ac_id; -- 002SO

        l_retval                                VARCHAR2 (4000); -- 003SO
    BEGIN
        l_retval := NULL;

        OPEN cemails;

        FETCH cemails INTO l_retval;

        CLOSE cemails;

        RETURN l_retval;
    END la_invoice_emails;

    /* =========================================================================
       Return rendered range information for LongID.
       ---------------------------------------------------------------------- */

    FUNCTION longid_range (
        p_longid1                               IN NUMBER,
        p_longid2                               IN NUMBER)
        RETURN VARCHAR2
    IS
        result                                  VARCHAR2 (100);
    BEGIN
        result := TO_CHAR (p_longid1);

        IF     p_longid2 IS NOT NULL
           AND p_longid2 > p_longid1
        THEN -- 002SO
            result := result || '..' || SUBSTR (p_longid2, -5);
        END IF;

        RETURN result;
    END longid_range;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_job_details ( -- 003SO
        p_packingid                             IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2, -- 003SO
        p_refcursor                                OUT SYS_REFCURSOR,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
    BEGIN
        OPEN p_refcursor FOR SELECT -- 008DA
                                    pac_id,
                                    pac_name,
                                    pac_short,
                                    pac_template,
                                    pac_filemask,
                                    pac_pdfmask,
                                    pac_outputdir,
                                    pac_archivestatistic,
                                    pac_archivedir,
                                    pac_compress, -- 012DA
                                    pac_fieldsep, -- 012DA
                                    pac_linesep, -- 012DA
                                    pac_notification, -- 011DA
                                    NVL (pac_encodingtype, 'UTF8')    AS pac_encodingtype, -- 022DA
                                    not_subject,
                                    not_body,
                                    not_senderdisp,
                                    not_sendertxt,
                                    not_recdisp,
                                    not_adrfrom,
                                    CASE not_adrto
                                        WHEN '<JOB_LA_INVOICE_EMAILS>'
                                        THEN
                                            pkg_mec_oc.job_la_invoice_emails (p_jobid) -- 027SO
                                        WHEN '<JOB_BN_STATS_EMAILS>'
                                        THEN
                                            pkg_mec_oc.job_bn_stats_emails (p_jobid) -- 028SO
                                        ELSE
                                            not_adrto
                                    END                               AS not_adrto,
                                    not_adrcc,
                                    not_adrbcc,
                                    not_attfile,
                                    not_maxattsize, -- 009DA
                                    not_etid, -- 009DA
                                    stac_smtphost, -- 010DA
                                    stac_smtpport -- 010DA
                             FROM   packing,
                                    notificationtempl,
                                    sta_config -- 010DA
                             WHERE      pac_id = p_packingid
                                    AND pac_esid IN (rpackingstate.active,
                                                     rpackingstate.scheduled)
                                    AND pac_notid = not_id(+)
                                    AND stac_name = 'DEFAULT' -- 010DA
                                                             ; -- 030SO                                                                when '<JOB_ADRID_MAIN_EMAIL>' removed

        p_errorcode := NULL;
        p_errordesc := NULL;
        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    /*  -- 020SO
    Exception
        When others then
            p_ErrorCode := SqlCode;
            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    */
    END sp_get_job_details;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_job_queries (
        p_packingid                             IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_refcursor                                OUT SYS_REFCURSOR,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS -- 004SO
        CURSOR cpacking IS
            SELECT pac_etid
            FROM   packing
            WHERE  pac_id = p_packingid; -- 014SO
    BEGIN
        FOR cpackingrow IN cpacking
        LOOP
            IF cpackingrow.pac_etid = 'STATIND'
            THEN
                OPEN p_refcursor FOR SELECT   stajq_queryname                                      AS staq_queryname,
                                              pkg_mec_oc.job_expanded_sql (p_jobid, stajq_sql)     AS staq_sql -- 021SO
                                     FROM     sta_jobsql
                                     WHERE    stajq_jobid = p_jobid
                                     ORDER BY DECODE (stajq_queryname,  '<StartTransaction>', '1',  '<EndTransaction>', '9',  '2' || stajq_queryname) ASC; -- 025SO -- 024SO -- 014SO
            ELSE
                OPEN p_refcursor FOR SELECT   staq_queryname,
                                              pkg_mec_oc.job_expanded_sql (p_jobid, staq_sql)     AS staq_sql -- 021SO
                                     FROM     sta_sqldef
                                     WHERE    staq_pacid = p_packingid
                                     ORDER BY DECODE (staq_queryname,  '<StartTransaction>', '1',  '<EndTransaction>', '9',  '2' || staq_queryname) ASC; -- 025SO-- 024SO
            END IF;
        END LOOP;

        p_errorcode := NULL;
        p_errordesc := NULL;
        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    --    --  -- 020SO
    --    Exception
    --        When others then
    --            p_ErrorCode := SqlCode;
    --            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
    --            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    END sp_get_job_queries;

    /* =========================================================================
       TODO.

       007DA
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_packing_id (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
    BEGIN
        --
        -- get packing id and raise an exception, if suspended
        --
        IF p_packingid IS NOT NULL
        THEN
            -- specific packing is given
            IF pkg_common_packing.istimeforpacking (p_packingid) = 0
            THEN
                RAISE pkg_common.excp_inconvenient_time;
            END IF;
        ELSE
            -- only packing type is given - must search a candidate first
            p_packingid := pkg_common_packing.getpackingcandidatefortype (p_packingtype, p_thread);

            IF p_packingid IS NULL
            THEN
                RAISE pkg_common.excp_inconvenient_time;
            END IF;
        END IF;

        --
        -- packing found, which can be executed
        --
        UPDATE packing
        SET    pac_datetry = SYSDATE
        WHERE  pac_id = p_packingid;

        p_returnstatus := pkg_common.return_status_ok;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            p_errorcode := pkg_common.eno_inconvenient_time;
            p_errordesc := pkg_common.edesc_inconvenient_time;
            p_returnstatus := pkg_common.return_status_suspended;
    --    --  -- 020SO
    --        When others then
    --            p_ErrorCode := SqlCode;
    --            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
    --            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    END sp_get_packing_id;

    /* =========================================================================
       TODO.
      ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_headerid                                 OUT VARCHAR2,
        p_jobid                                    OUT VARCHAR2,
        p_filename                                 OUT VARCHAR2, -- 002SO
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
    BEGIN
        p_headerid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype,
            p_packingid,
            p_headerid,
            p_jobid,
            p_filename, -- 002SO
            p_appname,
            p_appver,
            p_thread,
            p_taskid, -- 019SO
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
            p_returnstatus := pkg_common.return_status_failure; -- 013SO
        WHEN pkg_common_packing.excp_workflow_abort
        THEN
            p_errorcode := pkg_common_packing.eno_workflow_abort;
            p_errordesc := pkg_common_packing.edesc_workflow_abort;
            p_returnstatus := pkg_common.return_status_failure; -- 013SO
    --    --  -- 020SO
    --        When others then
    --            p_ErrorCode := SqlCode;
    --            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
    --            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    END sp_insert_header;

    /* =========================================================================
       TODO.
      ---------------------------------------------------------------------- */

    PROCEDURE sp_modify_header (
        p_headerid                              IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_filename                                 OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS -- 015SO
    BEGIN
        -- Update the given Biheader Id with the information supplied

        pkg_common_packing.modify_boheader (
            p_headerid,
            p_appname,
            p_appver,
            p_thread,
            p_taskid,
            p_hostname,
            p_filename);
        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    EXCEPTION
        WHEN pkg_common.excp_missing_header_fld
        THEN -- not used yet
            p_errorcode := pkg_common.eno_missing_header_fld;
            p_errordesc := pkg_common.edesc_missing_header_fld;
            p_returnstatus := pkg_common.return_status_failure;
    --    --  -- 020SO
    --        When Others then
    --            p_ErrorCode := SqlCode;
    --            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
    --            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    --            Return;
    END sp_modify_header;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_register_output (
        p_packingid                             IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_jobid                                 IN     VARCHAR2,
        p_filepath                              IN     VARCHAR2, -- absolute path without file name
        p_filename                              IN     VARCHAR2, -- name only
        p_filesize                              IN     NUMBER, -- 006SO -- TODO unused parameter? (wwe)
        p_outputtype                            IN     VARCHAR2, -- XLS / PDF / CSV for now
        p_outputid                                 OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS -- 005SO
    BEGIN
        p_outputid := pkg_common.generateuniquekey ('G');

        INSERT INTO sta_joboutput (
                        stajo_id,
                        stajo_jobid,
                        stajo_datecre,
                        stajo_outputdir,
                        stajo_filename,
                        stajo_etid)
        VALUES      (
                        p_outputid,
                        p_jobid,
                        SYSDATE,
                        p_filepath,
                        p_filename,
                        p_outputtype); -- add file size here $$$$$$$$$$$$$$$$$$$

        p_errorcode := NULL;
        p_errordesc := NULL;
        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    --    Exception
    --        When others then
    --            p_ErrorCode := SqlCode;
    --            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
    --            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
    END sp_register_output;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_update_header (
        p_headerid                              IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_filename                              IN OUT VARCHAR2,
        p_filedate                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        p_dataheader                            IN     VARCHAR2,
        p_reccount                              IN     NUMBER,
        p_errcount                              IN     NUMBER,
        p_datefc                                IN     VARCHAR2,
        p_datelc                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
    BEGIN
        -- Update the given Biheader Id with the information supplied

        pkg_common_packing.update_boheader (
            p_headerid,
            p_jobid,
            p_filename,
            p_filedate,
            p_maxage,
            p_dataheader,
            p_reccount,
            p_errcount,
            p_datefc,
            p_datelc);
        -- 018SO
        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    EXCEPTION
        WHEN pkg_common.excp_missing_header_fld
        THEN -- not used yet
            p_errorcode := pkg_common.eno_missing_header_fld;
            p_errordesc := pkg_common.edesc_missing_header_fld;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_reccount_mismatch
        THEN -- not used yet
            p_errorcode := pkg_common.eno_reccount_mismatch;
            p_errordesc := pkg_common.edesc_reccount_mismatch;
            p_returnstatus := pkg_common.return_status_failure;
    /*
        When Others then
            p_ErrorCode := SqlCode;
            p_ErrorDesc := PKG_COMMON.getHardErrorDesc;
            p_ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
            Return;
    */
    END sp_update_header;
END pkg_mec_oc;
/
