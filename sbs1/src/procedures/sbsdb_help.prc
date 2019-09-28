CREATE OR REPLACE PROCEDURE sbsdb_help (sqlt_str_filter IN VARCHAR2:= NULL)
/* =============================================================================
   Wrapper procedure.
   -------------------------------------------------------------------------- */
IS
BEGIN
    sbsdb_help_lib.HELP (sqlt_str_filter);
END sbsdb_help;
/