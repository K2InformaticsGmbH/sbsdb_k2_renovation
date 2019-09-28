CREATE OR REPLACE PACKAGE sbs1_admin.pkg_debug
IS
    /*<>
    Allow applications to write debug information to their respective debug tables.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    01.02.2006  Procedure debug_enpla added
    002SO    26.10.2008  Remove MMSVAS section
    003SO    13.12.2011  Remove CAT implementation
    004SO    14.12.2011  Remove schema qualifier "S B S 0 ."
    005SO    17.10.2018  Remove procedures debug_enpla and jschedule
    000SO    13.02.2019  HASH:25621D4E272694F1A6B05BE375CBEB3C pkg_debug.pkb
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE debug_reva (
        lbih_id                                 IN VARCHAR2,
        lboh_id                                 IN VARCHAR2,
        lrevah_id                               IN VARCHAR2,
        lreccount                               IN NUMBER,
        what                                    IN VARCHAR2,
        lhint                                   IN VARCHAR2) /*<>
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
    */
                                                            ;
END pkg_debug;
/
