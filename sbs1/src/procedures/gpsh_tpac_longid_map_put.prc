CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_tpac_longid_map_put (p_longid_json IN VARCHAR2)
IS
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
BEGIN
    pkg_tpac_cpro.gpsh_tpac_longid_map_put (p_longid_json);
END gpsh_tpac_longid_map_put;
/
