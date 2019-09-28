CREATE OR REPLACE FUNCTION sbs1_admin.json_number (
    p_1                                     IN NUMBER,
    p_2                                     IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_json.json_number (p_1, p_2);
END json_number;
/