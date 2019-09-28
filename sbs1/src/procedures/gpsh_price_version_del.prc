CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_price_version_del (p_pmv_id IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_price_version_del (p_pmv_id);
END gpsh_price_version_del;
/
