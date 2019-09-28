CREATE OR REPLACE PACKAGE BODY pkg_adhoc
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION account_name (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        result                                  VARCHAR2 (100);
    BEGIN
        result := NULL;

        SELECT ac_name
        INTO   result
        FROM   account
        WHERE  ac_id = p_ac_id;

        RETURN result;
    END account_name;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION as_date (p_date IN DATE)
        RETURN DATE
    IS
    BEGIN
        RETURN p_date;
    END as_date;

    /* =========================================================================
       Cut out billtext from UFIH CDR.
       ---------------------------------------------------------------------- */

    FUNCTION billtext_in_ufih (s IN VARCHAR2)
        RETURN VARCHAR2
    IS
        pos_f30                                 PLS_INTEGER;
        pos_f31                                 PLS_INTEGER;
        pos_f32                                 PLS_INTEGER;
    BEGIN
        pos_f30 := INSTR (s, 'F30=');
        pos_f31 := INSTR (s, 'F31=');
        pos_f32 := INSTR (s, 'F32=');

        IF pos_f30 > 0
        THEN
            IF pos_f31 > 0
            THEN
                RETURN SUBSTR (s, pos_f30 + 5, pos_f31 - pos_f30 - 7);
            ELSIF pos_f32 > 0
            THEN
                RETURN SUBSTR (s, pos_f30 + 5, pos_f32 - pos_f30 - 7);
            END IF;
        ELSE
            RETURN NULL;
        END IF;
    END billtext_in_ufih;

    /* =========================================================================
       Extract bit at given position (0 based) from bitstring (0 or 1 or NULL
       if bistring is too short).
       ---------------------------------------------------------------------- */

    FUNCTION bitpos (
        p_pos                                   IN NUMBER,
        p_bitstr                                IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        IF p_bitstr IS NULL
        THEN
            RETURN NULL;
        ELSIF LENGTH (p_bitstr) < p_pos + 1
        THEN
            RETURN NULL;
        ELSE
            RETURN TO_NUMBER (SUBSTR (p_bitstr, p_pos + 1));
        END IF;
    END bitpos;

    /* =========================================================================
       Extract bit at given position (0 based) from integer number.
       ---------------------------------------------------------------------- */

    FUNCTION bitval (
        p_pos                                   IN NUMBER,
        p_number                                IN NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        IF p_number IS NULL
        THEN
            RETURN NULL;
        ELSIF BITAND (p_number, POWER (2, p_pos)) + 0 = 0
        THEN
            RETURN 0;
        ELSE
            RETURN 1;
        END IF;
    END bitval;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION content_revenue_share (
        p_pricemodelversionid                   IN VARCHAR2,
        p_billrate                              IN NUMBER,
        p_amountcustomer                        IN NUMBER,
        p_prepaid                               IN VARCHAR2)
        RETURN NUMBER
    IS
        -- Prices from PriceModelVersion and bill rate
        CURSOR ccontentpricebillrate IS
            SELECT DECODE (p_prepaid, 'Y', NVL (pme_amountpv_pp, pme_amountpv), pme_amountpv)
            FROM   prmodelentry
            WHERE      pme_pmvid = p_pricemodelversionid
                   AND pme_billrate = p_billrate;

        -- Price interpolation values from price model, end user price and datetime
        -- Get smallest "BillRate" with PME_AMOUNTCU greater or equal to the Amount given
        -- Only look from "BillRate" 50 to 99
        CURSOR ccontentpriceplus IS
            SELECT   pme_amountcu,
                     DECODE (p_prepaid, 'Y', NVL (pme_amountpv_pp, pme_amountpv), pme_amountpv)     AS amountpv_plus,
                     pme_billrate
            FROM     prmodelentry
            WHERE        pme_pmvid = p_pricemodelversionid
                     AND pme_amountcu >= p_amountcustomer
                     AND pme_billrate >= 50
            ORDER BY pme_billrate ASC;

        -- Get lower bracketing billrate values by model version and billrate position
        CURSOR ccontentpriceminus (billrate IN NUMBER)
        IS
            SELECT pme_amountcu,
                   DECODE (p_prepaid, 'Y', NVL (pme_amountpv_pp, pme_amountpv), pme_amountpv)
            FROM   prmodelentry
            WHERE      pme_pmvid = p_pricemodelversionid
                   AND pme_billrate = billrate
                   AND pme_billrate >= 50;

        revenueshareprovider                    NUMBER (9, 4); -- result

        x_upperbillrate                         PLS_INTEGER;
        x_lowerbillrate                         PLS_INTEGER;

        x_amountcu_plus                         NUMBER (9, 4); -- split sample entry with customer charge HIGHER or equal to current
        x_amountpv_plus                         NUMBER (9, 4);

        x_amountcu_minus                        NUMBER (9, 4); -- split sample entry with customer charge SMALLER or equal to current
        x_amountpv_minus                        NUMBER (9, 4);
    BEGIN
        revenueshareprovider := NULL; -- signals an error

        IF p_billrate IS NOT NULL
        THEN
            -- Get prices from billrate
            OPEN ccontentpricebillrate;

            FETCH ccontentpricebillrate INTO revenueshareprovider;

            CLOSE ccontentpricebillrate;
        ELSE
            -- Get price splits from amount charged or refunded to customer (subscriber)
            -- Amount is compulsary here ( always for MBS billing and if BillRate not given)
            OPEN ccontentpriceplus;

            FETCH ccontentpriceplus
                INTO x_amountcu_plus,
                     x_amountpv_plus,
                     x_upperbillrate;

            IF ccontentpriceplus%FOUND
            THEN
                IF p_amountcustomer = x_amountcu_plus
                THEN
                    revenueshareprovider := x_amountpv_plus;
                ELSE
                    x_lowerbillrate := x_upperbillrate - 1;

                    OPEN ccontentpriceminus (x_lowerbillrate);

                    FETCH ccontentpriceminus
                        INTO x_amountcu_minus,
                             x_amountpv_minus;

                    IF ccontentpriceminus%FOUND
                    THEN
                        -- interpolate between bracketing values (minus and plus)
                        revenueshareprovider := x_amountpv_minus + (x_amountpv_plus - x_amountpv_minus) * (p_amountcustomer - x_amountcu_minus) / (x_amountcu_plus - x_amountcu_minus);
                    END IF;

                    CLOSE ccontentpriceminus;
                END IF;
            END IF;

            CLOSE ccontentpriceplus;
        END IF;

        RETURN revenueshareprovider;
    END content_revenue_share;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_acname (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        result                                  VARCHAR2 (100);
    BEGIN
        result := NULL;

        SELECT ac_name
        INTO   result
        FROM   contract,
               account
        WHERE      ac_id = con_acid
               AND con_id = p_con_id;

        RETURN result;
    END contract_acname;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_amount_range (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (20);
    BEGIN
        SELECT DECODE (
                   TRIM (TO_CHAR (MIN (pme_amountcu), '99990.00')) || '..' || TRIM (TO_CHAR (MAX (pme_amountcu), '99990.00')),
                   '..', '-0.01',
                   TRIM (TO_CHAR (MIN (pme_amountcu), '99990.00')) || '..' || TRIM (TO_CHAR (MAX (pme_amountcu), '99990.00')))
        INTO   l_retval
        FROM   (SELECT pme_amountcu
                FROM   contract,
                       prmodelver,
                       prmodelentry
                WHERE      contract.con_pmid = prmodelver.pmv_pmid
                       AND prmodelver.pmv_id = prmodelentry.pme_pmvid
                       AND con_id = p_con_id
                       AND pmv_start <= SYSDATE
                       AND pmv_end > SYSDATE
                       AND pmv_esid IN ('A')
                       AND pme_ratedesc <> 'undefined Rate'
                       AND (   pme_billrate = 50
                            OR pme_billrate IN (SELECT MIN (pme_billrate) - 1
                                                FROM   prmodelver,
                                                       prmodelentry
                                                WHERE      prmodelver.pmv_id = prmodelentry.pme_pmvid
                                                       AND pmv_pmid = con_pmid
                                                       AND pmv_start <= SYSDATE
                                                       AND pmv_end > SYSDATE
                                                       AND pmv_esid IN ('A')
                                                       AND pme_billrate >= 51
                                                       AND (   pme_ratedesc = 'undefined Rate'
                                                            OR pme_kw_check <> 0
                                                            OR pme_kw_review <> 0))));

        RETURN l_retval;
    END contract_amount_range;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_billrates (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cbillrates IS
            SELECT   pme_billrate
            FROM     contract,
                     prmodelver,
                     prmodelentry
            WHERE        contract.con_pmid = prmodelver.pmv_pmid
                     AND prmodelver.pmv_id = prmodelentry.pme_pmvid
                     AND con_id = p_con_id
                     AND pmv_start <= SYSDATE
                     AND pmv_end > SYSDATE
                     AND pmv_esid IN ('A')
                     AND pme_ratedesc <> 'undefined Rate'
            ORDER BY pme_billrate ASC;

        l_retval                                VARCHAR2 (300);
    BEGIN
        FOR cbillratesrow IN cbillrates
        LOOP
            IF l_retval IS NULL
            THEN
                l_retval := TRIM (TO_CHAR (cbillratesrow.pme_billrate));
            ELSE
                l_retval := l_retval || ';' || TRIM (TO_CHAR (cbillratesrow.pme_billrate));
            END IF;
        END LOOP;

        RETURN l_retval;
    END contract_billrates;

    /* =========================================================================
       Return IOT for a given
           - Telecom Operator Contract,
           - direction ('ORIG','TERM'),
           - transport medium ('SMS','MMS'), and
           - message size.
      ---------------------------------------------------------------------- */

    FUNCTION contract_iot (
        p_con_id                                IN VARCHAR2,
        p_iwdid                                 IN coniot.ciot_iwdid%TYPE,
        p_trctid                                IN coniot.ciot_trctid%TYPE,
        p_msgsize                               IN coniote.ciote_msgsize_max%TYPE DEFAULT 0)
        RETURN coniote.ciote_price%TYPE
    IS
        CURSOR csmsprice IS
            SELECT ciote_price
            FROM   coniot,
                   coniote
            WHERE      coniot.ciot_id = coniote.ciote_ciotid
                   AND ciot_trctid = p_trctid
                   AND ciot_iwdid = p_iwdid
                   AND ciot_conid = p_con_id; -- 002SO

        CURSOR cmmsprice IS
            SELECT   ciote_price
            FROM     coniot,
                     coniote
            WHERE        coniot.ciot_id = coniote.ciote_ciotid
                     AND ciot_trctid = p_trctid
                     AND ciot_iwdid = p_iwdid
                     AND ciot_conid = p_con_id
                     AND p_msgsize / 1024 < ciote_msgsize_max
            ORDER BY ciote_msgsize_max ASC; -- 002SO

        l_price                                 NUMBER (10, 4);
    BEGIN
        l_price := NULL;

        IF p_trctid = 'SMS'
        THEN
            FOR crow IN csmsprice
            LOOP
                l_price := crow.ciote_price;
            END LOOP;
        ELSE
            FOR crow IN cmmsprice
            LOOP
                l_price := crow.ciote_price;
                EXIT; -- 002SO first price
            END LOOP;
        END IF;

        RETURN l_price;
    END contract_iot;

    /* =========================================================================
       Return activity status of contract, depending on entity state, start-
       and end date.
       ---------------------------------------------------------------------- */

    FUNCTION contract_is_active (p_con_id IN VARCHAR2)
        RETURN NUMBER
    IS
        l_esid                                  contract.con_esid%TYPE;
        l_date_start                            DATE;
        l_date_end                              DATE;
        l_date_block                            DATE;
        l_date_now                              DATE;
    BEGIN
        l_date_now := SYSDATE;

        SELECT con_esid,
               con_datestart,
               con_dateend,
               con_dateblock
        INTO   l_esid,
               l_date_start,
               l_date_end,
               l_date_block
        FROM   contract
        WHERE  con_id = p_con_id;

        IF l_esid <> 'A'
        THEN
            RETURN 0;
        ELSIF l_date_block <= l_date_now
        THEN
            RETURN 0;
        ELSE
            IF     (   l_date_start IS NULL
                    OR l_date_start <= l_date_now)
               AND (   l_date_end IS NULL
                    OR l_date_end > l_date_now)
            THEN
                RETURN 1;
            ELSE
                RETURN 0;
            END IF;
        END IF;
    END contract_is_active;

    /* =========================================================================
       Return activity status of contract, depending on entity state, start-
       and end date
       ---------------------------------------------------------------------- */

    FUNCTION contract_is_active_or_test (p_con_id IN VARCHAR2)
        RETURN NUMBER
    IS
        l_esid                                  contract.con_esid%TYPE;
        l_date_start                            DATE;
        l_date_end                              DATE;
        l_date_block                            DATE;
        l_date_now                              DATE;
    BEGIN
        l_date_now := SYSDATE;

        SELECT con_esid,
               con_datestart,
               con_dateend,
               con_dateblock
        INTO   l_esid,
               l_date_start,
               l_date_end,
               l_date_block
        FROM   contract
        WHERE  con_id = p_con_id;

        IF l_esid NOT IN ('A',
                          'T')
        THEN
            RETURN 0;
        ELSIF l_date_block <= l_date_now
        THEN
            RETURN 0;
        ELSE
            IF    l_date_end IS NULL
               OR l_date_end > l_date_now
            THEN
                RETURN 1;
            ELSE
                RETURN 0;
            END IF;
        END IF;
    END contract_is_active_or_test;

    /* =========================================================================
       Return activity status of contract, depending on entity state, start-
       and end date.
       ---------------------------------------------------------------------- */

    FUNCTION contract_state (p_con_id IN VARCHAR2)
        RETURN NUMBER
    IS
        l_esid                                  contract.con_esid%TYPE;
        l_date_start                            DATE;
        l_date_end                              DATE;
        l_date_block                            DATE;
        l_date_now                              DATE;
    BEGIN
        l_date_now := SYSDATE;

        SELECT con_esid,
               con_datestart,
               con_dateend,
               con_dateblock
        INTO   l_esid,
               l_date_start,
               l_date_end,
               l_date_block
        FROM   contract
        WHERE  con_id = p_con_id;

        IF l_esid NOT IN ('A',
                          'T')
        THEN
            RETURN 0;
        ELSIF l_date_block <= l_date_now
        THEN
            RETURN 0;
        ELSIF     (   l_date_start IS NULL
                   OR l_date_start <= l_date_now)
              AND (   l_date_end IS NULL
                   OR l_date_end > l_date_now)
        THEN
            IF l_esid = 'A'
            THEN
                RETURN 1;
            ELSE
                RETURN 2;
            END IF;
        ELSIF    l_date_end IS NULL
              OR l_date_end > l_date_now
        THEN
            RETURN 2;
        ELSE
            RETURN 0;
        END IF;
    END contract_state;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contract_zero_billrates (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cbillrates IS
            SELECT   pme_billrate
            FROM     contract,
                     prmodelver,
                     prmodelentry
            WHERE        contract.con_pmid = prmodelver.pmv_pmid
                     AND prmodelver.pmv_id = prmodelentry.pme_pmvid
                     AND con_id = p_con_id
                     AND pmv_start <= SYSDATE
                     AND pmv_end > SYSDATE
                     AND pmv_esid IN ('A')
                     AND pme_ratedesc <> 'undefined Rate'
                     AND pme_amountcu = 0
            ORDER BY pme_billrate ASC;

        l_retval                                VARCHAR2 (300);
    BEGIN
        FOR cbillratesrow IN cbillrates
        LOOP
            IF l_retval IS NULL
            THEN
                l_retval := TRIM (TO_CHAR (cbillratesrow.pme_billrate));
            ELSE
                l_retval := l_retval || ';' || TRIM (TO_CHAR (cbillratesrow.pme_billrate));
            END IF;
        END LOOP;

        RETURN l_retval;
    END contract_zero_billrates;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION contractcountforaccount (p_ac_id IN VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR ccontractcount (p_ac_id IN VARCHAR2)
        IS
            SELECT COUNT (con_esid)
            FROM   account,
                   contract
            WHERE      account.ac_id = contract.con_acid
                   AND ac_id = p_ac_id
                   AND con_esid IN ('A',
                                    'E',
                                    'T');

        contract_count                          NUMBER;
    BEGIN
        OPEN ccontractcount (p_ac_id);

        FETCH ccontractcount INTO contract_count;

        IF ccontractcount%NOTFOUND
        THEN
            contract_count := 0;
        END IF;

        CLOSE ccontractcount;

        RETURN contract_count;
    END contractcountforaccount;

    /* =========================================================================
       Return activity status of a content service, also depending on contract
       entity state, start- and end date.
       ---------------------------------------------------------------------- */

    FUNCTION cs_is_active (p_cs_id IN VARCHAR2)
        RETURN NUMBER
    IS
        l_esid                                  contract.con_esid%TYPE;
        l_csesid                                contentservice.cs_esid%TYPE;
        l_date_start                            DATE;
        l_date_end                              DATE;
        l_date_block                            DATE;
        l_date_now                              DATE;
    BEGIN
        l_date_now := SYSDATE;

        SELECT cs_esid,
               con_esid,
               con_datestart,
               con_dateend,
               con_dateblock
        INTO   l_csesid,
               l_esid,
               l_date_start,
               l_date_end,
               l_date_block
        FROM   contentservice,
               contract
        WHERE      con_id = cs_conid
               AND cs_id = p_cs_id;

        IF l_csesid <> 'A'
        THEN
            l_esid := l_csesid; -- state of content service counts
        END IF;

        IF l_esid <> 'A'
        THEN
            RETURN 0;
        ELSIF l_date_block <= l_date_now
        THEN
            RETURN 0;
        ELSE
            IF     (   l_date_start IS NULL
                    OR l_date_start <= l_date_now)
               AND (   l_date_end IS NULL
                    OR l_date_end > l_date_now)
            THEN
                RETURN 1;
            ELSE
                RETURN 0;
            END IF;
        END IF;
    END cs_is_active;

    /* =========================================================================
       Return activity status of a content service, also depending on contract
       entity state, start- and end date.
       ---------------------------------------------------------------------- */

    FUNCTION cs_is_active_or_test (p_cs_id IN VARCHAR2)
        RETURN NUMBER
    IS
        l_esid                                  contract.con_esid%TYPE;
        l_csesid                                contentservice.cs_esid%TYPE;
        l_date_start                            DATE;
        l_date_end                              DATE;
        l_date_block                            DATE;
        l_date_now                              DATE;
    BEGIN
        l_date_now := SYSDATE;

        SELECT cs_esid,
               con_esid,
               con_datestart,
               con_dateend,
               con_dateblock
        INTO   l_csesid,
               l_esid,
               l_date_start,
               l_date_end,
               l_date_block
        FROM   contentservice,
               contract
        WHERE      con_id = cs_conid
               AND cs_id = p_cs_id;

        IF l_csesid <> 'A'
        THEN
            l_esid := l_csesid; -- state of content service counts
        END IF;

        IF l_esid NOT IN ('A',
                          'T')
        THEN
            RETURN 0;
        ELSIF l_date_block <= l_date_now
        THEN
            RETURN 0;
        ELSE
            IF    l_date_end IS NULL
               OR l_date_end > l_date_now
            THEN
                RETURN 1;
            ELSE
                RETURN 0;
            END IF;
        END IF;
    END cs_is_active_or_test;

    /* =========================================================================
       Return Content service code transformation which allows key collation.
       ---------------------------------------------------------------------- */

    FUNCTION cs_service_key (p_cs_service IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_medium                                VARCHAR2 (10);
        l_direction                             VARCHAR2 (10);
        l_shortid                               VARCHAR2 (10);
        l_extension                             VARCHAR2 (10);
    BEGIN
        l_medium := REGEXP_SUBSTR (p_cs_service, '[^-]+', 1, 1);
        l_direction := REGEXP_SUBSTR (p_cs_service, '[^-]+', 1, 2);
        l_shortid := REGEXP_SUBSTR (p_cs_service, '[^-]+', 1, 3);
        l_extension := REGEXP_SUBSTR (p_cs_service, '[^-]+', 1, 4);

        IF REGEXP_SUBSTR (p_cs_service, '[^-]+', 1, 4) IS NULL
        THEN
            RETURN l_shortid || '-' || l_medium || '-' || l_direction;
        ELSE
            RETURN l_shortid || '-' || l_medium || '-' || l_direction || '-' || l_extension;
        END IF;
    END cs_service_key;

    /* =========================================================================
       Return activity status of contract, depending on entity state,
       start- and end date.
       ---------------------------------------------------------------------- */

    FUNCTION cs_state (p_cs_id IN VARCHAR2)
        RETURN NUMBER
    IS
        l_esid                                  contract.con_esid%TYPE;
        l_csesid                                contentservice.cs_esid%TYPE;
        l_date_start                            DATE;
        l_date_end                              DATE;
        l_date_block                            DATE;
        l_date_now                              DATE;
    BEGIN
        l_date_now := SYSDATE;

        SELECT cs_esid,
               con_esid,
               con_datestart,
               con_dateend,
               con_dateblock
        INTO   l_csesid,
               l_esid,
               l_date_start,
               l_date_end,
               l_date_block
        FROM   contentservice,
               contract
        WHERE      con_id = cs_conid
               AND cs_id = p_cs_id;

        IF l_csesid <> 'A'
        THEN
            l_esid := l_csesid; -- state of content service counts
        END IF;

        IF l_esid NOT IN ('A',
                          'T')
        THEN
            RETURN 0;
        ELSIF l_date_block <= l_date_now
        THEN
            RETURN 0;
        ELSIF     (   l_date_start IS NULL
                   OR l_date_start <= l_date_now)
              AND (   l_date_end IS NULL
                   OR l_date_end > l_date_now)
        THEN
            IF l_esid = 'A'
            THEN
                RETURN 1;
            ELSE
                RETURN 2;
            END IF;
        ELSIF    l_date_end IS NULL
              OR l_date_end > l_date_now
        THEN
            RETURN 2;
        ELSE
            RETURN 0;
        END IF;
    END cs_state;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION desc_corr (
        p_old_desc                              IN VARCHAR2,
        p_old_count                             IN NUMBER,
        p_count_diff                            IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (p_old_desc, '/MT' || p_old_count || '/', '/MT' || (p_old_count + p_count_diff) || '/');
    END desc_corr;

    /* =========================================================================
       Get hierarchical hash from lines of text containing prefixes.
       ---------------------------------------------------------------------- */

    FUNCTION gethierarchicalhash (p_details IN VARCHAR2)
        RETURN VARCHAR2
    IS
        crlf                                    VARCHAR2 (2) := CHR (13) || CHR (10);
        l_sep                                   VARCHAR2 (1) := ':';

        l_result                                VARCHAR2 (1000);

        l_curlinestartpos                       PLS_INTEGER;
        l_curlineendpos                         PLS_INTEGER; -- begining of line sep chars
        l_cursectionstartpos                    PLS_INTEGER;
        l_cursectionendpos                      PLS_INTEGER;
        l_cursectionprefix                      VARCHAR2 (41);
        l_newsectionprefix                      VARCHAR2 (41);
    BEGIN
        l_result := NULL;
        l_curlinestartpos := 1;
        l_cursectionstartpos := 1;
        l_cursectionprefix := NULL;
        l_curlineendpos := INSTR (p_details, crlf, l_curlinestartpos);

        WHILE l_curlineendpos > l_curlinestartpos
        LOOP
            -- find the current line's end
            IF SUBSTR (p_details, l_curlinestartpos, 1) = l_sep
            THEN
                l_newsectionprefix := l_sep;
            ELSE
                l_newsectionprefix := SUBSTR (p_details, l_curlinestartpos, INSTR (p_details, l_sep, l_curlinestartpos) - l_curlinestartpos + 1);
            END IF;

            IF l_cursectionprefix IS NULL
            THEN
                l_cursectionprefix := l_newsectionprefix;
            ELSIF l_newsectionprefix <> l_cursectionprefix
            THEN
                -- prefix changed. Time to add a hash line to the output
                l_cursectionendpos := l_curlinestartpos - 1;
                l_result := l_result || l_cursectionprefix || hash_md5 (SUBSTR (p_details, l_cursectionstartpos, l_cursectionendpos - l_cursectionstartpos + 1)) || crlf;
                l_cursectionstartpos := l_curlinestartpos;
                l_cursectionprefix := l_newsectionprefix;
            END IF;

            l_curlinestartpos := l_curlineendpos + LENGTH (crlf);
            l_curlineendpos := INSTR (p_details, crlf, l_curlinestartpos);
        END LOOP;

        IF l_newsectionprefix IS NOT NULL
        THEN
            l_cursectionendpos := l_curlinestartpos - 1;
            l_result := l_result || l_cursectionprefix || hash_md5 (SUBSTR (p_details, l_cursectionstartpos, l_cursectionendpos - l_cursectionstartpos + 1)) || crlf;
        END IF;

        RETURN l_result;
    END gethierarchicalhash;

    /* =========================================================================
       Used for evaluation of Amount range for given price model.
       ---------------------------------------------------------------------- */

    FUNCTION getpricerange (p_pm_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_retval                                VARCHAR2 (20);
    BEGIN
        SELECT DECODE (
                   TRIM (TO_CHAR (MIN (pme_amountcu), '99990.00')) || '..' || TRIM (TO_CHAR (MAX (pme_amountcu), '99990.00')),
                   '..', '-0.01',
                   TRIM (TO_CHAR (MIN (pme_amountcu), '99990.00')) || '..' || TRIM (TO_CHAR (MAX (pme_amountcu), '99990.00')))
        INTO   l_retval
        FROM   (SELECT pme_amountcu
                FROM   prmodelver,
                       prmodelentry
                WHERE      prmodelver.pmv_id = prmodelentry.pme_pmvid
                       AND pmv_pmid = p_pm_id
                       AND pmv_start <= SYSDATE
                       AND pmv_end > SYSDATE
                       AND pmv_esid IN ('A')
                       AND pme_ratedesc <> 'undefined Rate'
                       AND (   pme_billrate = 50
                            OR pme_billrate IN (SELECT MIN (pme_billrate) - 1
                                                FROM   prmodelver,
                                                       prmodelentry
                                                WHERE      prmodelver.pmv_id = prmodelentry.pme_pmvid
                                                       AND pmv_pmid = p_pm_id
                                                       AND pmv_start <= SYSDATE
                                                       AND pmv_end > SYSDATE
                                                       AND pmv_esid IN ('A')
                                                       AND pme_billrate >= 51
                                                       AND (   pme_ratedesc = 'undefined Rate'
                                                            OR pme_kw_check <> 0
                                                            OR pme_kw_review <> 0))));

        RETURN l_retval;
    END getpricerange;

    /* =========================================================================
       Return MD5 HASH of given input parameter.
       ---------------------------------------------------------------------- */

    FUNCTION hash_md5 (var IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN DBMS_OBFUSCATION_TOOLKIT.md5 (input => UTL_RAW.cast_to_raw (NVL (var, '<NULL>')));
    END hash_md5;

    /* =========================================================================
       Used for evaluation of reporting parematers.
       ---------------------------------------------------------------------- */

    FUNCTION job_search_parameter_test (
        p_job_id                                IN VARCHAR2,
        p_par_name                              IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cparamvalue IS
            SELECT stajp_value
            FROM   sta_jobparam
            WHERE      stajp_name = p_par_name
                   AND stajp_jobid = p_job_id;

        l_retval                                VARCHAR2 (100);
    BEGIN
        OPEN cparamvalue;

        FETCH cparamvalue INTO l_retval;

        IF cparamvalue%FOUND
        THEN
            IF l_retval IS NULL
            THEN
                l_retval := '%';
            ELSE
                l_retval := REPLACE (l_retval, '*', '%');
                l_retval := REPLACE (l_retval, '?', '_');
            END IF;
        ELSE
            l_retval := '%';
        END IF;

        CLOSE cparamvalue;

        RETURN l_retval;
    END job_search_parameter_test;

    /* =========================================================================
       SMS-LA Revenue in microfrancs per CDR.
       ---------------------------------------------------------------------- */

    FUNCTION kpi_sms_la_revenue (p_bihid IN VARCHAR2)
        RETURN NUMBER
    IS
        l_result                                NUMBER;
    BEGIN
        SELECT 1000000 * SUM (bd_amounttr) / COUNT (*)
        INTO   l_result
        FROM   bdetail1
        WHERE      bd_bihid = p_bihid
               AND bd_tarid NOT IN ('X',
                                    'V',
                                    'S',
                                    'P',
                                    'T');

        RETURN l_result;
    /*
    SELECT
         BIH_DATEFC
        ,KPI_SMS_LA_REVENUE(BIH_ID)
    FROM biheader
    WHERE BIH_SRCTYPE = 'SMSC'
    AND BIH_DATETIME >= to_date('04.09.2014','dd.mm.yyyy')
    AND BIH_DATETIME < to_date('09.09.2014','dd.mm.yyyy')
    AND to_char(BIH_DATETIME,'SS') like '00'
    */
    END kpi_sms_la_revenue;

    /* =========================================================================
       Return current account name for large account with givne consolidation
       field.
       ---------------------------------------------------------------------- */

    FUNCTION la_acname (p_consol IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cactive IS
            SELECT ac_name
            FROM   contract,
                   account
            WHERE      ac_id = con_acid
                   AND con_etid = 'LAC'
                   AND con_esid IN ('A')
                   AND (   SYSDATE >= con_datestart
                        OR con_datestart IS NULL)
                   AND (   SYSDATE < con_dateend
                        OR con_dateend IS NULL)
                   AND con_consol = p_consol;

        CURSOR cactivefuture IS
            SELECT   ac_name
            FROM     contract,
                     account
            WHERE        ac_id = con_acid
                     AND con_etid = 'LAC'
                     AND con_esid IN ('A')
                     AND con_consol = p_consol
            ORDER BY con_datestart ASC;

        CURSOR cinactive IS
            SELECT   ac_name
            FROM     contract,
                     account
            WHERE        ac_id = con_acid
                     AND con_etid = 'LAC'
                     AND con_esid IN ('I')
                     AND con_consol = p_consol
            ORDER BY con_dateend DESC;

        result                                  VARCHAR2 (100);
    BEGIN
        result := NULL;

        OPEN cactive;

        FETCH cactive INTO result;

        CLOSE cactive;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cactivefuture;

        FETCH cactivefuture INTO result;

        CLOSE cactivefuture;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cinactive;

        FETCH cinactive INTO result;

        CLOSE cinactive;

        RETURN result;
    END la_acname;

    /* =========================================================================
       Return true account ID for SMS-LA contract (matching IPC account's ID).
       ---------------------------------------------------------------------- */

    FUNCTION lac_ipc_acid (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cactivelac IS
            SELECT con_acid     AS ac_id
            FROM   contract
            WHERE      con_id = p_con_id
                   AND con_etid = 'LAC'
                   AND con_esid IN ('A',
                                    'T')
                   AND con_tarid NOT IN ('P',
                                         'S')
                   AND (   SYSDATE >= con_datestart
                        OR con_datestart IS NULL)
                   AND (   SYSDATE < con_dateend
                        OR con_dateend IS NULL);

        CURSOR cactivelacfuture IS
            SELECT con_acid     AS ac_id
            FROM   contract
            WHERE      con_id = p_con_id
                   AND con_etid = 'LAC'
                   AND con_esid IN ('E',
                                    'A',
                                    'T')
                   AND con_tarid NOT IN ('P',
                                         'S');

        CURSOR cactiveipc IS
            SELECT NVL (
                       (SELECT ipc.con_acid
                        FROM   contract ipc
                        WHERE      lac.con_consol = ipc.con_shortid
                               AND ipc.con_etid = 'IPC'
                               AND ipc.con_esid IN ('A',
                                                    'T')
                               AND (   SYSDATE >= ipc.con_datestart
                                    OR ipc.con_datestart IS NULL)
                               AND (   SYSDATE < ipc.con_dateend
                                    OR ipc.con_dateend IS NULL)),
                       lac.con_acid)    AS ac_id
            FROM   contract lac
            WHERE      lac.con_id = p_con_id
                   AND lac.con_etid = 'LAC'
                   AND lac.con_esid IN ('A',
                                        'T')
                   AND lac.con_tarid IN ('P',
                                         'S')
                   AND (   SYSDATE >= lac.con_datestart
                        OR lac.con_datestart IS NULL)
                   AND (   SYSDATE < lac.con_dateend
                        OR lac.con_dateend IS NULL);

        CURSOR cinactive IS
            SELECT con_acid     AS ac_id
            FROM   contract
            WHERE      con_id = p_con_id
                   AND con_etid = 'LAC' -- AND     CON_ESID NOT In ('E','A','T')
                                       ;

        result                                  VARCHAR2 (100);
    BEGIN
        result := NULL;

        OPEN cactivelac;

        FETCH cactivelac INTO result;

        CLOSE cactivelac;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cactivelacfuture;

        FETCH cactivelacfuture INTO result;

        CLOSE cactivelacfuture;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cactiveipc;

        FETCH cactiveipc INTO result;

        CLOSE cactiveipc;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cinactive;

        FETCH cinactive INTO result;

        CLOSE cinactive;

        RETURN result;
    END lac_ipc_acid;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION local_time (
        p_datetime                              IN DATE,
        p_offset                                IN NUMBER,
        p_local_offset                          IN NUMBER)
        RETURN DATE
    IS
    BEGIN
        RETURN p_datetime - (p_offset - p_local_offset) / 24 / 3600; --
    END local_time;

    /* =========================================================================
       Return true account ID for MMS-LA contract (matching IPC account's ID).
       ---------------------------------------------------------------------- */

    FUNCTION mlc_ipc_acid (p_con_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cactivelac IS
            SELECT con_acid     AS ac_id
            FROM   contract
            WHERE      con_id = p_con_id
                   AND con_etid = 'MLC'
                   AND con_esid IN ('A',
                                    'T')
                   AND con_tarid NOT IN ('P',
                                         'S')
                   AND (   SYSDATE >= con_datestart
                        OR con_datestart IS NULL)
                   AND (   SYSDATE < con_dateend
                        OR con_dateend IS NULL);

        CURSOR cactivelacfuture IS
            SELECT con_acid     AS ac_id
            FROM   contract
            WHERE      con_id = p_con_id
                   AND con_etid = 'MLC'
                   AND con_esid IN ('E',
                                    'A',
                                    'T')
                   AND con_tarid NOT IN ('P',
                                         'S');

        CURSOR cactiveipc IS
            SELECT NVL (
                       (SELECT ipc.con_acid
                        FROM   contract ipc
                        WHERE      lac.con_consol = ipc.con_shortid
                               AND ipc.con_etid = 'IPC'
                               AND ipc.con_esid IN ('A',
                                                    'T')
                               AND (   SYSDATE >= ipc.con_datestart
                                    OR ipc.con_datestart IS NULL)
                               AND (   SYSDATE < ipc.con_dateend
                                    OR ipc.con_dateend IS NULL)),
                       lac.con_acid)    AS ac_id
            FROM   contract lac
            WHERE      lac.con_id = p_con_id
                   AND lac.con_etid = 'MLC'
                   AND lac.con_esid IN ('A',
                                        'T')
                   AND lac.con_tarid IN ('P',
                                         'S')
                   AND (   SYSDATE >= lac.con_datestart
                        OR lac.con_datestart IS NULL)
                   AND (   SYSDATE < lac.con_dateend
                        OR lac.con_dateend IS NULL);

        CURSOR cinactive IS
            SELECT con_acid     AS ac_id
            FROM   contract
            WHERE      con_id = p_con_id
                   AND con_etid = 'MLC' -- AND     CON_ESID NOT In ('E','A','T')
                                       ;

        result                                  VARCHAR2 (100);
    BEGIN
        result := NULL;

        OPEN cactivelac;

        FETCH cactivelac INTO result;

        CLOSE cactivelac;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cactivelacfuture;

        FETCH cactivelacfuture INTO result;

        CLOSE cactivelacfuture;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cactiveipc;

        FETCH cactiveipc INTO result;

        CLOSE cactiveipc;

        IF NOT (result IS NULL)
        THEN
            RETURN result;
        END IF;

        OPEN cinactive;

        FETCH cinactive INTO result;

        CLOSE cinactive;

        RETURN result;
    END mlc_ipc_acid;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION partreorg_prepare_fk_only (
        own                                     IN VARCHAR2,
        tbl                                     IN VARCHAR2,
        part                                    IN VARCHAR2)
        -- $Id: function.sbs1_admin.partreorg_prepare.sql 24 2012-12-06 10:32:54Z svnrepo $
        RETURN NUMBER
    --   1: prepared table and corresponding partition with different number of rows
    --   2: specified table-partition does not exist
    --   2: reorg-table already exists
    IS
        sdat                                    DATE;
        diff                                    NUMBER;
        prt                                     NUMBER;
        tab                                     NUMBER := -1;
        tbs                                     VARCHAR2 (30);
        felder                                  VARCHAR2 (4000);
        felder2                                 VARCHAR2 (4000);
        sqlcmd                                  VARCHAR2 (4000);
        objname                                 VARCHAR2 (30);
        ref_obj                                 VARCHAR2 (61);
        ungleich1                               EXCEPTION;
    BEGIN
        -- Bestimmung Tablespace-Name der Partition. TBS f?r komprimierte Partition ist *_HC
        sqlcmd := 'select tablespace_name from all_tab_partitions where table_owner=''' || own || ''' and table_name=''' || tbl || ''' and partition_name=''' || part || '''';
        DBMS_OUTPUT.put_line (sqlcmd || ';');

        BEGIN
            SELECT tablespace_name
            INTO   tbs
            FROM   all_tab_partitions
            WHERE      table_owner = own
                   AND table_name = tbl
                   AND partition_name = part;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                DBMS_OUTPUT.put_line ('Partition ' || own || '.' || tbl || '.' || part || ' does not exist');
                RETURN 2;
        END;

        IF tbs LIKE '%_UC'
        THEN
            tbs := SUBSTR (tbs, 1, LENGTH (tbs) - 3) || '_HC';
        ELSIF tbs LIKE '%_NC'
        THEN
            tbs := SUBSTR (tbs, 1, LENGTH (tbs) - 3) || '_HC';
        END IF;

        -- erstellen der neuen komprimierten Tabelle fuer den Partition-Exchange
        sqlcmd := 'create table ' || own || '.' || tbl || '_' || part || ' tablespace ' || tbs || ' pctfree 0 compress for archive high as select * from ' || own || '.' || tbl || ' where 1=2';
        DBMS_OUTPUT.put_line (sqlcmd || ';');

        BEGIN
            NULL;
        --     execute immediate sqlcmd;
        EXCEPTION
            WHEN OTHERS
            THEN
                IF SQLCODE = -955
                THEN -- ORA-00955: name is already used by an existing object
                    DBMS_OUTPUT.put_line ('Table ' || own || '.' || tbl || '_' || part || ' for re-organization already exists');
                    RETURN 3;
                ELSE
                    RAISE;
                END IF;
        END;

        BEGIN
            -- Umkopieren (und HCC komprimieren) der Daten
            sqlcmd := 'insert /*+ append */ into ' || own || '.' || tbl || '_' || part || ' select /* parallel(t,8) */ * from ' || own || '.' || tbl || ' partition (' || part || ') t';
            DBMS_OUTPUT.put_line (TO_CHAR (SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
            DBMS_OUTPUT.put_line (sqlcmd || ';');
            sdat := SYSDATE;
            --    execute immediate sqlcmd;
            diff := SYSDATE - sdat;
            DBMS_OUTPUT.put_line ('Duration: ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));

           -- Erstellen der Indices
           <<loop_all_indexes>>
            FOR ind IN (SELECT *
                        FROM   all_indexes --all_ind_columns
                        WHERE      table_owner = own
                               AND table_name = tbl
                               AND (table_owner,
                                    table_name) IN (SELECT table_owner,
                                                           table_name
                                                    FROM   all_tab_partitions
                                                    WHERE  compression = 'DISABLED'))
            LOOP
                felder := NULL;

               <<loop_all_ind_columns>>
                FOR col IN (SELECT *
                            FROM   all_ind_columns
                            WHERE      index_owner = own
                                   AND table_name = tbl
                                   AND index_name = ind.index_name)
                LOOP
                    SELECT DECODE (felder, NULL, col.column_name, felder || ',' || col.column_name) INTO felder FROM DUAL;
                END LOOP loop_all_ind_columns;

                SELECT tablespace_name
                INTO   tbs
                FROM   all_ind_partitions
                WHERE      index_owner = ind.owner
                       AND index_name = ind.index_name
                       AND partition_name = part;

                IF LENGTH (ind.index_name || '_' || part) > 30
                THEN
                    objname := SUBSTR (ind.index_name || '_' || part, -30); --indexnamen muessen eindeutig sein. Bei aktueller Namenskonvention funktioniert das
                ELSE
                    objname := ind.index_name || '_' || part;
                END IF;

                sqlcmd := 'create index ' || ind.owner || '.' || objname || ' on ' || ind.table_owner || '.' || ind.table_name || '_' || part || ' (' || felder || ') tablespace ' || tbs;
                DBMS_OUTPUT.put_line (sqlcmd || ';');
                sdat := SYSDATE;

                EXECUTE IMMEDIATE sqlcmd;

                diff := SYSDATE - sdat;
                DBMS_OUTPUT.put_line ('Duration: ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
            END LOOP loop_all_indexes;

           -- Foreign Key Constraints (novalidate)
           <<loop_constraint_name>>
            FOR c0 IN (SELECT constraint_name,
                              DECODE (status, 'ENABLED', ' enable ', 'disable ')     AS en
                       FROM   all_constraints
                       WHERE      owner = own
                              AND table_name = tbl
                              AND constraint_type = 'R')
            LOOP
                felder := NULL;
                felder2 := NULL;

                IF LENGTH (c0.constraint_name || '_' || part) > 30
                THEN
                    objname := 'R_' || SUBSTR (c0.constraint_name || '_' || part, -28);
                ELSE
                    objname := c0.constraint_name || '_' || part;
                END IF;

               <<loop_all_constraints>>
                FOR c1 IN (SELECT t.owner,
                                  t.constraint_name,
                                  t.table_name,
                                  t.r_owner,
                                  t.r_constraint_name,
                                  c.column_name,
                                  rc.column_name     AS ref_col,
                                  rc.table_name      AS ref_tbl,
                                  rc.owner           AS ref_own
                           FROM   all_constraints   t,
                                  all_cons_columns  c,
                                  all_cons_columns  rc
                           WHERE      t.owner = c.owner
                                  AND t.constraint_name = c.constraint_name
                                  AND t.r_owner = rc.owner
                                  AND t.r_constraint_name = rc.constraint_name
                                  AND c.position = rc.position
                                  AND t.owner = own
                                  AND t.table_name = tbl
                                  AND t.constraint_name = c0.constraint_name)
                LOOP
                    SELECT DECODE (felder, NULL, c1.column_name, felder || ',' || c1.column_name) INTO felder FROM DUAL;

                    SELECT DECODE (felder2, NULL, c1.ref_col, felder2 || ',' || c1.ref_col) INTO felder2 FROM DUAL;

                    ref_obj := c1.ref_own || '.' || c1.ref_tbl;
                END LOOP loop_all_constraints;

                sqlcmd :=
                       'alter table '
                    || own
                    || '.'
                    || tbl
                    || '_'
                    || part
                    || ' add constraint '
                    || objname
                    || ' foreign key('
                    || felder
                    || ') references '
                    || ref_obj
                    || '('
                    || felder2
                    || ')'
                    || c0.en
                    || 'novalidate';
                DBMS_OUTPUT.put_line (sqlcmd || ';');
                sdat := SYSDATE;

                EXECUTE IMMEDIATE sqlcmd;

                diff := SYSDATE - sdat;
                DBMS_OUTPUT.put_line ('Duration: ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
            END LOOP loop_constraint_name;

            -- Foreign Key Constraints (validate)
            FOR c0 IN (SELECT constraint_name
                       FROM   all_constraints
                       WHERE      owner = own
                              AND table_name = tbl
                              AND constraint_type = 'R'
                              AND status = 'ENABLED'
                              AND validated = 'VALIDATED')
            LOOP
                IF LENGTH (c0.constraint_name || '_' || part) > 30
                THEN
                    objname := 'R_' || SUBSTR (c0.constraint_name || '_' || part, -28);
                ELSE
                    objname := c0.constraint_name || '_' || part;
                END IF;

                sqlcmd := 'alter table ' || own || '.' || tbl || '_' || part || ' enable constraint ' || objname;
                DBMS_OUTPUT.put_line (sqlcmd || ';');
                sdat := SYSDATE;

                EXECUTE IMMEDIATE sqlcmd;

                diff := SYSDATE - sdat;
                DBMS_OUTPUT.put_line ('Duration: ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
            END LOOP; --c0

            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || '_' || part
                INTO                                     tab;

            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || ' partition (' || part || ')'
                INTO                                     prt;

            IF prt <> tab
            THEN
                DBMS_OUTPUT.put_line ('rows in original partition / compressed: ' || part || ' / ' || tab);
                RETURN 1;
            END IF;

            RETURN 0;
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    DBMS_OUTPUT.put_line ('ERROR: Compress partition unsuccessful ' || SQLCODE || ' : ' || SQLERRM);
                    pkg_common.insert_warning (
                        'PKG_PARTAG',
                        'partreorg_prepare',
                        'Compress partition command unsuccessful' || SQLCODE || ' : ' || SQLERRM,
                        own || '.' || tbl || '_' || part,
                        NULL,
                        NULL);
                    sqlcmd := 'drop table ' || own || '.' || tbl || '_' || part;
                    DBMS_OUTPUT.put_line (sqlcmd || ';');

                    EXECUTE IMMEDIATE sqlcmd;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                RAISE;
        END;
    END partreorg_prepare_fk_only;

    /* =========================================================================
       Return list of colon separated valid bill rates.
       ---------------------------------------------------------------------- */

    FUNCTION pmv_billrates (p_pmv_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR cbillrates IS
            SELECT   TO_CHAR (pme_billrate) || '=' || TO_CHAR (ROUND (pme_amountcu * 1000, 0))     AS item
            FROM     prmodelentry
            WHERE        prmodelentry.pme_pmvid = p_pmv_id
                     AND pme_ratedesc <> 'undefined Rate'
            ORDER BY pme_billrate ASC;

        l_retval                                VARCHAR2 (2000);
    BEGIN
        FOR cbillratesrow IN cbillrates
        LOOP
            IF l_retval IS NULL
            THEN
                l_retval := cbillratesrow.item;
            ELSE
                l_retval := l_retval || ';' || cbillratesrow.item;
            END IF;
        END LOOP;

        RETURN l_retval;
    END pmv_billrates;

    /* =========================================================================
       Used for re-rating of SMS CDRs (correction of incident in
       SBS Release 14.02.01).
       ---------------------------------------------------------------------- */

    FUNCTION re_rated_sms_cdr (
        vascontractid                           IN VARCHAR2,
        tariffid                                IN VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR csmslamttariff (
            conid                                   IN VARCHAR2,
            tarid                                   IN VARCHAR2)
        IS
            SELECT NVL (con_price, tar_price) + DECODE (NVL (con_price, tar_price), 0.00, 0.00, rs_price)                    AS scm_price, -- 384SO -- SCM price  / + NVL(CON_NOTFLAG * CON_NOTCHARGE,0.0)
                   NVL (con_priceint, tar_priceint) + DECODE (NVL (con_priceint, tar_priceint), 0.00, 0.00, rs_priceint)     AS int_price, -- 384SO -- INT price  / + NVL(CON_NOTFLAG * CON_NOTCHARGE,0.0)
                   NVL (con_hdgroup, 0)                                                                                      AS motid,
                   con_price, -- mV: transport price
                   con_refundcu -- mV: end user refund
            FROM   contract,
                   tariff,
                   retschema
            WHERE      con_id = conid
                   AND tar_id = tarid
                   AND rs_id = NVL (con_rsid, 'P0'); -- 226SO

        csmslamttariffrow                       csmslamttariff%ROWTYPE;

        CURSOR csmsmolatariff (
            conid                                   IN VARCHAR2,
            tarid                                   IN VARCHAR2)
        IS
            SELECT NVL (con_hdgroup, 0)                       AS motid,
                   NVL (con_pricehg, tar_pricehg)             AS pricehg,
                   tar_hgznid                                 AS hgznid,
                   con_price, -- mV: transport price
                   con_pricecu, -- mV: end user price
                   con_refundcu, -- mV: end user refund
                   con_retsharepv, -- mV: revenue share LA
                   NVL (con_pricemofn, tar_pricemofn_def)     AS con_pricemofn -- 345SO
            FROM   contract,
                   tariff
            WHERE      tariff.tar_id = tarid
                   AND con_id = conid;

        l_transportcost                         NUMBER (12, 4);
    BEGIN
        -- Only made for processing (rerating) SMS-LA CDRs withe BD_NPI_B = 1 BD_PID_B = 0 and BD_AMOUNTTR NOT NULL

        OPEN csmslamttariff (vascontractid, tariffid);

        FETCH csmslamttariff INTO csmslamttariffrow;

        IF csmslamttariff%NOTFOUND
        THEN
            l_transportcost := 0.00; -- 116SO
        ELSE
            -- Finalize the price calculation, now that we know about domestic / international
            -- Use LA pricing. Distinguish domestic and international price.    -- 226SO moved here, Lcase condition dropped
            -- If p_CdrInfo.PaymentMethod = cintPaymentUnknown then
            -- International price
            --    l_TransportCost := cSmsLaMtTariffRow.int_price;     -- 116SO
            --else
            -- Domestic price used for SCM network termination.
            l_transportcost := csmslamttariffrow.scm_price; -- 116SO
        -- end if;
        END IF;

        CLOSE csmslamttariff;

        RETURN l_transportcost;
    END re_rated_sms_cdr;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION reva_sigmask_merge (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (100);
        i                                       PLS_INTEGER;
    BEGIN
        IF LENGTH (s) <> LENGTH (m)
        THEN
            RAISE VALUE_ERROR;
        ELSE
           <<loop_length>>
            FOR i IN 1 .. LENGTH (s)
            LOOP
                IF SUBSTR (s, i, 1) = '_'
                THEN
                    l_result := l_result || SUBSTR (m, i, 1);
                ELSE
                    l_result := l_result || SUBSTR (s, i, 1);
                END IF;
            END LOOP loop_length;
        END IF;

        RETURN l_result;
    END reva_sigmask_merge;

    /* =========================================================================
       Return Content service parameter string representation.
       ---------------------------------------------------------------------- */

    FUNCTION service_parameter (
        p_type                                  IN VARCHAR2,
        p_value                                 IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (2000);
    BEGIN
        IF p_value IS NULL
        THEN
            l_result := 'null'; -- 002SO
        ELSIF p_type = 'boolean'
        THEN
            l_result := LOWER (p_value);
        ELSIF p_type = 'string'
        THEN
            l_result := pkg_json.json_string (p_value);
        ELSE
            l_result := p_value;
        END IF;

        RETURN l_result;
    END service_parameter;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION shift_vas_ts (
        p_hihid                                 IN VARCHAR2,
        p_datetime                              IN DATE,
        p_msisdn_a                              IN VARCHAR2,
        p_msisdn_b                              IN VARCHAR2,
        p_requestid                             IN VARCHAR2)
        RETURN DATE
    IS
        CURSOR cvasoccupied (
            msisdn_a                                IN VARCHAR2,
            msisdn_b                                IN VARCHAR2,
            shifted_date                            IN DATE)
        IS
            SELECT COUNT (*)     AS chargecount
            FROM   sbs0_admin.meccache_vas
            WHERE      meccvas_msisdn_a = msisdn_a
                   AND meccvas_msisdn_b = msisdn_b
                   AND meccvas_datetime = shifted_date;

        x_offset                                PLS_INTEGER;
        x_timestamp                             DATE;
        x_dup_count                             PLS_INTEGER;
    BEGIN
        -- avoid duplicate reject in back end billing by implementing time shift workaround
        x_offset := 0; -- try first without shifting the timestamp

       <<loop_dup_count>>
        LOOP
            x_timestamp := p_datetime + x_offset / 86400.00;

           <<loop_cvasoccupied>>
            FOR cvasoccupiedrow IN cvasoccupied (p_msisdn_a, p_msisdn_b, x_timestamp)
            LOOP
                x_dup_count := cvasoccupiedrow.chargecount;
            END LOOP loop_cvasoccupied;

            EXIT WHEN x_dup_count = 0;
            x_offset := x_offset + 1;
        END LOOP loop_dup_count;

        -- record billable CDR in the cache for future checks
        INSERT INTO sbs0_admin.meccache_vas (
                        meccvas_hihid,
                        meccvas_msisdn_a,
                        meccvas_msisdn_b,
                        meccvas_requestid,
                        meccvas_datetime,
                        meccvas_datesubmit,
                        meccvas_commit_state)
        VALUES      (
                        p_hihid,
                        p_msisdn_a,
                        p_msisdn_b,
                        p_requestid,
                        x_timestamp,
                        p_datetime,
                        0);

        RETURN x_timestamp;
    END shift_vas_ts;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION sigmask_merge (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result                                VARCHAR2 (100);
        i                                       PLS_INTEGER;
    BEGIN
        IF LENGTH (s) <> LENGTH (m)
        THEN
            RAISE VALUE_ERROR;
        ELSE
           <<loop_length>>
            FOR i IN 1 .. LENGTH (s)
            LOOP
                IF SUBSTR (s, i, 1) = '_'
                THEN
                    l_result := l_result || SUBSTR (m, i, 1);
                ELSE
                    l_result := l_result || SUBSTR (s, i, 1);
                END IF;
            END LOOP loop_length;
        END IF;

        RETURN l_result;
    END sigmask_merge;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION slow_text_table (
        sqlt_str_text                           IN VARCHAR2,
        sqlt_int_rows                           IN INTEGER,
        sqlt_vnr_delay                          IN NUMBER)
        RETURN t_text_tab
        PIPELINED
    IS
    BEGIN
        FOR i IN 1 .. sqlt_int_rows
        LOOP
            PIPE ROW (t_text_row (sqlt_str_text || i));
            sys.DBMS_LOCK.sleep (sqlt_vnr_delay);
        END LOOP;

        RETURN;
    END slow_text_table;

    /* =========================================================================
       Used for re-rating of SMS CDRs (correction of incident in
       SBS Release 14.02.01).
       ---------------------------------------------------------------------- */

    FUNCTION sms_la_mt_price (
        vascontractid                           IN VARCHAR2,
        tariffid                                IN VARCHAR2,
        paymentmethod                           IN NUMBER)
        RETURN NUMBER
    IS
        CURSOR csmslamttariff (
            conid                                   IN VARCHAR2,
            tarid                                   IN VARCHAR2)
        IS
            SELECT NVL (con_price, tar_price) + DECODE (NVL (con_price, tar_price), 0.00, 0.00, rs_price)                    AS scm_price, -- 384SO -- SCM price  / + NVL(CON_NOTFLAG * CON_NOTCHARGE,0.0)
                   NVL (con_priceint, tar_priceint) + DECODE (NVL (con_priceint, tar_priceint), 0.00, 0.00, rs_priceint)     AS int_price, -- 384SO -- INT price  / + NVL(CON_NOTFLAG * CON_NOTCHARGE,0.0)
                   NVL (con_hdgroup, 0)                                                                                      AS motid,
                   con_price, -- mV: transport price
                   con_refundcu -- mV: end user refund
            FROM   contract,
                   tariff,
                   retschema
            WHERE      con_id = conid
                   AND tar_id = tarid
                   AND rs_id = NVL (con_rsid, 'P0'); -- 226SO

        csmslamttariffrow                       csmslamttariff%ROWTYPE;

        CURSOR csmsmolatariff (
            conid                                   IN VARCHAR2,
            tarid                                   IN VARCHAR2)
        IS
            SELECT NVL (con_hdgroup, 0)                       AS motid,
                   NVL (con_pricehg, tar_pricehg)             AS pricehg,
                   tar_hgznid                                 AS hgznid,
                   con_price, -- mV: transport price
                   con_pricecu, -- mV: end user price
                   con_refundcu, -- mV: end user refund
                   con_retsharepv, -- mV: revenue share LA
                   NVL (con_pricemofn, tar_pricemofn_def)     AS con_pricemofn -- 345SO
            FROM   contract,
                   tariff
            WHERE      tariff.tar_id = tarid
                   AND con_id = conid;

        l_transportcost                         NUMBER (12, 4);
    BEGIN
        -- Only made for processing (rerating) SMS-LA CDRs withe BD_NPI_B = 1 BD_PID_B = 0 (and maybe BD_AMOUNTTR NOT NULL)

        OPEN csmslamttariff (vascontractid, tariffid);

        FETCH csmslamttariff INTO csmslamttariffrow;

        IF csmslamttariff%NOTFOUND
        THEN
            l_transportcost := 0.00; -- 116SO
        ELSE
            -- Finalize the price calculation, now that we know about domestic / international
            -- Use LA pricing. Distinguish domestic and international price.    -- 226SO moved here, Lcase condition dropped
            IF NVL (paymentmethod, 0) = 0
            THEN
                -- International price
                l_transportcost := csmslamttariffrow.int_price; -- 116SO
            ELSE
                -- Domestic price used for SCM network termination.
                l_transportcost := csmslamttariffrow.scm_price; -- 116SO
            END IF;
        END IF;

        CLOSE csmslamttariff;

        RETURN l_transportcost;
    END sms_la_mt_price;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION string_match (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        IF s IS NULL
        THEN
            RETURN NULL;
        ELSIF m IS NULL
        THEN
            RETURN NULL;
        ELSIF s LIKE m
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END string_match;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION string_match_count (
        s                                       IN VARCHAR2,
        m                                       IN VARCHAR2)
        RETURN NUMBER
    IS
        result                                  PLS_INTEGER := 0;
    BEGIN
        IF s IS NULL
        THEN
            result := NULL;
        ELSIF m IS NULL
        THEN
            result := NULL;
        ELSIF s = m
        THEN
            result := LENGTH (s);
        ELSIF LENGTH (s) <= LENGTH (m)
        THEN
            FOR c IN 1 .. LENGTH (s)
            LOOP
                IF SUBSTR (s, c, 1) = SUBSTR (m, c, 1)
                THEN
                    result := result + 1;
                END IF;
            END LOOP;
        ELSE
            FOR c IN 1 .. LENGTH (m)
            LOOP
                IF SUBSTR (s, c, 1) = SUBSTR (m, c, 1)
                THEN
                    result := result + 1;
                END IF;
            END LOOP;
        END IF;

        RETURN result;
    END string_match_count;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION to_base (
        p_dec                                   IN NUMBER,
        p_base                                  IN NUMBER)
        RETURN VARCHAR2
    IS
        l_str                                   VARCHAR2 (255) DEFAULT NULL;
        l_num                                   NUMBER DEFAULT p_dec;
        l_hex                                   VARCHAR2 (16) DEFAULT '0123456789ABCDEF';
    BEGIN
        IF    p_dec IS NULL
           OR p_base IS NULL
        THEN
            RETURN NULL;
        END IF;

        IF    TRUNC (p_dec) <> p_dec
           OR p_dec < 0
        THEN
            RAISE PROGRAM_ERROR;
        END IF;

        LOOP
            l_str := SUBSTR (l_hex, MOD (l_num, p_base) + 1, 1) || l_str;
            l_num := TRUNC (l_num / p_base);
            EXIT WHEN l_num = 0;
        END LOOP;

        RETURN l_str;
    END to_base;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE app_create_synonym (
        obj                                     IN VARCHAR2,
        src                                     IN VARCHAR2,
        dest                                    IN VARCHAR2,
        p_exec                                  IN NUMBER DEFAULT 1)
    IS
    BEGIN
        admin.app_create_synonym (obj, src, dest, p_exec);
    END app_create_synonym;

    /* =========================================================================
       Merge all application object grants with the existing ones in table
       APP_OBJECT_GRANT.
       ---------------------------------------------------------------------- */

    PROCEDURE app_merge_app_grants (p_grantee IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO app_object_grant (
                        object_name,
                        grantee,
                        permission,
                        object_type)
            SELECT   app_object.object_name,
                     p_grantee,
                     app_permission.app_perm_id,
                     app_object.object_type
            FROM     app_object,
                     app_permission
            WHERE        (       app_perm_id = 'EXECUTE'
                             AND app_object.object_type IN ('PROCEDURE',
                                                            'FUNCTION',
                                                            'PACKAGE')
                          OR     app_perm_id IN ('SELECT',
                                                 'INSERT',
                                                 'UPDATE',
                                                 'DELETE')
                             AND app_object.object_type IN ('TABLE')
                          OR     app_perm_id IN ('SELECT')
                             AND app_object.object_type IN ('VIEW',
                                                            'MATERIALIZED VIEW',
                                                            'SEQUENCE')
                          OR     app_perm_id IN ('ENQUEUE',
                                                 'DEQUEUE')
                             AND app_object.object_type IN ('QUEUE')
                          OR     app_perm_id IN ('USE')
                             AND app_object.object_type IN ('SYNONYM'))
                     AND NOT EXISTS
                             (SELECT ROWID
                              FROM   app_object_grant
                              WHERE      object_name = app_object.object_name
                                     AND grantee = p_grantee
                                     AND permission = app_perm_id)
                     AND (   app_object.object_type <> 'TABLE'
                          OR NOT EXISTS
                                 (SELECT ao2.object_name
                                  FROM   app_object ao2
                                  WHERE      ao2.object_name = app_object.object_name
                                         AND ao2.object_type = 'MATERIALIZED VIEW'))
                     AND app_object.object_name NOT IN (SELECT object_name || '_' || subobject_name
                                                        FROM   all_objects
                                                        WHERE      owner = USER
                                                               AND object_type IN ('TABLE PARTITION'))
            GROUP BY app_object.object_name,
                     app_permission.app_perm_id,
                     app_object.object_type;

        COMMIT WORK;
    END app_merge_app_grants;

    /* =========================================================================
       Merge needed object grants with the existing ones in table
       APP_OBJECT_GRANT.
       ---------------------------------------------------------------------- */

    PROCEDURE app_merge_token_grants (p_grantee IN VARCHAR2)
    IS
    BEGIN
        UPDATE app_token
        SET    token = UPPER (token);

        INSERT INTO app_object_grant (
                        object_name,
                        grantee,
                        permission,
                        object_type)
            SELECT   app_token.token,
                     p_grantee,
                     app_permission.app_perm_id,
                     app_object.object_type
            FROM     app_object,
                     app_token,
                     app_permission
            WHERE        app_object.object_name = app_token.token
                     AND (       app_perm_id IN ('EXECUTE')
                             AND app_object.object_type IN ('PROCEDURE',
                                                            'FUNCTION',
                                                            'PACKAGE')
                          OR     app_perm_id IN ('SELECT',
                                                 'INSERT',
                                                 'UPDATE',
                                                 'DELETE')
                             AND app_object.object_type IN ('TABLE')
                          OR     app_perm_id IN ('SELECT')
                             AND app_object.object_type IN ('VIEW',
                                                            'MATERIALIZED VIEW',
                                                            'SEQUENCE')
                          OR     app_perm_id IN ('ENQUEUE',
                                                 'DEQUEUE')
                             AND app_object.object_type IN ('QUEUE')
                          OR     app_perm_id IN ('USE')
                             AND app_object.object_type IN ('SYNONYM'))
                     AND NOT EXISTS
                             (SELECT ROWID
                              FROM   app_object_grant
                              WHERE      object_name = app_token.token
                                     AND grantee = p_grantee
                                     AND permission = app_perm_id)
                     AND (   app_object.object_type <> 'TABLE'
                          OR NOT EXISTS
                                 (SELECT ao2.object_name
                                  FROM   app_object ao2
                                  WHERE      ao2.object_name = app_token.token
                                         AND ao2.object_type = 'MATERIALIZED VIEW'))
            GROUP BY app_token.token,
                     app_permission.app_perm_id,
                     app_object.object_type;

        COMMIT WORK;
    END app_merge_token_grants;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE correlate_seg
    IS
        stmt                                    VARCHAR2 (4000);
    BEGIN
        stmt := '
            CREATE TABLE bdetail2_hr_seg_master_11
            TABLESPACE sbs1_archiv_data_nc
            AS
                SELECT /*+ NO_INDEX BDETAIL2_HR_SEG */
                       m.bd_id,
                       m.bd_datetime,
                       m.bd_msisdn_a,
                       m.bd_msisdn_b,
                       m.bd_imsi,
                       m.bd_length,
                       m.bd_ogti,
                       m.bd_dgti,
                       m.bd_iw,
                       m.bd_messagereference,
                       m.bd_smscid,
                       m.bd_origsca,
                       m.bd_deliver_esme_id,
                       m.bd_seg_id,
                       m.bd_seg_count,
                       m.bd_ogti_opkey,
                       m.bd_deliver_opkey,
                       m.bd_dgti_opkey,
                       m.bd_sca_opkey,
                       m.bd_iw_amount,
                       m.bd_iw_apmn,
                       m.bd_iw_curid,
                       m.bd_iw_dir,
                       m.bd_iw_scenario,
                       m.bd_iw_constate,
                       (SELECT /*+ INDEX (BDETAIL2_HR_SEG,BDETAIL2_HR_SEG_IND) */
                               COUNT (*)
                        FROM   bdetail2_hr_seg s
                        WHERE      s.bd_seg_count = m.bd_seg_count
                               AND s.bd_origsca = m.bd_origsca
                               AND s.bd_msisdn_a = m.bd_msisdn_a
                               AND s.bd_msisdn_b = m.bd_msisdn_b
                               AND s.bd_datetime >= m.bd_datetime - 0.3 / 24
                               AND s.bd_datetime <= m.bd_datetime + 0.1 / 24)    AS is_count
                FROM   bdetail2_hr_seg m
                WHERE      m.bd_datetime >= TO_DATE (''01.11.2017'', ''dd.mm.yyyy'')
                       AND m.bd_datetime < TO_DATE (''01.12.2017'', ''dd.mm.yyyy'')
      ';

        EXECUTE IMMEDIATE stmt;

        COMMIT WORK;
    END correlate_seg;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE correlate_seg2
    IS
        stmt                                    VARCHAR2 (4000);
    BEGIN
        stmt := '
            CREATE TABLE bdetail2_hr_seg_master2_06
            TABLESPACE sbs1_archiv_data_nc
            AS
                SELECT /*+ NO_INDEX BDETAIL2_HR_SEG */
                       m.bd_id,
                       m.bd_datetime,
                       m.bd_msisdn_a,
                       m.bd_msisdn_b,
                       m.bd_imsi,
                       m.bd_length,
                       m.bd_ogti,
                       m.bd_dgti,
                       m.bd_iw,
                       m.bd_messagereference,
                       m.bd_smscid,
                       m.bd_origsca,
                       m.bd_deliver_esme_id,
                       m.bd_seg_id,
                       m.bd_seg_count,
                       m.bd_ogti_opkey,
                       m.bd_deliver_opkey,
                       m.bd_dgti_opkey,
                       m.bd_sca_opkey,
                       m.bd_iw_amount,
                       m.bd_iw_apmn,
                       m.bd_iw_curid,
                       m.bd_iw_dir,
                       m.bd_iw_scenario,
                       m.bd_iw_constate,
                       (SELECT /*+ INDEX (BDETAIL2_HR_SEG,BDETAIL2_HR_SEG_IND) */
                               COUNT (*)
                        FROM   bdetail2_hr_seg s
                        WHERE      s.bd_seg_count = m.bd_seg_count
                               AND s.bd_origsca = m.bd_origsca
                               AND s.bd_msisdn_a = m.bd_msisdn_a
                               AND s.bd_msisdn_b = m.bd_msisdn_b
                               AND s.bd_datetime >= m.bd_datetime - 0.15 / 24
                               AND s.bd_datetime <= m.bd_datetime + 0.05 / 24)    AS is_count
                FROM   bdetail2_hr_seg m
                WHERE      m.bd_datetime >= TO_DATE (''01.06.2017'', ''dd.mm.yyyy'')
                       AND m.bd_datetime < TO_DATE (''01.07.2017'', ''dd.mm.yyyy'')
      ';

        EXECUTE IMMEDIATE stmt;

        COMMIT WORK;
    END correlate_seg2;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE partreorg (
        own                                     IN VARCHAR2,
        tbl                                     IN VARCHAR2,
        part                                    IN VARCHAR2)
    IS
        tbs                                     VARCHAR2 (30);
        felder                                  VARCHAR2 (4000);
        felder2                                 VARCHAR2 (4000);
        sqlcmd                                  VARCHAR2 (4000);
        objname                                 VARCHAR2 (30);
        ref_obj                                 VARCHAR2 (61);
    BEGIN
        SELECT tablespace_name
        INTO   tbs
        FROM   all_tab_partitions
        WHERE      table_owner = own
               AND table_name = tbl
               AND partition_name = part;

        IF tbs LIKE '%_UC'
        THEN
            tbs := SUBSTR (tbs, 1, LENGTH (tbs) - 3) || '_HC';
        END IF;

        sqlcmd := 'create table ' || own || '.' || tbl || '_' || part || ' tablespace ' || tbs || ' pctfree 0 compress for archive high as select * from ' || own || '.' || tbl || ' where 1=2';
        DBMS_OUTPUT.put_line (sqlcmd || ';');

        EXECUTE IMMEDIATE sqlcmd;

        sqlcmd := 'insert /*+ append */ into ' || own || '.' || tbl || '_' || part || ' select * from ' || own || '.' || tbl || ' partition (' || part || ')';
        DBMS_OUTPUT.put_line (sqlcmd || ';');

        EXECUTE IMMEDIATE sqlcmd;

       <<loop_all_indexes>>
        FOR ind IN (SELECT *
                    FROM   all_indexes --all_ind_columns
                    WHERE      table_owner = own
                           AND table_name = tbl
                           AND (table_owner,
                                table_name) IN (SELECT table_owner,
                                                       table_name
                                                FROM   all_tab_partitions
                                                WHERE  compression = 'DISABLED'))
        LOOP
            felder := NULL;

           <<loop_all_index_columns>>
            FOR col IN (SELECT *
                        FROM   all_ind_columns
                        WHERE      index_owner = own
                               AND table_name = tbl
                               AND index_name = ind.index_name)
            LOOP
                SELECT DECODE (felder, NULL, col.column_name, felder || ',' || col.column_name) INTO felder FROM DUAL;
            END LOOP loop_all_index_columns;

            SELECT tablespace_name
            INTO   tbs
            FROM   all_ind_partitions
            WHERE      index_owner = ind.owner
                   AND index_name = ind.index_name
                   AND partition_name = part;

            IF LENGTH (ind.index_name || '_' || part) > 30
            THEN
                objname := SUBSTR (ind.index_name || '_' || part, -30);
            ELSE
                objname := ind.index_name || '_' || part;
            END IF;

            sqlcmd := 'create index ' || ind.owner || '.' || objname || ' on ' || ind.table_owner || '.' || ind.table_name || '_' || part || ' (' || felder || ') tablespace ' || tbs;
            DBMS_OUTPUT.put_line (sqlcmd || ';');

            EXECUTE IMMEDIATE sqlcmd;
        END LOOP loop_all_indexes;

       <<loop_all_constraints>>
        FOR c0 IN (SELECT constraint_name
                   FROM   all_constraints
                   WHERE      owner = own
                          AND table_name = tbl
                          AND constraint_type = 'R')
        LOOP
            felder := NULL;
            felder2 := NULL;

            IF LENGTH (c0.constraint_name || '_' || part) > 30
            THEN
                objname := SUBSTR (c0.constraint_name || '_' || part, -30);
            ELSE
                objname := c0.constraint_name || '_' || part;
            END IF;

           <<loop_all_cons_columns>>
            FOR c1 IN (SELECT t.owner,
                              t.constraint_name,
                              t.table_name,
                              t.r_owner,
                              t.r_constraint_name,
                              c.column_name,
                              rc.column_name     AS ref_col,
                              rc.table_name      AS ref_tbl,
                              rc.owner           AS ref_own
                       FROM   all_constraints   t,
                              all_cons_columns  c,
                              all_cons_columns  rc
                       WHERE      t.owner = c.owner
                              AND t.constraint_name = c.constraint_name
                              AND t.r_owner = rc.owner
                              AND t.r_constraint_name = rc.constraint_name
                              AND c.position = rc.position
                              AND t.owner = own
                              AND t.table_name = tbl
                              AND t.constraint_name = c0.constraint_name)
            LOOP
                SELECT DECODE (felder, NULL, c1.column_name, felder || ',' || c1.column_name) INTO felder FROM DUAL;

                SELECT DECODE (felder2, NULL, c1.ref_col, felder2 || ',' || c1.ref_col) INTO felder2 FROM DUAL;

                ref_obj := c1.ref_own || '.' || c1.ref_tbl;
            END LOOP loop_all_cons_columns;

            sqlcmd := 'alter table ' || own || '.' || tbl || '_' || part || ' add constraint ' || objname || ' foreign key(' || felder || ') references ' || ref_obj || '(' || felder2 || ')';
            DBMS_OUTPUT.put_line (sqlcmd);

            EXECUTE IMMEDIATE sqlcmd;
        END LOOP loop_all_constraints;

        sqlcmd := 'alter table ' || own || '.' || tbl || ' exchange partition ' || part || ' with table ' || own || '.' || tbl || '_' || part || ' including indexes';
        DBMS_OUTPUT.put_line (sqlcmd || ';');

        EXECUTE IMMEDIATE sqlcmd;
    END partreorg;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_compile_all
    IS
        CURSOR invalid_objects IS
            SELECT   DECODE (
                         object_type,
                         'PACKAGE BODY', 'alter package ' || owner || '.' || object_name || ' compile body',
                         'alter ' || object_type || ' ' || owner || '.' || object_name || ' compile')    AS compile_sql
            FROM     all_objects               a,
                     order_object_by_dependency b
            WHERE        a.object_id = b.object_id(+)
                     AND a.status = 'INVALID'
                     -- AND    A.object_name not like 'SIS__SUBSCRIBERDATAMSISDN'
                     AND a.object_type IN ('PACKAGE BODY',
                                           'PACKAGE',
                                           'FUNCTION',
                                           'PROCEDURE',
                                           'TRIGGER',
                                           'VIEW')
            ORDER BY b.dlevel DESC,
                     a.object_type ASC,
                     a.object_name ASC;

        invalid_objects_row                     invalid_objects%ROWTYPE;
        v_cursor                                PLS_INTEGER;
        v_ddl                                   VARCHAR2 (32000);
        v_dummy                                 PLS_INTEGER;
    BEGIN
       <<loop_invalid_objects>>
        FOR invalid_objects_row IN invalid_objects
        LOOP
            BEGIN
                v_ddl := invalid_objects_row.compile_sql;
                v_cursor := DBMS_SQL.open_cursor;
                DBMS_SQL.parse (v_cursor, v_ddl, DBMS_SQL.native);
                v_dummy := DBMS_SQL.execute (v_cursor);
                DBMS_SQL.close_cursor (v_cursor);
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_SQL.close_cursor (v_cursor);
                    sys.DBMS_LOCK.sleep (10);
            END;
        END LOOP loop_invalid_objects;
    END sp_compile_all;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_ismsisdn (
        p_pac_id                                IN     VARCHAR2, -- 'ISMSISDN'   ISMSISDN Consolidation -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
        -- procedure fills up consolidation table ISMSTAT (Info Service Msisdn) with data from bdetail
        -- procedure fills up consolidation table TPMCONSOL (Third Party Msisdn) with data from bdetail
        x_tpid                                  VARCHAR2 (10);
        n_tpid                                  NUMBER;
        x_service                               VARCHAR2 (20); --  040SO
        x_billtext                              VARCHAR2 (80);

        x_msisdn                                VARCHAR2 (20);
        n_msisdn                                NUMBER;
        x_shortid                               VARCHAR2 (6);
        n_shortid                               NUMBER;
        x_keyword                               VARCHAR2 (80);
        x_consubtype                            VARCHAR2 (10);
        x_reqtype                               NUMBER;
        n_amountcu                              NUMBER (9, 4);
        n_pullinc                               NUMBER;
        n_pushinc                               NUMBER;

        CURSOR c1 (period_id IN VARCHAR2)
        IS
            SELECT /*+ FULL(BDETAIL) */
                   bd_msisdn_a,
                   NVL (con_estid, '-e-'), --  037SO
                   NVL (bd_shortid, '0'),
                   NVL (bd_keyword, '-empty-'),
                   bd_reqtype,
                   bd_amountcu,
                   bd_service,
                   NVL (bd_billtext, '-empty-'),
                   NVL (bd_tpid, '0')
            FROM   bdetail,
                   contract
            WHERE      bdetail.bd_conid = contract.con_id
                   AND bd_demo = 0
                   AND bd_mapsid = 'R'
                   AND bd_cdrtid = 'CTB-CO' --  043SO
                   AND bd_datetime >= TO_DATE (period_id, 'YYYYMM') --  032SO
                   AND bd_datetime < ADD_MONTHS (TO_DATE (period_id, 'YYYYMM'), 1) --  032SO
                                                                                  ;

        v_sep_id                                VARCHAR2 (6); -- YYYYMM                               --  029SO
    BEGIN
        -- v_sep_id := to_char(ADD_MONTHS(TRUNC(sysdate,'MONTH'),-1),'YYYYMM');     --  029SO
        v_sep_id := TO_CHAR (ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), 0), 'YYYYMM'); --  SURRENT MONTH

        recordsaffected := 0;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ISMSTAT';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE TPMCONSOL';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE TPMCONSOL_BAD'; --  029SO

        OPEN c1 (v_sep_id);

        LOOP
            FETCH c1
                INTO x_msisdn,
                     x_consubtype,
                     x_shortid,
                     x_keyword,
                     x_reqtype,
                     n_amountcu,
                     x_service,
                     x_billtext,
                     x_tpid;

            EXIT WHEN c1%NOTFOUND;

            BEGIN
                n_msisdn := TO_NUMBER (SUBSTR (pkg_bdetail_common.normalizedmsisdn (x_msisdn), 1, 16)); -- internationalize MSISDN
                n_shortid := TO_NUMBER (x_shortid); -- convert to number
                x_keyword := SUBSTR (x_keyword, 1, 30); -- truncate keyword
                x_billtext := SUBSTR (x_billtext, 1, 30); -- truncate billtext
                n_tpid := TO_NUMBER (x_tpid); -- convert to number

                IF x_reqtype IN (0,
                                 501,
                                 603)
                THEN
                    -- considered pull
                    n_pullinc := 1;
                    n_pushinc := 0;
                ELSE
                    -- everything else considered push: check later for MMS
                    n_pullinc := 0;
                    n_pushinc := 1;
                END IF;

                UPDATE ismstat
                SET    ism_pullcount = ism_pullcount + n_pullinc,
                       ism_pushcount = ism_pushcount + n_pushinc,
                       ism_amountcu = ism_amountcu + n_amountcu
                WHERE      ism_msisdn = n_msisdn
                       AND ism_consub = x_consubtype
                       AND ism_shortid = n_shortid
                       AND ism_keyword = x_keyword;

                IF SQL%ROWCOUNT = 0
                THEN -- must insert this row
                    INSERT INTO ismstat (
                                    ism_msisdn,
                                    ism_consub,
                                    ism_shortid,
                                    ism_keyword,
                                    ism_pullcount,
                                    ism_pushcount,
                                    ism_amountcu)
                    VALUES      (
                                    n_msisdn,
                                    x_consubtype,
                                    n_shortid,
                                    x_keyword,
                                    n_pullinc,
                                    n_pushinc,
                                    n_amountcu);

                    recordsaffected := recordsaffected + 1;
                END IF;

                UPDATE tpmconsol
                SET    tpmc_pullcount = tpmc_pullcount + n_pullinc,
                       tpmc_pushcount = tpmc_pushcount + n_pushinc,
                       tpmc_amountcu = tpmc_amountcu + n_amountcu
                WHERE      tpmc_msisdn = n_msisdn
                       AND tpmc_consub = x_consubtype
                       AND tpmc_tpid = n_tpid
                       AND tpmc_service = x_service
                       AND tpmc_billtext = x_billtext;

                IF SQL%ROWCOUNT = 0
                THEN -- must insert this row
                    INSERT INTO tpmconsol (
                                    tpmc_msisdn,
                                    tpmc_consub,
                                    tpmc_tpid,
                                    tpmc_service,
                                    tpmc_billtext,
                                    tpmc_pullcount,
                                    tpmc_pushcount,
                                    tpmc_amountcu,
                                    tpmc_billtext_agr --  053SO
                                                     )
                    VALUES      (
                                    n_msisdn,
                                    x_consubtype,
                                    n_tpid,
                                    x_service,
                                    x_billtext,
                                    n_pullinc,
                                    n_pushinc,
                                    n_amountcu,
                                    0 --  053SO
                                     );

                    recordsaffected := recordsaffected + 1;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    pkg_common.insert_warning (
                        'PKG_BDETAIL_INFO',
                        'SP_INSERT_ISMSTAT',
                        'Illegal values',
                        'MSISDN=' || x_msisdn || ' CONSUBTYPE=' || x_consubtype || ' TPID=' || x_tpid || ' SERVICE=' || x_service || ' SHORTID=' || x_shortid || ' KEYWORD=' || x_keyword,
                        NULL,
                        p_boh_id,
                        NULL,
                        x_shortid); --  064SO
            END;
        END LOOP;

        CLOSE c1;

        --  053SO --  029SO aggregate entries for short IDs which have too many BillTexts

        -- Mark the 'bad' entries
        UPDATE tpmconsol
        SET    tpmc_billtext_agr = 1 --  053SO
        WHERE  tpmc_service IN (SELECT isca_service
                                FROM   isc_aggregation
                                WHERE  isca_sepid = v_sep_id);

        errorcode := 0;
        returnstatus := 1;
        RETURN;
    END sp_cons_ismsisdn;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_next_period (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
    BEGIN
        sp_insert_period (TO_CHAR (ADD_MONTHS (SYSDATE, 1), 'YYYYMM'));

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
            recordsaffected := 0;
    END sp_insert_next_period;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_period (p_code IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO setperiod (
                        sep_id,
                        sep_date1,
                        sep_date2,
                        sep_lang01,
                        sep_lang02,
                        sep_lang03,
                        sep_lang04)
            (SELECT p_code                                                                                                                                   AS sep_id,
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
    END sp_insert_period;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE stats_analyzejob
    IS
        CURSOR cdonejobs IS
            SELECT   *
            FROM     sta_job
            WHERE    staj_esid = 'O'
            ORDER BY staj_datesta DESC,
                     staj_pacid DESC;

        cjobrow                                 cdonejobs%ROWTYPE;

        vtemp1                                  VARCHAR2 (50);
        vtemp2                                  VARCHAR2 (50);

        ntimesec                                NUMBER;
        ntimemin                                NUMBER;
        ntimestd                                NUMBER;
    BEGIN
        --Successfully executed (11.07.2003 13:08:55)
        --Processing started at 11.07.2003 13:08:24
        --Scheduled on 11.07.2003 13:08:21

        DELETE FROM sta_jobanalyze;

        COMMIT;

       <<loop_cdonejobs>>
        FOR cjobrow IN cdonejobs
        LOOP
            IF INSTR (cjobrow.staj_sysinfo, 'Successfully executed') <> 0
            THEN
                vtemp1 := SUBSTR (cjobrow.staj_sysinfo, 24, 19);
                vtemp2 := SUBSTR (cjobrow.staj_sysinfo, LENGTH ('Successfully executed (11.07.2003 13:08:55)') + 24, 19);

                ntimesec := (TO_DATE (vtemp1, 'DD.MM.YYYY hh24:mi:ss') - TO_DATE (vtemp2, 'DD.MM.YYYY hh24:mi:ss')) * 86400;
                ntimestd := TRUNC (ntimesec / 3600);
                ntimesec := ntimesec - (ntimestd * 3600);
                ntimemin := TRUNC (ntimesec / 60);

                ntimesec := TRUNC (ntimesec - (ntimemin * 60));

                INSERT INTO sta_jobanalyze
                VALUES      (
                                cjobrow.staj_pacid,
                                TO_DATE (vtemp2, 'DD.MM.YYYY hh24:mi:ss'),
                                TO_DATE (vtemp1, 'DD.MM.YYYY hh24:mi:ss'),
                                ntimestd,
                                ntimemin,
                                ntimesec);
            END IF;
        END LOOP loop_cdonejobs;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END stats_analyzejob;
END pkg_adhoc;
/