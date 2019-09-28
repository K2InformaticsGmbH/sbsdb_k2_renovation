CREATE OR REPLACE PACKAGE BODY sbsdb_type_lib
IS
    gc_false                       CONSTANT bool_t := 'false';
    gc_true                        CONSTANT bool_t := 'true';

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION cr
        RETURN VARCHAR2;

    FUNCTION crlf
        RETURN VARCHAR2;

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    FUNCTION FALSE
        RETURN bool_t
    IS
    BEGIN
        RETURN gc_false;
    END FALSE;

    FUNCTION get_os_crlf
        RETURN VARCHAR2
    IS
    BEGIN
        IF sbsdb_db_con.is_os_windows () = sbsdb_type_lib.TRUE
        THEN
            RETURN crlf ();
        ELSE
            RETURN lf ();
        END IF;
    END get_os_crlf;

    FUNCTION lf
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CHR (10);
    END lf;

    FUNCTION TRUE
        RETURN bool_t
    IS
    BEGIN
        RETURN gc_true;
    END TRUE;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    FUNCTION cr
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CHR (13);
    END cr;

    FUNCTION crlf
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CHR (13) || CHR (10);
    END crlf;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_type_lib;
/