CREATE OR REPLACE PACKAGE test_in_development
IS
    /*<>
       Unit testing software in development.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    --%test
    PROCEDURE sp_lat_cdr_b;
END test_in_development;
/