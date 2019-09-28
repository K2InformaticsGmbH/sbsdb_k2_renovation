CREATE OR REPLACE PACKAGE test_pkg_mec_ic_csv
IS
    /*<>
       Unit testing package pkg_mec_ic_csv.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       sp_insert_csv.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_insert_csv_after)
    PROCEDURE sp_insert_csv;

    PROCEDURE sp_insert_csv_after;

    /* =========================================================================
       sp_insert_header.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header;

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header_1001;

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header_1002;

    --%test
    PROCEDURE sp_insert_header_1003;

    PROCEDURE sp_insert_header_after;

    /* =========================================================================
       sp_update_header.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_update_header_after)
    PROCEDURE sp_update_header;

    PROCEDURE sp_update_header_after;
END test_pkg_mec_ic_csv;
/