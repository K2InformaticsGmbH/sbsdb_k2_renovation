CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_admin_common
IS
    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_warning --002AH
                             (
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_usererrcode                         IN VARCHAR2 DEFAULT NULL,
        p_w_bihid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN VARCHAR2 DEFAULT NULL);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    FUNCTION geterrordesc (lverrcode IN VARCHAR2)
        RETURN errdef.errd_lang01%TYPE
    IS
        errdesc                                 errdef.errd_lang01%TYPE;
    BEGIN
        errdesc := lverrcode || ': Error Description not available';

        SELECT errd_lang01
        INTO   errdesc
        FROM   errdef
        WHERE     UPPER (errd_code) = UPPER (lverrcode)
               OR UPPER (errd_exception) = UPPER (lverrcode);

        RETURN errdesc;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN errdesc;
        WHEN OTHERS
        THEN
            RETURN lverrcode || ': Error Code is not unique';
    END geterrordesc;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_report (
        str_acid                                IN     VARCHAR2,
        str_pac_id                              IN     VARCHAR2,
        dat_from                                IN     DATE,
        dat_to                                  IN     DATE,
        str_opt_param                           IN     VARCHAR2,
        str_comment                             IN     VARCHAR2,
        str_system_info                         IN     VARCHAR2,
        str_parameter_info                      IN     VARCHAR2,
        int_pac_modis                           IN     NUMBER, -- TODO unused parameter? (wwe)
        int_pac_modla                           IN     NUMBER, -- TODO unused parameter? (wwe)
        int_pac_modiw                           IN     NUMBER, -- TODO unused parameter? (wwe)
        int_pac_modsys                          IN     NUMBER, -- TODO unused parameter? (wwe)
        int_pac_modcuc                          IN     NUMBER, -- TODO unused parameter? (wwe)
        int_errnumber                              OUT NUMBER, -- TODO unused parameter? (wwe)
        str_errdesc                                OUT VARCHAR2) -- TODO unused parameter? (wwe)
    IS --  023SO
        l_staj_id                               VARCHAR2 (10);
        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
        l_err_number                            PLS_INTEGER;
        l_err_desc                              VARCHAR2 (4000);
    BEGIN
        l_staj_id := pkg_common.generateuniquekey ('G');

        INSERT INTO sta_job (
                        staj_id,
                        staj_pacid,
                        staj_parentid,
                        staj_esid,
                        staj_etid,
                        staj_info,
                        staj_datesta,
                        staj_datecre,
                        staj_acidcre,
                        staj_chngcnt,
                        staj_periodid,
                        staj_notification,
                        staj_notsendatt)
        VALUES      (
                        l_staj_id,
                        str_pac_id,
                        '0',
                        'A',
                        'XLS',
                        SUBSTR (str_comment || CHR (10) || str_system_info || CHR (10) || str_parameter_info, 1, 2000) --  024SO
                                                                                                                      ,
                        SYSDATE,
                        SYSDATE,
                        str_acid,
                        0,
                        NULL,
                        0,
                        0);

         
        iNSERT INTO sta_jobparam (
                        stajp_id,
                        stajp_jobid,
                        stajp_name,
                        stajp_value)
        VALUES      (
                        pkg_common.generateuniquekey ('G'),
                        l_staj_id,
                        '[DATEFROM]',
                        TO_CHAR (dat_from, 'dd.mm.yyyy hh24:mi:ss'));

        INSERT INTO sta_jobparam (
                        stajp_id,
                        stajp_jobid,
                        stajp_name,
                        stajp_value)
        VALUES      (
                        pkg_common.generateuniquekey ('G'),
                        l_staj_id,
                        '[DATETO]',
                        TO_CHAR (dat_to, 'dd.mm.yyyy hh24:mi:ss'));

        INSERT INTO sta_jobparam (
                        stajp_id,
                        stajp_jobid,
                        stajp_name,
                        stajp_value)
        VALUES      (
                        pkg_common.generateuniquekey ('G'),
                        l_staj_id,
                        '[OPT_PARAM]',
                        NVL (str_opt_param, str_parameter_info));

        pkg_stats.sp_new_sta_jobsqls (
            l_staj_id,
            l_recordsaffected,
            l_err_number,
            l_err_desc,
            l_returnstatus);
    END sp_add_report;

    PROCEDURE sp_hide_job_output (
        p_acid                                  IN     account.ac_id%TYPE,
        p_joboutputid                           IN     sta_joboutput.stajo_id%TYPE,
        p_errnumber                             IN OUT NUMBER, -- TODO looks very odd (wwe)
        p_errdesc                               IN OUT VARCHAR2) -- TODO looks very odd (wwe)
    IS --  022SO
        l_file_name                             VARCHAR2 (100);
        l_staj_id                               VARCHAR2 (10);
    BEGIN
        SELECT stajo_filename,
               stajo_jobid
        INTO   l_file_name,
               l_staj_id
        FROM   sta_joboutput
        WHERE  stajo_id = p_joboutputid;

        insert_warning ('STATS', 'SP_HIDE_JOB_OUTPUT', 'JOB DELETED BY ACCOUNT ' || p_acid, l_file_name);

        UPDATE sta_job
        SET    staj_esid = 'D'
        WHERE  staj_id = l_staj_id;

        -- DELETE FROM STA_JOBOUTPUT where STAJO_ID = p_JobOutputId;

        p_errnumber := 0;
        p_errdesc := NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_errnumber := SQLCODE;
            p_errdesc := SQLERRM;
    END sp_hide_job_output;

    PROCEDURE sp_validate_exchange_rates (
        p_cur_id                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) -- TODO looks very odd (wwe)
    IS
    BEGIN
        UPDATE exchangerate er1
        SET    er1.exr_end =
                   (SELECT NVL (MIN (er2.exr_start), TO_DATE ('21000101', 'yyyymmdd'))
                    FROM   exchangerate er2
                    WHERE      er2.exr_curid = er1.exr_curid
                           AND er2.exr_start > er1.exr_start)
        WHERE  er1.exr_curid = p_cur_id;

        returnstatus := 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
    END sp_validate_exchange_rates;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Write Warnings and Errors into global WARNING Table.
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
                        pkg_common.generateuniquekey ('G'),
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
END pkg_admin_common;
/