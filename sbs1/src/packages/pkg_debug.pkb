CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_debug
IS
    vlinecount                              NUMBER;

    /* =========================================================================
       Public Procedure Implementation.
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
        lhint                                   IN VARCHAR2)
    IS
        errorcode                               NUMBER;
        errormsg                                VARCHAR2 (4000);
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF UPPER (what) = 'START'
        THEN
            INSERT INTO reva_debug (
                            bih_id,
                            boh_id,
                            revah_id,
                            startdate,
                            hint)
            VALUES      (
                            lbih_id,
                            lboh_id,
                            lrevah_id,
                            SYSDATE,
                            lhint);
        ELSE
            UPDATE reva_debug
            SET    enddate = SYSDATE,
                   reccount = lreccount
            WHERE      bih_id = lbih_id
                   AND revah_id = lrevah_id;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
    END debug_reva;
END pkg_debug;
/