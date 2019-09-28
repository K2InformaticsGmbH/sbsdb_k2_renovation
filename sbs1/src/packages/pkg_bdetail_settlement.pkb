CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_bdetail_settlement
IS
    cstrofficiallongid                      VARCHAR2 (20) := '4179807%'; --036SO

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION billtextla (
        p_consolidation                         IN VARCHAR2,
        p_tarid                                 IN VARCHAR2,
        p_international                         IN VARCHAR2,
        p_sed_etid                              IN VARCHAR2,
        p_sed_prepaid                           IN VARCHAR2,
        p_sed_count1                            IN NUMBER,
        p_sed_count2                            IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION billtextli (
        p_consolidation                         IN VARCHAR2,
        p_sed_count1                            IN NUMBER,
        p_sed_count2                            IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION billtextmincharge (
        p_consolidation                         IN VARCHAR2,
        p_tarid                                 IN VARCHAR2,
        p_datetime                              IN DATE)
        RETURN VARCHAR2;

    FUNCTION nextavailabletimestamp (
        p_sed_charge                            IN VARCHAR2,
        p_sed_date                              IN DATE)
        RETURN NUMBER; -- seconds after midnight

    FUNCTION ufihrendered (
        p_sed_date                              IN VARCHAR2,
        p_sed_charge                            IN VARCHAR2,
        p_sed_price                             IN FLOAT,
        p_sed_desc                              IN VARCHAR2,
        p_gart                                  IN NUMBER,
        p_sed_tarid                             IN VARCHAR2)
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE insertperiod (p_code IN VARCHAR2);

    PROCEDURE sp_insert_setdetail (
        p_sed_setid                             IN     VARCHAR2,
        p_sed_etid                              IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_quantity                          IN     FLOAT,
        p_sed_discount                          IN     FLOAT,
        p_sed_vatid                             IN     VARCHAR2,
        p_sed_vatrate                           IN     FLOAT,
        p_sed_desc                              IN     VARCHAR2,
        p_sed_order                             IN     VARCHAR2,
        p_sed_visible                           IN     NUMBER,
        p_sed_comment                           IN     VARCHAR2,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_charge                            IN     VARCHAR2,
        p_sed_bohid                             IN     VARCHAR2,
        p_sed_pmvid                             IN     VARCHAR2,
        p_sed_tarid                             IN     VARCHAR2,
        p_sed_esid                              IN     VARCHAR2,
        p_sed_int                               IN     VARCHAR2,
        p_sed_date                              IN     VARCHAR2,
        p_sed_prepaid                           IN     VARCHAR2, --001SO
        p_sed_amountcu                          IN     FLOAT, --001SO
        p_sed_retsharepv                        IN     FLOAT, --001SO
        p_sed_retsharemo                        IN     FLOAT, --001SO
        p_sed_longid_1                          IN     VARCHAR2, --036SO --003SO
        p_sed_longid_2                          IN     VARCHAR2, --036SO
        p_sed_id                                   OUT VARCHAR2,
        p_sed_pos                                  OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER);

    PROCEDURE sp_insert_settling (
        p_set_etid                              IN     VARCHAR2,
        p_set_conid                             IN     VARCHAR2,
        p_set_demo                              IN     NUMBER,
        p_set_sepid                             IN     VARCHAR2,
        p_set_setidold                          IN     VARCHAR2,
        p_set_currency                          IN     VARCHAR2,
        p_set_comment                           IN     VARCHAR2,
        p_set_id                                   OUT VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER);

    PROCEDURE sp_update_setdetail (
        p_sed_id                                IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_quantity                          IN     FLOAT,
        p_sed_discount                          IN     FLOAT,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_amountcu                          IN     FLOAT, --001SO
        p_sed_retsharepv                        IN     FLOAT, --001SO
        p_sed_retsharemo                        IN     FLOAT, --001SO
        p_sed_pos                                  OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION nextavailableorder (
        p_sed_charge                            IN VARCHAR2,
        p_sed_date                              IN DATE)
        RETURN VARCHAR2
    IS --004SO
        CURSOR cexisting IS
            SELECT TO_DATE (MIN (sed_order), 'yyyy-mm-dd hh24:mi:ss')
            FROM   setdetail
            WHERE      sed_charge = p_sed_charge
                   AND sed_order >= TO_CHAR (TRUNC (p_sed_date) + 0.5, 'yyyy-mm-dd hh24:mi:ss')
                   AND sed_order < TO_CHAR (TRUNC (p_sed_date) + 1, 'yyyy-mm-dd hh24:mi:ss');

        l_existing_order                        DATE;
    BEGIN
        OPEN cexisting;

        FETCH cexisting INTO l_existing_order;

        CLOSE cexisting;

        IF l_existing_order IS NULL
        THEN
            l_existing_order := TRUNC (p_sed_date) + 1.0;
        END IF;

        RETURN TO_CHAR (l_existing_order - 1 / 24 / 3600, 'yyyy-mm-dd hh24:mi:ss');
    END nextavailableorder;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION settledduration (
        con_datestart                           IN DATE,
        con_dateend                             IN DATE)
        RETURN NUMBER
    IS
    BEGIN
        RETURN (  LEAST (NVL (con_dateend, TRUNC (SYSDATE, 'MONTH')), TRUNC (SYSDATE, 'MONTH'))
                - GREATEST (NVL (con_datestart, TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')), TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')));
    END settledduration;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_add_setdetail (
        p_set_etid                              IN     VARCHAR2,
        p_sed_etid                              IN     VARCHAR2,
        p_sed_charge                            IN     VARCHAR2,
        p_sed_bohid                             IN     VARCHAR2,
        p_date                                  IN     DATE,
        p_set_conid                             IN     VARCHAR2,
        p_sed_tarid                             IN     VARCHAR2,
        p_sed_int                               IN     VARCHAR2,
        p_sed_prepaid                           IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_amountcu                          IN     FLOAT,
        p_sed_retsharepv                        IN     FLOAT,
        p_sed_retsharemo                        IN     FLOAT,
        p_sed_longid                            IN     VARCHAR2,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_desc                              IN     VARCHAR2,
        p_gart                                  IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --006SO
        l_order                                 VARCHAR2 (20);
        l_date                                  VARCHAR2 (20);

        l_sep_id                                VARCHAR2 (10);
        l_set_id                                VARCHAR2 (10);
        l_sed_id                                VARCHAR2 (10);
        l_sed_pos                               NUMBER;

        l_ufih                                  VARCHAR2 (400); --013SO
        l_ufihstream                            VARCHAR2 (10); --013SO
        l_schedule_zero_ufih                    BOOLEAN; --025SO
    BEGIN
        returnstatus := 0; --011SO

        l_date := TO_CHAR (p_date, 'yyyy-mm-dd hh24:mi:ss');
        l_order := l_date;

        --        L('SP_ADD_SETDETAIL_BY_DATE');
        --        L('p_SET_ETID',p_SET_ETID);
        --        L('p_SED_ETID',p_SED_ETID);
        --        L('p_SED_CHARGE',p_SED_CHARGE);
        --        L('p_SED_BOHID',p_SED_BOHID);
        --        L('p_Date',p_Date);
        --        L('p_SET_CONID',p_SET_CONID);
        --        L('p_SED_TARID',p_SED_TARID);
        --        L('p_SED_INT',p_SED_INT);
        --        L('p_SED_PREPAID',p_SED_PREPAID);
        --        L('p_SED_PRICE',p_SED_PRICE);
        --        L('p_SED_AMOUNTCU',p_SED_AMOUNTCU);
        --        L('p_SED_RETSHAREPV',p_SED_RETSHAREPV);
        --        L('p_SED_RETSHAREMO',p_SED_RETSHAREMO);
        --        L('p_SED_LONGID',p_SED_LONGID);
        --        L('p_SED_COUNT1',p_SED_COUNT1);
        --        L('p_SED_COUNT2',p_SED_COUNT2);
        --        L('p_SED_DESC',p_SED_DESC);
        --        L('l_date',l_date);

        sp_add_setdetail_by_date (
            l_date, -- p_Date           IN varchar2,
            p_set_conid, -- p_SET_CONID      IN varchar2,
            p_set_etid, -- p_SET_ETID       IN varchar2,
            0, -- p_SET_DEMO       IN number,
            'CHF', -- p_SET_CURRENCY   IN varchar2,
            NULL, -- p_SET_COMMENT    IN varchar2,
            p_sed_etid, -- p_SED_ETID       IN varchar2,
            p_sed_price, -- p_SED_PRICE      IN float,
            1.0, -- p_SED_QUANTITY   IN float,
            0.0, -- p_SED_DISCOUNT   IN float,
            'NA', -- p_SED_VATID      IN varchar2, --  030SO
            0.0, -- p_SED_VATRATE    IN float,
            p_sed_desc, -- p_SED_DESC       IN varchar2,
            l_order, -- p_SED_ORDER      IN varchar2,
            1, -- p_SED_VISIBLE    IN number,
            NULL, -- p_SED_COMMENT    IN varchar2,
            p_sed_count1, -- p_SED_COUNT1     IN number,
            p_sed_count2, -- p_SED_COUNT2     IN number,
            p_sed_charge, -- p_SED_CHARGE     IN varchar2,
            p_sed_bohid, -- p_SED_BOHID      IN varchar2,
            NULL, -- p_SED_PMVID      IN varchar2,
            p_sed_tarid, -- p_SED_TARID      IN varchar2,
            'A', -- p_SED_ESID       IN varchar2,
            p_sed_int, -- p_SED_INT        IN varchar2,
            p_sed_prepaid, -- p_SED_PREPAID    IN varchar2,
            p_sed_amountcu, -- p_SED_AMOUNTCU   IN float,
            p_sed_retsharepv, -- p_SED_RETSHAREPV IN float,
            p_sed_retsharemo, -- p_SED_RETSHAREMO IN float,
            p_sed_longid, -- p_SED_LONGID_1   IN varchar2, --036SO
            NULL, -- p_SED_LONGID_2   IN varchar2, --036SO
            l_sep_id, -- p_SEP_ID         OUT varchar2,
            l_set_id, -- p_SET_ID         OUT varchar2,
            l_sed_id, -- p_SED_ID         OUT varchar2,
            l_sed_pos, -- p_SED_POS        OUT number,
            errorcode, -- ErrorCode        OUT number,
            errormsg, -- ErrorMsg         OUT varchar2,
            returnstatus -- ReturnStatus     IN OUT number
                        );

        IF     (returnstatus = 1)
           AND (p_sed_desc <> 'accumulating')
        THEN
            -- Render UFIH output CDR and storein SETDETAIL

            l_schedule_zero_ufih := TRUE; --025SO

            IF p_sed_etid IN ('CDR',
                              'PAG',
                              'MFLID',
                              'MFGR')
            THEN --039SO
                l_ufihstream := 'UN_SBS4';
                l_schedule_zero_ufih := FALSE; --028SO
            ELSIF p_sed_etid IN ('MCC')
            THEN
                l_ufihstream := 'UN_SBS8';
                l_schedule_zero_ufih := FALSE; --028SO
            ELSIF p_sed_etid IN ('IOTLACT',
                                 'MOFN')
            THEN
                l_ufihstream := 'UN_SBS9';
                l_schedule_zero_ufih := FALSE; --028SO
            ELSIF p_sed_etid IN ('MOIWST')
            THEN
                l_ufihstream := 'UN_SBS9';
                l_schedule_zero_ufih := FALSE; --025SO
            ELSE
                l_ufihstream := NULL;
            END IF;

            IF l_ufihstream IS NOT NULL
            THEN
                l_ufih :=
                    ufihrendered (
                        l_date, -- IN varchar2,
                        p_sed_charge, -- IN varchar2,
                        p_sed_price, -- IN float,
                        p_sed_desc, -- IN varchar2,
                        p_gart, -- IN varchar2,
                        p_sed_tarid -- IN varchar2
                                   ); --034SO

                IF    l_schedule_zero_ufih
                   OR (p_sed_count1 <> 0)
                   OR (p_sed_count2 <> 0)
                   OR (p_sed_price <> 0.00)
                THEN
                    UPDATE setdetail
                    SET    sed_ufih_stream = l_ufihstream,
                           sed_ufih_out = l_ufih,
                           sed_ufih_bosid = 'S'
                    WHERE  sed_id = l_sed_id; -- schedule the UFIH CDR file output
                ELSE -- l_schedule_zero_ufih or .. = false
                    UPDATE setdetail
                    SET    sed_ufih_stream = l_ufihstream,
                           sed_ufih_out = l_ufih
                    WHERE  sed_id = l_sed_id; -- only store the UFIH CDR file output without scheduling   --025SO
                END IF; -- l_schedule_zero_ufih or .. = false
            END IF; -- l_UfihStream IS NOT NULL
        END IF; -- (ReturnStatus = 1)and (p_SED_DESC <> 'accumulating')

        RETURN;
    --    --      --011SO
    --    Exception
    --    When Others then
    --       ErrorCode := SQLCODE;
    --       ErrorMsg  := SQLERRM;
    --       ReturnStatus := 0;

    END sp_add_setdetail;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_add_setdetail_by_date (
        p_date                                  IN     VARCHAR2,
        p_set_conid                             IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2,
        p_set_demo                              IN     NUMBER,
        p_set_currency                          IN     VARCHAR2,
        p_set_comment                           IN     VARCHAR2,
        p_sed_etid                              IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_quantity                          IN     FLOAT,
        p_sed_discount                          IN     FLOAT,
        p_sed_vatid                             IN     VARCHAR2,
        p_sed_vatrate                           IN     FLOAT,
        p_sed_desc                              IN     VARCHAR2,
        p_sed_order                             IN     VARCHAR2,
        p_sed_visible                           IN     NUMBER,
        p_sed_comment                           IN     VARCHAR2,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_charge                            IN     VARCHAR2,
        p_sed_bohid                             IN     VARCHAR2,
        p_sed_pmvid                             IN     VARCHAR2,
        p_sed_tarid                             IN     VARCHAR2,
        p_sed_esid                              IN     VARCHAR2,
        p_sed_int                               IN     VARCHAR2,
        p_sed_prepaid                           IN     VARCHAR2, --001SO
        p_sed_amountcu                          IN     FLOAT, --001SO
        p_sed_retsharepv                        IN     FLOAT, --001SO
        p_sed_retsharemo                        IN     FLOAT, --001SO
        p_sed_longid_1                          IN     VARCHAR2, --036SO --003SO
        p_sed_longid_2                          IN     VARCHAR2, --036SO
        p_sep_id                                   OUT VARCHAR2,
        p_set_id                                   OUT VARCHAR2,
        p_sed_id                                   OUT VARCHAR2,
        p_sed_pos                                  OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        CURSOR c3 IS
            SELECT set_id
            FROM   settling
            WHERE      p_set_conid = set_conid
                   AND p_sep_id = set_sepid
                   AND p_set_demo = set_demo
                   AND p_set_etid = set_etid
                   AND set_esid = 'A';

        CURSOR c4 (
            longid1                                 IN NUMBER,
            longid2                                 IN NUMBER)
        IS --036SO --005SO
            SELECT sed_id
            FROM   setdetail
            WHERE      sed_setid = p_set_id
                   AND sed_etid = p_sed_etid
                   AND sed_tarid = p_sed_tarid
                   AND sed_charge = p_sed_charge
                   AND sed_date = TRUNC (TO_DATE (p_date, 'yyyy-mm-dd hh24:mi:ss'))
                   AND (   sed_int = p_sed_int
                        OR (    p_sed_int IS NULL
                            AND sed_int IS NULL))
                   AND NVL (sed_prepaid, 'U') = NVL (p_sed_prepaid, 'U') --001SO
                   AND sed_esid = 'A'
                   AND NVL (sed_longid, 0) = NVL (longid1, 0) --005SO --003SO
                   AND NVL (sed_longid2, 0) = NVL (longid2, 0) --036SO
                                                              ;

        CURSOR clongid IS
            SELECT long_id
            FROM   longid
            WHERE  long_id = TO_NUMBER (p_sed_longid_1); --005SO

        CURSOR clongidrange (longid IN NUMBER)
        IS
            SELECT longm_longid1,
                   longm_longid2
            FROM   longidmap
            WHERE      longm_esid = 'M'
                   AND longm_datestart <= TO_DATE (p_date, 'yyyy-mm-dd hh24:mi:ss') --037SO
                   AND longm_longid1 <= longid
                   AND longm_longid2 >= longid
                   AND (   longm_dateend IS NULL
                        OR longm_dateend > TO_DATE (p_date, 'yyyy-mm-dd hh24:mi:ss')) --037SO
                                                                                     ; --036SO

        l_long_id                               longid.long_id%TYPE; --005SO
        l_long_id_1                             longid.long_id%TYPE; --036SO
        l_long_id_2                             longid.long_id%TYPE; --036SO
    BEGIN
        returnstatus := 0; --020SO
        l_long_id := NULL; --005SO
        l_long_id_1 := NULL; --036SO
        l_long_id_2 := NULL; --036SO

        SELECT sep_id
        INTO   p_sep_id
        FROM   setperiod
        WHERE      TO_DATE (p_date, 'YYYY-MM-DD HH24:MI:SS') >= sep_date1
               AND TO_DATE (p_date, 'YYYY-MM-DD HH24:MI:SS') < sep_date2;

        returnstatus := 1; --002SO moved up here -- May be set to 0 in called procedures upon error condition

        IF p_sed_longid_1 IS NOT NULL
        THEN
            OPEN clongid;

            FETCH clongid INTO l_long_id;

            IF clongid%FOUND
            THEN
                IF p_sed_longid_2 IS NOT NULL
                THEN
                    l_long_id_1 := l_long_id; --036SO
                    l_long_id_2 := TO_NUMBER (p_sed_longid_2); --036SO
                ELSIF p_sed_longid_1 LIKE cstrofficiallongid
                THEN
                    l_long_id_1 := l_long_id; --036SO
                ELSE
                    OPEN clongidrange (l_long_id);

                    FETCH clongidrange
                        INTO l_long_id_1,
                             l_long_id_2;

                    CLOSE clongidrange;
                END IF;
            END IF;

            CLOSE clongid;
        END IF;

        OPEN c3;

        FETCH c3 INTO p_set_id;

        IF c3%NOTFOUND
        THEN
            SELECT pkg_common.generateuniquekey ('G') INTO p_set_id FROM DUAL;

            sp_insert_settling (
                p_set_etid,
                p_set_conid,
                p_set_demo,
                p_sep_id,
                NULL,
                p_set_currency,
                p_set_comment,
                p_set_id,
                errorcode,
                errormsg,
                returnstatus);

            IF returnstatus = 1
            THEN
                sp_insert_setdetail (
                    p_set_id,
                    p_sed_etid,
                    p_sed_price,
                    p_sed_quantity,
                    p_sed_discount,
                    p_sed_vatid,
                    p_sed_vatrate,
                    p_sed_desc,
                    p_sed_order,
                    p_sed_visible,
                    p_sed_comment,
                    p_sed_count1,
                    p_sed_count2,
                    p_sed_charge,
                    p_sed_bohid,
                    p_sed_pmvid,
                    p_sed_tarid,
                    p_sed_esid,
                    p_sed_int,
                    p_date,
                    NVL (p_sed_prepaid, 'U'),
                    p_sed_amountcu,
                    p_sed_retsharepv,
                    p_sed_retsharemo, --001SO
                    TO_CHAR (l_long_id_1),
                    TO_CHAR (l_long_id_2), --036SO --005SO --003SO
                    p_sed_id,
                    p_sed_pos,
                    errorcode,
                    errormsg,
                    returnstatus);
            END IF;
        ELSE
            OPEN c4 (l_long_id_1, l_long_id_2); --036SO --005SO

            FETCH c4 INTO p_sed_id;

            IF c4%NOTFOUND
            THEN
                sp_insert_setdetail (
                    p_set_id,
                    p_sed_etid,
                    p_sed_price,
                    p_sed_quantity,
                    p_sed_discount,
                    p_sed_vatid,
                    p_sed_vatrate,
                    p_sed_desc,
                    p_sed_order,
                    p_sed_visible,
                    p_sed_comment,
                    p_sed_count1,
                    p_sed_count2,
                    p_sed_charge,
                    p_sed_bohid,
                    p_sed_pmvid,
                    p_sed_tarid,
                    p_sed_esid,
                    p_sed_int,
                    p_date,
                    NVL (p_sed_prepaid, 'U'),
                    p_sed_amountcu,
                    p_sed_retsharepv,
                    p_sed_retsharemo, --001SO
                    TO_CHAR (l_long_id_1),
                    TO_CHAR (l_long_id_2), --036SO --005SO --003SO
                    p_sed_id,
                    p_sed_pos,
                    errorcode,
                    errormsg,
                    returnstatus);
            ELSE
                IF p_sed_desc = 'accumulating'
                THEN
                    sp_update_setdetail (
                        p_sed_id,
                        p_sed_price,
                        p_sed_quantity,
                        p_sed_discount,
                        p_sed_count1,
                        p_sed_count2,
                        p_sed_amountcu,
                        p_sed_retsharepv,
                        p_sed_retsharemo, --001SO
                        errorcode,
                        p_sed_pos,
                        errormsg,
                        returnstatus);
                ELSE
                    sp_insert_setdetail (
                        p_set_id,
                        p_sed_etid,
                        p_sed_price,
                        p_sed_quantity,
                        p_sed_discount,
                        p_sed_vatid,
                        p_sed_vatrate,
                        p_sed_desc,
                        p_sed_order,
                        p_sed_visible,
                        p_sed_comment,
                        p_sed_count1,
                        p_sed_count2,
                        p_sed_charge,
                        p_sed_bohid,
                        p_sed_pmvid,
                        p_sed_tarid,
                        p_sed_esid,
                        p_sed_int,
                        p_date,
                        NVL (p_sed_prepaid, 'U'),
                        p_sed_amountcu,
                        p_sed_retsharepv,
                        p_sed_retsharemo, --001SO
                        TO_CHAR (l_long_id_1),
                        TO_CHAR (l_long_id_2), --036SO --005SO --003SO
                        p_sed_id,
                        p_sed_pos,
                        errorcode,
                        errormsg,
                        returnstatus);
                END IF;
            END IF;

            CLOSE c4;
        END IF;

        CLOSE c3;

        RETURN;
    --    --          --020SO
    --    Exception
    --    When Others then
    --       ErrorCode := SQLCODE;
    --       ErrorMsg  := SQLERRM;
    --       ReturnStatus := 0;
    END sp_add_setdetail_by_date;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lam_mcc (
        p_pac_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- SLA or MLA
        p_gart                                  IN     NUMBER, --016SO
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --015SO
        CURSOR c1 IS
            SELECT sep_date2 - 1                         AS posdatetime,
                   c1.con_pscall                         AS posmsisdn,
                   c1.con_id                             AS posconid,
                   c1.con_consol                         AS posconsolidation,
                   c1.con_tarid                          AS postarid,
                   NVL (c1.con_pricehg, tar_pricehg)     AS posprice, -- MO price (used for MCC correction, in case of HG)
                   'MCC'                                 AS possetdetailtype,
                   NVL (c1.con_hdgroup, 0)               AS poshdgroup,
                   '0'                                   AS posinternational,
                   c1.con_mcapplied                      AS posmincharge,
                   sed_count1                            AS poscountmt,
                   sed_count2                            AS poscountmo,
                   sed_total                             AS posamount
            FROM   contract  c1,
                   tariff,
                   la_settling_accumulated
            WHERE      tar_id = c1.con_tarid
                   AND c1.con_etid = DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid')
                   AND set_etid = p_set_etid
                   AND c1.con_esid IN ('A',
                                       'I')
                   AND (   (c1.con_datestart < TRUNC (SYSDATE, 'MONTH'))
                        OR (c1.con_datestart IS NULL))
                   AND (   (c1.con_dateend > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                        OR (c1.con_dateend IS NULL))
                   AND c1.con_tarid NOT IN ('P',
                                            'Q',
                                            'R',
                                            'S',
                                            'T') --030SO -- info service Tariffs
                   AND sed_charge = c1.con_pscall
                   AND con_mcapplied IS NOT NULL
            UNION ALL
            SELECT TRUNC (SYSDATE, 'MONTH') - 1          AS posdatetime,
                   c1.con_pscall                         AS posmsisdn,
                   c1.con_id                             AS posconid,
                   c1.con_consol                         AS posconsolidation,
                   c1.con_tarid                          AS postarid,
                   NVL (c1.con_pricehg, tar_pricehg)     AS posprice,
                   'MCC'                                 AS possetdetailtype,
                   NVL (c1.con_hdgroup, 0)               AS poshdgroup,
                   '0'                                   AS posinternational,
                   c1.con_mcapplied                      AS posmincharge,
                   0                                     AS poscountmt,
                   0                                     AS poscountmo,
                   0.0                                   AS posamount
            FROM   contract  c1,
                   tariff
            WHERE      tar_id = c1.con_tarid
                   AND c1.con_esid IN ('A',
                                       'I')
                   AND (   (c1.con_datestart < TRUNC (SYSDATE, 'MONTH'))
                        OR (c1.con_datestart IS NULL))
                   AND (   (c1.con_dateend > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                        OR (c1.con_dateend IS NULL))
                   AND c1.con_tarid NOT IN ('P',
                                            'Q',
                                            'R',
                                            'S',
                                            'T') --030SO -- info service Tariffs
                   AND con_mcapplied IS NOT NULL
                   AND c1.con_etid = DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid')
                   AND NOT EXISTS
                           (SELECT *
                            FROM   la_settling_accumulated
                            WHERE      sed_charge = c1.con_pscall
                                   AND set_etid = p_set_etid); --038SO

        l_billtext                              VARCHAR2 (100);
        l_timeoffset                            NUMBER;
        l_minchargelimit                        FLOAT;
        l_mcc                                   FLOAT;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lam_mcc'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
            sbsdb_logger_lib.log_param ('p_gart', p_gart));

        errorcode := 0; --023SO
        recordsaffected := 0;
        returnstatus := pkg_common.return_status_ok; -- assume this for now

        FOR c1_rec IN c1
        LOOP
            l_minchargelimit := c1_rec.posmincharge;

            IF c1_rec.poshdgroup = 1
            THEN
                l_minchargelimit := l_minchargelimit - c1_rec.poscountmo * c1_rec.posprice;
            END IF;

            l_mcc := l_minchargelimit - c1_rec.posamount;

            IF l_mcc > 0.0
            THEN
                returnstatus := 0;

                l_timeoffset := nextavailabletimestamp (c1_rec.posmsisdn, c1_rec.posdatetime);

                l_billtext := billtextmincharge (c1_rec.posconsolidation, c1_rec.postarid, c1_rec.posdatetime);

                pkg_bdetail_settlement.sp_add_setdetail (
                    p_set_etid, -- p_SET_ETID       IN varchar2,
                    c1_rec.possetdetailtype, -- p_SED_ETID       IN varchar2,
                    c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                    p_boh_id, -- p_SED_BOHID      IN varchar2,
                    c1_rec.posdatetime + l_timeoffset / 24 / 3600, -- p_Date           IN DATE,
                    c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                    c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                    c1_rec.posinternational, -- p_SED_INT        IN varchar2,
                    'U', --C1_Rec.PosPrepaid,                        -- p_SED_PREPAID    IN varchar2,
                    l_mcc, -- p_SED_PRICE      IN float,
                    0.0, --C1_Rec.AmountCu,                          -- p_SED_AMOUNTCU   IN float,
                    0.0, --C1_Rec.RevenueShareLa,                    -- p_SED_RETSHAREPV IN float,
                    0.0, --C1_Rec.RevenueShareOp,                    -- p_SED_RETSHAREMO IN float,
                    NULL, --C1_Rec.PosLongId,                         -- p_SED_LONGID     IN varchar2,
                    0, --C1_Rec.CdrCountMT,                        -- p_SED_COUNT1     IN number,
                    0, --C1_Rec.CdrCountMO,                        -- p_SED_COUNT2     IN number,
                    l_billtext, -- p_SED_DESC       IN varchar2,
                    p_gart, --C1_Rec.PosGart,                           -- p_GART           IN varchar2,    --016SO
                    errorcode, -- ErrorCode        OUT number,
                    errormsg, -- ErrorMsg         OUT varchar2,
                    returnstatus -- ReturnStatus     IN OUT number
                                );

                IF returnstatus = 1
                THEN
                    recordsaffected := recordsaffected + 1;
                ELSE
                    sbsdb_error_lib.LOG (
                        errorcode,
                           sbsdb_logger_lib.json_other_first ('errcode', errorcode)
                        || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                        || sbsdb_logger_lib.json_other_add ('topic', 'PROCESSING ERROR')
                        || sbsdb_logger_lib.json_other_add ('bih_id')
                        || sbsdb_logger_lib.json_other_add ('boh_id', p_boh_id)
                        || sbsdb_logger_lib.json_other_add ('bd_id')
                        || sbsdb_logger_lib.json_other_last ('short_id'),
                        sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lam_mcc'),
                        sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                        sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                        sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                        sbsdb_logger_lib.log_param ('p_gart', p_gart));

                    EXIT; -- C1_Rec
                END IF;
            END IF; -- l_MCC > 0.0
        END LOOP; -- C1_Rec

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lam_mcc'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'EXCEPTION'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lam_mcc'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                sbsdb_logger_lib.log_param ('p_gart', p_gart));
            RAISE;
    END sp_lam_mcc;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lapmcc (
        p_pac_id                                IN     VARCHAR2, -- 'LAPMCC_SMS' or 'LAPMCC_MMS'    MCC Preparation (Minimum Charge Calculation) -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_set_etid                              IN     VARCHAR2, -- SLA or MLA
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                               OUT NUMBER)
    IS --014SO
       -- get a list of SMS or MMS LA contracts which can have a minimum charge
       -- per pseudo call number, the contracts with the top overall min charge are choosen
       -- more than one contract can be returned, if they have equal weighted minimum charge
       -- this is taken care of in the processing of the result
        CURSOR cminchargeablecontracts IS
            SELECT   c1.con_pscall     AS x_pscall,
                     c1.con_id         AS x_conid
            FROM     contract c1
            WHERE        c1.con_etid = DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid')
                     AND c1.con_esid IN ('A',
                                         'I')
                     AND (   (c1.con_datestart < TRUNC (SYSDATE, 'MONTH'))
                          OR (c1.con_datestart IS NULL))
                     AND (   (c1.con_dateend > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                          OR (c1.con_dateend IS NULL))
                     AND c1.con_tarid NOT IN ('P',
                                              'Q',
                                              'R',
                                              'S',
                                              'T',
                                              'U',
                                              'V',
                                              'W',
                                              'X',
                                              'Y',
                                              'Z') --038SO
                     AND NOT EXISTS
                             (SELECT c2.con_id
                              FROM   contract c2
                              WHERE      c2.con_etid = DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid')
                                     AND c2.con_esid IN ('A',
                                                         'I')
                                     AND (   (c2.con_datestart < TRUNC (SYSDATE, 'MONTH'))
                                          OR (c2.con_datestart IS NULL))
                                     AND (   (c2.con_dateend > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                                          OR (c2.con_dateend IS NULL))
                                     AND c2.con_tarid NOT IN ('P',
                                                              'Q',
                                                              'R',
                                                              'S',
                                                              'T',
                                                              'U',
                                                              'V',
                                                              'W',
                                                              'X',
                                                              'Y',
                                                              'Z') --038SO
                                     AND c2.con_mceff > c1.con_mceff
                                     AND c2.con_pscall = c1.con_pscall)
            ORDER BY c1.con_pscall ASC,
                     c1.con_id ASC;

        cminchargeablecontractsrow              cminchargeablecontracts%ROWTYPE;

        -- get minimum charge per day as the maximum of any of the running contracts of that day for the pseudo call number
        CURSOR cminchargebyday (pscall IN VARCHAR2)
        IS
            SELECT   MAX (NVL (con_mincharge, tar_mincharge) / (TRUNC (SYSDATE, 'MONTH') - TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')))     AS x_mincharge_day
            FROM     contract,
                     tariff,
                     enumerator
            WHERE        pkg_bdetail_common.contractperiodstart (con_datestart) <= TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH') + enum_id - 1
                     AND pkg_bdetail_common.contractperiodend (con_dateend) > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH') + enum_id - 1
                     AND con_tarid = tar_id
                     AND con_etid IN DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid')
                     AND con_esid IN ('A',
                                      'I')
                     AND (   (con_datestart < TRUNC (SYSDATE, 'MONTH'))
                          OR (con_datestart IS NULL))
                     AND (   (con_dateend > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                          OR (con_dateend IS NULL))
                     AND con_tarid NOT IN ('P',
                                           'Q',
                                           'R',
                                           'S',
                                           'T',
                                           'U',
                                           'V',
                                           'W',
                                           'X',
                                           'Y',
                                           'Z') --038SO
                     AND enum_id >= 1
                     AND enum_id <= TRUNC (SYSDATE, 'MONTH') - TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH')
                     AND con_pscall = pscall
            GROUP BY enum_id;

        cminchargebydayrow                      cminchargebyday%ROWTYPE;

        x_pscall_last                           VARCHAR2 (20);
        x_conid_last                            VARCHAR2 (10);
        x_mincharge_tot                         NUMBER;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lapmcc'),
            sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
            sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
            sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid));

        UPDATE contract c1
        SET    c1.con_mcapplied = NULL,
               c1.con_mceff = NULL
        WHERE  c1.con_etid = DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid');

        UPDATE contract c1
        SET    c1.con_mcapplied = NULL,
               c1.con_mceff =
                   (SELECT   NVL (c2.con_mincharge, tar_mincharge)
                           * pkg_bdetail_settlement.settledduration (c2.con_datestart, c2.con_dateend)
                           / (TRUNC (SYSDATE, 'MONTH') - TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                    FROM   contract  c2,
                           tariff
                    WHERE      c2.con_tarid = tar_id
                           AND c2.con_id = c1.con_id)
        WHERE      c1.con_etid = DECODE (p_set_etid,  'SLA', 'LAC',  'MLA', 'MLC',  'invalid')
               AND c1.con_esid IN ('A',
                                   'I')
               AND (   (c1.con_datestart < TRUNC (SYSDATE, 'MONTH'))
                    OR (c1.con_datestart IS NULL))
               AND (   (c1.con_dateend > TRUNC (ADD_MONTHS (SYSDATE, -1), 'MONTH'))
                    OR (c1.con_dateend IS NULL))
               AND c1.con_tarid NOT IN ('P',
                                        'Q',
                                        'R',
                                        'S',
                                        'T',
                                        'U',
                                        'V',
                                        'W',
                                        'X',
                                        'Y',
                                        'Z') --038SO
                                            ;

        x_pscall_last := 'rubbish';
        x_conid_last := NULL;

       <<loop_outer>>
        FOR cminchargeablecontractsrow IN cminchargeablecontracts
        LOOP
            IF cminchargeablecontractsrow.x_pscall <> x_pscall_last
            THEN
                -- only first occurence  of a pseudo numbers needs to be processed
                -- (eliminate duplicates returned by cursor)

                x_mincharge_tot := 0.0;

               <<loop_cminchargebydayrow>>
                FOR cminchargebydayrow IN cminchargebyday (cminchargeablecontractsrow.x_pscall)
                LOOP
                    -- add minimum charges for the days with running contract(s)
                    x_mincharge_tot := x_mincharge_tot + cminchargebydayrow.x_mincharge_day;
                END LOOP cminchargebydayrow;

                -- update the effectively chargeable minimum charge on the contract selected
                -- this value is compared in the VB part of the OC to the already charged amounts
                -- for this pseudo call number
                UPDATE contract
                SET    con_mcapplied = x_mincharge_tot
                WHERE  con_id = cminchargeablecontractsrow.x_conid;

                x_pscall_last := cminchargeablecontractsrow.x_pscall;
            END IF;
        END LOOP loop_outer;

        recordsaffected := SQL%ROWCOUNT;
        errorcode := 0;
        returnstatus := 1;

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lapmcc'),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'EXCEPTION'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lapmcc'),
                sbsdb_logger_lib.log_param ('p_pac_id', p_pac_id),
                sbsdb_logger_lib.log_param ('p_boh_id', p_boh_id),
                sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid));
            RAISE;
    END sp_lapmcc;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lat_cdr (
        p_bd_bohid                              IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- 'SLA'  or 'MLA'
        p_gart                                  IN     NUMBER,
        p_minage                                IN     NUMBER,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS --007SO
        CURSOR c1 IS
            SELECT   TRUNC (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS'))     AS posdatetime,
                     sed_charge                                               AS posmsisdn,
                     set_conid                                                AS posconid,
                     con_consol                                               AS posconsolidation,
                     sed_tarid                                                AS postarid,
                     NVL (sed_int, '0')                                       AS posinternational,
                     SUBSTR (sed_etid, 1, LENGTH (sed_etid) - 1)              AS possetdetailtype,
                     NVL (sed_prepaid, 'U')                                   AS posprepaid,
                     p_gart                                                   AS posgart,
                     COUNT (*)                                                AS cdrcount,
                     SUM (sed_count1)                                         AS cdrcountmt,
                     SUM (sed_count2)                                         AS cdrcountmo, -- (including HR)
                     ROUND (SUM (sed_total), 2)                               AS amounttotal, --027SO
                     SUM (NVL (sed_amountcu, 0.0))                            AS amountcu,
                     SUM (NVL (sed_retsharepv, 0.0))                          AS revenuesharela,
                     SUM (NVL (sed_retsharemo, 0.0))                          AS revenueshareop
            FROM     setdetail,
                     settling,
                     contract
            WHERE        setdetail.sed_setid = settling.set_id
                     AND sed_order > TO_CHAR (SYSDATE - p_maxage, 'YYYY-MM-DD')
                     AND sed_order < TO_CHAR (SYSDATE - p_minage, 'YYYY-MM-DD')
                     AND contract.con_id = settling.set_conid
                     AND sed_gohid = p_bd_bohid
            GROUP BY TRUNC (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS')), -- PosDATETIME,
                     sed_charge, -- PosMSISDN,
                     set_conid, -- PosConId,
                     con_consol, -- PosCONSOLIDATION,
                     sed_tarid, -- PosTarId,
                     NVL (sed_int, '0'), -- PosInternational,
                     SUBSTR (sed_etid, 1, LENGTH (sed_etid) - 1), -- PosSetDetailType,
                     NVL (sed_prepaid, 'U'), -- PosPrepaid,
                     p_gart -- PosGart,
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC,
                     posinternational ASC,
                     possetdetailtype ASC,
                     posprepaid ASC,
                     posgart ASC;

        l_returnstatus                          PLS_INTEGER;

        l_timeoffset                            NUMBER;
        l_amount                                NUMBER;
        l_billtext                              VARCHAR2 (100);
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lat_cdr'),
            sbsdb_logger_lib.log_param ('p_bd_bohid', p_bd_bohid),
            sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
            sbsdb_logger_lib.log_param ('p_gart', p_gart),
            sbsdb_logger_lib.log_param ('p_minage', p_minage),
            sbsdb_logger_lib.log_param ('p_maxage', p_maxage));

        recordsaffected := 0;

        FOR c1_rec IN c1
        LOOP
            l_returnstatus := 0;

            IF c1_rec.possetdetailtype <> 'MOFN'
            THEN
                -- Aggregate and write MT part of billing
                -- MT only here
                l_timeoffset := nextavailabletimestamp (c1_rec.posmsisdn, c1_rec.posdatetime); --021SO
                l_billtext :=
                    billtextla (
                        c1_rec.posconsolidation,
                        c1_rec.postarid,
                        c1_rec.posinternational,
                        c1_rec.possetdetailtype,
                        c1_rec.posprepaid,
                        c1_rec.cdrcountmt,
                        0);
                pkg_bdetail_settlement.sp_add_setdetail (
                    p_set_etid, -- p_SET_ETID       IN varchar2,
                    c1_rec.possetdetailtype, -- p_SED_ETID       IN varchar2,
                    c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                    p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                    c1_rec.posdatetime + l_timeoffset / 24 / 3600, -- p_Date           IN DATE,
                    c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                    c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                    c1_rec.posinternational, -- p_SED_INT        IN varchar2,
                    c1_rec.posprepaid, -- p_SED_PREPAID    IN varchar2,
                    c1_rec.amounttotal, -- p_SED_PRICE      IN float,
                    c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                    c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                    c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                    NULL, --C1_Rec.PosLongId,                         -- p_SED_LONGID     IN varchar2,
                    c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                    0, --C1_Rec.CdrCountMO,                        -- p_SED_COUNT2     IN number,
                    l_billtext, -- p_SED_DESC       IN varchar2,
                    c1_rec.posgart, -- p_GART           IN varchar2,
                    errorcode, -- ErrorCode        OUT number,
                    errormsg, -- ErrorMsg         OUT varchar2,
                    l_returnstatus -- ReturnStatus     IN OUT number
                                  ); --038SO
            END IF;

            IF c1_rec.cdrcountmo > 0
            THEN --038SO
                -- Aggregate and write MO part of billing
                IF c1_rec.possetdetailtype <> 'MOFN'
                THEN
                    l_amount := 0.0; -- MO are normally not charged to LA ...
                ELSE
                    l_amount := c1_rec.amounttotal; -- ... except for IW
                END IF;

                l_timeoffset := nextavailabletimestamp (c1_rec.posmsisdn, c1_rec.posdatetime); --021SO
                l_billtext :=
                    billtextla (
                        c1_rec.posconsolidation,
                        c1_rec.postarid,
                        c1_rec.posinternational,
                        c1_rec.possetdetailtype,
                        c1_rec.posprepaid,
                        0,
                        c1_rec.cdrcountmo);
                pkg_bdetail_settlement.sp_add_setdetail (
                    p_set_etid, -- p_SET_ETID       IN varchar2,
                    c1_rec.possetdetailtype, -- p_SED_ETID       IN varchar2,
                    c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                    p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                    c1_rec.posdatetime + l_timeoffset / 24 / 3600, -- p_Date           IN DATE,
                    c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                    c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                    c1_rec.posinternational, -- p_SED_INT        IN varchar2,
                    c1_rec.posprepaid, -- p_SED_PREPAID    IN varchar2,
                    l_amount, -- p_SED_PRICE      IN float,       --022SO
                    c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                    c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                    c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                    NULL, --C1_Rec.PosLongId,                         -- p_SED_LONGID     IN varchar2,
                    0, --C1_Rec.CdrCountMT,                        -- p_SED_COUNT1     IN number,
                    c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                    l_billtext, -- p_SED_DESC       IN varchar2,
                    c1_rec.posgart, -- p_GART           IN varchar2,
                    errorcode, -- ErrorCode        OUT number,
                    errormsg, -- ErrorMsg         OUT varchar2,
                    l_returnstatus -- ReturnStatus     IN OUT number
                                  );
            END IF;

            IF l_returnstatus = 1
            THEN
                recordsaffected := recordsaffected + c1_rec.cdrcount;
            ELSE
                sbsdb_error_lib.LOG (
                    errorcode,
                       sbsdb_logger_lib.json_other_first ('errcode', errorcode)
                    || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                    || sbsdb_logger_lib.json_other_add ('topic', 'PROCESSING ERROR')
                    || sbsdb_logger_lib.json_other_add ('bih_id')
                    || sbsdb_logger_lib.json_other_add ('boh_id', p_bd_bohid)
                    || sbsdb_logger_lib.json_other_add ('bd_id')
                    || sbsdb_logger_lib.json_other_last ('short_id'),
                    sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lat_cdr'),
                    sbsdb_logger_lib.log_param ('p_bd_bohid', p_bd_bohid),
                    sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                    sbsdb_logger_lib.log_param ('p_gart', p_gart),
                    sbsdb_logger_lib.log_param ('p_minage', p_minage),
                    sbsdb_logger_lib.log_param ('p_maxage', p_maxage));
                EXIT; -- C1_Rec
            END IF;
        END LOOP; -- C1_Rec

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lat_cdr'),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected));
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'EXCEPTION'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lat_cdr'),
                sbsdb_logger_lib.log_param ('p_bd_bohid', p_bd_bohid),
                sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                sbsdb_logger_lib.log_param ('p_gart', p_gart),
                sbsdb_logger_lib.log_param ('p_minage', p_minage),
                sbsdb_logger_lib.log_param ('p_maxage', p_maxage));
            RAISE;
    END sp_lat_cdr;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_lit_cdr (
        p_bd_bohid                              IN     VARCHAR2,
        p_set_etid                              IN     VARCHAR2, -- 'SLA'  or 'MLA'
        p_gart                                  IN     NUMBER,
        p_minage                                IN     NUMBER,
        p_maxage                                IN     NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        recordsaffected                            OUT NUMBER)
    IS --018SO
        CURSOR c1 IS
            SELECT   TRUNC (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS'))     AS posdatetime,
                     sed_charge                                               AS posmsisdn,
                     set_conid                                                AS posconid,
                     con_consol                                               AS posconsolidation,
                     sed_tarid                                                AS postarid,
                     NVL (sed_int, '0')                                       AS posinternational,
                     SUBSTR (sed_etid, 1, LENGTH (sed_etid) - 1) || 'T'       AS possetdetailtype, --024SO IOTLACT / MOIWST
                     NVL (sed_prepaid, 'U')                                   AS posprepaid,
                     p_gart                                                   AS posgart,
                     COUNT (*)                                                AS cdrcount,
                     SUM (sed_count1)                                         AS cdrcountmt,
                     SUM (sed_count2)                                         AS cdrcountmo,
                     ROUND (SUM (sed_total), 2)                               AS amounttotal, --027SO
                     SUM (NVL (sed_amountcu, 0.0))                            AS amountcu,
                     SUM (NVL (sed_retsharepv, 0.0))                          AS revenuesharela,
                     SUM (NVL (sed_retsharemo, 0.0))                          AS revenueshareop
            FROM     setdetail,
                     settling,
                     contract
            WHERE        setdetail.sed_setid = settling.set_id
                     AND sed_order > TO_CHAR (SYSDATE - p_maxage, 'YYYY-MM-DD')
                     AND sed_order < TO_CHAR (SYSDATE - p_minage, 'YYYY-MM-DD')
                     AND contract.con_id = settling.set_conid
                     AND sed_gohid = p_bd_bohid
            GROUP BY TRUNC (TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS')), -- PosDATETIME,
                     sed_charge, -- PosMSISDN,
                     set_conid, -- PosConId,
                     con_consol, -- PosCONSOLIDATION,
                     sed_tarid, -- PosTarId,
                     NVL (sed_int, '0'), -- PosInternational,
                     SUBSTR (sed_etid, 1, LENGTH (sed_etid) - 1), -- PosSetDetailType,
                     NVL (sed_prepaid, 'U'), -- PosPrepaid,
                     p_gart -- PosGart,
            ORDER BY posdatetime ASC,
                     posmsisdn ASC,
                     posconid ASC,
                     posconsolidation ASC,
                     postarid ASC,
                     posinternational ASC,
                     possetdetailtype ASC,
                     posprepaid ASC,
                     posgart ASC;

        l_returnstatus                          PLS_INTEGER;

        l_timeoffset                            NUMBER;
        l_billtext                              VARCHAR2 (100);
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lit_cdr'),
            sbsdb_logger_lib.log_param ('p_bd_bohid', p_bd_bohid),
            sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
            sbsdb_logger_lib.log_param ('p_gart', p_gart),
            sbsdb_logger_lib.log_param ('p_minage', p_minage),
            sbsdb_logger_lib.log_param ('p_maxage', p_maxage));

        recordsaffected := 0;
        errorcode := 0;

        FOR c1_rec IN c1
        LOOP
            l_returnstatus := 0;

            l_timeoffset := nextavailabletimestamp (c1_rec.posmsisdn, c1_rec.posdatetime);

            l_billtext := billtextli (c1_rec.posconsolidation, c1_rec.cdrcountmt, c1_rec.cdrcountmo);

            pkg_bdetail_settlement.sp_add_setdetail (
                p_set_etid, -- p_SET_ETID       IN varchar2,
                c1_rec.possetdetailtype, -- p_SED_ETID       IN varchar2,
                c1_rec.posmsisdn, -- p_SED_CHARGE     IN varchar2,
                p_bd_bohid, -- p_SED_BOHID      IN varchar2,
                c1_rec.posdatetime + l_timeoffset / 24 / 3600, -- p_Date           IN DATE,
                c1_rec.posconid, -- p_SET_CONID      IN varchar2,
                c1_rec.postarid, -- p_SED_TARID      IN varchar2,
                c1_rec.posinternational, -- p_SED_INT        IN varchar2,
                c1_rec.posprepaid, -- p_SED_PREPAID    IN varchar2,
                c1_rec.amounttotal, -- p_SED_PRICE      IN float,
                c1_rec.amountcu, -- p_SED_AMOUNTCU   IN float,
                c1_rec.revenuesharela, -- p_SED_RETSHAREPV IN float,
                c1_rec.revenueshareop, -- p_SED_RETSHAREMO IN float,
                NULL, --C1_Rec.PosLongId,                     -- p_SED_LONGID     IN varchar2,
                c1_rec.cdrcountmt, -- p_SED_COUNT1     IN number,
                c1_rec.cdrcountmo, -- p_SED_COUNT2     IN number,
                l_billtext, -- p_SED_DESC       IN varchar2,
                c1_rec.posgart, -- p_GART           IN varchar2,
                errorcode, -- ErrorCode        OUT number,
                errormsg, -- ErrorMsg         OUT varchar2,
                l_returnstatus -- ReturnStatus     IN OUT number
                              );

            IF l_returnstatus = 1
            THEN
                recordsaffected := recordsaffected + c1_rec.cdrcount;
            ELSE
                sbsdb_error_lib.LOG (
                    errorcode,
                       sbsdb_logger_lib.json_other_first ('errcode', errorcode)
                    || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (errormsg))
                    || sbsdb_logger_lib.json_other_add ('topic', 'PROCESSING ERROR')
                    || sbsdb_logger_lib.json_other_add ('bih_id')
                    || sbsdb_logger_lib.json_other_add ('boh_id', p_bd_bohid)
                    || sbsdb_logger_lib.json_other_add ('bd_id')
                    || sbsdb_logger_lib.json_other_last ('short_id'),
                    sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lit_cdr'),
                    sbsdb_logger_lib.log_param ('p_bd_bohid', p_bd_bohid),
                    sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                    sbsdb_logger_lib.log_param ('p_gart', p_gart),
                    sbsdb_logger_lib.log_param ('p_minage', p_minage),
                    sbsdb_logger_lib.log_param ('p_maxage', p_maxage));
                EXIT; -- C1_Rec
            END IF;
        END LOOP; -- C1_Rec

        sbsdb_logger_lib.log_info (
            'End',
            sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lit_cdr'),
            sbsdb_logger_lib.log_param ('errorcode', errorcode),
            sbsdb_logger_lib.log_param ('errormsg', errormsg),
            sbsdb_logger_lib.log_param ('recordsaffected', recordsaffected));
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'EXCEPTION'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_lit_cdr'),
                sbsdb_logger_lib.log_param ('p_bd_bohid', p_bd_bohid),
                sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                sbsdb_logger_lib.log_param ('p_gart', p_gart),
                sbsdb_logger_lib.log_param ('p_minage', p_minage),
                sbsdb_logger_lib.log_param ('p_maxage', p_maxage));
            RAISE;
    END sp_lit_cdr;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION billtextla (
        p_consolidation                         IN VARCHAR2,
        p_tarid                                 IN VARCHAR2, -- TODO unused parameter? (wwe)
        p_international                         IN VARCHAR2,
        p_sed_etid                              IN VARCHAR2,
        p_sed_prepaid                           IN VARCHAR2, -- TODO unused parameter? (wwe)
        p_sed_count1                            IN NUMBER,
        p_sed_count2                            IN NUMBER)
        RETURN VARCHAR2
    IS --008SO
       -- Return UFIH BillText (F30) for SMS and MMS LA UFIH tickets
        l_result                                VARCHAR2 (100);
        l_temp                                  VARCHAR2 (100);
        c_max_length                   CONSTANT PLS_INTEGER := 24;
    BEGIN
        l_result := 'ID' || p_consolidation;

        IF p_sed_etid = 'MFGR'
        THEN
            l_temp := '/MFGR';

            IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
            THEN
                l_result := l_result || l_temp;
            END IF;
        ELSIF p_sed_etid = 'MFLID'
        THEN
            l_temp := '/MFLID';

            IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
            THEN
                l_result := l_result || l_temp;
            END IF;
        ELSE
            IF p_sed_count1 > 0
            THEN
                l_temp := '/MT' || p_sed_count1;

                IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
                THEN
                    l_result := l_result || l_temp;
                END IF;
            END IF;

            IF p_sed_count2 > 0
            THEN
                l_temp := '/MO' || p_sed_count2;

                IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
                THEN
                    l_result := l_result || l_temp;
                END IF;
            END IF;

            IF p_international = '0'
            THEN
                l_temp := '/SCM';

                IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
                THEN
                    l_result := l_result || l_temp;
                END IF;
            END IF;

            IF p_international = '1'
            THEN
                l_temp := '/FN';

                IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
                THEN
                    l_result := l_result || l_temp;
                END IF;
            END IF;
        END IF; --038SO

        RETURN l_result;
    END billtextla;

    /* =========================================================================
        TODO.

       pfsBillTextIotLac(strLastConsolidation, lngCumulatedCdrCount, 0, True)
        ---------------------------------------------------------------------- */

    FUNCTION billtextli (
        p_consolidation                         IN VARCHAR2,
        p_sed_count1                            IN NUMBER,
        p_sed_count2                            IN NUMBER)
        RETURN VARCHAR2
    IS --018SO
       -- Return UFIH BillText (F30) for SMS and MMS LA IW UFIH tickets
        l_result                                VARCHAR2 (100);
        l_temp                                  VARCHAR2 (100);
        c_max_length                   CONSTANT PLS_INTEGER := 24;
    BEGIN
        l_result := 'ID' || p_consolidation;

        IF p_sed_count1 > 0
        THEN
            l_temp := '/IWT' || p_sed_count1;

            IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
            THEN
                l_result := l_result || l_temp;
            END IF;
        END IF;

        IF p_sed_count2 > 0
        THEN
            l_temp := '/MO' || p_sed_count2 || '/IW';

            IF LENGTH (l_result) + LENGTH (l_temp) <= c_max_length
            THEN
                l_result := l_result || l_temp;
            END IF;
        END IF;

        RETURN l_result;
    END billtextli;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION billtextmincharge (
        p_consolidation                         IN VARCHAR2,
        p_tarid                                 IN VARCHAR2,
        p_datetime                              IN DATE)
        RETURN VARCHAR2
    IS
        -- Return UFIH BillText (F30) for SMS and MMS LA UFIH MinCharge tickets

        l_result                                VARCHAR2 (100);
    BEGIN
        l_result := 'ID' || p_consolidation || '/Diff. ' || TO_CHAR (p_datetime, 'MM.YYYY') || '/' || p_tarid;

        RETURN l_result;
    END billtextmincharge;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION nextavailabletimestamp (
        p_sed_charge                            IN VARCHAR2,
        p_sed_date                              IN DATE)
        RETURN NUMBER -- seconds after midnight
    IS --009SO
       -- Return largest possible second offset unused for given
       -- pseudo chargeable number in SEDDETAIL charges
       -- same as nextAvailableOrder but numeric offset outut
        c_lastsecondofday              CONSTANT PLS_INTEGER := 86399;
        l_last                                  VARCHAR2 (20);
    BEGIN
        SELECT MIN (sed_order)
        INTO   l_last
        FROM   setdetail
        WHERE      sed_charge = p_sed_charge --010SO
               AND sed_order >= TO_CHAR (p_sed_date, 'YYYY-MM-DD ') || '12:00:00'
               AND sed_order <= TO_CHAR (p_sed_date, 'YYYY-MM-DD ') || '23:59:59';

        IF l_last IS NULL
        THEN
            RETURN c_lastsecondofday;
        ELSE
            RETURN TO_NUMBER (SUBSTR (l_last, 18, 2)) + 60 * TO_NUMBER (SUBSTR (l_last, 15, 2)) + 3600 * TO_NUMBER (SUBSTR (l_last, 12, 2)) - 1;
        END IF;
    END nextavailabletimestamp;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION ufihrendered (
        p_sed_date                              IN VARCHAR2,
        p_sed_charge                            IN VARCHAR2,
        p_sed_price                             IN FLOAT,
        p_sed_desc                              IN VARCHAR2,
        p_gart                                  IN NUMBER,
        p_sed_tarid                             IN VARCHAR2) -- TODO unused parameter? (wwe)
        RETURN VARCHAR2
    IS --013SO -- Return UFIH string for CDR
        l_result                                VARCHAR2 (400);

        l_billtextprefix                        VARCHAR2 (80);

        c_startstring                  CONSTANT VARCHAR2 (1) := '{';
        c_endstring                    CONSTANT VARCHAR2 (1) := '}';
        c_charstart                    CONSTANT VARCHAR2 (1) := '''';
        c_charend                      CONSTANT VARCHAR2 (1) := '''';
        c_datetimestart                CONSTANT VARCHAR2 (1) := '@';
        c_datetimeend                  CONSTANT VARCHAR2 (1) := NULL;

        l_fixedprefix                           VARCHAR2 (100);
        l_datestring                            VARCHAR2 (20);
        l_taxamountstr                          VARCHAR2 (20);
    BEGIN
        l_datestring := REPLACE (p_sed_date, ':', '');
        l_datestring := REPLACE (l_datestring, '-', '');
        l_datestring := REPLACE (l_datestring, ' ', '');

        l_taxamountstr := TRIM (TO_CHAR (p_sed_price, '999990.00')); --038SO --026SO

        l_billtextprefix := '0' || SUBSTR (p_sed_charge, 3) || '                       ';
        l_billtextprefix := SUBSTR (l_billtextprefix, 1, 24) || '+00000';

        l_fixedprefix := 'F3=1,F7=21,F29=3,F32=''00001000''';

        l_result := c_startstring || l_fixedprefix;
        l_result := l_result || ',F17=' || c_datetimestart || l_datestring || c_datetimeend;
        l_result := l_result || ',F10=' || p_sed_charge;
        l_result := l_result || ',F5=' || TRIM (l_taxamountstr);
        l_result := l_result || ',F23=' || TRIM (p_gart);
        l_result := l_result || ',F30=' || c_charstart || l_billtextprefix || p_sed_desc || c_charend;
        l_result := l_result || c_endstring;

        RETURN l_result;
    END ufihrendered;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE insertperiod (p_code IN VARCHAR2)
    IS --019SO
    BEGIN
        INSERT INTO setperiod (
                        sep_id,
                        sep_date1,
                        sep_date2,
                        sep_lang01,
                        sep_lang02,
                        sep_lang03,
                        sep_lang04)
            (SELECT p_code,
                    TO_DATE (p_code, 'YYYYMM')                                                                                                               AS sep_date1,
                    TO_DATE (TO_CHAR (ADD_MONTHS (TO_DATE (p_code, 'yyyymm'), 1), 'yyyymm'), 'YYYYMM')                                                       AS sep_date2,
                    TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'Month', 'NLS_DATE_LANGUAGE = American') || ' ' || TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'YYYY')     AS sep_lang01,
                    TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'Month', 'NLS_DATE_LANGUAGE = German') || ' ' || TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'YYYY')       AS sep_lang02,
                    TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'Month', 'NLS_DATE_LANGUAGE = French') || ' ' || TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'YYYY')       AS sep_lang03,
                    TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'Month', 'NLS_DATE_LANGUAGE = Italian') || ' ' || TO_CHAR (TO_DATE (p_code, 'YYYYMM'), 'YYYY')      AS sep_lang04
             FROM   DUAL
             WHERE  NOT EXISTS
                        (SELECT sep_id
                         FROM   setperiod
                         WHERE  sep_id = p_code));
    END insertperiod;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_insert_period (
        p_pac_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER, -- TODO unused parameter? (wwe)
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                               OUT NUMBER)
    IS --019SO
    BEGIN
        insertperiod (TO_CHAR (ADD_MONTHS (SYSDATE, 1), 'YYYYMM'));

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    END sp_cons_insert_period;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_setdetail (
        p_sed_setid                             IN     VARCHAR2,
        p_sed_etid                              IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_quantity                          IN     FLOAT,
        p_sed_discount                          IN     FLOAT,
        p_sed_vatid                             IN     VARCHAR2,
        p_sed_vatrate                           IN     FLOAT,
        p_sed_desc                              IN     VARCHAR2,
        p_sed_order                             IN     VARCHAR2,
        p_sed_visible                           IN     NUMBER,
        p_sed_comment                           IN     VARCHAR2,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_charge                            IN     VARCHAR2,
        p_sed_bohid                             IN     VARCHAR2,
        p_sed_pmvid                             IN     VARCHAR2,
        p_sed_tarid                             IN     VARCHAR2,
        p_sed_esid                              IN     VARCHAR2,
        p_sed_int                               IN     VARCHAR2,
        p_sed_date                              IN     VARCHAR2,
        p_sed_prepaid                           IN     VARCHAR2, --001SO
        p_sed_amountcu                          IN     FLOAT, --001SO
        p_sed_retsharepv                        IN     FLOAT, --001SO
        p_sed_retsharemo                        IN     FLOAT, --001SO
        p_sed_longid_1                          IN     VARCHAR2, --036SO --003SO
        p_sed_longid_2                          IN     VARCHAR2, --036SO
        p_sed_id                                   OUT VARCHAR2,
        p_sed_pos                                  OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        v_sed_order                             VARCHAR2 (19);
        v_timestamp                             DATE;

        CURSOR c1 IS
            SELECT   TO_DATE (sed_order, 'YYYY-MM-DD HH24:MI:SS')     AS a_timestamp
            FROM     setdetail
            WHERE        sed_charge = p_sed_charge
                     AND sed_order >= SUBSTR (p_sed_order, 1, 10)
                     AND sed_order < SUBSTR (p_sed_order, 1, 10) || ' 12:00:00'
            ORDER BY sed_order DESC;
    BEGIN
        SELECT pkg_common.generateuniquekey ('G') INTO p_sed_id FROM DUAL;

        SELECT NVL (MAX (sed_pos), 0) + 1
        INTO   p_sed_pos
        FROM   setdetail
        WHERE  sed_setid = p_sed_setid;

        IF SUBSTR (p_sed_order, 12, 8) = '00:00:00'
        THEN
            OPEN c1;

            FETCH c1 INTO v_timestamp;

            IF c1%NOTFOUND
            THEN
                v_sed_order := p_sed_order;
            ELSE
                v_sed_order := TO_CHAR (v_timestamp + 1.0 / 86399, 'YYYY-MM-DD HH24:MI:SS');
            END IF;
        ELSE
            v_sed_order := p_sed_order;
        END IF;

        INSERT INTO setdetail (
                        sed_id,
                        sed_setid,
                        sed_pos,
                        sed_etid,
                        sed_visible,
                        sed_desc,
                        sed_order,
                        sed_price,
                        sed_quantity,
                        sed_discount,
                        sed_net,
                        sed_vatid,
                        sed_vatrate,
                        sed_vat,
                        sed_total,
                        sed_comment,
                        sed_count1,
                        sed_count2,
                        sed_charge,
                        sed_bohid,
                        sed_pmvid,
                        sed_tarid,
                        sed_datetime,
                        sed_datecre,
                        sed_esid,
                        sed_int,
                        sed_prepaid, --001SO
                        sed_amountcu, --001SO
                        sed_retsharepv, --001SO
                        sed_retsharemo, --001SO
                        sed_date,
                        sed_longid, --003SO
                        sed_longid2 --036SO
                                   )
        VALUES      (
            p_sed_id,
            p_sed_setid,
            p_sed_pos,
            p_sed_etid,
            p_sed_visible,
            p_sed_desc,
            v_sed_order,
            p_sed_price,
            p_sed_quantity,
            p_sed_discount,
            p_sed_price * p_sed_quantity - p_sed_discount,
            p_sed_vatid,
            p_sed_vatrate,
            (p_sed_price * p_sed_quantity - p_sed_discount) * p_sed_vatrate,
            p_sed_price * p_sed_quantity - p_sed_discount + (p_sed_price * p_sed_quantity - p_sed_discount) * p_sed_vatrate,
            p_sed_comment,
            p_sed_count1,
            p_sed_count2,
            p_sed_charge,
            p_sed_bohid,
            p_sed_pmvid,
            p_sed_tarid,
            SYSDATE,
            SYSDATE,
            p_sed_esid,
            p_sed_int,
            p_sed_prepaid, --001SO
            p_sed_amountcu, --001SO
            p_sed_retsharepv, --001SO
            p_sed_retsharemo, --001SO
            TRUNC (TO_DATE (p_sed_date, 'yyyy-mm-dd HH24:MI:SS')),
            TO_NUMBER (p_sed_longid_1), --003SO
            TO_NUMBER (p_sed_longid_2) --036SO
                                      );

        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'Error'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_insert_setdetail'),
                sbsdb_logger_lib.log_param ('p_sed_setid', p_sed_setid),
                sbsdb_logger_lib.log_param ('p_sed_etid', p_sed_etid),
                sbsdb_logger_lib.log_param ('p_sed_price', p_sed_price),
                sbsdb_logger_lib.log_param ('p_sed_quantity', p_sed_quantity),
                sbsdb_logger_lib.log_param ('p_sed_discount', p_sed_discount),
                sbsdb_logger_lib.log_param ('p_sed_vatrate', p_sed_vatrate),
                sbsdb_logger_lib.log_param ('p_sed_desc', p_sed_desc),
                sbsdb_logger_lib.log_param ('p_sed_order', p_sed_order),
                sbsdb_logger_lib.log_param ('p_sed_visible', p_sed_visible),
                sbsdb_logger_lib.log_param ('p_sed_comment', p_sed_comment),
                sbsdb_logger_lib.log_param ('p_sed_count1', p_sed_count1),
                sbsdb_logger_lib.log_param ('p_sed_count2', p_sed_count2),
                sbsdb_logger_lib.log_param ('p_sed_charge', p_sed_charge),
                sbsdb_logger_lib.log_param ('p_sed_bohid', p_sed_bohid),
                sbsdb_logger_lib.log_param ('p_sed_pmvid', p_sed_pmvid),
                sbsdb_logger_lib.log_param ('p_sed_tarid', p_sed_tarid),
                sbsdb_logger_lib.log_param ('p_sed_esid', p_sed_esid),
                sbsdb_logger_lib.log_param ('p_sed_int', p_sed_int),
                sbsdb_logger_lib.log_param ('p_sed_date', p_sed_date),
                sbsdb_logger_lib.log_param ('p_sed_prepaid', p_sed_prepaid),
                sbsdb_logger_lib.log_param ('p_sed_amountcu', p_sed_amountcu),
                sbsdb_logger_lib.log_param ('p_sed_retsharepv', p_sed_retsharepv),
                sbsdb_logger_lib.log_param ('p_sed_retsharemo', p_sed_retsharemo),
                sbsdb_logger_lib.log_param ('p_sed_longid_1', p_sed_longid_1),
                sbsdb_logger_lib.log_param ('p_sed_longid_2', p_sed_longid_2),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    END sp_insert_setdetail;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_settling (
        p_set_etid                              IN     VARCHAR2,
        p_set_conid                             IN     VARCHAR2,
        p_set_demo                              IN     NUMBER,
        p_set_sepid                             IN     VARCHAR2,
        p_set_setidold                          IN     VARCHAR2,
        p_set_currency                          IN     VARCHAR2,
        p_set_comment                           IN     VARCHAR2,
        p_set_id                                   OUT VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        SELECT pkg_common.generateuniquekey ('G') INTO p_set_id FROM DUAL;

        INSERT INTO settling (
                        set_id,
                        set_etid,
                        set_conid,
                        set_demo,
                        set_sepid,
                        set_datecre,
                        set_dateprn1,
                        set_repid1,
                        set_dateprn2,
                        set_repid2,
                        set_datecan,
                        set_setidold,
                        set_currency,
                        set_net,
                        set_vat,
                        set_total,
                        set_esid,
                        set_date1,
                        set_date2,
                        set_comment)
        VALUES      (
            p_set_id,
            p_set_etid,
            p_set_conid,
            p_set_demo,
            p_set_sepid,
            SYSDATE,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            p_set_setidold,
            p_set_currency,
            0.00,
            0.00,
            0.00,
            'A',
            NULL,
            NULL,
            p_set_comment);

        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'Error'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_insert_settling'),
                sbsdb_logger_lib.log_param ('p_set_etid', p_set_etid),
                sbsdb_logger_lib.log_param ('p_set_conid', p_set_conid),
                sbsdb_logger_lib.log_param ('p_set_demo', p_set_demo),
                sbsdb_logger_lib.log_param ('p_set_sepid', p_set_sepid),
                sbsdb_logger_lib.log_param ('p_set_setidold', p_set_setidold),
                sbsdb_logger_lib.log_param ('p_set_currency', p_set_currency),
                sbsdb_logger_lib.log_param ('p_set_comment', p_set_comment),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    END sp_insert_settling;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_update_setdetail (
        p_sed_id                                IN     VARCHAR2,
        p_sed_price                             IN     FLOAT,
        p_sed_quantity                          IN     FLOAT,
        p_sed_discount                          IN     FLOAT,
        p_sed_count1                            IN     NUMBER,
        p_sed_count2                            IN     NUMBER,
        p_sed_amountcu                          IN     FLOAT, --001SO
        p_sed_retsharepv                        IN     FLOAT, --001SO
        p_sed_retsharemo                        IN     FLOAT, --001SO
        p_sed_pos                                  OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        UPDATE setdetail
        SET    sed_price = DECODE (p_sed_price, sed_price, sed_price, NULL),
               sed_quantity = sed_quantity + p_sed_quantity,
               sed_discount = sed_discount + p_sed_discount,
               sed_net = sed_net + p_sed_price * p_sed_quantity - p_sed_discount,
               sed_vat = sed_vat + (p_sed_price * p_sed_quantity - p_sed_discount) * sed_vatrate,
               sed_total = sed_total + p_sed_price * p_sed_quantity - p_sed_discount + (p_sed_price * p_sed_quantity - p_sed_discount) * sed_vatrate,
               sed_count1 = sed_count1 + p_sed_count1,
               sed_count2 = sed_count2 + p_sed_count2,
               sed_amountcu = sed_amountcu + p_sed_amountcu, --001SO
               sed_retsharepv = sed_retsharepv + p_sed_retsharepv, --001SO
               sed_retsharemo = sed_retsharemo + p_sed_retsharemo, --001SO
               sed_datetime = SYSDATE
        WHERE  sed_id = p_sed_id;

        p_sed_pos := 0; -- not evaluated yet

        returnstatus := 1;
        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;

            sbsdb_error_lib.LOG (
                SQLCODE,
                   sbsdb_logger_lib.json_other_first ('errcode', SQLCODE)
                || sbsdb_logger_lib.json_other_add ('errormsg', sbsdb_logger_lib.normalized_json (SQLERRM))
                || sbsdb_logger_lib.json_other_last ('topic', 'Error'),
                sbsdb_logger_lib.scope ($$plsql_unit, 'sp_update_setdetail'),
                sbsdb_logger_lib.log_param ('p_sed_id', p_sed_id),
                sbsdb_logger_lib.log_param ('p_sed_price', p_sed_price),
                sbsdb_logger_lib.log_param ('p_sed_quantity', p_sed_quantity),
                sbsdb_logger_lib.log_param ('p_sed_discount', p_sed_discount),
                sbsdb_logger_lib.log_param ('p_sed_count1', p_sed_count1),
                sbsdb_logger_lib.log_param ('p_sed_count2', p_sed_count2),
                sbsdb_logger_lib.log_param ('p_sed_amountcu', p_sed_amountcu),
                sbsdb_logger_lib.log_param ('p_sed_retsharepv', p_sed_retsharepv),
                sbsdb_logger_lib.log_param ('p_sed_retsharemo', p_sed_retsharemo),
                sbsdb_logger_lib.log_param ('returnstatus', returnstatus));
    END sp_update_setdetail;
END pkg_bdetail_settlement;
/