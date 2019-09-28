CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_toac_smsc_put (
    p_conop_key                             IN VARCHAR2,
    p_smsc_json                             IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_toac_cpro.gpsh_toac_smsc_put (p_conop_key, p_smsc_json);
END gpsh_toac_smsc_put;
/
