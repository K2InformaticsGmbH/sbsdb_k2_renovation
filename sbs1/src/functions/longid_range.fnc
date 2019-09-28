CREATE OR REPLACE FUNCTION sbs1_admin.longid_range (
    p_longid1                               IN NUMBER,
    p_longid2                               IN NUMBER)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_mec_oc.longid_range (p_longid1, p_longid2);
END longid_range;
/