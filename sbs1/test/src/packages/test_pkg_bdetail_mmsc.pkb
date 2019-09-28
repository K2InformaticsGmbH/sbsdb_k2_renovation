CREATE OR REPLACE PACKAGE BODY test_pkg_bdetail_mmsc
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sp_cons_lam_mms - sp_cons_lam_mms]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lam_mms
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_sta_pacparam_scratch ();

        COMMIT;

        pkg_bdetail_mmsc.sp_cons_lam_mms (
            p_pac_id                             => test_data.gc_pac_id,
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
    END sp_cons_lam_mms;

    PROCEDURE sp_cons_lam_mms_after
    IS
    BEGIN
        test_data.del_sta_pacparam_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_lam_mms_after;

    PROCEDURE sp_cons_lam_mms_1008
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_mmsc.sp_cons_lam_mms (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ROLLBACK;
    END sp_cons_lam_mms_1008;

    /* =========================================================================
       Test: [Test method sp_cons_lapmcc_mms - sp_cons_lapmcc_mms]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lapmcc_mms
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_mmsc.sp_cons_lapmcc_mms (
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
    END sp_cons_lapmcc_mms;

    /* =========================================================================
       Test: [Test method sp_cons_lat_mms - sp_cons_lat_mms]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lat_mms_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_packing_scratch ();
        test_data.crea_sedstate_all ();

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (30);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MINAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (0);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_esid = 'A',
               sed_etid = 'CDRA',
               sed_order = TO_CHAR (SYSDATE - 5, 'YYYY-MM-DD'),
               sed_setid =
                   (SELECT set_id
                    FROM   settling
                    WHERE  set_etid IN ('MLA'));

        COMMIT;

        pkg_bdetail_mmsc.sp_cons_lat_mms (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lat_mms_a;

    PROCEDURE sp_cons_lat_mms_after
    IS
    BEGIN
        -- Level 0
        test_data.del_setdetail_complete ();
        test_data.del_sta_pacparam_complete ();
        test_data.del_sedstate ();

        -- Level 1
        test_data.del_setperiod_complete ();
        test_data.del_settling_complete ();
        test_data.del_tariff_complete ();
        test_data.del_bostate ();
        test_data.del_sedtype ();

        -- Level 2
        test_data.del_contract_complete ();
        test_data.del_packing_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_lat_mms_after;

    PROCEDURE sp_cons_lat_mms_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setdetail                             setdetail%ROWTYPE;
        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_bostate_all ();
        test_data.crea_sedstate_all ();
        test_data.crea_sedtype_all ();

        test_data.crea_setperiod ();
        l_setperiod.sep_id := TO_CHAR (TRUNC (SYSDATE, 'MONTH'), 'YYYYMM');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        test_data.crea_packing_scratch ();

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (30);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MINAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (0);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();
        l_setdetail.sed_count1 := 1;
        l_setdetail.sed_count2 := 2;
        l_setdetail.sed_esid := 'A';
        l_setdetail.sed_etid := 'CDRA';
        l_setdetail.sed_gohid := test_data.gc_boh_id;
        l_setdetail.sed_order := TO_CHAR (SYSDATE - 2, 'YYYY-MM-DD');
        l_setdetail.sed_setid := test_data.gc_set_id;

       <<loop_setdetail_1>>
        FOR i IN 1 .. 10
        LOOP
            l_setdetail.sed_id := pkg_common.generateuniquekey ('G');
            l_setdetail.sed_pos := i;
            test_data.crea_setdetail (l_setdetail);
        END LOOP loop_setdetail_1;

        COMMIT;

        pkg_bdetail_mmsc.sp_cons_lat_mms (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => test_data.gc_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (10);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lat_mms_b;

    PROCEDURE sp_cons_lat_mms_1008
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_mmsc.sp_cons_lat_mms (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ROLLBACK;
    END sp_cons_lat_mms_1008;

    /* =========================================================================
       Test: [Test method sp_cons_lit_mms - sp_cons_lit_mms]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_lit_mms_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_bostate_all ();
        test_data.crea_sedstate_all ();

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (30);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MINAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (0);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_packing_scratch ();

        test_data.crea_setdetail_scratch ();

        UPDATE setdetail
        SET    sed_esid = 'A',
               sed_etid = 'IOTLACA',
               sed_gohid = 'ut_id_w',
               sed_order = TO_CHAR (SYSDATE - 5, 'YYYY-MM-DD'),
               sed_setid =
                   (SELECT set_id
                    FROM   settling
                    WHERE  set_etid IN ('MLA'));

        l_setperiod.sep_id := TO_CHAR (SYSDATE, 'yyyymm');
        test_data.crea_setperiod (l_setperiod);

        COMMIT;

        pkg_bdetail_mmsc.sp_cons_lit_mms (
            p_pac_id                             => test_data.gc_pac_id,
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
    END sp_cons_lit_mms_a;

    PROCEDURE sp_cons_lit_mms_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail6_complete ();
        test_data.del_bostate ();
        test_data.del_pacstate ();
        test_data.del_setdetail_complete ();
        test_data.del_sta_pacparam_complete ();
        test_data.del_sedstate ();

        -- Level 1
        test_data.del_settling_complete ();
        test_data.del_setperiod_complete ();
        test_data.del_sedtype ();

        -- Level 2
        test_data.del_contract_complete ();
        test_data.del_packing_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_lit_mms_after;

    PROCEDURE sp_cons_lit_mms_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setdetail                             setdetail%ROWTYPE;
        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_bostate_all ();
        test_data.crea_pacstate_all ();
        test_data.crea_sedstate_all ();
        test_data.crea_sedtype_all ();

        test_data.crea_bdetail6_scratch ();

        UPDATE bdetail6
        SET    bd_demo = 0,
               bd_mapsid = 'R',
               bd_pacsid3 = 'S',
               bd_srctype = 'MMSC'
        WHERE  bd_id = test_data.gc_bd_id;

        test_data.crea_packing_scratch ();

        l_setperiod.sep_id := TO_CHAR (SYSDATE, 'yyyymm');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_settling_scratch ();

        UPDATE settling
        SET    set_etid = 'MLA'
        WHERE  set_id = test_data.gc_set_id;

        test_data.crea_sta_pacparam_scratch ();

        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (30);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MINAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (0);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();

        l_setdetail.sed_esid := 'A';
        l_setdetail.sed_etid := 'IOTLACA';
        l_setdetail.sed_gohid := 'ut_id_a';
        l_setdetail.sed_order := TO_CHAR (SYSDATE - 2, 'YYYY-MM-DD');
        l_setdetail.sed_setid := test_data.gc_set_id;

       <<loop_setdetail_1>>
        FOR i IN 1 .. 10
        LOOP
            l_setdetail.sed_id := pkg_common.generateuniquekey ('G');
            l_setdetail.sed_pos := i;
            test_data.crea_setdetail (l_setdetail);
        END LOOP loop_setdetail_1;

        COMMIT;

        pkg_bdetail_mmsc.sp_cons_lit_mms (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => 'ut_id_a',
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (10);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_lit_mms_b;

    PROCEDURE sp_cons_lit_mms_1008
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_mmsc.sp_cons_lit_mms (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ROLLBACK;
    END sp_cons_lit_mms_1008;

    /* =========================================================================
       Test: [Test method sp_cons_mmsc - sp_cons_mmsc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_mmsc
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bdetail6_scratch ();
        test_data.crea_mmsconsolidation_scratch ();
        test_data.crea_setperiod ();

        COMMIT;

        pkg_bdetail_mmsc.sp_cons_mmsc (
            p_pact_id                            => NULL,
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
    END sp_cons_mmsc;

    PROCEDURE sp_cons_mmsc_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail6_complete ();
        test_data.del_mmsconsolidation_complete ();

        -- Level 1
        test_data.del_setperiod_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_mmsc_after;

    /* =========================================================================
       Test: [Test method sp_try_laa_mmsc - sp_try_laa_mmsc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_laa_mmsc_a
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_pacstate_all ();
        test_data.crea_sedstate_all ();

        l_setperiod.sep_id := TO_CHAR (SYSDATE, 'yyyymm');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_bdetail6_scratch ();
        test_data.crea_boheader_scratch ();

        UPDATE bdetail6
        SET    bd_datetime = SYSDATE - 2,
               bd_demo = 0,
               bd_mapsid = 'R',
               bd_pacsid3 = 'S',
               bd_srctype = 'MMSC';

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_pacid := 'LAA_MMSC';
        l_sta_pacparam.stap_name := '[BATCHCOUNT]';
        l_sta_pacparam.stap_value := TO_CHAR (10);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (60);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_bdetail_mmsc.sp_try_laa_mmsc (
            p_pac_id                             => 'LAA_MMSC',
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;
    END sp_try_laa_mmsc_a;

    PROCEDURE sp_try_laa_mmsc_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail6_complete ();
        test_data.del_boheader_complete ();
        test_data.del_setdetail_complete ();
        test_data.del_sta_pacparam_complete ();
        test_data.del_pacstate ();

        -- Level 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_try_laa_mmsc_after;

    PROCEDURE sp_try_laa_mmsc_b
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_pacstate_all ();
        test_data.crea_sedstate_all ();

        l_setperiod.sep_id := TO_CHAR (SYSDATE, 'yyyymm');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_bdetail6_scratch ();
        test_data.crea_boheader_scratch ();
        test_data.crea_contract_scratch ();

        UPDATE bdetail6
        SET    bd_conid = test_data.gc_con_id,
               bd_datetime = SYSDATE - 2,
               bd_demo = 0,
               bd_mapsid = 'R',
               bd_pacsid3 = 'S',
               bd_srctype = 'MMSC';

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_pacid := 'LAA_MMSC';
        l_sta_pacparam.stap_name := '[BATCHCOUNT]';
        l_sta_pacparam.stap_value := TO_CHAR (10);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (60);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_bdetail_mmsc.sp_try_laa_mmsc (
            p_pac_id                             => 'LAA_MMSC',
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_laa_mmsc_b;

    PROCEDURE sp_try_laa_mmsc_1008
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_mmsc.sp_try_laa_mmsc (
            p_pac_id                             => 'LAA_MMSC',
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ROLLBACK;
    END sp_try_laa_mmsc_1008;

    /* =========================================================================
       Test: [Test method sp_try_lia_mmsc - sp_try_lia_mmsc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_lia_mmsc_a
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_packing                               packing%ROWTYPE;

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_pacstate_all ();
        test_data.crea_sedstate_all ();

        l_setperiod.sep_id := TO_CHAR (SYSDATE, 'yyyymm');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_bdetail6_scratch ();
        test_data.crea_boheader_scratch ();

        UPDATE bdetail6
        SET    bd_datetime = SYSDATE - 2,
               bd_demo = 0,
               bd_mapsid = 'R',
               bd_pacsid2 = 'S',
               bd_srctype = 'MMSC';

        l_packing.pac_id := 'LIA_MMSC';
        test_data.crea_packing (l_packing);

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_pacid := 'LIA_MMSC';
        l_sta_pacparam.stap_name := '[BATCHCOUNT]';
        l_sta_pacparam.stap_value := TO_CHAR (10);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (60);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_bdetail_mmsc.sp_try_lia_mmsc (
            p_pac_id                             => 'LIA_MMSC',
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;
    END sp_try_lia_mmsc_a;

    PROCEDURE sp_try_lia_mmsc_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail6_complete ();
        test_data.del_boheader_complete ();
        test_data.del_setdetail_complete ();
        test_data.del_sta_pacparam_complete ();
        test_data.del_pacstate ();

        -- Level 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_try_lia_mmsc_after;

    PROCEDURE sp_try_lia_mmsc_b
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_packing                               packing%ROWTYPE;

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_pacstate_all ();
        test_data.crea_sedstate_all ();

        l_setperiod.sep_id := TO_CHAR (SYSDATE, 'yyyymm');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_bdetail6_scratch ();
        test_data.crea_boheader_scratch ();
        test_data.crea_contract_scratch ();

        UPDATE bdetail6
        SET    bd_conid = test_data.gc_con_id,
               bd_datetime = SYSDATE - 2,
               bd_demo = 0,
               bd_mapsid = 'R',
               bd_pacsid2 = 'S',
               bd_srctype = 'MMSC';

        l_packing.pac_id := 'LIA_MMSC';
        test_data.crea_packing (l_packing);

        test_data.crea_sta_pacparam_scratch ();
        l_sta_pacparam.stap_pacid := 'LIA_MMSC';
        l_sta_pacparam.stap_name := '[BATCHCOUNT]';
        l_sta_pacparam.stap_value := TO_CHAR (10);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (60);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_setdetail_scratch ();

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_bdetail_mmsc.sp_try_lia_mmsc (
            p_pac_id                             => 'LIA_MMSC',
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_lia_mmsc_b;

    PROCEDURE sp_try_lia_mmsc_1008
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_mmsc.sp_try_lia_mmsc (
            p_pac_id                             => 'LIA_MMSC',
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ROLLBACK;
    END sp_try_lia_mmsc_1008;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_bdetail_mmsc;
/