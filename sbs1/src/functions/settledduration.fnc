CREATE OR REPLACE FUNCTION sbs1_admin.settledduration (
    con_datestart                           IN DATE,
    con_dateend                             IN DATE)
    RETURN NUMBER
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_bdetail_settlement.settledduration (con_datestart, con_dateend);
END settledduration;
/