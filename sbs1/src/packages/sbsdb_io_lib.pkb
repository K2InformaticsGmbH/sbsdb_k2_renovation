SET DEFINE OFF;

CREATE OR REPLACE PACKAGE BODY sbsdb_io_lib
IS
    gc_io_type_log_file            CONSTANT sbsdb_type_lib.oracle_name_t := 'file';
    gc_io_type_log_table           CONSTANT sbsdb_type_lib.oracle_name_t := 'table';

    g_io_type_log                  sbsdb_type_lib.oracle_name_t := 'table';

    /* =========================================================================
       Private Function Definition.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Definition.
       ---------------------------------------------------------------------- */

    --    PROCEDURE ins_sbsdb_log_file (p_cvalue_in IN sbsdb_type_lib.logger_cvalue_t);

    PROCEDURE ins_sbsdb_log_table (
        p_ckey_in                               IN sbsdb_type_lib.logger_ckey_t,
        p_cvalue_in                             IN sbsdb_type_lib.logger_cvalue_t,
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_time_stamp_in                         IN TIMESTAMP);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Getting the IO Type of log.
       ---------------------------------------------------------------------- */

    FUNCTION get_io_type_log
        RETURN sbsdb_type_lib.oracle_name_t
    IS
    BEGIN
        RETURN g_io_type_log;
    END get_io_type_log;

    FUNCTION get_io_type_log_table
        RETURN sbsdb_type_lib.oracle_name_t
    IS
    BEGIN
        RETURN gc_io_type_log_table;
    END get_io_type_log_table;

    /* =========================================================================
       Setting the IO Type of Log.
       ---------------------------------------------------------------------- */

    PROCEDURE set_io_type_log_file
    IS
    BEGIN
        g_io_type_log := gc_io_type_log_file;
    END set_io_type_log_file;

    PROCEDURE set_io_type_log_table
    IS
    BEGIN
        g_io_type_log := gc_io_type_log_table;
    END set_io_type_log_table;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Application uses this to log errors and events.
       ---------------------------------------------------------------------- */

    PROCEDURE ins_sbsdb_log (
        p_ckey_in                               IN sbsdb_type_lib.logger_ckey_t,
        p_cvalue_in                             IN sbsdb_type_lib.logger_cvalue_t,
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_time_stamp_in                         IN TIMESTAMP)
    AS
    BEGIN
        ins_sbsdb_log_table (
            p_ckey_in                            => p_ckey_in,
            p_cvalue_in                          => p_cvalue_in,
            p_logger_level_in                    => p_logger_level_in,
            p_scope_in                           => p_scope_in,
            p_time_stamp_in                      => p_time_stamp_in);
    END ins_sbsdb_log;

    /* =========================================================================
       Application uses this to log errors and events - database version.
       ---------------------------------------------------------------------- */

    PROCEDURE ins_sbsdb_log_table (
        p_ckey_in                               IN sbsdb_type_lib.logger_ckey_t,
        p_cvalue_in                             IN sbsdb_type_lib.logger_cvalue_t,
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_time_stamp_in                         IN TIMESTAMP)
    AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO sbsdb_log (
                        ckey,
                        cvalue,
                        logger_level,
                        scope,
                        time_stamp)
        VALUES      (
                        p_ckey_in,
                        p_cvalue_in,
                        p_logger_level_in,
                        p_scope_in,
                        p_time_stamp_in);

        COMMIT;
    END ins_sbsdb_log_table;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */

BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_io_lib;
/