CREATE OR REPLACE PACKAGE sbs1_admin.pkg_bdetail_info
AS
    /*<>
    Routines for info service CDR input and output converters.

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    SO          06.06.2001  Created from earlier versions (SBS phase 4)
    002AA       17.02.2003  Added partition creation for BDITEM table after that of BDETAIL table (in SP_ADD_INFO_PARTITIONS, SP_ADD_INFO_PARTITIONS_MAN)
    003SO       20.02.2003  Corrected override of error flags in SP_CONS_IS exception handler
    004AA       26.02.2003  Added BDITEM table in Cursor selection criteria for processing Indexes belonging to BDITEM table along with those of BDETAIL table
    005AA       26.02.2003  Analyze the BDITEM table after analyzing the BDETAIL table
    006AA       27.03.2003  Add partition handling for BDETAIL9 (AAA-UFIH) table (also includes indexes updating and table analyzing)
    007AA       18.06.2003  Add Price Model Version State checking to Price Model lookup criteria
    008SO       23.09.2003  Use SP_UPDATE_TOPSTOP as centralized update mechanism for all ICs
    009SO       23-09.2003  Streamline SP_UPDATE_BIHEADER_INFO, reducing BDETAIL scans
    010SO       31.03.2004  Suppress Output after CutoffDate April 1st
    011SO       07.06.2004  Replace MMS Traffic consolidation in SP_CONS_TR
    012SO       21.06.2004  Prioritize SMS over MMS in SP_CONS_TR for SMS La
    013SO       21.06.2004  Prioritize MMS over SMS in SP_CONS_TR for MMS La
    014AH       14.07.2004  Hack Red CODE (Billtext Patching for SERVICE = '9733')
    015SO       03.09.2004  Desupport IC functions and and remove unnecessary references to PKG_AAA
    016SO       13.06.2005  Synchronize-Funktion f?r DuoBill lookup table
    017SO       14.06.2005  FlatFile Import Procedure SP_INSERT_ADBC for Duobill Customer MSISDN und IMSI Lookup Table
    018AA       20.06.2005  Added SP_UPDATE_BIHEADER_ADBC for updating Biheader for Duobill import (ALL_DUO_BILL_CUST)
    019AA       20.06.2005  Added SP_CLEAR_ADBC for clearing up the ALL_DUO_BILL_CUST table before Duobill import
    020AA       20.06.2005  Updated SP_INSERT_ADBC stored proc for importing Duobill flat file (ALL_DUO_BILL_CUST)
    021SO       05.07.2005  Implement DuoBill mapping table transfer in SP_SYNC_DUO_BILL_CUST
    022SO       06.07.2005  Implement DuoBill config table read
    023SO       06.07.2005  Change DuoBill checking for numberranges
    024SO       10.11.2005  Loosen validation for DuoBill DuoCard support (duplicate virtual MSISDN and IMSI allowed)
    025SO       10.11.2005  Loosen validation for DuoBill DuoCard support (410... dummy MSISDNs allowed)
    026SO       18.11.2005  Allow for TFL DuoBill Customers in DouBill Lookup Provisioning
    027SO       18.11.2005  Aggregate content consolidation for contracts using too many billtexts
    028SO       18.11.2005  Remove Hack 014AH (pure numeric BillTexts for ShortId 9733
    029SO       18.11.2005  Aggregate content per MSISDN consolidation for contracts using too many billtexts
    030SO       21.11.2005  Use period id for IS consolidation (simplifies re-consolidating older periods)
    031SO       21.11.2005  Correct AutoFix Insert statement
    032SO       21.11.2005  Use period id for Cursor in SP_CONS_IS_MSISDN
    033SO       22.11.2005  Correct AutoFix aggregation SQL in order to allow multiple  consolidations
    034SO       05.03.2005  Make warning texts stronger when aborting DuoBill Synchronisation.
    035SO       08.05.2006  Implement separated Transport cost calculation for prepaid/postpaid
    036SO       16.08.2006  Add period entry by using PKG_BDETAIL_COMMON.SP_INSERT_PERIOD()
    037SO       02.10.2006  Replace renamed fields: CON_CODE->CON_ESTID, CON_SHORTCODEx->CON_SHORTID
    038SO       02.10.2006  Add fields to ISCONSOL
    039SO       17.10.2006  Include MMS Bulk traffic in transport cost calculation
    040SO       09.11.2006  Correct data field size for service code from 10 to 20
    041SO       09.11.2006  Correct sorting for transport cost ip contract mapping
    042SO       29.04.2007  Consolidate BDETAIL including CDR type ID
    043SO       23.07.2007  Consolidate for MT content only (ignoring MO CDRs) in SP_CONS_MSISDN
    044SO       03.10.2007  Do not populate ISC_KEYWORD any more in info service consolidation
    045SO       17.10.2007  Implement partition rollover for REVI tables
    046SO       22.01.2008  Consolidate VAS Keywords when BillRate is not NULL
    047SO       22.01.2007  Add IS consolidation fields for new Transport Cost Calculation
    048SO       22.01.2007  Use IS consolidation for Message Broker Transport Cost Calculation (ISRV)
    049SO       12.02.2008  Correct Transport Price for MMS
    050SO       14.02.2008  Correct Transport Cost Lookup for SMS
    052SO       07.09.2008  Implement partition ageing for REVIPRE - Index Tables
    053SO       02.04.2009  Implement new billtext aggregation logic using ISC_BILLTEXT_AGR
    054SO       31.10.2009  Move Period Insert to standalone Procedure
    055SO       26.08.2010  Rename procedures according to driving Packing-ID
    056SO       26.08.2010  Remove partition management code (ADD/ANA)
    057SO       04.02.2011  New consolidation field BD_GART
    058SO       20.04.2011  New consolidation fields BD_SHOW, BD_CAMPAIGN
    059SO       14.12.2011  Remove schema qualifier "S B S 0 ."
    060SO       19.04.2012  Remove procedure SP_CLEAR_ADBC
    061SO       19.04.2012  Remove procedure SP_INSERT_ADBC
    062SO       19.04.2012  Remove procedure SP_UPDATE_BIHEADER_ADBC
    063SO       19.04.2012  Remove procedure SP_CONS_DUOBILLSYN
    064SO       19.04.2012  Use PKG_COMMON.INSERT_WARNING
    065SO       15.11.2018  Remove reference to CON_SERVICE
    000SO       13.02.2019  HASH:D2818453A636F6C4769CE392419EEEF1 pkg_bdetail_info.pkb
    066SO       05.04.2019  Restrict transport cost calculation to ISRV (table ISCONSOL)
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_is (
        p_pac_id                                IN     VARCHAR2, -- 'IS'
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    Soft deletes and then (re-) fills up consolidation table ISCONSOL (Info Service Consolidation) 
    with aggregated transaction data from table BDETAIL.
    Deletes and then fills table isc_aggregation with aggregated data for contracts which have too 
    many items. Adds a flag to those contract entries in ISCONSOL. This can be used as a row count 
    warning (provoke a fallback to lump sum presentation) later in the reports.

    Input Parameter:
      p_pac_id     - ActorId varchar2(10) usually 'SYSTEM'.
      p_boh_id     - BillingOutputHeaderId (Output Converter attempt id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - number of flagged row count warnings.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    */
                                                              ;
    PROCEDURE sp_cons_ismsisdn (
        p_pac_id                                IN     VARCHAR2, -- 'ISMSISDN'   ISMSISDN Consolidation
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    Fills up consolidation table ISMSTAT (Info Service per Msisdn) with data from table BDETAIL
    Fills up consolidation table TPMCONSOL (Third Party Msisdn) with data from table BDETAIL

    Input Parameter:
      p_pac_id     - ActorId varchar2(10) usually 'SYSTEM'.
      p_boh_id     - BillingOutputHeaderId (Output Converter attempt id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - 1 for success, 0 for error.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    */
                                                              ;
    PROCEDURE sp_cons_tr (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    Consolidate transport costs for previous month.
    Soft delete pre-existing entries for the period in table TRCONSOL.
    Aggregate transport costs (separately for SMS and MMS transport) from table ISCONSOL
    and populate TRCONSOL with the result.
    
    Input Parameter:
      p_pac_id     - ActorId varchar2(10) usually 'SYSTEM'.
      p_boh_id     - BillingOutputHeaderId (Output Converter attempt id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - Count of overall inserted consolidation rows.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    */
                                                              ;
END pkg_bdetail_info;
/
