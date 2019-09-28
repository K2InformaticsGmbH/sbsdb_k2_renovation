CREATE OR REPLACE PACKAGE sbs1_admin.pkg_common_stats
IS
    /*<>
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
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_sta_job_scheduled_count (
        p_stajpacid                             IN sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN sta_job.staj_periodid%TYPE)
        RETURN INTEGER /*<>
    TODO.

    Input Parameter:
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                      ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_sta_job_error_count (
        p_stajpacid                             IN sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN sta_job.staj_periodid%TYPE)
        RETURN INTEGER /*<>
    TODO.

    Input Parameter:
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                      ;

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE get_sta_job_working (
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE) /*<>
    TODO.

    Input Parameter:
      p_stajpacid    - TODO.
      p_stajperiodid - TODO.
      p_boheaderid   - TODO.

    Output Parameter:
      p_stajid - TODO.

    Restrictions:
      - TODO.
    */
                                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_job_working (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajltvalue                           IN     sta_job.staj_ltvalue%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_stajid                                   OUT sta_job.staj_id%TYPE) /*<>
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
    */
                                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE new_sta_jobs_loopers (
        p_stajparentid                          IN     sta_job.staj_parentid%TYPE,
        p_stajpacid                             IN     sta_job.staj_pacid%TYPE,
        p_stajperiodid                          IN     sta_job.staj_periodid%TYPE,
        p_boheaderid                            IN     boheader.boh_id%TYPE,
        p_createdjobcount                          OUT NUMBER) /*<>
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
    */
                                                              ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job_success (p_stajid IN sta_job.staj_id%TYPE) /*<>
    TODO.

    Input Parameter:
      p_stajid - TODO.

    Restrictions:
      - TODO.
    */
                                                                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_sta_job_working (
        p_stajid                                IN sta_job.staj_id%TYPE,
        p_boheaderid                            IN boheader.boh_id%TYPE) /*<>
    TODO.

    Input Parameter:
      p_stajid     - TODO.
      p_boheaderid - TODO.

    Restrictions:
      - TODO.
    */
                                                                        ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE watchpackagestatechanges (
        vpacid                                  IN packing.pac_id%TYPE,
        voldpacesid                             IN packing.pac_esid%TYPE,
        vnewpacesid                             IN packing.pac_esid%TYPE,
        voldpacltid                             IN packing.pac_ltid%TYPE,
        vnewpacltid                             IN packing.pac_ltid%TYPE) /*<>
    TODO.

    Input Parameter:
      vpacid      - TODO.
      voldpacesid - TODO.
      vnewpacesid - TODO.
      voldpacltid - TODO.
      vnewpacltid - TODO.

    Restrictions:
      - TODO.
    */
                                                                         ;
END pkg_common_stats;
/
