CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_price_version_put (
    p_pmv_pmid                              IN VARCHAR2,
    p_pmv_id                                IN VARCHAR2,
    p_pmv_json                              IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_price_version_put (p_pmv_pmid, p_pmv_id, p_pmv_json);
END gpsh_price_version_put;
/
