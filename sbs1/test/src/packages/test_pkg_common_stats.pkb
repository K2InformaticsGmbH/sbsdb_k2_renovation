CREATE OR REPLACE PACKAGE BODY test_pkg_common_stats
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method get_sta_job_error_count - get_sta_job_error_count]].
       ---------------------------------------------------------------------- */

    PROCEDURE get_sta_job_error_count
    IS
    BEGIN
        ut.expect (pkg_common_stats.get_sta_job_error_count (p_stajpacid => NULL, p_stajperiodid => NULL)).to_equal (0);

        ROLLBACK;

        test_data.crea_sta_job_scratch ();
        test_data.crea_sta_config ();

        UPDATE sta_job
        SET    staj_datesta = SYSDATE,
               staj_nooftrials =
                     (SELECT stac_nooftrials
                      FROM   sta_config
                      WHERE  stac_id = 'DEFAULT')
                   + 1;

        COMMIT;

        ut.expect (pkg_common_stats.get_sta_job_error_count (p_stajpacid => test_data.gc_pac_id, p_stajperiodid => test_data.gc_period_id)).to_equal (1);

        ROLLBACK;
    END get_sta_job_error_count;

    PROCEDURE get_sta_job_error_count_after
    IS
    BEGIN
        -- 0
        test_data.del_sta_config ();

        -- 1
        test_data.del_sta_job_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END get_sta_job_error_count_after;

    /* =========================================================================
       Test: [Test method get_sta_job_scheduled_count - get_sta_job_scheduled_count]].
       ---------------------------------------------------------------------- */

    PROCEDURE get_sta_job_scheduled_count
    IS
    BEGIN
        ut.expect (pkg_common_stats.get_sta_job_scheduled_count (p_stajpacid => NULL, p_stajperiodid => NULL)).to_equal (0);

        ROLLBACK;

        test_data.crea_sta_job_scratch ();
        test_data.crea_sta_config ();

        UPDATE sta_job
        SET    staj_datesta = SYSDATE,
               staj_nooftrials =
                     (SELECT stac_nooftrials
                      FROM   sta_config
                      WHERE  stac_id = 'DEFAULT')
                   - 1;

        COMMIT;

        ut.expect (pkg_common_stats.get_sta_job_scheduled_count (p_stajpacid => test_data.gc_pac_id, p_stajperiodid => test_data.gc_period_id)).to_equal (1);

        ROLLBACK;
    END get_sta_job_scheduled_count;

    PROCEDURE get_sta_job_scheduled_count_af
    IS
    BEGIN
        -- 0
        test_data.del_sta_config ();

        -- 1
        test_data.del_sta_job_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END get_sta_job_scheduled_count_af;

    /* =========================================================================
       Test: [Test method get_sta_job_working - get_sta_job_working]].
       ---------------------------------------------------------------------- */

    PROCEDURE get_sta_job_working
    IS
        l_stajid                                sta_job.staj_id%TYPE;
    BEGIN
        pkg_common_stats.get_sta_job_working (p_stajpacid => NULL, p_stajperiodid => NULL, p_boheaderid => NULL, p_stajid => l_stajid);

        ut.expect (l_stajid).to_be_null ();

        ROLLBACK;

        test_data.crea_sta_config ();

        test_data.crea_sta_job_scratch ();

        UPDATE sta_job
        SET    staj_datesta = SYSDATE,
               staj_nooftrials =
                     (SELECT stac_nooftrials
                      FROM   sta_config
                      WHERE  stac_id = 'DEFAULT')
                   - 1;

        COMMIT;

        pkg_common_stats.get_sta_job_working (p_stajpacid => test_data.gc_pac_id, p_stajperiodid => test_data.gc_period_id, p_boheaderid => test_data.gc_boh_id, p_stajid => l_stajid);

        ut.expect (l_stajid).to_equal (test_data.gc_staj_id);

        ROLLBACK;
    END get_sta_job_working;

    PROCEDURE get_sta_job_working_after
    IS
    BEGIN
        -- 1
        test_data.del_sta_job_complete ();

        -- 0
        test_data.del_sta_config ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END get_sta_job_working_after;

    /* =========================================================================
       Test: [Test method new_sta_job_working - new_sta_job_working]].
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_job_working
    IS
        l_stajid                                sta_job.staj_id%TYPE;
    BEGIN
        test_data.crea_sta_config ();

        test_data.crea_sta_job_scratch ();
        test_data.crea_packing_scratch ();

        UPDATE sta_job
        SET    staj_datesta = SYSDATE,
               staj_nooftrials =
                     (SELECT stac_nooftrials
                      FROM   sta_config
                      WHERE  stac_id = 'DEFAULT')
                   - 1;

        COMMIT;

        pkg_common_stats.new_sta_job_working (
            p_stajparentid                       => test_data.gc_staj_id,
            p_stajpacid                          => test_data.gc_pac_id,
            p_stajltvalue                        => 'ut_value_a',
            p_stajperiodid                       => test_data.gc_period_id,
            p_boheaderid                         => test_data.gc_boh_id,
            p_stajid                             => l_stajid);

        ut.expect (l_stajid).to_be_not_null ();

        ROLLBACK;
    END new_sta_job_working;

    PROCEDURE new_sta_job_working_after
    IS
    BEGIN
        -- 0
        test_data.del_sta_jobparam_complete ();
        test_data.del_sta_config ();

        -- 1
        test_data.del_sta_job_complete ();

        -- 2
        test_data.del_packing_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END new_sta_job_working_after;

    /* =========================================================================
       Test: [Test method new_sta_jobs_loopers - new_sta_jobs_loopers]].
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_jobs_loopers
    IS
        l_createdjobcount                       PLS_INTEGER;
    BEGIN
        test_data.crea_periodicity_all ();
        test_data.crea_sta_config ();

        test_data.crea_sta_job_scratch ();
        test_data.crea_packing_scratch ();
        test_data.crea_paciterator_scratch ();

        UPDATE packing
        SET    pac_itid = test_data.gc_paci_id;

        UPDATE sta_job
        SET    staj_datesta = SYSDATE,
               staj_nooftrials =
                     (SELECT stac_nooftrials
                      FROM   sta_config
                      WHERE  stac_id = 'DEFAULT')
                   - 1;

        COMMIT;

        pkg_common_stats.new_sta_jobs_loopers (
            p_stajparentid                       => test_data.gc_staj_id,
            p_stajpacid                          => test_data.gc_pac_id,
            p_stajperiodid                       => test_data.gc_period_id,
            p_boheaderid                         => test_data.gc_boh_id,
            p_createdjobcount                    => l_createdjobcount);

        ut.expect (l_createdjobcount).to_be_greater_than (0);

        ROLLBACK;
    END new_sta_jobs_loopers;

    PROCEDURE new_sta_jobs_loopers_after
    IS
    BEGIN
        -- 0
        test_data.del_paciterator_complete ();
        test_data.del_periodicity ();
        test_data.del_sta_config ();
        test_data.del_sta_jobparam_complete ();

        -- 1
        test_data.del_sta_job_complete ();

        -- 2
        test_data.del_packing_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END new_sta_jobs_loopers_after;

    /* =========================================================================
       Test: [Test method update_sta_job_success - update_sta_job_success]].
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job_success
    IS
    BEGIN
        test_data.crea_sta_job_scratch ();

        COMMIT;

        pkg_common_stats.update_sta_job_success (p_stajid => test_data.gc_staj_id);

        ROLLBACK;
    END update_sta_job_success;

    PROCEDURE update_sta_job_success_after
    IS
    BEGIN
        test_data.del_sta_job_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END update_sta_job_success_after;

    /* =========================================================================
       Test: [Test method update_sta_job_working - update_sta_job_working]].
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job_working
    IS
    BEGIN
        test_data.crea_sta_job_scratch ();

        COMMIT;

        pkg_common_stats.update_sta_job_working (p_stajid => test_data.gc_staj_id, p_boheaderid => test_data.gc_boh_id);

        ROLLBACK;
    END update_sta_job_working;

    PROCEDURE update_sta_job_working_after
    IS
    BEGIN
        test_data.del_sta_job_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END update_sta_job_working_after;

    /* =========================================================================
       Test: [Test method watchpackagestatechanges - watchpackagestatechanges]].
       ---------------------------------------------------------------------- */

    PROCEDURE watchpackagestatechanges
    IS
    BEGIN
        test_data.crea_sta_job_scratch ();
        test_data.crea_sta_config ();

        COMMIT;

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'A',
            vnewpacesid                          => 'D',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'A',
            vnewpacesid                          => 'I',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'A',
            vnewpacesid                          => 'L',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'I',
            vnewpacesid                          => 'A',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'I',
            vnewpacesid                          => 'D',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'L',
            vnewpacesid                          => 'A',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'L',
            vnewpacesid                          => 'D',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'L',
            vnewpacesid                          => 'R',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'S',
            vnewpacesid                          => 'D',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'S',
            vnewpacesid                          => 'I',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        pkg_common_stats.watchpackagestatechanges (
            vpacid                               => test_data.gc_pac_id,
            voldpacesid                          => 'S',
            vnewpacesid                          => 'L',
            voldpacltid                          => NULL,
            vnewpacltid                          => NULL);

        ROLLBACK;
    END watchpackagestatechanges;

    PROCEDURE watchpackagestatechanges_after
    IS
    BEGIN
        -- 0
        test_data.del_sta_config ();

        -- 1
        test_data.del_sta_job_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END watchpackagestatechanges_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_common_stats;
/
