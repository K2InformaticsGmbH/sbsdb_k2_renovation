CREATE OR REPLACE FUNCTION sbs1_admin.gpull_price_json (p_price_key IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpull_price_json (p_price_key);
END gpull_price_json;
/
