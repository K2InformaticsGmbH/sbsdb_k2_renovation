CREATE OR REPLACE PACKAGE sbs1_admin.pkg_mec_ic_csv
IS
    /*<>
    Message Event Consolidation Input Converter.
    Putting CSV-Data into SBS1.

    MODIFICATION HISTORY
    Person       Date        Comments
    001SO        08.01.2010  Created based on module used for ASCII0 before:
    075SO        02.11.2009  Implement SP_INSERT_HEADER by calling PKG_BDETAIL_COMMON
    076SO        02.11.2009  Evaluate SrcType from Mapping and rename inputParameter to MapTypeId
    077SO        03.11.2009  Remove correction of MM4 submit timestamp done in 039SO
    078DA        13.11.2009  Return p_ReturnStatus for SP_INSERT_MEC
    079DA        24.11.2009  New procedure SP_INSERT_CSV created
    080DA        25.11.2009  New (internal) procedures INSERT_CSV_CCNDC and INSERT_CSV_MCCMNC created
    081DA        25.11.2009  New procedure SP_UPDATE_HEADER with generic interface created
    002SO        12.01.2010  Create new package using only new bookeeping concept
    003SO        13.01.2010  Use latest version of InsertBiHeader from common package
    004SO        14.01.2009  Delete Operator Number Range entries after successful header insert
    005SO        14.01.2009  Treat all exceptions as hard errors and log details
    006SO        14.01.2009  Exclude Swisscom MSCs and HLRs from import for CCNDC
    007SO        14.01.2009  Abandon PKG_BDETAIL_COMMON and use PKG_COMMON and PKG_BIHEADER instead
    008SO        15.01.2010  Move error id to the end in insert warning
    009SO        18.01.2010  Invoke renamed common packages
    010SO        18.01.2010  Add (yet unused) source type parameter to internal record interface
    011SO        18.01.2010  Add (yet unused) record version to internal record interface
    012SO        18.01.2010  Add parameter p_DataHeader to SP_UPDATE_HEADER
    013DA        21.01.2010  Convert varchar dates to valid date format in SP_UPDATE_HEADER
    014SO        25.01.2010  Use standardized hardErrorMessage
    015SO        25.01.2010  Move PKG_COMMON.CutFirstItem to PKG_COMMON
    016SO        26.01.2010  Set date done in Mapping table for tracking purposes
    017SO        22.04.2010  Remove Filtering of Swisscom Number Ranges
    018SO        22.04.2010  Limit Operator Code input to 20 characters
    019SO        06.05.2010  Clear the ALL_ tables upon receipt of the first batch
    020SO        14.12.2011  Remove schema qualifier "S B S 0 ."
    021SO        14.04.2016  Ignore non-numeric OpKeys
    000SO        13.02.2019  HASH:8F5A71623367C599EB9D60BB585C1D00 pkg_mec_ic_csv.pkb
    */

    TYPE arrrecnr IS TABLE OF NUMBER (8)
        INDEX BY PLS_INTEGER;

    TYPE arrrecdata IS TABLE OF VARCHAR2 (4000)
        INDEX BY PLS_INTEGER;

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
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

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

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
END pkg_mec_ic_csv;
/