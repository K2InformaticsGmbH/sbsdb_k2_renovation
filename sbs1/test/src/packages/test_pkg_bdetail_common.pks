CREATE OR REPLACE PACKAGE test_pkg_bdetail_common
IS
    /*<>
       Unit testing package pkg_bdetail_common.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       contract_iot_chf.
       ---------------------------------------------------------------------- */

    PROCEDURE contract_iot_chf_after;

    --%test
    --%aftertest(contract_iot_chf_after)
    PROCEDURE contract_iot_chf_mms;

    --%test
    --%aftertest(contract_iot_chf_after)
    PROCEDURE contract_iot_chf_sms;

    /* =========================================================================
       contractperiodend.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE contractperiodend;

    /* =========================================================================
       contractperiodstart.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE contractperiodstart;

    /* =========================================================================
       generatebase36kpikey.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE generatebase36kpikey;

    /* =========================================================================
       gettypeformapping.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(gettypeformapping_after)
    PROCEDURE gettypeformapping;

    PROCEDURE gettypeformapping_after;

    /* =========================================================================
       gettypeforpacking.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(gettypeforpacking_after)
    PROCEDURE gettypeforpacking;

    PROCEDURE gettypeforpacking_after;

    /* =========================================================================
       getufihfield.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE getufihfield;

    /* =========================================================================
       normalizedmsisdn.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE normalizedmsisdn;

    /* =========================================================================
       simplehash.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE simplehash;

    /* =========================================================================
       sp_update_dls_dates.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_update_dls_dates_after)
    PROCEDURE sp_update_dls_dates;

    PROCEDURE sp_update_dls_dates_after;
END test_pkg_bdetail_common;
/