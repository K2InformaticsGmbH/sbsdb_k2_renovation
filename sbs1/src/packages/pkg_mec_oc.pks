SET DEFINE OFF;

CREATE OR REPLACE PACKAGE sbs1_admin.pkg_mec_oc
IS
    /*<>
    Output Converter.
    Getting Data out from SBS2.

    MODIFICATION HISTORY
    Person       Date        Comments
    001SO        27.01.2010  Created based on PKG_MEC_IC_CSV
    002SO        28.01.2010  Add Parameter p_FileName to insert header
    003SO        09.02.2010  Add Parameter p_JobId and rename to SP_GET_JOB_DETAILS
    004SO        09.02.2010  Add SP_GET_JOB_QUERIES
    005SO        09.02.2010  Add SP_REGISTER_OUTPUT
    006SO        11.02.2010  Change signature of SP_REGISTER_OUTPUT
    007DA        23.02.2010  Method SP_GET_PACKING_ID added
    008DA        16.03.2010  GetJobDetails() now returns also Email related attribute values (right outer join)
    009DA        17.03.2010  Added attributes NOT_MAXATTSIZE & NOT_ETID to GetJobDetails() output
    010DA        18.03.2010  Added attributes STAC_SMTPHOST & STAC_SMTPPORT to GetJobDetails() output
    011DA        19.03.2010  Added attribute PAC_NOTIFICATION to GetJobDetails() output
    012DA        19.03.2010  PAC_COMPRESS, PAC_FIELDSEP and PAC_LINESEP now taken from PACKING table
    013SO        28.03.2010  Handle 2 new workflow exceptions
    014SO        28.03.2010  Use prepared JobSql for Individual Statistics generation
    015SO        29.03.2010  Implement SP_MODIFY_HEADER, used by SPTRY output converters
    016SO        07.04.2010  Adapted for use on SBS2 database
    017SO        07.04.2010  Adapted for use on SBS2 database
    018SO        12.04.2010  Remove wrong packing update
    019SO        14.04.2010  Correct parameter typo
    020SO        24.04.2010  Remove exception handler for other errors
    021SO        08.05.2010  Use generalized job parameter replacement
    022DA        27.05.2010  New Packing attribute PAC_ENCODINGTYPE implemented
    023SO        12.08.2010  Implement dynamic address evaluation for looper statistics notifications
    024SO        26.08.2010  Implement sorting for transaction statements with job queries
    025SO        09.09.2010  Correct Token to <EndTransaction>
    026SO        10.09.2010  Correct name NOT_ADRTO back to how it was before 025SO
    027SO        08.12.2010  Implement eMail sending of LA-invoices to several adddresses
    028SO        15.09.2011  Implement eMail sending of BN-statistics
    029SO        14.12.2011  Remove schema qualifier "S B S 0 ."
    030SO        06.08.2017  Remove deprecated notification address placeholder
    000SO        13.02.2019  HASH:AE92178C3885B12693518AD05B118840 pkg_mec_oc.pkb
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Return concatenated eMail adresses for BN-Statistics for given AC_ID.
       ---------------------------------------------------------------------- */

    FUNCTION bn_stats_emails (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return concatenated eMail adresses for BN-Statistics for given AC_ID.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Concatenated eMail adresses.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    27.08.2011  Created
    002SO    23.02.2017  Use ACCOUNT.AC_BN_STATS_EMAILS directly
    003SO    25.04.2017  Longer Variables
    004SO    05.05.2017  Simplify Body
    */
                       ;

    /* =========================================================================
       Used for evaluation of main eMail-Adress of Job.
       ---------------------------------------------------------------------- */

    FUNCTION job_adrid_main_email (p_job_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of main eMail-Adress of Job.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Return concatenated eMail adresses for BN-Statistics for given statistics
       job.
       ---------------------------------------------------------------------- */

    FUNCTION job_bn_stats_emails (p_job_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return concatenated eMail adresses for BN-Statistics for given statistics
    job.

    Uses function BN_STATS_EMAILS(ac_id).

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    27.08.2011  Created
    */
                       ;

    /* =========================================================================
       Used for evaluation of BOH_ID belonging to the statistic executor.
       ---------------------------------------------------------------------- */

    FUNCTION job_bohidexec (p_job_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of BOH_ID belonging to the statistic executor.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_datefrom (p_job_id IN VARCHAR2)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_datetill (p_job_id IN VARCHAR2)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_dateto (p_job_id IN VARCHAR2)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       Used for evaluation of job sql.
       ---------------------------------------------------------------------- */

    FUNCTION job_expanded_sql (
        p_jobid                                 IN VARCHAR2,
        p_job_sql                               IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of job sql.

    Input Parameter:
      p_job_id  - TODO.
      p_job_sql - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    --MODIFICATION HISTORY
    --Code  Date        Comments
    ------- ----------  ----------------------------------------------
    --001SO 09.09.2010  Add replacement of JOB_BOHIDEXEC function
    --002SO 05.09.2011  Expand buffer variables
    */
                       ;

    /* =========================================================================
       Return concatenated eMail adresses for invoices for given statistics job.
       ---------------------------------------------------------------------- */

    FUNCTION job_la_invoice_emails (p_job_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return concatenated eMail adresses for invoices for given statistics job.

    Uses function LA_INVOICE_EMAILS(ac_id).

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      Concatenated eMail adresses.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    08.12.2009  Created
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION job_loopvar (p_job_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    002SO    17.03.2012  Correct wrong result type
    */
                       ;

    /* =========================================================================
       Used for evaluation of reporting parameters.
       ---------------------------------------------------------------------- */

    FUNCTION job_parameter (
        p_job_id                                IN VARCHAR2,
        p_par_name                              IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of reporting parameters.

    Input Parameter:
      p_job_id   - TODO.
      p_par_name - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Used for evaluation of reporting parameters.
       ---------------------------------------------------------------------- */

    FUNCTION job_search_parameter (
        p_job_id                                IN VARCHAR2,
        p_par_name                              IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of reporting parameters.

    Input Parameter:
      p_job_id   - TODO.
      p_par_name - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Return concatenated eMail adresses for invoices for given AC_ID.
       ---------------------------------------------------------------------- */

    FUNCTION la_invoice_emails (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return concatenated eMail adresses for invoices for given AC_ID.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Concatenated eMail adresses.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    08.12.2009  Created
    002SO    23.02.2017  Use ACCOUNT.AC_LA_INVOICE_EMAILS directly
    003SO    25.04.2017  Longer Variables
    004SO    05.05.2017  Simplify Body
    */
                       ;

    /* =========================================================================
       Return rendered range information for LongID.
       ---------------------------------------------------------------------- */

    FUNCTION longid_range (
        p_longid1                               IN NUMBER,
        p_longid2                               IN NUMBER)
        RETURN VARCHAR2 /*<>
    Return rendered range information for LongID.

    Input Parameter:
      p_longid1 - TODO.
      p_longid2 - TODO.

    Return Parameter:
      Range information.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    02.08.2017  Created
    002SO    04.08.2017  suppress single LongID range suffix and remove CNT
    */
                       ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_job_details ( -- 003SO
        p_packingid                             IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2, -- 003SO
        p_refcursor                                OUT SYS_REFCURSOR,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_packingid - TODO.
      p_jobid     - TODO.

    Output Parameter:
      p_refcursor    - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_job_queries (
        p_packingid                             IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_refcursor                                OUT SYS_REFCURSOR,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<> -- 004SO
    TODO.

    Input Parameter:
      p_packingid - TODO.
      p_jobid     - TODO.

    Output Parameter:
      p_refcursor    - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_packing_id (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_packingid   - TODO.
      p_thread      - TODO.

    Output Parameter:
      p_packingid    - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.

       -- 007DA
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_headerid                                 OUT VARCHAR2,
        p_jobid                                    OUT VARCHAR2,
        p_filename                                 OUT VARCHAR2, -- 002SO
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<> -- 005SO
    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_packingid   - TODO.
      p_appname     - TODO.
      p_appver      - TODO.
      p_thread      - TODO.
      p_taskid      - TODO.
      p_hostname    - TODO.

    Output Parameter:
      p_packingid    - TODO.
      p_headerid     - TODO.
      p_jobid        - TODO.
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_modify_header (
        p_headerid                              IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_filename                                 OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<> -- 015SO
    TODO.

    Input Parameter:
      p_headerid - TODO.
      p_appname  - TODO.
      p_appver   - TODO.
      p_thread   - TODO.
      p_taskid   - TODO.
      p_hostname - TODO.

    Output Parameter:
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_register_output (
        p_packingid                             IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_filepath                              IN     VARCHAR2, -- absolute path without file name
        p_filename                              IN     VARCHAR2, -- name only
        p_filesize                              IN     NUMBER, -- 006SO
        p_outputtype                            IN     VARCHAR2, -- XLS / PDF / CSV for now
        p_outputid                                 OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<> -- 005SO
    TODO.

    Input Parameter:
      p_packingid  - TODO.
      p_jobid      - TODO.
      p_filepath   - TODO.
      p_filename   - TODO.
      p_filesize   - TODO.
      p_outputtype - TODO.

    Output Parameter:
      p_outputid     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_update_header (
        p_headerid                              IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_filename                              IN OUT VARCHAR2,
        p_filedate                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        p_dataheader                            IN     VARCHAR2,
        p_reccount                              IN     NUMBER,
        p_errcount                              IN     NUMBER,
        p_datefc                                IN     VARCHAR2,
        p_datelc                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_headerid   - TODO.
      p_jobid      - TODO.
      p_filename   - TODO.
      p_filedate   - TODO.
      p_maxage     - TODO.
      p_dataheader - TODO.
      p_reccount   - TODO.
      p_errcount   - TODO.
      p_datefc     - TODO.
      p_datelc     - TODO.

    Output Parameter:
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;
END pkg_mec_oc;
/