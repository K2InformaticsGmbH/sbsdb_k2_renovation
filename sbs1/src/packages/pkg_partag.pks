CREATE OR REPLACE PACKAGE sbs1_admin.pkg_partag
IS
    /*<>
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
    020SO 13.06.2013  Use 'NC' instead on 'UC' for uncompressed tablespaces
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
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION partreorg_exch_partition (
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
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION partreorg_prepare (
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
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE cleanup (
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

    PROCEDURE cleanup_delete (
        pintablename                            IN     VARCHAR2,
        pinwhereclause                          IN     VARCHAR2,
        pinboh_id                               IN     VARCHAR2,
        poutdeleted                                OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      pintablename   - TODO.
      pinwhereclause - TODO.
      poutdeleted    - TODO.

    Output Parameter:
      poutdeleted - TODO.

    Restrictions:
      - TODO.
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_info_partitions (
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

    PROCEDURE sp_add_info_partitions_man (p_partition_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_mmsc_partitions (
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

    PROCEDURE sp_add_mmsc_partitions_man (p_partition_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_msca_partitions (
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

    PROCEDURE sp_add_msca_partitions_man (p_partition_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsa_partitions (
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

    PROCEDURE sp_add_smsa_partitions_man (p_partition_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsc_partitions (
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

    PROCEDURE sp_add_smsc_partitions_man (p_partition_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsd_partitions (
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

    PROCEDURE sp_add_smsd_partitions_man (p_partition_code IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_partition_code - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_info_partitions (
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

    PROCEDURE sp_cpr_mmsc_partitions (
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

    PROCEDURE sp_cpr_msca_partitions (
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

    PROCEDURE sp_cpr_revi_partitions (
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

    PROCEDURE sp_cpr_smsc_partitions (
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

    PROCEDURE sp_cpr_smsd_partitions (
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
END pkg_partag;
/