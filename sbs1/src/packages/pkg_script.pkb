CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_script
IS
    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION create_entry (
        p_scr_name                              IN VARCHAR2,
        p_scr_line                              IN NUMBER,
        p_scr_text                              IN VARCHAR2,
        p_scr_job                               IN VARCHAR2,
        p_scr_bohid                             IN VARCHAR2)
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE update_entry (
        p_scr_id                                IN VARCHAR2,
        p_scr_bohid                             IN VARCHAR2,
        p_scr_esid                              IN VARCHAR2,
        p_scr_response                          IN VARCHAR2);

    /* =========================================================================
       Public Function Implementation.
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
        RETURN VARCHAR2
    IS --003SO
        id                                      VARCHAR2 (10);
        cmd                                     VARCHAR2 (2000);
        deleted                                 NUMBER;
    BEGIN
        deleted := 0;
        cmd := 'DELETE FROM ' || p_scr_table || ' WHERE ' || p_scr_where;
        id :=
            create_entry (
                p_scr_name,
                p_scr_line,
                cmd,
                p_scr_job,
                p_scr_bohid);

        BEGIN
            IF p_scr_line > 0
            THEN
                -- only execute if line is not 0
                dynsql.delete (p_scr_table, p_scr_where, deleted);
                p_scr_esid := 'OK';
                update_entry (id, p_scr_bohid, p_scr_esid, TO_CHAR (deleted));
            ELSE
                p_scr_esid := 'OK';
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                p_scr_esid := 'E';
                update_entry (id, p_scr_bohid, p_scr_esid, SQLERRM);
        END;

        RETURN id;
    END create_and_delete;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION create_and_execute (
        p_scr_name                              IN     VARCHAR2,
        p_scr_line                              IN     NUMBER, -- 0=do not execute 1...n=do execute
        p_scr_text                              IN     VARCHAR2,
        p_scr_job                               IN     VARCHAR2,
        p_scr_bohid                             IN     VARCHAR2,
        p_scr_esid                                 OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        id                                      VARCHAR2 (10);
    BEGIN
        id :=
            create_entry (
                p_scr_name,
                p_scr_line,
                p_scr_text,
                p_scr_job,
                p_scr_bohid);

        BEGIN
            IF p_scr_line > 0
            THEN
                -- only execute if line is not 0
                dynsql.exec (p_scr_text); --002SO EXECUTE IMMEDIATE P_SCR_TEXT;
                p_scr_esid := 'OK';
                update_entry (id, p_scr_bohid, p_scr_esid, NULL);
            ELSE
                p_scr_esid := 'OK';
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                p_scr_esid := 'E';
                update_entry (id, p_scr_bohid, p_scr_esid, SQLERRM);
        END;

        RETURN id;
    END create_and_execute;

    FUNCTION entry_state (p_scr_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        st                                      VARCHAR2 (10);
    BEGIN
        SELECT scr_esid
        INTO   st
        FROM   script
        WHERE  scr_id = p_scr_id;

        RETURN st;
    END entry_state;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION create_entry (
        p_scr_name                              IN VARCHAR2,
        p_scr_line                              IN NUMBER,
        p_scr_text                              IN VARCHAR2,
        p_scr_job                               IN VARCHAR2,
        p_scr_bohid                             IN VARCHAR2)
        RETURN VARCHAR2
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        id                                      VARCHAR2 (10);
    BEGIN
        id := pkg_common.generateuniquekey ('G');

        INSERT INTO script (
                        scr_id,
                        scr_name,
                        scr_line,
                        scr_text,
                        scr_job,
                        scr_datetime,
                        scr_bohid,
                        scr_esid)
        VALUES      (
                        id,
                        p_scr_name,
                        p_scr_line,
                        p_scr_text,
                        p_scr_job,
                        SYSDATE,
                        p_scr_bohid,
                        'W');

        COMMIT;
        RETURN id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN NULL;
    END create_entry;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE update_entry (
        p_scr_id                                IN VARCHAR2,
        p_scr_bohid                             IN VARCHAR2,
        p_scr_esid                              IN VARCHAR2,
        p_scr_response                          IN VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE script
        SET    scr_bohid = NVL (p_scr_bohid, scr_bohid),
               scr_esid = p_scr_esid,
               scr_dateend = SYSDATE,
               scr_response = NVL (p_scr_response, scr_response)
        WHERE  scr_id = p_scr_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
    END update_entry;
END pkg_script;
/