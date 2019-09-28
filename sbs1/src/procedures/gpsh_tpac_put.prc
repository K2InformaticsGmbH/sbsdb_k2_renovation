CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_tpac_put (
    p_ac_id                                 IN VARCHAR2,
    p_ac_json                               IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_tpac_put (p_ac_id, p_ac_json);
END gpsh_tpac_put;
/
