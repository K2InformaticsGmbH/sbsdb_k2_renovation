CREATE OR REPLACE PACKAGE sbsdb_api_lib
IS
    /*<>
    SBSDB specific auxiliary functions for SBSDB standard tasks.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    --<> api_hidden = true
    FUNCTION scope (p_method_name_in IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t;

    --<> api_hidden = true
    FUNCTION scope (
        p_package_name_in                       IN sbsdb_type_lib.oracle_name_t,
        p_method_name_in                        IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t;
/*
*/
END sbsdb_api_lib;
/
