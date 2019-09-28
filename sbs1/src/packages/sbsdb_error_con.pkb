CREATE OR REPLACE PACKAGE BODY sbsdb_error_con
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Generically raise a application error, called by specific raise_.. procedures.
       Mixes in (or appends) up to 3 variable text pieces into the error message
       Then raises the application error
       ---------------------------------------------------------------------- */

    PROCEDURE raise_appl_error (
        p_errcode_in                            IN PLS_INTEGER,
        p_err_msg_in                            IN VARCHAR2 := NULL,
        p_variable_1_in                         IN VARCHAR2 := NULL,
        p_variable_2_in                         IN VARCHAR2 := NULL,
        p_variable_3_in                         IN VARCHAR2 := NULL,
        p_variable_4_in                         IN VARCHAR2 := NULL)
    IS
        l_errmsg                                sbsdb_type_lib.err_msg_t := p_err_msg_in;
    BEGIN
        IF INSTR (p_err_msg_in, ':1') = 0
        THEN
            l_errmsg := l_errmsg || p_variable_1_in;
        ELSE
            l_errmsg := REPLACE (l_errmsg, ':1', p_variable_1_in);
        END IF;

        IF INSTR (p_err_msg_in, ':2') = 0
        THEN
            l_errmsg := l_errmsg || p_variable_2_in;
        ELSE
            l_errmsg := REPLACE (l_errmsg, ':2', p_variable_2_in);
        END IF;

        IF INSTR (p_err_msg_in, ':3') = 0
        THEN
            l_errmsg := l_errmsg || p_variable_3_in;
        ELSE
            l_errmsg := REPLACE (l_errmsg, ':3', p_variable_3_in);
        END IF;

        IF INSTR (p_err_msg_in, ':4') = 0
        THEN
            l_errmsg := l_errmsg || p_variable_3_in;
        ELSE
            l_errmsg := REPLACE (l_errmsg, ':4', p_variable_4_in);
        END IF;

        raise_application_error (p_errcode_in, l_errmsg);
    END raise_appl_error;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_error_con;
/