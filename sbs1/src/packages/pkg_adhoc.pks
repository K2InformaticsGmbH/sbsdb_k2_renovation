CREATE OR REPLACE PACKAGE sbs1_admin.pkg_adhoc
IS
    /*<>
    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Functions.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION account_name (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Current account name.

    Restrictions:
      - TODO.

    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION as_date (p_date IN DATE)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      p_date - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       Cut out billtext from UFIH CDR.
       ---------------------------------------------------------------------- */

    FUNCTION billtext_in_ufih (s IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Cut out billtext from UFIH CDR.

    Input Parameter:
      s - TODO.

    Return Parameter:
      Billtext from UFIH CDR.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Extract bit at given position (0 based) from bitstring (0 or 1 or NULL
       if bistring is too short).
       ---------------------------------------------------------------------- */

    FUNCTION bitpos (
        p_pos                                   IN NUMBER,
        p_bitstr                                IN VARCHAR2)
        RETURN NUMBER /*<>
    Extract bit at given position (0 based) from bitstring (0 or 1 or NULL
    if bistring is too short).

    Input Parameter:
      p_pos    - TODO.
      p_bitstr - TODO.

    Return Parameter:
      Bit at given position (0 based) from bitstring (0 or 1 or NULL if bistring is too short).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    02.09.2014  Created
    */
                     ;

    /* =========================================================================
       Extract bit at given position (0 based) from integer number.
       ---------------------------------------------------------------------- */

    FUNCTION bitval (
        p_pos                                   IN NUMBER,
        p_number                                IN NUMBER)
        RETURN NUMBER /*<>
    Extract bit at given position (0 based) from integer number.

    Input Parameter:
      p_pos    - TODO.
      p_number - TODO.

    Return Parameter:
      Bit at given position (0 based).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    02.09.2014  Created
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION content_revenue_share (
        p_pricemodelversionid                   IN VARCHAR2,
        p_billrate                              IN NUMBER,
        p_amountcustomer                        IN NUMBER,
        p_prepaid                               IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_pricemodelversionid - TODO.
      p_billrate            - TODO.
      p_amountcustomer      - TODO.
      p_prepaid             - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_acname (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      current account name for contract.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    09.12.2016  Created
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_amount_range (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      Amount range for given contract from current price model version.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_billrates (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      List of colon separated valid bill rates for for given IP contract.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Return IOT for a given
           - Telecom Operator Contract,
           - direction ('ORIG','TERM'),
           - transport medium ('SMS','MMS'), and
           - message size.
       ---------------------------------------------------------------------- */

    FUNCTION contract_iot (
        p_con_id                                IN VARCHAR2,
        p_iwdid                                 IN coniot.ciot_iwdid%TYPE,
        p_trctid                                IN coniot.ciot_trctid%TYPE,
        p_msgsize                               IN coniote.ciote_msgsize_max%TYPE DEFAULT 0)
        RETURN coniote.ciote_price%TYPE /*<>
    Return IOT for a given
       - Telecom Operator Contract,
       - direction ('ORIG','TERM'),
       - transport medium ('SMS','MMS'), and
       - message size.

    Input Parameter:
      p_con_id  - TODO.
      p_iwdid   - TODO.
      p_trctid  - TODO.
      p_msgsize - TODO.

    Return Parameter:
      IOT in currency as defined or NULL if not found.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    04.10.2007  Created
    002SO    12.11.2016  Do not depend on CIOTE_MSGSIZE_MIN any more
    */
                                       ;

    /* =========================================================================
       Return activity status of contract, depending on entity state, start-
       and end date.
       ---------------------------------------------------------------------- */

    FUNCTION contract_is_active (p_con_id IN VARCHAR2)
        RETURN NUMBER /*<>
    Return activity status of contract, depending on entity state, start-
    and end date.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      Activity status of contract.

    Restrictions:
      - ATTENTION: LOGIC IS DUPLICATED IN TRIGGERS               002SO
                      ENPLA_ACCOUNT and
                      ENPLA_CONTRACT.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    27.01.2006  Created
    002SO    01.02.2006  Added code dup warning
    */
                     ;

    /* =========================================================================
       Return activity status of contract, depending on entity state, start-
       and end date
       ---------------------------------------------------------------------- */

    FUNCTION contract_is_active_or_test (p_con_id IN VARCHAR2)
        RETURN NUMBER /*<>
    Return activity status of contract, depending on entity state, start-
    and end date

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      - returns 1 if contract is active (state A and in time frame)
      - returns 1 if contract is active or test and we are before start (considered as test mode).

    Restrictions:
      - ATTENTION: LOGIC IS DUPLICATED IN TRIGGERS               002SO
                      ENPLA_ACCOUNT and
                      ENPLA_CONTRACT.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    30.04.2007  Created
    002SO    18.04.2010  REMOVE S B S 0 schema reference
    */
                     ;

    /* =========================================================================
       Return activity status of contract, depending on entity state, start-
       and end date.
       ---------------------------------------------------------------------- */

    FUNCTION contract_state (p_con_id IN VARCHAR2)
        RETURN NUMBER /*<>
    Return activity status of contract, depending on entity state, start-
    and end date.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      Returns 0 if contract is inactive, out of time frame or suspended
      Returns 1 if contract is active (state A and in time frame)
      Returne 2 if contract is test or we are before start (considered as test mode)
      This mapping corresponds to the SBS instances as defined by MB (1_prod 2=test)

    Restrictions:
      - ATTENTION: LOGIC IS DUPLICATED IN TRIGGERS
                      ENPLA_ACCOUNT and
                      ENPLA_CONTRACT.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    30.04.2007  Created
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_zero_billrates (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      List of colon separated valid bill rates with zero Amount for for given IP contract.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contractcountforaccount (p_ac_id IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Number of "active" accounts belonging to an account.


    Restrictions:
      - Condition: CON_ESID IN ('A','E','T').
    */
                     ;

    /* =========================================================================
       Return activity status of a content service, also depending on contract
       entity state, start- and end date.
       ---------------------------------------------------------------------- */

    FUNCTION cs_is_active (p_cs_id IN VARCHAR2)
        RETURN NUMBER /*<>
    Return activity status of a content service, also depending on contract
    entity state, start- and end date.

    Input Parameter:
      p_cs_id - TODO.

    Return Parameter:
      Activity status of a content service.

    Restrictions:
      - ATTENTION: LOGIC IS DUPLICATED IN TRIGGERS               002SO
                      ENPLA_ACCOUNT and
                      ENPLA_CONTRACT.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    31.04.2007  Created
    */
                     ;

    /* =========================================================================
       Return activity status of a content service, also depending on contract
       entity state, start- and end date.
       ---------------------------------------------------------------------- */

    FUNCTION cs_is_active_or_test (p_cs_id IN VARCHAR2)
        RETURN NUMBER /*<>
    Return activity status of a content service, also depending on contract
    entity state, start- and end date.

    Input Parameter:
      p_cs_id - TODO.

    Return Parameter:
      Activity status of a content service.

    Restrictions:
      - ATTENTION: LOGIC IS DUPLICATED IN TRIGGERS               002SO
                      ENPLA_ACCOUNT and
                      ENPLA_CONTRACT.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    31.04.2007  Created
    002SO    18.04.2010  REMOVE S B S 0 schema reference
    */
                     ;

    /* =========================================================================
       Return Content service code transformation which allows key collation.
       ---------------------------------------------------------------------- */

    FUNCTION cs_service_key (p_cs_service IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_cs_service - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    02.05.2014  Created
    002SO    05.05.2014  Replace ':' with '-'
    */
                       ;

    /* =========================================================================
       Return activity status of contract, depending on entity state,
       start- and end date.
       ---------------------------------------------------------------------- */

    FUNCTION cs_state (p_cs_id IN VARCHAR2)
        RETURN NUMBER /*<>
    Return activity status of contract, depending on entity state,
    start- and end date.

    Input Parameter:
      p_cs_id - TODO.

    Return Parameter:
      Returns 0 if contract is inactive, out of time frame or suspended
      Returns 1 if contract is active (state A and in time frame)
      Returne 2 if contract is test or we are before start (considered as test mode)
      This mapping corresponds to the SBS instances as defined by MB (1_prod 2=test)

    Restriction
      - ATTENTION: LOGIC IS DUPLICATED IN TRIGGERS
                      ENPLA_ACCOUNT and
                      ENPLA_CONTRACT.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    30.04.2007  Created
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION desc_corr (
        p_old_desc                              IN VARCHAR2,
        p_old_count                             IN NUMBER,
        p_count_diff                            IN NUMBER)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_old_desc   - TODO.
      p_old_count  - TODO.
      p_count_diff - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Get hierarchical hash from lines of text containing prefixes.
       ---------------------------------------------------------------------- */

    FUNCTION gethierarchicalhash (p_details IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Get hierarchical hash from lines of text containing prefixes.

    Input Parameter:
      p_details - XXX:A..CrLf
                  XXX:B..CrLf
                  YYY:a..CrLf
                  YYY:b..CrLf
                  YYY:c..CrLf
                  ZZZ:1..CrLf

    Return Parameter:
      XXX:HASH_MD5(XXX section)
      YYY:HASH_MD5(YYY section)
      ZZZ:HASH_MD5(ZZZ section)

      Hash includes sets of whole lines, e.g. "XXX:B..CrLf"

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Used for evaluation of Amount range for given price model.
       ---------------------------------------------------------------------- */

    FUNCTION getpricerange (p_pm_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of Amount range for given price model.

    Input Parameter:
      p_pm_id - TODO.

    Return Parameter:
      Amount range.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Return MD5 HASH of given input parameter.
       ---------------------------------------------------------------------- */

    FUNCTION hash_md5 (var IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return MD5 HASH of given input parameter.

    Input Parameter:
      var - TODO.

    Return Parameter:
      MD5 HASH.

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Used for evaluation of reporting parematers.
       ---------------------------------------------------------------------- */

    FUNCTION job_search_parameter_test (
        p_job_id                                IN VARCHAR2,
        p_par_name                              IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Used for evaluation of reporting parematers.

    Input Parameter:
      p_job_id   - TODO.
      p_par_name - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    002SO    18.04.2010  REMOVE S B S 0 schema reference

    */
                       ;

    /* =========================================================================
       SMS-LA Revenue in microfrancs per CDR.
       ---------------------------------------------------------------------- */

    FUNCTION kpi_sms_la_revenue (p_bihid IN VARCHAR2)
        RETURN NUMBER /*<>
    SMS-LA Revenue in microfrancs per CDR.

    Input Parameter:
      p_bihid - TODO.

    Return Parameter:
      Microfrancs.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    16.09.2014  Created
    */
                     ;

    /* =========================================================================
       Return current account name for large account with givne consolidation
       field.
       ---------------------------------------------------------------------- */

    FUNCTION la_acname (p_consol IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return current account name for large account with givne consolidation
    field.

    Input Parameter:
      p_consol - TODO.

    Return Parameter:
      Account name.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    08.03.2009  Created
    */
                       ;

    /* =========================================================================
       Return true account ID for SMS-LA contract (matching IPC account's ID).
       ---------------------------------------------------------------------- */

    FUNCTION lac_ipc_acid (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return true account ID for SMS-LA contract (matching IPC account's ID).

    Input Parameter:
      v - TODO.

    Return Parameter:
      Account ID.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    16.03.2015  Created
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION local_time (
        p_datetime                              IN DATE,
        p_offset                                IN NUMBER,
        p_local_offset                          IN NUMBER)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      p_datetime     - TODO.
      p_offset       - TODO.
      p_local_offset - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       Return true account ID for MMS-LA contract (matching IPC account's ID).
       ---------------------------------------------------------------------- */

    FUNCTION mlc_ipc_acid (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return true account ID for MMS-LA contract (matching IPC account's ID).

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      Account ID.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    16.03.2015  Created
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION partreorg_prepare_fk_only (
        own                                     IN VARCHAR2,
        tbl                                     IN VARCHAR2,
        part                                    IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      own  - TODO.
      tbl  - TODO.
      part - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       Return list of colon separated valid bill rates.
       ---------------------------------------------------------------------- */

    FUNCTION pmv_billrates (p_pmv_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return list of colon separated valid bill rates:
        0=-100;1=0;2=100 ... 99=0
        before = Billrate 0..99 (integer)
        after  = Amount Customer in 0.001 CHF (integer)
    Used for provisioning ISCP with end user prices.

    Input Parameter:
      p_pmv_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Used for re-rating of SMS CDRs (correction of incident in
       SBS Release 14.02.01).
       ---------------------------------------------------------------------- */

    FUNCTION re_rated_sms_cdr (
        vascontractid                           IN VARCHAR2,
        tariffid                                IN VARCHAR2)
        RETURN NUMBER /*<>
    Used for re-rating of SMS CDRs (correction of incident in
    SBS Release 14.02.01).

    Input Parameter:
      vascontractid - TODO.
      tariffid      - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    16.09.2014  Created
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION reva_sigmask_merge (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Return Content service parameter string representation.
       ---------------------------------------------------------------------- */

    FUNCTION service_parameter (
        p_type                                  IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    Return Content service parameter string representation.

    Input Parameter:
      p_type  - TODO.
      p_value - TODO.

    Return Parameter:
      Content service parameter string,

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    19.05.2014  Created
    002SO    28.08.2014  Support for **null** in MBS config
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION shift_vas_ts (
        p_hihid                                 IN VARCHAR2,
        p_datetime                              IN DATE,
        p_msisdn_a                              IN VARCHAR2,
        p_msisdn_b                              IN VARCHAR2,
        p_requestid                             IN VARCHAR2)
        RETURN DATE /*<>
    TODO.

    Input Parameter:
      p_hihid     - TODO.
      p_datetime  - TODO.
      p_msisdn_a  - TODO.
      p_msisdn_b  - TODO.
      p_requestid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION sigmask_merge (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION slow_text_table (
        sqlt_str_text                           IN VARCHAR2,
        sqlt_int_rows                           IN INTEGER,
        sqlt_vnr_delay                          IN NUMBER)
        RETURN t_text_tab
        PIPELINED /*<>
    TODO.

    Input Parameter:
      sqlt_str_text  - TODO.
      sqlt_int_rows  - TODO.
      sqlt_vnr_delay - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                 ;

    /* =========================================================================
       Used for re-rating of SMS CDRs (correction of incident in
       SBS Release 14.02.01).
       ---------------------------------------------------------------------- */

    FUNCTION sms_la_mt_price (
        vascontractid                           IN VARCHAR2,
        tariffid                                IN VARCHAR2,
        paymentmethod                           IN NUMBER)
        RETURN NUMBER /*<>
    Used for re-rating of SMS CDRs (correction of incident in
    SBS Release 14.02.01).

    Input Parameter:
      vascontractid - TODO.
      tariffid      - TODO.
      paymentmethod - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    17.09.2014  Created
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION string_match (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION string_match_count (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                     ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION to_base (
        p_dec                                   IN NUMBER,
        p_base                                  IN NUMBER)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_dec  - TODO.
      p_base - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       Procedures.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE app_create_synonym (
        obj                                     IN VARCHAR2,
        src                                     IN VARCHAR2,
        dest                                    IN VARCHAR2,
        p_exec                                  IN NUMBER DEFAULT 1) /*<>
    TODO.

    Input Parameter:
      obj    - TODO.
      src    - TODO.
      dest   - TODO.
      p_exec - TODO.

    Restrictions:
      - TODO.
    */
                                                                    ;

    /* =========================================================================
       Merge all application object grants with the existing ones in table
       APP_OBJECT_GRANT.
       ---------------------------------------------------------------------- */

    PROCEDURE app_merge_app_grants (p_grantee IN VARCHAR2) /*<>
    Merge all application object grants with the existing ones in table
    APP_OBJECT_GRANT.

    APP_OBJECTS : view of potential useful objects for access by non schema
                 owners

    Input Parameter:
      p_grantee - TODO.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    ---------    ------      -------------------------------------------
    Person       Date        Comments
    001SO        08.03.2012  Created
    002SO        09.03.2012  Use SELECT on Sequences
    */
                                                          ;

    /* =========================================================================
       Merge needed object grants with the existing ones in table
       APP_OBJECT_GRANT.
       ---------------------------------------------------------------------- */

    PROCEDURE app_merge_token_grants (p_grantee IN VARCHAR2) /*<>
    Merge needed object grants with the existing ones in table
    APP_OBJECT_GRANT.

    APP_OBJECTS : view of potential useful objects for access by non schema
                 owners
    APP_TOKEN   : staging table for found tokens in source code
                 (some matching the ones in USER_OBJECTS)

    Input Parameter:
      p_grantee - TODO.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    ---------    ------      -------------------------------------------
    Person       Date        Comments
    SO           01.03.2012  Created
    001SO        08.03.2012  Use baic filtering in view APP_OBJECTS
    002SO        09.03.2012  Use SELECT on Sequences
   */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE correlate_seg /*<>
    TODO.

    Restrictions:
      - TODO.
    */
                           ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE correlate_seg2 /*<>
    TODO.

    Restrictions:
      - TODO.
    */
                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE partreorg (
        own                                     IN VARCHAR2,
        tbl                                     IN VARCHAR2,
        part                                    IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      own  - TODO.
      tbl  - TODO.
      part - TODO.

    Restrictions:
      - TODO.
    */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_compile_all /*<>
    TODO.

    Restrictions:
      - TODO.
    */
                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_ismsisdn (
        p_pac_id                                IN     VARCHAR2,
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

    PROCEDURE sp_insert_next_period (
        p_pact_id                               IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
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
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_period (p_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_code - TODO.

    Restrictions:
      - TODO.
    */
                                                   ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE stats_analyzejob /*<>
    TODO.

    Restrictions:
      - TODO.
    */
                              ;
END pkg_adhoc;
/