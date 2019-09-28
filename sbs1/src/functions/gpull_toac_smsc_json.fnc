CREATE OR REPLACE FUNCTION sbs1_admin.gpull_toac_smsc_json (p_smsc_code IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpull_toac_smsc_json (p_smsc_code);
END gpull_toac_smsc_json;
/
