CREATE OR REPLACE PACKAGE BODY test_pkg_reva
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sp_try_reva_recent_msc - pkg_reva.sp_try_reva_recent_msc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_reva_recent_msc_a
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
        l_reva_anastate                         reva_anastate%ROWTYPE;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_reva_billeditem_all ();
        test_data.crea_reva_billtype ();
        test_data.crea_reva_config_all ();

        test_data.crea_biheader_scratch ();
        test_data.crea_reva_anastate_scratch (p_complete_in => FALSE);
        test_data.crea_reva_anastate_all ();
        test_data.crea_reva_sigmask_scratch ();

        test_data.crea_reva_header_all ();

        l_reva_anastate.revast_id := 'S';
        l_reva_anastate.revast_srctype := 'MSC';
        test_data.crea_reva_anastate (l_reva_anastate);

        test_data.crea_bdetail4_scratch ();

        UPDATE bdetail4
        SET    bd_datetime = SYSDATE
        WHERE  bd_id = test_data.gc_bd_id;

        UPDATE biheader
        SET    bih_datetime = SYSDATE,
               bih_esid = 'RDY',
               bih_revasid = 'S',
               bih_srctype = 'MSC'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE reva_config
        SET    revac_batchnorecords = 1,
               revac_debugmode = 0,
               revac_runtimelimit = 300,
               revac_file_min_age = 0,
               revac_file_max_age = 90
        WHERE  revac_id = test_data.gc_revac_id;

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_reva.sp_try_reva_recent_msc (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_reva_recent_msc_a;

    PROCEDURE sp_try_reva_recent_msc_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail4_complete ();
        test_data.del_reva_sigmask_complete ();
        test_data.del_bihstate ();
        test_data.del_reva_billeditem ();
        test_data.del_reva_billtype ();

        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_reva_anastate_complete ();
        test_data.del_reva_header_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_try_reva_recent_msc_after;

    PROCEDURE sp_try_reva_recent_msc_b
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
        l_reva_anastate                         reva_anastate%ROWTYPE;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_reva_billeditem_all ();
        test_data.crea_reva_billtype ();
        test_data.crea_reva_config_all ();

        test_data.crea_biheader_scratch ();
        test_data.crea_reva_anastate_scratch (p_complete_in => FALSE);
        test_data.crea_reva_anastate_all ();
        test_data.crea_reva_sigmask_scratch ();

        test_data.crea_reva_header_all ();

        l_reva_anastate.revast_id := 'S';
        l_reva_anastate.revast_srctype := 'MSC';
        test_data.crea_reva_anastate (l_reva_anastate);

        test_data.crea_bdetail4_scratch ();

        UPDATE bdetail4
        SET    bd_datetime = SYSDATE
        WHERE  bd_id = test_data.gc_bd_id;

        UPDATE biheader
        SET    bih_datetime = SYSDATE,
               bih_esid = 'RDY',
               bih_revasid = 'S',
               bih_srctype = 'MSC'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE reva_config
        SET    revac_batchnorecords = 1,
               revac_debugmode = 1,
               revac_runtimelimit = 300,
               revac_file_min_age = 0,
               revac_file_max_age = 90
        WHERE  revac_id = test_data.gc_revac_id;

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_reva.sp_try_reva_recent_msc (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_reva_recent_msc_b;

    /* =========================================================================
       Test: [Test method sp_try_reva_recent_others - pkg_reva.sp_try_reva_recent_others]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_reva_recent_others
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
        l_reva_anastate                         reva_anastate%ROWTYPE;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_reva_billeditem_all ();
        test_data.crea_reva_billtype ();
        test_data.crea_reva_config_all ();

        test_data.crea_biheader_scratch ();
        test_data.crea_reva_anastate_scratch (p_complete_in => FALSE);
        test_data.crea_reva_anastate_all ();
        test_data.crea_reva_sigmask_scratch ();

        test_data.crea_reva_header_all ();

        l_reva_anastate.revast_id := 'S';
        l_reva_anastate.revast_srctype := 'ISRV';
        test_data.crea_reva_anastate (l_reva_anastate);

        test_data.crea_bdetail_scratch ();

        UPDATE bdetail
        SET    bd_datetime = SYSDATE
        WHERE  bd_id = test_data.gc_bd_id;

        UPDATE biheader
        SET    bih_datetime = SYSDATE,
               bih_esid = 'RDY',
               bih_revasid = 'S',
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE reva_config
        SET    revac_batchnorecords = 1,
               revac_debugmode = 0,
               revac_runtimelimit = 300,
               revac_file_min_age = 0,
               revac_file_max_age = 90
        WHERE  revac_id = test_data.gc_revac_id;

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_reva.sp_try_reva_recent_others (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_reva_recent_others;

    PROCEDURE sp_try_reva_recent_others_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_reva_sigmask_complete ();
        test_data.del_bihstate ();
        test_data.del_reva_billeditem ();
        test_data.del_reva_billtype ();

        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_reva_anastate_complete ();
        test_data.del_reva_header_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_try_reva_recent_others_after;

    /* =========================================================================
       Test: [Test method sp_try_reva_recent_smsc - pkg_reva.sp_try_reva_recent_smsc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_reva_recent_smsc
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
        l_reva_anastate                         reva_anastate%ROWTYPE;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_reva_billeditem_all ();
        test_data.crea_reva_billtype ();
        test_data.crea_reva_config_all ();

        test_data.crea_biheader_scratch ();
        test_data.crea_reva_anastate_scratch (p_complete_in => FALSE);
        test_data.crea_reva_anastate_all ();
        test_data.crea_reva_sigmask_scratch ();

        test_data.crea_reva_header_all ();

        l_reva_anastate.revast_id := 'S';
        l_reva_anastate.revast_srctype := 'SMSN';
        test_data.crea_reva_anastate (l_reva_anastate);

        test_data.crea_bdetail2_scratch ();

        UPDATE bdetail2
        SET    bd_datetime = SYSDATE
        WHERE  bd_id = test_data.gc_bd_id;

        UPDATE biheader
        SET    bih_datetime = SYSDATE,
               bih_esid = 'RDY',
               bih_revasid = 'S',
               bih_srctype = 'SMSN'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE reva_config
        SET    revac_batchnorecords = 1,
               revac_debugmode = 0,
               revac_runtimelimit = 300,
               revac_file_min_age = 0,
               revac_file_max_age = 90
        WHERE  revac_id = test_data.gc_revac_id;

        COMMIT;

        l_boh_id := test_data.gc_boh_id;

        pkg_reva.sp_try_reva_recent_smsc (
            p_pac_id                             => test_data.gc_pac_id,
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_reva_recent_smsc;

    PROCEDURE sp_try_reva_recent_smsc_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail2_complete ();
        test_data.del_reva_sigmask_complete ();
        test_data.del_bihstate ();
        test_data.del_reva_billeditem ();
        test_data.del_reva_billtype ();

        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_reva_anastate_complete ();
        test_data.del_reva_header_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_try_reva_recent_smsc_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_reva;
/