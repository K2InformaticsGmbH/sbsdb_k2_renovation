CREATE OR REPLACE PACKAGE sbsdb_user_con
IS
    /*<>
    Back-end package for managing user-related tasks. The most important
    functionality includes creating, changing, deleting, and listing of profiles,
    roles, and users.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION get_os_user
        RETURN sbsdb_type_lib.property_value_t /*<>
    Returns the operating system user name of the client process that
    initiated the database session (OS_USER).
    */
                                              ;

    FUNCTION get_session_id
        RETURN PLS_INTEGER /*<>
    Returns the session ID (SID).
    */
                          ;
/* =========================================================================
   Public Procedure Declarations
   ---------------------------------------------------------------------- */

END sbsdb_user_con;
/
