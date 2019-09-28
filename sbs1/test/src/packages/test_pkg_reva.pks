CREATE OR REPLACE PACKAGE test_pkg_reva
IS
    /*<>
       Unit testing package pkg_reva.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       sp_try_reva_recent_msc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_try_reva_recent_msc_after)
    PROCEDURE sp_try_reva_recent_msc_a;

    PROCEDURE sp_try_reva_recent_msc_after;

    --%test
    --%aftertest(sp_try_reva_recent_msc_after)
    PROCEDURE sp_try_reva_recent_msc_b;

    /* =========================================================================
       sp_try_reva_recent_others.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_try_reva_recent_others_after)
    PROCEDURE sp_try_reva_recent_others;

    PROCEDURE sp_try_reva_recent_others_after;

    /* =========================================================================
       sp_try_reva_recent_smsc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_try_reva_recent_smsc_after)
    PROCEDURE sp_try_reva_recent_smsc;

    PROCEDURE sp_try_reva_recent_smsc_after;
END test_pkg_reva;
/