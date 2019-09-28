CREATE OR REPLACE PACKAGE BODY sbsdb_sql_lib
IS
    /* =========================================================================
       Package Exports
       ---------------------------------------------------------------------- */

    --    SUBTYPE info_short_t IS VARCHAR2 (255);

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE new_line
    IS
    BEGIN
        DBMS_OUTPUT.new_line ();
    END new_line;

    PROCEDURE put (p_text_in IN sbsdb_type_lib.api_help_t)
    IS
    BEGIN
        DBMS_OUTPUT.put (p_text_in);
    END put;

    PROCEDURE put_line (p_text_in IN sbsdb_type_lib.api_help_t)
    IS
    BEGIN
        DBMS_OUTPUT.put_line (p_text_in);
    END put_line;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_sql_lib;
/