-- GENERATED CODE (based on the man pages in the implementation specification packages)

SET DEFINE OFF;

CREATE OR REPLACE FUNCTION sbsdb_api_scope_help
    RETURN sbsdb_api_scope_help_nt
IS
    l_sbsdb_api_scope_help_ntv     sbsdb_api_scope_help_nt := sbsdb_api_scope_help_nt ();
BEGIN
    l_sbsdb_api_scope_help_ntv.EXTEND (392);

    l_sbsdb_api_scope_help_ntv (1) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.ACCOUNT_NAME', api_help_text => '

    TODO.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Current account name.

    Restrictions:
      - TODO.

    
            ');
    l_sbsdb_api_scope_help_ntv (2) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.AS_DATE', api_help_text => '

    TODO.

    Input Parameter:
      p_date - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (3) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.BILLTEXT_IN_UFIH', api_help_text => '

    Cut out billtext from UFIH CDR.

    Input Parameter:
      s - TODO.

    Return Parameter:
      Billtext from UFIH CDR.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (4) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.BITPOS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (5) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.BITVAL', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (6) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTENT_REVENUE_SHARE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (7) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_ACNAME', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (8) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_AMOUNT_RANGE', api_help_text => '

    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      Amount range for given contract from current price model version.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (9) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_BILLRATES', api_help_text => '

    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      List of colon separated valid bill rates for for given IP contract.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (10) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_IOT', api_help_text => '

    Return IOT for a given
       - Telecom Operator Contract,
       - direction (''ORIG'',''TERM''),
       - transport medium (''SMS'',''MMS''), and
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
    
            ');
    l_sbsdb_api_scope_help_ntv (11) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_IS_ACTIVE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (12) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_IS_ACTIVE_OR_TEST', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (13) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_STATE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (14) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACT_ZERO_BILLRATES', api_help_text => '

    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      List of colon separated valid bill rates with zero Amount for for given IP contract.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (15) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CONTRACTCOUNTFORACCOUNT', api_help_text => '

    TODO.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Number of "active" accounts belonging to an account.


    Restrictions:
      - Condition: CON_ESID IN (''A'',''E'',''T'').
    
            ');
    l_sbsdb_api_scope_help_ntv (16) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CS_IS_ACTIVE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (17) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CS_IS_ACTIVE_OR_TEST', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (18) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CS_SERVICE_KEY', api_help_text => '

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
    002SO    05.05.2014  Replace '':'' with ''-''
    
            ');
    l_sbsdb_api_scope_help_ntv (19) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CS_STATE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (20) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.DESC_CORR', api_help_text => '

    TODO.

    Input Parameter:
      p_old_desc   - TODO.
      p_old_count  - TODO.
      p_count_diff - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (21) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.GETHIERARCHICALHASH', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (22) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.GETPRICERANGE', api_help_text => '

    Used for evaluation of Amount range for given price model.

    Input Parameter:
      p_pm_id - TODO.

    Return Parameter:
      Amount range.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (23) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.HASH_MD5', api_help_text => '

    Return MD5 HASH of given input parameter.

    Input Parameter:
      var - TODO.

    Return Parameter:
      MD5 HASH.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (24) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.JOB_SEARCH_PARAMETER_TEST', api_help_text => '

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

    
            ');
    l_sbsdb_api_scope_help_ntv (25) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.KPI_SMS_LA_REVENUE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (26) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.LA_ACNAME', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (27) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.LAC_IPC_ACID', api_help_text => '

    Return true account ID for SMS-LA contract (matching IPC account''s ID).

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
    
            ');
    l_sbsdb_api_scope_help_ntv (28) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.LOCAL_TIME', api_help_text => '

    TODO.

    Input Parameter:
      p_datetime     - TODO.
      p_offset       - TODO.
      p_local_offset - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (29) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.MLC_IPC_ACID', api_help_text => '

    Return true account ID for MMS-LA contract (matching IPC account''s ID).

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
    
            ');
    l_sbsdb_api_scope_help_ntv (30) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.PARTREORG_PREPARE_FK_ONLY', api_help_text => '

    TODO.

    Input Parameter:
      own  - TODO.
      tbl  - TODO.
      part - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (31) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.PMV_BILLRATES', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (32) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.RE_RATED_SMS_CDR', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (33) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.REVA_SIGMASK_MERGE', api_help_text => '

    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (34) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SERVICE_PARAMETER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (35) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SHIFT_VAS_TS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (36) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SIGMASK_MERGE', api_help_text => '

    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (37) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SLOW_TEXT_TABLE', api_help_text => '

    TODO.

    Input Parameter:
      sqlt_str_text  - TODO.
      sqlt_int_rows  - TODO.
      sqlt_vnr_delay - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (38) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SMS_LA_MT_PRICE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (39) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.STRING_MATCH', api_help_text => '

    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (40) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.STRING_MATCH_COUNT', api_help_text => '

    TODO.

    Input Parameter:
      s - TODO.
      m - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (41) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.TO_BASE', api_help_text => '

    TODO.

    Input Parameter:
      p_dec  - TODO.
      p_base - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (42) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.APP_CREATE_SYNONYM', api_help_text => '

    TODO.

    Input Parameter:
      obj    - TODO.
      src    - TODO.
      dest   - TODO.
      p_exec - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (43) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.APP_MERGE_APP_GRANTS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (44) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.APP_MERGE_TOKEN_GRANTS', api_help_text => '

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
   
            ');
    l_sbsdb_api_scope_help_ntv (45) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CORRELATE_SEG', api_help_text => '

    TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (46) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.CORRELATE_SEG2', api_help_text => '

    TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (47) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.PARTREORG', api_help_text => '

    TODO.

    Input Parameter:
      own  - TODO.
      tbl  - TODO.
      part - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (48) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SP_COMPILE_ALL', api_help_text => '

    TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (49) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SP_CONS_ISMSISDN', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (50) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SP_INSERT_NEXT_PERIOD', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (51) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.SP_INSERT_PERIOD', api_help_text => '

    TODO.

    Input Parameter:
      p_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (52) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC.STATS_ANALYZEJOB', api_help_text => '

    TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (53) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADHOC', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (54) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADMIN_COMMON.GETERRORDESC', api_help_text => '

    Get standard error message for given error code or exception name.
    Look it up in table errdef.

    Input Parameter:
      lverrcode - ErrorCode or ExceptionName.

    Return Parameter:
      on success - english version of error message (errdef.lang01)
      on error - lverrcode || '': Error Description not available''

    Restrictions:
      - input is searched in errdef.errd_code or in errd_exception
        for a a case insensitive match
    
            ');
    l_sbsdb_api_scope_help_ntv (55) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADMIN_COMMON.SP_ADD_REPORT', api_help_text => '

    Schedule a report creation workflow in the tables sta_job, sta_jobparam and sta_jobsql.

    Input Parameter:
      str_acid           - AccountId of statistics engine workflow runner (always ''SYSTEM'' so far).
      str_pac_id         - PackingId (report type, e.g. ''SL093a'').
      dat_from           - report time frame start time, fills sta_jobparam ''[DATEFROM]'' attribute.
      dat_to             - report time frame start time, fills sta_jobparam ''[DATETO]'' attribute.
      str_opt_param      - report optional filter parameter, fills sta_jobparam ''[OPT_PARAM] attribute.
      str_comment        - concatenated with str_system_info and str_parameter_info into sta_job.staj_info.
      str_system_info    - concatenated with str_comment and str_parameter_info into sta_job.staj_info.
      str_parameter_info - concatenated with str_comment and str_system_info into sta_job.staj_info.
      int_pac_modis      - not used since statistics module ist statically assigned on table packing.
      int_pac_modla      - not used since statistics module ist statically assigned on table packing.
      int_pac_modiw      - not used since statistics module ist statically assigned on table packing.
      int_pac_modsys     - not used since statistics module ist statically assigned on table packing.
      int_pac_modcuc     - not used since statistics module ist statically assigned on table packing.

    Output Parameter:
      int_errnumber - error code returned by pkg_stats.sp_new_sta_jobsqls.
      str_errdesc   - error description returned by pkg_stats.sp_new_sta_jobsqls.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (56) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADMIN_COMMON.SP_HIDE_JOB_OUTPUT', api_help_text => '

    Soft delete a statistics job (set state = ''D'' for deleted) based on the id of one of its output ids.
    Emit a warning ''STATS'', ''SP_HIDE_JOB_OUTPUT'', ''JOB DELETED BY ACCOUNT '' || p_acid in the logs.

    Input Parameter:
      p_acid        - AccountId of statistics engine workflow runner (always ''SYSTEM'' so far).
      p_joboutputid - Job OutputId (ResultDocumentId) for which to soft delete the job.

    Output Parameter:
      p_errnumber - 0 for success or SQLCODE for failure.
      p_errdesc   - NULL for success or SQLERRM for failure.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (57) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADMIN_COMMON.SP_VALIDATE_EXCHANGE_RATES', api_help_text => '

    Validate exchange rates and re-calculate gapless end dates from time sorted start dates.

    Input Parameter:
      p_cur_id     - CurrencyId.
      returnstatus - any value (not relevant).

    Output Parameter:
      errorcode    - 0 for success or SQLCODE for failure.
      errormsg     - NULL for success or SQLERRM for failure.
      returnstatus - 1 = success, 0 = error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (58) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ADMIN_COMMON', api_help_text => '

    Common routines for SBS input and output converters.

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    001SO       25.11.2003  Created, code moved from PKG_BDETAIL_COMMON
    002AA       02.12.2003  Created routing stored procedure calls for all packages SPs accessed from WebModule
    002AH       31.03.2004  Added new WARNING Writer, without ReturnCode
    003AH       31.03.2004  Added new ERROR HANDLING, WARNING Writer, without RETURNCODE, and VALUES
    004AH       07.04.2004  Changed getErrorDesc -> Merge table error with errdef
    005AA       18.07.2004  Added wrapper procedure ''SP_REPLACE_PARAMS'' for ''PKG_STATS.SP_REPLACE_PARAMS''
    006SO       03.09.2004  Using PKG_AAA_PROV now instead of PKG_AAA
    007SO       21.12.2004  Desupport for checkDependenciesWeb
    008AA       30.12.2004  Added overload procedure SP_NEW_STA_JOB with extra job notification parameters (p_StajNotification,p_StajNotId,p_StajNotEmailSuccess,p_StajNotEmailFailure,p_StajNotSendAttachment)
    009AA       10.01.2005  Added overlaoded procedure SP_INSERT_ISSUE with additional parameter for AC_ID (called by Pkg_Centrum for creating Account/Address related issues (history entries))
    010SO       08.02.2004  Using PKG_AAA_HB instead of PKG_AAA_PROV
    011AA       11.02.2004  Add new stored procedure SP_INSERT_AAACUSTBAR to insert a new AAA RBT Barring Rule
    012SO       08.02.2009  Add Procedures for LongID management
    013SO       09.02.2009  Implement LongID mapping validation and logging
    014SO       23.02.2009  Correct naming for parameter p_AC_ID and field LONGH_ACID
    015SO       08.03.2009  Create overload for SP_INSERT_AAALOG
    016SO       13.12.2011  Remove CAT test implementation
    017SO       14.12.2011  Remove schema qualifier "S B S 0 ."
    018SO       29.02.2012  Use DB Link to SBS0 so that we can grant usage to SBSWEB
    019SO       18.04.2012  Use synonyms instead of DB-Links to other schemas
    020SO       06.05.2012  Use local synonyms instead of explicit schemas
    021SO       13.06.2015  Remove stub for customer barring (ringbacktone)
    022SO       01.12.2015  Add Procedure to hide Statistics Job output from GUI
    023SO       14.12.2015  Add Procedure to generate Statistics Job
    024SO       15.01.2019  Concatenate individual remarks into Job Info
    000SO       13.02.2019  HASH:4FEF4B41CF288DF61E2EFCE7D01B4CF8 pkg_admin_common.pkb
    025SO       01.04.2019  Remove deprecated procedure insert_issue
    
    ');
    l_sbsdb_api_scope_help_ntv (59) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.CONTRACT_IOT_CHF', api_help_text => '

    Return IOT (Inter-Operator-Tariff = Interworking Price) for a given
          - Telecom Operator Contract,
          - direction (''ORIG'',''TERM''),
          - transport medium (''SMS'',''MMS''), and
          - message size.

    Input Parameter:
      p_con_id  - Telecom Operator ContractId varchar2(10).
      p_iwdid   - InterworkingDirectionId (''ORIG'',''TERM'').
      p_trctid  - TransportCarrierTypeId (''SMS'',''MMS'').
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
    
            ');
    l_sbsdb_api_scope_help_ntv (60) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.CONTRACTPERIODEND', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (61) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.CONTRACTPERIODSTART', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (62) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.GENERATEBASE36KPIKEY', api_help_text => '

    Return the next KPI sequence number (bdkpi_seq.NEXTVAL) in base36 format.

    Return Parameter:
      Next KpiId in base36

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (63) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.GETTYPEFORMAPPING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (64) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.GETTYPEFORPACKING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_pacid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (65) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.GETUFIHFIELD', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (66) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.ISTIMEFORMAPPING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (67) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.ISTIMEFORPACKING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_pacid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (68) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.NORMALIZEDMSISDN', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (69) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SIMPLEHASH', api_help_text => '

    Calculates simple numerical hash for eMail-Adresses.
    Used in SBS0 (with 41 - prefix) as a MSISDN like placeholder for B-Numbers.
    Provided here on SBS1 for analytics with the same semantics.

    Input Parameter:
      s - input string to be hashed (e.g. eMail Address).

    Return Parameter:
      Hash (integer)

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (70) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.INSERT_WARNING', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (71) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_GET_NEXT_PAC_SEQ', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (72) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_INSERT_BIHEADER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (73) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_INSERT_BIHEADER_MEC', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (74) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_INSERT_BOHEADER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (75) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_INSERT_BOHEADER_MEC', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (76) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_INSERT_WARNING', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (77) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON.SP_UPDATE_DLS_DATES', api_help_text => '

    Update the daylight saving table for the current year.

    Input Parameter:
      p_pact_id    - ActorId varchar2(10), usually ''SYSTEM''.
      p_boh_id     - BoheaderId (Output Converter Task Id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - 1 for success, 0 for error.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - to be called before daylight saving switch in April.
    
            ');
    l_sbsdb_api_scope_help_ntv (78) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_COMMON', api_help_text => '

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
    
    ');
    l_sbsdb_api_scope_help_ntv (79) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_INFO.SP_CONS_IS', api_help_text => '

    Soft deletes and then (re-) fills up consolidation table ISCONSOL (Info Service Consolidation) 
    with aggregated transaction data from table BDETAIL.
    Deletes and then fills table isc_aggregation with aggregated data for contracts which have too 
    many items. Adds a flag to those contract entries in ISCONSOL. This can be used as a row count 
    warning (provoke a fallback to lump sum presentation) later in the reports.

    Input Parameter:
      p_pac_id     - ActorId varchar2(10) usually ''SYSTEM''.
      p_boh_id     - BillingOutputHeaderId (Output Converter attempt id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - number of flagged row count warnings.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (80) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_INFO.SP_CONS_ISMSISDN', api_help_text => '

    Fills up consolidation table ISMSTAT (Info Service per Msisdn) with data from table BDETAIL
    Fills up consolidation table TPMCONSOL (Third Party Msisdn) with data from table BDETAIL

    Input Parameter:
      p_pac_id     - ActorId varchar2(10) usually ''SYSTEM''.
      p_boh_id     - BillingOutputHeaderId (Output Converter attempt id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - 1 for success, 0 for error.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (81) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_INFO.SP_CONS_TR', api_help_text => '

    Consolidate transport costs for previous month.
    Soft delete pre-existing entries for the period in table TRCONSOL.
    Aggregate transport costs (separately for SMS and MMS transport) from table ISCONSOL
    and populate TRCONSOL with the result.
    
    Input Parameter:
      p_pac_id     - ActorId varchar2(10) usually ''SYSTEM''.
      p_boh_id     - BillingOutputHeaderId (Output Converter attempt id).
      returnstatus - not used.

    Output Parameter:
      recordsaffected - Count of overall inserted consolidation rows.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (82) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_INFO', api_help_text => '

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
    014AH       14.07.2004  Hack Red CODE (Billtext Patching for SERVICE = ''9733'')
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
    041SO       09.11.2006  Correct sorting for tr');
    l_sbsdb_api_scope_help_ntv (83) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_CONS_LAM_MMS', api_help_text => '

    Perform minimum charge settlement for MMS LA by delegation to pkg_bdetail_settlement.sp_lam_mcc().

    Input Parameter:
      p_pac_id - ''LATMCC_MMS''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - forwarded record count from pkg_bdetail_settlement.sp_lam_mcc.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - depends on preparation task in sp_cons_lapmcc_mms.
    
            ');
    l_sbsdb_api_scope_help_ntv (84) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_CONS_LAPMCC_MMS', api_help_text => '

    Prepare minimum charge settlement for MMS LA by delegation to pkg_bdetail_settlement.sp_lapmcc().
    Get a list of MMS LA contracts which can have a minimum charge per pseudo call number. More than 
    one contract can be returned, if they have equal weighted minimum charge.
    This is taken care of in the processing of the result

    Input Parameter:
      p_pact_id - ''LAPMCC_MMS''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - forwarded record count from pkg_bdetail_settlement.sp_lapmcc.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - depends on aggregating consolidations for the settlement period (last month).
    
            ');
    l_sbsdb_api_scope_help_ntv (85) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_CONS_LAT_MMS', api_help_text => '

    Consolidate MMS-LA daily UFIH transport tickets from so-far accumulated but not settled settlement details.
    This means: collect entries of type ''CDRA'' from yesterday and maybe also from days before and generate 
    entries of type ''CDR'' for them.

    Input Parameter:
      p_pac_id - ''LAT_MMS''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - marked and processed record count from table setdetail.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - should run daily but not too early in the day in order to catch all accumulated
        data from yesterday.
    
            ');
    l_sbsdb_api_scope_help_ntv (86) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_CONS_LIT_MMS', api_help_text => '

    Consolidate MMS-LA daily UFIH interworking tickets from so-far accumulated but not settled settlement details.
    This means: collect entries of type ''IOTLACA from yesterday and maybe also from days before and generate 
    entries of type ''IOTLAC'' for them.

    Input Parameter:
      p_pac_id - ''LIT_MMS''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - marked and processed record count from table setdetail.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - should run daily but not too early in the day in order to catch all accumulated
        data from yesterday.
    
            ');
    l_sbsdb_api_scope_help_ntv (87) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_CONS_MMSC', api_help_text => '
 -- 033SO
    Aggregate (consolidate) last month''s MMS transaction CDRs from table BDETAIL6 into 
    table MMSCONSOLIDATION.

    Input Parameter:
      p_pact_id - ''MMSC''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - insert record count to table MMSCONSOLIDATION.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (88) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_TRY_LAA_MMSC', api_help_text => '

    Accumulate fresh MMSC-LA transport CDRs from table BDETAIL6 into table SETDETAIL as a first step 
    in MMS-LA settlement. Only consider CDRs of a configured age and younger.
    Process one batch per call up to a configured maximum batch count (e.g. 5000 CDRs at once). 

    Input Parameter:
      p_pac_id - ''LAA_MMSC''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - record count collected and aggregated.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (89) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC.SP_TRY_LIA_MMSC', api_help_text => '

    Accumulate fresh MMSC-LA interworking CDRs from table BDETAIL6 into table SETDETAIL as a first step 
    in MMS-LA interworking settlement. Only consider CDRs of a configured age and younger.
    Process one batch per call up to a configured maximum batch count (e.g. 5000 CDRs at once). 

    Input Parameter:
      p_pac_id - ''LIA_MMSC''.
      p_boh_id - BillingOutputHeaderId (Output Converter attempt id).

    Output Parameter:
      recordsaffected - record count collected and aggregated.
      errorcode       - SQLCODE or NULL for success.
      errormsg        - SQLERRM or NULL for success.
      returnstatus    - 1 for success, 0 for error.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (90) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MMSC', api_help_text => '

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
    
    ');
    l_sbsdb_api_scope_help_ntv (91) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MSC.ADD_SMSC_CODE_TO_UNKNOWN_TOC', api_help_text => '

    TODO.

    Input Parameter:
      p_smsc_code  - TODO.
      returnstatus - TODO.

    Output Parameter:
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (92) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MSC.GET_SMSC_ID', api_help_text => '

    TODO.

    Input Parameter:
      p_bd_sca     - TODO.
      returnstatus - TODO.

    Output Parameter:
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (93) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MSC.SP_TRY_MSCCU', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (94) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_MSC', api_help_text => '

    TODO.

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    001SO       31.03.2004  Suppress Output before CutoffDate April 1st (not wanted at that time)
    002SO       28.04.2004  Move cutoff back to March 1st for reprocessing March data)
    003SO       21.10.2004  Rebuild index partitions instead of using default tablespace
    004SO       21.10.2004  Compile all in error case too
    005SO       16.08.2006  Add period entry by using PKG_BDETAIL_COMMON.SP_INSERT_PERIOD()
    006SO       21.01.2008  Remove SP_INSERT_MSC, SP_DELETE_BDETAIL_MSC, SP_DELETE_ALL_RECORDS_MSC
    007SO       31.10.2009  Move Period Insert to standalone Procedure
    008SO       31.03.2010  Implement SP_MSCCU_TRY (mark and process MSC counter updates)
    009SO       15.04.2010  Update the packing state after marked process
    010SO       26.08.2010  Rename procedures according to driving Packing-ID
    011SO       14.12.2011  Remove schema qualifier "S B S 0 ."
    000SO       13.02.2019  HASH:BC1005C8DDB7C91025AEB2A0769F2299 pkg_bdetail_msc.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (95) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.NEXTAVAILABLEORDER', api_help_text => '

    TODO.

    Input Parameter:
      p_sed_charge - TODO.
      p_sed_date   - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (96) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SETTLEDDURATION', api_help_text => '

    TODO.

    Input Parameter:
      con_datestart - TODO.
      con_dateend   - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (97) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_ADD_SETDETAIL', api_help_text => '

    TODO.

    Input Parameter:
      p_set_etid       - TODO.
      p_sed_etid       - TODO.
      p_sed_charge     - TODO.
      p_sed_bohid      - TODO.
      p_date           - TODO.
      p_set_conid      - TODO.
      p_sed_tarid      - TODO.
      p_sed_int        - TODO.
      p_sed_prepaid    - TODO.
      p_sed_price      - TODO.
      p_sed_amountcu   - TODO.
      p_sed_retsharepv - TODO.
      p_sed_retsharemo - TODO.
      p_sed_longid     - TODO.
      p_sed_count1     - TODO.
      p_sed_count2     - TODO.
      p_sed_desc       - TODO.
      p_gart           - TODO.
      returnstatus     - TODO.

    Output Parameter:
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (98) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_ADD_SETDETAIL_BY_DATE', api_help_text => '

    TODO.

    Input Parameter:
      p_date           - TODO.
      p_set_conid      - TODO.
      p_set_etid       - TODO.
      p_set_demo       - TODO.
      p_set_currency   - TODO.
      p_set_comment    - TODO.
      p_sed_etid       - TODO.
      p_sed_price      - TODO.
      p_sed_quantity   - TODO.
      p_sed_discount   - TODO.
      p_sed_vatid      - TODO.
      p_sed_vatrate    - TODO.
      p_sed_desc       - TODO.
      p_sed_order      - TODO.
      p_sed_visible    - TODO.
      p_sed_comment    - TODO.
      p_sed_count1     - TODO.
      p_sed_count2     - TODO.
      p_sed_charge     - TODO.
      p_sed_bohid      - TODO.
      p_sed_pmvid      - TODO.
      p_sed_tarid      - TODO.
      p_sed_esid       - TODO.
      p_sed_int        - TODO.
      p_sed_prepaid    - TODO.
      p_sed_amountcu   - TODO.
      p_sed_retsharepv - TODO.
      p_sed_retsharemo - TODO.
      p_sed_longid_1   - TODO.
      p_sed_longid_2   - TODO.
      returnstatus     - TODO.

    Output Parameter:
      p_sep_id     - TODO.
      p_set_id     - TODO.
      p_sed_id     - TODO.
      p_sed_pos    - TODO.
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (99) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_CONS_INSERT_PERIOD', api_help_text => '

    TODO.

    Input Parameter:
      p_pac_id   - TODO.
      p_boh_id   - TODO.

    Output Parameter:
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (100) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_LAM_MCC', api_help_text => '

    TODO.

    Input Parameter:
      p_pac_id   - TODO.
      p_boh_id   - TODO.
      p_set_etid - TODO.
      p_gart     - TODO.

    Output Parameter:
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (101) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_LAPMCC', api_help_text => '

    TODO.

    Input Parameter:
      p_pac_id   - TODO.
      p_boh_id   - TODO.
      p_set_etid - TODO.

    Output Parameter:
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (102) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_LAT_CDR', api_help_text => '

    TODO.

    Input Parameter:
      p_bd_bohid - TODO.
      p_set_etid - TODO.
      p_gart     - TODO.
      p_minage   - TODO.
      p_maxage   - TODO.

    Output Parameter:
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (103) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT.SP_LIT_CDR', api_help_text => '

    TODO.

    Input Parameter:
      p_bd_bohid - TODO.
      p_set_etid - TODO.
      p_gart     - TODO.
      p_minage   - TODO.
      p_maxage   - TODO.

    Output Parameter:
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (104) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SETTLEMENT', api_help_text => '

    Briefly explain the functionality of the package body.

    To modify this template, edit file PKGBODY.TXT in TEMPLATE
    directory of SQL Navigator.

    Enter package declarations as shown below

    MODIFICATION HISTORY
    Person    Date        Comments
    001SO     18.06.2004  Added settlement parameters for mVoting
    002SO     21.06.2004  Change error handling in SP_ADD_SETDETAIL_BY_DATE, SP_INSERT_SETDETAIL and SP_INSERT_SETTLING
    003SO     22.05.2009  Add LongId to settlement detail insert signatures (for SMS Global Reply)
                            use VARCHAR2(20) as datatype to make the field nullable
    004SO     27.05.2009  Add function NextAvailableDatetime
    005SO     05.06.2009  Reset LongID to 0 if not in table LONG_ID
    006SO     20.08.2010  Implement SP_ADD_SETDETAIL (simplifying stub for SP_ADD_SETDETAIL_BY_DATE)
    007SO     20.08.2010  Implement SP_MOLAT_CDR_AGR (generate CDRs for aggregated records)
    008SO     20.08.2010  Implement FUNCTION billTextLa (UFIH ticket Remark field content for LA)
    009SO     20.08.2010  Implement FUNCTION nextAvailableTimestamp
    010SO     23.08.2010  Correct typo
    011SO     23.08.2010  Remove exception handlers in new procedure
    012SO     23.08.2010  Add MOLAT Consolidation for MO messages
    013SO     23.08.2010  Implement UFIH rendering in SP_ADD_SETDETAIL
    014SO     24.08.2010  Implement SP_PREPARE_LA_MCC generically for SLA and MLA
    015SO     24.08.2010  Implement SP_MOLAM_CONS (Minimum Charge Consolidation)
    016SO     25.08.2010  Accept GART as input parameter in SP_MOLAM_CONS
    017SO     26.08.2010  Rename procedures according to driving Packing-ID
    018SO     31.08.2010  Implement SP_LIT_CDR (Ticket generation for SMS/MMS IW fees)
    019SO     06.09.2010  Implement SP_CONS_INSERT_PERIOD
    020SO     06.09.2010  Simplify error handling in INSERT_SETDETAIL
    021SO     07.09.2010  Calculate time offset per CDR
    022SO     07.09.2010  Use correct amount variable for MO tickets
    023SO     07.09.2010  Correct error return variables
    024SO     07.09.2010  Use correct settlement detail type ''IOTLACT'' for IW tickets
    025SO     08.09.2010  Implement schedule option for UFUH generation (for MOIWST)
    026SO     08.09.2010  Correct numeric Format for UFIH F5
    027SO     18.09.2010  Round Settlement items to 2 digits
    028SO     18.09.2010  Suppress zero (counts=0 and price=0.00) UFIH CDRs of all types now
    029SO     18.09.2010  Patch UFIH-Price to 0.00 for all internal LA
    030SO     11.04.2011  Treat Tariff T (Televote) as Info Service
    031SO     14.12.2011  Remove schema qualifier "S B S 0 ."
    032SO     18.04.2012  Use PKG_COMMON.INSERT_WARNING
    033SO     09.08.2016  Suppress Tariff ''i'' interworking costs in UFIH
    034SO     16.10.2016  Removing latest change 033SO and fully trust zero rating for internal LA and Triff i
    035SO     16.10.2016  Remove references to mVoting CDR Tags SMS-MV*
    036SO     12.07.2017  Compress LongId ranges if outside ''official'' block 4179807...
    037SO     03.08.2017  Add missing date format
    038SO     04.08.2017  Remove support for Tariff ''M'' (M-Voting)
    039SO     01.12.2017  Fix logging typo
    039SO     16.04.2018  Settle pager messages also (PAG)
    040SO     15.11.2018  Remove reference to CON_DEMO
    000SO     13.02.2019  HASH:54A9D889A9B385CE9313DC8550BC4FFD pkg_bdetail_settlement.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (105) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_DGTI', api_help_text => '
 --  039SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (106) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_IWT', api_help_text => '
 --  039SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (107) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_LAA_MFGR', api_help_text => '
 --  039SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (108) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_LAM_SMS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (109) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_LAPMCC_SMS', api_help_text => '
 --  039SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (110) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_LAT_MFGR', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (111) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_LAT_SMS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (112) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_LIT_SMS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (113) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_OGTI', api_help_text => '
 --  039SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (114) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_CONS_SMSC', api_help_text => '
 --  039SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (115) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_TRY_LAA_SMS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (116) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_TRY_LIA_RSGR', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (117) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_TRY_LIA_SMS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (118) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC.SP_TRY_SMSCCU', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (119) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_BDETAIL_SMSC', api_help_text => '

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
    045SO       18.09.2010  IW Accumulators: Calculate IW Tariff when m');
    l_sbsdb_api_scope_help_ntv (120) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CODE_MGMT.GET_DDL', api_help_text => '

    TODO.

    Input Parameter:
      lvtype   - TODO.
      lvname   - TODO.
      lvschema - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (121) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CODE_MGMT.GET_DDL_FILE_NAME', api_help_text => '

    TODO.

    Input Parameter:
      lvtype   - TODO.
      lvname   - TODO.
      lvschema - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (122) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CODE_MGMT.MD5CHECKSUM', api_help_text => '

    TODO.

    Input Parameter:
      lvtype   - TODO.
      lvname   - TODO.
      lvschema - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (123) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CODE_MGMT', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (124) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.CUTFIRSTITEM', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (125) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.DURATION', api_help_text => '

    TODO.

    Input Parameter:
      p_time_diff - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (126) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.GENERATEUNIQUEKEY', api_help_text => '

    TODO.

    Input Parameter:
      identifier - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (127) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.GETHARDERRORDESC', api_help_text => '

    TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (128) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.GETREQUIREDHEADERFIELD', api_help_text => '

    TODO.

    Input Parameter:
      p_headerdata - TODO.
      p_token      - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (129) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.IS_ALPHANUMERIC', api_help_text => '

    TODO.

    Input Parameter:
      p_inputvalue - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (130) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.IS_INTEGER', api_help_text => '

    TODO.

    Input Parameter:
      p_inputvalue - TODO.
      p_minvalue   - TODO.
      p_maxvalue   - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (131) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.IS_NUMERIC', api_help_text => '

    TODO.

    Input Parameter:
      p_inputvalue - TODO.
      p_minvalue   - TODO.
      p_maxvalue   - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (132) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.ISDONEINPERIOD', api_help_text => '

    TODO.

    Input Parameter:
      p_period_id - TODO.
      p_datedone  - TODO.

    Return:
      - TODO. --009SO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (133) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.ISTIMEFORPROCESS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (134) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.SP_IS_NUMERIC', api_help_text => '

    TODO.

    Input Parameter:
      p_inputvalue - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (135) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.SPEED', api_help_text => '

    TODO.

    Input Parameter:
      bih_reccount - TODO.
      bih_start    - TODO.
      bih_end      - TODO.

    Return:
      - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (136) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.COMPILE_ALL', api_help_text => '

    TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (137) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.GETDATESFORPERIOD', api_help_text => '

    TODO.

    Input Parameter:
      p_period_id - TODO.

    Output Parameter:
      p_period_start - TODO.
      p_period_end   - TODO.


    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (138) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.INSERT_WARNING', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (139) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.L', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (140) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.LB', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (141) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.SP_DB_SLEEP', api_help_text => '
 --013SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (142) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON.SP_INSERT_WARNING', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (143) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON', api_help_text => '

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
    
    ');
    l_sbsdb_api_scope_help_ntv (144) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_MAPPING.GETSRCTYPEFORBIHEADER', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (145) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_MAPPING.GETTYPEFORMAPPING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (146) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_MAPPING.ISTIMEFORMAPPING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (147) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_MAPPING.INSERT_BIHEADER', api_help_text => '

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
      p_taskid       - TODO.
      p_hostname     - TODO.
      p_status       - TODO.

    Output Parameter:
      p_bih_id - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (148) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_MAPPING.SP_INSERT_HEADER', api_help_text => '
 --009SO
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
    
            ');
    l_sbsdb_api_scope_help_ntv (149) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_MAPPING', api_help_text => '

    Common routines for SBS input converters (associated with control table BIHEADER).

    MODIFICATION HISTORY
    Person    Date        Comments
    001SO     14.01.2010  Created as subset of PKG_BDETAIL_COMMON
    002SO     14.01.2010  Implement Duplicate check for input converters
    003SO     26.01.2010  Set try date in Mapping table for tracking purposes
    004SO     26.01.2010  Check scheduling for mapping
    005SO     01.02.2010  Implement clearance window for process execution (suspended seconds before period end)
    006SO     28.03.2010  Raname p_JobId to p_TaskId
    007SO     05.04.2010  Implement getMappingIdForBiHeader
    008SO     07.04.2010  Implement file timestamp tolerance in duplicate checking
    009SO     03.05.2010  Duplicate SP_INSERT_HEADER stub here (from ind. input converters)
    010SO     14.12.2011  Remove schema qualifier "S B S 0 ."
    000SO     13.02.2019  HASH:CCADBE8AB9DE1936317F1A390A6E0B40 pkg_common_mapping.pkb
    011SO     13.06.2019  Change file duplicate check time window from 10 seconds to 10 days
    
    ');
    l_sbsdb_api_scope_help_ntv (150) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.GETPACKINGCANDIDATEFORTYPE', api_help_text => '

    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_thread      - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (151) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.GETPACKINGPARAMETER', api_help_text => '

    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_name   - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (152) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.GETTYPEFORPACKING', api_help_text => '

    TODO.

    Input Parameter:
      p_bih_pacid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (153) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.ISTIMEFORPACKING', api_help_text => '

    TODO.

    Input Parameter:
      p_pac_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (154) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.SETSTRINGTAGSTOLOWERCASE', api_help_text => '

    TODO.

    Input Parameter:
      p_string - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (155) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.INSERT_BOHEADER', api_help_text => '

    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_packingid   - TODO.
      p_headerid    - TODO.
      p_appname     - TODO.
      p_appver      - TODO.
      p_thread      - TODO.
      p_taskid      - TODO.
      p_hostname    - TODO.

    Output Parameter:
      p_packingid - TODO.
      p_headerid  - TODO.
      p_jobid     - TODO.
      p_filename  - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (156) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.INSERT_BOHEADER_SPTRY', api_help_text => '

    TODO.

    Input Parameter:
      p_packingid - TODO.
      p_headerid  - TODO.

    Output Parameter:
      p_headerid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (157) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.MODIFY_BOHEADER', api_help_text => '
 --020SO
    TODO.

    Input Parameter:
      p_headerid - TODO.
      p_appname  - TODO.
      p_appver   - TODO.
      p_thread   - TODO.
      p_taskid   - TODO.
      p_hostname - TODO.
      p_filename - TODO.

    Output Parameter:
      p_filename - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (158) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.SP_GET_NEXT_PAC_SEQ', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (159) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.SP_INSERT_HEADER', api_help_text => '
 --039SO
    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_packingid   - TODO.
      p_appname     - TODO.
      p_appver      - TODO.
      p_thread      - TODO.
      p_taskid      - TODO.
      p_hostname    - TODO.

    Output Parameter:
      p_packingid    - TODO.
      p_headerid     - TODO.
      p_jobid        - TODO.
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (160) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING.UPDATE_BOHEADER', api_help_text => '

    TODO.

    Input Parameter:
      p_headerid   - TODO.
      p_jobid      - TODO.
      p_filename   - TODO.
      p_filedate   - TODO.
      p_maxage     - TODO.
      p_dataheader - TODO.
      p_reccount   - TODO.
      p_errcount   - TODO.
      p_datefc     - TODO.
      p_datelc     - TODO.

    Output Parameter:
      p_filename - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (161) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_PACKING', api_help_text => '

    Common routines for SBS output converters (associated with control table BOHEADER).

    MODIFICATION HISTORY
    Person    Date        Comments
    001SO     14.01.2010  Created as subset of PKG_BDETAIL_COMMON
    002SO     26.01.2010  Check scheduling for packing
    003SO     28.01.2010  Add Parameter p_FileName to insert header
    004SO     01.02.2010  Implement dependency checks
    005SO     01.02.2010  Implement clearance window for process execution (suspended seconds before period end)
    006SO     02.02.2010  Implement file name token replacement in update header
    007SO     02.02.2010  Generate Job ID for periodic packings
    008SO     03.02.2010  Modify job creation and implement job closing (success only)
    009SO     05.02.2010  Correct Update Header date formats
    010SO     05.02.2010  Schedule / Unschedule Packing if JobId id used
    011DA     19.02.2010  Implementation for method setStringTagsToLowerCase(..)
    012DA     19.02.2010  All tag names to be replaced changed to lower case / additional use of setStringTagsToLowerCase(..)
    013DA     19.02.2010  "<" and ">" must not be removed from filename (UPDATE_BOHEADER) - there may be still tags to replace
    014DA     24.02.2010  Update BoHeader filename only if not NULL
    015DA     04.03.2010  All procedure/function calls from PKG_STATS now rerouted to new PKG_COMMON_STATS
    016SO     26.03.2010  Implement bookkeeping for looper jobs
    017SO     27.03.2010  Add Periodicity to looper registration
    018SO     28.03.2010  Consider STA_CONFIG in suspend evaluation
    019SO     28.03.2010  Consider looper jobs in suspend evaluation
    020SO     29.03.2010  Implement MODIFY_BOHEADER, used by SPTRY output converters
    021SO     29.03.2010  Implement INSERT_BOHEADER_SPTRY, used by SPTRY output converters for dummy header
    022SO     29.03.2010  Correct FileName initialisation (earlier and derived from other packing fields)
    023SO     31.03.2010  Implement packing parameter evaluation form STA_PACPARAM
    024SO     31.03.2010  Correct LoopType conditions
    025SO     01.04.2010  Remove reference to PACKINGSTATE
    026SO     07.04.2010  Correctly set the file mask in BOHEADER when registering an OC
    027SO     12.04.2010  Render packing sequence according to max value
    028SO     12.04.2010  Correct bug in isTimeForPacking
    029SO     14.04.2010  Implement scheduling (in working state) for individual statistic jobs
    030SO     20.04.2010  Recover simple jobs after failure
    031SO     21.04.2010  Set packing to scheduled for non-loopers and restructure UPDATE_BOHEADER for non-loopers
    032SO     21.04.2010  Set packing to done for scheduled empty loopersand implement JobId =''none''
    033SO     23.04.2010  Use ''NONE'' instead an properly check the value
    034SO     23.04.2010  Correct debug logging logic and require level 5 for success entries
    035SO     23.04.2010  Commit packing lock while registering, otherwise it will be rolled back by DotNet caller
    036SO     24.04.2010  Clip potentially long token values (ac_name, con_name) to 25 Characters
    037SO     27.04.2010  Correct status list for resuming uncompleted STATIND jobs
    038SO     28.04.2010  Correct packing sequence format bug
    039SO     03.05.2010  Copy SP_INSERT_HEADER here from PKG_MEC_OC
    040SO     17.08.2010  Replace token brackets <> with spaces in dile names with unresolved tokens
    041SO     17.08.2010  Reset locked packings to active in new period (when no jobs exist in current period)
    042SO     17.08.2010  Preserve existing DateFc DateLc in UPDATE_BOHEADER when no values age given
    043SO     01.09.2010  Revert 040SO This must be done in MEC Driver (last occation to replace tokens)
    044SO     07.09.2011  Replace arbitrary job parameters in file naming
    045SO     07.09.2011  Correct casing and simplify one cursor
    046SO     14.12.2011  Remove schema qualifier "S B S 0 ."
    047SO     15.11.2018  Remove reference to ');
    l_sbsdb_api_scope_help_ntv (162) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.GET_STA_JOB_SCHEDULED_COUNT', api_help_text => '

    TODO.

    Input Parameter:
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (163) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.GET_STA_JOB_ERROR_COUNT', api_help_text => '

    TODO.

    Input Parameter:
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (164) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.GET_STA_JOB_WORKING', api_help_text => '

    TODO.

    Input Parameter:
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.
      p_boheaderid   - TODO.

    Output Parameter:
      p_stajid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (165) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.NEW_STA_JOB_WORKING', api_help_text => '

    TODO.

    Input Parameter:
      p_stajparentid - TODO.
      p_stajpacid    - TODO.
      p_stajltvalue  - TODO.
      p_stajperiodid - TODO.
      p_boheaderid   - TODO.

    Output Parameter:
      p_stajid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (166) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.NEW_STA_JOBS_LOOPERS', api_help_text => '

    TODO.

    Input Parameter:
      p_stajparentid - TODO.
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.
      p_boheaderid   - TODO.

    Output Parameter:
      p_createdjobcount - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (167) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.UPDATE_STA_JOB_SUCCESS', api_help_text => '

    TODO.

    Input Parameter:
      p_stajid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (168) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.UPDATE_STA_JOB_WORKING', api_help_text => '

    TODO.

    Input Parameter:
      p_stajid     - TODO.
      p_boheaderid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (169) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS.WATCHPACKAGESTATECHANGES', api_help_text => '

    TODO.

    Input Parameter:
      vpacid      - TODO.
      voldpacesid - TODO.
      vnewpacesid - TODO.
      voldpacltid - TODO.
      vnewpacltid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (170) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_COMMON_STATS', api_help_text => '

    Statistical Module.

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    000DA       06.03.2010  Creation
    001SO       26.03.2010  Add NEW_STA_JOB_SCHEDULED
    002SO       26.03.2010  Add NEW_STA_JOBS_LOOPERS
    003SO       26.03.2010  Add GET_STA_JOB_WORKING
    004SO       26.03.2010  Implement looper mechanism
    005SO       28.03.2010  Add function for evaluating executable loop job count
    006SO       13.04.2010  Create Job Parameters for DATEFROM and DATETO
    007SO       20.04.2010  Correct type DATEFROM
    008SO       20.04.2010  Abort when number of retry count is reached (not when overridden)
    009SO       23.04.2010  Also consider active jobs for resuming (after package unlock)
    010SO       23.04.2010  Move watchPackingStateChanges here ans simplyfy (remove) error handling
    011SO       23.04.2010  Consider active job state as executable and also as error cause when trycount is exceeded
    012SO       04.05.2010  Use job state change instead of exe date
    046SO       14.12.2011  Remove schema qualifier "S B S 0 ."
    000SO       13.02.2019  HASH:63072A99A4023275752F99E092CC5D4D pkg_common_stats.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (171) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPSH_TPAC_NEW_ADR_ID', api_help_text => '

    Return The Adr_Id of a new tpac address.

    Input Parameter:
      p_adr_email          - TODO.
      p_adr_invoiceemail   - TODO.
      p_adr_statisticsmail - TODO.

    Return Parameter:
      Adr_Id of a tpac address.

    Restrictions:
      - TODO.

    Modification History
    Person       Date        Comments
    ----------   ----------  -------------------------------------------
    SO           11.04.2016  Initial version
    
            ');
    l_sbsdb_api_scope_help_ntv (172) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_CONTENT_SERVICE_JSON', api_help_text => '

    To generate contentservice JSON value (sbsgui like) for the corresponding
    to contract id and cs id.

    Input Parameter:
      p_cs_id - TODO.

    Return Parameter:
      Contentservice JSON value.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          14.10.16 Created
    
            ');
    l_sbsdb_api_scope_help_ntv (173) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_CURRENCY_JSON', api_help_text => '

    To generate JSON value (sbsgui like) for the corresponding currency key.

    Input Parameter:
      p_cur_key - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          17.8.16 Created
    SS          04.8.17 Added ID to the exchangerate vlaue
    
            ');
    l_sbsdb_api_scope_help_ntv (174) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_KEYWORD_JSON', api_help_text => '

    To generate keyword JSON value (sbsgui like) for the corresponding to
    contract id.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          14.10.16 Created
    
            ');
    l_sbsdb_api_scope_help_ntv (175) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_PRICE_JSON', api_help_text => '

    To generate JSON value (sbsgui like) for the corresponding price key.

    Input Parameter:
      p_price_key - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          17.08.2016 Created
    SO001       16.02.2017 NULL PM Version End Date if 01.01.2100
    SS002       28.02.2017 PM version return "" instead of null
    SS003       28.01.2018 PM content prepaid revenue not using nvl
    
            ');
    l_sbsdb_api_scope_help_ntv (176) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_TOAC_SMSC_JSON', api_help_text => '

    To generate toac smsc JSON value (sbsgui like).

    Input Parameter:
      p_smsc_code - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          04.10.17 Created
    
            ');
    l_sbsdb_api_scope_help_ntv (177) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_TOCON_JSON', api_help_text => '

    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    -------- ----------  -------------------------------------------
    001SO    15.11.2018  Remove reference to CON_COMMENT
    
            ');
    l_sbsdb_api_scope_help_ntv (178) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO.GPULL_TPAC_JSON', api_help_text => '

    To generate tpac JSON value (sbsgui like) for the corresponding to account id.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          24.02.17 Created
    001SS       24.07.17 MBUNIT added
    
            ');
    l_sbsdb_api_scope_help_ntv (179) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_CPRO', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (180) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_DEBUG.DEBUG_REVA', api_help_text => '

    TODO.

    Input Parameter:
      lbih_id   - TODO.
      lboh_id   - TODO.
      lrevah_id - TODO.
      lreccount - TODO.
      what      - TODO.
      lhint     - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (181) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_DEBUG', api_help_text => '

    Allow applications to write debug information to their respective debug tables.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    01.02.2006  Procedure debug_enpla added
    002SO    26.10.2008  Remove MMSVAS section
    003SO    13.12.2011  Remove CAT implementation
    004SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    005SO    17.10.2018  Remove procedures debug_enpla and jschedule
    000SO    13.02.2019  HASH:25621D4E272694F1A6B05BE375CBEB3C pkg_debug.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (182) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_INTERWORKING.SP_CONS_NBR_MERGE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (183) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_INTERWORKING.SP_CONS_NBR_PREP', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (184) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_INTERWORKING.SP_CONS_SMSC_PROPOSE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (185) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_INTERWORKING', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO                Adding con_hdgroup in insert into contract (not null now)
    002AA                Increate the size of the parameter arrays declaration for NBR for bulk import
    003AH                Create SP_UPDATESR038
    004SO                Account Insert must set AC_SHORT (not Null since CENTRUM)
    005SO                Moving procedure SP_UPDATE_BOHEADER_IOTLACA_2 to PKG_BDETAIL_SMSC and PKG_BDETAIL_MMSC
    006SO    02.03.2009  Insert SMS and MMS IOT prices for new contracts
    007SO    02.03.2009  Use MmsSizeClassCount = 8
    008SO    10.09.2009  Add prepaid roaming zone field to NUMBERRANGE, fill based on country name (Apollo project)
    009SO    29.03.2010  Rename p_PACT_ID to p_PAC_ID
    010SO    31.03.2010  Implement SP_UPDATE_DLS_DATES (moved here from PKG_BDETAIL_COMMON)
    011SO    26.08.2010  Rename procedures according to driving Packing-ID
    012SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    013SO    19.04.2012  Use PKG_COMMON.PKG_COMMON.SP_IS_NUMERIC
    014SO    14.04.2016  Remove special treatment for Swisscom number ranges
    015SO    07.12.2016  Remove redundant implementation of DLS date calculation SP_CONS_DLSUPDATE
    016SO    26.05.2017  Do not  create MMS size classes as a default for IW prices
    017SO    01.06.2017  Directly assign OpKeys according to NUMBERRANGE modifications
    018SO    15.11.2018  Remove reference to CON_DEMO, CON_INIACTIVE and CON_DATEACTIVE
    000SO    13.02.2019  HASH:6411F21CF7BE16949463281FEAFC8828 pkg_interworking.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (186) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.FROM_JSON_BOOLEAN', api_help_text => '

    Convert an input string to a number.

    Input Parameter:
      p_data - input string.

    Return Parameter:
      0    - if the input string equals to ''false'' (case-sensitive)
      1    - if the input string equals to ''true''  (case-sensitive)
      NULL - in other respects

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (187) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.FROM_JSON_DATE', api_help_text => '

    Convert an input string to a DATE value or NULL.
    Expected date format after removing double quotes and ''Z'' characters
    and replacing the ''T'' characters with '' '': ''yyyy-mm-dd hh24:mi:ss''

    Input Parameter:
      p_date - string.

    Return Parameter:
      NULL              - if the input string is NULL
      a DATE type value - if the input string fits the expected date format

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (188) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_BOOLEAN', api_help_text => '

    Normalize input string representing a truth value with default.

    Input Parameter:
      p_1 - string containing a truth value.
      p_2 - string containing a default value.

    Return Parameter:
      ''false'' - if the input string p_1 equals to ''0'' or ''false'' (case-insensitive)
      ''true''  - if the input string p_1 equals to ''1'' or ''true''  (case-insensitive)
      p_2     - in other respects

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (189) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_DATE', api_help_text => '

    Convert a DATE value to a string representing the date value 
    with a JSON style date string (including double quotes, 
    e.g. "2019-04-05T01:02:03Z" ).
    
    A NULL input will result in "".

    Input Parameter:
      p_date - DATE value.

    Return Parameter:
      "" if the imput value was NULL,
      a string in the format "yyyy-mm-ddThh24:mi:ssZ" in other respects 

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (190) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_FOREIGN_KEY', api_help_text => '

    Create a foreign key string like it is used in tpac (JSON list of Strings) by
    combining ''{"fk":[...]}'' with a list of key parts (optional from right to left).
    Assume all key parts to be strings.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.
      p_3 - KeyPart3 varchar2.
      p_4 - KeyPart4 varchar2.
      p_5 - KeyPart5 varchar2.
      p_6 - KeyPart6 varchar2.
      p_7 - KeyPart7 varchar2.
      p_8 - KeyPart8 varchar2.
      p_9 - KeyPart9 varchar2.
      p_a - KeyParta varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (191) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_FOREIGN_KEY_2', api_help_text => '

    Create a foreign key string like it is used in tpac (JSON list of Strings) by
    combining ''{"fk":[...]}'' with a list of two key parts. Key parts can be NULL 
    which then are converted to ''""''. Assume all key parts to be strings or NULL.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (192) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_FOREIGN_KEYS', api_help_text => '

    Create a foreign keys string (note plural) like it is used in tpac (JSON list of Strings)
    by combining ''{"fks":[[...]]}'' with a list of keys parts (optional from right to left).
    Assume all key parts to be strings.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.
      p_3 - KeyPart3 varchar2.
      p_4 - KeyPart4 varchar2.
      p_5 - KeyPart5 varchar2.
      p_6 - KeyPart6 varchar2.
      p_7 - KeyPart7 varchar2.
      p_8 - KeyPart8 varchar2.
      p_9 - KeyPart9 varchar2.
      p_a - KeyParta varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (193) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_FOREIGN_KEYS_2', api_help_text => '

    Create a foreign keys string (note plural) like it is used in tpac (JSON list of Strings) by
    combining ''{"fks":[[...]]}'' with a list of two key parts. Key parts can be NULL 
    which then are converted to ''""''. Assume all key parts to be strings or NULL.

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.

    Return Parameter:
      string representing json foreign key.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (194) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_KEY_SN', api_help_text => '

    Create a key string like it is used in tpac (JSON list of String and number).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 number.

    Return Parameter:
      string representing json key.

    Restrictions:
      - KeyPart1 must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (195) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_KEY_SNN', api_help_text => '

    Create a key string like it is used in tpac (JSON list of String and number).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 number.
      p_3 - KeyPart3 number.

    Return Parameter:
      string representing json key.

    Restrictions:
      - KeyPart1 must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (196) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_KEY_SNS', api_help_text => '

    Create a key string like it is used in tpac (JSON list of Strings and Number).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 number.
      p_3 - KeyPart3 varchar2.

    Return Parameter:
      string representing json key.

    Restrictions:
      - String KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (197) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_NOT_NULL', api_help_text => '

    Return an empty string if p_value is null or "", otherwise return a comma plus
    a string representation of a JSON attribute (e.g. '',"p_name":"p_value"'').
    Used to append attributes to a JSON object only if the value is non-empty.

    Input Parameter:
      p_name  - AttributeName.
      p_value - AttributeValue.

    Return Parameter:
      NULL or next JSON attribute

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (198) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_NUM', api_help_text => '

    Return a number p_1 in JSON number format, if necessary use the given default ''0''.

    Input Parameter:
      p_1 - number as a string or NULL.
      p_2 - default input when p_1 is NULL.

    Return Parameter:
      string representing a number.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (199) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_NUMBER', api_help_text => '

    Return a number p_1 in JSON number format, if necessary use the given default ''null''.

    Input Parameter:
      p_1 - number as a string or NULL.
      p_2 - default input when p_1 is NULL.

    Return Parameter:
      string representing a number or ''null''

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (200) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_NUMSTR', api_help_text => '

    Return a JSON string representing a rounded and formatted input number p_1.
    The rounding precision is given as number of digits in p_2.

    Input Parameter:
      p_1 - input number.
      p_2 - precision for formatting (number of digits after the decimal point).

    Return Parameter:
      string representing a number or ''""''

    Restrictions:
      - full precision for p_2 below 0 or above 4
    
            ');
    l_sbsdb_api_scope_help_ntv (201) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_PREFIX', api_help_text => '

    Return a comma and the provided input. Used for appending a list of 
    attribute-value pairs to a given string.

    Input Parameter:
      p_value - string.

    Return Parameter:
      concatenated string

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (202) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_STRING', api_help_text => '

    Return a (properly JSON-escaped) string in double quotes.

    Input Parameter:
      p_string - input string.

    Return Parameter:
      escaped and wrapped output string.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (203) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_STRING_KEY', api_help_text => '

    Concatenate multiple key parts into a JSON list. Non-empty KeyParts only 
    (optional input parameters from right to left).

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.
      p_3 - KeyPart3 varchar2.
      p_4 - KeyPart4 varchar2.
      p_5 - KeyPart5 varchar2.
      p_6 - KeyPart6 varchar2.
      p_7 - KeyPart7 varchar2.
      p_8 - KeyPart8 varchar2.
      p_9 - KeyPart9 varchar2.
      p_a - KeyParta varchar2.

    Return Parameter:
      string representation of a JSON key, like wi use it in tpac.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (204) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_STRING_KEY_2', api_help_text => '

    Concatenate two key parts into a JSON list. Empty KeyParts are allowed.
    Using ''[]'' for p_1 when NULL
    Using ''""'' for p_2 when NULL

    Input Parameter:
      p_1 - KeyPart1 varchar2.
      p_2 - KeyPart2 varchar2.

    Return Parameter:
      string representation of a JSON key, like wi use it in tpac.

    Restrictions:
      - KeyParts must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (205) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_SUFFIX', api_help_text => '

    Return NULL if p_value is NULL, otherwise return p_value and a comma.
    Used to prepend JSON attribute pair(s) to existing string.

    Input Parameter:
      p_value - JSON attribute pair(s).

    Return Parameter:
      string to prepend or NULL

    Restrictions:
      - p_value must be JSON-escaped already.
    
            ');
    l_sbsdb_api_scope_help_ntv (206) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_TEXT', api_help_text => '

    Concatenate up to three strings by JSON-escaping them and concatenating with crlf.

    Input Parameter:
      p_string1 - TextPart1.
      p_string2 - TextPart2.
      p_string3 - TextPart3.

    Return Parameter:
      Lines of text (JSON-escaped and separated with crlf)

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (207) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_TRUE', api_help_text => '

    Create JSON attribute with name and boolean value (only if p_value is not NULL).

    Input Parameter:
      p_name  - AttributeName.
      p_value - boolean value or NULL.

    Return Parameter:
      Attribute value pair or NULL

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (208) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSON_TYPE', api_help_text => '

    Cast a value p_2 into JSON type p_1.

    Input Parameter:
      p_1 - type to cast to.
      p_2 - value to be casted.

    Return Parameter:
      JSON represetation of cast value

    Restrictions:
      - supported types: ''integer'', ''double'', ''boolean'', ''string''=default.
    
            ');
    l_sbsdb_api_scope_help_ntv (209) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSOND', api_help_text => '

    Prepare a json date kv-pair and append to p_start. Add a comma to p_start if it 
    does not end with ''{''.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start appended with a date attribute.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (210) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSOND0', api_help_text => '

    Prepare a json date kv-pair and append to p_start only if not null. 
    Add a comma to p_start if it does not end with ''{''.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start, possibly appended with a date attribute.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (211) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSONN', api_help_text => '

    Prepare a json number kv-pair and append to p_start. Add a comma to p_start if it 
    does not end with ''{''.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start appended with a number attribute.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (212) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSONN0', api_help_text => '

    Prepare a json number kv-pair and append to p_start only if not null. 
    Add a comma to p_start if it does not end with ''{''.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start, possibly appended with a number attribute.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (213) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSONS', api_help_text => '

    Prepare a json string kv-pair and append to p_start. Add a comma to p_start if it 
    does not end with ''{''.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start appended with a string attribute.

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (214) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON.JSONS0', api_help_text => '

    Prepare a json string kv-pair and append to p_start only if not null. 
    Add a comma to p_start if it does not end with ''{''.

    Input Parameter:
      p_start - optional prefix.
      p_key   - atribute name.
      p_value - attribute value.

    Return Parameter:
      p_start, possibly appended with a string attribute.

    Restrictions:
      - none.
     
            ');
    l_sbsdb_api_scope_help_ntv (215) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_JSON', api_help_text => '

    Libarary functions for working with JSON strings.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (216) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_KPI_BD.SP_TRY_KPI', api_help_text => '

    TODO.

    Input Parameter:
      sqlt_str_pacid - the name of the desired KPI - must be between KPI000 and KPI999.
      sqlt_str_bohid - TODO.

    Output Parameter:
      sqlt_str_bohid     - TODO.
      sqlt_int_records   - the number of data records processed.
      sqlt_int_error     - error code:
                           ok  - 0
                           nok - others
      sqlt_str_errormsg  - error message:
                           ok  - NULL
                           nok - others
      sqlt_int_retstatus - return status:
                           ok  - pkg_common.return_status_ok
                           nok - others

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (217) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_KPI_BD', api_help_text => '

    Implementation of the KPI calculation for the KPIs KPI000 to KPI999.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    15.11.2017  Create for Project SBS-17.08 Technical_Application_KPI_Plotter
    000SO    13.02.2019  HASH:1C78C9E9BD2632A6331BC08A4791F294 pkg_kpi_bd.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (218) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_KPI_BD1.SP_TRY_KPI', api_help_text => '

    TODO.

    Input Parameter:
      sqlt_str_pacid - the name of the desired KPI - must be between KPI000 and KPI999.
      sqlt_str_bohid - TODO.

    Output Parameter:
      sqlt_str_bohid     - TODO.
      sqlt_int_records   - the number of data records processed.
      sqlt_int_error     - error code:
                           ok  - 0
                           nok - others
      sqlt_str_errormsg  - error message:
                           ok  - NULL
                           nok - others
      sqlt_int_retstatus - return status:
                           ok  - pkg_common.return_status_ok
                           nok - others

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (219) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_KPI_BD1', api_help_text => '

    Implementation of the KPI calculation for the KPIs KPI000 to KPI999.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    13.11.2017  Create for Project SBS-17.08 Technical_Application_KPI_Plotter
    002SO    14.11.2017  First realistic KPI calculation, shortened context attribute names
    003SO    15.11.2017  Hint BDETAIL1 Queries
    000SO    13.02.2019  HASH:108F7898958681C4AF477A4C28CF431D pkg_kpi_bd1.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (220) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_KPI_BD2.SP_TRY_KPI', api_help_text => '

    TODO.

    Input Parameter:
      sqlt_str_pacid - the name of the desired KPI - must be between KPI000 and KPI999.
      sqlt_str_bohid - TODO.

    Output Parameter:
      sqlt_str_bohid     - TODO.
      sqlt_int_records   - the number of data records processed.
      sqlt_int_error     - error code:
                           ok  - 0
                           nok - others
      sqlt_str_errormsg  - error message:
                           ok  - NULL
                           nok - others
      sqlt_int_retstatus - return status:
                           ok  - pkg_common.return_status_ok
                           nok - others

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (221) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_KPI_BD2', api_help_text => '

    Implementation of the KPI calculation for the KPIs KPI000 to KPI999.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    14.11.2017  Create for Project SBS-17.08 Technical_Application_KPI_Plotter
    002SO    15.11.2017  Hint BDETAIL2 Queries
    003SO    29.11.2018  New KPI Item ''Bd2RateMtOutCh''   Percentage of IMS CH MT Delivery CDRs to total CH delivery CDRs
    004SO    29.11.2018  New KPI Item ''Bd2RateMtOutRoam'' Percentage of IMS Roaming MT Delivery CDRs to total Roaming delivery CDRs
    000SO    13.02.2019  HASH:39121CB67E35AC862A524BE6964C1CAC pkg_kpi_bd2.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (222) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_HB', api_help_text => '

    Message Event Consolidation DUMMY package for SBS1 Database.
    Referenced by PKG_MEC_IC

    MODIFICATION HISTORY (for details see VSS repository)
    Person      Date        Comments
    000SO       13.02.2019  HASH:D15EFD1F34D581259C5923104E63C7C0 pkg_mec_hb.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (223) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.IMS_LTE_CELL_ID', api_help_text => '

    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (224) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.IMS_WIFI_MCC', api_help_text => '

    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (225) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.IMS_WLAN_NODE_ID', api_help_text => '

    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (226) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.IS_ROAMING_PANI', api_help_text => '

    TODO.

    Input Parameter:
      p_paniheader - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (227) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.OPKEY_FROM_GT', api_help_text => '

    TODO.

    Input Parameter:
      msisdn - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (228) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.SP_INSERT_CSV', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (229) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.SP_INSERT_HEADER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (230) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0.SP_UPDATE_HEADER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (231) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_ASCII0', api_help_text => '

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
    016SO        01.03.2004  Reassigning the schedule flags is unnecessary ''S'' should be the only possible value in ASCII0 file
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
    037SO        03.09.2004  Replacing all referen');
    l_sbsdb_api_scope_help_ntv (232) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_CSV.SP_INSERT_CSV', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (233) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_CSV.SP_INSERT_HEADER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (234) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_CSV.SP_UPDATE_HEADER', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (235) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_IC_CSV', api_help_text => '

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
    
    ');
    l_sbsdb_api_scope_help_ntv (236) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.BN_STATS_EMAILS', api_help_text => '

    Return concatenated eMail adresses for BN-Statistics for given AC_ID.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Concatenated eMail adresses.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    27.08.2011  Created
    002SO    23.02.2017  Use ACCOUNT.AC_BN_STATS_EMAILS directly
    003SO    25.04.2017  Longer Variables
    004SO    05.05.2017  Simplify Body
    
            ');
    l_sbsdb_api_scope_help_ntv (237) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_ADRID_MAIN_EMAIL', api_help_text => '

    Used for evaluation of main eMail-Adress of Job.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (238) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_BN_STATS_EMAILS', api_help_text => '

    Return concatenated eMail adresses for BN-Statistics for given statistics
    job.

    Uses function BN_STATS_EMAILS(ac_id).

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    27.08.2011  Created
    
            ');
    l_sbsdb_api_scope_help_ntv (239) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_BOHIDEXEC', api_help_text => '

    Used for evaluation of BOH_ID belonging to the statistic executor.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    
            ');
    l_sbsdb_api_scope_help_ntv (240) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_DATEFROM', api_help_text => '

    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (241) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_DATETILL', api_help_text => '

    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (242) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_DATETO', api_help_text => '

    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (243) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_EXPANDED_SQL', api_help_text => '

    Used for evaluation of job sql.

    Input Parameter:
      p_job_id  - TODO.
      p_job_sql - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    --MODIFICATION HISTORY
    --Code  Date        Comments
    ------- ----------  ----------------------------------------------
    --001SO 09.09.2010  Add replacement of JOB_BOHIDEXEC function
    --002SO 05.09.2011  Expand buffer variables
    
            ');
    l_sbsdb_api_scope_help_ntv (244) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_LA_INVOICE_EMAILS', api_help_text => '

    Return concatenated eMail adresses for invoices for given statistics job.

    Uses function LA_INVOICE_EMAILS(ac_id).

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      Concatenated eMail adresses.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    08.12.2009  Created
    
            ');
    l_sbsdb_api_scope_help_ntv (245) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_LOOPVAR', api_help_text => '

    TODO.

    Input Parameter:
      p_job_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    002SO    17.03.2012  Correct wrong result type
    
            ');
    l_sbsdb_api_scope_help_ntv (246) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_PARAMETER', api_help_text => '

    Used for evaluation of reporting parameters.

    Input Parameter:
      p_job_id   - TODO.
      p_par_name - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (247) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.JOB_SEARCH_PARAMETER', api_help_text => '

    Used for evaluation of reporting parameters.

    Input Parameter:
      p_job_id   - TODO.
      p_par_name - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (248) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.LA_INVOICE_EMAILS', api_help_text => '

    Return concatenated eMail adresses for invoices for given AC_ID.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      Concatenated eMail adresses.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    08.12.2009  Created
    002SO    23.02.2017  Use ACCOUNT.AC_LA_INVOICE_EMAILS directly
    003SO    25.04.2017  Longer Variables
    004SO    05.05.2017  Simplify Body
    
            ');
    l_sbsdb_api_scope_help_ntv (249) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.LONGID_RANGE', api_help_text => '

    Return rendered range information for LongID.

    Input Parameter:
      p_longid1 - TODO.
      p_longid2 - TODO.

    Return Parameter:
      Range information.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    ------   ----------  -------------------------------------------
    001SO    02.08.2017  Created
    002SO    04.08.2017  suppress single LongID range suffix and remove CNT
    
            ');
    l_sbsdb_api_scope_help_ntv (250) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_GET_JOB_DETAILS', api_help_text => '

    TODO.

    Input Parameter:
      p_packingid - TODO.
      p_jobid     - TODO.

    Output Parameter:
      p_refcursor    - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (251) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_GET_JOB_QUERIES', api_help_text => '
 -- 004SO
    TODO.

    Input Parameter:
      p_packingid - TODO.
      p_jobid     - TODO.

    Output Parameter:
      p_refcursor    - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (252) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_GET_PACKING_ID', api_help_text => '

    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_packingid   - TODO.
      p_thread      - TODO.

    Output Parameter:
      p_packingid    - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (253) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_INSERT_HEADER', api_help_text => '
 -- 005SO
    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_packingid   - TODO.
      p_appname     - TODO.
      p_appver      - TODO.
      p_thread      - TODO.
      p_taskid      - TODO.
      p_hostname    - TODO.

    Output Parameter:
      p_packingid    - TODO.
      p_headerid     - TODO.
      p_jobid        - TODO.
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (254) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_MODIFY_HEADER', api_help_text => '
 -- 015SO
    TODO.

    Input Parameter:
      p_headerid - TODO.
      p_appname  - TODO.
      p_appver   - TODO.
      p_thread   - TODO.
      p_taskid   - TODO.
      p_hostname - TODO.

    Output Parameter:
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (255) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_REGISTER_OUTPUT', api_help_text => '
 -- 005SO
    TODO.

    Input Parameter:
      p_packingid  - TODO.
      p_jobid      - TODO.
      p_filepath   - TODO.
      p_filename   - TODO.
      p_filesize   - TODO.
      p_outputtype - TODO.

    Output Parameter:
      p_outputid     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (256) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC.SP_UPDATE_HEADER', api_help_text => '

    TODO.

    Input Parameter:
      p_headerid   - TODO.
      p_jobid      - TODO.
      p_filename   - TODO.
      p_filedate   - TODO.
      p_maxage     - TODO.
      p_dataheader - TODO.
      p_reccount   - TODO.
      p_errcount   - TODO.
      p_datefc     - TODO.
      p_datelc     - TODO.

    Output Parameter:
      p_filename     - TODO.
      p_errorcode    - TODO.
      p_errordesc    - TODO.
      p_returnstatus - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (257) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_MEC_OC', api_help_text => '

    Output Converter.
    Getting Data out from SBS2.

    MODIFICATION HISTORY
    Person       Date        Comments
    001SO        27.01.2010  Created based on PKG_MEC_IC_CSV
    002SO        28.01.2010  Add Parameter p_FileName to insert header
    003SO        09.02.2010  Add Parameter p_JobId and rename to SP_GET_JOB_DETAILS
    004SO        09.02.2010  Add SP_GET_JOB_QUERIES
    005SO        09.02.2010  Add SP_REGISTER_OUTPUT
    006SO        11.02.2010  Change signature of SP_REGISTER_OUTPUT
    007DA        23.02.2010  Method SP_GET_PACKING_ID added
    008DA        16.03.2010  GetJobDetails() now returns also Email related attribute values (right outer join)
    009DA        17.03.2010  Added attributes NOT_MAXATTSIZE & NOT_ETID to GetJobDetails() output
    010DA        18.03.2010  Added attributes STAC_SMTPHOST & STAC_SMTPPORT to GetJobDetails() output
    011DA        19.03.2010  Added attribute PAC_NOTIFICATION to GetJobDetails() output
    012DA        19.03.2010  PAC_COMPRESS, PAC_FIELDSEP and PAC_LINESEP now taken from PACKING table
    013SO        28.03.2010  Handle 2 new workflow exceptions
    014SO        28.03.2010  Use prepared JobSql for Individual Statistics generation
    015SO        29.03.2010  Implement SP_MODIFY_HEADER, used by SPTRY output converters
    016SO        07.04.2010  Adapted for use on SBS2 database
    017SO        07.04.2010  Adapted for use on SBS2 database
    018SO        12.04.2010  Remove wrong packing update
    019SO        14.04.2010  Correct parameter typo
    020SO        24.04.2010  Remove exception handler for other errors
    021SO        08.05.2010  Use generalized job parameter replacement
    022DA        27.05.2010  New Packing attribute PAC_ENCODINGTYPE implemented
    023SO        12.08.2010  Implement dynamic address evaluation for looper statistics notifications
    024SO        26.08.2010  Implement sorting for transaction statements with job queries
    025SO        09.09.2010  Correct Token to <EndTransaction>
    026SO        10.09.2010  Correct name NOT_ADRTO back to how it was before 025SO
    027SO        08.12.2010  Implement eMail sending of LA-invoices to several adddresses
    028SO        15.09.2011  Implement eMail sending of BN-statistics
    029SO        14.12.2011  Remove schema qualifier "S B S 0 ."
    030SO        06.08.2017  Remove deprecated notification address placeholder
    000SO        13.02.2019  HASH:AE92178C3885B12693518AD05B118840 pkg_mec_oc.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (258) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.PARTREORG_EXCH_PARTITION', api_help_text => '

    TODO.

    Input Parameter:
      own  - TODO.
      tbl  - TODO.
      part - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (259) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.PARTREORG_PREPARE', api_help_text => '

    TODO.

    Input Parameter:
      own  - TODO.
      tbl  - TODO.
      part - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (260) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.CLEANUP', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (261) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.CLEANUP_DELETE', api_help_text => '

    TODO.

    Input Parameter:
      pintablename   - TODO.
      pinwhereclause - TODO.
      poutdeleted    - TODO.

    Output Parameter:
      poutdeleted - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (262) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_INFO_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (263) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_INFO_PARTITIONS_MAN', api_help_text => '

    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (264) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_MMSC_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (265) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_MMSC_PARTITIONS_MAN', api_help_text => '

    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (266) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_MSCA_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (267) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_MSCA_PARTITIONS_MAN', api_help_text => '

    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (268) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_SMSA_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (269) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_SMSA_PARTITIONS_MAN', api_help_text => '

    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (270) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_SMSC_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (271) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_SMSC_PARTITIONS_MAN', api_help_text => '

    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (272) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_SMSD_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (273) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_ADD_SMSD_PARTITIONS_MAN', api_help_text => '

    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (274) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_CPR_INFO_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (275) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_CPR_MMSC_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (276) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_CPR_MSCA_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (277) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_CPR_REVI_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (278) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_CPR_SMSC_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (279) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG.SP_CPR_SMSD_PARTITIONS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (280) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_PARTAG', api_help_text => '

    Used for the management of daily partitions and data ageing.
    Execute Immediate Statements in Partition Ageing.
    Log attempts and results to the SCRIPT table with the help of PKG_SCRIPT.

    MODIFICATION HISTORY
    Code  Date        Comments
    001SO 09.11.2005  Package creation
    002SO 19.11.2005  Bring all data ageing procedures here from the other packages
    002SO 20.11.2005  Do not try to rebuild indexes ONLINE. Does not work in execute immediate.
    003SO 20.11.2005  Use MODIFY DEFAULT ATTRIBUTE when creating normal (non IOT) partitions with indexes
    004SO 20.11.2005  Rename partition and tablespase prefix from MMCA to MTRC (MessageTRansCoder)
    005SO 17.10.2006  Include MMS Bulk Index table (only B) into partition ageing
    006SO 14.09.2009  Take over from SBS2. Replace daily ageing by monthly ageing.
    007SO 21.10.2009  Correct Tablespaces
    008SO 15.01.2010  Use PKG_COMMON instead of PKG_BDETAIL_COMMON
    009SO 15.01.2010  Add partition ageing for INFO, MMSC, MMSB and MSCA
    010SO 02.04.2010  Correct BDINFO -> BDITEM
    011SO 03.04.2010  Add partition ageing for REVI-Tables (date code partition keys)
    012SO 06.03.2012  Clean out obsolete code for MMSB
    013SO 01.05.2012  Create new partition in single TS using _UC postfix
    014SO 06.05.2012  Correct TS name for SMS IW archive
    015SO 14.05.2012  Correct TS name for other tables
    016SO 14.05.2012  Remove code fro BDITEM
    017SO 14.05.2012  Remove code fro REVI_BLK
    018SO 29.05.2012  Bugfix Tablespace naming
    019SO 16.05.2013  Implement table compression and partition exchange
    020SO 13.06.2013  Use ''NC'' instead on ''UC'' for uncompressed tablespaces
    021SO 23.08.2013  Improve error logging with stack trace
    022SO 21.10.2013  Add BDETAIL7 for M2M SMS Delivery CDRs
    023SO 09.11.2013  Use SMSD as partition Prefix for M2M Data in BDETAIL7
    024SO 01.06.2015  Use *_UC for partitions which are to be compressed, *_NC for others
    025SO 01.06.2015  Use *_QC for compressed partitions
    026SO 13.06.2015  Compress BDETAIL7 partitions too
    027SO 09.09.2015  Patch Compression rules for re-compressing badly compressed older partitions $$$$ TO BE REMOVED $$$$
    028SO 23.11.2017  Revert 028SO
    029SO 23.11.2017  Compress BDKPI partitions too
    030SO 23.11.2017  Roll BDKPI partitions too
    000SO 13.02.2019  HASH:ADABEDFF51D6B6D5FFF4026F09E1429B pkg_partag.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (281) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVA.SP_TRY_REVA_RECENT_MSC', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (282) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVA.SP_TRY_REVA_RECENT_OTHERS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (283) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVA.SP_TRY_REVA_RECENT_SMSC', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (284) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVA', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Person       Date        Comments
    AH           2004-08-11  Creation
    001SO        2004-10-20  Add calling parameters BIH_ID, BOH_ID for INSERT_WARNING
    002SO        2004-10-20  Remove unused exceptions
    003SO        2004-10-20  Set RecordsAffected
    004SO        2004-10-20  Remove dependence from BDETAIL4
    005SO        2004-10-20  Set / Reset ErrorMsg
    006SO        2004-10-20  Check all BiHeader States (''''RDY'''',''''ERR'''', ''''IDX'''', ''''IDE'''')
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
    019SO        2005-11-12  Also consider indexing intermediate states ''idx'' and ''ide'' for MMS files (used only for migration)
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
    
    ');
    l_sbsdb_api_scope_help_ntv (285) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.REVI_INDEX_FILE', api_help_text => '
 -- 016SO
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_boh_id - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (286) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVICD', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (287) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVICS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (288) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVIM', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (289) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVIPRE', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (290) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVIPRM', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (291) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVIPRS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (292) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI.SP_CONS_REVIS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (293) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_REVI', api_help_text => '

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
    
    ');
    l_sbsdb_api_scope_help_ntv (294) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_SCRIPT.CREATE_AND_DELETE', api_help_text => '

    TODO.

    Input Parameter:
      p_scr_name  - TODO.
      p_scr_line  - TODO.
      p_scr_table - TODO.
      p_scr_where - TODO.
      p_scr_bohid - TODO.
      p_scr_name  - TODO.

    Output Parameter:
      p_scr_esid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (295) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_SCRIPT.CREATE_AND_EXECUTE', api_help_text => '

    TODO.

    Input Parameter:
      p_scr_name  - TODO.
      p_scr_line  - TODO.
      p_scr_text  - TODO.
      p_scr_job   - TODO.
      p_scr_bohid - TODO.

    Output Parameter:
      p_scr_esid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (296) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_SCRIPT.ENTRY_STATE', api_help_text => '

    TODO.

    Input Parameter:
      p_scr_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (297) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_SCRIPT', api_help_text => '

    Handle inserts and updates in script logging table SCRIPT.

    Used for the management of daily partitions and data ageing
    Execute Immediate Statements in Partition Ageing and Cleanup
    Log attempts and results to the SCRIPT table with the help of PKG_SCRIPT.

    MODIFICATION HISTORY
    Person Date        Comments
    001SO  09.11.2005  Package creation
    002SO  29.11.2016  Use dynsql DBA package for immediate sql execution
    003SO  29.11.2016  Add CREATE_AND_DELETE method calling dynsql.delete
    000SO  13.02.2019  HASH:97E5B7354821155F09C122EADE14FE6B pkg_script.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (298) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.CLEANJOBS', api_help_text => '

    TODO.

    Input Parameter:
      hrstoexec - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (299) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.GETNEXTEXECDATE', api_help_text => '

    TODO.

    Input Parameter:
      incaller  - TODO.
      inpacid   - TODO.
      inrefdate - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (300) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.CHECKBASETABLEDATA', api_help_text => '

    TODO.

    Input Parameter:
      inpacid      - TODO.
      returnstatus - TODO.

    Output Parameter:
      outdatefrom     - TODO.
      outdateto       - TODO.
      outdrop         - TODO.
      outdropperiod   - TODO.
      outdatefromraw  - TODO.
      outdatetoraw    - TODO.
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (301) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.GETNEXTJOB', api_help_text => '

    TODO.

    Input Parameter:
      p_pact_id    - TODO.
      p_boh_id     - TODO.
      returnstatus - TODO.

    Output Parameter:
      arrkey          - TODO.
      arrvalue        - TODO.
      arrnote         - TODO.
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (302) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.SCHEDULESTATS', api_help_text => '

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
    
            ');
    l_sbsdb_api_scope_help_ntv (303) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.SP_NEW_STA_JOB', api_help_text => '

    TODO.

    Input Parameter:
      p_stajparentid          - TODO.
      p_stajpacid             - TODO.
      p_stajinfo              - TODO.
      p_stajltvalue           - TODO.
      p_stajperiodid          - TODO.
      p_acidcre               - TODO.
      p_stajnotification      - TODO.
      p_stajnotid             - TODO.
      p_stajnotemailsuccess   - TODO.
      p_stajnotemailfailure   - TODO.
      p_stajnotsendattachment - TODO.
      p_errnumber             - TODO.
      p_errdesc               - TODO.
      p_returnstatus          - TODO.

    Output Parameter:
      p_stajid          - TODO.
      p_recordsaffected - TODO.
      p_errnumber       - TODO.
      p_errdesc         - TODO.
      p_returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (304) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.SP_NEW_STA_JOBPARAM', api_help_text => '

    TODO.

    Input Parameter:
      p_stajid       - TODO.
      p_stajpname    - TODO.
      p_stajpvalue   - TODO.
      p_errnumber    - TODO.
      p_errdesc      - TODO.
      p_returnstatus - TODO.

    Output Parameter:
      p_recordsaffected - TODO.
      p_errnumber       - TODO.
      p_errdesc         - TODO.
      p_returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (305) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.SP_NEW_STA_JOBSQLS', api_help_text => '

    TODO.

    Input Parameter:
      p_stajid     - TODO.
      errorcode    - TODO.
      errormsg     - TODO.
      returnstatus - TODO.

    Output Parameter:
      recordsaffected - TODO.
      errorcode       - TODO.
      errormsg        - TODO.
      returnstatus    - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (306) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.WATCHPACKAGESTATECHANGES', api_help_text => '

    TODO.

    Input Parameter:
      vpacid      - TODO.
      voldpacesid - TODO.
      vnewpacesid - TODO.
      voldpacltid - TODO.
      vnewpacltid - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (307) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS.WRITESYSLOG', api_help_text => '

    TODO.

    Input Parameter:
      pmethod    - TODO.
      psqlcode   - TODO.
      psqlerrm   - TODO.
      pparameter - TODO.
      ploggedon  - TODO.

    Restrictions:
      - TODO.
    
            ');
    l_sbsdb_api_scope_help_ntv (308) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_STATS', api_help_text => '

    Project: Statistical Module.
    Procedures for WEB, GENERATOR and SENDER (see XPIOC).

    MODIFICATION HISTORY
    Person       Date        Comments
    AHAUPENTHAL  31-03-2003  Creation
    AH           01-04-2003  checkDependencies
    AH           03-04-2003  cleanJobs, getNextJob
    AH           03-04-2003  scheduleStats: repeat until...
    AH           06-04-2003  scheduleStats: anythingToDo??
    AH           15-04-2003  executer: getNextJob
    AH           16-04-2003  executer: setJobResult
    AH           21-04-2003  scheduleStats: repeat until, typ II reports with loop
    AH           21-04-2003  getNextJob: checkDependencies for all jobs
    AH           21-04-2003  doAdminCleanJobs
    AH           22-05-2003  insert into table WARNINGS
    AH           26-05-2003  getNextJob: collect notification data
    AH           03-06-2003  scheduleJob: include ExcecutionDelay and job periodid
    AH           10-06-2003  Schedule Individual Jobs and repeat them; setJobResult -> update Repeat Monkeys
    AH           13-07-2003  getNextExecDay updated
    AH           15-07-2003      Transaction read only
    AH           16-07-2003  getNextDate -> individual
    AH           17-07-2003      Individuals, getNextExecDate
    AH           21-07-2003  getNextExecDate
    AH           07-01-2004  scheduleStats -> Iterator ID for Loopings (SCHNAPPS)
    AH           08-04-2004  Conditional Execution added to scheduleStats
    AA           19-03-2004  use Upper() function in cursors cNote and cNoteParam in procedure getNextJob()
    AH           23-04-2004  RecordCount for TopStopReport (getNextJob)
    AH           28-04-2004  getNextJob: Extend Array to XPIOC for PDF
    AH           10-05-2004      getNextJob: Extend Array to XPIOC for ARCHIVE DIR and USER OUTPUT DIR
    AA           30-06-2004  SP_NEW_STA_JOBSQLS: replace the parameters tokens for ShortId, MsisndnA, MsisdnB
    AH           05-07-2004  scheduleStats: No lower(vSql) because of CONSTANTS
    AH           28-07-2004  scheduleStats: bLooped
    001AA        18-08-2004  Added procedure for parameter ''SP_REPLACE_PARAMS'' replacement
    002AH        28-10-2004  scheduleStats: Add individual packing pac_execdelay for STATIND (SBS08.55)
    003SO        14-12-2004  Go back to days for parameter pac_execdelay and
    004SO        14-12-2004  Consider more than one dependency
    005SO        14-12-2004  checkDependenciesWeb removed. Not used any more
    006SO        15.12.2004  Simplify query condition in STA_GETNEXTJOB
    007SO        15.12.2004  Change rescheduling because of dependencies in STA_GETNEXTJOB
    008SO        15.12.2004  Catch exceptions in case of nonexisting BaseTable Info. No BT checking done.
    009AA        23.12.2004  Added sp GetJobNotifData to return Job local notification data to Xpioc
    010AA        30.12.2004  Added new parameters to SP_NEW_STA_JOB sp (p_StajNotification,p_StajNotId,p_StajNotEmailSuccess,p_StajNotEmailFailure,p_StajNotSendAttachment)
    011SO        04.04.2005  Consider locked workflow task as not done when checking dependencies
    012SO        13.03.2006  Correct scheduling time for weekly stats reports
    013SO        03.05.2007  Consider all packing states of forerunner jobs when checking dependency violations
    014SO        01.02.2008  Correct false truncation in scheduler
    015SO        02.02.2010  Create MEC_OC Stubs NEW_STA_JOB_xxx and UPDATE_STA_JOB_xxx
    016SO        25.03.2010  Remove MEC_OC Stubs NEW_STA_JOB_xxx and UPDATE_STA_JOB_xxx (implemented in PKG_STATS)
    017SO        28.03.2010  Implement scheduleIndividualStats as standard CONSOL job
    018SO        29.03.2010  Convert scheduleIndividualStats from CONSOL to SPTRY
    019SO        29.03.2010  Use new generalized method for inserting a dummy header in SPTRY
    020SO        29.03.2010  Correct error handling in scheduleIndividualStats (handle suspend)
    021SO        23.04.2010  Also lock working jobs together with locking of ');
    l_sbsdb_api_scope_help_ntv (309) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_CURRENCY_EXR_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_exr_curid - TODO.
          p_exr_start - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           10.08.2016  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (310) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_CURRENCY_EXR_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_cur_id   - TODO.
          p_exr_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           10.08.16    Created
        
            ');
    l_sbsdb_api_scope_help_ntv (311) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_CURRENCY_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_cur_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           10.08.16    Created
        
            ');
    l_sbsdb_api_scope_help_ntv (312) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_TOAC_CON_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           21.07.2016  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (313) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_TOAC_CON_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_con_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           21.07.2016    Created
        SS           22.07.2016    Added Name, Opkey, json into contract
        001SO        11.11.2016    Re-Implement table difference with set operations
        002SS        11.11.2016    Fixed bad condition fir MMS prices
        003S0        26.05.2017    Fill in / fix minimum message sizes for MMS transport Prices
        004SO        07.08.2016    Added CON_DATECRE, CON_DATEMOD attributes
        005SS        11.10.2017    changed the VATO and VATT number precision
        006SO        15.11.2018    Remove CON_DEMO and CON_COMMENT
        
            ');
    l_sbsdb_api_scope_help_ntv (314) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_TOAC_SMSC_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_smsc_code     - TODO.
          p_smsc_conopkey - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           05.10.2017  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (315) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO.GPSH_TOAC_SMSC_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_conop_key - TODO.
          p_smsc_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           05.10.17    Created
        
            ');
    l_sbsdb_api_scope_help_ntv (316) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TOAC_CPRO', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (317) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_PRICE_CONTENT_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_pme_pmvid - TODO.
          p_pme_json  - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.16    Created
        SS001        28.02.17    Deleting and inserting if the rows and size of the list dont match
        SS002        17.04.17    checking if the pmv_id exists if not integrity constraint error occurs
        SS003        28.01.18    PM content prepaid revenue not using nvl
        SS004        29.01.18    PM PME_AMOUNTMO removed nvl as ACU and SPO are required fields
        SS005        29.01.18    Checking difference between json and table using (A - B) <> 0 and (B - A) <> 0
        
            ');
    l_sbsdb_api_scope_help_ntv (318) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_PRICE_MODEL_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_pm_id   - TODO.
          p_pm_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.16    Created
        
            ');
    l_sbsdb_api_scope_help_ntv (319) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_PRICE_TRANSPORT_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_pmvt_pmvid - TODO.
          p_pmvt_json  - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.16    Created
        SS001        17.04.17    checking if the pmv_id exists if not integrity constraint error occurs
        SS002        05.05.17    Deleting and inserting if the rows and size of the list dont match
        
            ');
    l_sbsdb_api_scope_help_ntv (320) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_PRICE_VERSION_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_pmv_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           26.07.2016  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (321) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_PRICE_VERSION_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_pmv_pmid - TODO.
          p_pmv_id   - TODO.
          p_pmv_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.2016  Created
        SO001        16.02.2017  Defaul NULL end Date to 01.01.2100
        SS002        17.04.17    checking if the pm_id exists if not integrity constraint error occurs
        
            ');
    l_sbsdb_api_scope_help_ntv (322) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_CON_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           11.04.2016  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (323) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_CON_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_con_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           11.04.2016  Created
        SO           18.04.2016  Added CON_SRCTYPE
        SS           25.07.2016  Added CON_SETOPT
        001SO        07.08.2016  Added CON_DATECRE, CON_DATEMOD attributes
        SS           11.01.2018  Removed CON_IGNORE_DUOBILL attribute
        002SS        15.02.2018  Removed CON_MFLID and added CON_PRICEPG
        003SO        15.11.2018  Remove CON_DEMO CON_PROTOCOL
        003SS        16.11.2018  Changed interface to accept json and added MWD paramters
        
            ');
    l_sbsdb_api_scope_help_ntv (324) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_CS_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_cs_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           28.08.2016  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (325) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_CS_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_cs_id    - TODO.
          p_con_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           28.08.16    Created
        SS           20.03.17    added ESID Check for update
        
            ');
    l_sbsdb_api_scope_help_ntv (326) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_ac_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           24.02.2017  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (327) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_KEYWORD_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           28.08.2016  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (328) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_KEYWORD_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_key_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS001        28.09.2016  Created
        SO002        28.09.2016  Counter datatypes and comparison changed
        SS003        05.05.2017  Checking the count of input and data in db before comparing values
        
            ');
    l_sbsdb_api_scope_help_ntv (329) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_LONGID_MAP_DEL', api_help_text => '

        TODO.

        Input Parameter:
          p_longm_longid1 - TODO.
          p_longm_longid2 - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           21.06.2017  Created
        
            ');
    l_sbsdb_api_scope_help_ntv (330) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_LONGID_MAP_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_longid_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           25.04.2016  Created
        SO           21.06.2017  Deletion added (to be converted to use JSON)
        SS           22.06.2017  Using JSON input
        
            ');
    l_sbsdb_api_scope_help_ntv (331) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO.GPSH_TPAC_PUT', api_help_text => '

        TODO.

        Input Parameter:
          p_ac_id   - TODO.
          p_ac_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           24.02.2017  Created
        SS           25.07.2017  Added MBUNIT
        
            ');
    l_sbsdb_api_scope_help_ntv (332) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_TPAC_CPRO', api_help_text => '

    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (333) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.PKG_ZONING', api_help_text => '

    Contains all the ZONE-related function and procedures.
    
    This procedure applies the Zoning rules to the input data and returns the ZONE
    
    
        -- Start template for smsc zone lookup -------
        PROCEDURE sp_get_zone_id_smsc
        IS
        BEGIN
            NULL;
        EXCEPTION
            WHEN OTHERS
            THEN
                errorcode := SQLCODE;
                errormsg := SQLERRM;
                returnstatus := 0;
                p_zoneid := NULL;
        END sp_get_zone_id_smsc;
        -- End  template for smsc zone lookup -------
    
    
    Called from:
        PKG_BDETAIL_MSC.SP_INSERT_MSC
    
    MODIFICATION HISTORY
    Person      Date         Comments
    AA           03.06.2002  created the package and procedure (SP_GET_ZONE_ID)
    000SO        13.02.2019  HASH:15B9FD10CA8E0A55730E81382ECE04F4 pkg_zoning.pkb
    
    ');
    l_sbsdb_api_scope_help_ntv (334) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_API_LIB', api_help_text => '

    SBSDB specific auxiliary functions for SBSDB standard tasks.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (335) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.DBUNAME', api_help_text => '

    Returns name of the database as specified in the DB_UNIQUE_NAME initialization parameter.
    
            ');
    l_sbsdb_api_scope_help_ntv (336) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.IS_CDB', api_help_text => '

    Checks whether the current database is a CDB.
    
            ');
    l_sbsdb_api_scope_help_ntv (337) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.IS_OS_WINDOWS', api_help_text => '

    Checks whether the underlying operating system is Windows.
    
            ');
    l_sbsdb_api_scope_help_ntv (338) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.IS_VALID_DB_VERSION', api_help_text => '

    Checks if the database version is still supported for an operation

    Parameters:
       p_version_required_in           IN PLS_INTEGER
       p_release_required_in           IN PLS_INTEGER

    Returns:
      - true, if the database version is ok for the operation
      - false, if the database version is not ok for the operation
    
            ');
    l_sbsdb_api_scope_help_ntv (339) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.PDBNAME', api_help_text => '

    If queried while connected to a CDB, returns the current container name.
    Otherwise, returns null.
    
            ');
    l_sbsdb_api_scope_help_ntv (340) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.SBSDB_SCHEMA', api_help_text => '

    Returns SBSDB installation schema.
    
            ');
    l_sbsdb_api_scope_help_ntv (341) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON.RAISE_NON_VALID_DB_VERSION', api_help_text => '

    Raises an exception if the workflow requires a database version/release
    which is higher than the currently installed version

    Parameters:
        p_version_required_in - integer (version 11 or 12 for now)
        p_release_required_in - integer (release 0,1,2,..)
        p_err_msg_in          - exception error message or NULL for default
        p_variable_1_in       - message token replacement for :1
        p_variable_2_in       - message token replacement for :2
    
            ');
    l_sbsdb_api_scope_help_ntv (342) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_DB_CON', api_help_text => '

    Back-end package for managing database-related tasks.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (343) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_ERROR_CON.RAISE_APPL_ERROR', api_help_text => '

    Raises a generic application error

    Parameters:
        p_errcode_in        - the SQLCODE
        p_err_msg_in        - the error text to print (or NULL for the default)
        p_variable_1_in     - message token replacement for :1
        p_variable_2_in     - message token replacement for :2
        ...
    
            ');
    l_sbsdb_api_scope_help_ntv (344) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_ERROR_CON', api_help_text => '

    SBSDB application exception definitions
    Generic exception handling and logging

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (345) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_ERROR_LIB.LOG', api_help_text => '

   Creates the error message and calls the print and logging utility

   Parameters:
       p_errcode_in             - the SQLCODE
       p_errmsg_in              - the error text to print (or NULL for the default)
       p_log_scope_in           - the logging scope  <package>.<procedure>
       p_extra_in               - optional attachment as clob
       p_log_param_[1 .. 30]_in - optional interesting input parameter name and value
   
            ');
    l_sbsdb_api_scope_help_ntv (346) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_ERROR_LIB', api_help_text => '

    SBSDB application exception definitions
    Generic exception handling and logging

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (347) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_HELP_LIB.HELP', api_help_text => '

     Allows a search in the SBSDB help pages based on api_group (package name) or api_method (function or procedure name).
     The search is done with a LIKE match (ESCAPE ''\'').
     If the wildcard ''%'' is absent in the search filter, the search filter is prefixed and suffixed by ''%''.

     The resulting output depends on how many matches are found:

     - only 1 match:         Returns a single help page for a SBSDB api_method or a SBSDB api_group
     - more than 1 match:    Returns a list of all matching help commands for drill down to the detail pages

     Examples:

     - sbsdb_help()
         Shows a list of all possible help commands.
         The list includes commands for which the user has no execute permission.

     - sbsdb_help(''user'')
         Shows a list of all help commands where the api_group or the api_method contains ''user''.

     - sbsdb_help(''user_mgmt'')
         Shows a list of help commands for the package user_mgmt.
         This includes a link to the summary for the package itself plus one link per method in this package.

     - sbsdb_help(''user_mgmt.set'')
         Shows all set... api_methods for the package user_mgmt.
         Because we only have one such method, this will result in a direct help page ouptput
         for the user_mgmt.set_config api_method.

     - sbsdb_help(''\_mgmt.'')
         Shows all api_methods for all packages which are named ..._mgmt but not the package summary

     - sbsdb_help(''%mgmt'')
         Shows links to all package descriptions for packages named ...mgmt but not for their methods
      
            ');
    l_sbsdb_api_scope_help_ntv (348) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_HELP_LIB', api_help_text => '

   Implementation package for providing help in the form of searchable MAN pages

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (349) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_IO_LIB.INS_SBSDB_LOG', api_help_text => '

     Application uses this to log errors and events.

     Parameters:
         p_ckey_in      identification of the logging entry
         p_cvalue_in    content of the logging entry
                                                                         
            ');
    l_sbsdb_api_scope_help_ntv (350) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_IO_LIB', api_help_text => '

    Interface to the file system
    Implements file system methods to be used by the application

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (351) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.GET_VALID_JSON', api_help_text => '

    Returns always a valid JSON.

    Parameters:
       p_json_in  the string to be validated

    Returns:
      - unchanged input value, if the input value contains a valid JSON
      - {"invalid_json":"<p_json_in_out>"}, else
    
            ');
    l_sbsdb_api_scope_help_ntv (352) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.IS_VALID_JSON', api_help_text => '

    Checks if a given string contains a valid JSON.

    Parameters:
       p_json_in  the string to be validated

    Returns:
      - true, if the given string contains a valid JSON
      - false, else
    
            ');
    l_sbsdb_api_scope_help_ntv (353) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_ARRAY', api_help_text => '

    Creates a new JSON containing one JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the new JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (354) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_ARRAY_ADD', api_help_text => '

    Creates a new JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the modified incomplete JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (355) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_ARRAY_FIRST', api_help_text => '

    Creates the first JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the new incomplete JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (356) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_ARRAY_LAST', api_help_text => '

    Creates the last JSON member with a JSON element of type array.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type array
                           (the outer square brackets are optional)

    Returns:
      - the final JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (357) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OBJECT', api_help_text => '

    Creates a new JSON containing one JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the new JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (358) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OBJECT_ADD', api_help_text => '

    Creates a new JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the modified incomplete JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (359) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OBJECT_FIRST', api_help_text => '

    Creates the first JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the new incomplete JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (360) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OBJECT_LAST', api_help_text => '

    Creates the last JSON member with a JSON element of type object.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type object
                           (the outer curly brackets are optional)

    Returns:
      - the final JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (361) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OTHER', api_help_text => '

    Creates a new JSON containing one JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type timestamp

    Returns:
      - the new JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (362) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OTHER_ADD', api_help_text => '

    Creates a new JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type timestamp

    Returns:
      - the modified incomplete JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (363) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OTHER_FIRST', api_help_text => '

    Creates the first JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type timestamp

    Returns:
      - the new incomplete JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (364) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.JSON_OTHER_LAST', api_help_text => '

    Creates the last JSON member with a JSON element of type timestamp.

    Parameters:
       p_json_string_in  - the new JSON member''s JSON string
       p_json_element_in - the new JSON member''s JSON element of type timestamp

    Returns:
      - the final JSON
   
            ');
    l_sbsdb_api_scope_help_ntv (365) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.LOG_PARAM', api_help_text => '

    Prepares a parameter for logging.

    This procedure is overloaded.

    Parameters:
        p_name_in - parameter name
        p_val_in  - parameter value
    
            ');
    l_sbsdb_api_scope_help_ntv (366) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.NORMALIZED_JSON', api_help_text => '

    Cleanup of special characters in JSON.

    Parameters:
        p_json_in - JSON
    
            ');
    l_sbsdb_api_scope_help_ntv (367) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.SCOPE', api_help_text => '

    Creates the scope value for a SBSDB method implemented in a package.

    Parameters:
        p_package_name_in - package name
        p_method_name_in  - method name
    
            ');
    l_sbsdb_api_scope_help_ntv (368) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.APPEND_LOG_PARAM', api_help_text => '

    Adds a prepared parameter to a table of parameters.

    Parameters:
        p_log_params_inout - parameter table
        p_param_in         - prepared parameter
    
            ');
    l_sbsdb_api_scope_help_ntv (369) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.GET_VALID_JSON', api_help_text => '

     Returns always a valid JSON.


     Parameters:
        p_json_in_out  the string to be validated

     Returns:
       - unchanged input value, if the input value contains a valid JSON
       - {"invalid_json":"<p_json_in_out>"}, else
     
            ');
    l_sbsdb_api_scope_help_ntv (370) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.LOG_DEBUG', api_help_text => '

    Application can use this to log application events on debug level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - (optional) method qualified name without schema <package>.<method>
        p_extra_in      - (optional) attachment as clob
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    
            ');
    l_sbsdb_api_scope_help_ntv (371) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.LOG_ERROR', api_help_text => '

   Application can use this to log application errors on error level

   Parameters:
       p_text_in       - text describing the event to be logged
       p_scope_in      - method qualified name without schema <package>.<method>
       p_extra_in      - (optional) attachment as clob
       p_params_1_in   - (optional) method parameters (name,val) of request parameters
       p_params_%_in   - (optional) method parameters (name,val) of request parameters
   
            ');
    l_sbsdb_api_scope_help_ntv (372) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.LOG_INFO', api_help_text => '

    Application can use this to log application events on info level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - method qualified name without schema <package>.<method>
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    
            ');
    l_sbsdb_api_scope_help_ntv (373) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB.LOG_PERMANENT', api_help_text => '

    Application can use this to log application events on permanent level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - (optional) method qualified name without schema <package>.<method>
        p_extra_in      - (optional) attachment as clob
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    
            ');
    l_sbsdb_api_scope_help_ntv (374) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_LOGGER_LIB', api_help_text => '

    Interface to the logger library
    Implements logger extensions and proxy functions to be used by the application

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (375) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_SQL_LIB.NEW_LINE', api_help_text => '

    Sends text to the server output via DBMS_OUTPUT.new_line
    
            ');
    l_sbsdb_api_scope_help_ntv (376) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_SQL_LIB.PUT', api_help_text => '

    Sends text to the server output via DBMS_OUTPUT.put
    
            ');
    l_sbsdb_api_scope_help_ntv (377) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_SQL_LIB.PUT_LINE', api_help_text => '

    Sends text to the server output via DBMS_OUTPUT.put_line
    
            ');
    l_sbsdb_api_scope_help_ntv (378) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_SQL_LIB', api_help_text => '

    SBSDB specific auxiliary functions for SBSDB standard tasks.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (379) := sbsdb_api_scope_help_ot (api_scope => '.CONFIGURE_FOR_TEST', api_help_text => '

        TODO.

        Restrictions:
          - TODO.

        -- MODIFICATION HISTORY
        -- ---------    ------      -------------------------------------------
        -- Person       Date        Comments
        -- SO           06.11.2006  Created
        -- SO           27.10.2008  Remove MMSVAS Provisioning sections
        -- SO           27.10.2008  Add MMSC Provisioning sections
        -- SO           27.10.2008  Add SMCH30, CMCH80, SMCH90
        -- 001SO        15.07.2010  Reset Cleanup and refresh
        -- 002SO        09.07.2010  Enabling test Mapping for SMCH30
        -- 003SO        25.08.2010  Adapt to new NAS paths
        -- 004SO        01.03.2012  Remove S B S 0 and CAT Code
        -- 005SO        19.03.2012  Correct MUS eMail Address
        -- 006SO        12.07.2012  Adapt to Exadata environment
        -- 007SO        08.01.2014  Truncate log and debug tables
        -- 008SO        08.01.2014  Delete provisioning states for production platforms
        -- 009SO        08.04.2014  Correct NAS paths for production and test
        -- 010SO        18.07.2016  Changes brought in with Ora12c tests
        -- 011SO        17.01.2018  Point to new NAS path
        -- 012SO        17.10.2018  Remove REFERENCES to ENPLA
        
            ');
    l_sbsdb_api_scope_help_ntv (380) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_STANDALONE_SPEC', api_help_text => '

    Specification package for standalone methods.

    This package consists only of the package specification. It is used for
    standalone functions and procedures to support the annotation and API
    documentation mechanisms.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (381) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_TYPE_LIB', api_help_text => '

    SBSDB specific TYPE definitions for types used in several packages
    Types which are only relevant / used in a single package are defined there

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (382) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_USER_CON.GET_OS_USER', api_help_text => '

    Returns the operating system user name of the client process that
    initiated the database session (OS_USER).
    
            ');
    l_sbsdb_api_scope_help_ntv (383) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_USER_CON.GET_SESSION_ID', api_help_text => '

    Returns the session ID (SID).
    
            ');
    l_sbsdb_api_scope_help_ntv (384) := sbsdb_api_scope_help_ot (api_scope => 'SBSDB_USER_CON', api_help_text => '

    Back-end package for managing user-related tasks. The most important
    functionality includes creating, changing, deleting, and listing of profiles,
    roles, and users.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    
    ');
    l_sbsdb_api_scope_help_ntv (385) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.ALTER_USER', api_help_text => '

    Change an existing user profile in tables account and address.
    Log to uamlog. 

    Input Parameter:
      p_ac_short   - SwisscomLogin.
      p_ac_name    - UserName.
      p_ac_lang    - UserLanguage.
      p_ac_comment - Comment.
      p_ac_type    - AccountTypeId.
      p_ac_dept    - Department.
      p_adr_phone1 - Phone1.
      p_adr_phone2 - Phone2:
      p_adr_mobile - Mobile.
      p_adr_fax    - Fax.
      p_adr_email  - eMail.

    Restrictions:
      - user must exist.
    
            ');
    l_sbsdb_api_scope_help_ntv (386) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.CREATE_USER', api_help_text => '

    Create a new SBS user profile in tables account and address.
    Log to uamlog. 

    Input Parameter:
      p_ac_short   - SwisscomLogin.
      p_ac_name    - UserName.
      p_ac_lang    - UserLanguage.
      p_ac_comment - Comment.
      p_ac_type    - AccountTypeId.
      p_ac_dept    - Department.
      p_adr_phone1 - Phone1.
      p_adr_phone2 - Phone2:
      p_adr_mobile - Mobile.
      p_adr_fax    - Fax.
      p_adr_email  - eMail.

    Restrictions:
      - user must not exist.
    
            ');
    l_sbsdb_api_scope_help_ntv (387) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.DROP_USER', api_help_text => '

    TODO.

    Input Parameter:
      p_ac_short - SwisscomLogin.

    Restrictions:
      - user must exist.
    
            ');
    l_sbsdb_api_scope_help_ntv (388) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.INSERT_GROUP_CONN', api_help_text => '

    Assign the new user to the given AccountTypeId (ProfileId).

    Input Parameter:
      p_ac_short - SwisscomLogin.
      p_ac_type  - AccountType (main ProfileId for this user).

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (389) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.LOCK_USER', api_help_text => '

    Lock the given user.

    Input Parameter:
      p_ac_short - SwisscomId.

    Restrictions:
      - user must exist.
    
            ');
    l_sbsdb_api_scope_help_ntv (390) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.UNLOCK_USER', api_help_text => '

    Unlock the given user.

    Input Parameter:
      p_ac_short - SwisscomId.

    Restrictions:
      - user must exist.
    
            ');
    l_sbsdb_api_scope_help_ntv (391) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS.UPD_GROUP_CONN', api_help_text => '

    Re-assign the user to the given AccountTypeId (ProfileId).

    Input Parameter:
      p_ac_short - SwisscomLogin.
      p_ac_type  - AccountType (main ProfileId for this user).

    Restrictions:
      - none.
    
            ');
    l_sbsdb_api_scope_help_ntv (392) := sbsdb_api_scope_help_ot (api_scope => 'SBS1_ADMIN.USERMNG_SBS', api_help_text => '

    Provides an interface to UAM (Centrum) user for maintaining selected attributes
    of SBS users (Accounts and their Address) stored in SBS1 tables (to be deprecated). 
    TODO: The package should be removed around end of 2019 and replaced by a CPro solution
    (REST from UAM to be pushed into sbsgui.) 

    MODIFICATION HISTORY
    Person       Date        Comments
    001AA        07.01.2005  Created the package
    002AA        21.01.2005  Renamed the package from pkg_centrum to ''usermng_sbs''
    003AA        21.01.2005  Updated centrum username from CENTRUM_READER to CENTRUM_USER
    004AA        27.01.2005  Added flag to deactivate the issues creation
    005AA        08.02.2005  Remove (comment) the additional parameters not defined in the Centrum Specs
    006AA        14.02.2005  Moved the error codes and descriptions to the table Errdef and implement a sp to retrieve and use them
    007SO        28.02.2005  Implementing additional Requirement in Interface (AC_ID)
    008SO        03.04.2014  Implement UAM Logging
    009SO        13.12.2015  Inject AcId to all UAM Logs to enable efficient sycronisation in CPro
    000SO        13.02.2019  HASH:9516DF06CBAE9E628D6F7CEDDB4E3FB9 usermng_sbs.pkb
    010SO        01.04.2019  Remove use of deprecated procedure insert_issue
    
    ');

    RETURN l_sbsdb_api_scope_help_ntv;
END sbsdb_api_scope_help;
/
