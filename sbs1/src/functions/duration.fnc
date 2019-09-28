CREATE OR REPLACE FUNCTION sbs1_admin.duration (p_time_diff IN NUMBER)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_common.duration (p_time_diff);
END duration;
/