CREATE OR REPLACE PACKAGE sbs1_admin.pkg_reva
IS
    /*<>
    TODO.

    MODIFICATION HISTORY
    Person       Date        Comments
    AH           2004-08-11  Creation
    001SO        2004-10-20  Add calling parameters BIH_ID, BOH_ID for INSERT_WARNING
    002SO        2004-10-20  Remove unused exceptions
    003SO        2004-10-20  Set RecordsAffected
    004SO        2004-10-20  Remove dependence from BDETAIL4
    005SO        2004-10-20  Set / Reset ErrorMsg
    006SO        2004-10-20  Check all BiHeader States (''RDY'',''ERR'', ''IDX'', ''IDE'')
    007SO        2004-10-20  Reset InCountAnalyzed for each analysis (REVA HEADER)
    008SO        2004-10-20  Support some REVA HEADER tokens in REVA SQLs
    009SO        2004-10-21  Create unknown signatures with order 999.9999
    010SO        2004-10-25  Use static cursor for finding all relevant REVA Headers
    011SO        2004-10-25  Correct logic for suspended REVA Headers
    012SO        2004-10-25  Add Input parameter p_DESC to call SP_REVA_RECENT (for BOH_FILENAME)
    013SO        2004-10-25  Move Variable vBiheaderStm to scope of SP_REVA_RECENT and rename to SqlStmBiHeader
    014SO        2004-10-25  Add Input parameter p_SqlStmSrcType to call SP_REVA_RECENT (for BOH_FILENAME)
    015SO        2004-10-25  Add config parameter REVAC_RUNTIMELIMIT and use to terminate BIHEADER loop
    016SO        2004-10-25  Create separate stub for REVA-SMSC
    017SO        2004-10-25  Make SP_REVA_RECENT a private procedure and rename to REVA_RECENT
    018SO        2005-01-17  Allow for unions in execution of query REVA_INSQL (counting in more than one table)
    019SO        2005-11-12  Also consider indexing intermediate states 'idx' and 'ide' for MMS files (used only for migration)
    020SO        2006-08-17  Change signature mask length from 10 to 20
    021SO        2008-06-16  Process oldest files first and respect a minimum age and maximum age
    022SO        2008-06-19  Create index entries for near realtime Revenue Assurance where appliccable
    023SO        29.03.2010  Rename p_PACT_ID to p_PAC_ID
    024SO        29.03.2010  Use new generalized method for inserting a dummy header in SPTRY
    025SO        2010-06-28  Correct Index Hints (<table> <index>)
    026SO        2010-07-01  Optimize Execution Plan for Header Selection
    027SO        2010-07-14  Enable use of BIH_MAPID for Header Selection (Parallelizing SMSC RA)
    028SO        2010-07-14  Go back to single SMSC RA analysis (Lock contention on REVA_COUNTER)
    029SO        2010-07-15  Simplify REVA_OTHERS file query. Suspended REVA_HEADERs not supported any more
    030SO        2010_08-10  Correct intendation and initialize variable where unsafe
    031SO        26.08.2010  Rename procedures according to driving Packing-ID
    032SO        14.12.2011  Remove schema qualifier "S B S 0 ."
    033SO        19.04.2012  Use PKG_COMMON.INSERT_WARNING
    034SO        16.05.2012  Improve error logging
    035SO        18.05.2012  Correct error logging parameters
    036SO        18.06.2016  Include SMSN (new SMSCs) in Revenue Assurance
    037SO        17.11.2018  Use Bind Variables :1 / :2 for BIHEADER ID
    038SO        18.11.2018  Fix multiple insert of new sugnatures for different dates
    039SO        19.11.2018  Replace cursor with select/exception and add insert warnings per new signature
    040SO        20.11.2018  Improve signature warnings
    041SO        27.11.2018  Improve signature warnings (less verbose for less than 5 differences)
    000SO        13.02.2019  HASH:3B171E63D3752F13A19139B9EA3A1D7F pkg_reva.pkb
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

    PROCEDURE sp_try_reva_recent_msc (
        p_pac_id                                IN     VARCHAR2, -- 023SO
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

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_reva_recent_others (
        p_pac_id                                IN     VARCHAR2, -- 023SO
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

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_reva_recent_smsc (
        p_pac_id                                IN     VARCHAR2, -- 023SO
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
END pkg_reva;
/
