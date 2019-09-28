CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_json
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    FUNCTION from_json_boolean (p_data IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        IF p_data = 'true'
        THEN
            RETURN 1;
        ELSIF p_data = 'false'
        THEN
            RETURN 0;
        END IF;

        RETURN NULL;
    END from_json_boolean;

    FUNCTION from_json_date (p_date IN VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        IF p_date IS NULL
        THEN
            RETURN NULL;
        ELSE
            RETURN TO_DATE (REPLACE (REPLACE (REPLACE (p_date, 'T', ' '), 'Z', ''), '"', ''), 'yyyy-mm-dd hh24:mi:ss');
        END IF;
    END from_json_date;

    FUNCTION json_boolean (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT 'null')
        RETURN VARCHAR2
    IS
    BEGIN
        IF    p_1 = '1'
           OR LOWER (p_1) = 'true'
        THEN
            RETURN 'true';
        ELSIF    p_1 = '0'
              OR LOWER (p_1) = 'false'
        THEN
            RETURN 'false';
        END IF;

        RETURN p_2;
    END json_boolean;

    FUNCTION json_date (p_date IN DATE)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_date IS NULL
        THEN
            RETURN '""';
        ELSE
            RETURN '"' || REPLACE (TO_CHAR (p_date, 'yyyy-mm-dd hh24:mi:ss'), ' ', 'T') || 'Z"';
        END IF;
    END json_date;

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
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN    '{"fk":'
               || json_string_key (
                      p_1                                  => p_1,
                      p_2                                  => p_2,
                      p_3                                  => p_3,
                      p_4                                  => p_4,
                      p_5                                  => p_5,
                      p_6                                  => p_6,
                      p_7                                  => p_7,
                      p_8                                  => p_8,
                      p_9                                  => p_9,
                      p_a                                  => p_a)
               || '}';
    END json_foreign_key;

    FUNCTION json_foreign_key_2 (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        p1                                      VARCHAR2 (100);
        p2                                      VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            p1 := '""';
        ELSE
            p1 := '"' || p_1 || '"';
        END IF;

        IF p_2 IS NULL
        THEN
            p2 := '""';
        ELSE
            p2 := '"' || p_2 || '"';
        END IF;

        RETURN '{"fk":[' || p1 || ',' || p2 || ']}';
    END json_foreign_key_2;

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
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN    '{"fks":['
               || json_string_key (
                      p_1                                  => p_1,
                      p_2                                  => p_2,
                      p_3                                  => p_3,
                      p_4                                  => p_4,
                      p_5                                  => p_5,
                      p_6                                  => p_6,
                      p_7                                  => p_7,
                      p_8                                  => p_8,
                      p_9                                  => p_9,
                      p_a                                  => p_a)
               || ']}';
    END json_foreign_keys;

    FUNCTION json_foreign_keys_2 (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        list                                    VARCHAR2 (100);
    BEGIN
        IF TRIM (p_2) IS NULL
        THEN
            RETURN '{"fks":[["' || p_1 || '",null]]}';
        ELSE
            list := REPLACE (p_2, ' ', '');

            IF SUBSTR (list, 1, 1) = ';'
            THEN
                list := SUBSTR (list, 2);
            END IF;

            IF SUBSTR (list, LENGTH (list)) = ';'
            THEN
                list := SUBSTR (list, 1, LENGTH (list) - 1);
            END IF;

            IF list IS NULL
            THEN
                RETURN '{"fks":[["' || p_1 || '",null]]}';
            ELSE
                list := REPLACE (list, ';', '"],["' || p_1 || '","');
                RETURN '{"fks":[["' || p_1 || '","' || list || '"]]}';
            END IF;
        END IF;
    END json_foreign_keys_2;

    FUNCTION json_key_sn (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER)
        RETURN VARCHAR2
    IS
        p1                                      VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            p1 := '[]';
        ELSE
            p1 := '"' || p_1 || '"';
        END IF;

        RETURN '[' || p1 || ',' || p_2 || ']';
    END json_key_sn;

    FUNCTION json_key_snn (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER,
        p_3                                     IN NUMBER)
        RETURN VARCHAR2
    IS
        p1                                      VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            p1 := '[]';
        ELSE
            p1 := '"' || p_1 || '"';
        END IF;

        RETURN '[' || p1 || ',' || p_2 || ',' || p_3 || ']';
    END json_key_snn;

    FUNCTION json_key_sns (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER,
        p_3                                     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        p1                                      VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            p1 := '[]';
        ELSE
            p1 := json_string (p_1);
        END IF;

        RETURN '[' || p1 || ',' || p_2 || ',' || json_string (p_3) || ']';
    END json_key_sns;

    FUNCTION json_not_null (
        p_name                                  IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN NULL;
        ELSIF p_value = '""'
        THEN
            RETURN NULL;
        ELSE
            RETURN ',"' || p_name || '":' || json_string (p_value);
        END IF;
    END json_not_null;

    FUNCTION json_num (
        p_1                                     IN VARCHAR2,
        p_2                                     IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_1 IS NULL
        THEN
            RETURN TO_CHAR (p_2);
        ELSE
            RETURN TO_CHAR (TO_NUMBER (p_1));
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN json_string (p_1);
    END json_num;

    FUNCTION json_number (
        p_1                                     IN NUMBER,
        p_2                                     IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_num                                   VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            IF p_2 IS NULL
            THEN
                RETURN 'null';
            ELSE
                l_num := TO_CHAR (p_2);

                IF l_num LIKE '.%'
                THEN
                    RETURN '0' || l_num;
                ELSIF l_num LIKE '-.%'
                THEN
                    RETURN '-0' || SUBSTR (l_num, 2);
                ELSE
                    RETURN l_num;
                END IF;
            END IF;
        ELSE
            l_num := TO_CHAR (p_1);

            IF l_num LIKE '.%'
            THEN
                RETURN '0' || l_num;
            ELSIF l_num LIKE '-.%'
            THEN
                RETURN '-0' || SUBSTR (l_num, 2);
            ELSE
                RETURN l_num;
            END IF;
        END IF;
    END json_number;

    FUNCTION json_numstr (
        p_1                                     IN NUMBER,
        p_2                                     IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_1 IS NULL
        THEN
            RETURN '""'; -- NULL
        ELSIF p_2 = 0
        THEN
            RETURN '"' || LTRIM (TO_CHAR (p_1, '999999999990')) || '"';
        ELSIF p_2 = 1
        THEN
            RETURN '"' || LTRIM (TO_CHAR (p_1, '9999999990.0')) || '"';
        ELSIF p_2 = 2
        THEN
            RETURN '"' || LTRIM (TO_CHAR (p_1, '999999990.00')) || '"';
        ELSIF p_2 = 3
        THEN
            RETURN '"' || LTRIM (TO_CHAR (p_1, '99999990.000')) || '"';
        ELSIF p_2 = 4
        THEN
            RETURN '"' || LTRIM (TO_CHAR (p_1, '9999990.0000')) || '"';
        ELSE
            RETURN '"' || LTRIM (TO_CHAR (p_1)) || '"';
        END IF;
    END json_numstr;

    FUNCTION json_prefix (p_value IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN NULL;
        ELSE
            RETURN ',' || p_value;
        END IF;
    END json_prefix;

    FUNCTION json_string (p_string IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN    '"'
               || REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (p_string, '\', '\\'), '"', '\"'), CHR (8), '\b'), CHR (9), '\t'), CHR (10), '\n'), CHR (12), '\f'), CHR (13), '\r')
               || '"';
    END json_string;

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
        RETURN VARCHAR2
    IS
        p1                                      VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            p1 := '[]';
        ELSE
            p1 := '"' || p_1 || '"';
        END IF;

        IF p_2 IS NULL
        THEN
            RETURN '[' || p1 || ']';
        ELSIF p_3 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '"]';
        ELSIF p_4 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '"]';
        ELSIF p_5 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '"]';
        ELSIF p_6 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '","' || p_5 || '"]';
        ELSIF p_7 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '","' || p_5 || '","' || p_6 || '"]';
        ELSIF p_8 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '","' || p_5 || '","' || p_6 || '","' || p_7 || '"]';
        ELSIF p_9 IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '","' || p_5 || '","' || p_6 || '","' || p_7 || '","' || p_8 || '"]';
        ELSIF p_a IS NULL
        THEN
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '","' || p_5 || '","' || p_6 || '","' || p_7 || '","' || p_8 || '","' || p_9 || '"]';
        ELSE
            RETURN '[' || p1 || ',"' || p_2 || '","' || p_3 || '","' || p_4 || '","' || p_5 || '","' || p_6 || '","' || p_7 || '","' || p_8 || '","' || p_9 || '","' || p_a || '"]';
        END IF;
    END json_string_key;

    FUNCTION json_string_key_2 (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        p1                                      VARCHAR2 (100);
        p2                                      VARCHAR2 (100);
    BEGIN
        IF p_1 IS NULL
        THEN
            p1 := '[]';
        ELSE
            p1 := '"' || p_1 || '"';
        END IF;

        IF p_2 IS NULL
        THEN
            p2 := '""';
        ELSE
            p2 := '"' || p_2 || '"';
        END IF;

        RETURN '[' || p1 || ',' || p2 || ']';
    END json_string_key_2;

    FUNCTION json_suffix (p_value IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN NULL;
        ELSE
            RETURN p_value || ',';
        END IF;
    END json_suffix;

    FUNCTION json_text (
        p_string1                               IN VARCHAR2,
        p_string2                               IN VARCHAR2 DEFAULT NULL,
        p_string3                               IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        crlf                                    VARCHAR2 (10) := CHR (13) || CHR (10);
    BEGIN
        IF p_string3 IS NULL
        THEN
            IF p_string2 IS NULL
            THEN
                RETURN json_string (p_string1);
            ELSE
                RETURN json_string (p_string1 || crlf || p_string2);
            END IF;
        ELSE
            RETURN json_string (p_string1 || crlf || p_string2 || crlf || p_string3);
        END IF;
    END json_text;

    FUNCTION json_true (
        p_name                                  IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN NULL;
        ELSIF json_boolean (p_value, 'false') = 'true'
        THEN
            RETURN ',"' || p_name || '":' || json_boolean (p_value, 'false');
        ELSE
            RETURN NULL;
        END IF;
    END json_true;

    FUNCTION json_type (
        p_1                                     IN VARCHAR2,
        p_2                                     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
    BEGIN
        -- if p_1 = 'string' and p_2 = '**null**' then
        --     return '""';
        IF p_2 = '**null**'
        THEN
            RETURN 'null';
        ELSIF     p_1 = 'integer'
              AND p_2 IS NULL
        THEN
            RETURN 'null';
        ELSIF p_1 = 'integer'
        THEN
            RETURN json_num (p_2);
        ELSIF     p_1 = 'double'
              AND p_2 IS NULL
        THEN
            RETURN 'null';
        ELSIF p_1 = 'double'
        THEN
            RETURN json_num (p_2);
        ELSIF     p_1 = 'boolean'
              AND p_2 IS NULL
        THEN
            RETURN 'null';
        ELSIF p_1 = 'boolean'
        THEN
            RETURN json_boolean (p_2);
        ELSE
            RETURN json_string (p_2);
        END IF;
    END json_type;

    FUNCTION jsond (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN DATE)
        RETURN VARCHAR2
    IS -- append a json date
    BEGIN
        IF p_start IS NULL
        THEN
            RETURN '"' || p_key || '":' || json_date (p_value);
        ELSIF p_start LIKE '%{'
        THEN
            RETURN p_start || '"' || p_key || '":' || json_date (p_value);
        ELSE
            RETURN p_start || ',"' || p_key || '":' || json_date (p_value);
        END IF;
    END jsond;

    FUNCTION jsond0 (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN DATE)
        RETURN VARCHAR2
    IS -- append a json date
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN p_start;
        ELSIF p_start IS NULL
        THEN
            RETURN '"' || p_key || '":' || json_date (p_value);
        ELSIF p_start LIKE '%{'
        THEN
            RETURN p_start || '"' || p_key || '":' || json_date (p_value);
        ELSE
            RETURN p_start || ',"' || p_key || '":' || json_date (p_value);
        END IF;
    END jsond0;

    FUNCTION jsonn (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN NUMBER)
        RETURN VARCHAR2
    IS -- append a json number
    BEGIN
        IF p_start IS NULL
        THEN
            RETURN '"' || p_key || '":' || json_number (p_value);
        ELSIF p_start LIKE '%{'
        THEN
            RETURN p_start || '"' || p_key || '":' || json_number (p_value);
        ELSE
            RETURN p_start || ',"' || p_key || '":' || json_number (p_value);
        END IF;
    END jsonn;

    FUNCTION jsonn0 (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN NUMBER)
        RETURN VARCHAR2
    IS -- append a json number
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN p_start;
        ELSIF p_start IS NULL
        THEN
            RETURN '"' || p_key || '":' || json_number (p_value);
        ELSIF p_start LIKE '%{'
        THEN
            RETURN p_start || '"' || p_key || '":' || json_number (p_value);
        ELSE
            RETURN p_start || ',"' || p_key || '":' || json_number (p_value);
        END IF;
    END jsonn0;

    FUNCTION jsons (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS -- append a json string
    BEGIN
        IF p_start IS NULL
        THEN
            RETURN '"' || p_key || '":' || json_string (p_value);
        ELSIF p_start LIKE '%{'
        THEN
            RETURN p_start || '"' || p_key || '":' || json_string (p_value);
        ELSE
            RETURN p_start || ',"' || p_key || '":' || json_string (p_value);
        END IF;
    END jsons;

    FUNCTION jsons0 (
        p_start                                 IN VARCHAR2,
        p_key                                   IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS -- append a json string
    BEGIN
        IF p_value IS NULL
        THEN
            RETURN p_start;
        ELSIF p_start IS NULL
        THEN
            RETURN '"' || p_key || '":' || json_string (p_value);
        ELSIF p_start LIKE '%{'
        THEN
            RETURN p_start || '"' || p_key || '":' || json_string (p_value);
        ELSE
            RETURN p_start || ',"' || p_key || '":' || json_string (p_value);
        END IF;
    END jsons0;
END pkg_json;
/