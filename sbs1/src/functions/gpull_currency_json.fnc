CREATE OR REPLACE FUNCTION sbs1_admin.gpull_currency_json (p_cur_key IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpull_currency_json (p_cur_key);
END gpull_currency_json;
/
