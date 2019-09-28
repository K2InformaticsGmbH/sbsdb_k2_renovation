CREATE OR REPLACE PACKAGE sbs1_admin.usermng_sbs
IS
    /*<>
    Provides an interface to UAM (Centrum) user for maintaining selected attributes
    of SBS users (Accounts and their Address) stored in SBS1 tables (to be deprecated). 
    TODO: The package should be removed around end of 2019 and replaced by a CPro solution
    (REST from UAM to be pushed into sbsgui.) 

    MODIFICATION HISTORY
    Person       Date        Comments
    001AA        07.01.2005  Created the package
    002AA        21.01.2005  Renamed the package from pkg_centrum to 'usermng_sbs'
    003AA        21.01.2005  Updated centrum username from CENTRUM_READER to CENTRUM_USER
    004AA        27.01.2005  Added flag to deactivate the issues creation
    005AA        08.02.2005  Remove (comment) the additional parameters not defined in the Centrum Specs
    006AA        14.02.2005  Moved the error codes and descriptions to the table Errdef and implement a sp to retrieve and use them
    007SO        28.02.2005  Implementing additional Requirement in Interface (AC_ID)
    008SO        03.04.2014  Implement UAM Logging
    009SO        13.12.2015  Inject AcId to all UAM Logs to enable efficient sycronisation in CPro
    000SO        13.02.2019  HASH:9516DF06CBAE9E628D6F7CEDDB4E3FB9 usermng_sbs.pkb
    010SO        01.04.2019  Remove use of deprecated procedure insert_issue
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE alter_user (
        p_ac_short                              IN VARCHAR2,
        p_ac_name                               IN VARCHAR2,
        p_ac_lang                               IN VARCHAR2,
        p_ac_comment                            IN VARCHAR2,
        p_ac_type                               IN VARCHAR2,
        p_ac_dept                               IN VARCHAR2, -- 007SO
        p_adr_phone1                            IN VARCHAR2,
        p_adr_phone2                            IN VARCHAR2,
        p_adr_mobile                            IN VARCHAR2,
        p_adr_fax                               IN VARCHAR2,
        p_adr_email                             IN VARCHAR2) /*<>
    Change an existing user profile in tables account and address.
    Log to uamlog. 

    Input Parameter:
      p_ac_short   - SwisscomLogin.
      p_ac_name    - UserName.
      p_ac_lang    - UserLanguage.
      p_ac_comment - Comment.
      p_ac_type    - AccountTypeId.
      p_ac_dept    - Department.
      p_adr_phone1 - Phone1.
      p_adr_phone2 - Phone2:
      p_adr_mobile - Mobile.
      p_adr_fax    - Fax.
      p_adr_email  - eMail.

    Restrictions:
      - user must exist.
    */
                                                            ;

    PROCEDURE create_user (
        p_ac_short                              IN VARCHAR2,
        p_ac_name                               IN VARCHAR2,
        p_ac_lang                               IN VARCHAR2,
        p_ac_comment                            IN VARCHAR2,
        p_ac_type                               IN VARCHAR2,
        p_ac_dept                               IN VARCHAR2, -- 007SO
        p_adr_phone1                            IN VARCHAR2,
        p_adr_phone2                            IN VARCHAR2,
        p_adr_mobile                            IN VARCHAR2,
        p_adr_fax                               IN VARCHAR2,
        p_adr_email                             IN VARCHAR2) /*<>
    Create a new SBS user profile in tables account and address.
    Log to uamlog. 

    Input Parameter:
      p_ac_short   - SwisscomLogin.
      p_ac_name    - UserName.
      p_ac_lang    - UserLanguage.
      p_ac_comment - Comment.
      p_ac_type    - AccountTypeId.
      p_ac_dept    - Department.
      p_adr_phone1 - Phone1.
      p_adr_phone2 - Phone2:
      p_adr_mobile - Mobile.
      p_adr_fax    - Fax.
      p_adr_email  - eMail.

    Restrictions:
      - user must not exist.
    */
                                                            ;

    PROCEDURE drop_user (p_ac_short IN VARCHAR2) /*<>
    TODO.

    Input Parameter:
      p_ac_short - SwisscomLogin.

    Restrictions:
      - user must exist.
    */
                                                ;

    PROCEDURE insert_group_conn (
        p_ac_short                              IN VARCHAR2,
        p_ac_type                               IN VARCHAR2) /*<>
    Assign the new user to the given AccountTypeId (ProfileId).

    Input Parameter:
      p_ac_short - SwisscomLogin.
      p_ac_type  - AccountType (main ProfileId for this user).

    Restrictions:
      - none.
    */
                                                            ;

    PROCEDURE lock_user (p_ac_short IN VARCHAR2) /*<>
    Lock the given user.

    Input Parameter:
      p_ac_short - SwisscomId.

    Restrictions:
      - user must exist.
    */
                                                ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE unlock_user (p_ac_short IN VARCHAR2) /*<>
    Unlock the given user.

    Input Parameter:
      p_ac_short - SwisscomId.

    Restrictions:
      - user must exist.
    */
                                                  ;

    PROCEDURE upd_group_conn (
        p_ac_short                              IN VARCHAR2,
        p_ac_type                               IN VARCHAR2) /*<>
    Re-assign the user to the given AccountTypeId (ProfileId).

    Input Parameter:
      p_ac_short - SwisscomLogin.
      p_ac_type  - AccountType (main ProfileId for this user).

    Restrictions:
      - none.
    */
                                                            ;
END usermng_sbs;
/
