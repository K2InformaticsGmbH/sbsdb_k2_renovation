CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_price_content_put (
    p_pme_pmvid                             IN VARCHAR2,
    p_pme_json                              IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_price_content_put (p_pme_pmvid, p_pme_json);
END gpsh_price_content_put;
/
