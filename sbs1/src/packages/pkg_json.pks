CREATE OR REPLACE PACKAGE sbs1_admin.pkg_json
IS
    /*<>
    Libarary functions for working with JSON strings.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION from_json_boolean (p_data IN VARCHAR2)
        RETURN NUMBER /*<>
    Convert an input string to a number.

    Input Parameter:
      p_data - input string.

    Return Parameter:
      0    - if the input string equals to 'false' (case-sensitive)
      1    - if the input string equals to 'true'  (case-sensitive)
      NULL - in other respects

    Restrictions:
      - none.
    */
                     ;

    FUNCTION from_json_date (p_date IN VARCHAR2)
        RETURN DATE /*<>
    Convert an input string to a DATE value or NULL.
    Expected date format after removing double quotes and 'Z' characters
    and replacing the 'T' characters with ' ': 'yyyy-mm-dd hh24:mi:ss'

    Input Parameter:
      p_date - string.

    Return Parameter:
      NULL              - if the input string is NULL
      a DATE type value - if the input string fits the expected date format

    Restrictions:
      - none.
    */
                   ;

    FUNCTION json_boolean (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT 'null')
        RETURN VARCHAR2 /*<>
    Normalize input string representing a truth value with default.

    Input Parameter:
      p_1 - string containing a truth value.
      p_2 - string containing a default value.

    Return Parameter:
      'false' - if the input string p_1 equals to '0' or 'false' (case-insensitive)
      'true'  - if the input string p_1 equals to '1' or 'true'  (case-insensitive)
      p_2     - in other respects

    Restrictions:
      - none.
    */
                       ;

    FUNCTION json_date (p_date IN DATE)
        RETURN VARCHAR2 /*<>
    Convert a DATE value to a string representing the date value 
    with a JSON style date string (including double quotes, 
    e.g. "2019-04-05T01:02:03Z" ).
    
    A NULL input will result in "".

    Input Parameter:
      p_date - DATE value.

    Return Parameter:
      "" if the imput value was NULL,
      a string in the format "yyyy-mm-ddThh24:mi:ssZ" in other respects 

    Restrictions:
      - none.
    */
                       ;

    FUNCTION json_foreign_key (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL,
        p_3                                     IN VARCHAR2 DEFAULT NULL,
        p_4                                     IN VARCHAR2 DEFAULT NULL,
        p_5                                     IN VARCHAR2 DEFAULT NULL,
        p_6                                     IN VARCHAR2 DEFAULT NULL,
        p_7                                     IN VARCHAR2 DEFAULT NULL,
        p_8                                     IN VARCHAR2 DEFAULT NULL,
        p_9                                     IN VARCHAR2 DEFAULT NULL,
        p_a                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Create a foreign key string like it is used in tpac (JSON list of Strings) by
    combining '{"fk":[...]}' with a list of key parts (optional from right to left).
    Assume all key parts to be strings.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.
      p_3 - KeyPart3 varchar2.
      p_4 - KeyPart4 varchar2.
      p_5 - KeyPart5 varchar2.
      p_6 - KeyPart6 varchar2.
      p_7 - KeyPart7 varchar2.
      p_8 - KeyPart8 varchar2.
      p_9 - KeyPart9 varchar2.
      p_a - KeyParta varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_foreign_key_2 (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Create a foreign key string like it is used in tpac (JSON list of Strings) by
    combining '{"fk":[...]}' with a list of two key parts. Key parts can be NULL 
    which then are converted to '""'. Assume all key parts to be strings or NULL.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_foreign_keys (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL,
        p_3                                     IN VARCHAR2 DEFAULT NULL,
        p_4                                     IN VARCHAR2 DEFAULT NULL,
        p_5                                     IN VARCHAR2 DEFAULT NULL,
        p_6                                     IN VARCHAR2 DEFAULT NULL,
        p_7                                     IN VARCHAR2 DEFAULT NULL,
        p_8                                     IN VARCHAR2 DEFAULT NULL,
        p_9                                     IN VARCHAR2 DEFAULT NULL,
        p_a                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Create a foreign keys string (note plural) like it is used in tpac (JSON list of Strings)
    by combining '{"fks":[[...]]}' with a list of keys parts (optional from right to left).
    Assume all key parts to be strings.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.
      p_3 - KeyPart3 varchar2.
      p_4 - KeyPart4 varchar2.
      p_5 - KeyPart5 varchar2.
      p_6 - KeyPart6 varchar2.
      p_7 - KeyPart7 varchar2.
      p_8 - KeyPart8 varchar2.
      p_9 - KeyPart9 varchar2.
      p_a - KeyParta varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_foreign_keys_2 (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Create a foreign keys string (note plural) like it is used in tpac (JSON list of Strings) by
    combining '{"fks":[[...]]}' with a list of two key parts. Key parts can be NULL 
    which then are converted to '""'. Assume all key parts to be strings or NULL.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_key_sn (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER)
        RETURN VARCHAR2 /*<>
    Create a key string like it is used in tpac (JSON list of String and number).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 number.

    Return Parameter:
      string representing json key.

    Restrictions:
      - KeyPart1 must be JSON-escaped already.
    */
                       ;

    FUNCTION json_key_snn (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER,
        p_3                                     IN NUMBER)
        RETURN VARCHAR2 /*<>
    Create a key string like it is used in tpac (JSON list of String and number).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 number.
      p_3 - KeyPart3 number.

    Return Parameter:
      string representing json key.

    Restrictions:
      - KeyPart1 must be JSON-escaped already.
    */
                       ;


    FUNCTION json_key_sns (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER,
        p_3                                     IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Create a key string like it is used in tpac (JSON list of Strings and Number).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 number.
      p_3 - KeyPart3 varchar2.

    Return Parameter:
      string representing json key.

    Restrictions:
      - String KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_not_null (
        p_name                                  IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return an empty string if p_value is null or "", otherwise return a comma plus
    a string representation of a JSON attribute (e.g. ',"p_name":"p_value"').
    Used to append attributes to a JSON object only if the value is non-empty.

    Input Parameter:
      p_name  - AttributeName.
      p_value - AttributeValue.

    Return Parameter:
      NULL or next JSON attribute

    Restrictions:
      - none.
    */
                       ;


    FUNCTION json_num (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER DEFAULT 0)
        RETURN VARCHAR2 /*<>
    Return a number p_1 in JSON number format, if necessary use the given default '0'.

    Input Parameter:
      p_1 - number as a string or NULL.
      p_2 - default input when p_1 is NULL.

    Return Parameter:
      string representing a number.

    Restrictions:
      - none.
    */
                       ;


    FUNCTION json_number (
        p_1                                     IN NUMBER,
        p_2                                     IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Return a number p_1 in JSON number format, if necessary use the given default 'null'.

    Input Parameter:
      p_1 - number as a string or NULL.
      p_2 - default input when p_1 is NULL.

    Return Parameter:
      string representing a number or 'null'

    Restrictions:
      - none.
    */
                       ;


    FUNCTION json_numstr (
        p_1                                     IN NUMBER,
        p_2                                     IN NUMBER DEFAULT 0)
        RETURN VARCHAR2 /*<>
    Return a JSON string representing a rounded and formatted input number p_1.
    The rounding precision is given as number of digits in p_2.

    Input Parameter:
      p_1 - input number.
      p_2 - precision for formatting (number of digits after the decimal point).

    Return Parameter:
      string representing a number or '""'

    Restrictions:
      - full precision for p_2 below 0 or above 4
    */
                       ;


    FUNCTION json_prefix (p_value IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return a comma and the provided input. Used for appending a list of 
    attribute-value pairs to a given string.

    Input Parameter:
      p_value - string.

    Return Parameter:
      concatenated string

    Restrictions:
      - none.
    */
                       ;

    FUNCTION json_string (p_string IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return a (properly JSON-escaped) string in double quotes.

    Input Parameter:
      p_string - input string.

    Return Parameter:
      escaped and wrapped output string.

    Restrictions:
      - none.
    */
                       ;

    FUNCTION json_string_key (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL,
        p_3                                     IN VARCHAR2 DEFAULT NULL,
        p_4                                     IN VARCHAR2 DEFAULT NULL,
        p_5                                     IN VARCHAR2 DEFAULT NULL,
        p_6                                     IN VARCHAR2 DEFAULT NULL,
        p_7                                     IN VARCHAR2 DEFAULT NULL,
        p_8                                     IN VARCHAR2 DEFAULT NULL,
        p_9                                     IN VARCHAR2 DEFAULT NULL,
        p_a                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Concatenate multiple key parts into a JSON list. Non-empty KeyParts only 
    (optional input parameters from right to left).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.
      p_3 - KeyPart3 varchar2.
      p_4 - KeyPart4 varchar2.
      p_5 - KeyPart5 varchar2.
      p_6 - KeyPart6 varchar2.
      p_7 - KeyPart7 varchar2.
      p_8 - KeyPart8 varchar2.
      p_9 - KeyPart9 varchar2.
      p_a - KeyParta varchar2.

    Return Parameter:
      string representation of a JSON key, like wi use it in tpac.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_string_key_2 (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Concatenate two key parts into a JSON list. Empty KeyParts are allowed.
    Using '[]' for p_1 when NULL
    Using '""' for p_2 when NULL

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.

    Return Parameter:
      string representation of a JSON key, like wi use it in tpac.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    */
                       ;

    FUNCTION json_suffix (p_value IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return NULL if p_value is NULL, otherwise return p_value and a comma.
    Used to prepend JSON attribute pair(s) to existing string.

    Input Parameter:
      p_value - JSON attribute pair(s).

    Return Parameter:
      string to prepend or NULL

    Restrictions:
      - p_value must be JSON-escaped already.
    */
                       ;

    FUNCTION json_text (
        p_string1                               IN VARCHAR2,
        p_string2                               IN VARCHAR2 DEFAULT NULL,
        p_string3                               IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Concatenate up to three strings by JSON-escaping them and concatenating with crlf.

    Input Parameter:
      p_string1 - TextPart1.
      p_string2 - TextPart2.
      p_string3 - TextPart3.

    Return Parameter:
      Lines of text (JSON-escaped and separated with crlf)

    Restrictions:
      - none.
    */
                       ;

    FUNCTION json_true (
        p_name                                  IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Create JSON attribute with name and boolean value (only if p_value is not NULL).

    Input Parameter:
      p_name  - AttributeName.
      p_value - boolean value or NULL.

    Return Parameter:
      Attribute value pair or NULL

    Restrictions:
      - none.
    */
                       ;

    FUNCTION json_type (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 /*<>
    Cast a value p_2 into JSON type p_1.

    Input Parameter:
      p_1 - type to cast to.
      p_2 - value to be casted.

    Return Parameter:
      JSON represetation of cast value

    Restrictions:
      - supported types: 'integer', 'double', 'boolean', 'string'=default.
    */
                       ;

    FUNCTION jsond (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN DATE)
        RETURN VARCHAR2 /*<>
    Prepare a json date kv-pair and append to p_start. Add a comma to p_start if it 
    does not end with '{'.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start appended with a date attribute.

    Restrictions:
      - none.
    */
                       ;


    FUNCTION jsond0 (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN DATE)
        RETURN VARCHAR2 /*<>
    Prepare a json date kv-pair and append to p_start only if not null. 
    Add a comma to p_start if it does not end with '{'.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start, possibly appended with a date attribute.

    Restrictions:
      - none.
    */
                       ;


    FUNCTION jsonn (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN NUMBER)
        RETURN VARCHAR2 /*<>
    Prepare a json number kv-pair and append to p_start. Add a comma to p_start if it 
    does not end with '{'.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start appended with a number attribute.

    Restrictions:
      - none.
    */
                       ;

    FUNCTION jsonn0 (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN NUMBER)
        RETURN VARCHAR2 /*<>
    Prepare a json number kv-pair and append to p_start only if not null. 
    Add a comma to p_start if it does not end with '{'.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start, possibly appended with a number attribute.

    Restrictions:
      - none.
    */
                       ;

    FUNCTION jsons (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Prepare a json string kv-pair and append to p_start. Add a comma to p_start if it 
    does not end with '{'.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start appended with a string attribute.

    Restrictions:
      - none.
    */
                       ;

    FUNCTION jsons0 (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Prepare a json string kv-pair and append to p_start only if not null. 
    Add a comma to p_start if it does not end with '{'.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start, possibly appended with a string attribute.

    Restrictions:
      - none.
     */
                       ;

END pkg_json;
/