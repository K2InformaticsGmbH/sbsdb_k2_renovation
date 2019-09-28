CREATE OR REPLACE FUNCTION sbs1_admin.reva_sigmask_merge (
    s                                       IN VARCHAR2,
    m                                       IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_adhoc.reva_sigmask_merge (s, m);
END reva_sigmask_merge;
/