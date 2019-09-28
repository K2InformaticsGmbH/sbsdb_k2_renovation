CREATE OR REPLACE PACKAGE test_pkg_admin_common
IS
    /*<>
       Unit testing package pkg_admin_common.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       geterrordesc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(geterrordesc_after)
    PROCEDURE geterrordesc;

    PROCEDURE geterrordesc_after;

    /* =========================================================================
       sp_add_report.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_add_report_after)
    PROCEDURE sp_add_report;

    --%test
    --%throws(-2291)
    PROCEDURE sp_add_report_02291;

    PROCEDURE sp_add_report_after;

    /* =========================================================================
       sp_hide_job_output.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_hide_job_output_after)
    PROCEDURE sp_hide_job_output;

    PROCEDURE sp_hide_job_output_after;

    /* =========================================================================
       sp_validate_exchange_rates.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_validate_exchange_rates_aft)
    PROCEDURE sp_validate_exchange_rates;

    PROCEDURE sp_validate_exchange_rates_aft;
END test_pkg_admin_common;
/
