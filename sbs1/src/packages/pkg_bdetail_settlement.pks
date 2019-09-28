CREATE OR REPLACE PACKAGE sbs1_admin.pkg_bdetail_settlement
IS
    /*<>
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
    024SO     07.09.2010  Use correct settlement detail type 'IOTLACT' for IW tickets
    025SO     08.09.2010  Implement schedule option for UFUH generation (for MOIWST)
    026SO     08.09.2010  Correct numeric Format for UFIH F5
    027SO     18.09.2010  Round Settlement items to 2 digits
    028SO     18.09.2010  Suppress zero (counts=0 and price=0.00) UFIH CDRs of all types now
    029SO     18.09.2010  Patch UFIH-Price to 0.00 for all internal LA
    030SO     11.04.2011  Treat Tariff T (Televote) as Info Service
    031SO     14.12.2011  Remove schema qualifier "S B S 0 ."
    032SO     18.04.2012  Use PKG_COMMON.INSERT_WARNING
    033SO     09.08.2016  Suppress Tariff 'i' interworking costs in UFIH
    034SO     16.10.2016  Removing latest change 033SO and fully trust zero rating for internal LA and Triff i
    035SO     16.10.2016  Remove references to mVoting CDR Tags SMS-MV*
    036SO     12.07.2017  Compress LongId ranges if outside 'official' block 4179807...
    037SO     03.08.2017  Add missing date format
    038SO     04.08.2017  Remove support for Tariff 'M' (M-Voting)
    039SO     01.12.2017  Fix logging typo
    039SO     16.04.2018  Settle pager messages also (PAG)
    040SO     15.11.2018  Remove reference to CON_DEMO
    000SO     13.02.2019  HASH:54A9D889A9B385CE9313DC8550BC4FFD pkg_bdetail_settlement.pkb
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION nextavailableorder (
        p_sed_charge                            IN VARCHAR2,
        p_sed_date                              IN DATE)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_sed_charge - TODO.
      p_sed_date   - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION settledduration (
        con_datestart                           IN DATE,
        con_dateend                             IN DATE)
        RETURN NUMBER /*<>
    TODO.

    Input Parameter:
      con_datestart - TODO.
      con_dateend   - TODO.

    Return Parameter:
      TODO

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

    PROCEDURE sp_add_setdetail (
        p_set_etid                              IN     VARCHAR2,
        p_sed_etid                              IN     VARCHAR2,
        p_sed_charge                            IN     VARCHAR2,
        p_sed_bohid                             IN     VARCHAR2,
        p_date                                  IN     DATE,
        p_set_conid                             IN     VARCHAR2,
        p_sed_tarid                             IN     VARCHAR2,
        p_sed_int                               IN     VARCHAR2,
        p_sed_prepaid                           IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_amountcu                          IN     FLOAT,
        p_sed_retsharepv                        IN     FLOAT,
        p_sed_retsharemo                        IN     FLOAT,
        p_sed_longid                            IN     VARCHAR2,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_desc                              IN     VARCHAR2,
        p_gart                                  IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_add_setdetail_by_date (
        p_date                                  IN     VARCHAR2,
        p_set_conid                             IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2,
        p_set_demo                              IN     NUMBER,
        p_set_currency                          IN     VARCHAR2,
        p_set_comment                           IN     VARCHAR2,
        p_sed_etid                              IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_quantity                          IN     FLOAT,
        p_sed_discount                          IN     FLOAT,
        p_sed_vatid                             IN     VARCHAR2,
        p_sed_vatrate                           IN     FLOAT,
        p_sed_desc                              IN     VARCHAR2,
        p_sed_order                             IN     VARCHAR2,
        p_sed_visible                           IN     NUMBER,
        p_sed_comment                           IN     VARCHAR2,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_charge                            IN     VARCHAR2,
        p_sed_bohid                             IN     VARCHAR2,
        p_sed_pmvid                             IN     VARCHAR2,
        p_sed_tarid                             IN     VARCHAR2,
        p_sed_esid                              IN     VARCHAR2,
        p_sed_int                               IN     VARCHAR2,
        p_sed_prepaid                           IN     VARCHAR2, --001SO
        p_sed_amountcu                          IN     FLOAT, --001SO
        p_sed_retsharepv                        IN     FLOAT, --001SO
        p_sed_retsharemo                        IN     FLOAT, --001SO
        p_sed_longid_1                          IN     VARCHAR2, --036SO --003SO
        p_sed_longid_2                          IN     VARCHAR2, --036SO
        p_sep_id                                   OUT VARCHAR2,
        p_set_id                                   OUT VARCHAR2,
        p_sed_id                                   OUT VARCHAR2,
        p_sed_pos                                  OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_insert_period (
        p_pac_id                                IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lam_mcc (
        p_pac_id                                IN     VARCHAR2,
        p_boh_id                                IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- SLA or MLA
        p_gart                                  IN     NUMBER, --016SO
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lapmcc (
        p_pac_id                                IN     VARCHAR2, -- 'LAPMCC_SMS' or 'LAPMCC_MMS'    MCC Preparation (Minimum Charge Calculation)
        p_boh_id                                IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- SLA or MLA
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lat_cdr (
        p_bd_bohid                              IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- 'SLA'  or 'MLA'
        p_gart                                  IN     NUMBER,
        p_minage                                IN     NUMBER,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lit_cdr (
        p_bd_bohid                              IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- 'SLA'  or 'MLA'
        p_gart                                  IN     NUMBER,
        p_minage                                IN     NUMBER,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER) /*<>
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
    */
                                                              ;
END pkg_bdetail_settlement;
/