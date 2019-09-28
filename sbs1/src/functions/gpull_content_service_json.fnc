CREATE OR REPLACE FUNCTION sbs1_admin.gpull_content_service_json (p_cs_id IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpull_content_service_json (p_cs_id);
END gpull_content_service_json;
/
