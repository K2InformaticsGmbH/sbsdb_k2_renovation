CREATE OR REPLACE PACKAGE sbsdb_db_con
IS
    /*<>
    Back-end package for managing database-related tasks.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration
       ---------------------------------------------------------------------- */

    --<> object_privilege select = sys.v_$database
    FUNCTION dbuname
        RETURN sbsdb_type_lib.property_value_t /*<>
    Returns name of the database as specified in the DB_UNIQUE_NAME initialization parameter.
    */
                                              ;

    --<> object_privilege select = sys.v_$database
    FUNCTION is_cdb
        RETURN sbsdb_type_lib.bool_t /*<>
    Checks whether the current database is a CDB.
    */
                                    ;

    FUNCTION is_os_windows
        RETURN sbsdb_type_lib.bool_t /*<>
    Checks whether the underlying operating system is Windows.
    */
                                    ;

    FUNCTION is_valid_db_version (
        p_version_required_in                   IN PLS_INTEGER,
        p_release_required_in                   IN PLS_INTEGER)
        RETURN sbsdb_type_lib.bool_t /*<>
    Checks if the database version is still supported for an operation

    Parameters:
       p_version_required_in           IN PLS_INTEGER
       p_release_required_in           IN PLS_INTEGER

    Returns:
      - true, if the database version is ok for the operation
      - false, if the database version is not ok for the operation
    */
                                    ;

    FUNCTION pdbname
        RETURN sbsdb_type_lib.property_value_t /*<>
    If queried while connected to a CDB, returns the current container name.
    Otherwise, returns null.
    */
                                              ;

    FUNCTION sbsdb_schema
        RETURN sbsdb_type_lib.property_value_t /*<>
    Returns SBSDB installation schema.
    */
                                              ;

    PROCEDURE raise_non_valid_db_version (
        p_version_required_in                   IN PLS_INTEGER := 10, -- only globally limited
        p_release_required_in                   IN PLS_INTEGER := 0, -- only globally limited
        p_err_msg_in                            IN sbsdb_type_lib.err_msg_t := NULL,
        p_variable_1_in                         IN VARCHAR2 := NULL,
        p_variable_2_in                         IN VARCHAR2 := NULL) /*<>
    Raises an exception if the workflow requires a database version/release
    which is higher than the currently installed version

    Parameters:
        p_version_required_in - integer (version 11 or 12 for now)
        p_release_required_in - integer (release 0,1,2,..)
        p_err_msg_in          - exception error message or NULL for default
        p_variable_1_in       - message token replacement for :1
        p_variable_2_in       - message token replacement for :2
    */
                                                                    ;
/*
*/
END sbsdb_db_con;
/
