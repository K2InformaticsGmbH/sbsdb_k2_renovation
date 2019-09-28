CREATE OR REPLACE PACKAGE BODY test_sbsdb_io
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sbsdb_io_lib.get_sbsdb_property - sbsdb_io_lib.ins_sbsdb_log]].
       ---------------------------------------------------------------------- */

    PROCEDURE ins_sbsdb_log_table
    IS
        lc_ckey                        CONSTANT sbsdb_type_lib.logger_ckey_t := TO_NUMBER (TO_CHAR (SYSTIMESTAMP, 'YYYYMMDDHH24MISS'));
        lc_cvalue_set                  CONSTANT sbsdb_type_lib.logger_cvalue_t := '{}';

        l_cvalue_get                            sbsdb_type_lib.logger_cvalue_t;
        l_sql_stmnt                             sbsdb_type_lib.sql_stmnt_t;
    BEGIN
        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            RETURN;
        END IF;

        sbsdb_io_lib.ins_sbsdb_log (
            p_ckey_in                            => lc_ckey,
            p_cvalue_in                          => lc_cvalue_set,
            p_logger_level_in                    => 0,
            p_scope_in                           => NULL,
            p_time_stamp_in                      => SYSTIMESTAMP);

        l_sql_stmnt := 'SELECT cvalue
                          FROM sbsdb_log
                         WHERE ckey = ' || lc_ckey;

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_cvalue_get;

        ut.expect (l_cvalue_get).to_equal (lc_cvalue_set);
    END ins_sbsdb_log_table;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_sbsdb_io;
/
