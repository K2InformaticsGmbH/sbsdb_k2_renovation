CREATE OR REPLACE FUNCTION sbs1_admin.json_string (p_string IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN json_string (p_string);
END json_string;
/