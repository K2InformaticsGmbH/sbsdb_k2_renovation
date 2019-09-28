CREATE OR REPLACE PACKAGE test_pkg_common_stats
IS
    /*<>
       Unit testing package pkg_common_stats.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       get_sta_job_error_count.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(get_sta_job_error_count_after)
    PROCEDURE get_sta_job_error_count;

    PROCEDURE get_sta_job_error_count_after;

    /* =========================================================================
       get_sta_job_scheduled_count.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(get_sta_job_scheduled_count_af)
    PROCEDURE get_sta_job_scheduled_count;

    PROCEDURE get_sta_job_scheduled_count_af;

    /* =========================================================================
       get_sta_job_working.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(get_sta_job_working_after)
    PROCEDURE get_sta_job_working;

    PROCEDURE get_sta_job_working_after;

    /* =========================================================================
       new_sta_job_working.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(new_sta_job_working_after)
    PROCEDURE new_sta_job_working;

    PROCEDURE new_sta_job_working_after;

    /* =========================================================================
       new_sta_jobs_loopers.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(new_sta_jobs_loopers_after)
    PROCEDURE new_sta_jobs_loopers;

    PROCEDURE new_sta_jobs_loopers_after;

    /* =========================================================================
       update_sta_job_success.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(update_sta_job_success_after)
    PROCEDURE update_sta_job_success;

    PROCEDURE update_sta_job_success_after;

    /* =========================================================================
       update_sta_job_working.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(update_sta_job_working_after)
    PROCEDURE update_sta_job_working;

    PROCEDURE update_sta_job_working_after;

    /* =========================================================================
       watchpackagestatechanges.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(watchpackagestatechanges_after)
    PROCEDURE watchpackagestatechanges;

    PROCEDURE watchpackagestatechanges_after;
END test_pkg_common_stats;
/
