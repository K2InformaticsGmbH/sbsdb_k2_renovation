CREATE OR REPLACE PACKAGE sbs1_admin.pkg_script
IS
    /*<>
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
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION create_and_delete (
        p_scr_name                              IN     VARCHAR2,
        p_scr_line                              IN     NUMBER, -- 0=do not execute 1...n=do execute
        p_scr_table                             IN     VARCHAR2,
        p_scr_where                             IN     VARCHAR2,
        p_scr_job                               IN     VARCHAR2,
        p_scr_bohid                             IN     VARCHAR2,
        p_scr_esid                                 OUT VARCHAR2)
        RETURN VARCHAR2 /*<>
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
    */
                       ;

    FUNCTION create_and_execute (
        p_scr_name                              IN     VARCHAR2,
        p_scr_line                              IN     NUMBER,
        p_scr_text                              IN     VARCHAR2,
        p_scr_job                               IN     VARCHAR2,
        p_scr_bohid                             IN     VARCHAR2,
        p_scr_esid                                 OUT VARCHAR2)
        RETURN VARCHAR2 /*<>
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
    */
                       ;

    FUNCTION entry_state (p_scr_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_scr_id - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;
END pkg_script;
/