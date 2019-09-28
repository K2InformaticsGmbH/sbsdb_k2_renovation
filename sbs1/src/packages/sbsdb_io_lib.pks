CREATE OR REPLACE PACKAGE sbsdb_io_lib
IS
    /*<>
    Interface to the file system
    Implements file system methods to be used by the application

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    --<> api_hidden = true
    FUNCTION get_io_type_log
        RETURN sbsdb_type_lib.oracle_name_t;

    --<> api_hidden = true
    FUNCTION get_io_type_log_table
        RETURN sbsdb_type_lib.oracle_name_t;

    --<> api_hidden = true
    PROCEDURE set_io_type_log_file;

    --<> api_hidden = true
    PROCEDURE set_io_type_log_table;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --<> api_hidden = true
    --<> object_privilege execute = sys.utl_file
    PROCEDURE ins_sbsdb_log (
        p_ckey_in                               IN sbsdb_type_lib.logger_ckey_t,
        p_cvalue_in                             IN sbsdb_type_lib.logger_cvalue_t,
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_time_stamp_in                         IN TIMESTAMP) /*<>
     Application uses this to log errors and events.

     Parameters:
         p_ckey_in      identification of the logging entry
         p_cvalue_in    content of the logging entry
                                                                         */
                                                             ;
END sbsdb_io_lib;
/
