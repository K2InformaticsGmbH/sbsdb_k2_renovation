CREATE OR REPLACE PACKAGE sbs1_admin.pkg_common_mapping
IS
    /*<>
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
    */

    /* =========================================================================
       Mapping States.
       ---------------------------------------------------------------------- */

    TYPE tmapesid IS RECORD
    (
        error mapstate.maps_id%TYPE := 'E',
        ignore mapstate.maps_id%TYPE := 'I',
        mapnoset mapstate.maps_id%TYPE := 'm',
        mapping mapstate.maps_id%TYPE := 'M',
        ready mapstate.maps_id%TYPE := 'R'
    );

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getsrctypeforbiheader (p_bih_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_bih_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION gettypeformapping (p_bih_mapid IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION istimeformapping (p_bih_mapid IN VARCHAR2)
        RETURN INTEGER /*<>
    TODO.

    Input Parameter:
      p_bih_mapid - TODO.

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

    PROCEDURE insert_biheader (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2, --025SO
        p_taskid                                IN     NUMBER, --006SO was p_JobId
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2) /*<>
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
        p_returnstatus                             OUT NUMBER) /*<> --009SO
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
END pkg_common_mapping;
/