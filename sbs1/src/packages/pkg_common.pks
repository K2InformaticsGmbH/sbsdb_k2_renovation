CREATE OR REPLACE PACKAGE sbs1_admin.pkg_common
IS
    /*<>
    Purpose: Common routines for SBS handlers and converters.

    Common to all SBS instances.

    The functionality includes:

      TODO.

    MODIFICATION HISTORY
    Person    Date        Comments
    001SO     14.01.2010  Created as subset of PKG_BDETAIL_COMMON
    002SO     15.01.2010  Move error id to the end in insert warning
    003SO     15.01.2010  Rename SP_COMPILE_ALL to COMPILE_ALL
    004SO     25.01.2010  Add Error handling to COMPILE_ALL (in PKG_COMMON only)
    005SO     25.01.2010  Add Default Description for hard errors
    006SO     25.01.2010  Move CutFirstItem to PKG_COMMON
    007SO     25.01.2010  Move getHeaderField / getRequiredHeaderField to PKG_COMMON
    008SO     26.01.2010  Implement isTimeForProcess (mapping/packing)
    009SO     01.02.2010  Implement isDoneInPeriod
    010SO     01.02.2010  Implement clearance window for process execution (suspended seconds before period end)
    011SO     02.03.2010  Remove DLS stuff
    012SO     28.03.2010  Add Statistics workflow abort exception but move them to PKG_COMMON_PACKING later
    013SO     31.03.2010  Add SP_DB_SLEEP (moved from PKG_BDETAIL_COMMON)
    014SO     12.04.2010  Correct bug in isTimeForProcess
    015SO     13.04.2010  Implement getDatesForPeriod
    016SO     28.04.2010  Remove Oracle 11 option
    017SO     28.04.2010  Correct getDatesForPeriod
    018SO     04.05.2010  Go back to Oracle 11 option (revert 016SO)
    019SO     28.09.2010  Bugfix in packing scheduler
    020SO     04.05.2012  Limit Compile_all to code owner and current user
    021SO     01.10.2013  Add source type M2M
    022SO     15.04.2014  Support up to 16 KB records in CutFirstItem
    023SO     19.08.2015  Add source type SMSN (new OMN SMSC)
    024SO     21.07.2016  Replace DBA_OBJECTS with ALL_OBJECTS
    000SO     13.02.2019  HASH:1F841B50A08E9C12650C4D2902B4476A pkg_common.pkb
    */

    /* =========================================================================
      Source Type
      ---------------------------------------------------------------------- */

    TYPE tsrctype IS RECORD
    (
        ccndc srctype.srct_id%TYPE := 'CCNDC', --013DA
        isrv srctype.srct_id%TYPE := 'ISRV',
        m2m srctype.srct_id%TYPE := 'M2M', --021SO
        mbs srctype.srct_id%TYPE := 'MBS',
        mca_aud srctype.srct_id%TYPE := 'MCA_AUD', --013DA
        mca_img srctype.srct_id%TYPE := 'MCA_IMG', --013DA
        mca_mm1 srctype.srct_id%TYPE := 'MCA_MM1', --013DA
        mca_mm3 srctype.srct_id%TYPE := 'MCA_MM3', --013DA
        mca_sti srctype.srct_id%TYPE := 'MCA_STI', --013DA
        mca_vid srctype.srct_id%TYPE := 'MCA_VID', --013DA
        mccmnc srctype.srct_id%TYPE := 'MCCMNC', --013DA
        mmsb srctype.srct_id%TYPE := 'MMSB', --011SO
        mmsc srctype.srct_id%TYPE := 'MMSC',
        msc srctype.srct_id%TYPE := 'MSC',
        oper srctype.srct_id%TYPE := 'OPER', --013DA: OPER may be removed if checked
        ota srctype.srct_id%TYPE := 'OTA',
        pos srctype.srct_id%TYPE := 'POS',
        smsc srctype.srct_id%TYPE := 'SMSC',
        smsn srctype.srct_id%TYPE := 'SMSN', --023SO
        stan srctype.srct_id%TYPE := 'STAN', --012SO
        vasp srctype.srct_id%TYPE := 'VASP'
    );

    excp_inconvenient_time                  EXCEPTION;
    PRAGMA EXCEPTION_INIT (excp_inconvenient_time,
                           -01003);
    eno_inconvenient_time          CONSTANT PLS_INTEGER := 1003;
    edesc_inconvenient_time        CONSTANT VARCHAR2 (255) := 'The desired operation cannot be executed at this time. Try later.';

    excp_missing_header_fld                 EXCEPTION;
    PRAGMA EXCEPTION_INIT (excp_missing_header_fld,
                           -01005);
    eno_missing_header_fld         CONSTANT PLS_INTEGER := 1005;
    edesc_missing_header_fld       CONSTANT VARCHAR2 (255) := 'Processing header field not found';

    excp_rdy_err_header_found               EXCEPTION;
    PRAGMA EXCEPTION_INIT (excp_rdy_err_header_found,
                           -01001);
    eno_rdy_err_header_found       CONSTANT PLS_INTEGER := 1001;
    edesc_rdy_err_header_found     CONSTANT VARCHAR2 (255) := 'A File with this name and creation date already processed earlier has Ready/Error state.';

    excp_rdy_err_many_retries               EXCEPTION;
    PRAGMA EXCEPTION_INIT (excp_rdy_err_many_retries,
                           -01002);
    eno_rdy_err_many_retries       CONSTANT PLS_INTEGER := 1002;
    edesc_rdy_err_many_retries     CONSTANT VARCHAR2 (255)
        := 'A File with this name had too many processing failures. Change the file or rename one header file name to try one more time with file from error directory.' ;

    excp_reccount_mismatch                  EXCEPTION;
    PRAGMA EXCEPTION_INIT (excp_reccount_mismatch,
                           -01004);
    eno_reccount_mismatch          CONSTANT PLS_INTEGER := 1004;
    edesc_reccount_mismatch        CONSTANT VARCHAR2 (255) := 'The database detail record count does not match the record counter evaluated in the driver';

    return_status_failure          CONSTANT PLS_INTEGER := 0;
    return_status_ok               CONSTANT PLS_INTEGER := 1;
    return_status_suspended        CONSTANT PLS_INTEGER := 2;

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION cutfirstitem (
        p_itemlist                              IN OUT VARCHAR2,
        p_separator                             IN     VARCHAR2,
        p_trimitem                              IN     BOOLEAN := TRUE)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_itemlist  - TODO.
      p_separator - TODO.
      p_trimitem  - TODO.

    Output Parameter:
      p_itemlist - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION duration (p_time_diff IN NUMBER)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_time_diff - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION generateuniquekey (identifier IN CHAR)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      identifier - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getharderrordesc
        RETURN VARCHAR2 /*<>
    TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getrequiredheaderfield (
        p_headerdata                            IN VARCHAR2,
        p_token                                 IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_headerdata - TODO.
      p_token      - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION is_alphanumeric (p_inputvalue IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_inputvalue - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION is_integer (
        p_inputvalue                            IN VARCHAR2,
        p_minvalue                              IN NUMBER DEFAULT NULL,
        p_maxvalue                              IN NUMBER DEFAULT NULL)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_inputvalue - TODO.
      p_minvalue   - TODO.
      p_maxvalue   - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION is_numeric (
        p_inputvalue                            IN VARCHAR2,
        p_minvalue                              IN NUMBER DEFAULT NULL,
        p_maxvalue                              IN NUMBER DEFAULT NULL)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_inputvalue - TODO.
      p_minvalue   - TODO.
      p_maxvalue   - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION isdoneinperiod (
        p_period_id                             IN VARCHAR2,
        p_datedone                              IN DATE)
        RETURN BOOLEAN /*<>
    TODO.

    Input Parameter:
      p_period_id - TODO.
      p_datedone  - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    */
                      ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION istimeforprocess (
        p_period_id                             IN VARCHAR2,
        p_startday                              IN INTEGER,
        p_starthour                             IN INTEGER,
        p_startminute                           IN INTEGER,
        p_endclearance                          IN INTEGER, --010SO
        p_datedone                              IN DATE)
        RETURN BOOLEAN /*<>
    TODO.

    Input Parameter:
      p_period_id    - TODO.
      p_startday     - TODO.
      p_starthour    - TODO.
      p_startminute  - TODO.
      p_endclearance - TODO.
      p_datedone     - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                      ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION sp_is_numeric (p_inputvalue IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_inputvalue - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION speed (
        bih_reccount                            IN NUMBER,
        bih_start                               IN DATE,
        bih_end                                 IN DATE)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      bih_reccount - TODO.
      bih_start    - TODO.
      bih_end      - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE compile_all /*<>
    TODO.

    Restrictions:
      - TODO.
    */
                         ; --003SO

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE getdatesforperiod (
        p_period_id                             IN     VARCHAR2,
        p_period_start                             OUT DATE,
        p_period_end                               OUT DATE) /*<>
    TODO.

    Input Parameter:
      p_period_id - TODO.

    Output Parameter:
      p_period_start - TODO.
      p_period_end   - TODO.


    Restrictions:
      - TODO.
    */
                                                            ; --015SO

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_warning ( --002AH
        p_w_applic                              IN VARCHAR2,
        p_w_procedure                           IN VARCHAR2,
        p_w_topic                               IN VARCHAR2,
        p_w_message                             IN VARCHAR2,
        p_w_bihid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN VARCHAR2 DEFAULT NULL,
        p_w_usererrcode                         IN VARCHAR2 DEFAULT NULL --002SO
                                                                        ) /*<>
    TODO.

    Input Parameter:
      p_w_applic      - TODO.
      p_w_procedure   - TODO.
      p_w_topic       - TODO.
      p_w_message     - TODO.
      p_w_bihid       - TODO.
      p_w_bohid       - TODO.
      p_w_bdid        - TODO.
      p_w_shortid     - TODO.
      p_w_usererrcode - TODO.

    Restrictions:
      - TODO.
    */
                                                                         ;

    /* =========================================================================
       Log event to LOG_DEBUG table.
       ---------------------------------------------------------------------- */

    PROCEDURE l (
        logline                                 IN VARCHAR2,
        hint                                    IN VARCHAR2 DEFAULT NULL) /*<>
    Log event to LOG_DEBUG table.

    Input Parameter:
      logline - TODO.
      hint    - TODO.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    -------------------  ------------------------------------------
    001SO    11.10.2006  Adapted from earlier version. File insert added
    002SO    11.10.2006  Remove logging to file system
    */
                                                                         ;

    /* =========================================================================
       Log event to LOG_DEBUG table.
       ---------------------------------------------------------------------- */

    PROCEDURE lb (
        logline                                 IN VARCHAR2,
        hint                                    IN BOOLEAN) /*<>
    Log event to LOG_DEBUG table.

    Input Parameter:
      logline - TODO.
      hint    - TODO.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    -------------------  ------------------------------------------
    001SO    11.10.2006  Adapted from earlier version. File insert added
    002SO    11.10.2006  Remove logging to file system
    */
                                                           ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_db_sleep (
        p_pac_id                                IN     VARCHAR2,
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<> --013SO
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

    PROCEDURE sp_insert_warning (
        p_w_applic                              IN     VARCHAR2,
        p_w_procedure                           IN     VARCHAR2,
        p_w_topic                               IN     VARCHAR2,
        p_w_message                             IN     VARCHAR2,
        p_w_bihid                               IN     VARCHAR2 DEFAULT NULL,
        p_w_bohid                               IN     VARCHAR2 DEFAULT NULL,
        p_w_bdid                                IN     VARCHAR2 DEFAULT NULL,
        p_w_shortid                             IN     VARCHAR2 DEFAULT NULL,
        p_w_usererrcode                         IN     VARCHAR2 DEFAULT NULL, --002SO
        p_errorcode                                OUT NUMBER,
        p_errormsg                                 OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      p_w_applic      - TODO.
      p_w_procedure   - TODO.
      p_w_topic       - TODO.
      p_w_message     - TODO.
      p_w_bihid       - TODO.
      p_w_bohid       - TODO.
      p_w_bdid        - TODO.
      p_w_shortid     - TODO.
      p_w_usererrcode - TODO.


    Output Parameter:
      p_errorcode    - TODO.
      p_errormsg     - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;
END pkg_common;
/