CREATE OR REPLACE FUNCTION sbs1_admin.json_string_key (
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
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_json.json_string_key (
               p_1,
               p_2,
               p_3,
               p_4,
               p_5,
               p_6,
               p_7,
               p_8,
               p_9,
               p_a);
END json_string_key;
/