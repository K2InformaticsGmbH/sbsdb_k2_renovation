CREATE OR REPLACE PACKAGE BODY test_pkg_bdetail_msc
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sp_try_msccu - pkg_bdetail_msc.sp_try_msccu]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_msccu
    IS
        l_boheader                              boheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_packing                               packing%ROWTYPE;

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;

        l_sta_pacparam                          sta_pacparam%ROWTYPE;
    BEGIN
        test_data.crea_ctrstate_all ();
        test_data.crea_pactype_all ();
        test_data.crea_periodicity_all ();
        test_data.crea_smsc ();

        test_data.crea_packing_scratch (p_complete_in => FALSE);
        l_packing.pac_id := 'MSCCU';
        l_packing.pac_esid := 'A';
        l_packing.pac_etid := 'STATIND';
        l_packing.pac_execute := 1;
        l_packing.pac_periodid := test_data.gc_period_id;
        l_packing.pac_xprocid := NULL;
        test_data.crea_packing (l_packing);

        test_data.crea_sta_pacparam_scratch (p_complete_in => FALSE);
        l_sta_pacparam.stap_pacid := 'MSCCU';
        l_sta_pacparam.stap_name := '[BATCHCOUNT]';
        l_sta_pacparam.stap_value := TO_CHAR (10);
        test_data.crea_sta_pacparam (l_sta_pacparam);
        l_sta_pacparam.stap_name := '[MAXAGE]';
        l_sta_pacparam.stap_value := TO_CHAR (30);
        test_data.crea_sta_pacparam (l_sta_pacparam);

        test_data.crea_bdetail4_scratch ();

        UPDATE bdetail4
        SET    bd_cdrtid = 'MSC-MT',
               bd_datetime = SYSDATE,
               bd_demo = 0,
               bd_imsi = '228014711',
               bd_mapsid = 'R',
               bd_pacsid1 = 'S',
               bd_smscid = test_data.gc_smsc_id,
               bd_srctype = 'MSC'
        WHERE  bd_id = test_data.gc_bd_id;

        COMMIT;

        pkg_bdetail_msc.sp_try_msccu (
            p_pac_id                             => 'MSCCU',
            p_boh_id                             => l_boheader.boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (1003);
        ut.expect (l_errormsg).to_equal ('The desired operation cannot be executed at this time. Try later.');
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (2);

        ROLLBACK;

        test_data.crea_bohstate_all ();

        test_data.crea_sta_config ();

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        pkg_bdetail_msc.sp_try_msccu (
            p_pac_id                             => 'MSCCU',
            p_boh_id                             => l_boheader.boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_try_msccu;

    PROCEDURE sp_try_msccu_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bdetail4_complete ();
        test_data.del_boheader_complete ();
        test_data.del_sta_pacparam_complete ();
        test_data.del_periodicity ();
        test_data.del_sta_config ();

        -- Level 1
        test_data.del_smsc_complete ();
        test_data.del_sta_job_complete ();
        test_data.del_bohstate ();
        test_data.del_ctrstate ();

        -- Level 2
        test_data.del_packing_complete ();
        test_data.del_packingstate ();
        test_data.del_pactype ();

        -- Level 3
        test_data.del_looptype ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_try_msccu_after;

    PROCEDURE sp_try_msccu_1008
    IS
        l_boheader                              boheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_msc.sp_try_msccu (
            p_pac_id                             => 'MSCCU',
            p_boh_id                             => l_boheader.boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ROLLBACK;
    END sp_try_msccu_1008;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_bdetail_msc;
/
