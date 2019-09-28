CREATE OR REPLACE PACKAGE BODY test_pkg_bdetail_smsc
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sp_cons_dgti - pkg_bdetail_smsc.sp_cons_dgti]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_dgti
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_smsc.sp_cons_dgti (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        test_data.crea_bdetail2_scratch ();

        test_data.crea_dgticonsol_scratch ();

        UPDATE dgticonsol
        SET    dgtic_dgti = 'ut_code_a'
        WHERE  dgtic_id = test_data.gc_dgtic_id;

        test_data.crea_numberrange ();

        UPDATE numberrange
        SET    nbr_conopkey = 'ut_hit_a'
        WHERE  nbr_id = test_data.gc_nbr_id;

        COMMIT;

        pkg_bdetail_smsc.sp_cons_dgti (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_dgti;

    PROCEDURE sp_cons_dgti_after
    IS
    BEGIN
        -- 0
        test_data.del_bdetail2_complete ();
        test_data.del_dgticonsol_complete ();
        test_data.del_numberrange_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_dgti_after;

    /* =========================================================================
       Test: [Test method sp_cons_iwt - pkg_bdetail_smsc.sp_cons_iwt]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_iwt
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_smsc.sp_cons_iwt (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        test_data.crea_bdetail2_scratch ();

        UPDATE bdetail2
        SET    bd_mapsid = 'R'
        WHERE  bd_id = test_data.gc_bd_id;

        test_data.crea_bdetail7_scratch ();

        UPDATE bdetail7
        SET    bd_mapsid = 'R',
               bd_msgtype = 'M',
               bd_sinktype = '2'
        WHERE  bd_id = test_data.gc_bd_id;

        test_data.crea_roconsolidation_scratch ();

        UPDATE roconsolidation
        SET    roc_esid = 'R'
        WHERE  roc_id = test_data.gc_roc_id;

        COMMIT;

        pkg_bdetail_smsc.sp_cons_iwt (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (2);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_iwt;

    PROCEDURE sp_cons_iwt_after
    IS
    BEGIN
        -- 0
        test_data.del_bdetail2_complete ();
        test_data.del_bdetail7_complete ();
        test_data.del_roconsolidation_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_iwt_after;

    /* =========================================================================
       Test: [Test method sp_cons_laa_mfgr - pkg_bdetail_smsc.sp_cons_laa_mfgr]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_laa_mfgr_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_smsc.sp_cons_laa_mfgr (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        test_data.crea_contract_scratch ();
        test_data.crea_setperiod ();

        UPDATE contract
        SET    con_consol = 'ut_hit',
               con_datestart = ADD_MONTHS (SYSDATE, -1),
               con_etid = 'LAC',
               con_mfgr = 0.23
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_longid_scratch ();

        UPDATE longid
        SET    long_datestart = ADD_MONTHS (SYSDATE, -1),
               long_esid = 'M',
               long_price = 0.23,
               long_shortid = 'ut_hit'
        WHERE  long_id = test_data.gc_long_id;

        test_data.crea_setdetail_scratch ();

        COMMIT;

        pkg_bdetail_smsc.sp_cons_laa_mfgr (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (2);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_laa_mfgr_a;

    PROCEDURE sp_cons_laa_mfgr_after
    IS
    BEGIN
        -- 0
        test_data.del_setdetail_complete ();

        -- 1
        test_data.del_longid_complete ();
        test_data.del_setperiod_complete ();

        -- 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_laa_mfgr_after;

    PROCEDURE sp_cons_laa_mfgr_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_contract_scratch ();
        test_data.crea_longid_scratch ();

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_esid = 'V',
               sed_etid = 'MFGR',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM') || '%'
        WHERE  sed_id = test_data.gc_sed_id;

        COMMIT;

        pkg_bdetail_smsc.sp_cons_laa_mfgr (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_equal ('Cannot do SMS Global Reply monthly settlement twice for the same period.');
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;
    END sp_cons_laa_mfgr_b;

    /* =========================================================================
       Test: [Test method sp_cons_lam_sms - pkg_bdetail_smsc.sp_cons_lam_sms]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lam_sms
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_etid = 'CDR',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        test_data.crea_sta_pacparam_scratch ();

        COMMIT;

        pkg_bdetail_smsc.sp_cons_lam_sms (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => test_data.gc_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lam_sms;

    PROCEDURE sp_cons_lam_sms_after
    IS
    BEGIN
        -- Level 0
        test_data.del_setdetail_complete ();
        test_data.del_sta_pacparam_complete ();

        -- Level 1
        test_data.del_setperiod_complete ();
        test_data.del_settling_complete ();
        test_data.del_tariff_complete ();

        -- Level 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_lam_sms_after;

    /* =========================================================================
       Test: [Test method sp_cons_lapmcc_sms - pkg_bdetail_smsc.sp_cons_lapmcc_sms]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lapmcc_sms
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_etid = 'CDR',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_smsc.sp_cons_lapmcc_sms (
            p_pact_id                            => NULL,
            p_boh_id                             => test_data.gc_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lapmcc_sms;

    PROCEDURE sp_cons_lapmcc_sms_after
    IS
    BEGIN
        -- Level 0
        test_data.del_setdetail_complete ();

        -- Level 1
        test_data.del_setperiod_complete ();
        test_data.del_settling_complete ();
        test_data.del_tariff_complete ();

        -- Level 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_lapmcc_sms_after;

    /* =========================================================================
       Test: [Test method sp_cons_lat_mfgr - pkg_bdetail_smsc.sp_cons_lat_mfgr]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lat_mfgr_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_count1 = 1,
               sed_count2 = 2,
               sed_etid = 'CDR',
               sed_gohid = 'wwe',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        test_data.crea_sta_pacparam_scratch ();

        COMMIT;

        pkg_bdetail_smsc.sp_cons_lat_mfgr (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => test_data.gc_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lat_mfgr_a;

    PROCEDURE sp_cons_lat_mfgr_after
    IS
    BEGIN
        -- Level 0
        test_data.del_boheader_complete ();
        test_data.del_setdetail_complete ();
        test_data.del_sta_pacparam_complete ();

        -- Level 1
        test_data.del_setperiod_complete ();
        test_data.del_settling_complete ();
        test_data.del_tariff_complete ();

        -- Level 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_lat_mfgr_after;

    PROCEDURE sp_cons_lat_mfgr_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();
        test_data.crea_boheader_scratch ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_count1 = 1,
               sed_count2 = 2,
               sed_esid = 'A',
               sed_etid = 'MFGRA',
               sed_gohid = 'wwe',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD'),
               sed_setid = test_data.gc_set_id
        WHERE  sed_id = test_data.gc_sed_id;

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_etid = 'SLA',
               set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        test_data.crea_sta_pacparam_scratch ();

        COMMIT;

        pkg_bdetail_smsc.sp_cons_lat_mfgr (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => test_data.gc_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (-1);
        ut.expect (l_errormsg).to_equal ('Mismatch in marked/processed SMS CDR counts (1/0)');
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;
    END sp_cons_lat_mfgr_b;

    PROCEDURE sp_cons_lat_mfgr_c
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_count1 = 1,
               sed_count2 = 2,
               sed_esid = 'A',
               sed_etid = 'MFGRA',
               sed_gohid = 'wwe',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD'),
               sed_setid = test_data.gc_set_id
        WHERE  sed_id = test_data.gc_sed_id;

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_conid = test_data.gc_con_id,
               set_etid = 'SLA',
               set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        test_data.crea_sta_pacparam_scratch ();

        COMMIT;

        pkg_bdetail_smsc.sp_cons_lat_mfgr (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => test_data.gc_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lat_mfgr_c;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_bdetail_smsc;
/