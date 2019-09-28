CREATE OR REPLACE PACKAGE BODY sbsdb_api_lib
IS
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
       Generation of api scope (callable api method name) from package and method name
       ---------------------------------------------------------------------- */

    FUNCTION scope (p_method_name_in IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t
    IS
    BEGIN
        RETURN (LOWER (p_method_name_in));
    END scope;

    FUNCTION scope (
        p_package_name_in                       IN sbsdb_type_lib.oracle_name_t,
        p_method_name_in                        IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t
    IS
    BEGIN
        RETURN (LOWER (p_package_name_in) || '.' || LOWER (p_method_name_in));
    END scope;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_api_lib;
/