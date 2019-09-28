CREATE OR REPLACE PACKAGE test_sbsdb_logger
IS
    /*<>
       Unit testing package sbsdb_logger_lib.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    --%test
    PROCEDURE append_log_param;

    --%test
    PROCEDURE get_valid_json_fnc_false;

    --%test
    PROCEDURE get_valid_json_fnc_true;

    --%test
    PROCEDURE get_valid_json_prc_false;

    --%test
    PROCEDURE get_valid_json_prc_true;

    --%test
    PROCEDURE is_valid_json_false;

    --%test
    PROCEDURE is_valid_json_true;

    --%test
    PROCEDURE json_array;

    --%test
    PROCEDURE json_array_add;

    --%test
    PROCEDURE json_array_first;

    --%test
    PROCEDURE json_array_last;

    --%test
    PROCEDURE json_object;

    --%test
    PROCEDURE json_object_add;

    --%test
    PROCEDURE json_object_first;

    --%test
    PROCEDURE json_object_last;

    --%test
    PROCEDURE json_other_boolean;

    --%test
    PROCEDURE json_other_date;

    --%test
    PROCEDURE json_other_null;

    --%test
    PROCEDURE json_other_number;

    --%test
    PROCEDURE json_other_string;

    --%test
    PROCEDURE json_other_timestamp;

    --%test
    PROCEDURE json_other_add_boolean;

    --%test
    PROCEDURE json_other_add_date;

    --%test
    PROCEDURE json_other_add_null;

    --%test
    PROCEDURE json_other_add_number;

    --%test
    PROCEDURE json_other_add_string;

    --%test
    PROCEDURE json_other_add_timestamp;

    --%test
    PROCEDURE json_other_first_boolean;

    --%test
    PROCEDURE json_other_first_date;

    --%test
    PROCEDURE json_other_first_null;

    --%test
    PROCEDURE json_other_first_number;

    --%test
    PROCEDURE json_other_first_string;

    --%test
    PROCEDURE json_other_first_timestamp;

    --%test
    PROCEDURE json_other_last_boolean;

    --%test
    PROCEDURE json_other_last_date;

    --%test
    PROCEDURE json_other_last_null;

    --%test
    PROCEDURE json_other_last_number;

    --%test
    PROCEDURE json_other_last_string;

    --%test
    PROCEDURE json_other_last_timestamp;

    --%test
    PROCEDURE log_debug_table;

    --%test
    PROCEDURE log_error_table;

    --%test
    PROCEDURE log_info_table;

    --%test
    PROCEDURE log_param_boolean;

    --%context(log_param)

    --%test
    PROCEDURE log_param_date;

    --%test
    PROCEDURE log_param_number;

    --%test
    PROCEDURE log_param_sys_refcursor;

    --%test
    PROCEDURE log_param_timestamp;

    -- --%test
    -- PROCEDURE log_param_timestamp_w_local_tz;

    --%test
    PROCEDURE log_param_timestamp_w_tz;

    --%test
    PROCEDURE log_param_varchar2;

    --%endcontext

    --%test
    PROCEDURE log_permanent_table;

    --%context(scope)

    --%test
    PROCEDURE scope_method;

    --%test
    PROCEDURE scope_package;
--%endcontext
END test_sbsdb_logger;
/
