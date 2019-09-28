CREATE OR REPLACE PACKAGE sbs1_admin.pkg_revi
IS
    /*<>
    Cross-Indexing of Content CDRs and Transport CDRs for Revenue Assurance
    checking of Message Broker content services

    MODIFICATION HISTORY (see also Package Body)
    Person       Date        Comments
    SO           2007-09-18  Creation
    001SO        2007-09-30  Correct type problem
    002SO        2007-10-13  Corrections
    003SO        2007-10-13  Do not assume BillingId to be present (to be reverted)
    004SO        2007-11-07  Patch for first month (october 2007)
    005SO        2007-11-08  Correct typo
    006SO        2008-01-10  Correct SMS and MMS Master cursors (MT only, no MMS-LA)
    007SO        2008-01-11  Use truncate instead of delete for index data
    008SO        2008-01-21  Remove Condition for iServer/MB distinction
    009SO        2008-03-05  Do not index SMS auto-response content %-DEL-% (to be removed after MB Bugfix)
    010SO        2008-03-05  Do not index SMS Submits without BillingIdentifier (to be removed after MB Bugfix)
    011SO        2008-04-11  use to_date() in date comparisons for proper ExplainPlan and TKPROV
    012SO        2008-04-12  Correct typo in MMSB lookup
    013SO        2008-04-12  Exclude 333 and 888 mass sendings until we have a better index
    014SO        2008-06-02  Remove previous exclusion made in 013SO
    015SO        2008-06-12  Remove previous exclusions made in 010SO and 009SO
    016SO        2008-06-18  Add file based scanning for near realtime RA analysis
    017SO        2008-06-19  Ignore OTA SMS on ShortID 800
    018SO        2008-06-19  Also monitor billing states 4 (zero charge ignored) and 7 (MSISDN range ignored)
    019SO        2008-07-02  Make use of content lookup for MBB lookup configurable (set to OFF, files only)
    020SO        2008-09-07  Implement methods for monthly prepaid charge checking
    021SO        2008-09-08  Adapt to details of the new DSS table semantics in CDRSMS and CDRMMS
    022SO        2008-09-13  Implement methods for near realtime prepaid charge checking
    023SO        2008-09-15  Implement offset for index period (for tests)
    024SO        2008-10-17  Rename ROWID to ROWID_PPB in DSS CDR views
    025SO        2009-05-06  Remove old and obsolete VASOL constraints
    026SO        2009-05-06  Include OTA CDRs in RA to DSS (override RequestID by timestamp, calltype=20)
    027SO        2009-05-07  Include request only content
    028SO        2009-05-07  Index all billed content tickets of adssured source types
    029SO        2009-05-07  Suppress error messages for OTA and request only cases
    030SO        2009-05-08  Default empty ShortID on DSS with 800 (OTA)
    031SO        2009-05-09  Enable OTA for prepaid check (DSS scan)
    032SO        2009-09-09  Remove time condition when looking up DSS content charges
    033SO        2010-05-06  Remove support for OTA
    034SO        2010-06-28  Correct Index Hints (<table> <index>)
    035SO        26.08.2010  Rename procedures according to driving Packing-ID
    036SO        11.04.2011  Consider Tariff T for InfoService Transport (Televote)
    037SO        14.12.2011  Remove schema qualifier "S B S 0 ."
    038SO        14.03.2012  Remove obsolete code for MMSB
    039SO        18.04.2012  Use PKG_COMMON.INSERT_WARNING
    040SO        10.05.2012  Correct Hint
    041SO        16.05.2012  Improve error logging
    042SO        18.05.2012  Correct error logging parameters
    043SO        25.11.2014  Correlation change for MBS A-Party-Billing: B-Number is Destination
    044SO        06.03.2016  Support for CDRs from new SMSC
    045SO        31.10.2018  Remove dependency on UCP-Format for MessageId (support MBS over SMPP)
    046SO        31.10.2018  Remove check on transport type on prepaid billing logs
    000SO        13.02.2019  HASH:1049D321C9E453AFCD4586C60975E574 pkg_revi.pkb
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_file (
        p_bih_id                                IN VARCHAR2,
        p_boh_id                                IN VARCHAR2) /*<> -- 016SO
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

    Restrictions:
      - TODO.
    */
                                                            ;

    /* =========================================================================
       TODO.

       find and index SMS and MMS transport submits for chargeable content CDRs for last period
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revicd (
        p_pac_id                                IN     VARCHAR2, -- 'REVICD'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
       TODO.

       find and index SMS and MMS transport submits for chargeable content CDRs for last period
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revics (
        p_pac_id                                IN     VARCHAR2, -- 'REVICS'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revim (
        p_pac_id                                IN     VARCHAR2, -- 'REVIM'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
       TODO.

       020SO -- find and index content CDRs for SMS prepaid charges on DSS for last period
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revipre (
        p_pac_id                                IN     VARCHAR2, -- 'REVIPRE'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
       TODO.

       020SO -- find and index content CDRs for SMS prepaid charges on DSS for last period
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_reviprm (
        p_pac_id                                IN     VARCHAR2, -- 'REVIPRM'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
       TODO.

       020SO -- find and index content CDRs for SMS prepaid charges on DSS for last period
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_reviprs (
        p_pac_id                                IN     VARCHAR2, -- 'REVIPRS'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_revis (
        p_pac_id                                IN     VARCHAR2, -- 'REVIS'
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id     - TODO.
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
END pkg_revi;
/
