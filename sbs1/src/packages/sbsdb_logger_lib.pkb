CREATE OR REPLACE PACKAGE BODY sbsdb_logger_lib
IS
    gc_date_format                 CONSTANT VARCHAR2 (255) := 'DD-MON-YYYY HH24:MI:SS';
    gc_debug                       CONSTANT PLS_INTEGER := 16;
    gc_error                       CONSTANT PLS_INTEGER := 2;
    gc_information                 CONSTANT PLS_INTEGER := 8;
    gc_permanent                   CONSTANT PLS_INTEGER := 1;
    gc_timestamp_format            CONSTANT VARCHAR2 (255) := gc_date_format || ':FF';
    gc_timestamp_tz_format         CONSTANT VARCHAR2 (255) := gc_timestamp_format || ' TZR';

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION get_param_clob (p_params_in IN sbsdb_type_lib.logger_param_tab_t)
        RETURN CLOB;

    /* =========================================================================
       Creates a new JSON member.
       ---------------------------------------------------------------------- */

    FUNCTION json_member (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t := NULL,
        p_is_quoted_in                          IN sbsdb_type_lib.bool_t := sbsdb_type_lib.TRUE,
        p_is_first_in                           IN sbsdb_type_lib.bool_t := sbsdb_type_lib.FALSE,
        p_is_last_in                            IN sbsdb_type_lib.bool_t := sbsdb_type_lib.FALSE)
        RETURN sbsdb_type_lib.logger_cvalue_t;

    FUNCTION set_extra_with_params (
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t)
        RETURN sbsdb_type_lib.logger_extra_t;

    FUNCTION tochar (p_val_in IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN DATE)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN NUMBER)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN SYS_REFCURSOR)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN TIMESTAMP WITH LOCAL TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN TIMESTAMP WITH TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_val_t;

    FUNCTION tochar (p_val_in IN VARCHAR2)
        RETURN sbsdb_type_lib.logger_param_val_t;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            BOOLEAN);

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            DATE);

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            NUMBER);

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            TIMESTAMP);

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            TIMESTAMP WITH LOCAL TIME ZONE);

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            TIMESTAMP WITH TIME ZONE);

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            VARCHAR2);

    PROCEDURE ins_sbsdb_log (
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_text_in                               IN VARCHAR2, -- Not using type since want to be able to pass in 32767 characters
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_call_stack_in                         IN sbsdb_type_lib.logger_call_stack_t,
        p_unit_name_in                          IN sbsdb_type_lib.logger_unit_name_t,
        p_line_no_in                            IN sbsdb_type_lib.logger_line_no_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t);

    PROCEDURE log_debug (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param);

    PROCEDURE log_error (
        p_text_in                               IN sbsdb_type_lib.logger_message_t := NULL,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param);

    PROCEDURE log_info (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param);

    PROCEDURE log_information (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param);

    PROCEDURE log_internal (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_call_stack_in                         IN sbsdb_type_lib.logger_call_stack_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param);

    PROCEDURE log_permanent (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    FUNCTION get_valid_json (p_json_in IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        IF is_valid_json (p_json_in) = sbsdb_type_lib.TRUE
        THEN
            RETURN p_json_in;
        END IF;

        RETURN json_other ('invalid_json', p_json_in);
    END get_valid_json;

    FUNCTION is_valid_json (p_json_in IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.bool_t
    IS
        l_result                                PLS_INTEGER;
    BEGIN
        SELECT 1
        INTO   l_result
        FROM   DUAL
        WHERE  p_json_in IS JSON;

        RETURN sbsdb_type_lib.TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN sbsdb_type_lib.FALSE;
    END is_valid_json;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type array.
       ---------------------------------------------------------------------- */

    FUNCTION json_array (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '['
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '['
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> ']'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      ']'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_array;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type array.
       ---------------------------------------------------------------------- */

    FUNCTION json_array_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '['
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '['
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> ']'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      ']'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_array_add;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type array.
       ---------------------------------------------------------------------- */

    FUNCTION json_array_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '['
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '['
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> ']'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      ']'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_array_first;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type array.
       ---------------------------------------------------------------------- */

    FUNCTION json_array_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '['
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '['
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> ']'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      ']'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_array_last;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type object.
       ---------------------------------------------------------------------- */

    FUNCTION json_object (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '{'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '{'
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> '}'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '}'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_object;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type object.
       ---------------------------------------------------------------------- */

    FUNCTION json_object_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '{'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '{'
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> '}'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '}'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_object_add;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type object.
       ---------------------------------------------------------------------- */

    FUNCTION json_object_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '{'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '{'
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> '}'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '}'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_object_first;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type object.
       ---------------------------------------------------------------------- */

    FUNCTION json_object_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    =>    CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, 1, 1) <> '{'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '{'
                                                              END
                                                           || p_json_element_in
                                                           || CASE    p_json_element_in IS NULL
                                                                   OR SUBSTR (p_json_element_in, -1) <> '}'
                                                                  WHEN TRUE
                                                                  THEN
                                                                      '}'
                                                              END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_object_last;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type null.
       ---------------------------------------------------------------------- */

    FUNCTION json_other (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => NULL,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type boolean.
       ---------------------------------------------------------------------- */

    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => CASE p_json_element_in
                                                              WHEN TRUE
                                                              THEN
                                                                  'true'
                                                              ELSE
                                                                  'false'
                                                          END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type date.
       ---------------------------------------------------------------------- */

    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type number.
       ---------------------------------------------------------------------- */

    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in),
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type string.
       ---------------------------------------------------------------------- */

    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => p_json_element_in,
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other;

    /* =========================================================================
       Creates a new JSON containing one JSON member with a JSON element
       of type timestamp.
       ---------------------------------------------------------------------- */

    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type null.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_add (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => NULL,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_add;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type boolean.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => CASE p_json_element_in
                                                              WHEN TRUE
                                                              THEN
                                                                  'true'
                                                              ELSE
                                                                  'false'
                                                          END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_add;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type date.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_add;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type number.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in),
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_add;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type string.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => p_json_element_in,
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_add;

    /* =========================================================================
       Creates a new JSON member with a JSON element of type timestamp.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_add;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type null.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_first (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => NULL,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_first;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type boolean.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => CASE p_json_element_in
                                                              WHEN TRUE
                                                              THEN
                                                                  'true'
                                                              ELSE
                                                                  'false'
                                                          END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_first;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type date.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_first;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type number.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in),
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_first;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type string.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => p_json_element_in,
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_first;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type null.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_last (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => NULL,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other_last;

    /* =========================================================================
       Creates the first JSON member with a JSON element of type timestamp.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.TRUE,
                   p_is_last_in                         => sbsdb_type_lib.FALSE);
    END json_other_first;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type boolean.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => CASE p_json_element_in
                                                              WHEN TRUE
                                                              THEN
                                                                  'true'
                                                              ELSE
                                                                  'false'
                                                          END,
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other_last;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type date.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other_last;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type number.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in),
                   p_is_quoted_in                       => sbsdb_type_lib.FALSE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other_last;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type string.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => p_json_element_in,
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other_last;

    /* =========================================================================
       Creates the last JSON member with a JSON element of type timestamp.
       ---------------------------------------------------------------------- */

    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN json_member (
                   p_json_string_in                     => p_json_string_in,
                   p_json_element_in                    => TO_CHAR (p_json_element_in AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"'),
                   p_is_quoted_in                       => sbsdb_type_lib.TRUE,
                   p_is_first_in                        => sbsdb_type_lib.FALSE,
                   p_is_last_in                         => sbsdb_type_lib.TRUE);
    END json_other_last;

    /* =========================================================================
       Create a record for parameter logging
       ---------------------------------------------------------------------- */

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN DATE)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN NUMBER)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN SYS_REFCURSOR)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN TIMESTAMP WITH LOCAL TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN TIMESTAMP WITH TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := tochar (p_val_in);
        RETURN l_result;
    END log_param;

    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN VARCHAR2)
        RETURN sbsdb_type_lib.logger_param_rec_t
    IS
        l_result                                sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_result.name := p_name_in;
        l_result.val := p_val_in;
        RETURN l_result;
    END log_param;

    /* =========================================================================
       Cleanup of special characters in JSON strings.
       ---------------------------------------------------------------------- */

    FUNCTION normalized_json (p_json_in IN sbsdb_type_lib.logger_param_val_t)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (p_json_in, '\', '\\'), '"', '\"'), CHR (08), '\b'), CHR (09), '\t'), CHR (10), '\n'), CHR (12), '\f'), CHR (13), '\r');
    END normalized_json;

    /* =========================================================================
       Return the logging scope (e.g. <db name prefix>/<package>.<method>)
       ---------------------------------------------------------------------- */

    FUNCTION scope
        RETURN sbsdb_type_lib.logger_scope_t
    IS
    BEGIN
        RETURN    sbsdb_db_con.dbuname ()
               || CASE
                      WHEN sbsdb_db_con.is_cdb () = sbsdb_type_lib.TRUE
                      THEN
                          '.' || sbsdb_db_con.pdbname ()
                      ELSE
                          NULL
                  END;
    END scope;

    FUNCTION scope (p_method_name_in IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t
    IS
    BEGIN
        RETURN scope () || ':' || sbsdb_api_lib.scope (p_method_name_in);
    END scope;

    FUNCTION scope (
        p_package_name_in                       IN sbsdb_type_lib.oracle_name_t,
        p_method_name_in                        IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t
    IS
    BEGIN
        RETURN scope () || ':' || sbsdb_api_lib.scope (p_package_name_in, p_method_name_in);
    END scope;

    /* =========================================================================
       Public Procedure Implementation
       ---------------------------------------------------------------------- */

    PROCEDURE append_log_param (
        p_log_params_inout                      IN OUT sbsdb_type_lib.logger_param_tab_t,
        p_param_in                              IN     sbsdb_type_lib.logger_param_rec_t)
    IS
    BEGIN
        IF NOT p_param_in.name IS NULL
        THEN
            append_param (p_log_params_inout, p_param_in.name, p_param_in.val);
        END IF;
    END append_log_param;

    PROCEDURE get_valid_json (p_json_in_out IN OUT sbsdb_type_lib.logger_cvalue_t)
    IS
    BEGIN
        p_json_in_out := get_valid_json (p_json_in_out);
    END get_valid_json;

    PROCEDURE log_debug (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
    BEGIN
        log_debug (
            p_text_in                            => p_text_in,
            p_scope_in                           => p_scope_in,
            p_extra_in                           => NULL,
            p_log_param_1_in                     => p_log_param_1_in,
            p_log_param_2_in                     => p_log_param_2_in,
            p_log_param_3_in                     => p_log_param_3_in,
            p_log_param_4_in                     => p_log_param_4_in,
            p_log_param_5_in                     => p_log_param_5_in,
            p_log_param_6_in                     => p_log_param_6_in,
            p_log_param_7_in                     => p_log_param_7_in,
            p_log_param_8_in                     => p_log_param_8_in,
            p_log_param_9_in                     => p_log_param_9_in,
            p_log_param_10_in                    => p_log_param_10_in,
            p_log_param_11_in                    => p_log_param_11_in,
            p_log_param_12_in                    => p_log_param_12_in,
            p_log_param_13_in                    => p_log_param_13_in,
            p_log_param_14_in                    => p_log_param_14_in,
            p_log_param_15_in                    => p_log_param_15_in,
            p_log_param_16_in                    => p_log_param_16_in,
            p_log_param_17_in                    => p_log_param_17_in,
            p_log_param_18_in                    => p_log_param_18_in,
            p_log_param_19_in                    => p_log_param_19_in,
            p_log_param_20_in                    => p_log_param_20_in,
            p_log_param_21_in                    => p_log_param_21_in,
            p_log_param_22_in                    => p_log_param_22_in,
            p_log_param_23_in                    => p_log_param_23_in,
            p_log_param_24_in                    => p_log_param_24_in,
            p_log_param_25_in                    => p_log_param_25_in,
            p_log_param_26_in                    => p_log_param_26_in,
            p_log_param_27_in                    => p_log_param_27_in,
            p_log_param_28_in                    => p_log_param_28_in,
            p_log_param_29_in                    => p_log_param_29_in,
            p_log_param_30_in                    => p_log_param_30_in);
    END log_debug;

    PROCEDURE log_debug (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
        l_log_params                            sbsdb_type_lib.logger_param_tab_t;
    BEGIN
        append_log_param (l_log_params, p_log_param_1_in);
        append_log_param (l_log_params, p_log_param_2_in);
        append_log_param (l_log_params, p_log_param_3_in);
        append_log_param (l_log_params, p_log_param_4_in);
        append_log_param (l_log_params, p_log_param_5_in);
        append_log_param (l_log_params, p_log_param_6_in);
        append_log_param (l_log_params, p_log_param_7_in);
        append_log_param (l_log_params, p_log_param_8_in);
        append_log_param (l_log_params, p_log_param_9_in);
        append_log_param (l_log_params, p_log_param_10_in);
        append_log_param (l_log_params, p_log_param_11_in);
        append_log_param (l_log_params, p_log_param_12_in);
        append_log_param (l_log_params, p_log_param_13_in);
        append_log_param (l_log_params, p_log_param_14_in);
        append_log_param (l_log_params, p_log_param_15_in);
        append_log_param (l_log_params, p_log_param_16_in);
        append_log_param (l_log_params, p_log_param_17_in);
        append_log_param (l_log_params, p_log_param_18_in);
        append_log_param (l_log_params, p_log_param_19_in);
        append_log_param (l_log_params, p_log_param_20_in);
        append_log_param (l_log_params, p_log_param_21_in);
        append_log_param (l_log_params, p_log_param_22_in);
        append_log_param (l_log_params, p_log_param_23_in);
        append_log_param (l_log_params, p_log_param_24_in);
        append_log_param (l_log_params, p_log_param_25_in);
        append_log_param (l_log_params, p_log_param_26_in);
        append_log_param (l_log_params, p_log_param_27_in);
        append_log_param (l_log_params, p_log_param_28_in);
        append_log_param (l_log_params, p_log_param_29_in);
        append_log_param (l_log_params, p_log_param_30_in);

        log_debug (p_text_in, NVL (p_scope_in, scope ($$plsql_unit, 'log_debug')), p_extra_in, l_log_params);
    END log_debug;

    PROCEDURE log_error (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
        l_log_params                            sbsdb_type_lib.logger_param_tab_t;
    BEGIN
        append_log_param (l_log_params, p_log_param_1_in);
        append_log_param (l_log_params, p_log_param_2_in);
        append_log_param (l_log_params, p_log_param_3_in);
        append_log_param (l_log_params, p_log_param_4_in);
        append_log_param (l_log_params, p_log_param_5_in);
        append_log_param (l_log_params, p_log_param_6_in);
        append_log_param (l_log_params, p_log_param_7_in);
        append_log_param (l_log_params, p_log_param_8_in);
        append_log_param (l_log_params, p_log_param_9_in);
        append_log_param (l_log_params, p_log_param_10_in);
        append_log_param (l_log_params, p_log_param_11_in);
        append_log_param (l_log_params, p_log_param_12_in);
        append_log_param (l_log_params, p_log_param_13_in);
        append_log_param (l_log_params, p_log_param_14_in);
        append_log_param (l_log_params, p_log_param_15_in);
        append_log_param (l_log_params, p_log_param_16_in);
        append_log_param (l_log_params, p_log_param_17_in);
        append_log_param (l_log_params, p_log_param_18_in);
        append_log_param (l_log_params, p_log_param_19_in);
        append_log_param (l_log_params, p_log_param_20_in);
        append_log_param (l_log_params, p_log_param_21_in);
        append_log_param (l_log_params, p_log_param_22_in);
        append_log_param (l_log_params, p_log_param_23_in);
        append_log_param (l_log_params, p_log_param_24_in);
        append_log_param (l_log_params, p_log_param_25_in);
        append_log_param (l_log_params, p_log_param_26_in);
        append_log_param (l_log_params, p_log_param_27_in);
        append_log_param (l_log_params, p_log_param_28_in);
        append_log_param (l_log_params, p_log_param_29_in);
        append_log_param (l_log_params, p_log_param_30_in);

        log_error (p_text_in, p_scope_in, p_extra_in, l_log_params);
    END log_error;

    PROCEDURE log_info (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
    BEGIN
        log_info (
            p_text_in                            => p_text_in,
            p_scope_in                           => p_scope_in,
            p_extra_in                           => NULL,
            p_log_param_1_in                     => p_log_param_1_in,
            p_log_param_2_in                     => p_log_param_2_in,
            p_log_param_3_in                     => p_log_param_3_in,
            p_log_param_4_in                     => p_log_param_4_in,
            p_log_param_5_in                     => p_log_param_5_in,
            p_log_param_6_in                     => p_log_param_6_in,
            p_log_param_7_in                     => p_log_param_7_in,
            p_log_param_8_in                     => p_log_param_8_in,
            p_log_param_9_in                     => p_log_param_9_in,
            p_log_param_10_in                    => p_log_param_10_in,
            p_log_param_11_in                    => p_log_param_11_in,
            p_log_param_12_in                    => p_log_param_12_in,
            p_log_param_13_in                    => p_log_param_13_in,
            p_log_param_14_in                    => p_log_param_14_in,
            p_log_param_15_in                    => p_log_param_15_in,
            p_log_param_16_in                    => p_log_param_16_in,
            p_log_param_17_in                    => p_log_param_17_in,
            p_log_param_18_in                    => p_log_param_18_in,
            p_log_param_19_in                    => p_log_param_19_in,
            p_log_param_20_in                    => p_log_param_20_in,
            p_log_param_21_in                    => p_log_param_21_in,
            p_log_param_22_in                    => p_log_param_22_in,
            p_log_param_23_in                    => p_log_param_23_in,
            p_log_param_24_in                    => p_log_param_24_in,
            p_log_param_25_in                    => p_log_param_25_in,
            p_log_param_26_in                    => p_log_param_26_in,
            p_log_param_27_in                    => p_log_param_27_in,
            p_log_param_28_in                    => p_log_param_28_in,
            p_log_param_29_in                    => p_log_param_29_in,
            p_log_param_30_in                    => p_log_param_30_in);
    END log_info;

    PROCEDURE log_permanent (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
        l_log_params                            sbsdb_type_lib.logger_param_tab_t;
    BEGIN
        append_log_param (l_log_params, p_log_param_1_in);
        append_log_param (l_log_params, p_log_param_2_in);
        append_log_param (l_log_params, p_log_param_3_in);
        append_log_param (l_log_params, p_log_param_4_in);
        append_log_param (l_log_params, p_log_param_5_in);
        append_log_param (l_log_params, p_log_param_6_in);
        append_log_param (l_log_params, p_log_param_7_in);
        append_log_param (l_log_params, p_log_param_8_in);
        append_log_param (l_log_params, p_log_param_9_in);
        append_log_param (l_log_params, p_log_param_10_in);
        append_log_param (l_log_params, p_log_param_11_in);
        append_log_param (l_log_params, p_log_param_12_in);
        append_log_param (l_log_params, p_log_param_13_in);
        append_log_param (l_log_params, p_log_param_14_in);
        append_log_param (l_log_params, p_log_param_15_in);
        append_log_param (l_log_params, p_log_param_16_in);
        append_log_param (l_log_params, p_log_param_17_in);
        append_log_param (l_log_params, p_log_param_18_in);
        append_log_param (l_log_params, p_log_param_19_in);
        append_log_param (l_log_params, p_log_param_20_in);
        append_log_param (l_log_params, p_log_param_21_in);
        append_log_param (l_log_params, p_log_param_22_in);
        append_log_param (l_log_params, p_log_param_23_in);
        append_log_param (l_log_params, p_log_param_24_in);
        append_log_param (l_log_params, p_log_param_25_in);
        append_log_param (l_log_params, p_log_param_26_in);
        append_log_param (l_log_params, p_log_param_27_in);
        append_log_param (l_log_params, p_log_param_28_in);
        append_log_param (l_log_params, p_log_param_29_in);
        append_log_param (l_log_params, p_log_param_30_in);

        log_permanent (p_text_in, NVL (p_scope_in, scope ($$plsql_unit, 'log_permanent')), p_extra_in, l_log_params);
    END log_permanent;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Returns the display/print friendly parameter information.
       ---------------------------------------------------------------------- */

    FUNCTION get_param_clob (p_params_in IN sbsdb_type_lib.logger_param_tab_t)
        RETURN CLOB
    AS
        l_index                                 PLS_INTEGER;
        l_return                                CLOB;
    BEGIN
        -- Generate line feed delimited list
        -- Using while true ... option allows for unordered param list
        l_index := p_params_in.FIRST;

        WHILE TRUE
        LOOP
            l_return := l_return || p_params_in (l_index).name || ': ' || p_params_in (l_index).val;

            l_index := p_params_in.NEXT (l_index);

            EXIT WHEN l_index IS NULL;

            l_return := l_return || sbsdb_type_lib.get_os_crlf ();
        END LOOP;

        RETURN l_return;
    END get_param_clob;

    /* =========================================================================
       Creates a new JSON member.
       ---------------------------------------------------------------------- */

    FUNCTION json_member (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t := NULL,
        p_is_quoted_in                          IN sbsdb_type_lib.bool_t := sbsdb_type_lib.TRUE,
        p_is_first_in                           IN sbsdb_type_lib.bool_t := sbsdb_type_lib.FALSE,
        p_is_last_in                            IN sbsdb_type_lib.bool_t := sbsdb_type_lib.FALSE)
        RETURN sbsdb_type_lib.logger_cvalue_t
    IS
    BEGIN
        RETURN    CASE p_is_first_in
                      WHEN sbsdb_type_lib.TRUE
                      THEN
                          '{'
                      ELSE
                          ','
                  END
               || '"'
               || p_json_string_in
               || '":'
               || CASE p_is_quoted_in
                      WHEN sbsdb_type_lib.TRUE
                      THEN
                          '"'
                  END
               || CASE p_json_element_in IS NULL
                      WHEN TRUE
                      THEN
                          'null'
                      ELSE
                          p_json_element_in
                  END
               || CASE p_is_quoted_in
                      WHEN sbsdb_type_lib.TRUE
                      THEN
                          '"'
                  END
               || CASE p_is_last_in
                      WHEN sbsdb_type_lib.TRUE
                      THEN
                          '}'
                  END;
    END json_member;

    /* =========================================================================
       Will return the extra column appended with the display friendly parameters.
       ---------------------------------------------------------------------- */

    FUNCTION set_extra_with_params (
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t)
        RETURN sbsdb_type_lib.logger_extra_t
    AS
        l_extra                                 sbsdb_type_lib.logger_extra_t;
    BEGIN
        IF p_params_in.COUNT = 0
        THEN
            RETURN p_extra_in;
        ELSE
            l_extra :=
                   p_extra_in
                || sbsdb_type_lib.get_os_crlf ()
                || sbsdb_type_lib.get_os_crlf ()
                || '*** Parameters ***'
                || sbsdb_type_lib.get_os_crlf ()
                || sbsdb_type_lib.get_os_crlf ()
                || get_param_clob (p_params_in => p_params_in);
        END IF;

        RETURN l_extra;
    END set_extra_with_params;

    /* =========================================================================
        Converts parameter to a string

        Parameters:
            p_val_in - parameter value
        Returns:
            parameter value in string format
       ---------------------------------------------------------------------- */

    FUNCTION tochar (p_val_in IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN CASE p_val_in
                   WHEN TRUE
                   THEN
                       'TRUE'
                   ELSE
                       'FALSE'
               END;
    END tochar;

    FUNCTION tochar (p_val_in IN DATE)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN TO_CHAR (p_val_in, gc_date_format);
    END tochar;

    FUNCTION tochar (p_val_in IN sbsdb_type_lib.logger_param_val_t)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN p_val_in;
    END tochar;

    FUNCTION tochar (p_val_in IN NUMBER)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN TO_CHAR (p_val_in);
    END tochar;

    FUNCTION tochar (p_val_in IN SYS_REFCURSOR)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN '**SYS_REFCURSOR**';
    END tochar;

    FUNCTION tochar (p_val_in IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN TO_CHAR (p_val_in, gc_timestamp_format);
    END tochar;

    FUNCTION tochar (p_val_in IN TIMESTAMP WITH LOCAL TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN TO_CHAR (p_val_in, gc_timestamp_tz_format);
    END tochar;

    FUNCTION tochar (p_val_in IN TIMESTAMP WITH TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN TO_CHAR (p_val_in, gc_timestamp_tz_format);
    END tochar;

    FUNCTION tochar (p_val_in IN VARCHAR2)
        RETURN sbsdb_type_lib.logger_param_val_t
    IS
    BEGIN
        RETURN p_val_in;
    END tochar;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Append parameter to a table of parameters

       Nothing is actually logged in this procedure.
       This procedure is overloaded.
       ---------------------------------------------------------------------- */

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            BOOLEAN)
    AS
    BEGIN
        append_param (p_params_in => p_params_in, p_name_in => p_name_in, p_val_in => tochar (p_val_in => p_val_in));
    END append_param;

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            DATE)
    AS
    BEGIN
        append_param (p_params_in => p_params_in, p_name_in => p_name_in, p_val_in => tochar (p_val_in => p_val_in));
    END append_param;

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            NUMBER)
    AS
    BEGIN
        append_param (p_params_in => p_params_in, p_name_in => p_name_in, p_val_in => tochar (p_val_in => p_val_in));
    END append_param;

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            TIMESTAMP)
    AS
    BEGIN
        append_param (p_params_in => p_params_in, p_name_in => p_name_in, p_val_in => tochar (p_val_in => p_val_in));
    END append_param;

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            TIMESTAMP WITH LOCAL TIME ZONE)
    AS
    BEGIN
        append_param (p_params_in => p_params_in, p_name_in => p_name_in, p_val_in => tochar (p_val_in => p_val_in));
    END append_param;

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            TIMESTAMP WITH TIME ZONE)
    AS
    BEGIN
        append_param (p_params_in => p_params_in, p_name_in => p_name_in, p_val_in => tochar (p_val_in => p_val_in));
    END append_param;

    PROCEDURE append_param (
        p_params_in                             IN OUT NOCOPY sbsdb_type_lib.logger_param_tab_t,
        p_name_in                               IN            VARCHAR2,
        p_val_in                                IN            VARCHAR2)
    AS
        l_param                                 sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_param.name := p_name_in;
        l_param.val := p_val_in;
        p_params_in (p_params_in.COUNT + 1) := l_param;
    END append_param;

    /* =========================================================================
       Parses the call_stack to get unit and line number.
       ---------------------------------------------------------------------- */

    PROCEDURE get_debug_info (
        p_call_stack_in                         IN            CLOB,
        o_unit                                     OUT NOCOPY sbsdb_type_lib.logger_unit_name_t,
        o_line_no                                  OUT NOCOPY sbsdb_type_lib.logger_line_no_t)
    AS
        l_call_stack                            sbsdb_type_lib.logger_call_stack_t := p_call_stack_in;
    BEGIN
        l_call_stack := SUBSTR (l_call_stack, INSTR (l_call_stack, CHR (10), 1, 5) + 1);
        l_call_stack := SUBSTR (l_call_stack, 1, INSTR (l_call_stack, CHR (10), 1, 1) - 1);
        l_call_stack := TRIM (SUBSTR (l_call_stack, INSTR (l_call_stack, ' ')));
        o_line_no := SUBSTR (l_call_stack, 1, INSTR (l_call_stack, ' ') - 1);
        o_unit := TRIM (SUBSTR (l_call_stack, INSTR (l_call_stack, ' ', -1, 1)));
    END get_debug_info;

    /* =========================================================================
       Handles logging inserts.
       ---------------------------------------------------------------------- */

    PROCEDURE ins_sbsdb_log (
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_text_in                               IN VARCHAR2, -- Not using type since want to be able to pass in 32767 characters
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_call_stack_in                         IN sbsdb_type_lib.logger_call_stack_t,
        p_unit_name_in                          IN sbsdb_type_lib.logger_unit_name_t,
        p_line_no_in                            IN sbsdb_type_lib.logger_line_no_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t)
    AS
        lc_action                      CONSTANT sbsdb_type_lib.logger_param_name_t := SYS_CONTEXT ('userenv', 'action');
        lc_client_identifier           CONSTANT sbsdb_type_lib.logger_param_name_t := SYS_CONTEXT ('userenv', 'client_identifier');
        lc_client_info                 CONSTANT sbsdb_type_lib.logger_param_name_t := SYS_CONTEXT ('userenv', 'client_info');
        lc_module                      CONSTANT sbsdb_type_lib.logger_param_name_t := SYS_CONTEXT ('userenv', 'module');
        lc_os_user_name                CONSTANT sbsdb_type_lib.logger_param_name_t := sbsdb_user_con.get_os_user ();
        lc_sid                         CONSTANT sbsdb_type_lib.sid_t := sbsdb_user_con.get_session_id ();
        lc_time_stamp                  CONSTANT TIMESTAMP := SYSTIMESTAMP;
        lc_user                        CONSTANT sbsdb_type_lib.oracle_name_t := USER;

        l_ckey                                  sbsdb_type_lib.logger_ckey_t;
        l_cvalue                                sbsdb_type_lib.logger_cvalue_t;
        l_extra                                 sbsdb_type_lib.logger_cvalue_t;
        l_scn                                   sbsdb_type_lib.property_value_t;
    BEGIN
        l_ckey := sbsdb_log_seq.NEXTVAL;

        l_extra := CAST (p_extra_in AS VARCHAR2);

        SELECT current_scn INTO l_scn FROM v$database;

        l_cvalue :=
               json_other_first ('ckey', l_ckey)
            || json_other_add ('action', lc_action)
            || json_other_add ('callStack', normalized_json (p_call_stack_in))
            || json_other_add ('clientIdentifier', lc_client_identifier)
            || json_other_add ('clientInfo', lc_client_info)
            || json_other_add ('extra', normalized_json (p_extra_in))
            || json_other_add ('lineNo', p_line_no_in)
            || json_other_add ('loggerLevel', p_logger_level_in)
            || json_other_add ('module', lc_module)
            || json_other_add ('osUserName', normalized_json (lc_os_user_name))
            || json_other_add ('scn', l_scn)
            || json_other_add ('scope', LOWER (p_scope_in))
            || json_other_add ('sid', lc_sid)
            || CASE     LENGTH (p_text_in) > 1
                    AND SUBSTR (p_text_in, 1, 2) = '{"'
                    AND SUBSTR (TRIM (p_text_in), -1) = '}'
                   WHEN TRUE
                   THEN
                       json_object_add ('text', p_text_in)
                   ELSE
                       json_other_add ('text', normalized_json (p_text_in))
               END
            || json_other_add ('timeStamp', lc_time_stamp)
            || json_other_add ('unitName', UPPER (p_unit_name_in))
            || json_other_last ('userName', lc_user);

        sbsdb_io_lib.ins_sbsdb_log (
            p_ckey_in                            => l_ckey,
            p_cvalue_in                          => get_valid_json (l_cvalue),
            p_logger_level_in                    => p_logger_level_in,
            p_scope_in                           => LOWER (p_scope_in),
            p_time_stamp_in                      => lc_time_stamp);
    END ins_sbsdb_log;

    PROCEDURE log_debug (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param)
    IS
    BEGIN
        log_internal (
            p_text_in                            => p_text_in,
            p_logger_level_in                    => gc_debug,
            p_scope_in                           => p_scope_in,
            p_extra_in                           => p_extra_in,
            p_call_stack_in                      => DBMS_UTILITY.format_call_stack,
            p_params_in                          => p_params_in);
    END log_debug;

    PROCEDURE log_error (
        p_text_in                               IN sbsdb_type_lib.logger_message_t := NULL,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param)
    IS
        l_proc_name                             sbsdb_type_lib.logger_proc_name_t;
        l_line_no                               sbsdb_type_lib.logger_line_no_t;
        l_text                                  sbsdb_type_lib.logger_message_t;
        l_call_stack                            sbsdb_type_lib.logger_call_stack_t;
        l_extra                                 sbsdb_type_lib.logger_extra_t;
    BEGIN
        get_debug_info (p_call_stack_in => DBMS_UTILITY.format_call_stack, o_unit => l_proc_name, o_line_no => l_line_no);

        l_call_stack := DBMS_UTILITY.format_error_stack () || sbsdb_type_lib.get_os_crlf () || DBMS_UTILITY.format_error_backtrace;

        IF p_text_in IS NOT NULL
        THEN
            l_text := p_text_in;
        END IF;

        IF NOT (    LENGTH (l_text) > 1
                AND SUBSTR (l_text, 1, 2) = '{"'
                AND SUBSTR (TRIM (l_text), -1) = '}')
        THEN
            l_text := l_text || DBMS_UTILITY.format_error_stack ();
        END IF;

        l_extra := set_extra_with_params (p_extra_in => p_extra_in, p_params_in => p_params_in);

        ins_sbsdb_log (
            p_unit_name_in                       => UPPER (l_proc_name),
            p_scope_in                           => p_scope_in,
            p_logger_level_in                    => gc_error,
            p_extra_in                           => l_extra,
            p_text_in                            => l_text,
            p_call_stack_in                      => l_call_stack,
            p_line_no_in                         => l_line_no);
    END log_error;

    PROCEDURE log_info (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
        l_log_params                            sbsdb_type_lib.logger_param_tab_t;
    BEGIN
        append_log_param (l_log_params, p_log_param_1_in);
        append_log_param (l_log_params, p_log_param_2_in);
        append_log_param (l_log_params, p_log_param_3_in);
        append_log_param (l_log_params, p_log_param_4_in);
        append_log_param (l_log_params, p_log_param_5_in);
        append_log_param (l_log_params, p_log_param_6_in);
        append_log_param (l_log_params, p_log_param_7_in);
        append_log_param (l_log_params, p_log_param_8_in);
        append_log_param (l_log_params, p_log_param_9_in);
        append_log_param (l_log_params, p_log_param_10_in);
        append_log_param (l_log_params, p_log_param_11_in);
        append_log_param (l_log_params, p_log_param_12_in);
        append_log_param (l_log_params, p_log_param_13_in);
        append_log_param (l_log_params, p_log_param_14_in);
        append_log_param (l_log_params, p_log_param_15_in);
        append_log_param (l_log_params, p_log_param_16_in);
        append_log_param (l_log_params, p_log_param_17_in);
        append_log_param (l_log_params, p_log_param_18_in);
        append_log_param (l_log_params, p_log_param_19_in);
        append_log_param (l_log_params, p_log_param_20_in);
        append_log_param (l_log_params, p_log_param_21_in);
        append_log_param (l_log_params, p_log_param_22_in);
        append_log_param (l_log_params, p_log_param_23_in);
        append_log_param (l_log_params, p_log_param_24_in);
        append_log_param (l_log_params, p_log_param_25_in);
        append_log_param (l_log_params, p_log_param_26_in);
        append_log_param (l_log_params, p_log_param_27_in);
        append_log_param (l_log_params, p_log_param_28_in);
        append_log_param (l_log_params, p_log_param_29_in);
        append_log_param (l_log_params, p_log_param_30_in);

        log_information (p_text_in, p_scope_in, p_extra_in, l_log_params);
    END log_info;

    PROCEDURE log_information (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param)
    IS
    BEGIN
        log_internal (
            p_text_in                            => p_text_in,
            p_logger_level_in                    => gc_information,
            p_scope_in                           => p_scope_in,
            p_extra_in                           => p_extra_in,
            p_call_stack_in                      => DBMS_UTILITY.format_call_stack,
            p_params_in                          => p_params_in);
    END log_information;

    /* =========================================================================
       Main procedure that will store log data into sbsdb_log table.
       ---------------------------------------------------------------------- */

    PROCEDURE log_internal (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_logger_level_in                       IN sbsdb_type_lib.logger_level_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_call_stack_in                         IN sbsdb_type_lib.logger_call_stack_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param)
    IS
        l_proc_name                             sbsdb_type_lib.logger_proc_name_t;
        l_line_no                               sbsdb_type_lib.logger_line_no_t;
        l_text                                  sbsdb_type_lib.logger_message_t;
        l_call_stack                            sbsdb_type_lib.logger_call_stack_t;
        l_extra                                 sbsdb_type_lib.logger_extra_t;
    BEGIN
        l_text := p_text_in;

        -- Generate call_stack text
        IF p_call_stack_in IS NOT NULL
        THEN
            get_debug_info (p_call_stack_in => p_call_stack_in, o_unit => l_proc_name, o_line_no => l_line_no);

            l_call_stack :=
                REGEXP_REPLACE (
                    p_call_stack_in,
                    '^.*$',
                    '',
                    1,
                    4,
                    'm');
            l_call_stack :=
                REGEXP_REPLACE (
                    l_call_stack,
                    '^.*$',
                    '',
                    1,
                    1,
                    'm');
            l_call_stack := LTRIM (REPLACE (l_call_stack, CHR (10) || CHR (10), CHR (10)), CHR (10));
        END IF;

        l_extra := set_extra_with_params (p_extra_in => p_extra_in, p_params_in => p_params_in);

        ins_sbsdb_log (
            p_unit_name_in                       => UPPER (l_proc_name),
            p_scope_in                           => p_scope_in,
            p_logger_level_in                    => p_logger_level_in,
            p_extra_in                           => l_extra,
            p_text_in                            => l_text,
            p_call_stack_in                      => l_call_stack,
            p_line_no_in                         => l_line_no);
    END log_internal;

    PROCEDURE log_permanent (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t := NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t := NULL,
        p_params_in                             IN sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param)
    IS
    BEGIN
        log_internal (
            p_text_in                            => p_text_in,
            p_logger_level_in                    => gc_permanent,
            p_scope_in                           => p_scope_in,
            p_extra_in                           => p_extra_in,
            p_call_stack_in                      => DBMS_UTILITY.format_call_stack,
            p_params_in                          => p_params_in);
    END log_permanent;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_logger_lib;
/