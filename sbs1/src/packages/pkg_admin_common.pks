CREATE OR REPLACE PACKAGE sbs1_admin.pkg_admin_common
IS
    /*<>
    Common routines for SBS input and output converters.

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    001SO       25.11.2003  Created, code moved from PKG_BDETAIL_COMMON
    002AA       02.12.2003  Created routing stored procedure calls for all packages SPs accessed from WebModule
    002AH       31.03.2004  Added new WARNING Writer, without ReturnCode
    003AH       31.03.2004  Added new ERROR HANDLING, WARNING Writer, without RETURNCODE, and VALUES
    004AH       07.04.2004  Changed getErrorDesc -> Merge table error with errdef
    005AA       18.07.2004  Added wrapper procedure 'SP_REPLACE_PARAMS' for 'PKG_STATS.SP_REPLACE_PARAMS'
    006SO       03.09.2004  Using PKG_AAA_PROV now instead of PKG_AAA
    007SO       21.12.2004  Desupport for checkDependenciesWeb
    008AA       30.12.2004  Added overload procedure SP_NEW_STA_JOB with extra job notification parameters (p_StajNotification,p_StajNotId,p_StajNotEmailSuccess,p_StajNotEmailFailure,p_StajNotSendAttachment)
    009AA       10.01.2005  Added overlaoded procedure SP_INSERT_ISSUE with additional parameter for AC_ID (called by Pkg_Centrum for creating Account/Address related issues (history entries))
    010SO       08.02.2004  Using PKG_AAA_HB instead of PKG_AAA_PROV
    011AA       11.02.2004  Add new stored procedure SP_INSERT_AAACUSTBAR to insert a new AAA RBT Barring Rule
    012SO       08.02.2009  Add Procedures for LongID management
    013SO       09.02.2009  Implement LongID mapping validation and logging
    014SO       23.02.2009  Correct naming for parameter p_AC_ID and field LONGH_ACID
    015SO       08.03.2009  Create overload for SP_INSERT_AAALOG
    016SO       13.12.2011  Remove CAT test implementation
    017SO       14.12.2011  Remove schema qualifier "S B S 0 ."
    018SO       29.02.2012  Use DB Link to SBS0 so that we can grant usage to SBSWEB
    019SO       18.04.2012  Use synonyms instead of DB-Links to other schemas
    020SO       06.05.2012  Use local synonyms instead of explicit schemas
    021SO       13.06.2015  Remove stub for customer barring (ringbacktone)
    022SO       01.12.2015  Add Procedure to hide Statistics Job output from GUI
    023SO       14.12.2015  Add Procedure to generate Statistics Job
    024SO       15.01.2019  Concatenate individual remarks into Job Info
    000SO       13.02.2019  HASH:4FEF4B41CF288DF61E2EFCE7D01B4CF8 pkg_admin_common.pkb
    025SO       01.04.2019  Remove deprecated procedure insert_issue
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION geterrordesc (lverrcode IN VARCHAR2)
        RETURN errdef.errd_lang01%TYPE /*<>
    Get standard error message for given error code or exception name.
    Look it up in table errdef.

    Input Parameter:
      lverrcode - ErrorCode or ExceptionName.

    Return Parameter:
      on success - english version of error message (errdef.lang01)
      on error - lverrcode || ': Error Description not available'

    Restrictions:
      - input is searched in errdef.errd_code or in errd_exception
        for a a case insensitive match
    */
                                      ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_report (
        str_acid                                IN     VARCHAR2,
        str_pac_id                              IN     VARCHAR2,
        dat_from                                IN     DATE,
        dat_to                                  IN     DATE,
        str_opt_param                           IN     VARCHAR2,
        str_comment                             IN     VARCHAR2,
        str_system_info                         IN     VARCHAR2,
        str_parameter_info                      IN     VARCHAR2,
        int_pac_modis                           IN     NUMBER,
        int_pac_modla                           IN     NUMBER,
        int_pac_modiw                           IN     NUMBER,
        int_pac_modsys                          IN     NUMBER,
        int_pac_modcuc                          IN     NUMBER,
        int_errnumber                              OUT NUMBER,
        str_errdesc                                OUT VARCHAR2) /*<>
    Schedule a report creation workflow in the tables sta_job, sta_jobparam and sta_jobsql.

    Input Parameter:
      str_acid           - AccountId of statistics engine workflow runner (always 'SYSTEM' so far).
      str_pac_id         - PackingId (report type, e.g. 'SL093a').
      dat_from           - report time frame start time, fills sta_jobparam '[DATEFROM]' attribute.
      dat_to             - report time frame start time, fills sta_jobparam '[DATETO]' attribute.
      str_opt_param      - report optional filter parameter, fills sta_jobparam '[OPT_PARAM] attribute.
      str_comment        - concatenated with str_system_info and str_parameter_info into sta_job.staj_info.
      str_system_info    - concatenated with str_comment and str_parameter_info into sta_job.staj_info.
      str_parameter_info - concatenated with str_comment and str_system_info into sta_job.staj_info.
      int_pac_modis      - not used since statistics module ist statically assigned on table packing.
      int_pac_modla      - not used since statistics module ist statically assigned on table packing.
      int_pac_modiw      - not used since statistics module ist statically assigned on table packing.
      int_pac_modsys     - not used since statistics module ist statically assigned on table packing.
      int_pac_modcuc     - not used since statistics module ist statically assigned on table packing.

    Output Parameter:
      int_errnumber - error code returned by pkg_stats.sp_new_sta_jobsqls.
      str_errdesc   - error description returned by pkg_stats.sp_new_sta_jobsqls.

    Restrictions:
      - none.
    */
                                                                ;

    PROCEDURE sp_hide_job_output (
        p_acid                                  IN     account.ac_id%TYPE,
        p_joboutputid                           IN     sta_joboutput.stajo_id%TYPE,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2) /*<>
    Soft delete a statistics job (set state = 'D' for deleted) based on the id of one of its output ids.
    Emit a warning 'STATS', 'SP_HIDE_JOB_OUTPUT', 'JOB DELETED BY ACCOUNT ' || p_acid in the logs.

    Input Parameter:
      p_acid        - AccountId of statistics engine workflow runner (always 'SYSTEM' so far).
      p_joboutputid - Job OutputId (ResultDocumentId) for which to soft delete the job.

    Output Parameter:
      p_errnumber - 0 for success or SQLCODE for failure.
      p_errdesc   - NULL for success or SQLERRM for failure.

    Restrictions:
      - none.
    */
                                                                ;

    PROCEDURE sp_validate_exchange_rates (
        p_cur_id                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    Validate exchange rates and re-calculate gapless end dates from time sorted start dates.

    Input Parameter:
      p_cur_id     - CurrencyId.
      returnstatus - any value (not relevant).

    Output Parameter:
      errorcode    - 0 for success or SQLCODE for failure.
      errormsg     - NULL for success or SQLERRM for failure.
      returnstatus - 1 = success, 0 = error.

    Restrictions:
      - none.
    */
                                                              ;
END pkg_admin_common;
/