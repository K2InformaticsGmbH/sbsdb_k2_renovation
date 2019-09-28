CREATE OR REPLACE PACKAGE BODY test_pkg_admin_common
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method geterrordesc - geterrordesc]].
       ---------------------------------------------------------------------- */

    PROCEDURE geterrordesc
    IS
        l_errdef                                errdef%ROWTYPE;
    BEGIN
        ut.expect (pkg_admin_common.geterrordesc ('ut_code_a')).to_equal ('ut_code_a: Error Description not available');
        ut.expect (pkg_admin_common.geterrordesc ('ut_code_b')).to_equal ('ut_code_b: Error Description not available');
        ut.expect (pkg_admin_common.geterrordesc ('ut_code_c')).to_equal ('ut_code_c: Error Description not available');

        ROLLBACK;

        l_errdef.errd_lang01 := 'ut_lang01_a';
        l_errdef.errd_exception := 'ut_code_a';
        test_data.crea_errdef (l_errdef);

        l_errdef.errd_id := 'ut_id_b';
        l_errdef.errd_code := 'ut_code_b';
        l_errdef.errd_lang01 := 'ut_lang01_b';
        l_errdef.errd_exception := 'ut_code_a';
        test_data.crea_errdef (l_errdef);

        COMMIT;

        ut.expect (pkg_admin_common.geterrordesc ('ut_code_a')).to_equal ('ut_code_a: Error Code is not unique');
        ut.expect (pkg_admin_common.geterrordesc ('ut_code_b')).to_equal ('ut_lang01_b');
        ut.expect (pkg_admin_common.geterrordesc ('UT_CODE_B')).to_equal ('ut_lang01_b');
        ut.expect (pkg_admin_common.geterrordesc ('ut_code_c')).to_equal ('ut_code_c: Error Description not available');

        ROLLBACK;
    END geterrordesc;

    PROCEDURE geterrordesc_after
    IS
    BEGIN
        test_data.del_errdef ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END geterrordesc_after;

    /* =========================================================================
       Test: [Test method sp_add_report - sp_add_report]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_report
    IS
        lc_str_acid                    CONSTANT sta_job.staj_acidcre%TYPE := 'SYSTEM';

        l_int_errnumber                         PLS_INTEGER;
        l_str_errdesc                           VARCHAR2 (512);
    BEGIN
        test_data.crea_sta_joboutput_scratch ();

        COMMIT;

        pkg_admin_common.sp_add_report (
            str_acid                             => lc_str_acid,
            str_pac_id                           => test_data.gc_pac_id,
            dat_from                             => SYSDATE,
            dat_to                               => SYSDATE,
            str_opt_param                        => 'ut_str_opt_param_a',
            str_comment                          => 'ut_str_comment_a',
            str_system_info                      => 'ut_str_system_info_a',
            str_parameter_info                   => 'ut_str_parameter_info_a',
            int_pac_modis                        => 0,
            int_pac_modla                        => 0,
            int_pac_modiw                        => 0,
            int_pac_modsys                       => 0,
            int_pac_modcuc                       => 0,
            int_errnumber                        => l_int_errnumber,
            str_errdesc                          => l_str_errdesc);

        ut.expect (l_int_errnumber).to_be_null ();
        ut.expect (l_str_errdesc).to_be_null ();

        ROLLBACK;
    END sp_add_report;

    /* =========================================================================
       Test: [Test method sp_add_report_02291 - sp_add_report]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_report_02291
    IS
        lc_str_acid                    CONSTANT sta_job.staj_acidcre%TYPE := 'SYSTEM';

        l_int_errnumber                         PLS_INTEGER;
        l_str_errdesc                           VARCHAR2 (512);
    BEGIN
        pkg_admin_common.sp_add_report (
            str_acid                             => lc_str_acid,
            str_pac_id                           => test_data.gc_pac_id,
            dat_from                             => SYSDATE,
            dat_to                               => SYSDATE,
            str_opt_param                        => 'ut_str_opt_param_a',
            str_comment                          => 'ut_str_comment_a',
            str_system_info                      => 'ut_str_system_info_a',
            str_parameter_info                   => 'ut_str_parameter_info_a',
            int_pac_modis                        => 0,
            int_pac_modla                        => 0,
            int_pac_modiw                        => 0,
            int_pac_modsys                       => 0,
            int_pac_modcuc                       => 0,
            int_errnumber                        => l_int_errnumber,
            str_errdesc                          => l_str_errdesc);

        ROLLBACK;
    END sp_add_report_02291;

    PROCEDURE sp_add_report_after
    IS
    BEGIN
        DELETE FROM sta_jobparam
        WHERE       stajp_jobid IN (SELECT stajp_jobid
                                    FROM   sta_jobparam
                                    WHERE  stajp_value LIKE 'ut_str_opt_param%');

        test_data.del_sta_joboutput_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_add_report_after;

    /* =========================================================================
       Test: [Test method sp_hide_job_output - sp_hide_job_output]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_hide_job_output
    IS
        lc_acid                        CONSTANT account.ac_id%TYPE := 'SYSTEM';

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);
    BEGIN
        pkg_admin_common.sp_hide_job_output (lc_acid, test_data.gc_stajo_id, l_errorcode, l_errormsg);

        ut.expect (l_errorcode).to_equal (100);
        ut.expect (l_errormsg).to_be_like ('ORA-01403: %');

        ROLLBACK;

        test_data.crea_sta_joboutput_scratch ();

        COMMIT;

        pkg_admin_common.sp_hide_job_output (lc_acid, test_data.gc_stajo_id, l_errorcode, l_errormsg);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();

        ROLLBACK;
    END sp_hide_job_output;

    PROCEDURE sp_hide_job_output_after
    IS
    BEGIN
        -- 0
        test_data.del_sta_joboutput_complete ();
        test_data.del_warning ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_hide_job_output_after;

    /* =========================================================================
       Test: [Test method sp_validate_exchange_rates - sp_validate_exchange_rates]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_validate_exchange_rates
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_admin_common.sp_validate_exchange_rates (test_data.gc_cur_id, l_errorcode, l_errormsg, l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        test_data.crea_exchangerate_scratch ();

        COMMIT;

        pkg_admin_common.sp_validate_exchange_rates (test_data.gc_cur_id, l_errorcode, l_errormsg, l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_validate_exchange_rates;

    PROCEDURE sp_validate_exchange_rates_aft
    IS
    BEGIN
        test_data.del_exchangerate_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_validate_exchange_rates_aft;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_admin_common;
/