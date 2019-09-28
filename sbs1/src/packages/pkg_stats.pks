CREATE OR REPLACE PACKAGE sbs1_admin.pkg_stats
IS
    /*<>
    Project: Statistical Module.
    Procedures for WEB, GENERATOR and SENDER (see XPIOC).

    MODIFICATION HISTORY
    Person       Date        Comments
    AHAUPENTHAL  31-03-2003  Creation
    AH           01-04-2003  checkDependencies
    AH           03-04-2003  cleanJobs, getNextJob
    AH           03-04-2003  scheduleStats: repeat until...
    AH           06-04-2003  scheduleStats: anythingToDo??
    AH           15-04-2003  executer: getNextJob
    AH           16-04-2003  executer: setJobResult
    AH           21-04-2003  scheduleStats: repeat until, typ II reports with loop
    AH           21-04-2003  getNextJob: checkDependencies for all jobs
    AH           21-04-2003  doAdminCleanJobs
    AH           22-05-2003  insert into table WARNINGS
    AH           26-05-2003  getNextJob: collect notification data
    AH           03-06-2003  scheduleJob: include ExcecutionDelay and job periodid
    AH           10-06-2003  Schedule Individual Jobs and repeat them; setJobResult -> update Repeat Monkeys
    AH           13-07-2003  getNextExecDay updated
    AH           15-07-2003      Transaction read only
    AH           16-07-2003  getNextDate -> individual
    AH           17-07-2003      Individuals, getNextExecDate
    AH           21-07-2003  getNextExecDate
    AH           07-01-2004  scheduleStats -> Iterator ID for Loopings (SCHNAPPS)
    AH           08-04-2004  Conditional Execution added to scheduleStats
    AA           19-03-2004  use Upper() function in cursors cNote and cNoteParam in procedure getNextJob()
    AH           23-04-2004  RecordCount for TopStopReport (getNextJob)
    AH           28-04-2004  getNextJob: Extend Array to XPIOC for PDF
    AH           10-05-2004      getNextJob: Extend Array to XPIOC for ARCHIVE DIR and USER OUTPUT DIR
    AA           30-06-2004  SP_NEW_STA_JOBSQLS: replace the parameters tokens for ShortId, MsisndnA, MsisdnB
    AH           05-07-2004  scheduleStats: No lower(vSql) because of CONSTANTS
    AH           28-07-2004  scheduleStats: bLooped
    001AA        18-08-2004  Added procedure for parameter 'SP_REPLACE_PARAMS' replacement
    002AH        28-10-2004  scheduleStats: Add individual packing pac_execdelay for STATIND (SBS08.55)
    003SO        14-12-2004  Go back to days for parameter pac_execdelay and
    004SO        14-12-2004  Consider more than one dependency
    005SO        14-12-2004  checkDependenciesWeb removed. Not used any more
    006SO        15.12.2004  Simplify query condition in STA_GETNEXTJOB
    007SO        15.12.2004  Change rescheduling because of dependencies in STA_GETNEXTJOB
    008SO        15.12.2004  Catch exceptions in case of nonexisting BaseTable Info. No BT checking done.
    009AA        23.12.2004  Added sp GetJobNotifData to return Job local notification data to Xpioc
    010AA        30.12.2004  Added new parameters to SP_NEW_STA_JOB sp (p_StajNotification,p_StajNotId,p_StajNotEmailSuccess,p_StajNotEmailFailure,p_StajNotSendAttachment)
    011SO        04.04.2005  Consider locked workflow task as not done when checking dependencies
    012SO        13.03.2006  Correct scheduling time for weekly stats reports
    013SO        03.05.2007  Consider all packing states of forerunner jobs when checking dependency violations
    014SO        01.02.2008  Correct false truncation in scheduler
    015SO        02.02.2010  Create MEC_OC Stubs NEW_STA_JOB_xxx and UPDATE_STA_JOB_xxx
    016SO        25.03.2010  Remove MEC_OC Stubs NEW_STA_JOB_xxx and UPDATE_STA_JOB_xxx (implemented in PKG_STATS)
    017SO        28.03.2010  Implement scheduleIndividualStats as standard CONSOL job
    018SO        29.03.2010  Convert scheduleIndividualStats from CONSOL to SPTRY
    019SO        29.03.2010  Use new generalized method for inserting a dummy header in SPTRY
    020SO        29.03.2010  Correct error handling in scheduleIndividualStats (handle suspend)
    021SO        23.04.2010  Also lock working jobs together with locking of a package
    022SO        23.04.2010  Unlock job with a trycount reset after re-activating a package.
    023SO        18.04.2012  Use PKG_COMMON.INSERT_WARNING
    000SO        13.02.2019  HASH:9E53B9DCCAC9644B2E22F9E8AD3A4CF5 pkg_stats.pkb
    */

    TYPE rdepinfo IS RECORD
    (
        deppacid VARCHAR2 (10),
        deppacname VARCHAR2 (100),
        deppacexec DATE
    );

    TYPE tdepinfo IS VARRAY (100) OF rdepinfo;

    TYPE tjob IS TABLE OF VARCHAR2 (2000)
        INDEX BY PLS_INTEGER;

    TYPE tkey IS TABLE OF VARCHAR2 (4000)
        INDEX BY PLS_INTEGER;

    TYPE tnote IS TABLE OF VARCHAR2 (4000)
        INDEX BY PLS_INTEGER; -- 009AA also used by the procedure getJobNotifData

    TYPE tvalue IS TABLE OF VARCHAR2 (4000)
        INDEX BY PLS_INTEGER;

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Clean already scheduled jobs, which are not executed within allowed time frame
       ---------------------------------------------------------------------- */

    FUNCTION cleanjobs (hrstoexec IN sta_config.stac_execsched%TYPE)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      hrstoexec - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getnextexecdate (
        incaller                                IN VARCHAR2,
        inpacid                                 IN VARCHAR2,
        inrefdate                               IN DATE)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      incaller  - TODO.
      inpacid   - TODO.
      inrefdate - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.

       WEB STUFF
       ---------------------------------------------------------------------- */

    PROCEDURE checkbasetabledata (
        inpacid                                 IN     VARCHAR2,
        outdatefrom                                OUT DATE,
        outdateto                                  OUT DATE,
        outdrop                                    OUT NUMBER,
        outdropperiod                              OUT VARCHAR2,
        outdatefromraw                             OUT DATE,
        outdatetoraw                               OUT DATE,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      inpacid      - TODO.
      returnstatus - TODO.

    Output Parameter:
      outdatefrom     - TODO.
      outdateto       - TODO.
      outdrop         - TODO.
      outdropperiod   - TODO.
      outdatefromraw  - TODO.
      outdatetoraw    - TODO.
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       Executes next Job in Queue.

       EXECUTER

       Purpose:      Executes next Job in Queue
       Caller:       XPIOC
       Author:       Anita Haupenthal

       001AH         28.04.2004 PDF value
       002AH                 10.05.2004 ARCHIVE DIR and User OUTPUT DIR

       LastUpdate:       10-05-2004 ARCHIVE DIR and User OUTPUT DIR
       ---------------------------------------------------------------------- */

    PROCEDURE getnextjob (
        p_pact_id                               IN     VARCHAR2 DEFAULT NULL,
        p_boh_id                                IN     VARCHAR2 DEFAULT NULL,
        arrkey                                     OUT tkey,
        arrvalue                                   OUT tvalue,
        arrnote                                    OUT tnote,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_pact_id    - TODO.
      p_boh_id     - TODO.
      returnstatus - TODO.

    Output Parameter:
      arrkey          - TODO.
      arrvalue        - TODO.
      arrnote         - TODO.
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                                ;

    /* =========================================================================
       TODO.

       SCHEDULER
       Called by XPIOC and/or WebGUI
       Procedures and functions for SCHEDULER
       ---------------------------------------------------------------------- */

    PROCEDURE schedulestats (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_pact_id    - TODO.
      p_boh_id     - TODO.
      returnstatus - TODO.

    Output Parameter:
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                                ;

    /* =========================================================================
       Create a new Stats Job record and return the Job Id in the output
       parameter.
       Overloaded procedure version of SP_NEW_STA_JOB procedure with extra
       Job Notification parameters.

       010AA
       Author:   Ateeq Ahmed
       CALLER:   Web Interface (Web Module: clsStat.GetNewJob)
       ---------------------------------------------------------------------- */

    PROCEDURE sp_new_sta_job (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajinfo                              IN     sta_job.staj_info%TYPE,
        p_stajltvalue                           IN     sta_job.staj_ltvalue%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_acidcre                               IN     account.ac_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE,
        p_stajnotification                      IN     sta_job.staj_notification%TYPE, -- 010AA
        p_stajnotid                             IN     sta_job.staj_notid%TYPE, -- 010AA
        p_stajnotemailsuccess                   IN     sta_job.staj_notemailsuccess%TYPE, -- 010AA
        p_stajnotemailfailure                   IN     sta_job.staj_notemailfailure%TYPE, -- 010AA
        p_stajnotsendattachment                 IN     sta_job.staj_notsendatt%TYPE, -- 010AA
        p_recordsaffected                          OUT NUMBER,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_stajparentid          - TODO.
      p_stajpacid             - TODO.
      p_stajinfo              - TODO.
      p_stajltvalue           - TODO.
      p_stajperiodid          - TODO.
      p_acidcre               - TODO.
      p_stajnotification      - TODO.
      p_stajnotid             - TODO.
      p_stajnotemailsuccess   - TODO.
      p_stajnotemailfailure   - TODO.
      p_stajnotsendattachment - TODO.
      p_errnumber             - TODO.
      p_errdesc               - TODO.
      p_returnstatus          - TODO.

    Output Parameter:
      p_stajid          - TODO.
      p_recordsaffected - TODO.
      p_errnumber       - TODO.
      p_errdesc         - TODO.
      p_returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       Create a new Stats Job Parameter for the given StatJob Id.

       Author:   Ateeq Ahmed
       CALLER:   Web Interface
       ---------------------------------------------------------------------- */

    PROCEDURE sp_new_sta_jobparam (
        p_stajid                                IN     sta_job.staj_id%TYPE,
        p_stajpname                             IN     sta_jobparam.stajp_name%TYPE,
        p_stajpvalue                            IN     sta_jobparam.stajp_value%TYPE,
        p_recordsaffected                          OUT NUMBER,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_stajid       - TODO.
      p_stajpname    - TODO.
      p_stajpvalue   - TODO.
      p_errnumber    - TODO.
      p_errdesc      - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_recordsaffected - TODO.
      p_errnumber       - TODO.
      p_errdesc         - TODO.
      p_returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_new_sta_jobsqls (
        p_stajid                                IN     sta_job.staj_id%TYPE,
        p_recordsaffected                          OUT NUMBER,
        p_errnumber                             IN OUT NUMBER,
        p_errdesc                               IN OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_stajid     - TODO.
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Output Parameter:
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.

       Trigger: watchPackageStateChanges

       Anita Haupenthal
       LastUpdate: 14.07.2003

       Called by TRIGGER watchPackageStateChanges
       keep track of package-state and job-state integrity
       ---------------------------------------------------------------------- */

    PROCEDURE watchpackagestatechanges (
        vpacid                                  IN packing.pac_id%TYPE,
        voldpacesid                             IN packing.pac_esid%TYPE,
        vnewpacesid                             IN packing.pac_esid%TYPE,
        voldpacltid                             IN packing.pac_ltid%TYPE,
        vnewpacltid                             IN packing.pac_ltid%TYPE) /*<>
    TODO.

    Input Parameter:
      vpacid      - TODO.
      voldpacesid - TODO.
      vnewpacesid - TODO.
      voldpacltid - TODO.
      vnewpacltid - TODO.

    Restrictions:
      - TODO.
    */
                                                                         ;

    /* =========================================================================
       TODO.

       SYSTEM STUFF
       ---------------------------------------------------------------------- */

    PROCEDURE writesyslog (
        pmethod                                 IN VARCHAR2,
        psqlcode                                IN NUMBER,
        psqlerrm                                IN VARCHAR2,
        pparameter                              IN VARCHAR2,
        ploggedon                               IN DATE) /*<>
    TODO.

    Input Parameter:
      pmethod    - TODO.
      psqlcode   - TODO.
      psqlerrm   - TODO.
      pparameter - TODO.
      ploggedon  - TODO.

    Restrictions:
      - TODO.
    */
                                                        ;
END pkg_stats;
/