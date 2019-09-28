CREATE OR REPLACE FUNCTION sbs1_admin.job_parameter (
    p_job_id                                IN VARCHAR2,
    p_par_name                              IN VARCHAR2)
    RETURN VARCHAR2
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_mec_oc.job_parameter (p_job_id, p_par_name);
END job_parameter;
/