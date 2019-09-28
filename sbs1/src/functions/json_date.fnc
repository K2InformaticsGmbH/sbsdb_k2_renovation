CREATE OR REPLACE FUNCTION sbs1_admin.json_date (p_date IN DATE)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_json.json_date (p_date);
END json_date;
/