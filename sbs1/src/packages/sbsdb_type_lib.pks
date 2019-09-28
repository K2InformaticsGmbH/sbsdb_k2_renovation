CREATE OR REPLACE PACKAGE sbsdb_type_lib
IS
    /*<>
    SBSDB specific TYPE definitions for types used in several packages
    Types which are only relevant / used in a single package are defined there

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
        Types for properties handled via context.
        --------------------------------------------------------------------- */

    SUBTYPE property_value_t IS VARCHAR2 (4000);

    /* =========================================================================
       Exported API types (attention: api_scope currently matches logger_scope)
       ---------------------------------------------------------------------- */

    SUBTYPE api_scope_t IS VARCHAR2 (128);

    SUBTYPE api_message_t IS VARCHAR2 (4000);

    SUBTYPE api_help_t IS VARCHAR2 (32767); -- (internal use only, truncated in SQL output)

    TYPE sbsdb_api_scope_help_rt IS RECORD
    (
        api_scope api_scope_t,
        api_help_text api_help_t
    );

    TYPE sbsdb_api_scope_help_ct IS TABLE OF sbsdb_api_scope_help_rt
        INDEX BY PLS_INTEGER;

    /* =========================================================================
       Shared types for error handling
       ---------------------------------------------------------------------- */

    SUBTYPE err_msg_t IS VARCHAR2 (512);

    SUBTYPE bool_t IS VARCHAR2 (32);

    /* =========================================================================
       IO types  (user input/output)
       ---------------------------------------------------------------------- */

    SUBTYPE input_name_t IS VARCHAR2 (100);

    /* =========================================================================
       Exported sbsdb_logger types (must sematically match the logger library)
       ---------------------------------------------------------------------- */

    SUBTYPE logger_call_stack_t IS VARCHAR2 (10000);

    SUBTYPE logger_ckey_t IS NUMBER;

    SUBTYPE logger_cvalue_t IS VARCHAR2 (32767);

    SUBTYPE logger_extra_t IS CLOB;

    SUBTYPE logger_json_element_t IS VARCHAR2 (4000);

    SUBTYPE logger_json_string_t IS VARCHAR2 (255);

    SUBTYPE logger_level_t IS PLS_INTEGER;

    SUBTYPE logger_line_no_t IS VARCHAR2 (100);

    SUBTYPE logger_message_t IS VARCHAR2 (4000);

    SUBTYPE logger_param_name_t IS VARCHAR2 (255);

    SUBTYPE logger_param_val_t IS VARCHAR2 (4000);

    SUBTYPE logger_proc_name_t IS VARCHAR2 (100);

    SUBTYPE logger_scope_t IS VARCHAR2 (1000);

    SUBTYPE logger_unit_name_t IS VARCHAR2 (100);

    TYPE logger_param_rec_t IS RECORD
    (
        name logger_param_name_t,
        val logger_param_val_t
    );

    TYPE logger_param_tab_t IS TABLE OF logger_param_rec_t
        INDEX BY PLS_INTEGER;

    /* =========================================================================
       Oracle types
       ---------------------------------------------------------------------- */

    SUBTYPE oracle_name_t IS VARCHAR2 (32);

    SUBTYPE scn_t IS NUMBER;

    SUBTYPE sid_t IS NUMBER;

    /* =========================================================================
       SQL types
       ---------------------------------------------------------------------- */

    SUBTYPE sql_stmnt_t IS VARCHAR2 (4000);

    /* =========================================================================
        Global constants.
        --------------------------------------------------------------------- */

    gc_empty_rec_param                      logger_param_rec_t;
    gc_empty_tab_param                      logger_param_tab_t;

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION FALSE
        RETURN bool_t;

    FUNCTION get_os_crlf
        RETURN VARCHAR2;

    FUNCTION lf
        RETURN VARCHAR2;

    FUNCTION TRUE
        RETURN bool_t;
/*
*/
END sbsdb_type_lib;
/