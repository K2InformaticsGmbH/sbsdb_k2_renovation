CREATE OR REPLACE FUNCTION sbs1_admin.gpull_tpac_json (p_ac_id IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpull_tpac_json (p_ac_id);
END gpull_tpac_json;
/
