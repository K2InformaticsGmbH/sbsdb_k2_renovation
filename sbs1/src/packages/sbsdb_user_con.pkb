CREATE OR REPLACE PACKAGE BODY sbsdb_user_con
IS
    /* =========================================================================
       Private Function Declaration
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Declaration
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Function Implementation
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Returns the operating system user name of the client process that
       initiated the database session (OS_USER).
       ---------------------------------------------------------------------- */

    FUNCTION get_os_user
        RETURN sbsdb_type_lib.property_value_t
    IS
    BEGIN
        RETURN SYS_CONTEXT ('userenv', 'os_user');
    END get_os_user;

    /* =========================================================================
       Returns the session ID (SID).
       ---------------------------------------------------------------------- */

    FUNCTION get_session_id
        RETURN PLS_INTEGER
    IS
    BEGIN
        RETURN SYS_CONTEXT ('userenv', 'sid');
    END get_session_id;
/* =========================================================================
   Public Procedure Implementation.
   ---------------------------------------------------------------------- */

/* =========================================================================
   Private Function Implementation
   ---------------------------------------------------------------------- */

/* =========================================================================
   Private Procedure Implementation
   ---------------------------------------------------------------------- */

/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_user_con;
/