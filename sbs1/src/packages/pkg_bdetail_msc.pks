CREATE OR REPLACE PACKAGE sbs1_admin.pkg_bdetail_msc
IS
    /*<>
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
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION add_smsc_code_to_unknown_toc (
        p_smsc_code                             IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
        RETURN VARCHAR2 /*<>
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
    */
                       ;

    --  006SO

    FUNCTION get_smsc_id (
        p_bd_sca                                IN     VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
        RETURN VARCHAR2 /*<>
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
    */
                       ;

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_try_msccu (
        p_pac_id                                IN     VARCHAR2, -- 'MSCCU'
        p_boh_id                                IN OUT VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER) /*<>
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
END pkg_bdetail_msc;
/