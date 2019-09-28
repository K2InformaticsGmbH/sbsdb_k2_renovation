CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_toac_con_put (
    p_con_id                                IN VARCHAR2,
    p_con_json                              IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_toac_cpro.gpsh_toac_con_put (p_con_id, p_con_json);
END gpsh_toac_con_put;
/
