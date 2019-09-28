CREATE OR REPLACE PACKAGE sbs1_admin.pkg_interworking
IS
    /*<>
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

    PROCEDURE sp_cons_nbr_merge (
        p_pac_id                                IN     VARCHAR2, -- 'NBR_MERGE'            -- 009SO
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

    PROCEDURE sp_cons_nbr_prep (
        p_pac_id                                IN     VARCHAR2, -- 'NBR_PREP' -- 009SO
        p_bioh_id                               IN     VARCHAR2,
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

    PROCEDURE sp_cons_smsc_propose (
        p_pac_id                                IN     VARCHAR2, -- 'SMSC_PRPS1' or 'SMSC_PRPS2'            -- 009SO
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
END pkg_interworking;
/
