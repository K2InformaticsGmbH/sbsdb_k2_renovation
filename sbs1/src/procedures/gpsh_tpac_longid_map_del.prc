CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_tpac_longid_map_del (
    p_longm_longid1                         IN VARCHAR2,
    p_longm_longid2                         IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_tpac_cpro.gpsh_tpac_longid_map_del (p_longm_longid1, p_longm_longid2);
END gpsh_tpac_longid_map_del;
/
