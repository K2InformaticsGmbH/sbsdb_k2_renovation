CREATE OR REPLACE PACKAGE BODY test_pkg_bdetail_common
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method contract_iot_chf_mms - contract_iot_chf]].
       ---------------------------------------------------------------------- */

    PROCEDURE contract_iot_chf_after
    IS
    BEGIN
        -- 0
        test_data.del_coniote_complete ();
        test_data.del_exchangerate_complete ();
        test_data.del_iwdirection ();
        test_data.del_trctype ();

        -- 1
        test_data.del_currency ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END contract_iot_chf_after;

    PROCEDURE contract_iot_chf_mms
    IS
        l_coniote                               coniote%ROWTYPE;
        l_exchangerate                          exchangerate%ROWTYPE;
    BEGIN
        test_data.crea_exchangerate_scratch (p_complete_in => FALSE);

        l_exchangerate.exr_curid := test_data.gc_cur_id;
        l_exchangerate.exr_value := 1;
        l_exchangerate.exr_start := TO_DATE ('01.06.51', 'dd.mm.yy');
        l_exchangerate.exr_end := TO_DATE ('30.06.51', 'dd.mm.yy');
        test_data.crea_exchangerate (l_exchangerate);

        test_data.crea_iwdirection_all ();

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'MMS',
                p_date                               => TO_DATE ('21.06.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_be_null ();

        test_data.crea_coniote_scratch (p_complete_in => FALSE);

        test_data.crea_trctype_all ();

        UPDATE coniot
        SET    ciot_curid = test_data.gc_cur_id,
               ciot_iwdid = 'ORIG',
               ciot_trctid = 'MMS'
        WHERE  ciot_id = test_data.gc_ciot_id;

        l_coniote.ciote_id := test_data.gc_ciote_id || '1';
        l_coniote.ciote_ciotid := test_data.gc_ciot_id;
        l_coniote.ciote_msgsize_max := 300;
        l_coniote.ciote_price := 0.4;
        test_data.crea_coniote (l_coniote);

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'MMS',
                p_date                               => TO_DATE ('21.06.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_equal (0.8);

        l_coniote.ciote_id := test_data.gc_ciote_id || '2';
        l_coniote.ciote_msgsize_max := 30;
        l_coniote.ciote_price := 0.23;
        test_data.crea_coniote (l_coniote);

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'MMS',
                p_date                               => TO_DATE ('21.06.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_equal (0.46);

        l_coniote.ciote_id := test_data.gc_ciote_id || '3';
        l_coniote.ciote_msgsize_max := 3;
        l_coniote.ciote_price := 0.1;
        test_data.crea_coniote (l_coniote);

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'MMS',
                p_date                               => TO_DATE ('21.05.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_be_null ();

        ROLLBACK;
    END contract_iot_chf_mms;

    /* =========================================================================
       Test: [Test method contract_iot_chf_sms - contract_iot_chf]].
       ---------------------------------------------------------------------- */

    PROCEDURE contract_iot_chf_sms
    IS
        l_coniote                               coniote%ROWTYPE;
        l_exchangerate                          exchangerate%ROWTYPE;
    BEGIN
        test_data.crea_exchangerate_scratch (p_complete_in => FALSE);

        l_exchangerate.exr_curid := test_data.gc_cur_id;
        l_exchangerate.exr_value := 1;
        l_exchangerate.exr_start := TO_DATE ('01.06.51', 'dd.mm.yy');
        l_exchangerate.exr_end := TO_DATE ('30.06.51', 'dd.mm.yy');
        test_data.crea_exchangerate (l_exchangerate);

        test_data.crea_iwdirection_all ();

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'SMS',
                p_date                               => TO_DATE ('21.06.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_be_null ();

        test_data.crea_coniote_scratch (p_complete_in => FALSE);

        test_data.crea_trctype_all ();

        UPDATE coniot
        SET    ciot_curid = test_data.gc_cur_id,
               ciot_iwdid = 'ORIG',
               ciot_trctid = 'SMS'
        WHERE  ciot_id = test_data.gc_ciot_id;

        l_coniote.ciote_id := test_data.gc_ciote_id || '1';
        l_coniote.ciote_ciotid := test_data.gc_ciot_id;
        l_coniote.ciote_price := 1;
        test_data.crea_coniote (l_coniote);

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'SMS',
                p_date                               => TO_DATE ('21.06.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_equal (2);

        l_coniote.ciote_id := test_data.gc_ciote_id || '3';
        l_coniote.ciote_price := 3;
        test_data.crea_coniote (l_coniote);

        COMMIT;

        ut.expect (
            pkg_bdetail_common.contract_iot_chf (
                p_con_id                             => test_data.gc_ciot_id,
                p_iwdid                              => 'ORIG',
                p_trctid                             => 'SMS',
                p_date                               => TO_DATE ('21.05.51', 'dd.mm.yy'),
                p_msgsize                            => 0)).to_be_null ();

        ROLLBACK;
    END contract_iot_chf_sms;

    /* =========================================================================
       Test: [Test method contractperiodend - contractperiodend]].
       ---------------------------------------------------------------------- */

    PROCEDURE contractperiodend
    IS
        lc_period_end_date             CONSTANT DATE := TRUNC (SYSDATE, 'MONTH');
    BEGIN
        ut.expect (pkg_bdetail_common.contractperiodend (NULL)).to_equal (lc_period_end_date);

        -- two months in the past
        ut.expect (pkg_bdetail_common.contractperiodend (ADD_MONTHS (SYSDATE, -2))).to_be_null ();
        -- last day of the month in before-previous month
        ut.expect (pkg_bdetail_common.contractperiodend (LAST_DAY (ADD_MONTHS (SYSDATE, -2)))).to_be_null ();

        -- first day of previous month
        ut.expect (pkg_bdetail_common.contractperiodend (LAST_DAY (ADD_MONTHS (SYSDATE, -2)) + 1)).to_equal (LAST_DAY (ADD_MONTHS (SYSDATE, -2)) + 1);
        -- same day as today of previous month
        ut.expect (pkg_bdetail_common.contractperiodend (ADD_MONTHS (SYSDATE, -1))).to_equal (ADD_MONTHS (SYSDATE, -1));

        -- first day of current month
        ut.expect (pkg_bdetail_common.contractperiodend (LAST_DAY (ADD_MONTHS (SYSDATE, -1)) + 1)).to_equal (lc_period_end_date);
        -- today
        ut.expect (pkg_bdetail_common.contractperiodend (SYSDATE)).to_equal (lc_period_end_date);

        ROLLBACK;
    END contractperiodend;

    /* =========================================================================
       Test: [Test method contractperiodstart - contractperiodstart]].
       ---------------------------------------------------------------------- */

    PROCEDURE contractperiodstart
    IS
        lc_period_start_date           CONSTANT DATE := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -1);
    BEGIN
        ut.expect (pkg_bdetail_common.contractperiodstart (NULL)).to_equal (lc_period_start_date);

        -- two months in the past
        ut.expect (pkg_bdetail_common.contractperiodstart (ADD_MONTHS (SYSDATE, -2))).to_equal (lc_period_start_date);
        -- last day of the month in before-previous month
        ut.expect (pkg_bdetail_common.contractperiodstart (LAST_DAY (ADD_MONTHS (SYSDATE, -2)))).to_equal (lc_period_start_date);

        -- first day of previous month
        ut.expect (pkg_bdetail_common.contractperiodstart (LAST_DAY (ADD_MONTHS (SYSDATE, -2)) + 1)).to_equal (LAST_DAY (ADD_MONTHS (SYSDATE, -2)) + 1);
        -- same day as today of previous month
        ut.expect (pkg_bdetail_common.contractperiodstart (ADD_MONTHS (SYSDATE, -1))).to_equal (ADD_MONTHS (SYSDATE, -1));

        -- first day of current month
        ut.expect (pkg_bdetail_common.contractperiodstart (LAST_DAY (ADD_MONTHS (SYSDATE, -1)) + 1)).to_be_null ();
        -- today
        ut.expect (pkg_bdetail_common.contractperiodstart (SYSDATE)).to_be_null ();

        ROLLBACK;
    END contractperiodstart;

    /* =========================================================================
       Test: [Test method generatebase36kpikey - generatebase36kpikey]].
       ---------------------------------------------------------------------- */

    PROCEDURE generatebase36kpikey
    IS
    BEGIN
        ut.expect (pkg_bdetail_common.generatebase36kpikey ()).to_be_not_null ();

        ROLLBACK;
    END generatebase36kpikey;

    /* =========================================================================
       Test: [Test method gettypeformapping - gettypeformapping]].
       ---------------------------------------------------------------------- */

    PROCEDURE gettypeformapping
    IS
    BEGIN
        test_data.crea_mapping_all ();

        COMMIT;

        ut.expect (pkg_bdetail_common.gettypeformapping (p_bih_mapid => test_data.gc_map_id)).to_equal (test_data.gc_mapt_id);

        ROLLBACK;
    END gettypeformapping;

    PROCEDURE gettypeformapping_after
    IS
    BEGIN
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END gettypeformapping_after;

    /* =========================================================================
       Test: [Test method gettypeforpacking - gettypeforpacking]].
       ---------------------------------------------------------------------- */

    PROCEDURE gettypeforpacking
    IS
    BEGIN
        test_data.crea_packing_scratch ();

        COMMIT;

        ut.expect (pkg_bdetail_common.gettypeforpacking (p_bih_pacid => test_data.gc_pac_id)).to_equal (test_data.gc_pact_id);

        ROLLBACK;
    END gettypeforpacking;

    PROCEDURE gettypeforpacking_after
    IS
    BEGIN
        test_data.del_packing_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END gettypeforpacking_after;

    /* =========================================================================
       Test: [Test method getufihfield - getufihfield]].
       ---------------------------------------------------------------------- */

    PROCEDURE getufihfield
    IS
    BEGIN
        ut.expect (pkg_bdetail_common.getufihfield (p_token => NULL, p_cdrtext => NULL)).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F4', p_cdrtext => 'Hello World')).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F4', p_cdrtext => 'F4=''Hello World''')).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F4', p_cdrtext => 'F4=''Hello World'',')).to_equal ('Hello World');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F4', p_cdrtext => 'F4=''Hello World''}')).to_equal ('Hello World');

        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'Hello World')).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=''Hello World''')).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=Hello World,')).to_equal ('Hello World');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=Hello World}')).to_equal ('Hello World');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=@H@e@llo Wor@l@d@}')).to_equal ('Hello World');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=''Hello World'',')).to_equal ('''Hello World''');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=''Hello World''}')).to_equal ('''Hello World''');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F17', p_cdrtext => 'F17=@''@H@ello Wor@l@d@''@}')).to_equal ('''Hello World''');

        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'Hello World')).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=''Hello World''')).to_be_null ();
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=Hello World,')).to_equal ('Hello World');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=Hello World}')).to_equal ('Hello World');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=@H@e@llo Wor@l@d@}')).to_equal ('@H@e@llo Wor@l@d@');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=''Hello World'',')).to_equal ('''Hello World''');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=''Hello World''}')).to_equal ('''Hello World''');
        ut.expect (pkg_bdetail_common.getufihfield (p_token => 'F99', p_cdrtext => 'F99=@''@H@ello Wor@l@d@''@}')).to_equal ('@''@H@ello Wor@l@d@''@');

        ROLLBACK;
    END getufihfield;

    /* =========================================================================
       Test: [Test method normalizedmsisdn - normalizedmsisdn]].
       ---------------------------------------------------------------------- */

    PROCEDURE normalizedmsisdn
    IS
    BEGIN
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => NULL)).to_be_null ();
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '+')).to_be_null ();

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '+F4')).to_equal ('F4');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => 'F4')).to_equal ('F4');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+...')).to_equal ('....+...');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1.A..+')).to_equal ('....+....1.A..+');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1.B..+')).to_equal ('....+....1.B..+');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1.C..+')).to_equal ('....+....1.C..+');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1.D..+')).to_equal ('....+....1.D..+');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1.E..+')).to_equal ('....+....1.E..+');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1.F..+')).to_equal ('....+....1.F..+');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1....+....')).to_equal ('....+....1....+....');
        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '....+....1....+....2')).to_equal ('....+....1....+....2');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '00....+....1....+')).to_equal ('....+....1....+');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '0....+....1....+')).to_equal ('41....+....1....+');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '123456789')).to_equal ('41123456789');

        ut.expect (pkg_bdetail_common.normalizedmsisdn (msisdn => '123456xyz')).to_equal ('123456xyz');

        ROLLBACK;
    END normalizedmsisdn;

    /* =========================================================================
       Test: [Test method simplehash - simplehash]].
       ---------------------------------------------------------------------- */

    PROCEDURE simplehash
    IS
    BEGIN
        ut.expect (pkg_bdetail_common.simplehash (s => NULL)).to_equal (0);
        ut.expect (pkg_bdetail_common.simplehash (s => 'F')).to_equal (70);
        ut.expect (pkg_bdetail_common.simplehash (s => 'F4')).to_equal (174);
        ut.expect (pkg_bdetail_common.simplehash (s => 'F4=Hello World')).to_equal (9993);

        ROLLBACK;
    END simplehash;

    /* =========================================================================
       Test: [Test method sp_update_dls_dates - sp_update_dls_dates]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_update_dls_dates
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);
        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_bdetail_common.sp_update_dls_dates (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (100);
        ut.expect (l_errormsg).to_be_like ('ORA-01403: %');
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;

        test_data.crea_sysparameters ();

        COMMIT;

        pkg_bdetail_common.sp_update_dls_dates (
            p_pact_id                            => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (1);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_update_dls_dates;

    PROCEDURE sp_update_dls_dates_after
    IS
    BEGIN
        test_data.del_sysparameters_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_update_dls_dates_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_bdetail_common;
/
