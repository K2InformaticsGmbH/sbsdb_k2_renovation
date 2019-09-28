CREATE OR REPLACE FUNCTION sbs1_admin.job_datefrom (p_job_id IN VARCHAR2)
    RETURN DATE
/* =========================================================================
   Wrapper function.
   ---------------------------------------------------------------------- */
IS
BEGIN
    RETURN pkg_mec_oc.job_datefrom (p_job_id);
END job_datefrom;
/