CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_toac_con_del (p_con_id IN VARCHAR2)
IS
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
BEGIN
    pkg_toac_cpro.gpsh_toac_con_del (p_con_id);
END gpsh_toac_con_del;
/
