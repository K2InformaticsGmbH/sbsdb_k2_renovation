SET DEFINE OFF;

CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_interworking
IS
    mmssizeclasscount                       PLS_INTEGER := 0; -- 016SO -- 007SO

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION get_ac_id (
        p_ac_name                               IN VARCHAR2,
        p_adr_country                           IN VARCHAR2,
        p_acidcre                               IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_adr_id (p_adr_country IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_con_id (
        p_con_opkey                             IN VARCHAR2,
        p_ac_name                               IN VARCHAR2,
        p_adr_country                           IN VARCHAR2,
        p_acidcre                               IN VARCHAR2)
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE merge_imsirange (
        p_pac_id                                IN     VARCHAR2, -- 009SO
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE merge_numberrange (
        p_pac_id                                IN     VARCHAR2, -- 009SO
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE norm_nbr_range_level (p_level IN INTEGER);

    PROCEDURE prepare_temp_tables_imsi (
        p_pac_id                                IN     VARCHAR2, -- 009SO
        p_bioh_id                               IN     VARCHAR2,
        recordsaffected                            OUT NUMBER);

    PROCEDURE prepare_temp_tables_nbr (
        p_pac_id                                IN     VARCHAR2, -- 009SO
        p_bioh_id                               IN     VARCHAR2,
        recordsaffected                            OUT NUMBER);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_nbr_merge (
        p_pac_id                                IN     VARCHAR2, -- 'NBR_MERGE'            -- 009SO
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER, -- TODO unused parameter? (wwe)
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
        --
        -- Purpose:
        --
        -- Modification History
        -- Person       Date        Comments
        -- ---------    --------    -------------------------------------------
        -- A.Ahmed      10.10.2001  Created
        -- A.Ahmed      06.08.2003  Create two sub (private) procedures (SET_NUMBERRANGE & SET_IMSIRANGE)
        --                          to set the msisdn numberranges and imsi ranges respectively

        l_recordsaffected                       NUMBER;
        excp_nbr_ok_imsi_nok                    EXCEPTION;
        excp_nbr_nok_imsi_nok                   EXCEPTION;
    BEGIN
        -- call the procedure to SET (assign to operators) the msisdn numberranges
        merge_numberrange (p_pac_id, p_boh_id, l_recordsaffected); -- 009SO
        recordsaffected := l_recordsaffected;

        -- call the procedure to SET (assign to operators) the imsi ranges
        merge_imsirange (p_pac_id, p_boh_id, l_recordsaffected); -- 009SO
        recordsaffected := recordsaffected + l_recordsaffected;

        COMMIT;
        returnstatus := 1;
        RETURN;
    --    Exception
    --      When Others Then
    --        ErrorCode := SqlCode;
    --        ErrorMsg  := SqlErrM;
    --        ReturnStatus := 0;
    --        RecordsAffected := 0;
    --        Rollback;
    END sp_cons_nbr_merge;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_nbr_prep (
        p_pac_id                                IN     VARCHAR2, -- 'NBR_PREP' -- 009SO
        p_bioh_id                               IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER, -- TODO unused parameter? (wwe)
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
        --
        -- Purpose: To prepare the temporary tables (ALL_CC_NDC, CARRIER, NBRRANGE) to filter and
        --          bring the data to be imported in a consistent state.
        --          This Stored Proc must be called:
        --          - after calling the Stored Proc 'SP_INSERT_OPER' which fills the temporary table
        --            ALL_CC_NDC from the given Excel file (Input Converter / DDExplorer Copy&Paste)
        --          - before calling the Stored Proc 'SP_SET_NUMBERRANGE' for
        --            import (create or merge) the Telecom Operator Contracts and their Number Ranges
        --
        -- Modification History
        -- Person       Date        Comments
        -- ---------    --------    -------------------------------------------
        -- A.Ahmed      10.10.2001  Created
        -- A.Ahmed      06.08.2003  Created Imsi intermediate tables prepare routine based
        --                          on Number Ranges preparation, both called from this common procedure

        l_recordsaffected                       NUMBER;
    BEGIN
        -- Clear The Numberrange Temp Table
        DELETE FROM nbrrange;

        -- Clear The Imsi range Temp Table
        DELETE FROM irange;

        -- Clear The Carrier Table
        DELETE FROM carrier;

        -- call the internal private stored procedure to prepare intermediate tables for Number Ranges (MSISDN)
        prepare_temp_tables_nbr (p_pac_id, p_bioh_id, l_recordsaffected); -- 009SO

        -- store the number of records processed
        recordsaffected := l_recordsaffected;

        -- call the internal private stored procedure to prepare intermediate tables for Number Ranges (MSISDN)
        prepare_temp_tables_imsi (p_pac_id, p_bioh_id, l_recordsaffected); -- 009SO

        -- add the number of records processed by both the Prepare calls
        recordsaffected := recordsaffected + l_recordsaffected;

        -- Make The Intermediate Tables Contents Permanent Before Proceeding
        COMMIT;

        returnstatus := 1;

        RETURN;
    --    Exception
    --    When Others Then
    --      ErrorCode := SqlCode;
    --      ErrorMsg  := SqlErrM;
    --      RecordsAffected := 0;
    --      ReturnStatus := 0;
    --      Rollback;
    END sp_cons_nbr_prep;

    /* =========================================================================
       Look up the SMSC codes in MSISDN Number Ranges and set the Proposed
       OperatorKey values and SMSC States.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cons_smsc_propose (
        p_pac_id                                IN     VARCHAR2, -- 'SMSC_PRPS1' or 'SMSC_PRPS2'            -- 009SO -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2, -- TODO unused parameter? (wwe)
        returnstatus                            IN OUT NUMBER)
    IS
        l_rowcount                              NUMBER (10);
        l_conopkey_curr                         smsc.smsc_conopkey%TYPE;
        l_conopkey_prop                         smsc.smsc_conopkey_prop%TYPE;
        l_smsc_esid                             smsc.smsc_id%TYPE;
        l_conopkey_new                          smsc.smsc_conopkey%TYPE; -- 017SO

        CURSOR c1 IS
            SELECT   smsc_id,
                     smsc_conopkey,
                     smsc_code
            FROM     smsc
            ORDER BY smsc_code ASC;

        CURSOR c2 (a_smsc_code IN VARCHAR2)
        IS
            SELECT nbr_conopkey
            FROM   numberrange
            WHERE      nbr_code <= a_smsc_code
                   AND nbr_code LIKE SUBSTR (a_smsc_code, 1, 3) || '%'
                   AND nbr_code = SUBSTR (a_smsc_code, 1, LENGTH (nbr_code))
                   AND ROWNUM <= 1;
    BEGIN
        -- Cases (U=unknown operator opkey, T=Trash operator opkey)
        --      Assigned  Proposed      Smsc
        -- SNo  Conopkey  Conopkey      State
        -- ---- --------- ------------- -----
        --  1     xyz     xyz           D
        --  2     xyz     abc           D  -- 017SO was W
        --  3     xyz     notfound(=T)  W
        --  4     U       xyz           D  -- 017SO was S
        --  5     U       notfound(=T)  W
        --  6     T       xyz           D  -- 017SO was S
        --  7     T       notfound(=T)  D

        l_rowcount := 0;

        FOR c1_rec IN c1
        LOOP
            l_conopkey_new := NULL; -- 017SO

            -- Currently assigned Operator Key
            l_conopkey_curr := c1_rec.smsc_conopkey;

            -- look up Con Opkey in Number Range Codes for this SMSC_CODE
            OPEN c2 (c1_rec.smsc_code);

            FETCH c2 INTO l_conopkey_prop;

            IF c2%FOUND
            THEN
                -- Set the Proposed OpKey to the Opkey found and the SMSC state (for Web Module display)

                IF    (l_conopkey_curr = 0)
                   OR (l_conopkey_curr = 9999)
                THEN
                    -- CASE 4,5: New Opkey found for SMSC previously assigned to 'UknownToc' or 'TrashToc' -> Schedule the Assigment
                    l_conopkey_new := l_conopkey_prop; -- 017SO
                    l_smsc_esid := 'D'; -- 017SO was S
                ELSE
                    -- New Opkey found for SMSC previously assigned to Valid Operator-> Set the state to Warn (do not schedule the Assigment)

                    IF l_conopkey_curr = l_conopkey_prop
                    THEN
                        -- CASE 1: Proposed Opkey and previously assigned Opkey as same -> Set the SMSC State to Done
                        l_smsc_esid := 'D';
                    ELSE
                        -- CASE 2: Proposed Opkey is different than Opkey previously assigned -> Set the SMSC State to Warn (do not Schedule)
                        l_conopkey_new := l_conopkey_prop; -- 017SO
                        l_smsc_esid := 'D'; -- 017SO was W
                    END IF;
                END IF;
            ELSE
                IF l_conopkey_curr = 0
                THEN
                    -- CASE 6: New Opkey NOT found for SMSC previously assigned to 'UknownToc' -> set State to Warn, Set the Proposed Opkey to 'TrashToc'
                    l_conopkey_prop := '9999';
                    l_conopkey_new := l_conopkey_prop; -- 017SO
                    l_smsc_esid := 'W';
                ELSIF l_conopkey_curr = 9999
                THEN
                    -- CASE 7: New Opkey NOT found for SMSC previously assigned to or 'TrashToc' -> Set State to Done, Set the Proposed Opkey to 'TrashToc'
                    l_conopkey_prop := '9999';
                    l_smsc_esid := 'D';
                ELSE
                    -- CASE 3: New Opkey NOT found for SMSC previously assigned to a Valid Operator -> Schedule the Assigment, Set the Proposed Opkey to 'TrashToc'
                    l_conopkey_prop := '9999';
                    l_conopkey_new := l_conopkey_prop; -- 017SO
                    l_smsc_esid := 'W';
                END IF;
            END IF;

            IF l_conopkey_new IS NOT NULL
            THEN
                UPDATE smsc
                SET    smsc_conopkey = l_conopkey_new, -- 017SO
                       smsc_conopkey_prop = l_conopkey_prop,
                       smsc_esid = l_smsc_esid,
                       smsc_datemod = SYSDATE, -- 017SO
                       smsc_acidmod = 'ADMIN', -- 017SO
                       smsc_chngcnt = smsc_chngcnt + 1 -- 017SO
                WHERE  smsc_id = c1_rec.smsc_id;
            END IF;

            l_rowcount := l_rowcount + SQL%ROWCOUNT;

            CLOSE c2;
        END LOOP;

        recordsaffected := l_rowcount;
        errorcode := 0;
        returnstatus := 1;
        RETURN;
    --    Exception
    --
    --      When Others then
    --        ErrorCode := SqlCode;
    --        ErrorMsg  := SqlErrm;
    --        ReturnStatus := 0;
    --        RecordsAffected := 0;
    --        Return;
    END sp_cons_smsc_propose;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_ac_id (
        p_ac_name                               IN VARCHAR2,
        p_adr_country                           IN VARCHAR2,
        p_acidcre                               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        --
        -- Purpose: Return The Ac_Id Of The Given A_Ac_Name For Inserting A
        --          New Contract Record
        --
        -- Modification History
        -- Person      Date      Comments
        -- ---------   --------  -------------------------------------------
        -- Ma44        10.10.2001

        l_ac_id                                 VARCHAR2 (10);
        l_adr_id                                VARCHAR2 (10);
    BEGIN
        SELECT pkg_common.generateuniquekey ('G') INTO l_ac_id FROM DUAL;

        l_adr_id := get_adr_id (p_adr_country);

        INSERT INTO account (
                        ac_id,
                        ac_etid,
                        ac_demo,
                        ac_short, -- 004SO
                        ac_name,
                        ac_logret,
                        ac_langid,
                        ac_vat,
                        ac_currency,
                        ac_esid,
                        ac_adrid_main,
                        ac_acidcre,
                        ac_datecre,
                        ac_chngcnt)
            SELECT l_ac_id, 'TOP', 0, l_ac_id, -- 004SO
                                               p_ac_name, 0, 'de', 1, 'CHF', 'A', l_adr_id, p_acidcre, SYSDATE, 0 FROM DUAL;

        RETURN l_ac_id;
    END get_ac_id;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_adr_id (p_adr_country IN VARCHAR2)
        RETURN VARCHAR2
    IS
        --
        -- Purpose: Return The Adr_Id Of The Given A_Adr_Country For
        --          Inserting A New Account Record
        --
        -- Modification History
        -- Person      Date      Comments
        -- ---------   --------  -------------------------------------------
        -- Ma44        10.10.2001

        l_adr_id                                VARCHAR2 (10);
    BEGIN
        SELECT pkg_common.generateuniquekey ('G') INTO l_adr_id FROM DUAL;

        INSERT INTO address (
                        adr_id,
                        adr_etid,
                        adr_demo,
                        adr_esid,
                        adr_country,
                        adr_chngcnt)
            SELECT l_adr_id, 'STD', 0, 'A', p_adr_country, 0 FROM DUAL;

        RETURN l_adr_id;
    END get_adr_id;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_con_id (
        p_con_opkey                             IN VARCHAR2,
        p_ac_name                               IN VARCHAR2,
        p_adr_country                           IN VARCHAR2,
        p_acidcre                               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        --
        -- Purpose: Return The Contract Id Of An Active (or Inactive) Contract Given By
        --            The p_CON_OPKEY For
        --            Inserting Number Ranges Belonging To That Contract
        --          If contract Id is found then update the contract name
        --            with the new value of p_AC_NAME
        --          else create a new (inactive) contract
        --          An active contract takes precedence over an inactive one
        -- Modification History
        -- Person      Date      Comments
        -- ---------   --------  -------------------------------------------
        -- Ma44        10.10.2001
        -- 002SO       01.11.2001 Inert contract in inactive state

        l_con_id                                VARCHAR2 (10);
        l_ac_id                                 VARCHAR2 (10);
        l_adr_id                                VARCHAR2 (10);
        l_idx                                   PLS_INTEGER; -- 006SO

        CURSOR c1 (p_con_opkey IN VARCHAR2)
        IS
            SELECT   con_id
            FROM     contract
            WHERE        con_opkey = p_con_opkey
                     AND con_etid = 'TOC'
                     AND (   con_esid = 'A'
                          OR con_esid = 'I')
            ORDER BY con_esid ASC; -- And ROWNUM <=1;
    BEGIN
        OPEN c1 (p_con_opkey);

        FETCH c1 INTO l_con_id;

        IF c1%NOTFOUND
        THEN
            SELECT pkg_common.generateuniquekey ('G') INTO l_con_id FROM DUAL;

            l_ac_id := get_ac_id (p_ac_name, p_adr_country, p_acidcre);

            INSERT INTO contract (
                            con_id,
                            con_srctype,
                            con_etid,
                            con_acid,
                            con_name,
                            con_esid,
                            con_opkey,
                            con_acidcre,
                            con_datecre,
                            con_chngcnt,
                            con_hdgroup -- 001SO
                                       )
                SELECT l_con_id, 'OPER', 'TOC', l_ac_id, p_ac_name, 'I', p_con_opkey, p_acidcre, SYSDATE, 0, 0 FROM DUAL;

            INSERT INTO coniot (
                            ciot_id,
                            ciot_conid,
                            ciot_curid,
                            ciot_iwdid,
                            ciot_trctid)
            VALUES      (
                            pkg_common.generateuniquekey ('G'),
                            l_con_id,
                            NULL,
                            'TERM',
                            'SMS'); -- 006SO

            INSERT INTO coniot (
                            ciot_id,
                            ciot_conid,
                            ciot_curid,
                            ciot_iwdid,
                            ciot_trctid)
            VALUES      (
                            pkg_common.generateuniquekey ('G'),
                            l_con_id,
                            NULL,
                            'ORIG',
                            'SMS'); -- 006SO

            INSERT INTO coniot (
                            ciot_id,
                            ciot_conid,
                            ciot_curid,
                            ciot_iwdid,
                            ciot_trctid)
            VALUES      (
                            pkg_common.generateuniquekey ('G'),
                            l_con_id,
                            NULL,
                            'ORIG',
                            'MMS'); -- 006SO

            INSERT INTO coniote (
                            ciote_id,
                            ciote_ciotid,
                            ciote_msgsize_min,
                            ciote_msgsize_max,
                            ciote_price,
                            ciote_chngcnt)
                SELECT pkg_common.generateuniquekey ('G'),
                       ciot_id,
                       NULL,
                       NULL,
                       NULL,
                       0
                FROM   coniot
                WHERE      ciot_conid = l_con_id
                       AND ciot_iwdid = 'TERM'
                       AND ciot_trctid = 'SMS'; -- 006SO

            INSERT INTO coniote (
                            ciote_id,
                            ciote_ciotid,
                            ciote_msgsize_min,
                            ciote_msgsize_max,
                            ciote_price,
                            ciote_chngcnt)
                SELECT pkg_common.generateuniquekey ('G'),
                       ciot_id,
                       NULL,
                       NULL,
                       NULL,
                       0
                FROM   coniot
                WHERE      ciot_conid = l_con_id
                       AND ciot_iwdid = 'ORIG'
                       AND ciot_trctid = 'SMS'; -- 006SO

           <<loop_mmssizeclasscount>>
            FOR l_idx IN 1 .. mmssizeclasscount
            LOOP -- 007SO
                INSERT INTO coniote (
                                ciote_id,
                                ciote_ciotid,
                                ciote_msgsize_min,
                                ciote_msgsize_max,
                                ciote_price,
                                ciote_chngcnt)
                    SELECT pkg_common.generateuniquekey ('G'),
                           ciot_id,
                           NULL,
                           NULL,
                           NULL,
                           0
                    FROM   coniot
                    WHERE      ciot_conid = l_con_id
                           AND ciot_iwdid = 'ORIG'
                           AND ciot_trctid = 'MMS'; -- 006SO
            END LOOP loop_mmssizeclasscount;
        ELSE
            CLOSE c1;

           <<loop_c1>>
            FOR c1_rec IN c1 (p_con_opkey)
            LOOP
                UPDATE contract
                SET    con_name = p_ac_name
                WHERE  con_id = c1_rec.con_id;

                SELECT con_acid
                INTO   l_ac_id
                FROM   contract
                WHERE  con_id = c1_rec.con_id;

                UPDATE account
                SET    ac_name = p_ac_name
                WHERE  ac_id = l_ac_id;

                SELECT ac_adrid_main
                INTO   l_adr_id
                FROM   account
                WHERE  ac_id = l_ac_id;

                UPDATE address
                SET    adr_country = p_adr_country
                WHERE  adr_id = l_adr_id;
            END LOOP loop_c1;
        END IF;

        RETURN l_con_id;
    END get_con_id;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE merge_imsirange (
        p_pac_id                                IN     VARCHAR2, -- 009SO -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER)
    IS
        --
        -- Purpose:
        --
        -- Modification History
        -- Person       Date        Comments
        -- ---------    --------    -------------------------------------------
        -- A.Ahmed      06.08.2003  Created

        l_imsi_id                               VARCHAR2 (10);
        l_con_id                                VARCHAR2 (10);
        l_con_opkey                             NUMBER (10);
        l_con_opkey_other                       NUMBER (10);
        l_reccnt                                NUMBER;

        CURSOR ccarrier IS
            SELECT car_id,
                   car_country,
                   car_opname
            FROM   carrier
            WHERE      car_id IS NOT NULL
                   AND car_opname IS NOT NULL
                   AND car_id >= '0'
                   AND car_id <= '9999999999';

        CURSOR cirange (p_imsi_carid IN VARCHAR2)
        IS
            SELECT imr_mcc,
                   imr_mnc,
                   imr_country,
                   imr_opname,
                   imr_carid
            FROM   irange
            WHERE  imr_carid = p_imsi_carid;

        CURSOR cimsirange (
            p_imsi_mcc                              IN VARCHAR2,
            p_imsi_mnc                              IN VARCHAR2)
        IS
            SELECT imr_conopkey
            FROM   imsirange
            WHERE      imr_mcc = p_imsi_mcc
                   AND imr_mnc = p_imsi_mnc;
    BEGIN
        l_reccnt := 0;

       -- For Each Carrier (Operator Contract)
       <<loop_ccarrier>>
        FOR ccarrierrow IN ccarrier
        LOOP
            l_con_id := get_con_id (ccarrierrow.car_id, ccarrierrow.car_opname, ccarrierrow.car_country, 'ADMIN');
            l_con_opkey := ccarrierrow.car_id;

            -- Clear The Number Ranges Of This Operator
            DELETE FROM imsirange
            WHERE       imr_conopkey = l_con_opkey;

           -- For Each Imsi Range Belonging To This Operator
           <<loop_cirange>>
            FOR cirangerow IN cirange (ccarrierrow.car_id)
            LOOP
                -- Check If This Number Range Belong To Any Other Operator Contract
                -- If So, Then Delete Them In A Transaction
                -- Start A Transaction For The Consistency Of Number Ranges And Their Contracts
                OPEN cimsirange (cirangerow.imr_mcc, cirangerow.imr_mnc);

                FETCH cimsirange INTO l_con_opkey_other;

                IF cimsirange%FOUND
                THEN
                    DELETE FROM imsirange
                    WHERE       imr_conopkey = l_con_opkey_other;
                END IF;

                CLOSE cimsirange;

                SELECT pkg_common.generateuniquekey ('G') INTO l_imsi_id FROM DUAL;

                INSERT INTO imsirange (
                                imr_id,
                                imr_conopkey,
                                imr_mcc,
                                imr_mnc,
                                imr_acidcre,
                                imr_datecre,
                                imr_chngcnt)
                    SELECT l_imsi_id, l_con_opkey, cirangerow.imr_mcc, cirangerow.imr_mnc, 'ADMIN', SYSDATE, 0 FROM DUAL;
            END LOOP loop_cirange;

            l_reccnt := l_reccnt + 1;
        END LOOP loop_ccarrier;

        recordsaffected := l_reccnt;
        RETURN;
    END merge_imsirange;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE merge_numberrange (
        p_pac_id                                IN     VARCHAR2, -- 009SO -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER)
    IS
        --
        -- Purpose: Import (create or merge) the Telecom Operator Contracts and their Number Ranges
        --            from the Intermediate Tables (CARRIER, NBRRANGE)
        --          For each Operator Key of Operator Contract found in the CARRIER table, perform a lookup to
        --            determine the Contract Id (if contract is not found create one, else update the contract name)
        --          Clear the Number Ranges belonging to this Contract and for each of the new Number Ranges of this
        --            contract check if that Number Range belong to any other Contract. If so, clear the Number Ranges
        --            of the other Contract
        --          Return the number of Operator Contract
        --
        -- Modification History
        -- Person       Date        Comments
        -- ---------    --------    -------------------------------------------
        -- A.Ahmed      10.10.2001  Created
        -- A.Ahmed      06.08.2003  Renamed the procedure and treated as private, called by
        --                          other procedure 'SP_SET_NUMBERRANGE' also calling 'SET_IMSIRANGE'

        l_nbr_id                                VARCHAR2 (10);
        l_con_id                                VARCHAR2 (10);
        l_reccnt                                NUMBER;

        CURSOR ccarrier IS
            SELECT car_id,
                   car_country,
                   car_opname
            FROM   carrier
            WHERE      car_id IS NOT NULL
                   AND car_opname IS NOT NULL
                   AND car_id >= '0'
                   AND car_id <= '9999999999';

        CURSOR cnbrrange (p_nbr_carid IN VARCHAR2)
        IS
            SELECT nbr_code,
                   nbr_country,
                   nbr_opname,
                   nbr_carid
            FROM   nbrrange
            WHERE  nbr_carid = p_nbr_carid;

        CURSOR cnumberrange (p_nbr_code IN VARCHAR2)
        IS
            SELECT nbr_conopkey
            FROM   numberrange
            WHERE  nbr_code = p_nbr_code;

        CURSOR czoneidfromcountry (countryname IN VARCHAR2)
        IS
            SELECT znznu_znid
            FROM   zoneusage,
                   znznu
            WHERE      zoneusage.znu_code = countryname
                   AND znznu.znznu_znuid = zoneusage.znu_id; -- 008SO

        CURSOR czoneiddefault IS
            SELECT znznu_znid
            FROM   zoneusage,
                   znznu
            WHERE      zoneusage.znu_code = '%'
                   AND znznu.znznu_znuid = zoneusage.znu_id; -- 008SO

        l_zone_id                               VARCHAR2 (10); -- 008SO
    BEGIN
        l_reccnt := 0;

       -- For Each Carrier (Operator Contract)
       <<loop_ccarrier>>
        FOR ccarrierrow IN ccarrier
        LOOP
            l_con_id := get_con_id (ccarrierrow.car_id, ccarrierrow.car_opname, ccarrierrow.car_country, 'ADMIN');

            -- Clear The Number Ranges Of This Operator
            DELETE FROM numberrange
            WHERE       nbr_conopkey = ccarrierrow.car_id;

           -- For Each Number Range Belonging To This Operator
           <<loop_cnbrrange>>
            FOR cnbrrangerow IN cnbrrange (ccarrierrow.car_id)
            LOOP
                -- Check if this number range belonged to any other operator until now and delete it
                -- In case the offending code is equal or longer in length
                DELETE FROM numberrange
                WHERE       nbr_code LIKE cnbrrangerow.nbr_code || '%';

                -- In case the offending code is equal or smaller in length
                DELETE FROM numberrange
                WHERE       cnbrrangerow.nbr_code LIKE nbr_code || '%';

                SELECT pkg_common.generateuniquekey ('G') INTO l_nbr_id FROM DUAL;

                l_zone_id := NULL; -- 008SO

                IF NOT (ccarrierrow.car_country = 'SWITZERLAND')
                THEN
                    OPEN czoneidfromcountry (ccarrierrow.car_country);

                    FETCH czoneidfromcountry INTO l_zone_id;

                    IF czoneidfromcountry%NOTFOUND
                    THEN
                        OPEN czoneiddefault;

                        FETCH czoneiddefault INTO l_zone_id;

                        CLOSE czoneiddefault;
                    END IF;

                    CLOSE czoneidfromcountry;
                END IF; -- 008SO

                INSERT INTO numberrange (
                                nbr_id,
                                nbr_conopkey,
                                nbr_code,
                                nbr_acidcre,
                                nbr_datecre,
                                nbr_chngcnt,
                                nbr_pprznid -- 008SO
                                           )
                    SELECT l_nbr_id, ccarrierrow.car_id, cnbrrangerow.nbr_code, 'ADMIN', SYSDATE, 0, l_zone_id -- 008SO
                                                                                                              FROM DUAL;
            END LOOP loop_cnbrrange;

            l_reccnt := l_reccnt + 1;
        END LOOP loop_ccarrier;

        recordsaffected := l_reccnt;
        RETURN;
    END merge_numberrange;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE norm_nbr_range_level (p_level IN INTEGER)
    IS
        --
        -- Purpose: Normalizes MSISDN number range intermediate table NBRRANGE from last digit to first
        --          replacing full sets of 10 consecutive numer range codes by one with one digit less
        --          Table must be consistent before calling this reoutine (no contradicting entries on
        --          different levels or same level (number of digits)
        --          Routine may be called for levels 6 (trying to eliminate digit 7) until 1 (trying to eliminate digit 2)

        -- MODIFICATION HISTORY
        -- Person      Date         Comments
        -- SO          05.08.2003   created
        -- ---------   ------       -------------------------------------------

        CURSOR ccandidatecode (LEVEL IN INTEGER)
        IS
            SELECT   nbr_carid,
                     nbr_country,
                     nbr_opname,
                     SUBSTR (nbr_code, 1, LEVEL)     AS newcode
            FROM     nbrrange
            WHERE    LENGTH (nbr_code) = LEVEL + 1
            GROUP BY nbr_carid,
                     nbr_country,
                     nbr_opname,
                     SUBSTR (nbr_code, 1, LEVEL)
            HAVING   COUNT (*) = 10;
    BEGIN
        FOR ccandidatecoderow IN ccandidatecode (p_level)
        LOOP
            -- delete 10 numberranges
            DELETE FROM nbrrange
            WHERE           nbr_carid = ccandidatecoderow.nbr_carid
                        AND LENGTH (nbr_code) = p_level + 1
                        AND nbr_code LIKE ccandidatecoderow.newcode || '%';

            -- insert 1 normalized numberrange code instead
            INSERT INTO nbrrange (
                            nbr_code,
                            nbr_country,
                            nbr_opname,
                            nbr_carid)
            VALUES      (
                            ccandidatecoderow.newcode,
                            ccandidatecoderow.nbr_country,
                            ccandidatecoderow.nbr_opname,
                            ccandidatecoderow.nbr_carid);
        END LOOP;
    END norm_nbr_range_level;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE prepare_temp_tables_imsi (
        p_pac_id                                IN     VARCHAR2, -- 009SO -- TODO unused parameter? (wwe)
        p_bioh_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER)
    IS
    --
    -- Purpose: To prepare the temporary tables (ALL_MCC_MNC, CARRIER(only compliment earlier fill), IRANGE) to filter and
    --          bring the data to be imported in a consistent state.
    --          This Stored Proc must be called:
    --          - after calling the Stored Proc 'SP_INSERT_MCC_MNC' which fills the temporary table
    --            ALL_MCC_MNC from the given Csv file (Input Converter or DDExplorer Copy&Paste)
    --          - and before calling the Stored Proc 'SP_SET_IMSIRANGE' for
    --            import (create or merge) the Telecom Operator Contracts and their Number Ranges
    --
    -- Modification History
    -- Person       Date        Comments
    -- ---------    --------    -------------------------------------------
    -- A.Ahmed      06.05.2003  Created with name suffix _IMSI. Based on the prepare stored procedure
    --                          for preparing the Msisdn number ranges
    --

    BEGIN
        -- Remove Any Spaces In The Mcc and Mnc
        UPDATE all_mcc_mnc
        SET    amcmnc_mcc = REPLACE (amcmnc_mcc, ' ', ''),
               amcmnc_mnc = REPLACE (amcmnc_mnc, ' ', '');

        -- Get The Distinct Carrier Names (Group By) Into Intermediate Table Carrier
        -- Add only those which are not existing in the Carrier table (first inserted when NBRRANGE prepare)
        INSERT INTO carrier (
                        car_id,
                        car_country,
                        car_opname)
            SELECT   amcmnc_opkey,
                     amcmnc_country,
                     amcmnc_opname
            FROM     all_mcc_mnc
            WHERE    amcmnc_opkey NOT IN (SELECT car_id FROM carrier)
            GROUP BY amcmnc_opkey,
                     amcmnc_country,
                     amcmnc_opname;

        -- Get The IMSI Ranges Into Intermediate Table IRange
        -- If carriers share MCC+MNC codes, only the carrier with the lowest id (opkey) is taken
        -- opkey 752 is ignored (TELECOM Liechtenstein) and not transferred to th IRANGE table
        INSERT INTO irange (
                        imr_mcc,
                        imr_mnc,
                        imr_country,
                        imr_opname,
                        imr_carid)
            SELECT a1.amcmnc_mcc,
                   a1.amcmnc_mnc,
                   a1.amcmnc_country,
                   a1.amcmnc_opname,
                   a1.amcmnc_opkey
            FROM   all_mcc_mnc a1
            WHERE      a1.amcmnc_opkey <> '752'
                   AND NOT EXISTS
                           (SELECT a2.amcmnc_opkey
                            FROM   all_mcc_mnc a2
                            WHERE      a1.amcmnc_mcc = a2.amcmnc_mcc
                                   AND a1.amcmnc_mnc = a2.amcmnc_mnc
                                   AND a2.amcmnc_opkey < a1.amcmnc_opkey
                                   AND a2.amcmnc_opkey <> '752');

        -- Do not commit here, commit is performed by the calling routine
        --Commit;

        SELECT COUNT (*) INTO recordsaffected FROM irange;

        RETURN;
    END prepare_temp_tables_imsi;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE prepare_temp_tables_nbr (
        p_pac_id                                IN     VARCHAR2, -- 009SO -- TODO unused parameter? (wwe)
        p_bioh_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        recordsaffected                            OUT NUMBER)
    IS
    --
    -- Purpose: To prepare the temporary tables (ALL_CC_NDC, CARRIER, NBRRANGE) to filter and
    --          bring the data to be imported in a consistent state.
    --          This Stored Proc must be called:
    --          - after calling the Stored Proc 'SP_INSERT_OPER' which fills the temporary table
    --            ALL_CC_NDC from the given csv file (Input Converter / DDExplorer Copy&Paste)
    --          - and before calling the Stored Proc 'SP_SET_NUMBERRANGE' for
    --            import (create or merge) the Telecom Operator Contracts and their Number Ranges
    --
    -- Modification History
    -- Person       Date        Comments
    -- ---------    --------    -------------------------------------------
    -- A.Ahmed      10.10.2001  Created
    -- A.Ahmed      06.05.2003  Changed the name by suffixing _NBR. Now called from common
    --                          procedure preparing the Msisdn number ranges and Imsi ranges
    -- 001SO        14.04.2014  Remove old code for ignoring Swisscom ranges

    BEGIN
        -- Remove Any Spaces In The Number Range Code
        UPDATE all_cc_ndc
        SET    acndc_nbr = REPLACE (acndc_nbr, ' ', '');

        -- 014SO

        -- Get The Distinct Carrier Names (Group By) Into Intermediate Table Carrier
        INSERT INTO carrier (
                        car_id,
                        car_country,
                        car_opname)
            SELECT   acndc_opkey,
                     acndc_country,
                     acndc_opname
            FROM     all_cc_ndc
            WHERE    acndc_nbr <> 'CCandND'
            GROUP BY acndc_opkey,
                     acndc_country,
                     acndc_opname;

        -- Get the Number Ranges into intermediate table Nbrrange
        INSERT INTO nbrrange (
                        nbr_code,
                        nbr_country,
                        nbr_opname,
                        nbr_carid)
            SELECT DISTINCT acndc_nbr,
                            acndc_country,
                            acndc_opname,
                            acndc_opkey
            FROM   all_cc_ndc
            WHERE      acndc_nbr <> 'CCandND'
                   AND LENGTH (acndc_nbr) >= 3
                   AND pkg_common.sp_is_numeric (acndc_nbr) = 1; -- 013SO

        -- Filter Out The Number Ranges With Code Length Greater Than 7
        INSERT INTO nbrrange (
                        nbr_code,
                        nbr_country,
                        nbr_opname,
                        nbr_carid)
            SELECT   SUBSTR (nbr_code, 1, 10),
                     MIN (nbr_country),
                     MIN (nbr_opname),
                     MIN (nbr_carid)
            FROM     nbrrange
            WHERE    LENGTH (nbr_code) > 10
            GROUP BY SUBSTR (nbr_code, 1, 10);

        DELETE FROM nbrrange
        WHERE       LENGTH (nbr_code) > 10;

        -- Remove all the Number Range Codes that are overridden by smaller conflicting
        --  Number Ranges
        DELETE FROM nbrrange
        WHERE       nbr_code IN (SELECT a.nbr_code
                                 FROM   nbrrange  a,
                                        nbrrange  b
                                 WHERE      a.nbr_code <> b.nbr_code
                                        AND SUBSTR (a.nbr_code, 1, LENGTH (b.nbr_code)) = b.nbr_code);

        -- normalize number ranges from last digit to first
        norm_nbr_range_level (9);
        norm_nbr_range_level (8);
        norm_nbr_range_level (7);
        norm_nbr_range_level (6);
        norm_nbr_range_level (5);
        norm_nbr_range_level (4);
        norm_nbr_range_level (3);
        norm_nbr_range_level (2);
        norm_nbr_range_level (1);

        -- Do not commit here, commit is performed by the calling routine
        -- Commit;

        SELECT COUNT (*) INTO recordsaffected FROM nbrrange;

        RETURN;
    END prepare_temp_tables_nbr;
END pkg_interworking;
/
