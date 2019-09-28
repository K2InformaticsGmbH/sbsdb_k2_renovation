CREATE OR REPLACE PACKAGE sbs1_admin.pkg_bdetail_smsc
AS
    /*<>
    TODO.

    MODIFICATION HISTORY
    Person      Date        Comments
    001SO       06.01.2004  correcting bracketing in SP_CONS_SMSC
    002SO       17.06.2004  exclude Tariff M (mVoting) from Minimum Charge Correction
    003SO       21.10.2004  Rebuild index partitions instead of using default tablespace
    004SO       21.10.2004  Compile all in error case too
    005SO       01.12.2004  Correct index ageing for SMSD indexes (went to SMSC tablespaces before)
    006SO       16.08.2006  Add period entry by using PKG_BDETAIL_COMMON.SP_INSERT_PERIOD()
    006SO       09.09.2007  Add SP_UPDATE_BOHEADER_SMSC_2 (moved from PKG_INTERWORKING)
    007SO       25.09.2007  Reduce retries in manual SMSC partition creation from 100 to 2
    008SO       25.09.2007  Add error logging for partition creation
    009SO       21.01.2008  Remove SP_INSERT_SMSC, SP_UPDATE_BIHEADER_SMSC, SP_DELETE_BDETAIL_SMSC, SP_DELETE_ALL_RECORDS_SMSC
    010SO       22.05.2009  Add SC terminated counter update for home routed SMS
    011SO       27.05.2009  Add SP_UPDATE_BOHEADER_SMSC_1 for home routed IW counting SMSCCU
    012SO       28.05.2009  Implement Settlement for SMS Global Reply
    013SO       04.06.2009  Change SMS Global reply settlement from BDETAIL1 to BDETAIL2
    014SO       08.06.2009  Add procedure SP_UPDATE_BOHEADER_SMSCCU_1
    015SO       08.06.2009  Correct bugs in SP_SETTLE_GLOBAL_REPLY
    016SO       09.06.2009  Remove SP_UPDATE_BOHEADER_CHECKLA_0, SP_UPDATE_BOHEADER_GEMLAT_0
    017SO       10.06.2009  Use Accumulation for home routing monthly fees and refuse double settlement
    018SO       12.06.2009  Set customer price to 0.00 for global reply monthly fees
    019SO       12.06.2009  Correct cleanup in SP_SETTLE_GLOBAL_REPLY
    020SO       16.06.2009  Use final settlement detail description also for LongID/ShortId accumulation
    021SO       16.06.2009  Set description for accumulating settlement items which need to be printed
    022SO       24.06.2009  Correct wrong code for home routed IW refund accumulation
    023SO       24.09.2009  Ignore not null constraint when counting terminating IW SMS with unknown SMSC ID
    024SO       31.10.2009  Remove obsolete partition ageing methods ADD_SMSC_PARTITIONS.. ADD_SMSD_PARTITIONS...
    025SO       31.10.2009  31.03.2010  Implement SP_SMSCCA_TRY (mark and process MSC counter updates)
    026SO       14.04.2010  Remove Normalisation in DGTI and OGTI Consolidation
    027SO       15.04.2010  Update state after counter update
    028SO       17.08.2010  Implement SMSC-LA accumulation in SP_LAA_SMS_TRY
    029SO       19.08.2010  Correct Group Syntax for changed field
    030SO       19.08.2010  Correct VAT Code to NA (was N/A)
    031SO       20.08.2010  Implement SMS-LA UFIH ticket generation in SP_LAT_SMS_CONS
    032SO       23.08.2010  Remove exception handling for SMS-LA Settlement hard errors
    033SO       24.08.2010  Implement SP_LAM_SMS_CONS (MCC Consolidation, UFI creation)
    034SO       25.08.2010  Take out GR processing from SP_LAT_SMS_CONS and implement in SP_LAT_MFGR_CONS
    035SO       26.08.2010  Rename procedures according to driving Packing-ID
    036SO       31.08.2010  Implement SP_TRY_LIA_SMS (SMS-LA IW Accumulation, outgoing IW SMS)
    037SO       31.08.2010  Implement SP_CONS_LIT_SMS
    038SO       31.08.2010  Implement SP_TRY_LIA_RSGR
    039SO       06.09.2010  Correct Error Handling
    040SO       07.09.2010  Consider empty markings and report as success
    041SO       07.09.2010  Guard old partitions using datetime criterium when commiting marking
    042SO       07.09.2010  Remove cursor variables where not necessary / check status in ACCU
    042SO       07.09.2010  Include "MOIWSA" when generating UFIH IW tickets
    043SO       08.09.2010  Guard old partitions with 1 hour tolerance
    044SO       10.09.2010  Set error code when processed records <> marked records
    045SO       18.09.2010  IW Accumulators: Calculate IW Tariff when marking
    046SO       18.09.2010  Add ROC_IOT_INTERNAL to consolidation
    047SO       20.09.2010  Tolerate NULL prices when accumulating charges
    048SO       21.09.2010  Correct bug in Global reply revenue share calculation
    049SO       21.09.2010  Do not count zero global reply revenue shares
    050SO       04.10.2010  Correct result state in SP_CONS_OGTI
    051SO       11.04.2011  Consider Televote Transport CDRs with tariff T
    051SOa      12.10.2010  Correct min charge preparation in SP_CONS_LAPMCC_SMS
    052SO       14.12.2011  Remove schema qualifier "S B S 0 ."
    053SO       17.10.2013  Add M2M outgoing SMS to IW consolidation
    054SO       22.02.2016  Implement SC terminating IW counting for home routed roaming cases
    055SO       23.02.2016  Fix IW Counting for empty home routing counter value
    055SO       06.03.2016  Generalize settlement for new SMSC and simplify signatures
    056SO       10.06.2016  Suppress unwanted incoming IW CDRs for ROCONSOLIDATION
    057SO       09.08.2016  Suppress Tariff 'i' and all internal interworking costs from settlement table
    058SO       06.10.2016  Ignore internal home routed SMS (OnNet) in Output Consolidation
    059SO       06.10.2016  Remove obsolete SMS-MV* CDR Type References
    060SO       16.10.2016  Remove more references to mVoting CDR Tags SMS-MV*
    061SO       16.10.2016  Assume BD_RETSHAREPV = BD_RETSHAREMO = 0.00 (mVoting cleanup)
    062SO       16.10.2016  Distinguish OMN from Acision in MO/MT counting for Large Accounts
    063SO       22.10.2016  Fixes SMS-LA Settlement
    064SO       09.12.2016  Move MOFN Accumulation from SP_LAA_SMS_ACCU (BDETAIL1) to SP_LAA_SMS_ACCU (BDETAIL2)
    065SO       09.12.2016  Remove some support for SMSC (old Acision specialities)
    066SO       10.12.2016  Fix Query in MOFNA processing
    067SO       12.07.2017  Compress LongId ranges
    068SO       04.08.2017  Cosmetic comment change
    069SO       16.02.2018  Consolidate seperately per CDR Type (ROCONSOLIDATION)
    070SO       13.04.2018  Accumulate pager messages separately into SETDETAIL as PAGA
    071SO       16.04.2018  Settle pager messages separately (PAG)
    072SO       10.05.2018  Fix double billing issue for LongIDs with more than one contract in period
    000SO       13.02.2019  HASH:039CB45463CDDB8F5C98D53477D28C1F pkg_bdetail_smsc.pkb
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

    PROCEDURE sp_cons_dgti (
        p_pac_id                                IN     VARCHAR2, -- 'DGTI'     DGTI consolidation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --  039SO
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

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

    PROCEDURE sp_cons_iwt (
        p_pact_id                               IN     VARCHAR2, -- 'IWT'    IW Consolidation SC Outgoing
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --  039SO
    TODO.

    Input Parameter:
      p_pact_id - TODO.
      p_boh_id  - TODO.

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

    PROCEDURE sp_cons_laa_mfgr (
        p_pact_id                               IN     VARCHAR2, -- 'LAT_MFGR'   SMS-LA monthly UFIH Tickets GlobalReply
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --  039SO
    TODO.

    Input Parameter:
      p_pact_id - TODO.
      p_boh_id  - TODO.

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

    PROCEDURE sp_cons_lam_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LATMCC_SMS'     SMS-LA MCC UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

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

    PROCEDURE sp_cons_lapmcc_sms (
        p_pact_id                               IN     VARCHAR2, -- 'LAPMCC_SMS'     SMS-LA MCC Preparation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --  039SO
    TODO.

    Input Parameter:
      p_pact_id - TODO.
      p_boh_id  - TODO.

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

    PROCEDURE sp_cons_lat_mfgr (
        p_pac_id                                IN     VARCHAR2, -- 'LAT_MFGR'   SMS-LA monthly UFIH Tickets GlobalReply
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

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

    PROCEDURE sp_cons_lat_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LAT_SMS'    SMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

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

    PROCEDURE sp_cons_lit_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LIT_SMS'    SMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

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

    PROCEDURE sp_cons_ogti (
        p_pact_id                               IN     VARCHAR2, -- 'OGTI'   OGTI consolidation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --  039SO
    TODO.

    Input Parameter:
      p_pact_id - TODO.
      p_boh_id  - TODO.

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

    PROCEDURE sp_cons_smsc (
        p_pact_id                               IN     VARCHAR2, -- 'SMSC'   SMSC Consolidation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --  039SO
    TODO.

    Input Parameter:
      p_pact_id - TODO.
      p_boh_id  - TODO.

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

    PROCEDURE sp_try_laa_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LAA_SMS'    SMS-LA Accumulation
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

    Output Parameter:
      p_boh_id        - TODO.
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

    PROCEDURE sp_try_lia_rsgr (
        p_pac_id                                IN     VARCHAR2, -- 'LIA_SMS'    SMS-LA IW Accumulation
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

    Output Parameter:
      p_boh_id        - TODO.
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

    PROCEDURE sp_try_lia_sms (
        p_pac_id                                IN     VARCHAR2, -- 'LIA_SMS'    SMS-LA IW Accumulation
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

    Output Parameter:
      p_boh_id        - TODO.
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

    PROCEDURE sp_try_smsccu (
        p_pac_id                                IN     VARCHAR2, -- 'SMSCCU'     SMSC COUNTER UPDATE
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

    Output Parameter:
      p_boh_id        - TODO.
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;
END pkg_bdetail_smsc;
/
