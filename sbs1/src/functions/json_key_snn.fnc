CREATE OR REPLACE FUNCTION sbs1_admin.json_key_snn (
    p_1                                     IN VARCHAR2,
    p_2                                     IN NUMBER,
    p_3                                     IN NUMBER)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_json.json_key_snn (p_1, p_2, p_3);
END json_key_snn;
/