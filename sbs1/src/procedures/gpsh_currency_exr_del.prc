CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_currency_exr_del (
    p_exr_curid                             IN VARCHAR2,
    p_exr_start                             IN VARCHAR2)
/* =============================================================================
   Wrapper procedure until March 2019.
   -------------------------------------------------------------------------- */
IS
BEGIN
    pkg_toac_cpro.gpsh_currency_exr_del (p_exr_curid, p_exr_start);
END gpsh_currency_exr_del;
/
