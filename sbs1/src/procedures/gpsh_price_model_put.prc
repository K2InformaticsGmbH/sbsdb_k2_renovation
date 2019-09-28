CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_price_model_put (
    p_pm_id                                 IN VARCHAR2,
    p_pm_json                               IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_price_model_put (p_pm_id, p_pm_json);
END gpsh_price_model_put;
/
