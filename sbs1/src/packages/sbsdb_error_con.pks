CREATE OR REPLACE PACKAGE sbsdb_error_con
IS
    /*<>
    SBSDB application exception definitions
    Generic exception handling and logging

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Definition.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Definition.
       ---------------------------------------------------------------------- */

    PROCEDURE raise_appl_error (
        p_errcode_in                            IN PLS_INTEGER,
        p_err_msg_in                            IN VARCHAR2 := NULL,
        p_variable_1_in                         IN VARCHAR2 := NULL,
        p_variable_2_in                         IN VARCHAR2 := NULL,
        p_variable_3_in                         IN VARCHAR2 := NULL,
        p_variable_4_in                         IN VARCHAR2 := NULL) /*<>
    Raises a generic application error

    Parameters:
        p_errcode_in        - the SQLCODE
        p_err_msg_in        - the error text to print (or NULL for the default)
        p_variable_1_in     - message token replacement for :1
        p_variable_2_in     - message token replacement for :2
        ...
    */
                                                                    ;
END sbsdb_error_con;
/
