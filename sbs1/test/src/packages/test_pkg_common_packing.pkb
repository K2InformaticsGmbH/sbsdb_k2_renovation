CREATE OR REPLACE PACKAGE BODY test_pkg_common_packing
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method getpackingcandidatefortype - getpackingatefortype]].
       ---------------------------------------------------------------G------- */

    PROCEDURE getpackingcandidatefortype
    IS
        l_packing                               packing%ROWTYPE;
    BEGIN
        ut.expect (pkg_common_packing.getpackingcandidatefortype (p_packingtype => NULL, p_thread => NULL)).to_be_null ();

        ROLLBACK;

        test_data.crea_pactype_all ();

        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_xproc_scratch ();

        test_data.crea_packing_scratch (p_complete_in => FALSE);
        l_packing.pac_id := 'LAA_MMSC';
        l_packing.pac_debug := 9;
        l_packing.pac_datedone := SYSDATE - 60;
        l_packing.pac_esid := 'A';
        l_packing.pac_etid := 'STATIND';
        l_packing.pac_execute := 1;
        l_packing.pac_periodid := test_data.gc_period_id;
        l_packing.pac_xprocid := test_data.gc_xpr_id;
        test_data.crea_packing (l_packing);

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => l_packing.pac_id)).to_equal (1);

        ROLLBACK;

        ut.expect (pkg_common_packing.getpackingcandidatefortype (p_packingtype => l_packing.pac_etid, p_thread => l_packing.pac_xprocid)).to_equal (test_data.gc_pac_id);

        ROLLBACK;
    END getpackingcandidatefortype;

    PROCEDURE getpackingcandidatefortype_aft
    IS
    BEGIN
        -- Level 0
        test_data.del_periodicity ();
        test_data.del_sta_config ();
        test_data.del_xproc_complete ();

        -- Level 1
        test_data.del_sta_job_complete ();

        -- Level 2
        test_data.del_packing_complete ();
        test_data.del_pactype ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END getpackingcandidatefortype_aft;

    /* =========================================================================
       Test: [Test method getpackingparameter - getpackingparameter]].
       ---------------------------------------------------------------------- */

    PROCEDURE getpackingparameter
    IS
    BEGIN
        test_data.crea_sta_pacparam_scratch ();

        COMMIT;

        ut.expect (pkg_common_packing.getpackingparameter (p_pac_id => test_data.gc_pac_id, p_name => 'GART')).to_equal ('15');

        ROLLBACK;
    END getpackingparameter;

    PROCEDURE getpackingparameter_1008
    IS
        l_result                                sta_pacparam.stap_value%TYPE;
    BEGIN
        l_result := pkg_common_packing.getpackingparameter (p_pac_id => NULL, p_name => 'GART');
    END getpackingparameter_1008;

    PROCEDURE getpackingparameter_after
    IS
    BEGIN
        test_data.del_sta_pacparam_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END getpackingparameter_after;

    /* =========================================================================
       Test: [Test method gettypeforpacking - gettypeforpacking]].
       ---------------------------------------------------------------------- */

    PROCEDURE gettypeforpacking
    IS
    BEGIN
        test_data.crea_packing_scratch ();

        COMMIT;

        ut.expect (pkg_common_packing.gettypeforpacking (p_bih_pacid => test_data.gc_pac_id)).to_equal (test_data.gc_pact_id);

        ROLLBACK;
    END gettypeforpacking;

    PROCEDURE gettypeforpacking_1403
    IS
        l_result                                VARCHAR2 (10);
    BEGIN
        l_result := pkg_common_packing.gettypeforpacking (p_bih_pacid => NULL);
    END gettypeforpacking_1403;

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
       Test: [Test method insert_boheader - insert_boheader]].
       ---------------------------------------------------------------------- */

    PROCEDURE insert_boheader_a
    IS
        l_filename                              boheader.boh_filename%TYPE;

        l_headerid                              boheader.boh_id%TYPE;

        l_jobid                                 sta_job.staj_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_pactype_all ();

        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_esid = 'A',
               pac_etid = 'STATIND',
               pac_execute = 1,
               pac_periodid = test_data.gc_period_id,
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'STATIND',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'STATIND',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;
    END insert_boheader_a;

    PROCEDURE insert_boheader_after
    IS
    BEGIN
        -- Level 0
        test_data.del_boheader_complete ();
        test_data.del_periodicity ();
        test_data.del_sta_config ();

        -- Level 1
        test_data.del_bohstate ();
        test_data.del_sta_job_complete ();

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
    END insert_boheader_after;

    PROCEDURE insert_boheader_b
    IS
        l_filename                              boheader.boh_filename%TYPE;

        l_headerid                              boheader.boh_id%TYPE;

        l_jobid                                 sta_job.staj_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_pactype_all ();

        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_esid = 'A',
               pac_etid = test_data.gc_pact_id,
               pac_execute = 1,
               pac_periodid = test_data.gc_period_id,
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => test_data.gc_pact_id,
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => test_data.gc_pact_id,
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;
    END insert_boheader_b;

    PROCEDURE insert_boheader_c
    IS
        l_filename                              boheader.boh_filename%TYPE;

        l_headerid                              boheader.boh_id%TYPE;

        l_jobid                                 sta_job.staj_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_pactype_all ();

        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_esid = 'A',
               pac_etid = test_data.gc_pact_id,
               pac_execute = 1,
               pac_ltid = 'NONE',
               pac_periodid = 'YEARLY',
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'CATGENER',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'CATGENER',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;

        UPDATE packing
        SET    pac_periodid = 'NONE'
        WHERE  pac_id = test_data.gc_pac_id;

        UPDATE sta_config
        SET    stac_execsched = 7,
               stac_nooftrials = 0
        WHERE  stac_id = test_data.gc_stac_id;

        COMMIT;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'CATGENER',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'CATGENER',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;
    END insert_boheader_c;

    PROCEDURE insert_boheader_d
    IS
        l_filename                              boheader.boh_filename%TYPE;

        l_headerid                              boheader.boh_id%TYPE;

        l_jobid                                 sta_job.staj_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_pactype_all ();

        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_esid = 'A',
               pac_etid = test_data.gc_pact_id,
               pac_execute = 1,
               pac_ltid = 'AC_ID',
               pac_periodid = 'YEARLY',
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'CATGENER',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => 'CATGENER',
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);

        ROLLBACK;
    END insert_boheader_d;

    PROCEDURE insert_boheader_1003_a
    IS
        l_filename                              boheader.boh_filename%TYPE;

        l_headerid                              boheader.boh_id%TYPE;

        l_jobid                                 sta_job.staj_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_periodicity_all ();

        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_datedone = SYSDATE,
               pac_debug = 9,
               pac_execute = 1,
               pac_periodid = 'MONTHLY'
        WHERE  pac_id = test_data.gc_pac_id;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => NULL,
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);
    END insert_boheader_1003_a;

    PROCEDURE insert_boheader_1003_c
    IS
        l_filename                              boheader.boh_filename%TYPE;

        l_headerid                              boheader.boh_id%TYPE;

        l_jobid                                 sta_job.staj_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_pactype_all ();

        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();
        test_data.crea_sta_job_scratch ();

        UPDATE packing
        SET    pac_execute = 1,
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader (
            p_packingtype                        => test_data.gc_pact_id,
            p_packingid                          => l_packingid,
            p_headerid                           => l_headerid,
            p_jobid                              => l_jobid,
            p_filename                           => l_filename,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL);
    END insert_boheader_1003_c;

    /* =========================================================================
       Test: [Test method insert_boheader_sptry - insert_boheader_sptry]].
       ---------------------------------------------------------------------- */

    PROCEDURE insert_boheader_sptry
    IS
        l_headerid                              boheader.boh_id%TYPE;

        l_packingid                             boheader.boh_packid%TYPE;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_pactype_all ();
        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_esid = 'A',
               pac_etid = 'STATIND',
               pac_execute = 1,
               pac_periodid = test_data.gc_period_id,
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        l_packingid := test_data.gc_pac_id;

        pkg_common_packing.insert_boheader_sptry (p_packingid => l_packingid, p_headerid => l_headerid);

        ROLLBACK;

        l_packingid := NULL;

        pkg_common_packing.insert_boheader_sptry (p_packingid => l_packingid, p_headerid => l_headerid);

        ROLLBACK;
    END insert_boheader_sptry;

    PROCEDURE insert_boheader_sptry_after
    IS
    BEGIN
        -- Level 0
        test_data.del_boheader_complete ();
        test_data.del_periodicity ();
        test_data.del_sta_config ();

        -- Level 1
        test_data.del_bohstate ();
        test_data.del_sta_job_complete ();

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
    END insert_boheader_sptry_after;

    /* =========================================================================
       Test: [Test method istimeforpacking - istimeforpacking]].
       ---------------------------------------------------------------------- */

    PROCEDURE istimeforpacking_a
    IS
    BEGIN
        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_a;

    PROCEDURE istimeforpacking_after
    IS
    BEGIN
        -- Level 0
        test_data.del_mappacdep ();
        test_data.del_pacpacdep ();
        test_data.del_periodicity ();
        test_data.del_sta_config ();

        -- Level 1
        test_data.del_mapping_complete ();

        -- Level 2
        test_data.del_packing_complete ();

        -- Level 3
        test_data.del_looptype ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END istimeforpacking_after;

    PROCEDURE istimeforpacking_b
    IS
    BEGIN
        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_debug = 9,
               pac_execute = 1
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (1);

        ROLLBACK;
    END istimeforpacking_b;

    PROCEDURE istimeforpacking_c
    IS
    BEGIN
        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_conditionalexec = 'SELECT ''FALSE'' FROM DUAL',
               pac_debug = 9,
               pac_execute = 1
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_c;

    PROCEDURE istimeforpacking_d
    IS
    BEGIN
        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_conditionalexec = 'SELECT ''FALSE'' FROM DUAL WHERE  ''FALSE'' =  ''TRUE''',
               pac_debug = 9,
               pac_execute = 1
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_d;

    PROCEDURE istimeforpacking_e
    IS
    BEGIN
        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_conditionalexec = 'DUAL',
               pac_debug = 9,
               pac_execute = 1
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (1);

        ROLLBACK;
    END istimeforpacking_e;

    PROCEDURE istimeforpacking_f
    IS
        l_mappacdep                             mappacdep%ROWTYPE;

        l_packing                               packing%ROWTYPE;
        l_pacpacdep                             pacpacdep%ROWTYPE;
    BEGIN
        test_data.crea_mapping_all ();
        test_data.crea_periodicity_all ();

        test_data.crea_packing_scratch ();
        l_packing.pac_esid := 'S';
        l_packing.pac_id := pkg_common.generateuniquekey ('G');
        test_data.crea_packing (l_packing);

        l_mappacdep.mappac_mapid1 := test_data.gc_map_id;
        l_mappacdep.mappac_pacid2 := test_data.gc_pac_id;
        test_data.crea_mappacdep (l_mappacdep);

        l_pacpacdep.pacpac_pacid1 := l_packing.pac_id;
        l_pacpacdep.pacpac_pacid2 := test_data.gc_pac_id;
        test_data.crea_pacpacdep (l_pacpacdep);

        test_data.crea_sta_config ();

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'S',
               pac_execute = 1,
               pac_periodid = 'NONE'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_f;

    PROCEDURE istimeforpacking_g
    IS
        l_mappacdep                             mappacdep%ROWTYPE;
    BEGIN
        test_data.crea_sta_config ();
        test_data.crea_mapping_all ();
        test_data.crea_packing_scratch ();

        l_mappacdep.mappac_mapid1 := test_data.gc_map_id;
        l_mappacdep.mappac_pacid2 := test_data.gc_pac_id;
        test_data.crea_mappacdep (l_mappacdep);

        UPDATE packing
        SET    pac_debug = 9,
               pac_execute = 1
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_g;

    PROCEDURE istimeforpacking_h
    IS
        l_packing                               packing%ROWTYPE;
        l_pacpacdep                             pacpacdep%ROWTYPE;
    BEGIN
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();
        l_packing.pac_id := pkg_common.generateuniquekey ('G');
        test_data.crea_packing (l_packing);

        l_pacpacdep.pacpac_pacid1 := l_packing.pac_id;
        l_pacpacdep.pacpac_pacid2 := test_data.gc_pac_id;
        test_data.crea_pacpacdep (l_pacpacdep);

        UPDATE packing
        SET    pac_debug = 9,
               pac_execute = 1
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_h;

    PROCEDURE istimeforpacking_i
    IS
    BEGIN
        test_data.crea_periodicity_all ();

        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_datedone = SYSDATE,
               pac_debug = 9,
               pac_execute = 1,
               pac_periodid = 'MONTHLY'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_i;

    PROCEDURE istimeforpacking_k
    IS
    BEGIN
        test_data.crea_looptype_all ();
        test_data.crea_sta_config ();
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_conditionalexec = 'DUAL',
               pac_debug = 9,
               pac_esid = 'S',
               pac_execute = 1,
               pac_ltid = 'AC_ID'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        ut.expect (pkg_common_packing.istimeforpacking (p_pac_id => test_data.gc_pac_id)).to_equal (0);

        ROLLBACK;
    END istimeforpacking_k;

    PROCEDURE istimeforpacking_1403
    IS
        l_result                                PLS_INTEGER;
    BEGIN
        l_result := pkg_common_packing.istimeforpacking (p_pac_id => NULL);
    END istimeforpacking_1403;

    /* =========================================================================
       Test: [Test method modify_boheader - modify_boheader]].
       ---------------------------------------------------------------------- */

    PROCEDURE modify_boheader
    IS
        l_filename                              boheader.boh_filename%TYPE;
    BEGIN
        test_data.crea_boheader_scratch ();

        COMMIT;

        pkg_common_packing.modify_boheader (
            p_headerid                           => 'ut_id_a',
            p_appname                            => 'ut_appname',
            p_appver                             => 'ut_appver_',
            p_thread                             => 'ut_thread_',
            p_taskid                             => 47,
            p_hostname                           => 'ut_hostnam',
            p_filename                           => l_filename);

        ROLLBACK;
    END modify_boheader;

    PROCEDURE modify_boheader_after
    IS
    BEGIN
        -- Level 0
        test_data.del_boheader_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END modify_boheader_after;

    PROCEDURE modify_boheader_1005
    IS
        l_filename                              boheader.boh_filename%TYPE;
    BEGIN
        pkg_common_packing.modify_boheader (
            p_headerid                           => 'ut_id_a',
            p_appname                            => 'ut_appname',
            p_appver                             => 'ut_appver_',
            p_thread                             => 'ut_thread_',
            p_taskid                             => 47,
            p_hostname                           => 'ut_hostnam',
            p_filename                           => l_filename);

        ROLLBACK;
    END modify_boheader_1005;

    /* =========================================================================
       Test: [Test method setstringtagstolowercase - setstringtagstolowercase]].
       ---------------------------------------------------------------------- */

    PROCEDURE setstringtagstolowercase
    IS
        l_string                                VARCHAR2 (1024);
    BEGIN
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_be_null ();

        l_string := '';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_be_null ();

        l_string := 'Hello world!';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_equal (l_string);

        l_string := '<Hello <world!<';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_equal (l_string);

        l_string := '>Hello >world!<';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_equal (l_string);

        l_string := '<Hello> World!';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_equal ('<hello> World!');

        l_string := 'Hello <World!>';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_equal ('Hello <world!>');

        l_string := '<Hello> <World>!';
        ut.expect (pkg_common_packing.setstringtagstolowercase (p_string => l_string)).to_equal ('<hello> <world>!');
    END setstringtagstolowercase;

    /* =========================================================================
       Test: [Test method sp_get_next_pac_seq - sp_get_next_pac_seq]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_next_pac_seq
    IS
        l_errorcode                             PLS_INTEGER;
        l_errormsg                              VARCHAR2 (512);

        l_nextsequence                          packing.pac_id%TYPE;

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_fileseqmax = 9999,
               pac_nextseq = 0
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.sp_get_next_pac_seq (
            p_pacid                              => test_data.gc_pac_id,
            p_nextsequence                       => l_nextsequence,
            p_errorcode                          => l_errorcode,
            p_errormsg                           => l_errormsg,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errormsg).to_be_null ();
        ut.expect (l_nextsequence).to_equal ('0000');
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_get_next_pac_seq;

    PROCEDURE sp_get_next_pac_seq_after
    IS
    BEGIN
        -- Level 2
        test_data.del_packing_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_get_next_pac_seq_after;

    /* =========================================================================
       Test: [Test method sp_insert_header - sp_insert_header]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header_a
    IS
        l_boheader                              boheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_common_packing.sp_insert_header (
            p_packingtype                        => 'STATIND',
            p_packingid                          => l_boheader.boh_packid,
            p_headerid                           => l_boheader.boh_id,
            p_jobid                              => l_boheader.boh_job,
            p_filename                           => l_boheader.boh_filename,
            p_appname                            => l_boheader.boh_exe,
            p_appver                             => l_boheader.boh_version,
            p_thread                             => l_boheader.boh_thread,
            p_taskid                             => l_boheader.boh_job,
            p_hostname                           => l_boheader.boh_host,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_equal (1003);
        ut.expect (l_errordesc).to_equal ('The desired operation cannot be executed at this time. Try later.');
        ut.expect (l_returnstatus).to_equal (2);

        ROLLBACK;
    END sp_insert_header_a;

    PROCEDURE sp_insert_header_after
    IS
    BEGIN
        -- Level 0
        test_data.del_boheader_complete ();
        test_data.del_periodicity ();
        test_data.del_sta_config ();

        -- Level 1
        test_data.del_bohstate ();
        test_data.del_sta_job_complete ();

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
    END sp_insert_header_after;

    PROCEDURE sp_insert_header_b
    IS
        l_boheader                              boheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_pactype_all ();
        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_esid = 'A',
               pac_etid = test_data.gc_pact_id,
               pac_execute = 1,
               pac_periodid = test_data.gc_period_id,
               pac_xprocid = NULL
        WHERE  pac_id = test_data.gc_pac_id;

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datecre = SYSDATE,
               staj_esid = 'A',
               staj_nooftrials = 0,
               staj_pacid = test_data.gc_pac_id
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        l_boheader.boh_packid := test_data.gc_pac_id;

        pkg_common_packing.sp_insert_header (
            p_packingtype                        => 'STATIND',
            p_packingid                          => l_boheader.boh_packid,
            p_headerid                           => l_boheader.boh_id,
            p_jobid                              => l_boheader.boh_job,
            p_filename                           => l_boheader.boh_filename,
            p_appname                            => l_boheader.boh_exe,
            p_appver                             => l_boheader.boh_version,
            p_thread                             => l_boheader.boh_thread,
            p_taskid                             => l_boheader.boh_job,
            p_hostname                           => l_boheader.boh_host,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ROLLBACK;
    END sp_insert_header_b;

    /* =========================================================================
       Test: [Test method update_boheader - update_boheader]].
       ---------------------------------------------------------------------- */

    PROCEDURE update_boheader
    IS
        l_boheader                              boheader%ROWTYPE;

        l_sta_jobparam                          sta_jobparam%ROWTYPE;
    BEGIN
        test_data.crea_bohstate_all ();
        test_data.crea_periodicity_all ();
        test_data.crea_sta_jobstate_all ();

        test_data.crea_boheader_scratch ();

        test_data.crea_packing_scratch ();

        UPDATE packing
        SET    pac_debug = 9,
               pac_fileseqmax = 9999,
               pac_nextseq = 0
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_01.<pac_id>.<pac_name>.<pac_nextseq>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_periodid = 'YEARLY'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_02.<pac_id>.<pac_name>.<pac_nextseq>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_periodid = 'MONTHLY'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_03.<pac_id>.<pac_name>.<pac_nextseq>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_periodid = 'WEEKLY'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_04.<pac_id>.<pac_name>.<pac_nextseq>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_periodid = 'DAILY'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_05.<pac_id>.<pac_name>.<pac_nextseq>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_periodid = 'HOURLY'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_06.<pac_id>.<pac_name>.<pac_nextseq>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_periodid = 'NONE'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_07.<[DATEFROM]>.<[DATETO]>';

        test_data.crea_sta_job_scratch ();

        l_sta_jobparam.stajp_jobid := test_data.gc_staj_id;
        test_data.crea_sta_jobparam (l_sta_jobparam);

        UPDATE packing
        SET    pac_debug = 9
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_08.<ac_id>.<ac_name>.<ac_number>.<ac_mbunit>.<ac_tpid>';

        test_data.crea_account_scratch ();

        UPDATE sta_job
        SET    staj_ltvalue = test_data.gc_ac_id
        WHERE  staj_id = test_data.gc_staj_id;

        UPDATE packing
        SET    pac_debug = 9
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_09.<con_id>.<con_name>.<con_number>.<con_pscall>.<con_opkey>.<con_consol>.<con_shortid>';

        test_data.crea_contract_scratch ();

        UPDATE sta_job
        SET    staj_ltvalue = test_data.gc_con_id
        WHERE  staj_id = test_data.gc_staj_id;

        UPDATE packing
        SET    pac_debug = 9
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_10.<set_id>.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_11.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_12.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'A',
               pac_ltid = 'NONE'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => 'NONE',
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_13.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'A',
               pac_ltid = 'NONE'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_14.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'S',
               pac_ltid = 'NONE'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        test_data.crea_looptype_all ();

        l_boheader.boh_filename := 'file_15.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'A',
               pac_ltid = 'AC_ID'
        WHERE  pac_id = test_data.gc_pac_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => 'NONE',
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        test_data.crea_looptype_all ();

        l_boheader.boh_filename := 'file_16.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'S',
               pac_ltid = 'AC_ID'
        WHERE  pac_id = test_data.gc_pac_id;

        UPDATE sta_job
        SET    staj_esid = 'D'
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => 'NONE',
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;

        l_boheader.boh_filename := 'file_17.<loopvar>';

        UPDATE packing
        SET    pac_debug = 9,
               pac_esid = 'S',
               pac_ltid = 'AC_ID'
        WHERE  pac_id = test_data.gc_pac_id;

        UPDATE sta_job
        SET    staj_esid = 'D'
        WHERE  staj_id = test_data.gc_staj_id;

        COMMIT;

        pkg_common_packing.update_boheader (
            p_headerid                           => test_data.gc_boh_id,
            p_jobid                              => test_data.gc_staj_id,
            p_filename                           => l_boheader.boh_filename,
            p_filedate                           => NULL,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => 4711,
            p_errcount                           => 4711,
            p_datefc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'),
            p_datelc                             => TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS'));

        ROLLBACK;
    END update_boheader;

    PROCEDURE update_boheader_after
    IS
    BEGIN
        -- Level 0
        test_data.del_boheader_complete ();
        test_data.del_sta_jobparam_complete ();

        -- Level 1
        test_data.del_sta_job_complete ();
        test_data.del_bohstate ();
        test_data.del_sta_jobstate ();

        -- Level 2
        test_data.del_contract_complete ();
        test_data.del_packing_complete ();

        -- Level 3
        test_data.del_account_complete ();
        test_data.del_looptype ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END update_boheader_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_common_packing;
/