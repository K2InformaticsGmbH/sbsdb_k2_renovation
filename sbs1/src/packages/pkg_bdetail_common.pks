SET DEFINE OFF;

CREATE OR REPLACE PACKAGE sbs1_admin.pkg_bdetail_common
IS
    /*<>
    Common routines for SBS input and output converters.

    MODIFICATION HISTORY (for details see VSS repository)
    Person    Date        Comments
    SO        06.06.2001  Created from earlier versions (SBS phase 4)
    001AA     01.12.2003  SP_INSERT_HIHEADER moved to PKG_MEC
    002SO     02.12.2003  SP_IS_NUMERIC: returns 0 now for FALSE
    003SO     02.12.2003  Add SP_GET_NEXT_PAC_SEQ
    004SO     02.12.2003  SP_GET_NEXT_PAC_SEQ returns formatted sequence with leading zeroes now
    005SO     02.12.2003  SP_GET_NEXT_PAC_SEQ improved
    006AA     22.12.2003  Added overloaded prodecures for SP_INSERT_BIHEADER & SP_INSERT_BOHEADER
    007AA     27.01.2004  Check for null values in function SP_IS_NUMERIC
    008AH     12.08.2004  Fetch new BOHEADER ID
    009SO     30.05.2005  Add SP_UPDATE_DLS_DATES
    010SO     19.07.2005  Change sunday day numbering value to 7 (corresponding to european numbering)
    011SO     09.10.2006  Add Types for MBBulk processing
    012SO     13.09.2007  Add Types for STAN (St.Anton) processing
    013DA     25.11.2009  tSrcType enumeration extended with 8 new source types for MEC_IC CSV parser
    013SO     25.01.2008  Exclude SIS Access Procedures from SP_COMPILE_ALL
    014SO     08.03.2009  Add procedure SP_UPDATE_BOHEADER
    015SO     19.03.2009  Correct return values in SP_UPDATE_BOHEADER_xxxx
    016SO     23.03.2009  Use autonomous transaction for insert of BIHEADER and BOHEADER
    017SO     23.03.2009  Clip warning messages to 2000 characters
    018SO     24.03.2009  Revoke autonomous transaction
    019DA     29.06.2009  Truncate warning string to 4000 characters
    020SO     27.10.2009  Implement isTimeForMapping, isTimeForPacking
    021SO     27.10.2009  Generate missing Unique Key in InsertBiHeader, InsertBoHeader
    022SO     27.10.2009  Treat spaces as FALSE
    023SO     27.10.2009  Implement getTypeForMapping, getTypeForPacking
    024SO     31.10.2009  Remove SrcType para for new MEC, evaluate from Mapping Table
    025SO     31.10.2009  Add Thread Id parameter for new MEC
    026SO     02.10.2009  Change RetrurnStatus to OUT for Insert Header methods
    027SO     02.10.2009  Implement getSrcTypeForMapping
    028SO     02.10.2009  Implement getSrcTypeForBiHeader
    029SO     05.10.2009  Map SourceType to MappingID for Xpioc Header insert
    030SO     06.10.2009  Name current procedure for Mec 1.2.x to SP_INSERT_BIHEADER_MEC
    031SO     09.10.2009  Use previous implementation in PKG_BDETAIL_COMMON for old signatures
    032SO     14.12.2011  Remove schema qualifier "S B S 0 ."
    033SO     21.07.2016  Remove SP_COMPILE_ALL
    034SO     07.12.2016  Correct bad formula for DLS dates in leap years
    000SO     13.02.2019  HASH:C0BA2B613C83B121D789DAC654B974AB pkg_bdetail_common.pkb
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Return IOT for a given
              - Telecom Operator Contract,
              - direction ('ORIG','TERM'),
              - transport medium ('SMS','MMS'), and
              - message size.
       ---------------------------------------------------------------------- */

    FUNCTION contract_iot_chf (
        p_con_id                                IN VARCHAR2,
        p_iwdid                                 IN coniot.ciot_iwdid%TYPE,
        p_trctid                                IN coniot.ciot_trctid%TYPE,
        p_date                                  IN DATE DEFAULT NULL,
        p_msgsize                               IN coniote.ciote_msgsize_max%TYPE DEFAULT 0)
        RETURN coniote.ciote_price%TYPE /*<>
    Return IOT (Inter-Operator-Tariff = Interworking Price) for a given
          - Telecom Operator Contract,
          - direction ('ORIG','TERM'),
          - transport medium ('SMS','MMS'), and
          - message size.

    Input Parameter:
      p_con_id  - Telecom Operator ContractId varchar2(10).
      p_iwdid   - InterworkingDirectionId ('ORIG','TERM').
      p_trctid  - TransportCarrierTypeId ('SMS','MMS').
      p_date    - EventDate (DATE).
      p_msgsize - MessageSize (Bytes, number(8)).

    Return Parameter:
      IOT in currency as defined or NULL if not found.

    Restrictions:
      - none.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    04.10.2007  Created
    002SO    12.11.2016  Do not depend on CIOTE_MSGSIZE_MIN any more
    */
                                       ;

    /* =========================================================================
       Gets end date of contract in last month.
       ---------------------------------------------------------------------- */

    FUNCTION contractperiodend (p_con_dateend IN DATE)
        RETURN DATE /*<>
    Gets end date (exclusive) of contract in last month. If input lies in last month,
    return input. If input is NULL then return the first second of current month.
    If input is earlier or equal than the start of last month, then return NULL.

    Input Parameter:
      p_con_dateend - Optional EndDate of the contract.

    Return Parameter:
      EndDate of contract framed to last month.
      NULL if contract does not live in last month.

    Restrictions:
      - none.
    */
                   ;

    /* =========================================================================
       Gets start date of contract in last month.
       ---------------------------------------------------------------------- */

    FUNCTION contractperiodstart (p_con_datestart IN DATE)
        RETURN DATE /*<>
    Gets start date (inclusive) of contract in last month. If input lies in last month,
    return input. If input is NULL then return the first second of last month.
    If input is later or equal than the start of this month, then return NULL.

    Input Parameter:
      p_con_datestart - optional StartDate of the contract.

    Return Parameter:
      StartDate of contract framed to last month.
      NULL if contract does not live in last month.

    Restrictions:
      - none.
    */
                   ;

    FUNCTION generatebase36kpikey
        RETURN VARCHAR2 /*<>
    Return the next KPI sequence number (bdkpi_seq.NEXTVAL) in base36 format.

    Return Parameter:
      Next KpiId in base36

    Restrictions:
      - none.
    */
                       ;

    /* =========================================================================
       Utility function to be used in SQL.
       ---------------------------------------------------------------------- */

    FUNCTION gettypeformapping (p_bih_mapid IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    FUNCTION gettypeforpacking (p_bih_pacid IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_bih_pacid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    FUNCTION getufihfield (
        p_token                                 IN VARCHAR2,
        p_cdrtext                               IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Utility function to be used in SQL.
    NOTE: duplicated in Package PKG_MEC_HB on SBS0 Database

    Get an UFIH field value from a single CDR text string.

    Input Parameter:
      p_token   - UFIH attribute name to be extracted.
      p_cdrtext - UFIH CDR text from which to extract an attribute value.

    Return Parameter:
      UFIH field value.

    Restrictions:
      - does not necessarily cover all possible attribute names in correct format.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    12.09.2007 Creates based on UFIH Knowledge Base v1.7
    002SO    12.09.2007 Remove @ in Date fields
    */
                       ;

    FUNCTION istimeformapping (p_bih_mapid IN VARCHAR2)
        RETURN INTEGER /*<>
    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                      ;

    FUNCTION istimeforpacking (p_bih_pacid IN VARCHAR2)
        RETURN INTEGER /*<>
    TODO.

    Input Parameter:
      p_bih_pacid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                      ;

    FUNCTION normalizedmsisdn (msisdn IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return MSISDN in international format or as-is for short numbers or hex strings.
    DEPRECATED
    Redundant version in SBSx_ADMIN.normalizedmsisdn()
    More elaborate version with sanity cleanup can be found in
    SBS0_ADMIN.PKG_MEC_HB.NormalizeAddress()

    Input Parameter:
      msisdn - address string of a mobile of application subscription.

    Return Parameter:
      international format of address, if possible. otherwise input

    Restrictions:
      - deprected, advanced version in SBS0_ADMIN.PKG_MEC_HB

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    23.04.2013  remove Msisdn mapping 077.. -> 432..
    002SO    14.04.2016  Accept 9 digit MSISDNs without national/international prefi
    */
                       ;

    FUNCTION simplehash (s IN VARCHAR2)
        RETURN NUMBER /*<>
    Calculates simple numerical hash for eMail-Adresses.
    Used in SBS0 (with 41 - prefix) as a MSISDN like placeholder for B-Numbers.
    Provided here on SBS1 for analytics with the same semantics.

    Input Parameter:
      s - input string to be hashed (e.g. eMail Address).

    Return Parameter:
      Hash (integer)

    Restrictions:
      - none.
    */
                     ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_warning ( --002AH
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_usererrcode                         IN VARCHAR2 DEFAULT NULL,
        p_w_bihid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN VARCHAR2 DEFAULT NULL) /*<>
    TODO.

    Input Parameter:
      p_w_applic      - TODO.
      p_w_procedure   - TODO.
      p_w_topic       - TODO.
      p_w_message     - TODO.
      p_w_usererrcode - TODO.
      p_w_bihid       - TODO.
      p_w_bohid       - TODO.
      p_w_bdid        - TODO.
      p_w_shortid     - TODO.

    Restrictions:
      - TODO.
    */
                                                                         ;

    /* =========================================================================
       Update begin- and end-dates of daylight saving time (summer-time) in
       table SYSPARAMETERS.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_next_pac_seq (
        p_pacid                                 IN     VARCHAR2,
        p_nextsequence                             OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errormsg                                 OUT VARCHAR2,
        p_returnstatus                          IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_pacid        - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_nextsequence - TODO.
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    PROCEDURE sp_insert_biheader (
        p_bih_id                                IN     VARCHAR2,
        p_bih_srctype                           IN     VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_status                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_bih_id       - TODO.
      p_bih_srctype  - TODO.
      p_bih_demo     - TODO.
      p_bih_fileseq  - TODO.
      p_bih_filename - TODO.
      p_bih_filedate - TODO.
      p_bih_mapid    - TODO.
      p_status       - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ; --031SO

    PROCEDURE sp_insert_biheader (
        p_bih_id                                IN     VARCHAR2,
        p_bih_srctype                           IN     VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_bih_id       - TODO.
      p_bih_srctype  - TODO.
      p_bih_demo     - TODO.
      p_bih_fileseq  - TODO.
      p_bih_filename - TODO.
      p_bih_filedate - TODO.
      p_bih_mapid    - TODO.
      p_appname      - TODO.
      p_appver       - TODO.
      p_jobid        - TODO.
      p_hostname     - TODO.
      p_status       - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ; --031SO

    PROCEDURE sp_insert_biheader_mec (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2, --025SO
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER --026SO
                                                             ) /*<>
    TODO.

    Input Parameter:
      p_bih_id       - TODO.
      p_bih_demo     - TODO.
      p_bih_fileseq  - TODO.
      p_bih_filename - TODO.
      p_bih_filedate - TODO.
      p_bih_mapid    - TODO.
      p_appname      - TODO.
      p_appver       - TODO.
      p_thread       - TODO.
      p_jobid        - TODO.
      p_hostname     - TODO.
      p_status       - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ; --030SO

    PROCEDURE sp_insert_boheader (
        p_boh_id                                IN     VARCHAR2,
        p_boh_demo                              IN     NUMBER,
        p_boh_fileseq                           IN     NUMBER,
        p_boh_filename                          IN     VARCHAR2,
        p_boh_packid                            IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_boh_id       - TODO.
      p_boh_demo     - TODO.
      p_boh_fileseq  - TODO.
      p_boh_filename - TODO.
      p_boh_packid   - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ; --031SO

    PROCEDURE sp_insert_boheader (
        p_boh_id                                IN     VARCHAR2,
        p_boh_demo                              IN     NUMBER,
        p_boh_fileseq                           IN     NUMBER,
        p_boh_filename                          IN     VARCHAR2,
        p_boh_packid                            IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_boh_id       - TODO.
      p_boh_demo     - TODO.
      p_boh_fileseq  - TODO.
      p_boh_filename - TODO.
      p_boh_packid   - TODO.
      p_appname      - TODO.
      p_appver       - TODO.
      p_jobid        - TODO.
      p_hostname     - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ; --031SO

    PROCEDURE sp_insert_boheader_mec (
        p_boh_id                                IN OUT VARCHAR2,
        p_boh_demo                              IN     NUMBER,
        p_boh_fileseq                           IN     NUMBER,
        p_boh_filename                          IN     VARCHAR2,
        p_boh_packid                            IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2, --025SO
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER --026SO
                                                             ) /*<>
    TODO.

    Input Parameter:
      p_boh_id       - TODO.
      p_boh_demo     - TODO.
      p_boh_fileseq  - TODO.
      p_boh_filename - TODO.
      p_boh_packid   - TODO.
      p_appname      - TODO.
      p_appver       - TODO.
      p_thread       - TODO.
      p_jobid        - TODO.
      p_hostname     - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ; --030SO

    PROCEDURE sp_insert_warning (
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_bihid                               IN VARCHAR2,
        p_w_bohid                               IN VARCHAR2,
        p_w_bdid                                IN VARCHAR2,
        p_w_shortid                             IN VARCHAR2) /*<>
    Log a warning to the log table (as an AUTONOMOUS TRANSACTION).

    Input Parameter:
      p_w_applic    - ApplicationCode varchar2(30).
      p_w_procedure - ProcedureName varchar2(30).
      p_w_topic     - Classification of the Error.
      p_w_message   - Error Message.
      p_w_bihid     - InputHeaderId (HIH_ID or BIH_ID).
      p_w_bohid     - OutputHeaderId (optional).
      p_w_bdid      - BillingDetailId varchar2(10).
      p_w_shortid   - ShortNumber (optional).

    Restrictions:
      - field sizes see WARNING table.
    */
                                                            ;

    PROCEDURE sp_insert_warning (
        p_w_applic                              IN     VARCHAR2,
        p_w_procedure                           IN     VARCHAR2,
        p_w_topic                               IN     VARCHAR2,
        p_w_message                             IN     VARCHAR2,
        p_w_bihid                               IN     VARCHAR2,
        p_w_bohid                               IN     VARCHAR2,
        p_w_bdid                                IN     VARCHAR2,
        p_w_shortid                             IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_w_applic    - TODO.
      p_w_procedure - TODO.
      p_w_topic     - TODO.
      p_w_message   - TODO.
      p_w_bihid     - TODO.
      p_w_bohid     - TODO.
      p_w_bdid      - TODO.
      p_w_shortid   - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    PROCEDURE sp_update_dls_dates (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
    Update the daylight saving table for the current year.

    Input Parameter:
      p_pact_id    - ActorId varchar2(10), usually 'SYSTEM'.
      p_boh_id     - BoheaderId (Output Converter Task Id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - 1 for success, 0 for error.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - to be called before daylight saving switch in April.
    */
                                                              ;
END pkg_bdetail_common;
/