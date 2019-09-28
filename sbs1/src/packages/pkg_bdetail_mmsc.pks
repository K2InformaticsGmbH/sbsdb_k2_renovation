CREATE OR REPLACE PACKAGE sbs1_admin.pkg_bdetail_mmsc
IS
    /*<>
    TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    07.01.2004  Add SP_CONS_MMSC
    002GW    22.01.2004  Add Field to Add SP_CONS_MMSC
    003SO    07.06.2004  Patch temporarily to consolidate only 2nd half of May
    004SO    07.06.2004  Patch removed again
    004SO    08.08.2004  Correct NUM-fields by recipient count
    005SO    27.09.2004  Schedule Data Warehouse Sync
    006SO    05.10.2004  Drop obsolete procedure SP_INSERT_MMSC
    007SO    08.07.2005  Add Prices to MMS consolidation for reporting Roaming Promotion amounts
    008SO    20.02.2006  Add contract purge for MMS LA contracts
    009SO    16.08.2006  Add period entry if needed
    010SO    17.10.2006  Include MMS Bulk Table BDETAIL7 in partition management
    011SO    17.10.2006  Include MMS Bulk data into MMS consolidation
    012SO    11.04.2007  Harmonize Tablespace assignment between manual and automatic partition creation
    013SO    06.09.2007  Rename BD_MTARID to BD_TARID
    014SO    09.09.2007  Add Procedures SP_UPDATE_BOHEADER_MMSC_3 and SP_UPDATE_BOHEADER_MMSB_3
    015SO    09.09.2007  Add Procedures SP_UPDATE_BOHEADER_MMSC_2 and SP_UPDATE_BOHEADER_MMSB_2
    016SO    30.09.2007  Add Procedure SP_PREPARE_LA_MCC (clone from PKG_BDETAIL_SMSC)
    017SO    30.09.2007  Rename MMSC_MTARID to MMSC_TARID
    018SO    30.09.2007  Add MMSC_TOCID, MMSC_INT, MMSC_IW and MMSC_IOT to MMSCONSOLIDATION
    019SO    21.01.2008  Remove SP_DELETE_ALL_RECORDS_MMSC, SP_DELETE_ALL_RECORDS_MMSC, SP_DELETE_BDETAIL_MMSC
    020SO    31.10.2009  Move Period Insert to standalone Procedure
    021SO    24.04.2010  Change to new partition naming MMSB... for MMS Bulk Partition alnalysis
    022SO    20.08.2010  Implement SP_MOLAA_MMSC_ACCU
    023SO    20.08.2010  Implement SP_MOLAA_MMSC_TRY
    024SO    20.08.2010  Remove Partition ageing and partition analysis
    025SO    20.08.2010  Implement SP_MOLAA_MMSB_ACCU
    026SO    20.08.2010  Implement SP_MOLAA_MMSB_TRY
    027SO    23.08.2010  Add GART field when calling LA settlement functions
    028SO    23.08.2010  Implement SP_MOLAT_MMS_CONS similar to PKG_BDETAIL_SMSC.SP_MOLAT_SMS_CONS
    029SO    24.08.2010  Implement SP_MOLAM_MMS_CONS (MCC Consolidation, UFI creation)
    030SO    26.08.2010  Rename procedures according to driving Packing-ID
    031SO    31.08.2010  Implement SP_TRY_LIA_MMSC (MMS-LA IW Accumulation)
    032SO    31.08.2010  Implement SP_CONS_LIT_MMS (MMS-LA IW UFIH Generation)
    033SO    06.09.2010  Remove IN OUT for Consolidation Return Status
    034SO    08.09.2010  Add DateTime condition for commit of marked rows
    035SO    18.09.2010  IW Accumulators: Calculate IW Tariff when marking
    036SO    18.09.2010  Add MMSC_IOT_INTERNAL to consolidation
    037SO    20.09.2010  Tolerate NULL prices when accumulating charges
    038SO    11.04.2011  Consider Televote Transport CDRs with tariff T (not used yet)
    039SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    040SO    14.03.2012  Clean out BDETAIL7 (MMS Bulk)
    000SO    13.02.2019  HASH:CCF635C12ED5ECFD43FBC6037638E1C8 pkg_bdetail_mmsc.pkb
    041SO    05.04.2019  Document and clean out unused functions in pkg_bdetail_mmsc
    */

    PROCEDURE sp_cons_lam_mms (
        p_pac_id                                IN     VARCHAR2, -- 'LATMCC_MMS'     MMS-LA MCC UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    Perform minimum charge settlement for MMS LA by delegation to pkg_bdetail_settlement.sp_lam_mcc().

    Input Parameter:
      p_pac_id - 'LATMCC_MMS'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - forwarded record count from pkg_bdetail_settlement.sp_lam_mcc.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - depends on preparation task in sp_cons_lapmcc_mms.
    */
                                                              ;
    PROCEDURE sp_cons_lapmcc_mms (
        p_pact_id                               IN     VARCHAR2, -- 'LAPMCC_MMS' MMS-LA MCC Preparation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    Prepare minimum charge settlement for MMS LA by delegation to pkg_bdetail_settlement.sp_lapmcc().
    Get a list of MMS LA contracts which can have a minimum charge per pseudo call number. More than 
    one contract can be returned, if they have equal weighted minimum charge.
    This is taken care of in the processing of the result

    Input Parameter:
      p_pact_id - 'LAPMCC_MMS'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - forwarded record count from pkg_bdetail_settlement.sp_lapmcc.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - depends on aggregating consolidations for the settlement period (last month).
    */
                                                              ;

    PROCEDURE sp_cons_lat_mms (
        p_pac_id                                IN     VARCHAR2, -- 'LAT_MMS'    MMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    Consolidate MMS-LA daily UFIH transport tickets from so-far accumulated but not settled settlement details.
    This means: collect entries of type 'CDRA' from yesterday and maybe also from days before and generate 
    entries of type 'CDR' for them.

    Input Parameter:
      p_pac_id - 'LAT_MMS'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - marked and processed record count from table setdetail.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - should run daily but not too early in the day in order to catch all accumulated
        data from yesterday.
    */
                                                              ;

    PROCEDURE sp_cons_lit_mms (
        p_pac_id                                IN     VARCHAR2, -- 'LIT_MMS'    MMS-LA daily UFIH Ticket
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    Consolidate MMS-LA daily UFIH interworking tickets from so-far accumulated but not settled settlement details.
    This means: collect entries of type 'IOTLACA from yesterday and maybe also from days before and generate 
    entries of type 'IOTLAC' for them.

    Input Parameter:
      p_pac_id - 'LIT_MMS'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - marked and processed record count from table setdetail.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - should run daily but not too early in the day in order to catch all accumulated
        data from yesterday.
    */
                                                              ;

    PROCEDURE sp_cons_mmsc (
        p_pact_id                               IN     VARCHAR2, -- 'MMSC'   MMSC Consolidation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> -- 033SO
    Aggregate (consolidate) last month's MMS transaction CDRs from table BDETAIL6 into 
    table MMSCONSOLIDATION.

    Input Parameter:
      p_pact_id - 'MMSC'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - insert record count to table MMSCONSOLIDATION.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    */
                                                              ;

    PROCEDURE sp_try_laa_mmsc (
        p_pac_id                                IN     VARCHAR2, -- 'LAA_MMSC'   MMS-LA Accumulation (MMSC)
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    Accumulate fresh MMSC-LA transport CDRs from table BDETAIL6 into table SETDETAIL as a first step 
    in MMS-LA settlement. Only consider CDRs of a configured age and younger.
    Process one batch per call up to a configured maximum batch count (e.g. 5000 CDRs at once). 

    Input Parameter:
      p_pac_id - 'LAA_MMSC'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - record count collected and aggregated.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    */
                                                              ;

    PROCEDURE sp_try_lia_mmsc (
        p_pac_id                                IN     VARCHAR2, -- 'LIA_MMSC'   MMS-LA IW Accumulation (MMSC)
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
    Accumulate fresh MMSC-LA interworking CDRs from table BDETAIL6 into table SETDETAIL as a first step 
    in MMS-LA interworking settlement. Only consider CDRs of a configured age and younger.
    Process one batch per call up to a configured maximum batch count (e.g. 5000 CDRs at once). 

    Input Parameter:
      p_pac_id - 'LIA_MMSC'.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - record count collected and aggregated.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    */
                                                              ;
END pkg_bdetail_mmsc;
/
