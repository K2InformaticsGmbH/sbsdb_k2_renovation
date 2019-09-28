CREATE OR REPLACE FUNCTION sbs1_admin.json_boolean (
    p_1                                     IN VARCHAR2,
    p_2                                     IN VARCHAR2 DEFAULT 'null')
    RETURN VARCHAR2
IS
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
BEGIN
    RETURN pkg_json.json_boolean (p_1, p_2);
END json_boolean;
/