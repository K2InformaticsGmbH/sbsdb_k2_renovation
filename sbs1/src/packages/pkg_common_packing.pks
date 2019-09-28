CREATE OR REPLACE PACKAGE sbs1_admin.pkg_common_packing
IS
    /*<>
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
    032SO     21.04.2010  Set packing to done for scheduled empty loopersand implement JobId ='none'
    033SO     23.04.2010  Use 'NONE' instead an properly check the value
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
    047SO     15.11.2018  Remove reference to CON_CUSTNUMBER and CON_NUMBER
    000SO     13.02.2019  HASH:2271C62C7E5FFC87905A22D7ACB7203B pkg_common_packing.pkb
    */

    excp_missing_packing_par                EXCEPTION;
    PRAGMA EXCEPTION_INIT (excp_missing_packing_par,
                           -01008);
    eno_missing_packing_par                 PLS_INTEGER := 1008;
    edesc_missing_packing_par               VARCHAR2 (255) := 'Missing packing parameter entry in table STA_PACPARAM';

    excp_statistics_failure                 EXCEPTION; --012SO
    PRAGMA EXCEPTION_INIT (excp_statistics_failure,
                           -01007);
    eno_statistics_failure                  PLS_INTEGER := 1007;
    edesc_statistics_failure                VARCHAR2 (255) := 'Too many failures (retries) in statistics generation';

    excp_workflow_abort                     EXCEPTION; --012SO
    PRAGMA EXCEPTION_INIT (excp_workflow_abort,
                           -01006);
    eno_workflow_abort                      PLS_INTEGER := 1006;
    edesc_workflow_abort                    VARCHAR2 (255) := 'Inconsistent workflow state. Statistics generation may need a reset or a clearing';

    /* =========================================================================
       (Billing/Handler) Output Header States.
       ---------------------------------------------------------------------- */

    TYPE tboheaderesid IS RECORD
    (
        error bohstate.bohs_id%TYPE := 'PAE',
        ok bohstate.bohs_id%TYPE := 'OK',
        packing bohstate.bohs_id%TYPE := 'PAC'
    );

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    TYPE tpackingstateid IS RECORD
    (
        active packingstate.packs_id%TYPE := 'A',
        deleted packingstate.packs_id%TYPE := 'D',
        draft packingstate.packs_id%TYPE := 'R',
        inactive packingstate.packs_id%TYPE := 'I',
        locked packingstate.packs_id%TYPE := 'L',
        scheduled packingstate.packs_id%TYPE := 'S'
    );

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getpackingcandidatefortype (
        p_packingtype                           IN VARCHAR2,
        p_thread                                IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_packingtype - TODO.
      p_thread      - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getpackingparameter (
        p_pac_id                                IN VARCHAR2,
        p_name                                  IN sta_pacparam.stap_name%TYPE)
        RETURN sta_pacparam.stap_value%TYPE /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.
      p_name   - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                                           ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

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

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION istimeforpacking (p_pac_id IN VARCHAR2)
        RETURN INTEGER /*<>
    TODO.

    Input Parameter:
      p_pac_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                      ;

    /* =========================================================================
       TODO.

       --011DA
       ---------------------------------------------------------------------- */

    FUNCTION setstringtagstolowercase (p_string IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_string - TODO.

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

    PROCEDURE insert_boheader (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_headerid                              IN OUT VARCHAR2,
        p_jobid                                    OUT VARCHAR2,
        p_filename                                 OUT VARCHAR2, --003SO
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2) /*<>
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
    */
                                                                ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_boheader_sptry (
        p_packingid                             IN     VARCHAR2,
        p_headerid                              IN OUT VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_packingid - TODO.
      p_headerid  - TODO.

    Output Parameter:
      p_headerid - TODO.

    Restrictions:
      - TODO.
    */
                                                                ; --021SO

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE modify_boheader (
        p_headerid                              IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_filename                                 OUT VARCHAR2) /*<> --020SO
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
    */
                                                                ;

    /* =========================================================================
       TODO.
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

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header (
        p_packingtype                           IN     VARCHAR2,
        p_packingid                             IN OUT VARCHAR2,
        p_headerid                                 OUT VARCHAR2,
        p_jobid                                    OUT VARCHAR2,
        p_filename                                 OUT VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_taskid                                IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER) /*<> --039SO
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
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_boheader (
        p_headerid                              IN     VARCHAR2,
        p_jobid                                 IN     VARCHAR2,
        p_filename                              IN OUT VARCHAR2,
        p_filedate                              IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        p_dataheader                            IN     VARCHAR2,
        p_reccount                              IN     NUMBER,
        p_errcount                              IN     NUMBER,
        p_datefc                                IN     VARCHAR2,
        p_datelc                                IN     VARCHAR2) /*<>
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
    */
                                                                ;
END pkg_common_packing;
/