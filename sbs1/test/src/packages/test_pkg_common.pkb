CREATE OR REPLACE PACKAGE BODY test_pkg_common
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method cutfirstitem - cutfirstitem]].
       ---------------------------------------------------------------------- */

    PROCEDURE cutfirstitem
    IS
        l_itemlist                              VARCHAR2 (16000);
    BEGIN
        l_itemlist := NULL;
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => NULL, p_trimitem => NULL)).to_be_null ();

        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => NULL, p_trimitem => FALSE)).to_be_null ();

        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => NULL, p_trimitem => TRUE)).to_be_null ();

        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => NULL)).to_be_null ();

        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => FALSE)).to_be_null ();

        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => TRUE)).to_be_null ();

        l_itemlist := 'test_1 ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => NULL)).to_equal ('test_1 ');

        l_itemlist := 'test_1 ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => FALSE)).to_equal ('test_1 ');

        l_itemlist := 'test_1 ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => TRUE)).to_equal ('test_1');

        l_itemlist := ' ; ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => NULL)).to_equal (' ');

        l_itemlist := ' ; ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => FALSE)).to_equal (' ');

        l_itemlist := ' ; ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => TRUE)).to_be_null ();

        l_itemlist := 'test_1 ; ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => NULL)).to_equal ('test_1 ');

        l_itemlist := 'test_1 ; ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => FALSE)).to_equal ('test_1 ');

        l_itemlist := 'test_1 ; ';
        ut.expect (pkg_common.cutfirstitem (p_itemlist => l_itemlist, p_separator => ';', p_trimitem => TRUE)).to_equal ('test_1');

        ROLLBACK;
    END cutfirstitem;

    /* =========================================================================
       Test: [Test method duration - duration]].
       ---------------------------------------------------------------------- */

    PROCEDURE duration
    IS
        lc_factor                               PLS_INTEGER := 3600 * 24;

        l_time_diff                             NUMBER (38, 20);
    BEGIN
        l_time_diff := NULL;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_be_null ();

        l_time_diff := -5.9 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('-6 sec');

        l_time_diff := 5.9 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('6 sec');

        l_time_diff := 60 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('60 sec');

        l_time_diff := 61 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('1.02 min');

        l_time_diff := 3599 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('59.98 min');

        l_time_diff := 3600 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('1 hrs');

        l_time_diff := 3601 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('1 hrs');

        l_time_diff := 36000 / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('10 hrs');

        l_time_diff := (lc_factor - 1) / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('24 hrs');

        l_time_diff := 1;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('1 days');

        l_time_diff := (lc_factor + 1) / lc_factor;
        ut.expect (pkg_common.duration (p_time_diff => l_time_diff)).to_equal ('1 days');

        ROLLBACK;
    END duration;

    /* =========================================================================
       Test: [Test method generateuniquekey - generateuniquekey]].
       ---------------------------------------------------------------------- */

    PROCEDURE generateuniquekey
    IS
        l_identifier                            CHAR;

        l_cuniquekey_1                          VARCHAR2 (10);
        l_cuniquekey_2                          VARCHAR2 (10);
    BEGIN
        l_identifier := NULL;
        l_cuniquekey_1 := pkg_common.generateuniquekey (identifier => l_identifier);
        l_cuniquekey_2 := pkg_common.generateuniquekey (identifier => l_identifier);

        ut.expect (l_cuniquekey_1).to_be_not_null ();
        ut.expect (l_cuniquekey_2).to_be_not_null ();
        ut.expect (l_cuniquekey_1 = l_cuniquekey_2).to_be_false ();

        l_identifier := 'B';
        l_cuniquekey_1 := pkg_common.generateuniquekey (identifier => l_identifier);
        l_cuniquekey_2 := pkg_common.generateuniquekey (identifier => l_identifier);

        ut.expect (l_cuniquekey_1).to_be_not_null ();
        ut.expect (l_cuniquekey_2).to_be_not_null ();
        ut.expect (l_cuniquekey_1 = l_cuniquekey_2).to_be_false ();

        ROLLBACK;
    END generateuniquekey;

    /* =========================================================================
       Test: [Test method getdatesforperiod - getdatesforperiod]].
       ---------------------------------------------------------------------- */

    PROCEDURE getdatesforperiod
    IS
        l_period_end                            DATE;
        l_period_id                             VARCHAR2 (10);
        l_period_start                          DATE;
    BEGIN
        l_period_id := NULL;
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_start).to_be_null ();
        ut.expect (l_period_end).to_be_null ();

        l_period_id := 'NONE';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_start).to_be_null ();
        ut.expect (l_period_end).to_be_null ();

        l_period_id := 'any';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_start).to_be_null ();
        ut.expect (l_period_end).to_be_null ();

        l_period_id := 'HOURLY';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_end - l_period_start).to_equal (1 / 24);

        l_period_id := 'DAILY';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_end - l_period_start).to_equal (1);

        l_period_id := 'WEEKLY';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_end - l_period_start).to_equal (7);

        l_period_id := 'MONTHLY';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_end - l_period_start).to_be_between (28, 31);

        l_period_id := 'YEARLY';
        pkg_common.getdatesforperiod (p_period_id => l_period_id, p_period_start => l_period_start, p_period_end => l_period_end);

        ut.expect (l_period_end - l_period_start).to_be_between (365, 366);

        ROLLBACK;
    END getdatesforperiod;

    /* =========================================================================
       Test: [Test method getharderrordesc - getharderrordesc]].
       ---------------------------------------------------------------------- */

    PROCEDURE getharderrordesc
    IS
        l_bdetail                               bdetail%ROWTYPE;

        l_result                                PLS_INTEGER;
    BEGIN
        ut.expect (pkg_common.getharderrordesc ()).to_be_null ();

        ROLLBACK;

       <<sqlcode_06512>>
        BEGIN
            l_result := 1 / 0;
        EXCEPTION
            WHEN OTHERS
            THEN
                ut.expect (INSTR (pkg_common.getharderrordesc (), 'ORA-06512: ')).to_equal (1);

                ROLLBACK;
        END sqlcode_06512;

       <<sqlcode_14400>>
        BEGIN
            test_data.crea_bdetail_scratch (p_complete_in => FALSE);

            l_bdetail.bd_datetime := SYSDATE + 32;
            test_data.crea_bdetail (l_bdetail);

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                ut.expect (pkg_common.getharderrordesc ()).to_equal ('ORA-14400 NO_PARTITION');
                ROLLBACK;
        END sqlcode_14400;
    END getharderrordesc;

    PROCEDURE getharderrordesc_after
    IS
    BEGIN
        test_data.del_bdetail_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END getharderrordesc_after;

    /* =========================================================================
       Test: [Test method getrequiredheaderfield - getrequiredheaderfield]].
       ---------------------------------------------------------------------- */

    PROCEDURE getrequiredheaderfield
    IS
        l_headerdata                            VARCHAR2 (1024);
        l_token                                 VARCHAR2 (64);
    BEGIN
        l_headerdata := 'first<br>second' || CHR (9) || 'test';
        l_token := 'second';

        ut.expect (pkg_common.getrequiredheaderfield (p_headerdata => l_headerdata, p_token => l_token)).to_equal ('test');

        ROLLBACK;
    END getrequiredheaderfield;

    PROCEDURE getrequiredheaderfield_1005_1
    IS
        l_headerdata                            VARCHAR2 (1024);
        l_result                                VARCHAR2 (1024);
        l_token                                 VARCHAR2 (64);
    BEGIN
        l_headerdata := NULL;
        l_token := NULL;
        l_result := pkg_common.getrequiredheaderfield (p_headerdata => l_headerdata, p_token => l_token);
    END getrequiredheaderfield_1005_1;

    PROCEDURE getrequiredheaderfield_1005_2
    IS
        l_headerdata                            VARCHAR2 (1024);
        l_result                                VARCHAR2 (1024);
        l_token                                 VARCHAR2 (64);
    BEGIN
        l_headerdata := 'first<br>';
        l_token := NULL;

        l_result := pkg_common.getrequiredheaderfield (p_headerdata => l_headerdata, p_token => l_token);

        ROLLBACK;
    END getrequiredheaderfield_1005_2;

    PROCEDURE getrequiredheaderfield_1005_3
    IS
        l_headerdata                            VARCHAR2 (1024);
        l_result                                VARCHAR2 (1024);
        l_token                                 VARCHAR2 (64);
    BEGIN
        l_headerdata := 'first<br>';
        l_token := 'second';

        l_result := pkg_common.getrequiredheaderfield (p_headerdata => l_headerdata, p_token => l_token);

        ROLLBACK;
    END getrequiredheaderfield_1005_3;

    PROCEDURE getrequiredheaderfield_1005_4
    IS
        l_headerdata                            VARCHAR2 (1024);
        l_result                                VARCHAR2 (1024);
        l_token                                 VARCHAR2 (64);
    BEGIN
        l_headerdata := 'first<br>second';
        l_token := 'second';

        l_result := pkg_common.getrequiredheaderfield (p_headerdata => l_headerdata, p_token => l_token);

        ROLLBACK;
    END getrequiredheaderfield_1005_4;

    /* =========================================================================
       Test: [Test method insert_warning - insert_warning]].
       ---------------------------------------------------------------------- */

    PROCEDURE insert_warning
    IS
    BEGIN
        pkg_common.insert_warning (p_w_applic => 'ut_applic_a', p_w_procedure => 'ut_procedure_a', p_w_topic => 'ut_topic_a', p_w_message => 'ut_message_a');

        ROLLBACK;
    END insert_warning;

    PROCEDURE insert_warning_after
    IS
    BEGIN
        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END insert_warning_after;

    /* =========================================================================
       Test: [Test method is_alphanumeric - is_alphanumeric]].
       ---------------------------------------------------------------------- */

    PROCEDURE is_alphanumeric
    IS
    BEGIN
        ut.expect (pkg_common.is_alphanumeric (p_inputvalue => NULL)).to_equal (0);

        ut.expect (pkg_common.is_alphanumeric (p_inputvalue => '')).to_equal (0);

        ut.expect (pkg_common.is_alphanumeric (p_inputvalue => 'abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789')).to_equal (1);

        ut.expect (pkg_common.is_alphanumeric (p_inputvalue => '.')).to_equal (0);

        ROLLBACK;
    END is_alphanumeric;

    /* =========================================================================
       Test: [Test method is_integer - is_integer]].
       ---------------------------------------------------------------------- */

    PROCEDURE is_integer
    IS
    BEGIN
        ut.expect (pkg_common.is_integer (p_inputvalue => NULL)).to_equal (0);

        ut.expect (pkg_common.is_integer (p_inputvalue => '')).to_equal (0);

        ut.expect (pkg_common.is_integer (p_inputvalue => 'abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789')).to_equal (0);

        ut.expect (pkg_common.is_integer (p_inputvalue => '.')).to_equal (0);

        ut.expect (pkg_common.is_integer (p_inputvalue => 'e')).to_equal (0);

        ut.expect (pkg_common.is_integer (p_inputvalue => 'E')).to_equal (0);

        ut.expect (pkg_common.is_integer (p_inputvalue => '10')).to_equal (1);

        ut.expect (pkg_common.is_integer (p_inputvalue => '10', p_minvalue => 0)).to_equal (1);

        ut.expect (pkg_common.is_integer (p_inputvalue => '10', p_maxvalue => 20)).to_equal (1);

        ut.expect (pkg_common.is_integer (p_inputvalue => '10', p_minvalue => 0, p_maxvalue => 20)).to_equal (1);

        ROLLBACK;
    END is_integer;

    /* =========================================================================
       Test: [Test method is_numeric - is_numeric]].
       ---------------------------------------------------------------------- */

    PROCEDURE is_numeric
    IS
    BEGIN
        ut.expect (pkg_common.is_numeric (p_inputvalue => NULL)).to_equal (0);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '')).to_equal (0);

        ut.expect (pkg_common.is_numeric (p_inputvalue => 'abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789')).to_equal (0);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10')).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10', p_minvalue => 0)).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10', p_maxvalue => 20)).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10', p_minvalue => 0, p_maxvalue => 20)).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '.10')).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '.10E4')).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10.5')).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10.5', p_minvalue => 0)).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10.5', p_maxvalue => 20)).to_equal (1);

        ut.expect (pkg_common.is_numeric (p_inputvalue => '10.5', p_minvalue => 0, p_maxvalue => 20)).to_equal (1);

        ROLLBACK;
    END is_numeric;

    /* =========================================================================
       Test: [Test method isdoneinperiod - isdoneinperiod]].
       ---------------------------------------------------------------------- */

    PROCEDURE isdoneinperiod
    IS
        l_datedone                              DATE;
        l_period_id                             VARCHAR2 (10);
    BEGIN
        l_period_id := NULL;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'NONE';
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'any';
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'HOURLY';
        l_datedone := SYSDATE;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_true ();

        l_datedone := SYSDATE - 1;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'DAILY';
        l_datedone := SYSDATE;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_true ();

        l_datedone := SYSDATE - 2;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'WEEKLY';
        l_datedone := SYSDATE;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_true ();

        l_datedone := SYSDATE - 10;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'MONTHLY';
        l_datedone := SYSDATE;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_true ();

        l_datedone := SYSDATE - 40;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        l_period_id := 'YEARLY';
        l_datedone := SYSDATE;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_true ();

        l_datedone := SYSDATE - 400;
        ut.expect (pkg_common.isdoneinperiod (p_period_id => l_period_id, p_datedone => l_datedone)).to_be_false ();

        ROLLBACK;
    END isdoneinperiod;

    /* =========================================================================
       Test: [Test method istimeforprocess - istimeforprocess]].
       ---------------------------------------------------------------------- */

    PROCEDURE istimeforprocess
    IS
        l_datedone                              DATE;
        l_endclearance                          PLS_INTEGER;
        l_period_id                             VARCHAR2 (10);
        l_startday                              PLS_INTEGER;
        l_starthour                             PLS_INTEGER;
        l_startminute                           PLS_INTEGER;
    BEGIN
        l_period_id := NULL;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'NONE';
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'any';
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'HOURLY';
        l_datedone := SYSDATE;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_false ();

        l_datedone := SYSDATE - 1;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'DAILY';
        l_datedone := SYSDATE;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_false ();

        l_datedone := SYSDATE - 2;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'WEEKLY';
        l_datedone := SYSDATE;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_false ();

        l_datedone := SYSDATE - 10;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'MONTHLY';
        l_datedone := SYSDATE;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_false ();

        l_datedone := SYSDATE - 40;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        l_period_id := 'YEARLY';
        l_datedone := SYSDATE;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_false ();

        l_datedone := SYSDATE - 400;
        ut.expect (
            pkg_common.istimeforprocess (
                p_period_id                          => l_period_id,
                p_startday                           => l_startday,
                p_starthour                          => l_starthour,
                p_startminute                        => l_startminute,
                p_endclearance                       => l_endclearance,
                p_datedone                           => l_datedone)).to_be_true ();

        ROLLBACK;
    END istimeforprocess;

    /* =========================================================================
       Test: [Test method l - l]].
       ---------------------------------------------------------------------- */

    PROCEDURE l
    IS
    BEGIN
        pkg_common.l (logline => 'ut_debugstr_a', hint => 'ut_hint_a');

        ROLLBACK;
    END l;

    PROCEDURE l_after
    IS
    BEGIN
        test_data.del_log_debug ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END l_after;

    /* =========================================================================
       Test: [Test method lb - lb]].
       ---------------------------------------------------------------------- */

    PROCEDURE lb
    IS
    BEGIN
        pkg_common.lb (logline => 'ut_debugstr_a', hint => NULL);

        pkg_common.lb (logline => 'ut_debugstr_a', hint => FALSE);

        pkg_common.lb (logline => 'ut_debugstr_a', hint => TRUE);

        ROLLBACK;
    END lb;

    PROCEDURE lb_after
    IS
    BEGIN
        test_data.del_log_debug ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END lb_after;

    /* =========================================================================
       Test: [Test method sp_db_sleep - sp_db_sleep]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_db_sleep
    IS
        l_boh_id                                setdetail.sed_gohid%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_common.sp_db_sleep (
            p_pac_id                             => NULL,
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (0);
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_db_sleep;

    /* =========================================================================
       Test: [Test method sp_insert_warning - sp_insert_warning]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_warning
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_common.sp_insert_warning (
            p_w_applic                           => 'ut_applic_a',
            p_w_procedure                        => 'ut_procedure_a',
            p_w_topic                            => 'ut_topic_a',
            p_w_message                          => 'ut_message_a',
            p_errorcode                          => l_errorcode,
            p_errormsg                           => l_errormsg,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_returnstatus).to_equal (pkg_common.return_status_ok);

        ROLLBACK;
    END sp_insert_warning;

    PROCEDURE sp_insert_warning_after
    IS
    BEGIN
        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_insert_warning_after;

    /* =========================================================================
       Test: [Test method sp_is_numeric - sp_is_numeric]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_is_numeric
    IS
    BEGIN
        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => NULL)).to_equal (0);

        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => '')).to_equal (0);

        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => 'abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789')).to_equal (0);

        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => '10')).to_equal (1);

        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => '.10')).to_equal (1);

        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => '.10E4')).to_equal (1);

        ut.expect (pkg_common.sp_is_numeric (p_inputvalue => '10.5')).to_equal (1);

        ROLLBACK;
    END sp_is_numeric;

    /* =========================================================================
       Test: [Test method speed - speed]].
       ---------------------------------------------------------------------- */

    PROCEDURE speed
    IS
    BEGIN
        ut.expect (pkg_common.speed (bih_reccount => NULL, bih_start => NULL, bih_end => NULL)).to_be_null ();

        ut.expect (pkg_common.speed (bih_reccount => NULL, bih_start => SYSDATE, bih_end => NULL)).to_be_null ();

        ut.expect (pkg_common.speed (bih_reccount => NULL, bih_start => NULL, bih_end => SYSDATE)).to_be_null ();

        ut.expect (pkg_common.speed (bih_reccount => NULL, bih_start => SYSDATE, bih_end => SYSDATE)).to_be_null ();

        ut.expect (pkg_common.speed (bih_reccount => 4711, bih_start => SYSDATE, bih_end => SYSDATE)).to_equal (4711);

        ut.expect (pkg_common.speed (bih_reccount => 4711 * 24 * 3600, bih_start => SYSDATE, bih_end => SYSDATE + 1)).to_equal (4711);

        ROLLBACK;
    END speed;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_common;
/
