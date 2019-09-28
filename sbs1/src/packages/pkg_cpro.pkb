CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_cpro
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Return The Adr_Id of a new tpac address.
       ---------------------------------------------------------------------- */

    FUNCTION gpsh_tpac_new_adr_id (
        p_adr_email                             IN VARCHAR2,
        p_adr_invoiceemail                      IN NUMBER DEFAULT 0,
        p_adr_statisticsmail                    IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_adr_id                                VARCHAR2 (10);
    BEGIN
        SELECT pkg_common.generateuniquekey ('G') INTO l_adr_id FROM DUAL;

        INSERT INTO address (
                        adr_id,
                        adr_etid,
                        adr_demo,
                        adr_esid,
                        adr_email,
                        adr_invoiceemail,
                        adr_statisticsmail,
                        adr_chngcnt)
            SELECT l_adr_id, 'STD', 0, 'A', p_adr_email, p_adr_invoiceemail, p_adr_statisticsmail, 0 FROM DUAL;

        RETURN l_adr_id;
    END gpsh_tpac_new_adr_id;

    /* =========================================================================
       To generate contentservice JSON value (sbsgui like) for the corresponding
       to contract id and cs id.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_content_service_json (p_cs_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        etid                                    VARCHAR2 (10);
        name                                    VARCHAR2 (50);
        service                                 VARCHAR2 (50);
        gart                                    VARCHAR2 (10);
        esid                                    VARCHAR2 (10);
        duobill                                 VARCHAR2 (5);
        return_val                              VARCHAR2 (5000);
    BEGIN
        SELECT cs_etid,
               cs_name,
               cs_service,
               cs_gart,
               cs_ignore_duobill,
               cs_esid
        INTO   etid,
               name,
               service,
               gart,
               duobill,
               esid
        FROM   contentservice RIGHT JOIN DUAL ON cs_id = p_cs_id;

        IF etid IS NULL
        THEN
            RETURN 'null';
        ELSE
            return_val :=
                   '{"CODE":'
                || pkg_json.json_string (service)
                || ',"CSSTATE":{"fk":["csstate",'
                || pkg_json.json_string (esid)
                || ']},"CST":{"fk":["cst",'
                || pkg_json.json_string (etid)
                || ']},"GART":{"fk":["gart",'
                || pkg_json.json_string (gart)
                || ']},"IGNORE_DUOBILL":'
                || pkg_json.json_boolean (duobill)
                || ',"NAME":'
                || pkg_json.json_string (name)
                || '}';
            RETURN return_val;
        END IF;
    END gpull_content_service_json;

    /* =========================================================================
       To generate JSON value (sbsgui like) for the corresponding currency key.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_currency_json (p_cur_key IN VARCHAR2)
        RETURN VARCHAR2
    IS
        p_cur_id                                VARCHAR2 (5);
        p_start                                 VARCHAR2 (20);
        return_val                              VARCHAR2 (5000);
    BEGIN
        SELECT cur_key
        INTO   return_val
        FROM   gpsh_currency_keylist RIGHT JOIN DUAL ON cur_key = p_cur_key;

        IF return_val IS NULL
        THEN
            RETURN 'null';
        ELSE
            SELECT cur_id,
                   exr_start
            INTO   p_cur_id,
                   p_start
            FROM   JSON_TABLE (
                       p_cur_key,
                       '$'
                       COLUMNS (
                           cur_id PATH '$[1]',
                           exr_start PATH '$[3]'));

            IF p_start IS NULL
            THEN
                SELECT '{"CODE":' || pkg_json.json_string (cur_id) || ',"HEADVAL":' || pkg_json.json_number (cur_headval) || ',"NAME":' || pkg_json.json_string (cur_name) || '}'
                INTO   return_val
                FROM   currency
                WHERE  cur_id = p_cur_id;
            ELSE
                SELECT '{"ID":' || pkg_json.json_string (exr_id) || ',"RATE":' || pkg_json.json_number (exr_value) || ',"VALID_FROM":' || pkg_json.json_date (exr_start) || '}'
                INTO   return_val
                FROM   exchangerate
                WHERE      exr_curid = p_cur_id
                       AND exr_start = pkg_json.json_date (p_start);
            END IF;

            RETURN return_val;
        END IF;
    END gpull_currency_json;

    /* =========================================================================
       To generate keyword JSON value (sbsgui like) for the corresponding to
       contract id.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_keyword_json (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        return_val                              VARCHAR2 (5000);

        CURSOR key_cur (key_conid_in IN VARCHAR2)
        IS
            SELECT   key_keyword,
                     key_billrate,
                     key_allowed
            FROM     keyword
            WHERE    key_conid = key_conid_in
            ORDER BY key_keyword ASC,
                     key_billrate ASC;
    BEGIN
        SELECT DISTINCT key_conid
        INTO   return_val
        FROM   keyword RIGHT JOIN DUAL ON key_conid = p_con_id;

        IF return_val IS NULL
        THEN
            RETURN 'null';
        ELSE
            return_val := '{';

            FOR cur IN key_cur (p_con_id)
            LOOP
                return_val :=
                       return_val
                    || pkg_json.json_string (cur.key_keyword)
                    || ':{"ALLOWED":'
                    || pkg_json.json_boolean (cur.key_allowed)
                    || ',"BILLRATE":'
                    || pkg_json.json_number (cur.key_billrate)
                    || '},';
            END LOOP;

            return_val := TRIM (TRAILING ',' FROM return_val) || '}';

            RETURN return_val;
        END IF;
    END gpull_keyword_json;

    /* =========================================================================
       To generate JSON value (sbsgui like) for the corresponding price key.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_price_json (p_price_key IN VARCHAR2)
        RETURN VARCHAR2
    IS
        p_pm_id                                 VARCHAR2 (15);
        p_pmv_id                                VARCHAR2 (15);
        p_pmv_type                              VARCHAR2 (10);
        return_val                              VARCHAR2 (10000);

        CURSOR pmvt_cur (pmv_id_in IN VARCHAR2)
        IS
            SELECT   pmvt_trclass,
                     pmvt_classtype,
                     pmvt_classdesc,
                     pmvt_amountmo,
                     pmvt_amountmt,
                     pmvt_comment
            FROM     prmodelvertrans
            WHERE    pmvt_pmvid = pmv_id_in
            ORDER BY pmvt_classtype ASC,
                     pmvt_trclass ASC;

        CURSOR pme_cur (pmv_id_in IN VARCHAR2)
        IS
            SELECT   pme_billrate,
                     pme_amountcu,
                     DECODE (pme_ratedesc, 'undefined_rate', '', pme_ratedesc)     AS pme_ratedesc,
                     pme_amountpv,
                     pme_amountpv_pp,
                     pme_comment,
                     pme_kw_check,
                     pme_kw_review
            FROM     prmodelentry
            WHERE    pme_pmvid = pmv_id_in
            ORDER BY pme_billrate ASC;
    BEGIN
        SELECT price_key
        INTO   return_val
        FROM   gpsh_price_keylist RIGHT JOIN DUAL ON price_key = p_price_key;

        IF return_val IS NULL
        THEN
            return_val := 'null';
        ELSE
            SELECT pm_id,
                   pmv_id,
                   pmv_type
            INTO   p_pm_id,
                   p_pmv_id,
                   p_pmv_type
            FROM   JSON_TABLE (
                       p_price_key,
                       '$'
                       COLUMNS (
                           pm_id PATH '$[1]',
                           pmv_id PATH '$[3]',
                           pmv_type PATH '$[4]'));

            IF p_pmv_type IS NULL
            THEN
                IF p_pmv_id IS NULL
                THEN
                    --Build price model
                    SELECT '{"COMMENT":' || pkg_json.json_string (pm_comment) || ',"NAME":' || pkg_json.json_string (pm_name) || '}'
                    INTO   return_val
                    FROM   prmodel
                    WHERE  pm_id = p_pm_id;
                ELSE
                    --Build price model version
                    SELECT    '{"COMMENT":'
                           || pkg_json.json_string (pmv_comment)
                           || ',"END":'
                           || DECODE (pmv_end, TO_DATE ('01.01.2100', 'dd.mm.yyyy'), '""', pkg_json.json_date (pmv_end))
                           || ',"NAME":' --SS002
                           || pkg_json.json_string (pmv_name)
                           || ',"START":'
                           || pkg_json.json_date (pmv_start)
                           || '}'
                    INTO   return_val
                    FROM   prmodelver
                    WHERE      pmv_id = p_pmv_id
                           AND pmv_pmid = p_pm_id; -- SO001
                END IF;
            ELSIF p_pmv_type = 'ipprcvbr'
            THEN
                --Build price model version content
                return_val := '[';

                FOR cur IN pme_cur (p_pmv_id)
                LOOP
                    return_val :=
                           return_val
                        || '{"ACU":'
                        || pkg_json.json_number (cur.pme_amountcu)
                        || ',"BR":'
                        || pkg_json.json_number (cur.pme_billrate)
                        || ',"DSC":'
                        || pkg_json.json_string (cur.pme_ratedesc)
                        || ',"SPO":'
                        || pkg_json.json_number (cur.pme_amountpv)
                        || ',"CHK":'
                        || pkg_json.json_boolean (cur.pme_kw_check)
                        || ',"REV":'
                        || pkg_json.json_boolean (cur.pme_kw_review)
                        || ',"REM":'
                        || pkg_json.json_string (cur.pme_comment)
                        || ',"SPR":'
                        || pkg_json.json_number (cur.pme_amountpv_pp) -- SS003
                        || '},';
                END LOOP;

                return_val := TRIM (TRAILING ',' FROM return_val) || ']';
            ELSIF p_pmv_type = 'ipprcvtr'
            THEN
                --Build price model version transport
                return_val := '[';

                FOR cur IN pmvt_cur (p_pmv_id)
                LOOP
                    return_val :=
                           return_val
                        || '{"CLASS":'
                        || pkg_json.json_number (cur.pmvt_trclass)
                        || ',"MEDIUM":'
                        || pkg_json.json_string (cur.pmvt_classtype)
                        || ',"PRICEMO":'
                        || pkg_json.json_number (cur.pmvt_amountmo)
                        || ',"PRICEMT":'
                        || pkg_json.json_number (cur.pmvt_amountmt)
                        || ',"REMARK":'
                        || pkg_json.json_string (cur.pmvt_comment)
                        || '},';
                END LOOP;

                return_val := TRIM (TRAILING ',' FROM return_val) || ']';
            ELSE
                return_val := 'null';
            END IF;
        END IF;

        RETURN return_val;
    END gpull_price_json;

    --
    --[{"ACU":0,"BR":0,"DSC":"0% / 0%","SPO":0},{"ACU":0.1,"BR":1,"DSC":"0% / 100%","SPO":0},{"ACU":0.2,"BR":2,"DSC":"0% / 100%","SPO":0},{"ACU":0.3,"BR":3,"DSC":"0% / 100%","SPO":0},{"ACU":0.4,"BR":4,"DSC":"0% / 100%","SPO":0},{"ACU":0.5,"BR":5,"DSC":"0% / 100%","SPO":0},{"ACU":0.6,"BR":6,"DSC":"0% / 100%","SPO":0},{"ACU":0.7,"BR":7,"DSC":"0% / 100%","SPO":0},{"ACU":0.8,"BR":8,"DSC":"0% / 100%","SPO":0},{"ACU":0.9,"BR":9,"DSC":"0% / 100%","SPO":0},{"ACU":1,"BR":10,"DSC":"0% / 100%","SPO":0},{"ACU":1.1,"BR":11,"DSC":"0% / 100%","SPO":0},{"ACU":1.2,"BR":12,"DSC":"0% / 100%","SPO":0},{"ACU":1.3,"BR":13,"DSC":"0% / 100%","SPO":0},{"ACU":1.4,"BR":14,"DSC":"0% / 100%","SPO":0},{"ACU":1.5,"BR":15,"DSC":"0% / 100%","SPO":0},{"ACU":1.6,"BR":16,"DSC":"0% / 100%","SPO":0},{"ACU":1.7,"BR":17,"DSC":"0% / 100%","SPO":0},{"ACU":1.8,"BR":18,"DSC":"0% / 100%","SPO":0},{"ACU":1.9,"BR":19,"DSC":"0% / 100%","SPO":0},{"ACU":2,"BR":20,"DSC":"0% / 100%","SPO":0},{"ACU":2.1,"BR":21,"DSC":"0% / 100%","SPO":0},{"ACU":2.2,"BR":22,"DSC":"0% / 100%","SPO":0},{"ACU":2.3,"BR":23,"DSC":"0% / 100%","SPO":0},{"ACU":2.4,"BR":24,"DSC":"0% / 100%","SPO":0},{"ACU":2.5,"BR":25,"DSC":"0% / 100%","SPO":0},{"ACU":2.6,"BR":26,"DSC":"0% / 100%","SPO":0},{"ACU":2.7,"BR":27,"DSC":"0% / 100%","SPO":0},{"ACU":2.8,"BR":28,"DSC":"0% / 100%","SPO":0},{"ACU":2.9,"BR":29,"DSC":"0% / 100%","SPO":0},{"ACU":3,"BR":30,"DSC":"0% / 100%","SPO":0},{"ACU":0.2,"BR":40,"DSC":"0%/100%","SPO":0},{"ACU":0,"BR":41,"DSC":"0%/100%","SPO":0},{"ACU":0.2,"BR":42,"DSC":"0%/100%","SPO":0},{"ACU":0.5,"BR":44,"DSC":"0%/100%","SPO":0},{"ACU":0.5,"BR":45,"DSC":"0%/100%","SPO":0},{"ACU":0,"BR":50,"DSC":"Special Split","SPO":0},{"ACU":0.1,"BR":51,"DSC":"0%/100%","SPO":0},{"ACU":0.2,"BR":52,"DSC":"0%/100%","SPO":0},{"ACU":3,"BR":53,"DSC":"0%/100%","SPO":0},{"ACU":20,"BR":54,"DSC":"0%/100%","SPO":0}]
    --[{"CLASS":1,"MEDIUM":"MMS","PRICEMO":0.12,"PRICEMT":0.12,"REMARK":""},{"CLASS":30,"MEDIUM":"MMS","PRICEMO":0.3,"PRICEMT":0.3,"REMARK":""},{"CLASS":300,"MEDIUM":"MMS","PRICEMO":0.54,"PRICEMT":0.54,"REMARK":""},{"CLASS":160,"MEDIUM":"SMS","PRICEMO":0.05,"PRICEMT":0.05,"REMARK":""}]

    /* =========================================================================
       To generate toac smsc JSON value (sbsgui like).
       ---------------------------------------------------------------------- */

    FUNCTION gpull_toac_smsc_json (p_smsc_code IN VARCHAR2)
        RETURN VARCHAR2
    IS
        id                                      VARCHAR2 (10);
        prop_op_key                             VARCHAR2 (50);
        esid                                    VARCHAR2 (10);
        return_val                              VARCHAR2 (5000);
    BEGIN
        SELECT smsc_id,
               smsc_conopkey_prop,
               smsc_esid
        INTO   id,
               prop_op_key,
               esid
        FROM   smsc RIGHT JOIN DUAL ON smsc_code = p_smsc_code;

        IF id IS NULL
        THEN
            RETURN 'null';
        ELSE
            return_val :=
                   '{"NAME":'
                || pkg_json.json_string (p_smsc_code)
                || ',"PROP_OPKEY":'
                || pkg_json.json_string (prop_op_key)
                || ',"SMSC_ID":'
                || pkg_json.json_string (id)
                || ',"STATE":{"fk":["smsc_state",'
                || pkg_json.json_string (esid)
                || ']}}';
            RETURN return_val;
        END IF;
    END gpull_toac_smsc_json;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_tocon_json (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        return_val                              VARCHAR2 (5000);
        mmscuro                                 VARCHAR2 (5);
        mmsioto                                 VARCHAR2 (400);
        smscuro                                 VARCHAR2 (5);
        smscurt                                 VARCHAR2 (5);
        smsioto                                 NUMBER (10, 4);
        smsiott                                 NUMBER (10, 4);
        unlrp                                   VARCHAR2 (100);
        unlrpt                                  VARCHAR2 (100);

        CURSOR mmsioto_cur (con_id_in IN VARCHAR2)
        IS
            SELECT   DISTINCT ciot_curid,
                              TO_CHAR (ciote_price, 9990.9999)     AS price,
                              ciote_msgsize_max
            FROM     coniot
                     INNER JOIN coniote
                         ON     ciot_id = ciote_ciotid
                            AND ciot_conid = con_id_in
                            AND ciot_trctid = 'MMS'
                            AND ciot_iwdid = 'ORIG'
            ORDER BY ciote_msgsize_max ASC;
    BEGIN
        SELECT con_ulnrp
        INTO   unlrpt
        FROM   contract
        WHERE  con_id = p_con_id;

        IF unlrpt IS NULL
        THEN
            unlrp := '{"fks":[["toac", null]]}';
        ELSE
            unlrp := '{"fks":[["toac","' || REPLACE (unlrpt, ';', '"],["toac","') || '"]]}';
        END IF;

        SELECT ciot_curid,
               ciote_price
        INTO   smscuro,
               smsioto
        FROM   coniot
               INNER JOIN coniote
                   ON     ciot_id = ciote_ciotid
                      AND ciot_conid = p_con_id
                      AND ciot_trctid = 'SMS'
                      AND ciot_iwdid = 'ORIG';

        SELECT ciot_curid,
               ciote_price
        INTO   smscurt,
               smsiott
        FROM   coniot
               INNER JOIN coniote
                   ON     ciot_id = ciote_ciotid
                      AND ciot_conid = p_con_id
                      AND ciot_trctid = 'SMS'
                      AND ciot_iwdid = 'TERM';

        mmsioto := NULL;

        FOR cur IN mmsioto_cur (p_con_id)
        LOOP
            mmscuro := cur.ciot_curid;

            IF cur.price IS NULL
            THEN
                mmsioto := mmsioto || '{"IOT":null,"SIZE":' || pkg_json.json_number (NVL (cur.ciote_msgsize_max, 0)) || '},';
            ELSE
                mmsioto := mmsioto || '{"IOT":' || pkg_json.json_number (TRIM (cur.price)) || ',"SIZE":' || pkg_json.json_number (NVL (cur.ciote_msgsize_max, 0)) || '},';
            END IF;
        END LOOP;

        SELECT    '{"CODE":'
               || pkg_json.json_string (con_code)
               || ',"CONSTATE": {"fk":["constate",'
               || pkg_json.json_string (con_esid)
               || ']},"CON_ACID":'
               || pkg_json.json_string (con_acid)
               || ',"CON_NAME":'
               || pkg_json.json_string (con_name)
               || ',"CON_OPKEY":'
               || pkg_json.json_string (con_opkey)
               || ',"DATEEND":'
               || pkg_json.json_date (con_dateend)
               || ',"DATESTART":'
               || pkg_json.json_date (con_datestart)
               || ',"HUB": {"fk":["smshub",'
               || pkg_json.json_string (con_hub)
               || ']},"MMSCURO": {"fk":["cur",'
               || pkg_json.json_string (mmscuro)
               || ']},"MMSIOTO":['
               || TRIM (TRAILING ',' FROM mmsioto)
               || '],"SMSCURO": {"fk":["cur",'
               || pkg_json.json_string (smscuro)
               || ']},"SMSCURT": {"fk":["cur",'
               || pkg_json.json_string (smscurt)
               || ']},"SMSIOTO":'
               || NVL (pkg_json.json_number (smsioto), 'null')
               || ',"SMSIOTT":'
               || NVL (pkg_json.json_number (smsiott), 'null')
               || ',"UNLRP":'
               || unlrp
               || ',"VATO":'
               || pkg_json.json_number (NVL (con_vato, '0'))
               || ',"VATT":'
               || pkg_json.json_number (NVL (con_vatt, '0'))
               || ',"VIRTUAL":'
               || DECODE (NVL (con_virtual, 0),  0, 'false',  1, 'true')
               || '}'
        INTO   return_val
        FROM   contract
        WHERE  con_id = p_con_id;

        RETURN return_val;
    END gpull_tocon_json;

    /* =========================================================================
       To generate tpac JSON value (sbsgui like) for the corresponding to
       account id.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_tpac_json (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        name                                    VARCHAR2 (100);
        invoice_emails                          VARCHAR2 (4000);
        stats_emails                            VARCHAR2 (4000);
        mbunit                                  VARCHAR2 (20);
        return_val                              VARCHAR2 (8100);
    BEGIN
        SELECT ac_name,
               ac_la_invoice_emails,
               ac_bn_stats_emails,
               ac_mbunit
        INTO   name,
               invoice_emails,
               stats_emails,
               mbunit
        FROM   account RIGHT JOIN DUAL ON ac_id = p_ac_id;

        IF name IS NULL
        THEN
            RETURN 'null';
        ELSE
            return_val :=
                   '{"INVOICE_EMAILIDS":'
                || pkg_json.json_string (invoice_emails)
                || ',"MBUNIT":'
                || pkg_json.json_string (mbunit)
                || ',"NAME":'
                || pkg_json.json_string (name)
                || ',"STATISTICS_EMAILIDS":'
                || pkg_json.json_string (stats_emails)
                || '}';
            RETURN return_val;
        END IF;
    END gpull_tpac_json;
/* =========================================================================
   Public Procedure Implementation.
   ---------------------------------------------------------------------- */

END pkg_cpro;
/