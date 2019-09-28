CREATE OR REPLACE PACKAGE BODY sbsdb_db_con
IS
    /* =========================================================================
       Local Variable Declarations.
       ---------------------------------------------------------------------- */

    gc_sbsdb_schema                CONSTANT sbsdb_type_lib.oracle_name_t := 'sbs1_admin';

    -- hard coded global SBSDB DB version limits (respected for all methods)
    gc_min_db_version              CONSTANT PLS_INTEGER := 12; -- means: nothing below 12c
    gc_min_db_release              CONSTANT PLS_INTEGER := 1;

    gc_max_db_version              CONSTANT PLS_INTEGER := 12; -- means: do not support 18 yet
    gc_max_db_release              CONSTANT PLS_INTEGER := 99;

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Returns name of the database as specified in the DB_UNIQUE_NAME
       initialization parameter.
       ---------------------------------------------------------------------- */

    FUNCTION dbuname
        RETURN sbsdb_type_lib.property_value_t
    IS
    BEGIN
        RETURN SYS_CONTEXT ('userenv', 'db_unique_name');
    END dbuname;

    /* =========================================================================
       Checks whether the current database is a CDB.
       ---------------------------------------------------------------------- */

    FUNCTION is_cdb
        RETURN sbsdb_type_lib.bool_t
    IS
        l_cdb                                   sbsdb_type_lib.property_value_t;
    BEGIN
        SELECT cdb INTO l_cdb FROM v$database;

        RETURN CASE
                   WHEN l_cdb = 'YES'
                   THEN
                       sbsdb_type_lib.TRUE
                   ELSE
                       sbsdb_type_lib.FALSE
               END;
    END is_cdb;

    /* =========================================================================
       Checks whether the underlying operating system is any Linux version.
       ---------------------------------------------------------------------- */

    FUNCTION is_os_linux
        RETURN sbsdb_type_lib.bool_t
    IS
    BEGIN
        RETURN CASE
                   WHEN UPPER (DBMS_UTILITY.port_string ()) LIKE '%LINUX%'
                   THEN
                       sbsdb_type_lib.TRUE
                   ELSE
                       sbsdb_type_lib.FALSE
               END;
    END is_os_linux;

    /* =========================================================================
       Checks whether the underlying operating system is Windows.
       ---------------------------------------------------------------------- */

    FUNCTION is_os_windows
        RETURN sbsdb_type_lib.bool_t
    IS
    BEGIN
        RETURN CASE
                   WHEN UPPER (DBMS_UTILITY.port_string ()) LIKE 'IBMPC/WIN_NT%'
                   THEN
                       sbsdb_type_lib.TRUE
                   ELSE
                       sbsdb_type_lib.FALSE
               END;
    END is_os_windows;

    /* =========================================================================
       Checks if the database version is sufficient (supports the current
       operation)
       ---------------------------------------------------------------------- */

    FUNCTION is_valid_db_version (
        p_version_required_in                   IN PLS_INTEGER,
        p_release_required_in                   IN PLS_INTEGER)
        RETURN sbsdb_type_lib.bool_t
    IS
        l_result                                BOOLEAN;
    BEGIN
        l_result :=
               (DBMS_DB_VERSION.version < gc_max_db_version)
            OR (    DBMS_DB_VERSION.version = gc_max_db_version
                AND DBMS_DB_VERSION.release <= gc_max_db_release);

        IF l_result
        THEN
            -- compare required version/release with instance version/release
            l_result :=
                   (DBMS_DB_VERSION.version > p_version_required_in)
                OR (    DBMS_DB_VERSION.version = p_version_required_in
                    AND DBMS_DB_VERSION.release >= p_release_required_in);
        END IF;

        RETURN CASE
                   WHEN l_result
                   THEN
                       sbsdb_type_lib.TRUE
                   ELSE
                       sbsdb_type_lib.FALSE
               END;
    END is_valid_db_version;

    /* =========================================================================
       If queried while connected to a CDB, returns the current container name.
       Otherwise, returns null.
       ---------------------------------------------------------------------- */

    FUNCTION pdbname
        RETURN sbsdb_type_lib.property_value_t
    IS
    BEGIN
        RETURN CASE
                   WHEN is_cdb () = sbsdb_type_lib.TRUE
                   THEN
                       SYS_CONTEXT ('userenv', 'con_name')
                   ELSE
                       NULL
               END;
    END pdbname;

    /* =========================================================================
       Returns SBSDB installation schema.
       ---------------------------------------------------------------------- */

    FUNCTION sbsdb_schema
        RETURN sbsdb_type_lib.property_value_t
    IS
    BEGIN
        RETURN gc_sbsdb_schema;
    END sbsdb_schema;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Raises an exception if the database version is not longer supported
       ---------------------------------------------------------------------- */

    PROCEDURE raise_non_valid_db_version (
        p_version_required_in                   IN PLS_INTEGER := 10, -- only globally limited
        p_release_required_in                   IN PLS_INTEGER := 0, -- only globally limited
        p_err_msg_in                            IN sbsdb_type_lib.err_msg_t := NULL,
        p_variable_1_in                         IN VARCHAR2 := NULL,
        p_variable_2_in                         IN VARCHAR2 := NULL)
    IS
    BEGIN
        IF is_valid_db_version (gc_min_db_version, gc_min_db_release) = sbsdb_type_lib.FALSE
        THEN
            IF p_err_msg_in IS NULL
            THEN
                sbsdb_error_con.raise_appl_error (
                    p_errcode_in                         => sbsdb_error_lib.en_non_valid_db_version,
                    p_err_msg_in                         => sbsdb_error_lib.em_non_valid_db_version,
                    p_variable_1_in                      => gc_min_db_version,
                    p_variable_2_in                      => gc_min_db_release);
            ELSE
                sbsdb_error_con.raise_appl_error (
                    p_errcode_in                         => sbsdb_error_lib.en_non_valid_db_version,
                    p_err_msg_in                         => p_err_msg_in,
                    p_variable_1_in                      => p_variable_1_in,
                    p_variable_2_in                      => p_variable_2_in);
            END IF;
        END IF;

        IF is_valid_db_version (p_version_required_in, p_release_required_in) = sbsdb_type_lib.FALSE
        THEN
            IF p_err_msg_in IS NULL
            THEN
                sbsdb_error_con.raise_appl_error (
                    p_errcode_in                         => sbsdb_error_lib.en_non_valid_db_version,
                    p_err_msg_in                         => sbsdb_error_lib.em_non_valid_db_version,
                    p_variable_1_in                      => p_version_required_in,
                    p_variable_2_in                      => p_release_required_in);
            ELSE
                sbsdb_error_con.raise_appl_error (
                    p_errcode_in                         => sbsdb_error_lib.en_non_valid_db_version,
                    p_err_msg_in                         => p_err_msg_in,
                    p_variable_1_in                      => p_variable_1_in,
                    p_variable_2_in                      => p_variable_2_in);
            END IF;
        END IF;
    END raise_non_valid_db_version;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_db_con;
/
