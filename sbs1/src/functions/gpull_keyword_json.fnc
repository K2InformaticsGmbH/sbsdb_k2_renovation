CREATE OR REPLACE FUNCTION sbs1_admin.gpull_keyword_json (p_con_id IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpull_keyword_json (p_con_id);
END gpull_keyword_json;
/
