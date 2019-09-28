CREATE OR REPLACE PACKAGE BODY pkg_toac_cpro
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_currency_exr_del (
        p_exr_curid                             IN VARCHAR2,
        p_exr_start                             IN VARCHAR2)
    IS
        errorcode                               NUMBER;
        errormsg                                VARCHAR2 (100);
        returncode                              NUMBER;
    BEGIN
        DELETE FROM exchangerate
        WHERE           exr_curid = p_exr_curid
                    AND exr_start = pkg_json.from_json_date (p_exr_start);

        pkg_admin_common.sp_validate_exchange_rates (p_cur_id => p_exr_curid, errorcode => errorcode, errormsg => errormsg, returnstatus => returncode);
    END gpsh_currency_exr_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_currency_exr_put (
        p_cur_id                                IN VARCHAR2,
        p_exr_json                              IN VARCHAR2)
    IS
        id                                      VARCHAR2 (10);
        rate                                    VARCHAR2 (50);
        valid_from                              VARCHAR2 (20);
        valid_to                                VARCHAR2 (20);
        t_exr_id                                VARCHAR2 (20);

        errorcode                               NUMBER;
        errormsg                                VARCHAR2 (100);
        returncode                              NUMBER;
    BEGIN
        SELECT exr_id,
               exr_rate,
               exr_valid_from,
               exr_valid_to
        INTO   id,
               rate,
               valid_from,
               valid_to
        FROM   JSON_TABLE (
                   p_exr_json,
                   '$'
                   COLUMNS (
                       exr_id PATH '$.ID',
                       exr_rate PATH '$.RATE',
                       exr_valid_from PATH '$.VALID_FROM',
                       exr_valid_to PATH '$.VALID_TO'));

        IF valid_to IS NULL
        THEN
            valid_to := '2100-01-01T00:00:00Z';
        END IF;

        SELECT exr_id
        INTO   t_exr_id
        FROM   exchangerate
               RIGHT JOIN DUAL
                   ON     exr_start = pkg_json.from_json_date (valid_from)
                      AND exr_curid = p_cur_id;

        IF     t_exr_id IS NOT NULL
           AND t_exr_id <> id
        THEN
            DELETE FROM exchangerate
            WHERE       exr_id = t_exr_id;
        END IF;

        SELECT exr_id
        INTO   t_exr_id
        FROM   exchangerate RIGHT JOIN DUAL ON exr_id = id;

        IF t_exr_id IS NULL
        THEN
            INSERT INTO exchangerate (
                            exr_id,
                            exr_curid,
                            exr_value,
                            exr_start,
                            exr_end,
                            exr_datecre)
            VALUES      (
                            id,
                            p_cur_id,
                            rate,
                            pkg_json.from_json_date (valid_from),
                            pkg_json.from_json_date (valid_to),
                            SYSDATE);
        ELSE
            UPDATE exchangerate
            SET    exr_curid = p_cur_id,
                   exr_value = rate,
                   exr_start = pkg_json.from_json_date (valid_from),
                   exr_end = pkg_json.from_json_date (valid_to),
                   exr_datemod = SYSDATE
            WHERE  exr_id = id;
        END IF;

        pkg_admin_common.sp_validate_exchange_rates (p_cur_id => p_cur_id, errorcode => errorcode, errormsg => errormsg, returnstatus => returncode);
    END gpsh_currency_exr_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_currency_put (p_cur_json IN VARCHAR2)
    IS
        code                                    VARCHAR2 (10);
        name                                    VARCHAR2 (50);
        headval                                 VARCHAR2 (15);
        t_cur_id                                VARCHAR2 (20);
    BEGIN
        SELECT cur_code,
               cur_name,
               cur_headval
        INTO   code,
               name,
               headval
        FROM   JSON_TABLE (
                   p_cur_json,
                   '$'
                   COLUMNS (
                       cur_code PATH '$.CODE',
                       cur_name PATH '$.NAME',
                       cur_headval PATH '$.HEADVAL'));

        SELECT cur_id
        INTO   t_cur_id
        FROM   currency RIGHT JOIN DUAL ON cur_id = code;

        IF t_cur_id IS NULL
        THEN
            INSERT INTO currency (
                            cur_id,
                            cur_name,
                            cur_headval,
                            cur_datecre)
            VALUES      (
                            code,
                            name,
                            headval,
                            SYSDATE);
        ELSE
            UPDATE currency
            SET    cur_name = name,
                   cur_headval = headval,
                   cur_datemod = SYSDATE
            WHERE  cur_id = code;
        END IF;
    END gpsh_currency_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_con_del (p_con_id IN VARCHAR2)
    IS
    BEGIN
        UPDATE contract
        SET    con_esid = 'D'
        WHERE  con_id = p_con_id;
    END gpsh_toac_con_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_con_put (
        p_con_id                                IN VARCHAR2,
        p_con_json                              IN VARCHAR2)
    IS
        acid                                    VARCHAR2 (20);
        opkey                                   VARCHAR2 (20);
        name                                    VARCHAR2 (50);
        code                                    VARCHAR2 (19);
        esid                                    VARCHAR2 (1);
        dateend                                 VARCHAR2 (25);
        datestart                               VARCHAR2 (25);
        hub                                     VARCHAR2 (10);
        unlrpl                                  VARCHAR2 (100);
        unlrp                                   VARCHAR2 (100);
        vato                                    NUMBER (10, 4); --005SS
        vatt                                    NUMBER (10, 4); --005SS
        virtual                                 VARCHAR2 (6);
        smscuro                                 VARCHAR2 (5);
        smsioto                                 NUMBER (10, 4);
        smscurt                                 VARCHAR2 (5);
        smsiott                                 NUMBER (10, 4);
        mmscuro                                 VARCHAR2 (5);
        mmsioto                                 VARCHAR2 (400);
        l_ac_id                                 VARCHAR2 (10);

        current_smscuro_id                      VARCHAR2 (10);
        current_smscurt_id                      VARCHAR2 (10);
        current_mmscuro_id                      VARCHAR2 (10);
        mmscuro_count                           NUMBER;

        CURSOR cacc (con_acid_in IN VARCHAR2)
        IS
            SELECT ac_id
            FROM   account
            WHERE  ac_id = con_acid_in;

        CURSOR mmsioto_cur (mmscuro_in IN VARCHAR2)
        IS
            SELECT j.iot,
                   j.siz
            FROM   JSON_TABLE (
                       mmscuro_in,
                       '$[*]'
                       COLUMNS (
                           iot PATH '$.IOT',
                           siz PATH '$.SIZE')) AS j;
    BEGIN
        SELECT con_acid,
               con_name,
               con_opkey,
               con_code,
               con_esid,
               con_dateend,
               con_datestart,
               con_hub,
               con_unlrp,
               con_vato,
               con_vatt,
               con_virtual,
               con_smscuro,
               con_smsioto,
               con_smscurt,
               con_smsiott,
               con_mmscuro,
               con_mmsioto
        INTO   acid,
               name,
               opkey,
               code,
               esid,
               dateend,
               datestart,
               hub,
               unlrpl,
               vato,
               vatt,
               virtual,
               smscuro,
               smsioto,
               smscurt,
               smsiott,
               mmscuro,
               mmsioto
        FROM   JSON_TABLE (
                   p_con_json,
                   '$'
                   COLUMNS (
                       con_acid PATH '$.CON_ACID',
                       con_name PATH '$.CON_NAME',
                       con_opkey PATH '$.CON_OPKEY',
                       con_code PATH '$.CODE',
                       con_esid PATH '$.CONSTATE.fk[1]',
                       con_dateend PATH '$.DATEEND',
                       con_datestart PATH '$.DATESTART',
                       con_hub PATH '$.HUB.fk[1]',
                       con_unlrp VARCHAR2 (100) FORMAT JSON WITH WRAPPER PATH '$.UNLRP.fks[*][1]',
                       con_vato NUMBER PATH '$.VATO', --005SS
                       con_vatt NUMBER PATH '$.VATT', --005SS
                       con_virtual PATH '$.VIRTUAL',
                       con_smscuro PATH '$.SMSCURO.fk[1]',
                       con_smsioto NUMBER PATH '$.SMSIOTO',
                       con_smscurt PATH '$.SMSCURT.fk[1]',
                       con_smsiott NUMBER PATH '$.SMSIOTT',
                       con_mmscuro PATH '$.MMSCURO.fk[1]',
                       con_mmsioto VARCHAR2 (400) FORMAT JSON PATH '$.MMSIOTO'));

        unlrp := TRIM ('"' FROM REPLACE (REPLACE (TRIM (TRAILING ']' FROM TRIM (LEADING '[' FROM unlrpl)), 'null'), '","', ';'));

        OPEN cacc (acid);

        FETCH cacc INTO l_ac_id;

        IF cacc%NOTFOUND
        THEN
            INSERT INTO account (
                            ac_id,
                            ac_etid,
                            ac_demo,
                            ac_short,
                            ac_name,
                            ac_logret,
                            ac_langid,
                            ac_vat,
                            ac_currency,
                            ac_esid,
                            ac_adrid_main,
                            ac_adrid_maincontact,
                            ac_datecre,
                            ac_chngcnt)
                SELECT acid, 'TOP', 0, acid, name, 0, 'de', 0, 'CHF', 'A', pkg_cpro.gpsh_tpac_new_adr_id (NULL), pkg_cpro.gpsh_tpac_new_adr_id (NULL), SYSDATE, 0 FROM DUAL;
        END IF;

        CLOSE cacc;

        UPDATE contract
        SET    con_acid = acid,
               con_name = name,
               con_opkey = opkey,
               con_dateend = pkg_json.from_json_date (dateend),
               con_datestart = pkg_json.from_json_date (datestart),
               con_esid = esid,
               con_code = code,
               con_hub = hub,
               con_virtual = DECODE (virtual,  'true', 1,  'false', 0),
               con_ulnrp = unlrp,
               con_vato = vato,
               con_vatt = vatt,
               con_json = p_con_json,
               con_datemod = SYSDATE
        WHERE  con_id = p_con_id; -- 004SO

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO contract (
                            con_id,
                            con_acid,
                            con_name,
                            con_opkey,
                            con_dateend,
                            con_datestart,
                            con_esid,
                            con_etid,
                            con_code,
                            con_hub,
                            con_virtual,
                            con_ulnrp,
                            con_vato,
                            con_vatt,
                            con_srctype,
                            con_json,
                            con_datecre)
            VALUES      (
                            p_con_id,
                            acid,
                            name,
                            opkey,
                            pkg_json.from_json_date (dateend),
                            pkg_json.from_json_date (datestart),
                            esid,
                            'TOC',
                            code,
                            hub,
                            DECODE (virtual,  'true', 1,  'false', 0),
                            unlrp,
                            vato,
                            vatt,
                            'OPER',
                            p_con_json,
                            SYSDATE); -- 006SO -- 004SO
        END IF;

        SELECT ciot_id
        INTO   current_smscuro_id
        FROM   coniot
               RIGHT JOIN DUAL
                   ON     ciot_iwdid = 'ORIG'
                      AND ciot_conid = p_con_id
                      AND ciot_trctid = 'SMS';

        IF current_smscuro_id IS NULL
        THEN
            current_smscuro_id := pkg_common.generateuniquekey ('G');

            INSERT INTO coniot (
                            ciot_id,
                            ciot_conid,
                            ciot_iwdid,
                            ciot_trctid,
                            ciot_curid,
                            ciot_datecre)
            VALUES      (
                            current_smscuro_id,
                            p_con_id,
                            'ORIG',
                            'SMS',
                            smscuro,
                            SYSDATE);

            INSERT INTO coniote (
                            ciote_id,
                            ciote_ciotid,
                            ciote_price,
                            ciote_datecre)
            VALUES      (
                            pkg_common.generateuniquekey ('G'),
                            current_smscuro_id,
                            smsioto,
                            SYSDATE);
        ELSE
            UPDATE coniot
            SET    ciot_curid = smscuro,
                   ciot_datemod = SYSDATE
            WHERE  ciot_id = current_smscuro_id;

            UPDATE coniote
            SET    ciote_price = smsioto,
                   ciote_datemod = SYSDATE
            WHERE  ciote_ciotid = current_smscuro_id;
        END IF;

        SELECT ciot_id
        INTO   current_smscurt_id
        FROM   coniot
               RIGHT JOIN DUAL
                   ON     ciot_iwdid = 'TERM'
                      AND ciot_conid = p_con_id
                      AND ciot_trctid = 'SMS';

        IF current_smscurt_id IS NULL
        THEN
            current_smscurt_id := pkg_common.generateuniquekey ('G');

            INSERT INTO coniot (
                            ciot_id,
                            ciot_conid,
                            ciot_iwdid,
                            ciot_trctid,
                            ciot_curid,
                            ciot_datecre)
            VALUES      (
                            current_smscurt_id,
                            p_con_id,
                            'TERM',
                            'SMS',
                            smscurt,
                            SYSDATE);

            INSERT INTO coniote (
                            ciote_id,
                            ciote_ciotid,
                            ciote_price,
                            ciote_datecre)
            VALUES      (
                            pkg_common.generateuniquekey ('G'),
                            current_smscurt_id,
                            smsiott,
                            SYSDATE);
        ELSE
            UPDATE coniot
            SET    ciot_curid = smscurt,
                   ciot_datemod = SYSDATE
            WHERE  ciot_id = current_smscurt_id;

            UPDATE coniote
            SET    ciote_price = smsiott,
                   ciote_datemod = SYSDATE
            WHERE  ciote_ciotid = current_smscurt_id;
        END IF;

        SELECT ciot_id
        INTO   current_mmscuro_id
        FROM   coniot
               RIGHT JOIN DUAL
                   ON     ciot_iwdid = 'ORIG'
                      AND ciot_conid = p_con_id
                      AND ciot_trctid = 'MMS';

        IF current_mmscuro_id IS NULL
        THEN
            current_mmscuro_id := pkg_common.generateuniquekey ('G');

            INSERT INTO coniot (
                            ciot_id,
                            ciot_conid,
                            ciot_iwdid,
                            ciot_trctid,
                            ciot_curid,
                            ciot_datecre)
            VALUES      (
                            current_mmscuro_id,
                            p_con_id,
                            'ORIG',
                            'MMS',
                            mmscuro,
                            SYSDATE);

            FOR cur IN mmsioto_cur (mmsioto)
            LOOP
                INSERT INTO coniote (
                                ciote_id,
                                ciote_ciotid,
                                ciote_msgsize_max,
                                ciote_price,
                                ciote_datecre)
                VALUES      (
                                pkg_common.generateuniquekey ('G'),
                                current_mmscuro_id,
                                cur.siz,
                                cur.iot,
                                SYSDATE);
            END LOOP;
        ELSE
            UPDATE coniot
            SET    ciot_curid = mmscuro,
                   ciot_datemod = SYSDATE
            WHERE  ciot_id = current_mmscuro_id;

            SELECT COUNT (*)
            INTO   mmscuro_count
            FROM   ((SELECT price,
                            siz
                     FROM   JSON_TABLE (
                                mmsioto,
                                '$[*]'
                                COLUMNS (
                                    price NUMBER PATH '$.IOT',
                                    siz NUMBER PATH '$.SIZE'))
                     MINUS
                     SELECT ciote_price,
                            ciote_msgsize_max
                     FROM   coniote
                     WHERE  ciote_ciotid = current_mmscuro_id)
                    UNION ALL
                    (SELECT ciote_price,
                            ciote_msgsize_max
                     FROM   coniote
                     WHERE  ciote_ciotid = current_mmscuro_id
                     MINUS
                     SELECT price,
                            siz
                     FROM   JSON_TABLE (
                                mmsioto,
                                '$[*]'
                                COLUMNS (
                                    price NUMBER PATH '$.IOT',
                                    siz NUMBER PATH '$.SIZE')))); -- 001SO  Table Diff

            IF mmscuro_count <> 0
            THEN -- 002SS
                DELETE FROM coniote
                WHERE       ciote_ciotid = current_mmscuro_id;

                FOR cur IN mmsioto_cur (mmsioto)
                LOOP
                    INSERT INTO coniote (
                                    ciote_id,
                                    ciote_ciotid,
                                    ciote_msgsize_max,
                                    ciote_price,
                                    ciote_datecre)
                    VALUES      (
                                    pkg_common.generateuniquekey ('G'),
                                    current_mmscuro_id,
                                    cur.siz,
                                    cur.iot,
                                    SYSDATE);
                END LOOP;
            END IF;
        END IF;

        UPDATE coniote m
        SET    m.ciote_msgsize_min =
                   (SELECT NVL (MAX (l.ciote_msgsize_max), 0)
                    FROM   coniote l
                    WHERE      l.ciote_ciotid = current_mmscuro_id
                           AND (   l.ciote_msgsize_max < m.ciote_msgsize_max
                                OR m.ciote_msgsize_max = 9999999.999))
        WHERE  m.ciote_ciotid = current_mmscuro_id; -- 003S0
    END gpsh_toac_con_put;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_smsc_del (
        p_smsc_code                             IN VARCHAR2,
        p_smsc_conopkey                         IN VARCHAR2)
    IS
    BEGIN
        DELETE FROM smsc
        WHERE           smsc_code = p_smsc_code
                    AND smsc_conopkey = p_smsc_conopkey;
    END gpsh_toac_smsc_del;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_smsc_put (
        p_conop_key                             IN VARCHAR2,
        p_smsc_json                             IN VARCHAR2)
    IS
        code                                    VARCHAR2 (50);
        id                                      VARCHAR2 (50);
        esid                                    VARCHAR2 (10);
        prop_opkey                              VARCHAR2 (20);
        t_smsc_id                               VARCHAR2 (20);
    BEGIN
        SELECT smsc_id,
               smsc_code,
               smsc_esid,
               smsc_conopkey_prop
        INTO   id,
               code,
               esid,
               prop_opkey
        FROM   JSON_TABLE (
                   p_smsc_json,
                   '$'
                   COLUMNS (
                       smsc_id PATH '$.SMSC_ID',
                       smsc_code PATH '$.NAME',
                       smsc_esid PATH '$.STATE.fk[1]',
                       smsc_conopkey_prop PATH '$.PROP_OPKEY'));

        SELECT smsc_id
        INTO   t_smsc_id
        FROM   smsc RIGHT JOIN DUAL ON smsc_id = id;

        IF t_smsc_id IS NULL
        THEN
            INSERT INTO smsc (
                            smsc_id,
                            smsc_conopkey,
                            smsc_code,
                            smsc_esid,
                            smsc_conopkey_prop,
                            smsc_datecre)
            VALUES      (
                            id,
                            p_conop_key,
                            code,
                            esid,
                            prop_opkey,
                            SYSDATE);
        ELSE
            UPDATE smsc
            SET    smsc_conopkey = p_conop_key,
                   smsc_code = code,
                   smsc_esid = esid,
                   smsc_conopkey_prop = prop_opkey,
                   smsc_datemod = SYSDATE
            WHERE  smsc_id = id;
        END IF;
    END gpsh_toac_smsc_put;
END pkg_toac_cpro;
/