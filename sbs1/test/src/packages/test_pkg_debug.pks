CREATE OR REPLACE PACKAGE test_pkg_debug
IS
    /*<>
       Unit testing package pkg_debug.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       debug_reva.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(debug_reva_after)
    PROCEDURE debug_reva;

    PROCEDURE debug_reva_after;

END test_pkg_debug;
/
