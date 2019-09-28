CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_tpac_keyword_put (
    p_con_id                                IN VARCHAR2,
    p_key_json                              IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_tpac_keyword_put (p_con_id, p_key_json);
END gpsh_tpac_keyword_put;
/
