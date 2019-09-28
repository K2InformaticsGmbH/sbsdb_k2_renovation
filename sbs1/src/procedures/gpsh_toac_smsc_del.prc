CREATE OR REPLACE PROCEDURE sbs1_admin.gpsh_toac_smsc_del (
    p_smsc_code                             IN VARCHAR2,
    p_smsc_conopkey                         IN VARCHAR2)
/* =========================================================================
   Wrapper procedure until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_toac_cpro.gpsh_toac_smsc_del (p_smsc_code, p_smsc_conopkey);
END gpsh_toac_smsc_del;
/
