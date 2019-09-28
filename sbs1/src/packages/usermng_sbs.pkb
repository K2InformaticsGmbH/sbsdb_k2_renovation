CREATE OR REPLACE PACKAGE BODY sbs1_admin.usermng_sbs
IS
    /* =========================================================================
       Constants used to extract user-defined error codes and error descriptions
       from the Errdef table
       ---------------------------------------------------------------------- */

    err_get_unique_address_id               VARCHAR2 (10) := '1000000051';
    err_get_unique_account_id               VARCHAR2 (10) := '1000000052';
    err_cre_new_account                     VARCHAR2 (10) := '1000000053';
    err_cre_new_address                     VARCHAR2 (10) := '1000000054';
    err_upd_account                         VARCHAR2 (10) := '1000000055';
    err_upd_address                         VARCHAR2 (10) := '1000000056';
    err_account_not_found                   VARCHAR2 (10) := '1000000057';
    err_upd_account_state_nok               VARCHAR2 (10) := '1000000058';
    err_cre_issue_new_user                  VARCHAR2 (10) := '1000000059';
    err_cre_issue_upd_user                  VARCHAR2 (10) := '1000000060';
    err_cre_issue_del_user                  VARCHAR2 (10) := '1000000061';
    err_cre_issue_lck_user                  VARCHAR2 (10) := '1000000062';
    err_cre_issue_ulk_user                  VARCHAR2 (10) := '1000000063';
    err_cre_issue_grp_user                  VARCHAR2 (10) := '1000000064';
    err_duplicate_user_id                   VARCHAR2 (10) := '1000000065';

    /* =========================================================================
       Names of any procedure/function new created or updated must be set as constant here
       ---------------------------------------------------------------------- */

    g_procname_user_alter                   VARCHAR2 (20) := 'Alter_User';
    g_procname_user_create                  VARCHAR2 (20) := 'Create_User';
    g_procname_user_drop                    VARCHAR2 (20) := 'Drop_User';
    g_procname_user_lock                    VARCHAR2 (20) := 'Lock_User';
    g_procname_user_unlock                  VARCHAR2 (20) := 'UnLock_User';
    g_procname_user_updategroup             VARCHAR2 (20) := 'Upd_Group_Conn';

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getacid (p_ac_short IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION getcurrentuser
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE geterrcodeanddescfromerrdef (
        l_errid                                 IN     VARCHAR2,
        l_errd_code                                OUT VARCHAR2,
        l_errd_desc                                OUT VARCHAR2);

    PROCEDURE uamlog (
        p_uaml_acshort                          IN VARCHAR2,
        p_uaml_method                           IN VARCHAR2,
        p_uaml_acid                             IN VARCHAR2,
        p_uaml_name                             IN VARCHAR2,
        p_uaml_langid                           IN VARCHAR2,
        p_uaml_comment                          IN VARCHAR2,
        p_uaml_actype                           IN VARCHAR2,
        p_uaml_dept                             IN VARCHAR2,
        p_uaml_phone1                           IN VARCHAR2,
        p_uaml_phone2                           IN VARCHAR2,
        p_uaml_mobile                           IN VARCHAR2,
        p_uaml_fax                              IN VARCHAR2,
        p_uaml_email                            IN VARCHAR2,
        p_uaml_error                            IN VARCHAR2);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
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
        p_adr_email                             IN VARCHAR2)
    IS
        l_procname                              VARCHAR2 (20) := g_procname_user_alter;
        l_acid                                  VARCHAR2 (10);
        l_acadridmain                           VARCHAR2 (10);
        l_acesid                                VARCHAR2 (10);
        l_acetid                                VARCHAR2 (10);
        l_acidcurr                              VARCHAR2 (10);
        l_errorcode                             VARCHAR2 (10);
        l_errormsg                              VARCHAR2 (500);
        l_returnstatus                          NUMBER (10);

        CURSOR cgetaccount (p_ac_short IN VARCHAR2)
        IS
            SELECT ac_id,
                   ac_adrid_main,
                   ac_esid,
                   ac_etid
            FROM   account
            WHERE  ac_short = p_ac_short;

        l_errd_code                             VARCHAR2 (100);
        l_errd_desc                             VARCHAR2 (4000);
    BEGIN
        l_acidcurr := getcurrentuser ();

        -- Check if the Account belonging to the given ShortId is updateable
        OPEN cgetaccount (p_ac_short);

        FETCH cgetaccount
            INTO l_acid,
                 l_acadridmain,
                 l_acesid,
                 l_acetid;

        IF cgetaccount%NOTFOUND
        THEN
            -- Account for the given ShortId not found
            -- return error
            geterrcodeanddescfromerrdef (err_account_not_found, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
        END IF;

        CLOSE cgetaccount;

        IF l_acesid NOT IN ('A',
                            'I')
        THEN
            -- Account can not be updated if state other than Active or Inactive
            -- return error
            geterrcodeanddescfromerrdef (err_upd_account_state_nok, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc || ' (' || l_acesid || ')');
        END IF;

        -- update account and its address
        UPDATE account
        SET    ac_name = NVL (p_ac_name, ac_name),
               ac_langid = NVL (p_ac_lang, ac_langid),
               ac_etid = NVL (p_ac_type, ac_etid),
               ac_dept = NVL (p_ac_dept, ac_dept), -- 007SO
               ac_comment = NVL (p_ac_comment, ac_comment), -- May overwrite Previous Ac_Short values! (see drop_user)
               ac_acidmod = l_acidcurr,
               ac_datemod = SYSDATE,
               ac_chngcnt = NVL (ac_chngcnt, 0) + 1
        WHERE      ac_short = p_ac_short -- AC_SHORT is unique indexed
               AND ac_esid IN ('A',
                               'I'); -- only active Accounts can be updated

        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE address
            SET    adr_phone1 = NVL (p_adr_phone1, adr_phone1),
                   adr_phone2 = NVL (p_adr_phone2, adr_phone2),
                   adr_mobile = NVL (p_adr_mobile, adr_mobile),
                   adr_fax = NVL (p_adr_fax, adr_fax),
                   adr_email = NVL (p_adr_email, adr_email),
                   adr_chngcnt = adr_chngcnt + 1
            WHERE  adr_id = l_acadridmain;

            IF SQL%ROWCOUNT = 0
            THEN
                -- Error updating Address
                -- return error
                geterrcodeanddescfromerrdef (err_upd_address, l_errd_code, l_errd_desc);
                uamlog (
                    p_ac_short,
                    l_procname,
                    l_acid,
                    p_ac_name,
                    p_ac_lang,
                    p_ac_comment,
                    p_ac_type,
                    p_ac_dept,
                    p_adr_phone1,
                    p_adr_phone2,
                    p_adr_mobile,
                    p_adr_fax,
                    p_adr_email,
                    l_errd_code); -- 008SO
                raise_application_error (l_errd_code, l_errd_desc);
            END IF;
        ELSE
            -- Error updating Account
            -- return error
            geterrcodeanddescfromerrdef (err_upd_account, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
        END IF;

        uamlog (
            p_ac_short,
            l_procname,
            l_acid,
            p_ac_name,
            p_ac_lang,
            p_ac_comment,
            p_ac_type,
            p_ac_dept,
            p_adr_phone1,
            p_adr_phone2,
            p_adr_mobile,
            p_adr_fax,
            p_adr_email,
            l_errd_code); -- 008SO
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                SQLCODE); -- 008SO
            RAISE;
    END alter_user;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

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
        p_adr_email                             IN VARCHAR2)
    IS
        l_procname                              VARCHAR2 (20) := g_procname_user_create;
        l_acid                                  VARCHAR2 (10);
        l_adrid                                 VARCHAR2 (10);
        l_acidcurr                              VARCHAR2 (10);
        l_errorcode                             VARCHAR2 (10);
        l_errormsg                              VARCHAR2 (500);
        l_returnstatus                          NUMBER (10);
        l_ac_state                              VARCHAR2 (10) := 'A';
        l_adr_type                              VARCHAR2 (10) := 'STD';
        l_adr_state                             VARCHAR2 (10) := 'A';
        exp_duplicate_user_id                   EXCEPTION;
        PRAGMA EXCEPTION_INIT (exp_duplicate_user_id,
                               -1);
        exp_null_user_name                      EXCEPTION;
        PRAGMA EXCEPTION_INIT (exp_null_user_name,
                               -1400);
        l_errd_code                             VARCHAR2 (100);
        l_errd_desc                             VARCHAR2 (4000);
    BEGIN
        -- Create Account and its Address in one go (transaction)
        SELECT pkg_common.generateuniquekey ('G') INTO l_adrid FROM DUAL;

        IF SQL%NOTFOUND
        THEN
            -- Could not generate unique key for ADR_ID
            -- return error
            geterrcodeanddescfromerrdef (err_get_unique_address_id, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
            l_adrid := NULL;
        END IF;

        IF LENGTH (l_adrid) > 0
        THEN
            -- ?? Validate phone, mobile, fax, email based on rules in Web Module

            INSERT INTO address (
                            adr_id,
                            adr_etid,
                            adr_demo,
                            adr_esid,
                            adr_phone1,
                            adr_phone2,
                            adr_mobile,
                            adr_fax,
                            adr_email,
                            adr_chngcnt)
            VALUES      (
                            l_adrid,
                            l_adr_type,
                            0,
                            l_adr_state,
                            p_adr_phone1,
                            p_adr_phone2,
                            p_adr_mobile,
                            p_adr_fax,
                            p_adr_email,
                            0);

            IF SQL%ROWCOUNT > 0
            THEN
                -- Address created successfully, now create the Account
                SELECT pkg_common.generateuniquekey ('G') INTO l_acid FROM DUAL;

                IF SQL%NOTFOUND
                THEN
                    -- Could not generate unique key for AC_ID
                    -- return error
                    geterrcodeanddescfromerrdef (err_get_unique_account_id, l_errd_code, l_errd_desc);
                    uamlog (
                        p_ac_short,
                        l_procname,
                        l_acid,
                        p_ac_name,
                        p_ac_lang,
                        p_ac_comment,
                        p_ac_type,
                        p_ac_dept,
                        p_adr_phone1,
                        p_adr_phone2,
                        p_adr_mobile,
                        p_adr_fax,
                        p_adr_email,
                        l_errd_code); -- 008SO
                    raise_application_error (l_errd_code, l_errd_desc);
                    l_acid := NULL;
                END IF;

                IF LENGTH (l_acid) > 0
                THEN
                    l_acidcurr := getcurrentuser ();

                    INSERT INTO account (
                                    ac_id,
                                    ac_demo,
                                    ac_logret,
                                    ac_vat,
                                    ac_currency,
                                    ac_name,
                                    ac_short,
                                    ac_langid,
                                    ac_etid,
                                    ac_esid,
                                    ac_dept, -- 007SO
                                    ac_comment,
                                    ac_adrid_main,
                                    ac_acidcre,
                                    ac_datecre,
                                    ac_chngcnt)
                    VALUES      (
                                    l_acid,
                                    0,
                                    0,
                                    0,
                                    'CHF',
                                    p_ac_name,
                                    UPPER (p_ac_short),
                                    p_ac_lang,
                                    p_ac_type,
                                    l_ac_state,
                                    p_ac_dept, -- 007SO
                                    p_ac_comment,
                                    l_adrid,
                                    l_acidcurr,
                                    SYSDATE,
                                    0);

                    IF SQL%ROWCOUNT = 0
                    THEN
                        -- Account and Address, not created successfully
                        -- Could not create Account. Address created.
                        -- return error
                        geterrcodeanddescfromerrdef (err_cre_new_account, l_errd_code, l_errd_desc);
                        uamlog (
                            p_ac_short,
                            l_procname,
                            l_acid,
                            p_ac_name,
                            p_ac_lang,
                            p_ac_comment,
                            p_ac_type,
                            p_ac_dept,
                            p_adr_phone1,
                            p_adr_phone2,
                            p_adr_mobile,
                            p_adr_fax,
                            p_adr_email,
                            l_errd_code); -- 008SO
                        raise_application_error (l_errd_code, l_errd_desc);
                    END IF;
                ELSE
                    -- Could not generate unique key for AC_ID
                    -- return error
                    geterrcodeanddescfromerrdef (err_get_unique_account_id, l_errd_code, l_errd_desc);
                    uamlog (
                        p_ac_short,
                        l_procname,
                        l_acid,
                        p_ac_name,
                        p_ac_lang,
                        p_ac_comment,
                        p_ac_type,
                        p_ac_dept,
                        p_adr_phone1,
                        p_adr_phone2,
                        p_adr_mobile,
                        p_adr_fax,
                        p_adr_email,
                        l_errd_code); -- 008SO
                    raise_application_error (l_errd_code, l_errd_desc);
                    l_acid := NULL;
                END IF;
            ELSE
                -- Could not create the main Address for new Account
                -- return error
                geterrcodeanddescfromerrdef (err_cre_new_address, l_errd_code, l_errd_desc);
                uamlog (
                    p_ac_short,
                    l_procname,
                    l_acid,
                    p_ac_name,
                    p_ac_lang,
                    p_ac_comment,
                    p_ac_type,
                    p_ac_dept,
                    p_adr_phone1,
                    p_adr_phone2,
                    p_adr_mobile,
                    p_adr_fax,
                    p_adr_email,
                    l_errd_code); -- 008SO
                raise_application_error (l_errd_code, l_errd_desc);
            END IF;
        ELSE
            -- Could not generate unique key for ADR_ID
            -- return error
            geterrcodeanddescfromerrdef (err_get_unique_address_id, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
            l_adrid := NULL;
        END IF;

        uamlog (
            p_ac_short,
            l_procname,
            l_acid,
            p_ac_name,
            p_ac_lang,
            p_ac_comment,
            p_ac_type,
            p_ac_dept,
            p_adr_phone1,
            p_adr_phone2,
            p_adr_mobile,
            p_adr_fax,
            p_adr_email,
            l_errd_code); -- 008SO
        COMMIT;
    EXCEPTION
        WHEN exp_duplicate_user_id
        THEN
            geterrcodeanddescfromerrdef (err_duplicate_user_id, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
        WHEN OTHERS
        THEN
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                p_ac_name,
                p_ac_lang,
                p_ac_comment,
                p_ac_type,
                p_ac_dept,
                p_adr_phone1,
                p_adr_phone2,
                p_adr_mobile,
                p_adr_fax,
                p_adr_email,
                SQLCODE); -- 008SO
            RAISE;
    END create_user;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE drop_user (p_ac_short IN VARCHAR2)
    IS
        l_procname                              VARCHAR2 (20) := g_procname_user_drop;
        l_acid                                  VARCHAR2 (10);
        l_acidcurr                              VARCHAR2 (10);
        l_errorcode                             VARCHAR2 (10);
        l_errormsg                              VARCHAR2 (500);
        l_returnstatus                          NUMBER (10);
        l_errd_code                             VARCHAR2 (100);
        l_errd_desc                             VARCHAR2 (4000);
    BEGIN
        l_acidcurr := getcurrentuser ();
        l_acid := getacid (p_ac_short); -- 009SO

        UPDATE account
        SET    ac_esid = 'D',
               ac_short = ac_id,
               ac_comment = ac_comment || 'Previous Id:' || ac_short,
               ac_acidmod = l_acidcurr,
               ac_datemod = SYSDATE,
               ac_chngcnt = ac_chngcnt + 1
        WHERE      ac_short = p_ac_short -- AC_SHORT is unique indexed
               AND ac_esid IN ('A',
                               'I'); -- Allow deletion for active and locked Accounts only
                                     -- Account once soft-deleted can not recovered
                                     -- except by DBA by doing a direct table update

        IF SQL%ROWCOUNT = 0
        THEN
            -- Account with given Short value not found, or could not be updated
            -- return error
            geterrcodeanddescfromerrdef (err_account_not_found, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                NULL, -- p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
        END IF;

        uamlog (
            p_ac_short,
            l_procname,
            l_acid,
            NULL, -- p_ac_name,
            NULL, -- p_ac_lang,
            NULL, -- p_ac_comment,
            NULL, -- p_ac_type,
            NULL, -- p_ac_dept,
            NULL, -- p_adr_phone1,
            NULL, -- p_adr_phone2,
            NULL, -- p_adr_mobile,
            NULL, -- p_adr_fax,
            NULL, -- p_adr_email,
            l_errd_code); -- 008SO
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                NULL, -- p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                SQLCODE); -- 008SO
            RAISE;
    END drop_user;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_group_conn (
        p_ac_short                              IN VARCHAR2,
        p_ac_type                               IN VARCHAR2)
    IS
    BEGIN
        upd_group_conn (p_ac_short, p_ac_type);
    END insert_group_conn;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE lock_user (p_ac_short IN VARCHAR2)
    IS
        l_procname                              VARCHAR2 (20) := g_procname_user_lock;
        l_acid                                  VARCHAR2 (10);
        l_acidcurr                              VARCHAR2 (10);
        l_errorcode                             VARCHAR2 (10);
        l_errormsg                              VARCHAR2 (500);
        l_returnstatus                          NUMBER (10);
        l_errd_code                             VARCHAR2 (100);
        l_errd_desc                             VARCHAR2 (4000);
    BEGIN
        l_acidcurr := getcurrentuser ();
        l_acid := getacid (p_ac_short); -- 009SO

        -- Set the account state to Active to Unlocked the Account
        UPDATE account
        SET    ac_esid = 'I',
               ac_acidmod = l_acidcurr,
               ac_datemod = SYSDATE,
               ac_chngcnt = ac_chngcnt + 1
        WHERE      ac_short = p_ac_short -- AC_SHORT is unique indexed
               AND ac_esid IN ('A'); -- Allow locking of active Accounts only

        IF SQL%ROWCOUNT = 0
        THEN
            -- Account with given Short value not found, or could not be updated
            -- return error (same as in User_UnLock procedure)
            geterrcodeanddescfromerrdef (err_account_not_found, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                NULL, -- p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
        END IF;

        uamlog (
            p_ac_short,
            l_procname,
            l_acid,
            NULL, -- p_ac_name,
            NULL, -- p_ac_lang,
            NULL, -- p_ac_comment,
            NULL, -- p_ac_type,
            NULL, -- p_ac_dept,
            NULL, -- p_adr_phone1,
            NULL, -- p_adr_phone2,
            NULL, -- p_adr_mobile,
            NULL, -- p_adr_fax,
            NULL, -- p_adr_email,
            l_errd_code); -- 008SO
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                NULL, -- p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                SQLCODE); -- 008SO
            RAISE;
    END lock_user;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE unlock_user (p_ac_short IN VARCHAR2)
    IS
        l_procname                              VARCHAR2 (20) := g_procname_user_unlock;
        l_acid                                  VARCHAR2 (10);
        l_acidcurr                              VARCHAR2 (10);
        l_errorcode                             VARCHAR2 (10);
        l_errormsg                              VARCHAR2 (500);
        l_returnstatus                          NUMBER (10);
        l_errd_code                             VARCHAR2 (100);
        l_errd_desc                             VARCHAR2 (4000);
    BEGIN
        l_acidcurr := getcurrentuser ();
        l_acid := getacid (p_ac_short); -- 009SO

        -- Set the account state to Inactive to enforce Locked-Out Account
        UPDATE account
        SET    ac_esid = 'A',
               ac_acidmod = l_acidcurr,
               ac_datemod = SYSDATE,
               ac_chngcnt = ac_chngcnt + 1
        WHERE      ac_short = p_ac_short -- AC_SHORT is unique indexed
               AND ac_esid IN ('I'); -- Only Locked Accounts can be Unlocked
                                     -- Should not include 'D' or any other state

        IF SQL%ROWCOUNT = 0
        THEN
            -- Account with given Short value not found, or could not be updated
            -- return error (same as in User_Lock procedure)
            geterrcodeanddescfromerrdef (err_account_not_found, l_errd_code, l_errd_desc);
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                NULL, -- p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                l_errd_code); -- 008SO
            raise_application_error (l_errd_code, l_errd_desc);
        END IF;

        uamlog (
            p_ac_short,
            l_procname,
            l_acid,
            NULL, -- p_ac_name,
            NULL, -- p_ac_lang,
            NULL, -- p_ac_comment,
            NULL, -- p_ac_type,
            NULL, -- p_ac_dept,
            NULL, -- p_adr_phone1,
            NULL, -- p_adr_phone2,
            NULL, -- p_adr_mobile,
            NULL, -- p_adr_fax,
            NULL, -- p_adr_email,
            l_errd_code); -- 008SO
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                NULL, -- p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                SQLCODE); -- 008SO
            RAISE;
    END unlock_user;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE upd_group_conn (
        p_ac_short                              IN VARCHAR2,
        p_ac_type                               IN VARCHAR2)
    IS
        l_procname                              VARCHAR2 (20) := g_procname_user_updategroup;
        l_acid                                  VARCHAR2 (10);
        l_acidcurr                              VARCHAR2 (10);
        l_errorcode                             VARCHAR2 (10);
        l_errormsg                              VARCHAR2 (500);
        l_returnstatus                          NUMBER (10);

        CURSOR cgetaccount (
            p_ac_short                              IN VARCHAR2,
            p_ac_type                               IN VARCHAR2)
        IS
            SELECT ac_id
            FROM   account
            WHERE      ac_short = p_ac_short
                   AND ac_etid = p_ac_type;

        l_errd_code                             VARCHAR2 (100);
        l_errd_desc                             VARCHAR2 (4000);
    BEGIN
        l_acidcurr := getcurrentuser ();
        l_acid := getacid (p_ac_short); -- 009SO

        -- Check if the Account belongs to the same Type itself
        OPEN cgetaccount (p_ac_short, p_ac_type);

        FETCH cgetaccount INTO l_acid;

        IF cgetaccount%NOTFOUND
        THEN
            -- If not, update the Ac_type
            UPDATE account
            SET    ac_etid = p_ac_type,
                   ac_acidmod = l_acidcurr,
                   ac_datemod = SYSDATE,
                   ac_chngcnt = ac_chngcnt + 1
            WHERE      ac_short = p_ac_short -- AC_SHORT is unique indexed
                   AND ac_etid <> p_ac_type;

            l_acid := getacid (p_ac_short); -- 009SO                            -- If not already in same group

            IF SQL%ROWCOUNT = 0
            THEN
                -- Account with given Short value not found
                -- return error
                geterrcodeanddescfromerrdef (err_account_not_found, l_errd_code, l_errd_desc);
                uamlog (
                    p_ac_short,
                    l_procname,
                    l_acid,
                    NULL, -- p_ac_name,
                    NULL, -- p_ac_lang,
                    NULL, -- p_ac_comment,
                    p_ac_type,
                    NULL, -- p_ac_dept,
                    NULL, -- p_adr_phone1,
                    NULL, -- p_adr_phone2,
                    NULL, -- p_adr_mobile,
                    NULL, -- p_adr_fax,
                    NULL, -- p_adr_email,
                    l_errd_code); -- 008SO
                raise_application_error (l_errd_code, l_errd_desc);
            END IF;
        ELSE
            -- Account already belongs to the given Group
            -- No updated needed
            NULL;
        END IF;

        CLOSE cgetaccount;

        uamlog (
            p_ac_short,
            l_procname,
            l_acid,
            NULL, -- p_ac_name,
            NULL, -- p_ac_lang,
            NULL, -- p_ac_comment,
            p_ac_type,
            NULL, -- p_ac_dept,
            NULL, -- p_adr_phone1,
            NULL, -- p_adr_phone2,
            NULL, -- p_adr_mobile,
            NULL, -- p_adr_fax,
            NULL, -- p_adr_email,
            l_errd_code); -- 008SO
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            uamlog (
                p_ac_short,
                l_procname,
                l_acid,
                NULL, -- p_ac_name,
                NULL, -- p_ac_lang,
                NULL, -- p_ac_comment,
                p_ac_type,
                NULL, -- p_ac_dept,
                NULL, -- p_adr_phone1,
                NULL, -- p_adr_phone2,
                NULL, -- p_adr_mobile,
                NULL, -- p_adr_fax,
                NULL, -- p_adr_email,
                SQLCODE); -- 008SO
            RAISE;
    END upd_group_conn;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getacid (p_ac_short IN VARCHAR2)
        RETURN VARCHAR2
    IS -- 009SO
        CURSOR cgetaccount IS
            SELECT ac_id
            FROM   account
            WHERE  ac_short = p_ac_short;

        l_acid                                  VARCHAR2 (10);
    BEGIN
        OPEN cgetaccount;

        FETCH cgetaccount INTO l_acid;

        CLOSE cgetaccount;

        RETURN l_acid;
    END getacid;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getcurrentuser
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT ('USERENV', 'CURRENT_USER');
    END getcurrentuser;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE geterrcodeanddescfromerrdef (
        l_errid                                 IN     VARCHAR2,
        l_errd_code                                OUT VARCHAR2, --(100)
        l_errd_desc                                OUT VARCHAR2 --(4000)
                                                               )
    IS
    BEGIN
        SELECT errd_value1,
               errd_lang01
        INTO   l_errd_code,
               l_errd_desc
        FROM   errdef
        WHERE  errd_id = l_errid;
    END geterrcodeanddescfromerrdef;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE uamlog (
        p_uaml_acshort                          IN VARCHAR2,
        p_uaml_method                           IN VARCHAR2,
        p_uaml_acid                             IN VARCHAR2,
        p_uaml_name                             IN VARCHAR2,
        p_uaml_langid                           IN VARCHAR2,
        p_uaml_comment                          IN VARCHAR2,
        p_uaml_actype                           IN VARCHAR2,
        p_uaml_dept                             IN VARCHAR2,
        p_uaml_phone1                           IN VARCHAR2,
        p_uaml_phone2                           IN VARCHAR2,
        p_uaml_mobile                           IN VARCHAR2,
        p_uaml_fax                              IN VARCHAR2,
        p_uaml_email                            IN VARCHAR2,
        p_uaml_error                            IN VARCHAR2)
    IS -- 008SO
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_current_user                          VARCHAR2 (10);
    BEGIN
        l_current_user := getcurrentuser ();

        INSERT INTO uamlog (
                        uaml_acshort,
                        uaml_datetime,
                        uaml_uampaid,
                        uaml_method,
                        uaml_login_req,
                        uaml_acid_req,
                        uaml_acid,
                        uaml_name,
                        uaml_langid,
                        uaml_comment,
                        uaml_actype,
                        uaml_dept,
                        uaml_phone1,
                        uaml_phone2,
                        uaml_mobile,
                        uaml_fax,
                        uaml_email,
                        uaml_error)
        VALUES      (
                        p_uaml_acshort,
                        SYSDATE,
                        'USERMNG_SBS',
                        p_uaml_method,
                        NULL,
                        l_current_user,
                        p_uaml_acid,
                        p_uaml_name,
                        p_uaml_langid,
                        p_uaml_comment,
                        p_uaml_actype,
                        p_uaml_dept,
                        p_uaml_phone1,
                        p_uaml_phone2,
                        p_uaml_mobile,
                        p_uaml_fax,
                        p_uaml_email,
                        p_uaml_error);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            pkg_bdetail_common.sp_insert_warning (
                'USERMNG_SBS',
                'uamlog',
                SQLCODE,
                SQLERRM,
                NULL,
                NULL,
                NULL,
                NULL);
            ROLLBACK;
    END uamlog;
END usermng_sbs;
/