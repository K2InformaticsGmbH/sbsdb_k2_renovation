CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_currency_put (p_cur_json IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_toac_cpro.gpsh_currency_put (p_cur_json);
END gpsh_currency_put;
/
