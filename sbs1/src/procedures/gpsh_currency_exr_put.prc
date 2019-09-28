CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_currency_exr_put (
    p_cur_id                                IN VARCHAR2,
    p_exr_json                              IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_toac_cpro.gpsh_currency_exr_put (p_cur_id, p_exr_json);
END gpsh_currency_exr_put;
/
