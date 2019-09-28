CREATE OR REPLACE PACKAGE BODY test_pkg_bdetail_settlement
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method nextavailableorder - pkg_bdetail_settlement.nextavailableorder]].
       ---------------------------------------------------------------------- */

    PROCEDURE nextavailableorder
    IS
        lc_sysdate                              DATE := SYSDATE;

        l_existing_order                        DATE;
        l_result                                VARCHAR2 (50);
    BEGIN
        l_result := pkg_bdetail_settlement.nextavailableorder (p_sed_charge => NULL, p_sed_date => NULL);

        ut.expect (l_result).to_be_null ();

        ROLLBACK;

        l_result := pkg_bdetail_settlement.nextavailableorder (p_sed_charge => '2106', p_sed_date => lc_sysdate);

        ut.expect (l_result).to_equal (TO_CHAR (TRUNC (lc_sysdate) + 1 - 1 / 24 / 3600, 'yyyy-mm-dd hh24:mi:ss'));

        ROLLBACK;
    END nextavailableorder;

    PROCEDURE nextavailableorder_after
    IS
    BEGIN
        test_data.del_setdetail_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END nextavailableorder_after;

    /* =========================================================================
       Test: [Test method settledduration - pkg_bdetail_settlement.settledduration]].
       ---------------------------------------------------------------------- */

    PROCEDURE settledduration
    IS
        l_con_dateend                           DATE;
        l_con_datestart                         DATE;

        l_expected                              PLS_INTEGER;

        l_result                                PLS_INTEGER;
    BEGIN
        l_con_datestart := NULL;
        l_con_dateend := NULL;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := NULL;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := NULL;
        l_con_dateend := SYSDATE;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE + 1;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE + 30;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE + 60;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE + 120;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE - 1;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE - 30;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE - 60;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;

        l_con_datestart := SYSDATE;
        l_con_dateend := SYSDATE;
        l_expected :=
              LEAST (NVL (l_con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
            - GREATEST (NVL (l_con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'));
        l_result := pkg_bdetail_settlement.settledduration (con_datestart => l_con_datestart, con_dateend => l_con_dateend);
        ut.expect (l_result).to_equal (l_expected);

        ROLLBACK;
    END settledduration;

    /* =========================================================================
       Test: [Test method sp_add_setdetail - pkg_bdetail_settlement.sp_add_setdetail]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_setdetail
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;

        l_setperiod                             setperiod%ROWTYPE;
    BEGIN
        test_data.crea_contract_scratch ();
        test_data.crea_longid_scratch ();
        test_data.crea_settling_scratch ();

        test_data.crea_bostate_all ();
        test_data.crea_sedstate_all ();
        test_data.crea_sedtype_all ();

        l_setperiod.sep_id := TO_CHAR (TRUNC (SYSDATE, 'MONTH'), 'YYYYMM');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_setstate_all ();
        test_data.crea_settype_all ();
        test_data.crea_vatcode ();

        COMMIT;

        pkg_bdetail_settlement.sp_add_setdetail (
            p_set_etid                           => test_data.gc_sett_id,
            p_sed_etid                           => 'CDRA',
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_date                               => SYSDATE,
            p_set_conid                          => test_data.gc_con_id,
            p_sed_tarid                          => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_price                          => 0.23,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid                         => test_data.gc_long_id,
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_desc                           => 'ut_desc_a',
            p_gart                               => NULL,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        pkg_bdetail_settlement.sp_add_setdetail (
            p_set_etid                           => test_data.gc_sett_id,
            p_sed_etid                           => 'CDR',
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_date                               => SYSDATE,
            p_set_conid                          => test_data.gc_con_id,
            p_sed_tarid                          => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_price                          => 0.23,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid                         => test_data.gc_long_id,
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_desc                           => 'ut_desc_a',
            p_gart                               => NULL,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        pkg_bdetail_settlement.sp_add_setdetail (
            p_set_etid                           => test_data.gc_sett_id,
            p_sed_etid                           => 'MCC',
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_date                               => SYSDATE,
            p_set_conid                          => test_data.gc_con_id,
            p_sed_tarid                          => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_price                          => 0.23,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid                         => test_data.gc_long_id,
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_desc                           => 'ut_desc_a',
            p_gart                               => NULL,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        pkg_bdetail_settlement.sp_add_setdetail (
            p_set_etid                           => test_data.gc_sett_id,
            p_sed_etid                           => 'IOTLACT',
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_date                               => SYSDATE,
            p_set_conid                          => test_data.gc_con_id,
            p_sed_tarid                          => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_price                          => 0,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid                         => test_data.gc_long_id,
            p_sed_count1                         => 0,
            p_sed_count2                         => 0,
            p_sed_desc                           => 'ut_desc_a',
            p_gart                               => NULL,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_add_setdetail;

    /* =========================================================================
       Test: [Test method sp_add_setdetail - pkg_bdetail_settlement.sp_add_setdetail]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_setdetail_01403
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_settlement.sp_add_setdetail (
            p_set_etid                           => NULL,
            p_sed_etid                           => NULL,
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_date                               => NULL,
            p_set_conid                          => NULL,
            p_sed_tarid                          => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_price                          => NULL,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid                         => NULL,
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_desc                           => NULL,
            p_gart                               => NULL,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_add_setdetail_01403;

    PROCEDURE sp_add_setdetail_after
    IS
    BEGIN
        -- Level 0
        test_data.del_sedstate ();

        -- Level 1
        test_data.del_longid_complete ();
        test_data.del_setperiod_complete ();
        test_data.del_settling_complete ();
        test_data.del_bostate ();
        test_data.del_sedtype ();
        test_data.del_settype ();
        test_data.del_vatcode ();

        -- Level 2
        test_data.del_contract_complete ();
        test_data.del_setstate ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_add_setdetail_after;

    /* =========================================================================
       Test: [Test method sp_add_setdetail_by_date - pkg_bdetail_settlement.sp_add_setdetail_by_date]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_setdetail_by_date
    IS
        lc_long_id_special             CONSTANT longid.long_id%TYPE := 41798070000;
        lc_sysdate                     CONSTANT VARCHAR2 (21) := TO_CHAR (SYSDATE, 'YYYY-MM-DD HH24:MI:SS');

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_longid                                longid%ROWTYPE;

        l_returnstatus                          PLS_INTEGER;

        l_sed_id                                setdetail.sed_id%TYPE;
        l_sed_pos                               setdetail.sed_pos%TYPE;
        l_sep_id                                setperiod.sep_id%TYPE;
        l_set_id                                settling.set_id%TYPE;
        l_setperiod                             setperiod%ROWTYPE;
    BEGIN
        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();

        test_data.crea_longid_scratch ();
        l_longid.long_id := lc_long_id_special;
        test_data.crea_longid (l_longid);
        test_data.crea_sedtype_all ();

        l_setperiod.sep_id := TO_CHAR (TRUNC (SYSDATE, 'MONTH'), 'YYYYMM');
        test_data.crea_setperiod (l_setperiod);

        test_data.crea_sedstate_all ();
        test_data.crea_setstate_all ();
        test_data.crea_settype_all ();
        test_data.crea_tariff_all ();
        test_data.crea_vatcode ();

        COMMIT;

        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => lc_sysdate,
            p_set_conid                          => test_data.gc_con_id,
            p_set_etid                           => test_data.gc_sett_id,
            p_set_demo                           => test_data.gc_demo,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => 'CDRA',
            p_sed_price                          => 0.23,
            p_sed_quantity                       => 1,
            p_sed_discount                       => 0,
            p_sed_vatid                          => test_data.gc_vat_id,
            p_sed_vatrate                        => 8,
            p_sed_desc                           => NULL,
            p_sed_order                          => NULL,
            p_sed_visible                        => 1,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => NULL,
            p_sed_esid                           => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => NULL,
            p_sed_longid_2                       => NULL,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => lc_sysdate,
            p_set_conid                          => test_data.gc_con_id,
            p_set_etid                           => test_data.gc_sett_id,
            p_set_demo                           => test_data.gc_demo,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => 'CDRA',
            p_sed_price                          => 0.23,
            p_sed_quantity                       => 1,
            p_sed_discount                       => 0,
            p_sed_vatid                          => test_data.gc_vat_id,
            p_sed_vatrate                        => 8,
            p_sed_desc                           => NULL,
            p_sed_order                          => NULL,
            p_sed_visible                        => 1,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => '4711',
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => test_data.gc_tar_id,
            p_sed_esid                           => NULL,
            p_sed_int                            => 0,
            p_sed_prepaid                        => 'U',
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => lc_long_id_special,
            p_sed_longid_2                       => NULL,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => lc_sysdate,
            p_set_conid                          => test_data.gc_con_id,
            p_set_etid                           => test_data.gc_sett_id,
            p_set_demo                           => test_data.gc_demo,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => 'CDRA',
            p_sed_price                          => 0.23,
            p_sed_quantity                       => 1,
            p_sed_discount                       => 0,
            p_sed_vatid                          => test_data.gc_vat_id,
            p_sed_vatrate                        => 8,
            p_sed_desc                           => NULL,
            p_sed_order                          => NULL,
            p_sed_visible                        => 1,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => '4711',
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => test_data.gc_tar_id,
            p_sed_esid                           => NULL,
            p_sed_int                            => 0,
            p_sed_prepaid                        => 'U',
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => test_data.gc_long_id,
            p_sed_longid_2                       => test_data.gc_long_id,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => lc_sysdate,
            p_set_conid                          => test_data.gc_con_id,
            p_set_etid                           => test_data.gc_sett_id,
            p_set_demo                           => test_data.gc_demo,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => 'CDRA',
            p_sed_price                          => 0.23,
            p_sed_quantity                       => 1,
            p_sed_discount                       => 0,
            p_sed_vatid                          => test_data.gc_vat_id,
            p_sed_vatrate                        => 8,
            p_sed_desc                           => NULL,
            p_sed_order                          => NULL,
            p_sed_visible                        => 1,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => '4711',
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => test_data.gc_tar_id,
            p_sed_esid                           => NULL,
            p_sed_int                            => 0,
            p_sed_prepaid                        => 'U',
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => test_data.gc_long_id,
            p_sed_longid_2                       => NULL,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        UPDATE setdetail
        SET    sed_charge = '4711',
               sed_date = TRUNC (TO_DATE (lc_sysdate, 'yyyy-mm-dd hh24:mi:ss')),
               sed_esid = 'A',
               sed_etid = 'CDRA',
               sed_int = 0,
               sed_longid = test_data.gc_long_id,
               sed_longid2 = test_data.gc_long_id,
               sed_prepaid = 'U',
               sed_setid = test_data.gc_set_id,
               sed_tarid = test_data.gc_tar_id
        WHERE  sed_id = test_data.gc_sed_id;

        UPDATE settling
        SET    set_conid = test_data.gc_con_id,
               set_demo = test_data.gc_demo,
               set_esid = 'A',
               set_etid = test_data.gc_sett_id,
               set_sepid = l_setperiod.sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => lc_sysdate,
            p_set_conid                          => test_data.gc_con_id,
            p_set_etid                           => test_data.gc_sett_id,
            p_set_demo                           => test_data.gc_demo,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => 'CDRA',
            p_sed_price                          => 0.23,
            p_sed_quantity                       => 1,
            p_sed_discount                       => 0,
            p_sed_vatid                          => test_data.gc_vat_id,
            p_sed_vatrate                        => 8,
            p_sed_desc                           => NULL,
            p_sed_order                          => NULL,
            p_sed_visible                        => 1,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => '4711',
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => test_data.gc_tar_id,
            p_sed_esid                           => NULL,
            p_sed_int                            => 0,
            p_sed_prepaid                        => 'U',
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => test_data.gc_long_id,
            p_sed_longid_2                       => test_data.gc_long_id,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => lc_sysdate,
            p_set_conid                          => test_data.gc_con_id,
            p_set_etid                           => test_data.gc_sett_id,
            p_set_demo                           => test_data.gc_demo,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => 'CDRA',
            p_sed_price                          => 0.23,
            p_sed_quantity                       => 1,
            p_sed_discount                       => 0,
            p_sed_vatid                          => test_data.gc_vat_id,
            p_sed_vatrate                        => 8,
            p_sed_desc                           => 'accumulating',
            p_sed_order                          => NULL,
            p_sed_visible                        => 1,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => '4711',
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => test_data.gc_tar_id,
            p_sed_esid                           => NULL,
            p_sed_int                            => 0,
            p_sed_prepaid                        => 'U',
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => test_data.gc_long_id,
            p_sed_longid_2                       => test_data.gc_long_id,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_add_setdetail_by_date;

    PROCEDURE sp_add_setdetail_by_date_01403
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;

        l_sed_id                                setdetail.sed_id%TYPE;
        l_sed_pos                               setdetail.sed_pos%TYPE;
        l_sep_id                                setperiod.sep_id%TYPE;
        l_set_id                                settling.set_id%TYPE;
    BEGIN
        pkg_bdetail_settlement.sp_add_setdetail_by_date (
            p_date                               => NULL,
            p_set_conid                          => NULL,
            p_set_etid                           => NULL,
            p_set_demo                           => NULL,
            p_set_currency                       => NULL,
            p_set_comment                        => 'ut_comment_a',
            p_sed_etid                           => NULL,
            p_sed_price                          => NULL,
            p_sed_quantity                       => NULL,
            p_sed_discount                       => NULL,
            p_sed_vatid                          => NULL,
            p_sed_vatrate                        => NULL,
            p_sed_desc                           => NULL,
            p_sed_order                          => NULL,
            p_sed_visible                        => NULL,
            p_sed_comment                        => 'ut_comment_a',
            p_sed_count1                         => NULL,
            p_sed_count2                         => NULL,
            p_sed_charge                         => NULL,
            p_sed_bohid                          => NULL,
            p_sed_pmvid                          => NULL,
            p_sed_tarid                          => NULL,
            p_sed_esid                           => NULL,
            p_sed_int                            => NULL,
            p_sed_prepaid                        => NULL,
            p_sed_amountcu                       => NULL,
            p_sed_retsharepv                     => NULL,
            p_sed_retsharemo                     => NULL,
            p_sed_longid_1                       => NULL,
            p_sed_longid_2                       => NULL,
            p_sep_id                             => l_sep_id,
            p_set_id                             => l_set_id,
            p_sed_id                             => l_sed_id,
            p_sed_pos                            => l_sed_pos,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_add_setdetail_by_date_01403;

    PROCEDURE sp_add_setdetail_by_date_after
    IS
    BEGIN
        -- Level 0
        test_data.del_setdetail_complete ();
        test_data.del_sedstate ();

        -- Level 1
        test_data.del_longid_complete ();
        test_data.del_setperiod_complete ();
        test_data.del_tariff_complete ();
        test_data.del_sedtype ();
        test_data.del_settype ();
        test_data.del_vatcode ();

        -- Level 2
        test_data.del_contract_complete ();
        test_data.del_setstate ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_add_setdetail_by_date_after;

    /* =========================================================================
       Test: [Test method sp_cons_insert_period - pkg_bdetail_settlement.sp_cons_insert_period]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_insert_period
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_settlement.sp_cons_insert_period (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_cons_insert_period;

    /* =========================================================================
       Test: [Test method sp_lam_mcc - pkg_bdetail_settlement.sp_lam_mcc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_lam_mcc_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_settlement.sp_lam_mcc (
            p_pac_id                             => NULL,
            p_boh_id                             => test_data.gc_boh_id,
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_lam_mcc_a;

    PROCEDURE sp_lam_mcc_after
    IS
    BEGIN
        -- Level 0
        test_data.del_setdetail_complete ();
        test_data.del_bostate ();

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
    END sp_lam_mcc_after;

    PROCEDURE sp_lam_mcc_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();
        test_data.crea_settling_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        UPDATE setdetail
        SET    sed_etid = 'CDR',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        UPDATE settling
        SET    set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lam_mcc (
            p_pac_id                             => NULL,
            p_boh_id                             => test_data.gc_boh_id,
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (-1);
        ut.expect (l_errormsg).to_be_like ('ORA-00001: % (SBS1_ADMIN.IDXU_SET_CONID)%');
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;
    END sp_lam_mcc_b;

    PROCEDURE sp_lam_mcc_c
    IS
        l_contract                              contract%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bostate_all ();
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();
        test_data.crea_settling_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 0,
               con_mcapplied = 1,
               con_pscall = '4711',
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        l_contract.con_id := 'ut_id_b';
        l_contract.con_pscall := '4711';
        test_data.crea_contract (l_contract);

        UPDATE setdetail
        SET    sed_charge = '4711',
               sed_etid = 'CDR',
               sed_order = TO_CHAR (TRUNC (SYSDATE, 'MONTH') - 1, 'YYYY-MM-DD') || ' 12:00:00',
               sed_total = 0
        WHERE  sed_id = test_data.gc_sed_id;

        UPDATE settling
        SET    set_conid = l_contract.con_id,
               set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lam_mcc (
            p_pac_id                             => NULL,
            p_boh_id                             => test_data.gc_boh_id,
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_lam_mcc_c;

    PROCEDURE sp_lam_mcc_d
    IS
        l_contract                              contract%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bostate_all ();
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();
        test_data.crea_settling_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        l_contract.con_id := 'ut_id_b';
        l_contract.con_pscall := '4711';
        test_data.crea_contract (l_contract);

        UPDATE setdetail
        SET    sed_etid = 'CDR',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        UPDATE settling
        SET    set_conid = l_contract.con_id,
               set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lam_mcc (
            p_pac_id                             => NULL,
            p_boh_id                             => test_data.gc_boh_id,
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_lam_mcc_d;

    /* =========================================================================
       Test: [Test method sp_lapmcc - pkg_bdetail_settlement.sp_lapmcc]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_lapmcc_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_settlement.sp_lapmcc (
            p_pac_id                             => 'LAPMCC_SMS',
            p_boh_id                             => NULL,
            p_set_etid                           => 'MLA',
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_lapmcc_a;

    PROCEDURE sp_lapmcc_after
    IS
    BEGIN
        -- Level 1
        test_data.del_tariff_complete ();

        -- Level 2
        test_data.del_contract_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_lapmcc_after;

    PROCEDURE sp_lapmcc_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_enumerator_all ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_pscall = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lapmcc (
            p_pac_id                             => 'LAPMCC_SMS',
            p_boh_id                             => NULL,
            p_set_etid                           => 'MLA',
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_lapmcc_b;

    /* =========================================================================
       Test: [Test method sp_lat_cdr - pkg_bdetail_settlement.sp_lat_cdr]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_lat_cdr_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
    BEGIN
        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => NULL,
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 30,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);

        ROLLBACK;
    END sp_lat_cdr_a;

    PROCEDURE sp_lat_cdr_after
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
    END sp_lat_cdr_after;

    PROCEDURE sp_lat_cdr_b
    IS
        l_contract                              contract%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();
        test_data.crea_settling_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        l_contract.con_id := 'ut_id_b';
        l_contract.con_pscall := '4711';
        test_data.crea_contract (l_contract);

        UPDATE setdetail
        SET    sed_count1 = 1,
               sed_count2 = 2,
               sed_etid = 'CDR',
               sed_gohid = 'wwe',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        UPDATE settling
        SET    set_conid = l_contract.con_id,
               set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);

        ROLLBACK;

        UPDATE setdetail
        SET    sed_int = '1'
        WHERE  sed_id = test_data.gc_sed_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);

        ROLLBACK;

        UPDATE setdetail
        SET    sed_etid = 'MOFNA'
        WHERE  sed_id = test_data.gc_sed_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);

        ROLLBACK;

        UPDATE setdetail
        SET    sed_etid = 'MFGRA'
        WHERE  sed_id = test_data.gc_sed_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);

        ROLLBACK;

        UPDATE setdetail
        SET    sed_etid = 'MFLIDA'
        WHERE  sed_id = test_data.gc_sed_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lat_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);

        ROLLBACK;
    END sp_lat_cdr_b;

    /* =========================================================================
       Test: [Test method sp_lit_cdr - pkg_bdetail_settlement.sp_lit_cdr]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_lit_cdr_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
    BEGIN
        pkg_bdetail_settlement.sp_lit_cdr (
            p_bd_bohid                           => NULL,
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 30,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);

        ROLLBACK;
    END sp_lit_cdr_a;

    PROCEDURE sp_lit_cdr_after
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
    END sp_lit_cdr_after;

    PROCEDURE sp_lit_cdr_b
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
    BEGIN
        test_data.crea_setperiod ();
        test_data.crea_tariff_all ();

        test_data.crea_contract_scratch ();
        test_data.crea_setdetail_scratch ();
        test_data.crea_settling_scratch ();

        UPDATE contract
        SET    con_etid = 'MLC',
               con_hdgroup = 1,
               con_mcapplied = 1,
               con_tarid = test_data.gc_tar_id
        WHERE  con_id = test_data.gc_con_id;

        UPDATE setdetail
        SET    sed_count1 = 1,
               sed_count2 = 2,
               sed_etid = 'CDR',
               sed_gohid = 'wwe',
               sed_order = TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYY-MM-DD')
        WHERE  sed_id = test_data.gc_sed_id;

        UPDATE settling
        SET    set_sepid = test_data.gc_sep_id
        WHERE  set_id = test_data.gc_set_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lit_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_equal (-1);
        ut.expect (l_errormsg).to_be_like ('ORA-00001: % (SBS1_ADMIN.IDXU_SET_CONID)%');
        ut.expect (l_recordsaffected).to_equal (0);

        ROLLBACK;

        UPDATE setdetail
        SET    sed_etid = 'MOFNA'
        WHERE  sed_id = test_data.gc_sed_id;

        COMMIT;

        pkg_bdetail_settlement.sp_lit_cdr (
            p_bd_bohid                           => 'wwe',
            p_set_etid                           => 'MLA',
            p_gart                               => 0,
            p_minage                             => 0,
            p_maxage                             => 60,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            recordsaffected                      => l_recordsaffected);

        ut.expect (l_errorcode).to_equal (-1);
        ut.expect (l_errormsg).to_be_like ('ORA-00001: % (SBS1_ADMIN.IDXU_SET_CONID)%');
        ut.expect (l_recordsaffected).to_equal (0);

        ROLLBACK;
    END sp_lit_cdr_b;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */

BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_bdetail_settlement;
/