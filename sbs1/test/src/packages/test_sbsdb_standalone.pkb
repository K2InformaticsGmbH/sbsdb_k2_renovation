SET DEFINE OFF

CREATE OR REPLACE PACKAGE BODY test_sbsdb_standalone
IS
    gc_is_del_all                           BOOLEAN := TRUE;

/* =========================================================================
   Private Procedure Definition.
   ---------------------------------------------------------------------- */

/* =========================================================================
   Public Procedure Implementation.
   ---------------------------------------------------------------------- */

/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_sbsdb_standalone;
/
