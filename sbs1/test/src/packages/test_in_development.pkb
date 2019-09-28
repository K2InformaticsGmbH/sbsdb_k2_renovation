CREATE OR REPLACE PACKAGE BODY test_in_development
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
        Public Procedure Implementation.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lat_cdr_b
    IS
        l_contract                              contract%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
    BEGIN
    dbms_output.put_line('wwe_000');
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

    dbms_output.put_line('wwe_100');
        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();
        test_data.crea_settling_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

    dbms_output.put_line('wwe_200');
        l_contract.con_id := 'ut_id_b';
        l_contract.con_pscall := '4711';
        test_data.crea_contract (l_contract);

    dbms_output.put_line('wwe_300');
        UPDATE setdetail
        SET    sed_count1 = 1,
               sed_count2 = 2,
               sed_etid = 'CDR',
               sed_gohid = 'wwe',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

    dbms_output.put_line('wwe_400');
        UPDATE settling
        SET    set_conid = l_contract.con_id,
               set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

    dbms_output.put_line('wwe_500');
        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

    dbms_output.put_line('wwe_600');
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);

        ROLLBACK;
--
--        UPDATE setdetail
--        SET    sed_int = '1'
--        WHERE  sed_id = test_data.gc_sed_id;
--
--        COMMIT;
--
--        pkg_bdetail_settlement.sp_lat_cdr (
--            p_bd_bohid                           => 'wwe',
--            p_set_etid                           => 'MLA',
--            p_gart                               => 0,
--            p_minage                             => 0,
--            p_maxage                             => 60,
--            errorcode                            => l_errorcode,
--            errormsg                             => l_errormsg,
--            recordsaffected                      => l_recordsaffected);
--
--        ut.expect (l_errorcode).to_be_null ();
--        ut.expect (l_errormsg).to_be_null ();
--        ut.expect (l_recordsaffected).to_equal (1);
--
--        ROLLBACK;
--
--        UPDATE setdetail
--        SET    sed_etid = 'MOFNA'
--        WHERE  sed_id = test_data.gc_sed_id;
--
--        COMMIT;
--
--        pkg_bdetail_settlement.sp_lat_cdr (
--            p_bd_bohid                           => 'wwe',
--            p_set_etid                           => 'MLA',
--            p_gart                               => 0,
--            p_minage                             => 0,
--            p_maxage                             => 60,
--            errorcode                            => l_errorcode,
--            errormsg                             => l_errormsg,
--            recordsaffected                      => l_recordsaffected);
--
--        ut.expect (l_errorcode).to_be_null ();
--        ut.expect (l_errormsg).to_be_null ();
--        ut.expect (l_recordsaffected).to_equal (1);
--
--        ROLLBACK;
--
--        UPDATE setdetail
--        SET    sed_etid = 'MFGRA'
--        WHERE  sed_id = test_data.gc_sed_id;
--
--        COMMIT;
--
--        pkg_bdetail_settlement.sp_lat_cdr (
--            p_bd_bohid                           => 'wwe',
--            p_set_etid                           => 'MLA',
--            p_gart                               => 0,
--            p_minage                             => 0,
--            p_maxage                             => 60,
--            errorcode                            => l_errorcode,
--            errormsg                             => l_errormsg,
--            recordsaffected                      => l_recordsaffected);
--
--        ut.expect (l_errorcode).to_be_null ();
--        ut.expect (l_errormsg).to_be_null ();
--        ut.expect (l_recordsaffected).to_equal (1);
--
--        ROLLBACK;
--
--        UPDATE setdetail
--        SET    sed_etid = 'MFLIDA'
--        WHERE  sed_id = test_data.gc_sed_id;
--
--        COMMIT;
--
--        pkg_bdetail_settlement.sp_lat_cdr (
--            p_bd_bohid                           => 'wwe',
--            p_set_etid                           => 'MLA',
--            p_gart                               => 0,
--            p_minage                             => 0,
--            p_maxage                             => 60,
--            errorcode                            => l_errorcode,
--            errormsg                             => l_errormsg,
--            recordsaffected                      => l_recordsaffected);
--
--        ut.expect (l_errorcode).to_be_null ();
--        ut.expect (l_errormsg).to_be_null ();
--        ut.expect (l_recordsaffected).to_equal (1);
--
--        ROLLBACK;
    END sp_lat_cdr_b;


BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_in_development;
/
