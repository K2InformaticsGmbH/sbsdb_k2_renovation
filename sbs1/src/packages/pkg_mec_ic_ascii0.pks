CREATE OR REPLACE PACKAGE sbs1_admin.pkg_mec_ic_ascii0
IS
    /*<>
    Message Event Consolidation Input Converter
    Putting ASCII-Data from MEC Handler into SBS1
    Old interface solution with bookkeeping from DB (RecCount, DateFc, DateLc)

    MODIFICATION HISTORY
    Person       Date        Comments
    001SO        25.11.2003  Moved several procedures here from PKG_MEC
    002AA        04.12.2003  Added SP_INSERT_MEC, SP_UPDATE_BIHEADER_MEC and CutFirstItem procedures/functions
    003AA        19.12.2003  Using newly added Type and its declarations for Billing details tables (bdetail, bdetail1, ...)
    004AA        07.01.2004  Added Price Model Version Id field to the MSC and MMSC ascii0 formats, extracted and stored in corresponding tables, bdetail4 and bdetail6 tables
    005AA        07.01.2004  Updated SP_UPDATE_BIHEADER_MEC to set the Mapping State and BiHeader details separately for each BDetail table depending on the Source Type
    006AA(016SO) 09.01.2004  Adding Transport cost calculation for MMSC CDRs (TransportCost and TransportCount added for MMSC)
    007AA        09.01.2004  Added Interworking Contract Id field to the MSC ascii0 formats, extracted and stored in corresponding tables, bdetail6 tables (VER.1.0.3)
    008AA(020AA) 09.01.2004  Added new fields to the MMSC input interface stored procedure and Ascii0 format (MM7LinkedID, PrepaidFreeText, PromotionPlan, TariffClass, RoamingInfo, DestinationImsi)
    009AA        19.01.2004  Added INSERT_MEC_MBS stored procedure for importing Mbs Ascii0 data into transaction table
    010AA        20.01.2004  Added INSERT_MEC_OTA stored procedure for importing OTA Ascii0 data into transaction table
    011AA        21.01.2004  Added INSERT_MEC_SMSC stored procedure for importing SMSC Ascii0 data into transaction table
    012AA        29.01.2004  Added CdrTypeId to OTA and SMSC imports, Added BD_IW and BD_INT to Smsc insert
    013AA        30.01.2004  Update the mapping state in the Bdetail2 table along with Bdetail1 (SMSC source type)
    014SO        25.02.2004  Correcting bug in iServer ascii parsing
    015SO        26.02.2004  Adding error handling in SP_INSERT_MEC
    016SO        01.03.2004  Reassigning the schedule flags is unnecessary 'S' should be the only possible value in ASCII0 file
    017SO        01.03.2004  Inserting SmsTariff from SMSC ASCII0
    018SO        01.03.2004  Inserting analysis fields into BDETAIL for iServer
    019SO        01.03.2004  Inserting SmsTariff from MSC ASCII0
    020SO        01.03.2004  Insert oCdrInfo.ContractSubType from OTA/ISRV/MBS ASCII0 (to be consistent with iServer and MBS)
    021SO        01.04.2004  Add TopStop check/update for Content Services
    022SO        05.04.2004  Add SP_DELETE_BDETAIL_MEC
    023SO        11.05.2004  Hinting in SP_DELETE_BDETAIL_MEC
    024AA        28.05.2004  Added insert of new MMSC version of Ascii0 (cAscii0VersionMmsc_01_00_04)
    025AA        18.06.2004  Added DateTime timestamp member to the MEC Structure
    026SO        04.07.244   Change max Length of MMS RoamingInfo Field from 10 to 20
    027SO        04.07.2004  Add RecipIndex to MMSC interface and to MEC Structure
    028SO        05.07.2004  Replace RoamingZone by RoamingZone1 and add RoamingZone2
    029SO        06.07.2004  Rename fileds in BDETAIL6:  BD_AMOUNTPV to BD_RETSHAREPV and BD_AMOUNTMO to BD_RETSHAREMO
    030SO        06.07.2004  Rename MEC structure var CdrBilling to CdrBilled
    031SO        07.07.2004  Support for SMSC ASCII0 version cAscii0VersionSmsc_01_00_02 (MERGED IN)
    032SO        19.08.2004  Making oCdrInfo.TransportCost numeric, removing "to_number("
    033SO        28.08.2004  Removing AAA TopStop Update from MEC_IC (now done in MEC Handler)
    034SO        31.08.2004  Schedule Revenue Assurance Analysis for all files input by MEC_IC
    035SO        31.08.2004  Merge UPDATE_BIHEADER statements where possible
    036AA        01.09.2004  Added INSERT_MEC_POS and updated related stored procedures
    037SO        03.09.2004  Replacing all references PKG_MEC to PKG_MEC_HB
    038SO        27.09.2004  Schedule MMS Sync output
    039SO        25.11.2004  Correct Submit Timestamp for MMS MM4 Output CDRs (take from  originating record)
    040AA        13.12.2004  Update the ascii0 parsing for new versions of ISRV, MBS, OTA
    041SO        10.01.2005  Change in SQL for Submit Timestamp Correction: consider State M in current file
    042SO        10.01.2005  Additionally correct Submit Timestamp for MMSRrecords with foreign IMSI (Legacy delivery)
    043SO        30.05.2005  Correct and more performant evaluation of record count / success count (add records from BDETAIL2)
    044SO        15.08.2006  Introduce OrigSubmitTime and populate for Postpaid SMS when time shifted. Use cAscii0VersionMsc_01_00_04
    045SO        01.10.2006  Format Size increases for Karjala 2 MB billing
    046SO        07.10.2006  Additional fields for Karjala 2 MB content billing
    047SO        08.10.2006  Add INSERT_MEC_MMSB for input conversion of Message Broker MMS CDRs
    048SO        09.10.2006  Use typed records for MMSC and MMSB input
    049SO        11.10.2006  Add Source Type MMSB to SP_UPDATE_BIHEADER_MEC
    050SO        11.10.2006  Move Header Update after BDETAIL update (shorten waiting time)
    051SO        08.11.2006  Insert BD_CONSTID for iServer IC
    052SO        14.03.2007  Look at total record count before rejecting a file as awhole (ERF)
    053SO        06.09.2007  Rename BD_MTARID to BD_TARID
    054SO        16.09.2007  Add fields BD_ORIGSUBMIT and BD_BILLID to SMSC tables
    055SO        16.09.2007  Get BD_SUBMITTIME for SMSC
    056SO        25.09.2007  Add TransportCount for iServer and 3 transport fields for OTA, calculate TCs
    057SO        30.09.2007  Use TariffId instead of SmsTariffId and MmsTariffId and Ufih instead of Pos
    058SO        17.10.2007  Implement STAN input converter
    059SO        17.01.2008  Populate BD_VSPRCID (VAS Statistics Product Channel ID)
    060SO        21.01.2008  Schedule VAS Statistics Transfer
    061SO        21.01.2008  Schedule mVoting View only if we have Tariff M CDRs
    062SO        26.01.2008  Add OriginalSubmitTime for ISRV input
    063SO        04.02.2008  Add ProductChannel override by service for ISRV
    064SO        11.02.2008  Schedule SMSC for DWH export and MMSC not any more
    065SO        24.05.2008  Allow future CDR timestamps up to 1 day ahead of time (for load tests)
    066SO        20.06.2008  Include BDETAIL2-Timestamps for First/Last Timestamp evaluation
    067AT        27.07.2008  Additional field for VASOL Billing: OnlineCharge
    068SO        02.02.2009  Implement new fields for Cardinal SMSC
    069SO        02.02.2009  Use DGTI also in BDETAIL1 (home routing SMS might go to BDETAIL1 or to BDETAIL2, tbd)
    068SOa       15.01.2009  Extend Lookup for Original Submit Timestamp in MM4Rrecord (Nachtrag)
    069SO        23.04.2009  Extend Remark Field for UFIH (STAN)
    070SO        22.05.2009  Perform SMSC lookup for home routed SMS in BDETAIL1/2 tables
    071SO        02.06.2009  Add SMSC fields OriginatorImsi and PpPser
    072SO        09.06.2009  Suppress creation of SMSC ID for home routed SMS
    073SO        14.09.2009  Populate archive table for SC terminating IW SMS
    074SO        15.09.2009  Correct IW schedule channel (1 instead of 3)
    075SO        02.11.2009  Implement SP_INSERT_HEADER by calling PKG_BDETAIL_COMMON
    076SO        02.11.2009  Evaluate SrcType from Mapping and rename inputParameter to MapTypeId
    077SO        03.11.2009  Remove correction of MM4 submit timestamp done in 039SO
    078DA        13.11.2009  Return p_ReturnStatus for SP_INSERT_MEC
    079DA        25.11.2009  New procedure SP_UPDATE_HEADER with generic interface created
    080SO        12.01.2010  Use new InsertBiHeader in Common package
    081SO        12.01.2010  Remove SP_DELETE_BDETAIL_MEC
    082SO        12.01.2010  Create as new Packege PKG_MEC_IC_ASCII0
    083SO        15.01.2010  Eliminate calls to PKG_BDETAIL_COMMON and use PKG_COMMON and PKG_BIHEADER_COMMON instead
    084SO        15.01.2010  Rename SP_UPDATE_HEADER_MEC to SP_UPDATE_HEADER
    085SO        18.01.2010  Invoke renamed common packages
    086SO        18.01.2010  Remove Demo flag from internal interface and rename parameters like in PKG_MEC_IC_CSV
    087SO        18.01.2010  Use internal error handling like in PKH_MEC_IC_CSV
    088SO        18.01.2010  Remove double checks on p_BdetailTable and rename this parameter to p_DataHeader
    089SO        18.01.2010  Change interface to match completely PKG_MEC_IC_CSV
    090SO        18.01.2010  Parse Header for getting HIH_ID
    091SO        20.01.2010  Define version for ASCII0 format
    092SO        20.01.2010  Use DateTime for DateFc / DateLc (SMSC/MMSC/MMSB only)
    093SO        20.01.2010  Allow failure in product channel evaluation when no contract found
    094DA        21.01.2010  Convert varchar dates to valid date format in SP_UPDATE_HEADER
    095SO        25.01.2010  Use standardized hardErrorMessage
    096SO        25.01.2010  Use standardized exception for record counter mismatch
    096SO        25.01.2010  Move CutFirstItem to PKG_COMMON
    097SO        25.01.2010  Move getHeaderField to PKG_COMMON
    098SO        26.01.2010  Set date done in Mapping table for tracking purposes
    099SO        26.01.2010  Flag rejected CDRs as soft errors, Ignors must not be counted
    100SO        06.04.2010  Remove older Logging statements
    101SO        12.08.2010  Schedule indexing of MMSC CDRs
    102SO        17.01.2011  Suppress registration of new SMSC ID when inbound roaming traffic
    103SO        11.03.2011  Insert BD_GART into BDETAIL table for Spenden-SMS Project
    104SO        11.04.2011  Insert BD_SHOW and BD_CAMPAIGN into BDETAIL table for Televote Project
    105SO        11.09.2011  Insert MSC_ID to SMS IW archive table
    106SO        12.09.2011  Correct SMS IW Archiver Bug (swap A and B-Number for home routed SMS)
    107SO        14.12.2011  Remove schema qualifier "S B S 0 ."
    108SO        06.03.2012  Remove obsolete code for OTA, MBS, MMSB
    109SO        14.03.2012  Remove obsolete code for BDITEM
    110SO        30.05.2012  Add debugging for ascii IC
    111SO        29.01.2013  Extend field BD_MSGID from 20 to 30 Bytes
    112SO        16.10.2013  Implement basic IC for M2M
    113SO        29.08.2014  Add fields BD_DSER and BD_ORIGSCA to BDETAIL1 and BDETAIL2
    114SO        04.09.2014  Add calculated field "generated" to SMSC input converter
    115SO        04.09.2014  Add calculated field "generated" to MMSC input converter
    116SO        05.09.2014  Correct MMSC IC parser
    117SO        07.08.2015  Extend SMSC and M2M IC parser by 2/3 new fields (interworking OpKeys)
    118SO        12.08.2015  Extend SMSC and M2M IC parser by ScaOpKey
    119SO        20.08.2015  Remove insert into BD_PMVID for SMS (column dropped in BDETAIL1)
    120SO        20.08.2015  Clean up CDR structure names
    121SO        21.08.2015  Use record struct instead of local variables
    122SO        21.08.2015  Register SMSCs for home routed SMS now
    123SO        21.08.2015  Remove code for ProductChannelId
    124SO        21.08.2015  Remove code for ProductChannelId
    125SO        26.08.2015  Add RecipImsi for SMSN (home routed incoming SC address)
    126SO        27.08.2015  Add RecipAdr / Npi / Ton for SMSN separately
    127SO        22.09.2015  Enable SMSN source type wherever SMSC is enabled
    128SO        29.09.2015  Add Interworking fields for M2M / SMSC / SMSN (and MSC with OpKeys)
    129SO        29.09.2015  Add BD_MESSAGEREFERENCE to BDETAIL4
    130SO        08.10.2015  Fix SMSN IC and improve logging
    131SO        20.10.2015  Put Mew SMSC Replace-Submit CDRs into BDETAIL1
    132SO        14.12.2015  Add BD_MSISDN_B, BD_NPI_B, BD_TON_B to BDETAIL1 and BDETAIL2 for SMSN
    133SO        14.04.2016  Truncate B-Numbers for NewSMSC CDRs
    134SO        09.12.2016  Remove some support for SMSC (old Acision specialities)
    135SO        09.12.2016  Add Attribute BD_AMOUNTTR for SMSN
    136SO        09.12.2016  Add Attribute BD_ORIG_DCS for SMSN
    137SO        09.12.2016  Add Attribute BD_ORIG_MSG_ID for SMSN
    138SO        01.06.2017  Directly assign OpKey to new SMSC
    139SO        13.07.2017  Add SMSC-CDR-Attributes PaniHeader, OrigImei, DeliverImei
    140SO        12.01.2018  Rename PaniHeader to OrigPaniHeader
    141SO        12.01.2018  Add SMSC-CDR-Attributes DeliverPaniHeader, DeliverMapGti
    142SO        26.02.2018  Implement externally routed SMS/Pager under SMSN
    143SO        26.02.2018  Change counting of inserted CDRs in order to allow CDR cloning for SMS-EXT and PAGER-EXT
    144SO        26.02.2018  Default missing SegmentInformation (in bad external CDRs)
    145SO        14.03.2018  Add BIO attributes to ASCII IC (for RCS)
    146SO        16.11.2018  Add RVA signatures to BDETAIL, BDETAIL1, 2, 4, 6
    147SO        18.11.2018  Add more RVA signature characters (BioReqType, La Handygroup, MoPromotion, Reserve)
    148SO        25.11.2018  Provide TariffId 1:1 for MMS Signatures
    149SO        26.11.2018  Remove insert into VSHEADER
    150SO        30.11.2018  Schedule only needed source types for REVA
    151SO        11.01.2019  008936 REVA SMSN Roaming Signature fix
    152SO        21.01.2019  Fix Error Count for SMSN Records
    153SO        30.01.2019  008958 OrigSmsc Default for M2M
    000SO        13.02.2019  HASH:D031C3717C49AAFB79171588BEE7C95C pkg_mec_ic_ascii0.pkb
    154SO        25.03.2019  008989 RVA SBS Feb 2019 (Patch IMS IP signature to match 008931)
    155SO        10.05.2019  009030 SBS Monatskontrolle April 2019 / Fix REVA signature for dest_net
    156SO        13.06.2019  Add attributes for monitoring (LEGAL) UFIH output
    157SO        18.06.2019  Use G Flag also on DEST for simpler signature filtering
    */

    TYPE arrrecdata IS TABLE OF VARCHAR2 (4000)
        INDEX BY PLS_INTEGER;

    TYPE arrrecnr IS TABLE OF NUMBER (8)
        INDEX BY PLS_INTEGER;

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION ims_lte_cell_id (p_paniheader IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION ims_wifi_mcc (p_paniheader IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION ims_wlan_node_id (p_paniheader IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION is_roaming_pani (p_paniheader IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION opkey_from_gt (msisdn IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      msisdn - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_csv (
        p_bihid                                 IN     VARCHAR2,
        p_batchsize                             IN     INTEGER,
        p_maxage                                IN     NUMBER,
        p_dataheader                            IN     VARCHAR2,
        p_recordnr                              IN     arrrecnr,
        p_recorddata                            IN     arrrecdata,
        p_reccount                              IN OUT NUMBER,
        p_preparseerrcount                      IN OUT NUMBER,
        p_errcount                              IN OUT NUMBER,
        p_datefc                                IN OUT VARCHAR2,
        p_datelc                                IN OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_bihid            - TODO.
      p_batchsize        - TODO.
      p_maxage           - TODO.
      p_dataheader       - TODO.
      p_recordnr         - TODO.
      p_recorddata       - TODO.
      p_reccount         - TODO.
      p_preparseerrcount - TODO.
      p_errcount         - TODO.
      p_datefc           - TODO.
      p_datelc           - TODO.

    Output Parameter:
      p_reccount         - TODO.
      p_preparseerrcount - TODO.
      p_errcount         - TODO.
      p_datefc           - TODO.
      p_datelc           - TODO.
      p_errorcode        - TODO.
      p_errordesc        - TODO.
      p_returnstatus     - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    PROCEDURE sp_insert_header (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
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
      p_bih_id       - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    PROCEDURE sp_update_header (
        p_bihid                                 IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        p_dataheader                            IN     VARCHAR2, -- 012SO
        p_reccount                              IN     NUMBER,
        p_preparseerrcount                      IN     NUMBER,
        p_errcount                              IN     NUMBER,
        p_datefc                                IN     VARCHAR2,
        p_datelc                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_bihid            - TODO.
      p_maxage           - TODO.
      p_dataheader       - TODO.
      p_reccount         - TODO.
      p_preparseerrcount - TODO.
      p_errcount         - TODO.
      p_datefc           - TODO.
      p_datelc           - TODO.

    Output Parameter:
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;
END pkg_mec_ic_ascii0;
/
