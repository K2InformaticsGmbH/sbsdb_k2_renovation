CREATE OR REPLACE PACKAGE sbs1_admin.pkg_code_mgmt
IS
    /*<>
    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_ddl (
        lvtype                                  IN VARCHAR2,
        lvname                                  IN VARCHAR2,
        lvschema                                IN VARCHAR2)
        RETURN CLOB /*<>
    TODO.

    Input Parameter:
      lvtype   - TODO.
      lvname   - TODO.
      lvschema - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                   ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_ddl_file_name (
        lvtype                                  IN VARCHAR2,
        lvname                                  IN VARCHAR2,
        lvschema                                IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      lvtype   - TODO.
      lvname   - TODO.
      lvschema - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION md5checksum (
        lvtype                                  IN VARCHAR2,
        lvname                                  IN VARCHAR2,
        lvschema                                IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      lvtype   - TODO.
      lvname   - TODO.
      lvschema - TODO.

    Return Parameter:
      TODO

    Restrictions:
      - TODO.
    */
                       ;
/* =========================================================================
   Public Procedure Declaration.
   ---------------------------------------------------------------------- */

END pkg_code_mgmt;
/