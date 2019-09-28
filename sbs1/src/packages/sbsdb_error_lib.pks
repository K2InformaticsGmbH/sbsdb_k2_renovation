CREATE OR REPLACE PACKAGE sbsdb_error_lib
IS
    /*<>
    SBSDB application exception definitions
    Generic exception handling and logging

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       SBSDB-related application exceptions
       ---------------------------------------------------------------------- */

    en_non_valid_db_version        CONSTANT PLS_INTEGER := -20105;
    em_non_valid_db_version        CONSTANT sbsdb_type_lib.err_msg_t := 'Your DB version :1 is not supported for this command.';
    en_master_data_missing         CONSTANT PLS_INTEGER := -20301;
    em_master_data_missing         CONSTANT sbsdb_type_lib.err_msg_t := 'The master data is missing: database table ":1".';
    en_number_rows_wrong           CONSTANT PLS_INTEGER := -20302;
    em_number_rows_wrong           CONSTANT sbsdb_type_lib.err_msg_t := 'The number of rows to be generated must be greater than zero, not :1.';
    en_directory_missing           CONSTANT PLS_INTEGER := -20303;
    em_directory_missing           CONSTANT sbsdb_type_lib.err_msg_t := 'No Oracle directory with the name ":1" is defined in Oracle:2.';
    en_data_type_unknown           CONSTANT PLS_INTEGER := -20304;
    em_data_type_unknown           CONSTANT sbsdb_type_lib.err_msg_t := 'Data type ":1" is unknown or not supported.';
    en_file_open_mode_invalid      CONSTANT PLS_INTEGER := -20305;
    em_file_open_mode_invalid      CONSTANT sbsdb_type_lib.err_msg_t := '":1" is not a valid file open mode.';
    en_file_name_missing           CONSTANT PLS_INTEGER := -20306;
    em_file_name_missing           CONSTANT sbsdb_type_lib.err_msg_t := 'No file name specified:1.';

    -- SQLCODEs  -20000 .. -20099 reserved for legacy SBSDB (to be inserted here when referenced in the code)

    /* =========================================================================
       Public Procedure Definition.
       ---------------------------------------------------------------------- */

    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t DEFAULT NULL,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t DEFAULT NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t DEFAULT NULL);

    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t,
        p_log_param_2_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_3_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_4_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_5_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_6_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_7_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_8_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_9_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_10_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_11_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_12_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_13_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_14_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_15_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_16_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_17_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_18_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_19_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_20_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_21_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_22_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_23_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_24_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_25_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_26_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_27_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_28_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_29_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param);

    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t,
        p_log_param_2_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_3_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_4_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_5_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_6_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_7_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_8_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_9_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_10_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_11_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_12_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_13_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_14_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_15_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_16_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_17_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_18_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_19_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_20_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_21_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_22_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_23_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_24_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_25_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_26_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_27_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_28_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_29_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
   Creates the error message and calls the print and logging utility

   Parameters:
       p_errcode_in             - the SQLCODE
       p_errmsg_in              - the error text to print (or NULL for the default)
       p_log_scope_in           - the logging scope  <package>.<procedure>
       p_extra_in               - optional attachment as clob
       p_log_param_[1 .. 30]_in - optional interesting input parameter name and value
   */
                                                                                                                          ;
/*
*/
END sbsdb_error_lib;
/