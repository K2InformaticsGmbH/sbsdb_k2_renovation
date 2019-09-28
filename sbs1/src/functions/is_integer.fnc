CREATE OR REPLACE FUNCTION sbs1_admin.is_integer (
    p_inputvalue                            IN VARCHAR2,
    p_minvalue                              IN NUMBER DEFAULT NULL,
    p_maxvalue                              IN NUMBER DEFAULT NULL)
    RETURN NUMBER
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_common.is_integer (p_inputvalue, p_minvalue, p_maxvalue);
END is_integer;
/