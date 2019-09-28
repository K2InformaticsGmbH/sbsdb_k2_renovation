CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_price_transport_put (
    p_pmvt_pmvid                            IN VARCHAR2,
    p_pmvt_json                             IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_price_transport_put (p_pmvt_pmvid, p_pmvt_json);
END gpsh_price_transport_put;
/
