CREATE OR REPLACE PACKAGE BODY test_pkg_bdetail_info
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sp_cons_is - pkg_bdetail_info.sp_cons_is]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_is
    IS
        l_bdetail                               bdetail%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_info.sp_cons_is (
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

        test_data.crea_isconsol_scratch ();

        COMMIT;

        pkg_bdetail_info.sp_cons_is (
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

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        test_data.crea_contract_scratch ();
        test_data.crea_isc_aggregation_scratch ();
        test_data.crea_isccdrtype_all ();

        test_data.crea_isconsol_scratch ();

        UPDATE isconsol
        SET    isc_cdrtid = test_data.gc_isccdrt_id
        WHERE  isc_id = test_data.gc_isc_id;

        test_data.crea_mapstate_all ();
        test_data.crea_setperiod ();

        l_bdetail.bd_conid := test_data.gc_con_id;
        l_bdetail.bd_mapsid := 'R';

       <<loop_bdetail>>
        FOR i IN 1 .. 2001
        LOOP
            l_bdetail.bd_id := pkg_common.generateuniquekey ('G');
            l_bdetail.bd_reqtype := i;
            test_data.crea_bdetail (l_bdetail);

            IF MOD (i, 500) = 0
            THEN
                COMMIT;
            END IF;
        END LOOP loop_bdetail;

        COMMIT;

        pkg_bdetail_info.sp_cons_is (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (2001);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_is;

    PROCEDURE sp_cons_is_after
    IS
    BEGIN
        -- 0
        test_data.del_bdetail_complete ();
        test_data.del_isc_aggregation_complete ();
        test_data.del_isccdrtype ();
        test_data.del_isconsol_complete ();

        -- 1
        test_data.del_setperiod_complete ();
        test_data.del_mapstate ();

        -- 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_is_after;

    /* =========================================================================
       Test: [Test method sp_cons_ismsisdn - pkg_bdetail_info.sp_cons_ismsisdn]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_ismsisdn
    IS
        l_bdetail                               bdetail%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_info.sp_cons_ismsisdn (
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

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_msisdn_a := 'ut_msisdn_x';
        l_bdetail.bd_shortid := 'ut_s_x';
        l_bdetail.bd_tpid := 'ut_tpid_x';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_contract_scratch ();

        COMMIT;

        pkg_bdetail_info.sp_cons_ismsisdn (
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

        test_data.crea_isccdrtype_all ();

        l_bdetail.bd_cdrtid := 'CTB-CO';
        l_bdetail.bd_conid := test_data.gc_con_id;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := test_data.gc_bd_msisdn_a;
        l_bdetail.bd_reqtype := 0;
        l_bdetail.bd_shortid := test_data.gc_bd_shortid;
        l_bdetail.bd_tpid := test_data.gc_bd_tpid;

       <<loop_bdetail_1>>
        FOR i IN 1 .. 10
        LOOP
            l_bdetail.bd_id := pkg_common.generateuniquekey ('G');
            l_bdetail.bd_birecno := i;
            test_data.crea_bdetail (l_bdetail);
        END LOOP loop_bdetail_1;

        l_bdetail.bd_reqtype := 999;

       <<loop_bdetail_2>>
        FOR i IN 1 .. 10
        LOOP
            l_bdetail.bd_id := pkg_common.generateuniquekey ('G');
            l_bdetail.bd_birecno := i;
            test_data.crea_bdetail (l_bdetail);
        END LOOP loop_bdetail_2;

        COMMIT;

        pkg_bdetail_info.sp_cons_ismsisdn (
            p_pac_id                             => NULL,
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
    END sp_cons_ismsisdn;

    PROCEDURE sp_cons_ismsisdn_after
    IS
    BEGIN
        -- 0
        test_data.del_bdetail_complete ();
        test_data.del_isccdrtype ();

        -- 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_ismsisdn_after;

    /* =========================================================================
       Test: [Test method sp_cons_tr - pkg_bdetail_info.sp_cons_tr]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_tr
    IS
        l_contract                              contract%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_isconsol                              isconsol%ROWTYPE;

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
        l_srctype                               srctype%ROWTYPE;
    BEGIN
        pkg_bdetail_info.sp_cons_tr (
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

        test_data.crea_trcstate_all;
        test_data.crea_trctype_all;
        test_data.crea_trconsol_scratch;

        COMMIT;

        pkg_bdetail_info.sp_cons_tr (
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

        test_data.crea_isccdrtype_all ();
        test_data.crea_iscstate_all ();

        l_setperiod.sep_date2 := TRUNC (SYSDATE, 'MONTH');
        test_data.crea_setperiod (l_setperiod);

        UPDATE setperiod
        SET    sep_date2 = TRUNC (SYSDATE, 'MONTH');

        test_data.crea_trdirection_all ();

        l_srctype.srct_id := 'ISRV';
        l_srctype.srct_code := 'ut_code_is';
        test_data.crea_srctype (l_srctype);

        test_data.crea_contract_scratch (p_complete_in => FALSE);
        l_contract.con_srctype := 'ISRV';
        test_data.crea_contract (l_contract);

        UPDATE contract
        SET    con_srctype = 'ISRV';

        l_isconsol.isc_conid := test_data.gc_con_id;
        l_isconsol.isc_cdrtid := 'CTB-MO';
        l_isconsol.isc_esid := 'R';
        l_isconsol.isc_sepid := test_data.gc_sep_id;
        l_isconsol.isc_transportmedium := 'SMS';

       <<loop_isconsol_1>>
        FOR i IN 1 .. 10
        LOOP
            l_isconsol.isc_id := pkg_common.generateuniquekey ('G');
            l_isconsol.isc_count := i;
            test_data.crea_isconsol (l_isconsol);
        END LOOP loop_isconsol_1;

        COMMIT;

        pkg_bdetail_info.sp_cons_tr (
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

        test_data.crea_isccdrtype_all ();

        l_isconsol.isc_cdrtid := 'CTB-CO';

       <<loop_isconsol_2>>
        FOR i IN 1 .. 10
        LOOP
            l_isconsol.isc_id := pkg_common.generateuniquekey ('G');
            l_isconsol.isc_count := i;
            test_data.crea_isconsol (l_isconsol);
        END LOOP loop_isconsol_2;

        COMMIT;

        pkg_bdetail_info.sp_cons_tr (
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

        test_data.crea_trctype_all ();

        l_isconsol.isc_cdrtid := 'CTB-MO';
        l_isconsol.isc_transportmedium := 'MMS';

       <<loop_isconsol_3>>
        FOR i IN 1 .. 10
        LOOP
            l_isconsol.isc_id := pkg_common.generateuniquekey ('G');
            l_isconsol.isc_count := i;
            test_data.crea_isconsol (l_isconsol);
        END LOOP loop_isconsol_3;

        COMMIT;

        pkg_bdetail_info.sp_cons_tr (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (3);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        l_isconsol.isc_cdrtid := 'CTB-CO';

       <<loop_isconsol_4>>
        FOR i IN 1 .. 10
        LOOP
            l_isconsol.isc_id := pkg_common.generateuniquekey ('G');
            l_isconsol.isc_count := i;
            test_data.crea_isconsol (l_isconsol);
        END LOOP loop_isconsol_4;

        COMMIT;

        pkg_bdetail_info.sp_cons_tr (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (4);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_tr;

    PROCEDURE sp_cons_tr_after
    IS
    BEGIN
        -- 0
        test_data.del_isconsol_complete ();
        test_data.del_trconsol_complete ();
        test_data.del_isccdrtype ();
        test_data.del_trctype ();
        test_data.del_trdirection ();

        -- 1
        test_data.del_iscstate ();
        test_data.del_setperiod_complete ();
        test_data.del_trcstate ();

        -- 2
        test_data.del_contract_complete ();
        test_data.del_srctype ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_tr_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_bdetail_info;
/
