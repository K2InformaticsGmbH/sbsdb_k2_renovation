CREATE OR REPLACE FUNCTION sbs1_admin.speed (
    bih_reccount                            IN NUMBER,
    bih_start                               IN DATE,
    bih_end                                 IN DATE)
    RETURN NUMBER
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_common.speed (bih_reccount, bih_start, bih_end);
END speed;
/