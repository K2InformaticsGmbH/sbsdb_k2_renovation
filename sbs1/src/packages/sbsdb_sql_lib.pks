CREATE OR REPLACE PACKAGE sbsdb_sql_lib
IS
    /*<>
    SBSDB specific auxiliary functions for SBSDB standard tasks.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE new_line /*<>
    Sends text to the server output via DBMS_OUTPUT.new_line
    */
                      ;

    PROCEDURE put (p_text_in IN sbsdb_type_lib.api_help_t) /*<>
    Sends text to the server output via DBMS_OUTPUT.put
    */
                                                          ;

    PROCEDURE put_line (p_text_in IN sbsdb_type_lib.api_help_t) /*<>
    Sends text to the server output via DBMS_OUTPUT.put_line
    */
                                                               ;
END sbsdb_sql_lib;
/
