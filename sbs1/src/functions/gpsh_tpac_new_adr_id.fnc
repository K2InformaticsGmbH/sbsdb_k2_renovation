CREATE OR REPLACE FUNCTION sbs1_admin.gpsh_tpac_new_adr_id (
    p_adr_email                             IN VARCHAR2,
    p_adr_invoiceemail                      IN NUMBER DEFAULT 0,
    p_adr_statisticsmail                    IN NUMBER DEFAULT 0)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function until March 2019.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_cpro.gpsh_tpac_new_adr_id (p_adr_email, p_adr_invoiceemail, p_adr_statisticsmail);
END gpsh_tpac_new_adr_id;
/
