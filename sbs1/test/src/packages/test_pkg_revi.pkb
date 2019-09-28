CREATE OR REPLACE PACKAGE BODY test_pkg_revi
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method revi_index_file - pkg_revi.revi_index_file]].
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_file_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.drop_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_bdetail1_complete ();
        test_data.del_bdetail6_complete ();
        test_data.del_ppb_cdrmms ();
        test_data.del_ppb_cdrsms ();

        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_tariff_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END revi_index_file_after;

    PROCEDURE revi_index_file_content_a
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_bihid := test_data.gc_bih_id;
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 1;
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        -- test_data.crea_boheader_scratch ();

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := l_bdetail.bd_requestid;
        l_bdetail1.bd_consolidation := l_bdetail.bd_shortid;
        l_bdetail1.bd_datetime := SYSDATE - 1;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_b := l_bdetail.bd_msisdn_b;
        l_bdetail1.bd_status := 4;
        test_data.crea_bdetail1 (l_bdetail1);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_content_a;

    PROCEDURE revi_index_file_content_b
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_bihid := test_data.gc_bih_id;
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        -- test_data.crea_boheader_scratch ();

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := l_bdetail.bd_requestid;
        l_bdetail1.bd_consolidation := l_bdetail.bd_shortid;
        l_bdetail1.bd_datetime := SYSDATE - 1;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_b := l_bdetail.bd_msisdn_b;
        l_bdetail1.bd_status := 4;
        test_data.crea_bdetail1 (l_bdetail1);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_content_b;

    PROCEDURE revi_index_file_content_c
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_bihid := test_data.gc_bih_id;
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := NULL;
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_content_c;

    PROCEDURE revi_index_file_content_d
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail6                              bdetail6%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_bihid := test_data.gc_bih_id;
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'p_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_cdrrectype := 'MM7Orecord';
        l_bdetail6.bd_datetime := SYSDATE - 1;
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 2;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msisdn_b := l_bdetail.bd_msisdn_b;
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_shortid := l_bdetail.bd_shortid;
        l_bdetail6.bd_umsggrpid := l_bdetail.bd_msgid;
        test_data.crea_bdetail6 (l_bdetail6);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_content_d;

    PROCEDURE revi_index_file_content_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;

        l_cdrsms                                cdrsms%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_amountcu := -1;
        l_bdetail.bd_bihid := test_data.gc_bih_id;
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_prepaid := 'Y';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        l_cdrsms.calltype := 120;
        l_cdrsms.request_id := l_bdetail.bd_requestid || '_' || l_bdetail.bd_msisdn_a;
        test_data.crea_cdrsms (l_cdrsms);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := l_bdetail.bd_requestid;
        l_bdetail1.bd_consolidation := l_bdetail.bd_shortid;
        l_bdetail1.bd_datetime := SYSDATE - 1;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_b := l_bdetail.bd_msisdn_b;
        l_bdetail1.bd_status := 4;
        test_data.crea_bdetail1 (l_bdetail1);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_content_e;

    PROCEDURE revi_index_file_content_f
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail6                              bdetail6%ROWTYPE;

        l_cdrmms                                cdrmms%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_amountcu := 1;
        l_bdetail.bd_bihid := test_data.gc_bih_id;
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'p_msgid_a';
        l_bdetail.bd_prepaid := 'Y';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'ISRV'
        WHERE  bih_id = test_data.gc_bih_id;

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_cdrrectype := 'MM7Orecord';
        l_bdetail6.bd_datetime := SYSDATE - 1;
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 2;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msisdn_b := l_bdetail.bd_msisdn_b;
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_shortid := l_bdetail.bd_shortid;
        l_bdetail6.bd_umsggrpid := l_bdetail.bd_msgid;
        test_data.crea_bdetail6 (l_bdetail6);

        l_cdrmms.calltype := 121;
        l_cdrmms.request_id := l_bdetail.bd_requestid || '_' || l_bdetail.bd_msisdn_a;
        test_data.crea_cdrmms (l_cdrmms);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_content_f;

    PROCEDURE revi_index_file_mms
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail6                              bdetail6%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_tariff_all ();

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_bihid := test_data.gc_bih_id;
        l_bdetail6.bd_cdrrectype := 'MM7Orecord';
        l_bdetail6.bd_datetime := SYSDATE - 1;
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 2;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_shortid := 'ut_sho';
        l_bdetail6.bd_tarid := 'S';
        l_bdetail6.bd_umsggrpid := 'p_msgid_a';
        test_data.crea_bdetail6 (l_bdetail6);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'MMSC'
        WHERE  bih_id = test_data.gc_bih_id;

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msgid := l_bdetail6.bd_umsggrpid;
        l_bdetail.bd_msisdn_b := l_bdetail6.bd_msisdn_b;
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_shortid := l_bdetail6.bd_shortid;
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_mms;

    PROCEDURE revi_index_file_mms_14400
    IS
        l_bdetail6                              bdetail6%ROWTYPE;
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_tariff_all ();

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_bihid := test_data.gc_bih_id;
        l_bdetail6.bd_cdrrectype := 'MM7Orecord';
        l_bdetail6.bd_datetime := SYSDATE - 1;
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 2;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_shortid := 'ut_sho';
        l_bdetail6.bd_tarid := 'S';
        l_bdetail6.bd_umsggrpid := 'p_msgid_a';
        test_data.crea_bdetail6 (l_bdetail6);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'MMSC'
        WHERE  bih_id = test_data.gc_bih_id;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);
    END revi_index_file_mms_14400;

    PROCEDURE revi_index_file_sms
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO');
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_tariff_all ();

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_bihid := test_data.gc_bih_id;
        l_bdetail1.bd_billid := '1';
        l_bdetail1.bd_consolidation := 'ut_sho';
        l_bdetail1.bd_datetime := SYSDATE - 1;
        l_bdetail1.bd_demo := 0;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail1.bd_npi_b := '1';
        l_bdetail1.bd_pid_b := '0';
        l_bdetail1.bd_tarid := 'S';
        test_data.crea_bdetail1 (l_bdetail1);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'SMSC'
        WHERE  bih_id = test_data.gc_bih_id;

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_datetime := SYSDATE - 1;
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_b := l_bdetail1.bd_msisdn_b;
        l_bdetail.bd_requestid := l_bdetail1.bd_billid;
        l_bdetail.bd_shortid := l_bdetail1.bd_consolidation;
        l_bdetail.bd_srctype := 'ISRV';
        test_data.crea_bdetail (l_bdetail);

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'SMSN'
        WHERE  bih_id = test_data.gc_bih_id;

        COMMIT;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);

        ROLLBACK;
    END revi_index_file_sms;

    PROCEDURE revi_index_file_sms_14400
    IS
        l_bdetail1                              bdetail1%ROWTYPE;
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, 1));

        test_data.crea_revi_config_all ();

        UPDATE revi_config
        SET    revic_exec = 1
        WHERE  revic_id = 'DEFAULT';

        test_data.crea_tariff_all ();

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_bihid := test_data.gc_bih_id;
        l_bdetail1.bd_billed := '1';
        l_bdetail1.bd_consolidation := 'ut_sho';
        l_bdetail1.bd_datetime := SYSDATE - 1;
        l_bdetail1.bd_demo := 0;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail1.bd_npi_b := '1';
        l_bdetail1.bd_pid_b := '0';
        l_bdetail1.bd_tarid := 'S';
        test_data.crea_bdetail1 (l_bdetail1);

        test_data.crea_biheader_scratch ();

        UPDATE biheader
        SET    bih_reccount = 100,
               bih_srctype = 'SMSC'
        WHERE  bih_id = test_data.gc_bih_id;

        pkg_revi.revi_index_file (p_bih_id => test_data.gc_bih_id, p_boh_id => test_data.gc_boh_id);
    END revi_index_file_sms_14400;

    /* =========================================================================
       Test: [Test method sp_cons_revicd - pkg_revi.sp_cons_revicd]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revicd_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        UPDATE revi_config
        SET    revic_debugmode = 1;

        pkg_revi.sp_cons_revicd (
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
    END sp_cons_revicd_a;

    PROCEDURE sp_cons_revicd_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_bdetail2_complete ();
        test_data.del_bdetail6_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_revicd_after;

    PROCEDURE sp_cons_revicd_b
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail2                              bdetail2%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 1;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revicd (
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

        test_data.crea_bdetail2_scratch (p_complete_in => FALSE);
        l_bdetail2.bd_billid := '1';
        l_bdetail2.bd_consolidation := 'ut_sho';
        l_bdetail2.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail2.bd_demo := 0;
        l_bdetail2.bd_mapsid := 'R';
        l_bdetail2.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail2.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail2.bd_shortid := 'ut_sho';
        l_bdetail2.bd_srctype := 'ISRV';
        l_bdetail2.bd_status := 0;
        test_data.crea_bdetail2 (l_bdetail2);

        COMMIT;

        pkg_revi.sp_cons_revicd (
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
    END sp_cons_revicd_b;

    PROCEDURE sp_cons_revicd_c
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail2                              bdetail2%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revicd (
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

        test_data.crea_bdetail2_scratch (p_complete_in => FALSE);
        l_bdetail2.bd_billid := '1';
        l_bdetail2.bd_consolidation := 'ut_sho';
        l_bdetail2.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail2.bd_demo := 0;
        l_bdetail2.bd_mapsid := 'R';
        l_bdetail2.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail2.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail2.bd_shortid := 'ut_sho';
        l_bdetail2.bd_srctype := 'ISRV';
        l_bdetail2.bd_status := 0;
        test_data.crea_bdetail2 (l_bdetail2);

        COMMIT;

        pkg_revi.sp_cons_revicd (
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
    END sp_cons_revicd_c;

    PROCEDURE sp_cons_revicd_d
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail2                              bdetail2%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := NULL;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.sp_cons_revicd (
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

        test_data.crea_bdetail2_scratch (p_complete_in => FALSE);
        l_bdetail2.bd_billid := '1';
        l_bdetail2.bd_consolidation := 'ut_sho';
        l_bdetail2.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail2.bd_demo := 0;
        l_bdetail2.bd_mapsid := 'R';
        l_bdetail2.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail2.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail2.bd_shortid := 'ut_sho';
        l_bdetail2.bd_srctype := 'ISRV';
        l_bdetail2.bd_status := 0;
        test_data.crea_bdetail2 (l_bdetail2);

        COMMIT;

        pkg_revi.sp_cons_revicd (
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
    END sp_cons_revicd_d;

    PROCEDURE sp_cons_revicd_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail6                              bdetail6%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revicd (
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

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_cdrrectype := 'MMSRrecord';
        l_bdetail6.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 1;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail6.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail6.bd_shortid := 'ut_sho';
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_umsggrpid := 'ut_msgid_a';
        test_data.crea_bdetail6 (l_bdetail6);

        COMMIT;

        pkg_revi.sp_cons_revicd (
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
    END sp_cons_revicd_e;

    PROCEDURE sp_cons_revicd_f
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO');
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_DEL', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));

        pkg_revi.sp_cons_revicd (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);

        ut.expect (l_errorcode).to_equal (-2149);
        ut.expect (l_errormsg).to_be_like ('ORA-06512: %');
        ut.expect (l_recordsaffected).to_equal (0);
        ut.expect (l_returnstatus).to_equal (0);

        ROLLBACK;
    END sp_cons_revicd_f;

    /* =========================================================================
       Test: [Test method sp_cons_revics - pkg_revi.sp_cons_revics]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revics_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revics (
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
    END sp_cons_revics_a;

    PROCEDURE sp_cons_revics_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_bdetail1_complete ();
        test_data.del_bdetail6_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_revics_after;

    PROCEDURE sp_cons_revics_b
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 1;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revics (
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

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := '1';
        l_bdetail1.bd_consolidation := 'ut_sho';
        l_bdetail1.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail1.bd_demo := 0;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail1.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail1.bd_shortid := 'ut_sho';
        l_bdetail1.bd_srctype := 'ISRV';
        l_bdetail1.bd_status := 4;
        test_data.crea_bdetail1 (l_bdetail1);

        COMMIT;
        pkg_revi.sp_cons_revics (
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
    END sp_cons_revics_b;

    PROCEDURE sp_cons_revics_c
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revics (
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

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := '1';
        l_bdetail1.bd_consolidation := 'ut_sho';
        l_bdetail1.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail1.bd_demo := 0;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail1.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail1.bd_shortid := 'ut_sho';
        l_bdetail1.bd_srctype := 'ISRV';
        l_bdetail1.bd_status := 4;
        test_data.crea_bdetail1 (l_bdetail1);

        COMMIT;

        pkg_revi.sp_cons_revics (
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
    END sp_cons_revics_c;

    PROCEDURE sp_cons_revics_d
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := NULL;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.sp_cons_revics (
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

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := '1';
        l_bdetail1.bd_consolidation := 'ut_sho';
        l_bdetail1.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail1.bd_demo := 0;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail1.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail1.bd_shortid := 'ut_sho';
        l_bdetail1.bd_srctype := 'ISRV';
        l_bdetail1.bd_status := 4;
        test_data.crea_bdetail1 (l_bdetail1);

        COMMIT;

        pkg_revi.sp_cons_revics (
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
    END sp_cons_revics_d;

    PROCEDURE sp_cons_revics_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail6                              bdetail6%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_CONTENT_SUB', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revics (
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

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_cdrrectype := 'MM7Orecord';
        l_bdetail6.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 2;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail6.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail6.bd_shortid := 'ut_sho';
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_umsggrpid := 'ut_msgid_a';
        test_data.crea_bdetail6 (l_bdetail6);

        COMMIT;

        pkg_revi.sp_cons_revics (
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
    END sp_cons_revics_e;

    PROCEDURE sp_cons_revics_02149
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_revi.sp_cons_revics (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_cons_revics_02149;

    /* =========================================================================
       Test: [Test method sp_cons_revim - pkg_revi.sp_cons_revim]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revim_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revim (
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
    END sp_cons_revim_a;

    PROCEDURE sp_cons_revim_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_bdetail6_complete ();

        -- Level 1
        test_data.del_tariff_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_revim_after;

    PROCEDURE sp_cons_revim_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail6                              bdetail6%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_MMS', p_prefix_in => 'INFO');

        test_data.crea_tariff_all ();

        test_data.crea_bdetail6_scratch (p_complete_in => FALSE);
        l_bdetail6.bd_cdrrectype := 'MM7Orecord';
        l_bdetail6.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail6.bd_demo := 0;
        l_bdetail6.bd_eventdisp := 2;
        l_bdetail6.bd_mapsid := 'R';
        l_bdetail6.bd_msgtype := 0;
        l_bdetail6.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail6.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail6.bd_shortid := 'ut_sho';
        l_bdetail6.bd_srctype := 'MMSC';
        l_bdetail6.bd_tarid := 'S';
        l_bdetail6.bd_umsggrpid := 'ut_msgid_a';
        test_data.crea_bdetail6 (l_bdetail6);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revim (
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

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.sp_cons_revim (
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
    END sp_cons_revim_e;

    PROCEDURE sp_cons_revim_02149
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_revi.sp_cons_revim (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_cons_revim_02149;

    /* =========================================================================
       Test: [Test method sp_cons_revipre - pkg_revi.sp_cons_revipre]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revipre_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revipre (
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
    END sp_cons_revipre_a;

    PROCEDURE sp_cons_revipre_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_ppb_cdrmms ();
        test_data.del_ppb_cdrsms ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_revipre_after;

    PROCEDURE sp_cons_revipre_b
    IS
        l_bdetail                               bdetail%ROWTYPE;

        l_cdrsms                                cdrsms%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_prepaid := 'Y';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'SMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revipre (
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

        l_cdrsms.calltype := 120;
        l_cdrsms.request_id := '1_ut_msisdn_a';
        test_data.crea_cdrsms (l_cdrsms);

        COMMIT;

        pkg_revi.sp_cons_revipre (
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
    END sp_cons_revipre_b;

    PROCEDURE sp_cons_revipre_e
    IS
        l_bdetail                               bdetail%ROWTYPE;

        l_cdrmms                                cdrmms%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_PRE', p_prefix_in => 'INFO');

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_prepaid := 'Y';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revipre (
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

        l_cdrmms.calltype := 121;
        l_cdrmms.request_id := '1_ut_msisdn_a';
        test_data.crea_cdrmms (l_cdrmms);

        COMMIT;

        pkg_revi.sp_cons_revipre (
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
    END sp_cons_revipre_e;

    PROCEDURE sp_cons_revipre_02149
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_revi.sp_cons_revipre (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_cons_revipre_02149;

    /* =========================================================================
       Test: [Test method sp_cons_reviprm - pkg_revi.sp_cons_reviprm]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_reviprm_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVIPRE_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVIPRE_MMS', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_reviprm (
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
    END sp_cons_reviprm_a;

    PROCEDURE sp_cons_reviprm_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVIPRE_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVIPRE_MMS', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_cdrmms ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_reviprm_after;

    PROCEDURE sp_cons_reviprm_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_cdrmms                                cdrmms%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVIPRE_MMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVIPRE_MMS', p_prefix_in => 'INFO');

        l_cdrmms.called_nr := 'ut_called_nr_a';
        l_cdrmms.calltype := 121;
        l_cdrmms.startdatetime := ADD_MONTHS (SYSDATE, -1);
        l_cdrmms.request_id := '1_2';
        l_cdrmms.short_id := 'ut_sho';
        test_data.crea_cdrmms (l_cdrmms);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_reviprm (
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

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := '_called_nr_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.sp_cons_reviprm (
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
    END sp_cons_reviprm_e;

    PROCEDURE sp_cons_reviprm_02149
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_revi.sp_cons_reviprm (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_cons_reviprm_02149;

    /* =========================================================================
       Test: [Test method sp_cons_reviprs - pkg_revi.sp_cons_reviprs]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_reviprs_a
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVIPRE_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVIPRE_SMS', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_reviprs (
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
    END sp_cons_reviprs_a;

    PROCEDURE sp_cons_reviprs_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVIPRE_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVIPRE_SMS', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_cdrsms ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_reviprs_after;

    PROCEDURE sp_cons_reviprs_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_cdrsms                                cdrsms%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVIPRE_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVIPRE_SMS', p_prefix_in => 'INFO');

        l_cdrsms.called_nr := 'ut_called_nr_a';
        l_cdrsms.calltype := 120;
        l_cdrsms.startdatetime := ADD_MONTHS (SYSDATE, -1);
        l_cdrsms.request_id := '1_2';
        l_cdrsms.short_id := 'ut_sho';
        test_data.crea_cdrsms (l_cdrsms);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_reviprs (
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

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := '_called_nr_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.sp_cons_reviprs (
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
    END sp_cons_reviprs_e;

    PROCEDURE sp_cons_reviprs_02149
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_revi.sp_cons_reviprs (
            p_pac_id                             => NULL,
            p_boh_id                             => NULL,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_cons_reviprs_02149;

    /* =========================================================================
       Test: [Test method sp_cons_revis - pkg_revi.sp_cons_revis]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revis_a
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO');

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revis (
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
    END sp_cons_revis_a;

    PROCEDURE sp_cons_revis_after
    IS
    BEGIN
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.drop_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO');

        -- Level 0
        test_data.del_bdetail_complete ();
        test_data.del_bdetail1_complete ();

        -- Level 1
        test_data.del_tariff_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_cons_revis_after;

    PROCEDURE sp_cons_revis_e
    IS
        l_bdetail                               bdetail%ROWTYPE;
        l_bdetail1                              bdetail1%ROWTYPE;
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO', p_date_in => ADD_MONTHS (SYSDATE, -1));
        test_data.add_table_partition (p_table_in => 'REVI_SMS', p_prefix_in => 'INFO');

        test_data.crea_tariff_all ();

        test_data.crea_bdetail1_scratch (p_complete_in => FALSE);
        l_bdetail1.bd_billid := '1';
        l_bdetail1.bd_consolidation := 'ut_sho';
        l_bdetail1.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail1.bd_demo := 0;
        l_bdetail1.bd_mapsid := 'R';
        l_bdetail1.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail1.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail1.bd_npi_b := '1';
        l_bdetail1.bd_pid_b := '0';
        l_bdetail1.bd_shortid := 'ut_sho';
        l_bdetail1.bd_srctype := 'MMSC';
        l_bdetail1.bd_tarid := 'S';
        test_data.crea_bdetail1 (l_bdetail1);

        test_data.crea_revi_config_all ();

        COMMIT;

        pkg_revi.sp_cons_revis (
            p_pac_id                             => NULL,
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

        test_data.crea_bdetail_scratch (p_complete_in => FALSE);
        l_bdetail.bd_billed := '1';
        l_bdetail.bd_counttr := 2;
        l_bdetail.bd_datetime := ADD_MONTHS (SYSDATE, -1);
        l_bdetail.bd_demo := 0;
        l_bdetail.bd_mapsid := 'R';
        l_bdetail.bd_msisdn_a := 'ut_msisdn_a';
        l_bdetail.bd_msisdn_b := 'ut_msisdn_b';
        l_bdetail.bd_msgid := 'ut_msgid_a';
        l_bdetail.bd_requestid := '1';
        l_bdetail.bd_shortid := 'ut_sho';
        l_bdetail.bd_srctype := 'ISRV';
        l_bdetail.bd_transportmedium := 'MMS';
        test_data.crea_bdetail (l_bdetail);

        COMMIT;

        pkg_revi.sp_cons_revis (
            p_pac_id                             => NULL,
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
    END sp_cons_revis_e;

    PROCEDURE sp_cons_revis_02149
    IS
        l_boh_id                                boheader.boh_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_recordsaffected                       PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_revi.sp_cons_revis (
            p_pac_id                             => NULL,
            p_boh_id                             => l_boh_id,
            recordsaffected                      => l_recordsaffected,
            errorcode                            => l_errorcode,
            errormsg                             => l_errormsg,
            returnstatus                         => l_returnstatus);
    END sp_cons_revis_02149;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_revi;
/