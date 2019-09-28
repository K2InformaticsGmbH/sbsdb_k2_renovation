CREATE OR REPLACE PACKAGE test_sbsdb_io
IS
    /*<>
       Unit testing package sbsdb_io_lib.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       sbsdb_io_lib.ins_sbsdb_log_table.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE ins_sbsdb_log_table;
END test_sbsdb_io;
/
