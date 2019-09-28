CREATE OR REPLACE PACKAGE sbsdb_logger_lib
IS
    /*<>
    Interface to the logger library
    Implements logger extensions and proxy functions to be used by the application

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    --<> api_hidden = true
    FUNCTION get_valid_json (p_json_in IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Returns always a valid JSON.

    Parameters:
       p_json_in  the string to be validated

    Returns:
      - unchanged input value, if the input value contains a valid JSON
      - {"invalid_json":"<p_json_in_out>"}, else
    */
                                             ;

    --<> api_hidden = true
    FUNCTION is_valid_json (p_json_in IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.bool_t /*<>
    Checks if a given string contains a valid JSON.

    Parameters:
       p_json_in  the string to be validated

    Returns:
      - true, if the given string contains a valid JSON
      - false, else
    */
                                    ;

    --<> api_hidden = true
    FUNCTION json_array (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_array_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_array_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_array_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_object (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_object_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_object_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_object_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_cvalue_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type null.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type boolean.

    This procedure is overloaded.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type boolean

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type date.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type date

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type number.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type number

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type string.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type string

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON containing one JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type timestamp

    Returns:
      - the new JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_add (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type null.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type boolean.

    This procedure is overloaded.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type boolean

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type date.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type date

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type number.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type number

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type string.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type string

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_add (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates a new JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type timestamp

    Returns:
      - the modified incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_first (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type null.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type boolean.

    This procedure is overloaded.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type boolean

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type date.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type date

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type number.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type number

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type string.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type string

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_first (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the first JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type timestamp

    Returns:
      - the new incomplete JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_last (p_json_string_in IN sbsdb_type_lib.logger_json_string_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type null.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type boolean.

    This procedure is overloaded.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type boolean

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN DATE)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type date.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type date

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN NUMBER)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type number.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type number

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN sbsdb_type_lib.logger_json_element_t)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type string.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type string

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION json_other_last (
        p_json_string_in                        IN sbsdb_type_lib.logger_json_string_t,
        p_json_element_in                       IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_cvalue_t /*<>
    Creates the last JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member's JSON string
       p_json_element_in - the new JSON member's JSON element of type timestamp

    Returns:
      - the final JSON
   */
                                             ;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN BOOLEAN)
        RETURN sbsdb_type_lib.logger_param_rec_t /*<>
    Prepares a parameter for logging.

    This procedure is overloaded.

    Parameters:
        p_name_in - parameter name
        p_val_in  - parameter value
    */
                                                ;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN DATE)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN NUMBER)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN SYS_REFCURSOR)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN TIMESTAMP)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN TIMESTAMP WITH LOCAL TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN TIMESTAMP WITH TIME ZONE)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION log_param (
        p_name_in                               IN sbsdb_type_lib.logger_param_name_t,
        p_val_in                                IN VARCHAR2)
        RETURN sbsdb_type_lib.logger_param_rec_t;

    --<> api_hidden = true
    FUNCTION normalized_json (p_json_in IN sbsdb_type_lib.logger_param_val_t)
        RETURN sbsdb_type_lib.logger_param_val_t /*<>
    Cleanup of special characters in JSON.

    Parameters:
        p_json_in - JSON
    */
                                                ;

    --<> api_hidden = true
    FUNCTION scope
        RETURN sbsdb_type_lib.logger_scope_t /*<>
    Creates the scope value.
    */
                                            ;

    --<> api_hidden = true
    FUNCTION scope (p_method_name_in IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t /*<>
    Creates the scope value for a standalone SBSDB method.

    Parameters:
        p_method_name_in  - method name
    */
                                            ;

    --<> api_hidden = true
    FUNCTION scope (
        p_package_name_in                       IN sbsdb_type_lib.oracle_name_t,
        p_method_name_in                        IN sbsdb_type_lib.oracle_name_t)
        RETURN sbsdb_type_lib.logger_scope_t /*<>
    Creates the scope value for a SBSDB method implemented in a package.

    Parameters:
        p_package_name_in - package name
        p_method_name_in  - method name
    */
                                            ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --<> api_hidden = true
    PROCEDURE append_log_param (
        p_log_params_inout                      IN OUT sbsdb_type_lib.logger_param_tab_t,
        p_param_in                              IN     sbsdb_type_lib.logger_param_rec_t) /*<>
    Adds a prepared parameter to a table of parameters.

    Parameters:
        p_log_params_inout - parameter table
        p_param_in         - prepared parameter
    */
                                                                                         ;

    --<> api_hidden = true
    PROCEDURE get_valid_json (p_json_in_out IN OUT sbsdb_type_lib.logger_cvalue_t) /*<>
     Returns always a valid JSON.


     Parameters:
        p_json_in_out  the string to be validated

     Returns:
       - unchanged input value, if the input value contains a valid JSON
       - {"invalid_json":"<p_json_in_out>"}, else
     */
                                                                                  ;

    --<> api_hidden = true
    --<> object_privilege select = sys.v_$database
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
    Application can use this to log application events on debug level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - (optional) method qualified name without schema <package>.<method>
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    */
                                                                                                                          ;

    --<> api_hidden = true
    --<> object_privilege select = sys.v_$database
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
    Application can use this to log application events on debug level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - (optional) method qualified name without schema <package>.<method>
        p_extra_in      - (optional) attachment as clob
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    */
                                                                                                                          ;

    --<> api_hidden = true
    --<> object_privilege select = sys.v_$database
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
   Application can use this to log application errors on error level

   Parameters:
       p_text_in       - text describing the event to be logged
       p_scope_in      - method qualified name without schema <package>.<method>
       p_extra_in      - (optional) attachment as clob
       p_params_1_in   - (optional) method parameters (name,val) of request parameters
       p_params_%_in   - (optional) method parameters (name,val) of request parameters
   */
                                                                                                                          ;

    --<> api_hidden = true
    --<> object_privilege select = sys.v_$database
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
    Application can use this to log application events on info level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - method qualified name without schema <package>.<method>
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    */
                                                                                                                          ;

    --<> api_hidden = true
    --<> object_privilege select = sys.v_$database
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
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
    Application can use this to log application events on permanent level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - (optional) method qualified name without schema <package>.<method>
        p_extra_in      - (optional) attachment as clob
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    */
                                                                                                                          ;
END sbsdb_logger_lib;
/