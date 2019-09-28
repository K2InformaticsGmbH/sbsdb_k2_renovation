CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_mec_ic_ascii0
IS
    cfltfuturecdrtimespan                   FLOAT := 1.0; -- 065SO

    cintcreatesmscforhomeroutedsms          NUMBER := 1; -- 122SO -- 072SO

    cstrtab                                 VARCHAR2 (1) := CHR (9);

    cstrfieldseparator                      VARCHAR2 (1) := cstrtab;

    cstrmappingstatesuccess                 VARCHAR2 (1) := 'M'; -- 099SO

    -- mmsc related constants
    gcstrownmccmnc                          VARCHAR2 (10) := '22801'; -- 042SO -- MCC and MNC of the system owner (GSM operator)

    cstrcdrtypehomeroutedsms                VARCHAR2 (10) := 'SMS-HR'; -- 070SO

    cstrmecdatetimeformat                   VARCHAR2 (20) := 'YYYYMMDDHH24MISS';

    cstrmscmobileterminatingsms             VARCHAR2 (6) := 'MSC-MT';

    rsourcetype                             pkg_common.tsrctype; -- 083SO

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION addsmsccodetounknowntoc (p_smsc_code IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION extmsgreferencesuffix (
        p_logicalsegmentid                      IN NUMBER,
        p_physicalsegmentid                     IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION getsmscid (
        p_bd_sca                                IN VARCHAR2,
        p_create                                IN NUMBER)
        RETURN VARCHAR2;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_isrv (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    PROCEDURE insert_csv_m2m (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2,
        p_recordnr                              IN     NUMBER,
        p_recorddata                            IN     VARCHAR2,
        p_recordversion                         IN     VARCHAR2,
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    PROCEDURE insert_csv_mmsc (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    PROCEDURE insert_csv_msc ( -- 009AA
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    PROCEDURE insert_csv_pos ( -- 036AA
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    PROCEDURE insert_csv_smsn (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION ims_lte_cell_id (p_paniheader IN VARCHAR2)
        RETURN VARCHAR2
    IS -- 597SO
        l_pani                                  VARCHAR2 (200);
        l_dummy                                 VARCHAR2 (200); -- 666SO
        l_result                                VARCHAR2 (200); -- 666SO
    BEGIN
        l_pani := LOWER (p_paniheader);

        IF l_pani NOT LIKE '%;utran-cell-id-3gpp=%'
        THEN
            IF l_pani NOT LIKE '%;cgi-3gpp=%'
            THEN
                l_result := NULL; -- 666SO
            ELSE
                l_dummy := pkg_common.cutfirstitem (l_pani, ';cgi-3gpp=');
                l_result := pkg_common.cutfirstitem (l_pani, ';'); -- 666SO -- 642SO
            END IF;
        ELSE
            l_dummy := pkg_common.cutfirstitem (l_pani, ';utran-cell-id-3gpp=');
            l_result := pkg_common.cutfirstitem (l_pani, ';'); -- 666SO
        END IF;

        RETURN REPLACE (l_result, '"'); -- 666SO
    END ims_lte_cell_id;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION ims_wifi_mcc (p_paniheader IN VARCHAR2)
        RETURN VARCHAR2
    IS -- 597SO
        l_pani                                  VARCHAR2 (200);
        l_dummy                                 VARCHAR2 (200);
    BEGIN
        l_pani := TRIM (LOWER (p_paniheader)) || ';'; -- 612SO

        IF l_pani NOT LIKE '%;mcc=%'
        THEN
            RETURN NULL;
        ELSIF l_pani LIKE '%;mcc=228;%'
        THEN -- 600SO
            RETURN '228'; -- 600SO
        ELSE
            l_dummy := pkg_common.cutfirstitem (l_pani, ';mcc=');
            RETURN pkg_common.cutfirstitem (l_pani, ';');
        END IF;
    END ims_wifi_mcc;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION ims_wlan_node_id (p_paniheader IN VARCHAR2)
        RETURN VARCHAR2
    IS -- 597SO
        l_pani                                  VARCHAR2 (200);
        l_dummy                                 VARCHAR2 (200);
        l_result                                VARCHAR2 (200); -- 679SO
    BEGIN
        l_pani := LOWER (p_paniheader);

        IF l_pani NOT LIKE '%;i-wlan-node-id=%'
        THEN
            l_result := 'ffffffffffff'; -- 663SO
        ELSE
            l_dummy := pkg_common.cutfirstitem (l_pani, ';i-wlan-node-id=');
            l_result := NVL (pkg_common.cutfirstitem (l_pani, ';'), 'ffffffffffff'); -- 679SO-- 663SO
        END IF;

        RETURN REPLACE (l_result, '"'); -- 679SO
    END ims_wlan_node_id;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION is_roaming_pani (p_paniheader IN VARCHAR2)
        RETURN NUMBER
    IS -- 592SO
        l_pani                                  VARCHAR2 (200);
        l_cell                                  VARCHAR2 (200);
    BEGIN
        l_pani := TRIM (LOWER (p_paniheader)) || ';'; -- 612SO

        IF l_pani IS NULL
        THEN
            RETURN 0;
        ELSIF l_pani LIKE 'ieee-802.11%'
        THEN
            -- WiFi PANI
            IF l_pani NOT LIKE '%;mcc=%'
            THEN -- 593SO
                RETURN 0;
            ELSIF l_pani LIKE '%;mcc=228;%'
            THEN -- 600SO -- 593SO
                RETURN 0;
            ELSE
                RETURN 1;
            END IF;
        ELSE
            -- LTE PANI
            l_cell := ims_lte_cell_id (l_pani);

            IF l_cell IS NULL
            THEN
                RETURN 0;
            ELSIF l_cell LIKE '228%'
            THEN
                RETURN 0;
            ELSIF l_cell LIKE '29501%'
            THEN
                RETURN 0; -- 651SO
            ELSE
                RETURN 1;
            END IF;
        END IF;
    END is_roaming_pani;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION opkey_from_gt (msisdn IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR c1 IS
            SELECT /*+ INDEX(NUMBERRANGE, IDXU_NBR_CODE) */
                   nbr_conopkey
            FROM   numberrange
            WHERE      nbr_code <= msisdn
                   AND nbr_code LIKE SUBSTR (msisdn, 1, 3) || '%'
                   AND nbr_code = SUBSTR (msisdn, 1, LENGTH (nbr_code))
                   AND ROWNUM <= 1;

        l_retval                                VARCHAR2 (100);
    BEGIN
        OPEN c1;

        FETCH c1 INTO l_retval;

        CLOSE c1;

        RETURN l_retval;
    END opkey_from_gt;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_csv (
        p_bihid                                 IN     VARCHAR2,
        p_batchsize                             IN     INTEGER,
        p_maxage                                IN     NUMBER, -- TODO unused parameter? (wwe)
        p_dataheader                            IN     VARCHAR2,
        p_recordnr                              IN     arrrecnr,
        p_recorddata                            IN     arrrecdata,
        p_reccount                              IN OUT NUMBER,
        p_preparseerrcount                      IN OUT NUMBER, -- TODO unused parameter? (wwe)
        p_errcount                              IN OUT NUMBER,
        p_datefc                                IN OUT VARCHAR2,
        p_datelc                                IN OUT VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
        l_srctype                               VARCHAR2 (10); -- 076SO

        l_inserted                              NUMBER; -- 143SO
        l_datetime                              VARCHAR2 (20);
        l_softerrorcount                        NUMBER; -- 152SO
        l_softerrorid                           VARCHAR2 (10);
        l_softerrdesc                           VARCHAR2 (2000);

        l_recordindex                           PLS_INTEGER;
        l_record_version                        VARCHAR2 (20); -- 011SO
    BEGIN
        l_srctype := pkg_common_mapping.getsrctypeforbiheader (p_bihid); -- 085SO -- 083SO  -- 076SO

        l_record_version := pkg_common.getrequiredheaderfield (p_dataheader, 'VERSION'); -- 097SO -- 091SO -- 011SO (may later be extracted from the header)

        FOR i IN 1 .. p_batchsize
        LOOP
            l_recordindex := i;

            -- 100SO L(l_SrcType,'l_SrcType');
            -- 100SO L(p_DataHeader,'p_DataHeader');
            -- 100SO L(l_record_version,'l_record_version');
            -- 100SO L(p_RecordNr(I),'p_RecordNr(I)');
            -- 100SO L(p_RecordData(I),'p_RecordData(I)');

            IF l_srctype = rsourcetype.msc
            THEN
                insert_csv_msc (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_datetime,
                    l_softerrorcount,
                    l_softerrorid,
                    l_softerrdesc); -- 152SO -- 143SO -- 089SO
            ELSIF l_srctype = rsourcetype.m2m
            THEN
                insert_csv_m2m (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_datetime,
                    l_softerrorcount,
                    l_softerrorid,
                    l_softerrdesc); -- 152SO -- 143SO -- 112SO
            ELSIF l_srctype = rsourcetype.mmsc
            THEN
                insert_csv_mmsc (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_datetime,
                    l_softerrorcount,
                    l_softerrorid,
                    l_softerrdesc); -- 152SO -- 143SO -- 089SO
            ELSIF l_srctype = rsourcetype.isrv
            THEN
                insert_csv_isrv (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_datetime,
                    l_softerrorcount,
                    l_softerrorid,
                    l_softerrdesc); -- 152SO -- 143SO -- 089SO
            ELSIF l_srctype = rsourcetype.smsn
            THEN -- 124SO
                insert_csv_smsn (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_datetime,
                    l_softerrorcount,
                    l_softerrorid,
                    l_softerrdesc); -- 152SO -- 143SO
            ELSIF l_srctype IN (rsourcetype.pos,
                                rsourcetype.stan)
            THEN -- 058SO -- 036AA
                insert_csv_pos (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_datetime,
                    l_softerrorcount,
                    l_softerrorid,
                    l_softerrdesc); -- 152SO -- 143SO -- 089SO
            END IF;

            -- do the record counting
            p_reccount := p_reccount + l_inserted; -- 143SO
            p_errcount := p_errcount + l_softerrorcount; -- 152SO -- 099SO

            -- set first and last datetime of record
            IF     (l_datetime IS NOT NULL)
               AND (l_datetime < p_datefc)
            THEN
                p_datefc := l_datetime;
            END IF;

            IF     (l_datetime IS NOT NULL)
               AND (l_datetime > p_datelc)
            THEN
                p_datelc := l_datetime;
            END IF;

            -- soft error logging
            IF NOT (l_softerrorid IS NULL)
            THEN
                pkg_common.insert_warning ( -- 007SO
                    'PKG_MEC_IC_ASCII0',
                    'SP_INSERT_CSV',
                    'INSERT_CSV_' || l_srctype,
                    l_softerrdesc || ' *** ' || p_recorddata (i),
                    p_bihid,
                    NULL,
                    NULL,
                    NULL,
                    l_softerrorid -- 008SO
                                 );
            END IF;
        END LOOP;

        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    EXCEPTION
        WHEN pkg_common.excp_missing_header_fld
        THEN -- 097SO
            p_errorcode := pkg_common.eno_missing_header_fld;
            p_errordesc := pkg_common.edesc_missing_header_fld || ': VERSION in *** ' || p_dataheader;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errordesc := pkg_common.getharderrordesc; -- 095SO
            p_returnstatus := pkg_common.return_status_failure;
            -- hard error logging                                                   -- 005SO
            pkg_common.insert_warning ( -- 007SO
                'PKG_MEC_IC_CSV',
                'SP_INSERT_CSV',
                'INSERT_CSV_' || l_srctype,
                p_errordesc || ' *** ' || p_recorddata (l_recordindex), -- 095SO
                p_bihid -- 008SO
                       );
            RETURN;
    END sp_insert_csv;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header (
        p_bih_id                                IN OUT VARCHAR2,
        p_bih_demo                              IN     NUMBER,
        p_bih_fileseq                           IN     NUMBER,
        p_bih_filename                          IN     VARCHAR2,
        p_bih_filedate                          IN     VARCHAR2,
        p_bih_mapid                             IN     VARCHAR2,
        p_appname                               IN     VARCHAR2,
        p_appver                                IN     VARCHAR2,
        p_thread                                IN     VARCHAR2,
        p_jobid                                 IN     NUMBER,
        p_hostname                              IN     VARCHAR2,
        p_status                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS -- 075SO
    BEGIN
        pkg_common_mapping.insert_biheader ( -- 085SO -- 083SO -- 082SO
            p_bih_id,
            p_bih_demo,
            p_bih_fileseq,
            p_bih_filename,
            p_bih_filedate,
            p_bih_mapid,
            p_appname,
            p_appver,
            p_thread,
            p_jobid,
            p_hostname,
            p_status);

        p_returnstatus := pkg_common.return_status_ok;
    EXCEPTION
        WHEN pkg_common.excp_rdy_err_header_found
        THEN
            p_errorcode := pkg_common.eno_rdy_err_header_found;
            p_errordesc := pkg_common.edesc_rdy_err_header_found;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_rdy_err_many_retries
        THEN
            p_errorcode := pkg_common.eno_rdy_err_many_retries;
            p_errordesc := pkg_common.edesc_rdy_err_many_retries;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_inconvenient_time
        THEN
            p_errorcode := pkg_common.eno_inconvenient_time;
            p_errordesc := pkg_common.edesc_inconvenient_time;
            p_returnstatus := pkg_common.return_status_suspended;
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errordesc := pkg_common.getharderrordesc; -- 095SO
            p_returnstatus := pkg_common.return_status_failure;
    END sp_insert_header;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_update_header (
        p_bihid                                 IN     VARCHAR2,
        p_maxage                                IN     NUMBER,
        p_dataheader                            IN     VARCHAR2, -- 012SO
        p_reccount                              IN     NUMBER,
        p_preparseerrcount                      IN     NUMBER,
        p_errcount                              IN     NUMBER,
        p_datefc                                IN     VARCHAR2,
        p_datelc                                IN     VARCHAR2,
        p_errorcode                                OUT NUMBER,
        p_errordesc                                OUT VARCHAR2,
        p_returnstatus                             OUT NUMBER)
    IS
        l_srctype                               VARCHAR2 (10);
        l_headerstate                           VARCHAR2 (10);
        l_hihid                                 VARCHAR2 (10);

        l_successcount                          NUMBER := 0; -- 043SO
        l_warehouse_sync_state                  VARCHAR2 (1);
        l_reva_sync_state                       VARCHAR2 (1);
        l_tariffmcount                          NUMBER (10) := 0; -- 061SO mVoting CDR count
    BEGIN
        l_srctype := pkg_common_mapping.getsrctypeforbiheader (p_bihid); -- 009SO

        l_hihid := pkg_common.getrequiredheaderfield (p_dataheader, 'HIHID'); -- 097SO                         -- 090SO

        IF l_srctype = rsourcetype.msc
        THEN
            UPDATE /*+ INDEX(BDETAIL4 IDX_BD_BIHID4) */
                   bdetail4
            SET    bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            l_successcount := SQL%ROWCOUNT; -- 043SO (replacing another select)
        ELSIF l_srctype = rsourcetype.m2m
        THEN -- 112SO
            UPDATE /*+ INDEX(BDETAIL7 IDX_BD_BIHID7) */
                   bdetail7
            SET    bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan;

            l_successcount := SQL%ROWCOUNT;
        ELSIF l_srctype = rsourcetype.mmsc
        THEN
            UPDATE /*+ INDEX(BDETAIL6 IDX_BD_BIHID6) */
                   bdetail6
            SET    bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            l_successcount := SQL%ROWCOUNT; -- 043SO (replacing another select)
        ELSIF l_srctype IN (rsourcetype.isrv)
        THEN
            UPDATE /*+ INDEX(BDETAIL IDX_BD_BIHID) */
                   bdetail
            SET    bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            l_successcount := SQL%ROWCOUNT; -- 043SO (replacing another select)
        ELSIF l_srctype IN (rsourcetype.smsc,
                            rsourcetype.smsn)
        THEN -- 127SO
            SELECT /*+ INDEX(BDETAIL1 IDX_BD_BIHID1) */
                   SUM (DECODE (bd_tarid, 'M', 1, 0)) -- 061SO
            INTO   l_tariffmcount -- 061SO
            FROM   bdetail1
            WHERE      bd_bihid = p_bihid
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            UPDATE /*+ INDEX(BDETAIL1 IDX_BD_BIHID1) */
                   bdetail1
            SET    bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            l_successcount := SQL%ROWCOUNT; -- 043SO (replacing another select)

            UPDATE /*+ INDEX(BDETAIL2 IDX_BD_BIHID2) */
                   bdetail2
            SET -- 013AA
                   bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            l_successcount := l_successcount + SQL%ROWCOUNT; -- 043SO added
        ELSIF l_srctype IN (rsourcetype.pos,
                            rsourcetype.stan)
        THEN -- 058SO -- 036AA
            UPDATE /*+ INDEX(BDETAIL9 IDX_BD_BIHID9) */
                   bdetail9
            SET    bd_mapsid = 'R'
            WHERE      bd_bihid = p_bihid
                   AND bd_mapsid = 'M'
                   AND bd_datetime > SYSDATE - p_maxage
                   AND bd_datetime < SYSDATE + cfltfuturecdrtimespan; -- 065SO

            l_successcount := SQL%ROWCOUNT; -- 043SO (replacing another select)
        END IF;

        -- Update the given Biheader Id with the information supplied
        IF p_errcount + p_preparseerrcount = 0
        THEN
            l_headerstate := 'RDY'; -- no soft errors encounterd
        ELSE
            l_headerstate := 'ERR'; -- soft or pre-parse-errors encounterd
        END IF;

        IF l_successcount + p_errcount <> p_reccount
        THEN
            -- we lost CDRs (e.g. by time MaxAge clipping) and must reject the file at this stage
            ROLLBACK;
            RAISE pkg_common.excp_reccount_mismatch; -- 096SO
        ELSE
            -- this file will be accepted.                                          -- 149SO
            p_returnstatus := pkg_common.return_status_ok;

            IF l_srctype IN (rsourcetype.mmsc,
                             rsourcetype.isrv,
                             rsourcetype.smsn,
                             rsourcetype.msc)
            THEN -- 150SO
                l_reva_sync_state := 'S';
            END IF;
        END IF;

        UPDATE biheader
        SET    bih_esid = l_headerstate,
               bih_datefc = TO_DATE (p_datefc, cstrmecdatetimeformat), -- 094DA
               bih_datelc = TO_DATE (p_datelc, cstrmecdatetimeformat), -- 094DA
               bih_reccount = p_reccount,
               bih_errcount = p_errcount + p_preparseerrcount,
               bih_end = SYSDATE,
               bih_hihid = l_hihid,
               bih_whsyncsid = l_warehouse_sync_state,
               bih_revasid = l_reva_sync_state,
               bih_indexsid = DECODE (bih_srctype, 'MMSC', 'S', NULL) -- 101SO
        WHERE  bih_id = p_bihid;

        UPDATE mapping
        SET    map_datedone = SYSDATE -- 098SO
        WHERE  map_id IN (SELECT bih_mapid
                          FROM   biheader
                          WHERE  bih_id = p_bihid);

        RETURN;
    EXCEPTION
        WHEN pkg_common.excp_missing_header_fld
        THEN -- 097SO
            p_errorcode := pkg_common.eno_missing_header_fld;
            p_errordesc := pkg_common.edesc_missing_header_fld || ': HIHID in *** ' || p_dataheader;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_reccount_mismatch
        THEN -- 096SO
            p_errorcode := pkg_common.eno_reccount_mismatch;
            p_errordesc := pkg_common.edesc_reccount_mismatch || ' (' || l_successcount || '+' || p_errcount || '<>' || p_reccount || ')';
            p_returnstatus := pkg_common.return_status_failure;
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errordesc := pkg_common.getharderrordesc; -- 095SO
            p_returnstatus := pkg_common.return_status_failure;
            RETURN;
    END sp_update_header;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION addsmsccodetounknowntoc (p_smsc_code IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_smsc_id                               VARCHAR2 (10);
        l_con_opkey                             VARCHAR2 (10); -- 138SO
    BEGIN
        l_con_opkey := NVL (opkey_from_gt (p_smsc_code), '0'); -- 138SO

        SELECT generateuniquekey ('G') INTO l_smsc_id FROM DUAL;

        INSERT INTO smsc (
                        smsc_id,
                        smsc_conopkey,
                        smsc_code,
                        smsc_datecre,
                        smsc_acidcre,
                        smsc_chngcnt)
        VALUES      (
            l_smsc_id,
            l_con_opkey, -- 138SO
            p_smsc_code,
            SYSDATE,
            'ADMIN',
            0);

        RETURN l_smsc_id;
    END addsmsccodetounknowntoc;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION extmsgreferencesuffix (
        p_logicalsegmentid                      IN NUMBER,
        p_physicalsegmentid                     IN NUMBER)
        RETURN VARCHAR2
    IS -- 142SO
    BEGIN
        IF p_logicalsegmentid = 0
        THEN
            RETURN 'E' || TO_CHAR (p_physicalsegmentid, '000');
        ELSE
            RETURN NULL;
        END IF;
    END extmsgreferencesuffix;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getsmscid (
        p_bd_sca                                IN VARCHAR2,
        p_create                                IN NUMBER)
        RETURN VARCHAR2
    IS
        l_smsc_code                             VARCHAR2 (20);
        l_smsc_id                               VARCHAR2 (10);

        CURSOR c1 (a_smsc_code IN VARCHAR2)
        IS
            SELECT smsc_id
            FROM   smsc
            WHERE  smsc_code = a_smsc_code;
    BEGIN
        l_smsc_code := p_bd_sca;

        OPEN c1 (l_smsc_code);

        FETCH c1 INTO l_smsc_id;

        IF c1%FOUND
        THEN
            -- Smsc Id for given Code found, do nothing, just return the Smsc Id
            NULL;
        ELSIF p_create = 1
        THEN -- 072SO
            -- Smsc Id for given Code not found, do something, add the given Code
            -- to the dummy Operator Contract 'UNKNOWNTOC'. And then return the
            -- Smsc Id of the newly added Smsc Code
            l_smsc_id := addsmsccodetounknowntoc (l_smsc_code);
        END IF;

        CLOSE c1;

        RETURN l_smsc_id;
    END getsmscid;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_isrv (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO -- TODO unused parameter? (wwe)
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS -- 086SO
        l_recorddata                            VARCHAR2 (4000);
        ocdrinfo0                               pkg_mec_hb.tcdrinfo; -- 008AA(020SO)   -- untouched empty copy of the structure
        ocdrinfo                                pkg_mec_hb.tcdrinfo; -- 008AA(020SO)   -- working copy of the structure

        l_mimetypesize                          VARCHAR2 (2000);
    BEGIN
        p_inserted := 1; -- 143SO
        p_datetime := NULL;
        p_softerrorcount := 0; -- 152SO
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- get the Ascii0 value containing the tap-separated data
        l_recorddata := p_recorddata;
        -- use the PKG_MEC CdrInfo structure to store the read in values
        -- clear the structure for every data row
        ocdrinfo := ocdrinfo0;
        -- split the values and assign to the CdrInfo structure one by one, what is needed for this bdetail table -- 008AA(020SO)
        ocdrinfo.mappingstateid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 096SO
        ocdrinfo.requesttime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.origaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- chargeable party
        ocdrinfo.recipaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- receiver of the content
        ocdrinfo.origimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.service := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.lang := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.msgstatus := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.thirdpartyid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.subscriptiontype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.shortid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.vascontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.contractsubtype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.vaspricemodelversionid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.prepaid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.amountcustomer := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.revenuesharemobile := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.revenueshareprovider := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.billrate := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.ratingzoneid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.billingdomain := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.transportmedium := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.cdrtypeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.seglength := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.billingtime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.transportclass := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.transportcost := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.interworkingcontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.foreignrecipient := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.interworkingcase := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.requestitemtext := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.billtext := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.requesttype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.requestid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.nodename := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.network := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.location := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.requestitem := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.info := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.messageid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        l_mimetypesize := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- stored in BDITEM table
        ocdrinfo.category := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 046SO
        ocdrinfo.taxrate := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 046SO
        ocdrinfo.testmode := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 046SO
        ocdrinfo.errorid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.billingdetailid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.aaatopstopupdated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.cdrbilled := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.cdrrated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.packingidhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.outputhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.schedule1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.schedule2 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.schedule3 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        ocdrinfo.transportcount := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 056SO
        ocdrinfo.origsubmittime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 062SO
        ocdrinfo.onlinecharge := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 067AT
        ocdrinfo.gart := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 103SO
        ocdrinfo.show := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 104SO
        ocdrinfo.campaign := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 104SO

        p_datetime := ocdrinfo.requesttime;

        INSERT INTO bdetail (
                        bd_id,
                        bd_srctype,
                        bd_demo,
                        bd_bihid,
                        bd_birecno,
                        bd_msisdn_a,
                        bd_datetime,
                        bd_service,
                        bd_keyword,
                        bd_billtext,
                        bd_langid,
                        bd_reqtype,
                        bd_requestid,
                        bd_nodename,
                        bd_status,
                        bd_tpid,
                        bd_network,
                        bd_stype,
                        bd_mapsid,
                        bd_conid,
                        bd_constid, -- 051SO
                        bd_shortid,
                        bd_pmvid,
                        bd_prepaid,
                        bd_amountcu,
                        bd_retsharemo,
                        bd_retsharepv,
                        bd_location,
                        bd_itemno,
                        bd_imsi,
                        bd_billrate,
                        bd_info,
                        bd_msisdn_b,
                        bd_length,
                        bd_billtime,
                        bd_msgid,
                        bd_trclass,
                        bd_amounttr,
                        bd_znid, -- 018SO
                        bd_billingdomain, -- 040AA
                        bd_transportmedium, -- 040AA
                        bd_cdrtid,
                        bd_tocid,
                        bd_int,
                        bd_iw,
                        bd_category, -- 046SO
                        bd_taxrate, -- 046SO
                        bd_testmode, -- 046SO
                        bd_errid,
                        bd_aaats,
                        bd_billed,
                        bd_rated,
                        bd_pacidhb,
                        bd_outputhb,
                        bd_pacsid1,
                        bd_pacsid2,
                        bd_pacsid3,
                        bd_counttr, -- 056SO
                        bd_origsubmit, -- 062SO
                        bd_onlinecharge, -- 067AT
                        bd_gart, -- 103SO
                        bd_show, -- 104SO
                        bd_campaign, -- 104SO
                        bd_signature -- 146SO
                                    )
            VALUES      (
                ocdrinfo.billingdetailid,
                p_srctype,
                0,
                p_bihid,
                p_recordnr,
                ocdrinfo.origaddress,
                TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat),
                ocdrinfo.service,
                ocdrinfo.requestitemtext,
                ocdrinfo.billtext,
                ocdrinfo.lang,
                ocdrinfo.requesttype,
                ocdrinfo.requestid,
                ocdrinfo.nodename,
                ocdrinfo.msgstatus,
                ocdrinfo.thirdpartyid,
                ocdrinfo.network,
                ocdrinfo.subscriptiontype,
                ocdrinfo.mappingstateid,
                ocdrinfo.vascontractid,
                ocdrinfo.contractsubtype, -- 051SO
                ocdrinfo.shortid,
                ocdrinfo.vaspricemodelversionid,
                ocdrinfo.prepaid,
                ocdrinfo.amountcustomer,
                ocdrinfo.revenuesharemobile,
                ocdrinfo.revenueshareprovider,
                ocdrinfo.location,
                ocdrinfo.requestitem,
                ocdrinfo.imsi,
                ocdrinfo.billrate,
                ocdrinfo.info,
                ocdrinfo.recipaddress,
                ocdrinfo.seglength,
                TO_DATE (ocdrinfo.billingtime, cstrmecdatetimeformat),
                ocdrinfo.messageid,
                ocdrinfo.transportclass,
                ocdrinfo.transportcost,
                ocdrinfo.ratingzoneid, -- 018SO
                ocdrinfo.billingdomain, -- 040AA
                ocdrinfo.transportmedium, -- 040AA
                ocdrinfo.cdrtypeid,
                ocdrinfo.interworkingcontractid,
                ocdrinfo.foreignrecipient,
                ocdrinfo.interworkingcase,
                ocdrinfo.category, -- 046SO
                ocdrinfo.taxrate, -- 046SO
                ocdrinfo.testmode, -- 046SO
                ocdrinfo.errorid,
                ocdrinfo.aaatopstopupdated,
                ocdrinfo.cdrbilled,
                ocdrinfo.cdrrated,
                ocdrinfo.packingidhb,
                ocdrinfo.outputhb,
                ocdrinfo.schedule1,
                ocdrinfo.schedule2,
                ocdrinfo.schedule3,
                ocdrinfo.transportcount, -- 056SO
                TO_DATE (ocdrinfo.origsubmittime, cstrmecdatetimeformat), -- 062SO
                ocdrinfo.onlinecharge, -- 067AT
                ocdrinfo.gart, -- 103SO
                ocdrinfo.show, -- 104SO
                ocdrinfo.campaign -- 104SO
                                 -- BD_SIGNATURE                                                         -- 146SO
                                 -- 01: ZERO    0=zero charged, 1=nonzero charged
                                 -- 02: BILLED  1=billed, 0=not billed, 2=uninitialized
                                 -- 03: MAPSID  E=Error, M=Mapping
                                 -- 04: MSISDN  T=TFL(42377..), S=others(Swisscom)
                                 -- 05: PREPAID Y=yes, N=no, U=unknown
                                 -- 06: RESERVED '-'=unused
                                 -- 07: RESERVED '-'=unused
                                 -- 08: RESERVED '-'=unused
                                 ,
                   DECODE (ocdrinfo.amountcustomer, 0.0, '0', '1')
                || ocdrinfo.cdrbilled
                || ocdrinfo.mappingstateid
                || DECODE (SUBSTR (ocdrinfo.origaddress, 1, 5), '42377', 'T', 'S')
                || ocdrinfo.prepaid -- 146SO
                || '-' -- 147SO
                || '-' -- 147SO
                || '-' -- 147SO
                      );

        IF     p_softerrorid IS NULL
           AND ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorid := ocdrinfo.errorid; -- first error only !
        END IF;

        IF ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorcount := p_softerrorcount + 1; -- 152SO
        END IF;

        RETURN;
    END insert_csv_isrv;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_m2m (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER,
        p_recorddata                            IN     VARCHAR2,
        p_recordversion                         IN     VARCHAR2,
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS
        -- 112SO
        l_recorddata                            VARCHAR2 (4000);
        ocdrinfo0                               pkg_mec_hb.tcdrinfo; -- untouched empty copy of the structure
        ocdrinfo                                pkg_mec_hb.tcdrinfo; -- working copy of the structure
    BEGIN
        p_inserted := 1; -- 143SO
        p_datetime := NULL;
        p_softerrorcount := 0; -- 152SO
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        l_recorddata := p_recorddata; -- get the Ascii0 value containing the tab-separated data
        ocdrinfo := ocdrinfo0; -- clear the structure for every data row

        IF p_recordversion >= pkg_mec_hb.cascii0versionm2m_01_00_02
        THEN
            ocdrinfo.mappingstateid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_MAPSID
            ocdrinfo.msgreference := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_MESSAGEREFERENCE
            ocdrinfo.origimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_ORIGINATORIMSI
            ocdrinfo.origaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_MSISDN_A
            ocdrinfo.origgti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_OGTI
            ocdrinfo.requestitem := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_RECEIPTREQ
            ocdrinfo.delivergti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_DGTI
            ocdrinfo.deliverimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_IMSI
            ocdrinfo.recipaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_MSISDN_B
            ocdrinfo.seglength := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_LENGTH
            ocdrinfo.requesttime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_DATESUBMIT
            ocdrinfo.msgstatus := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_STATUS
            ocdrinfo.datetime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_DATETIME
            ocdrinfo.attempts := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_ATTEMPTS
            ocdrinfo.sinkname := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_SINKNAME
            ocdrinfo.sinktype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_SINKTYPE
            ocdrinfo.srcname := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_SOURCENAME
            ocdrinfo.srctype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_SOURCETYPE
            ocdrinfo.messagetype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_MSGTYPE
            ocdrinfo.errorparameter := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_ERRORPARAM
            ocdrinfo.billingdetailid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_ID
            ocdrinfo.cdrtypeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_CDRTID
            ocdrinfo.shortid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_SHORTID
            ocdrinfo.vascontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_CONID
            ocdrinfo.tariffid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_TARID
            ocdrinfo.interworkingcontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_TOCID
            ocdrinfo.foreignrecipient := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_INT
            ocdrinfo.interworkingcase := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_IW
            ocdrinfo.errorid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_ERRID
            ocdrinfo.schedule1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_PACSID1
            ocdrinfo.schedule2 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_PACSID2
            ocdrinfo.schedule3 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- BD_PACSID3
            ocdrinfo.scaopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 118SO
            ocdrinfo.origgtiopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.deliveropkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.delivergtiopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.interworkingamount := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingapmn := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingcurrency := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingdirection := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingscenario := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingstate := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.delivermapgti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 153SO
        END IF;

        p_datetime := ocdrinfo.datetime;

        INSERT INTO bdetail7 (
                        bd_id,
                        bd_srctype,
                        bd_demo,
                        bd_bihid,
                        bd_mapsid,
                        bd_birecno,
                        bd_messagereference,
                        bd_originatorimsi,
                        bd_msisdn_a,
                        bd_ogti,
                        bd_receiptreq,
                        bd_dgti,
                        bd_imsi,
                        bd_msisdn_b,
                        bd_length,
                        bd_datesubmit,
                        bd_status,
                        bd_datetime,
                        bd_attempts,
                        bd_sinkname,
                        bd_sinktype,
                        bd_sourcename,
                        bd_sourcetype,
                        bd_msgtype,
                        bd_errorparam,
                        bd_cdrtid,
                        bd_shortid,
                        bd_conid,
                        bd_tarid,
                        bd_tocid,
                        bd_int,
                        bd_iw,
                        bd_errid,
                        bd_pacsid1,
                        bd_pacsid2,
                        bd_pacsid3,
                        bd_sca_opkey -- 118SO
                                    ,
                        bd_ogti_opkey -- 117SO
                                     ,
                        bd_deliver_opkey -- 117SO
                                        ,
                        bd_dgti_opkey -- 117SO
                                     ,
                        bd_iw_amount -- 128SO
                                    ,
                        bd_iw_apmn -- 128SO
                                  ,
                        bd_iw_curid -- 128SO
                                   ,
                        bd_iw_dir -- 128SO
                                 ,
                        bd_iw_scenario -- 128SO
                                      ,
                        bd_iw_constate -- 128SO
                                      ,
                        bd_deliver_map_gti -- 153SO
                                          )
        VALUES      (
            ocdrinfo.billingdetailid,
            p_srctype,
            0,
            p_bihid,
            ocdrinfo.mappingstateid -- BD_MAPSID
                                   ,
            p_recordnr -- BD_BIRECNO
                      ,
            ocdrinfo.msgreference -- BD_MESSAGEREFERENCE
                                 ,
            ocdrinfo.origimsi -- BD_ORIGINATORIMSI
                             ,
            ocdrinfo.origaddress -- BD_MSISDN_A
                                ,
            ocdrinfo.origgti -- BD_OGTI
                            ,
            ocdrinfo.requestitem -- BD_RECEIPTREQ
                                ,
            ocdrinfo.delivergti -- BD_DGTI
                               ,
            ocdrinfo.deliverimsi -- BD_IMSI
                                ,
            ocdrinfo.recipaddress -- BD_MSISDN_B
                                 ,
            ocdrinfo.seglength -- BD_LENGTH
                              ,
            TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat) -- BD_DATESUBMIT
                                                                 ,
            ocdrinfo.msgstatus -- BD_STATUS
                              ,
            TO_DATE (ocdrinfo.datetime, cstrmecdatetimeformat) -- BD_DATETIME
                                                              ,
            ocdrinfo.attempts -- BD_ATTEMPTS
                             ,
            ocdrinfo.sinkname -- BD_SINKNAME
                             ,
            ocdrinfo.sinktype -- BD_SINKTYPE
                             ,
            ocdrinfo.srcname -- BD_SOURCENAME
                            ,
            ocdrinfo.srctype -- BD_SOURCETYPE
                            ,
            ocdrinfo.messagetype -- BD_MSGTYPE
                                ,
            ocdrinfo.errorparameter -- BD_ERRORPARAM
                                   ,
            ocdrinfo.cdrtypeid -- BD_CDRTID
                              ,
            ocdrinfo.shortid -- BD_SHORTID
                            ,
            ocdrinfo.vascontractid -- BD_CONID
                                  ,
            ocdrinfo.tariffid -- BD_TARID
                             ,
            ocdrinfo.interworkingcontractid -- BD_TOCID
                                           ,
            ocdrinfo.foreignrecipient -- BD_INT
                                     ,
            ocdrinfo.interworkingcase -- BD_IW
                                     ,
            ocdrinfo.errorid -- BD_ERRID
                            ,
            ocdrinfo.schedule1 -- BD_PACSID1
                              ,
            ocdrinfo.schedule2 -- BD_PACSID2
                              ,
            ocdrinfo.schedule3 -- BD_PACSID3
                              ,
            ocdrinfo.scaopkey -- BD_SCA_OPKEY     -- 118SO
                             ,
            ocdrinfo.origgtiopkey -- BD_OGTI_OPKEY    -- 117SO
                                 ,
            ocdrinfo.deliveropkey -- BD_DELIVER_OPKEY -- 117SO
                                 ,
            ocdrinfo.delivergtiopkey -- BD_DGTI_OPKEY    -- 117SO
                                    ,
            ocdrinfo.interworkingamount -- 'BD_IW_AMOUNT'   -- 128SO
                                       ,
            ocdrinfo.interworkingapmn -- 'BD_IW_APMN'     -- 128SO
                                     ,
            ocdrinfo.interworkingcurrency -- 'BD_IW_CURID'    -- 128SO
                                         ,
            ocdrinfo.interworkingdirection -- 'BD_IW_DIR'      -- 128SO
                                          ,
            ocdrinfo.interworkingscenario -- 'BD_IW_SCENARIO' -- 128SO
                                         ,
            ocdrinfo.interworkingstate -- 'BD_IW_CONSTATE' -- 128SO
                                      ,
            ocdrinfo.delivermapgti -- 'BD_DELIVER_MAP_GTI' -- 153SO
                                  );

        IF     p_softerrorid IS NULL
           AND ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorid := ocdrinfo.errorid; -- first error only !
        END IF;

        IF ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorcount := p_softerrorcount + 1; -- 152SO
        END IF;

        RETURN;
    END insert_csv_m2m;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_mmsc (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS
        l_recorddata                            VARCHAR2 (4000);
        ocdrinfo0                               pkg_mec_hb.tcdrinfo; -- 037SO-- untouched empty copy of the structure
        ocdrinfo                                pkg_mec_hb.tcdrinfo; -- 037SO-- working copy of the structure

        acdrinfo                                pkg_mec_hb.tcdrinfommsc; -- 048SO
        acdrinfo0                               pkg_mec_hb.tcdrinfommsc; -- 048SO
        l_dummy                                 VARCHAR2 (254);
        l_relevant_address                      VARCHAR2 (254); -- 146SO
        l_relevant_imsi                         VARCHAR2 (254); -- 146SO
    BEGIN
        p_inserted := 1; -- 143SO
        p_datetime := NULL;
        p_softerrorcount := 0; -- 152SO
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- get the Ascii0 value containing the tap-separated data
        l_recorddata := p_recorddata;

        -- use the PKG_MEC CdrInfo structure to store the read in values
        ocdrinfo := ocdrinfo0; -- clear the structure for every data row
        acdrinfo := acdrinfo0; -- clear the structure for every data row

        -- split the values and assign to the CdrInfo structure one by one, what is needed for this bdetail table   -- 037SO
        IF p_recordversion >= pkg_mec_hb.cascii0versionmmsc_01_00_05
        THEN -- 116SO
            ocdrinfo.mappingstateid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 096SO
            ocdrinfo.requesttime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.datetime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.recipaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.layerspecificattr := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.messagetype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.messagesize := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.seglength := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.storageduration := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.msgscheduletime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.delivertime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.msgexpirytime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.messagepriority := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.messageclass := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.messagecontent := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.messageid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numofnotification := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.mmsidentifier := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.cdrrecordtype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.fwdcopycopyind := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.contentrequestid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.prepaid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.eventdisposition := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.outgoinginterfaceid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.incominginterfaceid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.price := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.deliveryreadrepreqind := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.partytocharge := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.legacytermindicator := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numhomerecipients := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numnonhomeincountryrecipients := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numinternationalrecipients := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numemailrecipients := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numshortcoderecipients := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.numofconversions := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.freetext := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.ratingzoneid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.billingdetailid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.amountcustomer := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.revenuesharemobile := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.revenueshareprovider := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrtypeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.seglength := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.shortid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.vascontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.vaspricemodelversionid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 037SO-- 004AA
            ocdrinfo.tariffid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 057SO
            ocdrinfo.transportclass := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.transportclassiw := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.transportcost := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.transportcount := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.interworkingcontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.foreignrecipient := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.interworkingcase := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.mm7linkedid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.prepaidfreetext := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.promotionplan := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            acdrinfo.tariffclass := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.roaminginfo := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.deliverimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_dummy := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_dummy := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.mmsroamingzoneid1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 028SO
            l_dummy := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 028SO
            ocdrinfo.mmsdestinationzoneid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.mmssizezoneid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.recipcount := TO_NUMBER (pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator));
            ocdrinfo.recipindex := TO_NUMBER (pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator)); -- 027SO
            ocdrinfo.errorid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrbilled := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrrated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.packingidhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.outputhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule2 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule3 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.isgenerated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 115SO
            ocdrinfo.moroamingpromotion := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 147SO
            ocdrinfo.mtroamingpromotion := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 147SO
        END IF;

        p_datetime := ocdrinfo.datetime; -- 092SO

        -- L('BD_SRCTYPE',p_SrcType);
        -- L('BD_BIHID',p_BihId);
        -- L('BD_MAPSID',oCdrInfo.MappingStateId);
        -- L('BD_BIRECNO',p_RecordNr);
        -- L('BD_DATETIME',oCdrInfo.DateTime);

        l_relevant_address :=
            CASE
                WHEN SUBSTR (ocdrinfo.cdrtypeid, 4, 1) = 'O'
                THEN
                    ocdrinfo.origaddress
                ELSE
                    ocdrinfo.recipaddress
            END; -- 146SO
        l_relevant_imsi :=
            CASE
                WHEN SUBSTR (ocdrinfo.cdrtypeid, 4, 1) = 'O'
                THEN
                    ocdrinfo.origimsi
                ELSE
                    ocdrinfo.deliverimsi
            END; -- 146SO

        INSERT INTO bdetail6 (
                        bd_id,
                        bd_srctype,
                        bd_demo,
                        bd_bihid,
                        bd_mapsid,
                        bd_birecno,
                        bd_pacsid1,
                        bd_pacsid2,
                        bd_pacsid3,
                        bd_datetime,
                        bd_msisdn_a,
                        bd_msisdn_b,
                        bd_layerspecattr,
                        bd_msgtype,
                        bd_msgsize,
                        bd_storageduration,
                        bd_datedeliveryfuture,
                        bd_datedelivery,
                        bd_datesubmit,
                        bd_dateexpire,
                        bd_msgpriority,
                        bd_msgclass,
                        bd_msgcontent,
                        bd_umsggrpid,
                        bd_numnotification,
                        bd_mmsidentifier,
                        bd_cdrrectype,
                        bd_fwdcopyind,
                        bd_acccorrid,
                        bd_prepaid,
                        bd_eventdisp,
                        bd_outid,
                        bd_inid,
                        bd_price,
                        bd_requestind,
                        bd_partytocharge,
                        bd_legacyindicator,
                        bd_numhomerecip,
                        bd_numnonhomerecip,
                        bd_numintlrecip,
                        bd_numemailrecip,
                        bd_numscoderecip,
                        bd_numconversion,
                        bd_freetext,
                        bd_imsi,
                        bd_znid,
                        bd_shortid,
                        bd_amountcu,
                        bd_retsharemo -- 029SO
                                     ,
                        bd_retsharepv -- 029SO
                                     ,
                        bd_cdrtid,
                        bd_length,
                        bd_conid,
                        bd_pmvid -- 004AA
                                ,
                        bd_tarid -- 053SO
                                ,
                        bd_trclass,
                        bd_trclassiw,
                        bd_amounttr -- 006AA (016SO)
                                   ,
                        bd_counttr -- 006AA (016SO)
                                  ,
                        bd_tocid,
                        bd_int,
                        bd_iw,
                        bd_mm7linkedid -- 008AA (020AA)
                                      ,
                        bd_prepaidfreetext -- 008AA (020AA)
                                          ,
                        bd_promotionplan -- 008AA (020AA)
                                        ,
                        bd_tariffclass -- 008AA (020AA)
                                      ,
                        bd_roaminginfo -- 008AA (020AA)
                                      ,
                        bd_destinationimsi -- 008AA (020AA)
                                          ,
                        bd_mmsrzid1 -- 024AA
                                   ,
                        bd_mmsdzid -- 024AA
                                  ,
                        bd_mmsszid -- 024AA
                                  ,
                        bd_recipcount -- 024AA
                                     ,
                        bd_recipindex -- 027SO
                                     ,
                        bd_errid,
                        bd_billed,
                        bd_rated,
                        bd_pacidhb,
                        bd_outputhb,
                        bd_generated -- 115SO
                                    ,
                        bd_signature -- 146SO
                                    ,
                        bd_mo_roaming_prom -- 147SO
                                          ,
                        bd_mt_roaming_prom -- 147SO
                                          )
            VALUES      (
                ocdrinfo.billingdetailid,
                p_srctype,
                0,
                p_bihid,
                ocdrinfo.mappingstateid,
                p_recordnr,
                ocdrinfo.schedule1,
                ocdrinfo.schedule2,
                ocdrinfo.schedule3,
                NVL (TO_DATE (ocdrinfo.datetime, cstrmecdatetimeformat), SYSDATE) -- 025AA -- should not be null
                                                                                 ,
                ocdrinfo.origaddress,
                ocdrinfo.recipaddress,
                acdrinfo.layerspecificattr,
                ocdrinfo.messagetype,
                acdrinfo.messagesize,
                TO_NUMBER (acdrinfo.storageduration),
                TO_DATE (ocdrinfo.msgscheduletime, cstrmecdatetimeformat),
                TO_DATE (ocdrinfo.delivertime, cstrmecdatetimeformat),
                TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat) -- 077SO -- 039SO
                                                                     ,
                TO_DATE (ocdrinfo.msgexpirytime, cstrmecdatetimeformat),
                acdrinfo.messagepriority,
                acdrinfo.messageclass,
                acdrinfo.messagecontent,
                ocdrinfo.messageid,
                acdrinfo.numofnotification,
                acdrinfo.mmsidentifier,
                acdrinfo.cdrrecordtype,
                acdrinfo.fwdcopycopyind,
                acdrinfo.contentrequestid,
                ocdrinfo.prepaid,
                ocdrinfo.eventdisposition,
                acdrinfo.outgoinginterfaceid,
                ocdrinfo.incominginterfaceid,
                acdrinfo.price,
                acdrinfo.deliveryreadrepreqind,
                ocdrinfo.partytocharge,
                ocdrinfo.legacytermindicator,
                acdrinfo.numhomerecipients,
                acdrinfo.numnonhomeincountryrecipients,
                acdrinfo.numinternationalrecipients,
                acdrinfo.numemailrecipients,
                acdrinfo.numshortcoderecipients,
                acdrinfo.numofconversions,
                acdrinfo.freetext,
                ocdrinfo.origimsi,
                ocdrinfo.ratingzoneid,
                ocdrinfo.shortid,
                ocdrinfo.amountcustomer,
                ocdrinfo.revenuesharemobile,
                ocdrinfo.revenueshareprovider,
                ocdrinfo.cdrtypeid,
                ocdrinfo.seglength,
                ocdrinfo.vascontractid,
                ocdrinfo.vaspricemodelversionid -- 004AA
                                               ,
                ocdrinfo.tariffid -- 057SO
                                 ,
                ocdrinfo.transportclass,
                ocdrinfo.transportclassiw,
                ocdrinfo.transportcost -- 006AA (016SO)
                                      ,
                ocdrinfo.transportcount -- 006AA (016SO)
                                       ,
                ocdrinfo.interworkingcontractid,
                ocdrinfo.foreignrecipient,
                ocdrinfo.interworkingcase,
                acdrinfo.mm7linkedid -- 008AA (020AA)
                                    ,
                acdrinfo.prepaidfreetext -- 008AA (020AA)
                                        ,
                acdrinfo.promotionplan -- 008AA (020AA)
                                      ,
                acdrinfo.tariffclass -- 008AA (020AA)
                                    ,
                ocdrinfo.roaminginfo -- 008AA (020AA)
                                    ,
                ocdrinfo.deliverimsi -- 008AA (020AA)
                                    ,
                ocdrinfo.mmsroamingzoneid1 -- 028SO
                                          ,
                ocdrinfo.mmsdestinationzoneid -- 024AA
                                             ,
                ocdrinfo.mmssizezoneid -- 024AA
                                      ,
                ocdrinfo.recipcount -- 024AA
                                   ,
                ocdrinfo.recipindex -- 027SO
                                   ,
                ocdrinfo.errorid,
                ocdrinfo.cdrbilled,
                ocdrinfo.cdrrated,
                ocdrinfo.packingidhb,
                ocdrinfo.outputhb,
                ocdrinfo.isgenerated -- 115SO
                                    -- BD_SIGNATURE                                                         -- 146SO
                                    -- 01: ZERO  0=zero charged 1=nonzero charged
                                    -- 02: BILLED 1=billed, 0=not billed, 2=uninitialized, 3=duplicate submit
                                    -- 03: MAPSID E=Error, M=Mapping
                                    -- 04: CDRTID O=MMSOrecord, R=MMSRrecord, 3=MM3Rrecord, 4=MM4Rrecord, 7=MM7?record, U=unexpected
                                    -- 05: MSISDN F=TFL(42377..), S=others(Swisscom)
                                    -- 06: PREPAID Y=yes, N=no, U=Unknown
                                    -- 07: TARID V=free-free, X=internal, S=BN, P=PTS, L=MMS-LA or '-'=P2P
                                    -- 08: EVENTDISPOSITION 1=delivered, 2=received, 3=expired, 4=rejected network, 7=rejected terminal, 0=others
                                    -- 09: ROAMINGINFO D=41.794998800 (default), S=NULL (home net), F=foreign net
                                    -- 10: MESSAGETYPE 0=Message, 1=Notification, 2=DeliveryReport, 3=ReadReply
                                    -- 11: RECIPINDEX 1=first, n=added by splitter
                                    -- 12: IMSI D=228010000000, N=NULL, S=22801..., F=others
                                    -- 13: MOPROM   0=no, 1=yes
                                    -- 14: MTPROM   0=no, 1=yes
                                    -- 15: RESERVED '-'=unused
                                    -- 16: RESERVED '-'=unused
                                    -- 17: RESERVED '-'=unused
                                    ,
                   DECODE (ocdrinfo.amountcustomer, 0.0, '0', '1')
                || ocdrinfo.cdrbilled
                || ocdrinfo.mappingstateid
                || DECODE (ocdrinfo.cdrtypeid,  'MMSO', 'O',  'MMSR', 'R',  'MM3O', '3',  'MM3R', '3',  'MM4O', '4',  'MM4R', '4',  'MM7O', '7',  'MM7R', '7',  'U')
                || DECODE (SUBSTR (l_relevant_address, 1, 5), '42377', 'F', 'S')
                || NVL (ocdrinfo.prepaid, '-')
                || DECODE (NVL (ocdrinfo.tariffid, '-'),  '-', '-',  'S', 'S',  'P', 'P',  'X', 'X',  'V', 'V',  'L') -- 148SO
                || DECODE (ocdrinfo.eventdisposition,  1, 1,  2, 2,  3, 3,  4, 4,  7, 7,  0)
                || DECODE (ocdrinfo.roaminginfo,  '41.794998800', 'D',  NULL, 'S',  'F')
                || ocdrinfo.messagetype
                || DECODE (ocdrinfo.recipindex, 1, '1', 'n')
                || DECODE (l_relevant_imsi,  '228010000000', 'D',  NULL, 'N',  DECODE (SUBSTR (l_relevant_imsi, 1, 5), '22801', 'S', 'F'))
                || DECODE (ocdrinfo.moroamingpromotion, 1, '1', '0') -- 147SO
                || DECODE (ocdrinfo.mtroamingpromotion, 1, '1', '0') -- 147SO
                || '-' -- 147SO
                || '-' -- 147SO
                || '-' -- 147SO
                      ,
                ocdrinfo.moroamingpromotion -- 147SO
                                           ,
                ocdrinfo.mtroamingpromotion -- 147SO
                                           );

        IF     p_softerrorid IS NULL
           AND ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorid := ocdrinfo.errorid; -- first error only !
        END IF;

        IF ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorcount := p_softerrorcount + 1; -- 152SO
        END IF;

        RETURN;
    END insert_csv_mmsc;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_msc ( -- 009AA
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS
        l_recorddata                            VARCHAR2 (4000);
        ocdrinfo0                               pkg_mec_hb.tcdrinfo; -- 037SO   -- untouched empty copy of the structure
        ocdrinfo                                pkg_mec_hb.tcdrinfo; -- 037SO   -- working copy of the structure

        l_exchangeidentity                      VARCHAR2 (20);
        l_route                                 VARCHAR2 (20);
        l_teleservicecode                       VARCHAR2 (2);
        l_powerclass                            VARCHAR2 (20);
        l_smscid                                VARCHAR2 (10);
    BEGIN
        p_inserted := 1; -- 143SO
        p_datetime := NULL;
        p_softerrorcount := 0; -- 152SO
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- get the Ascii0 value containing the tap-separated data
        l_recorddata := p_recorddata;
        -- use the PKG_MEC CdrInfo structure to store the read in values
        -- clear the structure for every data row
        ocdrinfo := ocdrinfo0;

        -- split the values and assign to the CdrInfo structure one by one, what is needed for this bdetail table
        IF p_recordversion >= pkg_mec_hb.cascii0versionmsc_01_00_04
        THEN -- 044SO -- 037SO
            ocdrinfo.mappingstateid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 096SO
            ocdrinfo.cdrtypeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- connected party
            ocdrinfo.recipaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- other party
            ocdrinfo.requesttime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.imsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.imei := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_exchangeidentity := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.mscidentificationid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_route := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cell := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_teleservicecode := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.servicecenteraddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_powerclass := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.subscriptiontype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.prepaid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.billingdetailid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.shortid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.amountcustomer := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.revenuesharemobile := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.revenueshareprovider := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.vascontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.tariffid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 057SO-- 019SO
            ocdrinfo.vaspricemodelversionid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 004AA
            ocdrinfo.errorid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrbilled := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrrated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.packingidhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.outputhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.ratingzoneid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.interworkingcontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 004AA
            ocdrinfo.schedule1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule2 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule3 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origsubmittime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 044SO
            ocdrinfo.msgreference := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 129SO
            ocdrinfo.scaopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 118SO
            ocdrinfo.origgtiopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.deliveropkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.delivergtiopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.interworkingamount := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingapmn := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingcurrency := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingdirection := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingscenario := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingstate := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
        END IF;

        p_datetime := ocdrinfo.requesttime;

        IF ocdrinfo.cdrtypeid = cstrmscmobileterminatingsms
        THEN
            -- Lookup SMSCId (BS_SMSCID) using ServiceCentreAddress (BD_SCA) from the table SMSC
            -- If ServiceCenterAddress is not found then the SMSCs are added to (belong to) a
            -- predefined Operator Contract called 'UNKNOWNTOC'
            IF ocdrinfo.imsi LIKE gcstrownmccmnc || '%'
            THEN
                l_smscid := getsmscid (ocdrinfo.servicecenteraddress, 1); -- 072SO
            ELSE
                l_smscid := getsmscid (ocdrinfo.servicecenteraddress, 0); -- 102SO
            END IF;
        ELSE
            -- SMSC ID is not needed for MO CDRs for now
            l_smscid := NULL;
        END IF;

        INSERT INTO bdetail4 (
                        bd_id,
                        bd_srctype,
                        bd_demo,
                        bd_bihid,
                        bd_mapsid,
                        bd_birecno,
                        bd_pacsid1,
                        bd_pacsid2,
                        bd_pacsid3,
                        bd_cdrtid,
                        bd_msisdn_a, -- connected party  (Originator for MO / Recipient for MT)
                        bd_msisdn_b, -- other party      (Recipient for MO / Originator for MT)
                        bd_datetime,
                        bd_imsi,
                        bd_imei,
                        bd_exid,
                        bd_mscid,
                        bd_route,
                        bd_cell,
                        bd_tsc,
                        bd_sca,
                        bd_power,
                        bd_subtype,
                        bd_prepaid,
                        bd_znid,
                        bd_smscid,
                        bd_shortid,
                        bd_amountcu,
                        bd_retsharemo,
                        bd_retsharepv,
                        bd_conid,
                        bd_tarid, -- 019SO
                        bd_pmvid, -- 004AA
                        bd_tocid, -- 007AA
                        bd_errid,
                        bd_billed,
                        bd_rated,
                        bd_pacidhb,
                        bd_outputhb,
                        bd_origsubmittime -- 044SO
                                         ,
                        bd_messagereference -- 129SO
                                           ,
                        bd_sca_opkey -- 118SO
                                    ,
                        bd_ogti_opkey -- 117SO
                                     ,
                        bd_deliver_opkey -- 117SO
                                        ,
                        bd_dgti_opkey -- 117SO
                                     ,
                        bd_iw_amount -- 128SO
                                    ,
                        bd_iw_apmn -- 128SO
                                  ,
                        bd_iw_curid -- 128SO
                                   ,
                        bd_iw_dir -- 128SO
                                 ,
                        bd_iw_scenario -- 128SO
                                      ,
                        bd_iw_constate -- 128SO
                                      ,
                        bd_signature -- 146SO
                                    )
            VALUES      (
                ocdrinfo.billingdetailid,
                p_srctype,
                0,
                p_bihid,
                ocdrinfo.mappingstateid,
                p_recordnr,
                ocdrinfo.schedule1,
                ocdrinfo.schedule2,
                ocdrinfo.schedule3,
                ocdrinfo.cdrtypeid,
                ocdrinfo.origaddress, -- connected party
                ocdrinfo.recipaddress, -- other party
                TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat),
                ocdrinfo.imsi,
                ocdrinfo.imei,
                l_exchangeidentity,
                ocdrinfo.mscidentificationid,
                l_route,
                ocdrinfo.cell,
                l_teleservicecode,
                ocdrinfo.servicecenteraddress,
                l_powerclass,
                ocdrinfo.subscriptiontype,
                ocdrinfo.prepaid,
                ocdrinfo.ratingzoneid,
                l_smscid,
                ocdrinfo.shortid,
                ocdrinfo.amountcustomer,
                ocdrinfo.revenuesharemobile,
                ocdrinfo.revenueshareprovider,
                ocdrinfo.vascontractid,
                ocdrinfo.tariffid, -- 057SO-- 019SO
                ocdrinfo.vaspricemodelversionid, -- 004AA
                ocdrinfo.interworkingcontractid, -- 007AA
                ocdrinfo.errorid,
                ocdrinfo.cdrbilled,
                ocdrinfo.cdrrated,
                ocdrinfo.packingidhb,
                ocdrinfo.outputhb,
                TO_DATE (ocdrinfo.origsubmittime, cstrmecdatetimeformat) -- 044SO
                                                                        ,
                ocdrinfo.msgreference -- BD_MESSAGEREFERENCE -- 129SO
                                     ,
                ocdrinfo.scaopkey -- BD_SCA_OPKEY     -- 118SO
                                 ,
                ocdrinfo.origgtiopkey -- BD_OGTI_OPKEY    -- 117SO
                                     ,
                ocdrinfo.deliveropkey -- BD_DELIVER_OPKEY -- 117SO
                                     ,
                ocdrinfo.delivergtiopkey -- BD_DGTI_OPKEY    -- 117SO
                                        ,
                ocdrinfo.interworkingamount -- 'BD_IW_AMOUNT'   -- 128SO
                                           ,
                ocdrinfo.interworkingapmn -- 'BD_IW_APMN'     -- 128SO
                                         ,
                ocdrinfo.interworkingcurrency -- 'BD_IW_CURID'    -- 128SO
                                             ,
                ocdrinfo.interworkingdirection -- 'BD_IW_DIR'      -- 128SO
                                              ,
                ocdrinfo.interworkingscenario -- 'BD_IW_SCENARIO' -- 128SO
                                             ,
                ocdrinfo.interworkingstate -- 'BD_IW_CONSTATE' -- 128SO
                                          -- BD_SIGNATURE                                                         -- 146SO
                                          -- 01: ZERO  0=zero charged 1=nonzero charged
                                          -- 02: BILLED 1=billed, 0=not billed, 2=uninitialized, 3=ignore-dup, 4=ignore-0, 5=reject-dup, 6=reject-sub, 7=send-frng, 8=recv-frng (see table BDBSTATE)
                                          -- 03: MAPSID E=Error, M=Mapping
                                          -- 04: CDRTID O=originating, T=terminating
                                          -- 05: IMSI   S=22801, F=others
                                          -- 06: PREPAID Y=yes, N=no, U=unknown
                                          -- 07: TARID  L=LA, S=BN-IS, P=Portal-IS, T=Televote, V=free-free, X=intern or '-' =P2P
                                          -- 08: RATZONE  0=normal, 1=la-handygroup(SMS-HG-a/SMS-HG-b/SMS-HG-d)   -- 147SO                                          -- 147SO
                                          -- 09: RESERVED '-'=unused                                              -- 147SO
                                          -- 10: RESERVED '-'=unused                                              -- 147SO
                                          -- 11: RESERVED '-'=unused                                              -- 147SO
                                          ,
                   DECODE (ocdrinfo.amountcustomer, 0.0, '0', '1')
                || ocdrinfo.cdrbilled
                || ocdrinfo.mappingstateid
                || SUBSTR (ocdrinfo.cdrtypeid, 6, 1)
                || DECODE (SUBSTR (ocdrinfo.imsi, 1, 5), '22801', 'S', 'F')
                || ocdrinfo.prepaid
                || DECODE (ocdrinfo.tariffid,  'X', 'X',  'V', 'V',  'S', 'S',  'P', 'P',  'T', 'T',  NULL, '-',  'L')
                || DECODE (SUBSTR (ocdrinfo.ratingzoneid, 1, 6), 'SMS-HG', '1', '0')
                || '-'
                || '-'
                || '-');

        IF     (ocdrinfo.cdrtypeid = cstrmscmobileterminatingsms)
           AND NOT (l_smscid IS NULL)
           AND (ocdrinfo.schedule1 = 'S')
        THEN -- 074SO
            INSERT INTO sms_iw_mt_arch (
                            bda_day,
                            bda_smscid,
                            bda_bihid,
                            bda_birecno,
                            bda_sca,
                            bda_datetime,
                            bda_msisdn_a,
                            bda_imsi,
                            bda_msisdn_b,
                            bda_mscid -- 105SO
                                     )
            VALUES      (
                TRUNC (TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat)),
                l_smscid,
                p_bihid,
                p_recordnr,
                ocdrinfo.servicecenteraddress,
                TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat),
                ocdrinfo.origaddress,
                ocdrinfo.imsi,
                ocdrinfo.recipaddress,
                ocdrinfo.mscidentificationid -- 105SO
                                            ); -- 073SO        14.09.2009  Populate archive table for SC terminating IW SMS
        END IF;

        IF     p_softerrorid IS NULL
           AND ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorid := ocdrinfo.errorid; -- first error only !
        END IF;

        IF ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorcount := p_softerrorcount + 1; -- 152SO
        END IF;

        RETURN;
    END insert_csv_msc;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_pos ( -- 036AA
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS -- 086SO
        l_recorddata                            VARCHAR2 (4000);
        ocdrinfo0                               pkg_mec_hb.tcdrinfo; -- 008AA(020SO)   -- untouched empty copy of the structure
        ocdrinfo                                pkg_mec_hb.tcdrinfo; -- 008AA(020SO)   -- working copy of the structure

        l_timeoffset                            VARCHAR2 (5); -- for pos
        l_nummsgs                               VARCHAR2 (20);
        l_calltype                              VARCHAR2 (2);
        l_servedpartycgi                        VARCHAR2 (25);
        l_gsmpi                                 VARCHAR2 (3);
        l_remark                                VARCHAR2 (160); -- 069SO
        l_utxparams                             VARCHAR2 (15);
        l_product_channel_id                    VARCHAR2 (10); -- 059SO
    BEGIN
        p_inserted := 1; -- 143SO
        p_datetime := NULL;
        p_softerrorcount := 0; -- 152SO
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- get the Ascii0 value containing the tap-separated data
        l_recorddata := p_recorddata;
        -- use the PKG_MEC CdrInfo structure to store the read in values
        -- clear the structure for every data row
        ocdrinfo := ocdrinfo0;

        -- split the values and assign to the CdrInfo structure one by one, what is needed for this bdetail table -- 008AA(020SO)
        IF p_recordversion >= pkg_mec_hb.cascii0versionufih_01_00_01
        THEN -- 057SO
            ocdrinfo.mappingstateid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 096SO
            ocdrinfo.requesttime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_timeoffset := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_nummsgs := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_calltype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_servedpartycgi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_gsmpi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_remark := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.ratedunits := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.amountcustomer := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            l_utxparams := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.prepaid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.contractsubtype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrtypeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.foreignrecipient := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.interworkingcase := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.errorid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.billingdetailid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.aaatopstopupdated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrbilled := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrrated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.packingidhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.outputhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule2 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule3 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
        END IF;

        p_datetime := ocdrinfo.requesttime;

        l_product_channel_id := NULL; -- 059SO

        INSERT INTO bdetail9 (
                        bd_id,
                        bd_srctype,
                        bd_demo,
                        bd_bihid,
                        bd_birecno,
                        bd_datetime,
                        bd_offset,
                        bd_nummsg,
                        bd_calltype,
                        bd_msisdn,
                        bd_cgi,
                        bd_gsmpi,
                        bd_remark,
                        bd_ratedunits,
                        bd_amountcu,
                        bd_utxparams,
                        bd_mapsid,
                        bd_prepaid,
                        bd_constid,
                        bd_cdrtid,
                        bd_int,
                        bd_iw,
                        bd_errid,
                        bd_aaats,
                        bd_billed,
                        bd_rated,
                        bd_pacidhb,
                        bd_outputhb,
                        bd_pacsid1,
                        bd_pacsid2,
                        bd_pacsid3,
                        bd_vsprcid -- 059SO
                                  )
        VALUES      (
            ocdrinfo.billingdetailid,
            p_srctype,
            0,
            p_bihid,
            p_recordnr,
            TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat),
            l_timeoffset,
            l_nummsgs,
            l_calltype,
            ocdrinfo.origaddress,
            l_servedpartycgi,
            l_gsmpi,
            l_remark,
            ocdrinfo.ratedunits,
            ocdrinfo.amountcustomer,
            l_utxparams,
            ocdrinfo.mappingstateid,
            ocdrinfo.prepaid,
            ocdrinfo.contractsubtype,
            ocdrinfo.cdrtypeid,
            ocdrinfo.foreignrecipient,
            ocdrinfo.interworkingcase,
            ocdrinfo.errorid,
            ocdrinfo.aaatopstopupdated,
            ocdrinfo.cdrbilled,
            ocdrinfo.cdrrated,
            ocdrinfo.packingidhb,
            ocdrinfo.outputhb,
            ocdrinfo.schedule1,
            ocdrinfo.schedule2,
            ocdrinfo.schedule3,
            l_product_channel_id -- 059SO
                                );

        IF     p_softerrorid IS NULL
           AND ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorid := ocdrinfo.errorid; -- first error only !
        END IF;

        IF ocdrinfo.mappingstateid <> cstrmappingstatesuccess
        THEN
            p_softerrorcount := p_softerrorcount + 1; -- 152SO
        END IF;

        RETURN;
    --Exception
    --    When others then
    --        RAISE;
    END insert_csv_pos;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_smsn (
        p_srctype                               IN     VARCHAR2,
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2, -- 086SO -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- 086SO
        p_recorddata                            IN     VARCHAR2, -- 086SO
        p_recordversion                         IN     VARCHAR2, -- 086SO
        p_inserted                                 OUT NUMBER, -- 143SO
        p_datetime                                 OUT VARCHAR2,
        p_softerrorcount                           OUT NUMBER, -- 152SO
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS -- 124SO
        l_recorddata                            VARCHAR2 (4000);
        ocdrinfo0                               pkg_mec_hb.tcdrinfo; -- untouched empty copy of the structure
        ocdrinfo                                pkg_mec_hb.tcdrinfo; -- working copy of the structure

        l_smscid                                VARCHAR2 (10);
        l_firstsegmentid                        NUMBER (8); -- 142SO
        l_lastsegmentid                         NUMBER (8); -- 142SO
        l_msgreference                          VARCHAR2 (100); -- 142SO
        l_origin                                VARCHAR2 (1); -- 146SO
        l_orignet                               VARCHAR2 (1); -- 146SO
        l_dest                                  VARCHAR2 (1); -- 146SO
        l_destnet                               VARCHAR2 (1); -- 146SO
        cstrimsfqdnpattern                      VARCHAR2 (50) := 'mscs__.sharedtcs.net:%'; -- 154SO
        cstrimscoreaddresses                    VARCHAR2 (100) := '10.94.64.130:5060;10.94.64.50:5060;10.94.8.130:5060;10.94.8.50:5060'; -- 154SO
    BEGIN
        p_inserted := 0; -- 143SO
        p_datetime := NULL;
        p_softerrorcount := 0; -- 152SO
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- get the Ascii0 value containing the tap-separated data
        l_recorddata := p_recorddata;
        -- use the PKG_MEC CdrInfo structure to store the read in values
        -- clear the structure for every data row
        ocdrinfo := ocdrinfo0;

        -- split the values and assign to the CdrInfo structure one by one, what is needed for this bdetail table
        IF p_recordversion >= pkg_mec_hb.cascii0versionsmsn_01_00_01
        THEN
            ocdrinfo.mappingstateid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 096SO
            ocdrinfo.origaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origaddresston := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origaddressnpi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.msgpid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.datetime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 055SO
            ocdrinfo.requesttime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 055SO
            ocdrinfo.deliverpid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.msgstatus := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.shortid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.vsmscid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.seglength := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.deliverimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origgti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.delivergti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.prepaid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.billingdetailid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.ratingzoneid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.amountcustomer := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.revenuesharemobile := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.revenueshareprovider := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.transportcost := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 031SO
            ocdrinfo.vascontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.tariffid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 057SO-- 017SO
            ocdrinfo.vaspricemodelversionid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.interworkingcontractid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrtypeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 012AA
            ocdrinfo.foreignrecipient := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 012AA
            ocdrinfo.interworkingcase := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 012AA
            ocdrinfo.errorid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrbilled := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.cdrrated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.packingidhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.outputhb := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule1 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule2 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.schedule3 := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator);
            ocdrinfo.origsubmittime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 054SO
            ocdrinfo.origbillingid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 054SO
            ocdrinfo.onlinecharge := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 068SO
            ocdrinfo.msgreference := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 068SO
            ocdrinfo.origimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 071SO
            ocdrinfo.pppser := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 071SO
            ocdrinfo.dser := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 113SO
            ocdrinfo.origsca := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 113SO
            ocdrinfo.isgenerated := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 113SO
            ocdrinfo.scaopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 118SO
            ocdrinfo.origgtiopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.deliveropkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.delivergtiopkey := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 117SO
            ocdrinfo.submitmicros := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.submitgti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.submitapp := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.origcharset := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.origesmeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.origip := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.delivermicros := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.deliverattempt := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.deliveraddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.deliveraddresston := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.deliveraddressnpi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.deliveresmeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.deliverip := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.msgreqtype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.msgscheduletime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.msgexpirytime := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.segid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.segcount := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.errortype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.errorcode := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.diaresult := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 124SO
            ocdrinfo.recipimsi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 125SO
            ocdrinfo.recipaddress := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 126SO
            ocdrinfo.recipaddresston := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 126SO
            ocdrinfo.recipaddressnpi := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 126SO
            ocdrinfo.interworkingamount := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingapmn := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingcurrency := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingdirection := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingscenario := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.interworkingstate := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 128SO
            ocdrinfo.origdcs := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 136SO
            ocdrinfo.origmessageid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 137SO
            ocdrinfo.origimei := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 139SO
            ocdrinfo.deliverimei := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 139SO
            ocdrinfo.origpaniheader := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 140SO -- 139SO
            ocdrinfo.deliverpaniheader := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 141SO
            ocdrinfo.delivermapgti := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 141SO
            ocdrinfo.bioclientid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 145SO
            ocdrinfo.bioorigesmeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 145SO
            ocdrinfo.biomsgreference := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 145SO
            ocdrinfo.recipesmeid := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 145SO
            ocdrinfo.biorequesttype := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 145SO
            ocdrinfo.moroamingpromotion := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 147SO
            ocdrinfo.cdrmonitored := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 696SO 'BD_MONITORED'
            ocdrinfo.packingidmon := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 696SO 'BD_PACIDMON'
            ocdrinfo.outputmon := pkg_common.cutfirstitem (l_recorddata, cstrfieldseparator); -- 696SO 'BD_OUTPUTMON'
        END IF;

        -- All the CDRs with status submit ('4') goto into BDETAIL1 table and
        -- everything else goes to BDETAIL2 table

        IF     (ocdrinfo.cdrtypeid = cstrcdrtypehomeroutedsms)
           AND (ocdrinfo.origsca IS NOT NULL)
        THEN
            -- Lookup SMSCId (BS_SMSCID) using the OrigSca field from the table SMSC
            -- If ServiceCenterAddress is not found then the SMSCs are added to (belong to) a
            -- predefined Operator Contract called 'UNKNOWNTOC'
            l_smscid := getsmscid (ocdrinfo.origsca, cintcreatesmscforhomeroutedsms);
        ELSE
            -- SMSC ID is not needed or not available
            l_smscid := NULL;
        END IF;

        p_datetime := ocdrinfo.datetime;

        ocdrinfo.recipaddress := SUBSTR (ocdrinfo.recipaddress, 1, 20); -- 133SO
        ocdrinfo.deliveraddress := SUBSTR (ocdrinfo.deliveraddress, 1, 20); -- 133SO

        -- L(p_RecordVersion || '/' || p_DateTime,p_RecordNr);

        IF NVL (ocdrinfo.segid, 0) = 0
        THEN -- 144SO
            -- unroll all segments for SMS-EXT/PAGER-EXT
            l_firstsegmentid := 1; -- 142SO
            l_lastsegmentid := NVL (ocdrinfo.segcount, 1); -- 144SO -- 142SO
        ELSE
            l_firstsegmentid := NVL (ocdrinfo.segid, 1); -- 144SO -- 142SO
            l_lastsegmentid := NVL (ocdrinfo.segid, 1); -- 144SO -- 142SO
        END IF;

        FOR l_segmentid IN l_firstsegmentid .. l_lastsegmentid
        LOOP -- 142SO
            l_msgreference := ocdrinfo.msgreference || extmsgreferencesuffix (ocdrinfo.segid, l_segmentid); -- 142SO
            -- SegId=0 means multi-segmented external SMS/Pager which needs to be unrolled with multiple SegCount CDRs

            l_origin :=
                CASE
                    WHEN ocdrinfo.isgenerated = 1
                    THEN
                        'G'
                    WHEN ocdrinfo.origesmeid IN ('36531',
                                                 '36533')
                    THEN
                        'R'
                    WHEN ocdrinfo.origip LIKE cstrimsfqdnpattern -- 154SO
                    THEN
                        'I'
                    WHEN INSTR (';' || cstrimscoreaddresses || ';', ';' || ocdrinfo.origip || ';') > 0
                    THEN
                        'I' -- 154SO
                    WHEN ocdrinfo.origsca LIKE '4179%'
                    THEN
                        'M'
                    WHEN ocdrinfo.origsca IS NOT NULL
                    THEN
                        'H'
                    WHEN ocdrinfo.cdrtypeid IN ('PAGER-EXT',
                                                'SMS-EXT') -- 151SO
                    THEN
                        'E'
                    WHEN ocdrinfo.origesmeid IS NOT NULL
                    THEN
                        'A'
                    ELSE
                        'S'
                END; -- 146SO

            l_orignet :=
                CASE
                    WHEN NVL (ocdrinfo.origgti, '4179') NOT LIKE '4179%'
                    THEN
                        'F'
                    WHEN ocdrinfo.cdrtypeid IN ('IMS-ORMO',
                                                'RCS-ORMO',
                                                'SMS-ORMO')
                    THEN
                        'F'
                    ELSE
                        'S'
                END; -- 146SO maybe ToDo: 'C' for CH but not Swisscom

            l_dest :=
                CASE
                    WHEN ocdrinfo.isgenerated = 1
                    THEN
                        'G' -- 157SO
                    WHEN ocdrinfo.cdrtypeid IN ('PAGER-EXT',
                                                'SMS-EXT')
                    THEN
                        'E' -- 151SO
                    WHEN ocdrinfo.deliveresmeid IN ('36531',
                                                    '36533')
                    THEN
                        'R'
                    WHEN ocdrinfo.deliveresmeid IS NOT NULL
                    THEN
                        'A'
                    WHEN ocdrinfo.msgstatus IN ('3',
                                                '4')
                    THEN
                        'U'
                    WHEN ocdrinfo.deliverip LIKE cstrimsfqdnpattern -- 154SO
                    THEN
                        'I'
                    WHEN INSTR (';' || cstrimscoreaddresses || ';', ';' || ocdrinfo.deliverip || ';') > 0
                    THEN
                        'I' -- 154SO
                    WHEN ocdrinfo.deliverimsi IS NOT NULL
                    THEN
                        'S'
                    ELSE
                        'U'
                END; -- 146SO

            l_destnet :=
                CASE
                    WHEN ocdrinfo.cdrtypeid IN ('PAGER-EXT')
                    THEN
                        'S' -- 151SO
                    WHEN     ocdrinfo.cdrtypeid IN ('SMS-EXT')
                         AND ocdrinfo.deliverimsi NOT LIKE '22801%' -- 155SO
                    THEN
                        'F' -- 151SO
                    WHEN ocdrinfo.cdrtypeid IN ('SMS-EXT')
                    THEN
                        'S' -- 151SO
                    WHEN ocdrinfo.delivergti LIKE '4179%'
                    THEN
                        'S'
                    WHEN ocdrinfo.delivergti NOT LIKE '4179%'
                    THEN
                        'F'
                    WHEN is_roaming_pani (ocdrinfo.deliverpaniheader) = 1
                    THEN
                        'F' -- 151SO
                    ELSE
                        'S'
                END; -- 146SO maybe ToDo: 'C' for CH but not Swisscom

            IF ocdrinfo.msgstatus IN ('3',
                                      '4')
            THEN -- 131SO
                -- Submit CDR

                INSERT INTO bdetail1 (
                                bd_id,
                                bd_srctype,
                                bd_demo,
                                bd_bihid,
                                bd_mapsid,
                                bd_birecno,
                                bd_pacsid1,
                                bd_pacsid2,
                                bd_pacsid3,
                                bd_msisdn_a,
                                bd_ton_a,
                                bd_npi_a,
                                bd_pid_a,
                                bd_datetime,
                                bd_pid_b,
                                bd_status,
                                bd_consolidation,
                                bd_vsmscid,
                                bd_length,
                                bd_imsi,
                                bd_ogti,
                                bd_dgti, -- 069SO
                                bd_prepaid,
                                bd_znid,
                                bd_amountcu,
                                bd_retsharemo,
                                bd_retsharepv,
                                bd_amounttr, -- 031SO
                                bd_conid,
                                bd_tarid, -- 017SO
                                bd_tocid,
                                bd_cdrtid, -- 012AA
                                bd_int,
                                bd_iw,
                                bd_errid,
                                bd_billed,
                                bd_rated,
                                bd_pacidhb,
                                bd_outputhb,
                                bd_origsubmit, -- 054SO
                                bd_billid, -- 054SO
                                bd_onlinecharge, -- 068SO
                                bd_messagereference, -- 068SO
                                bd_smscid, -- 070SO
                                bd_originatorimsi, -- 071SO
                                bd_pppser, -- 071SO
                                bd_dser, -- 113SO
                                bd_origsca, -- 113SO
                                bd_generated, -- 114SO
                                bd_sca_opkey, -- 118SO
                                bd_ogti_opkey, -- 117SO
                                bd_deliver_opkey, -- 117SO
                                bd_submit_us, -- 124SO
                                bd_submit_gt,
                                bd_submit_app,
                                bd_orig_charset,
                                bd_orig_esme_id,
                                bd_orig_ip,
                                bd_deliver_adr,
                                bd_deliver_ton,
                                bd_deliver_npi,
                                bd_deliver_esme_id,
                                bd_deliver_ip,
                                bd_msgreqtype,
                                bd_msgscheduletime,
                                bd_msgexpirytime,
                                bd_seg_id,
                                bd_seg_count,
                                bd_err_type,
                                bd_err_code,
                                bd_dia_result,
                                bd_recip_imsi, -- 125SO
                                bd_recip_adr, -- 126SO
                                bd_recip_ton, -- 126SO
                                bd_recip_npi, -- 126SO
                                bd_msisdn_b, -- 132SO
                                bd_ton_b, -- 132SO
                                bd_npi_b, -- 132SO
                                bd_orig_dcs, -- 136SO
                                bd_orig_msg_id, -- 137SO
                                bd_orig_imei, -- 139SO
                                bd_pani_header, -- 139SO
                                bd_bio_client_id, -- 145SO
                                bd_bio_orig_esme_id, -- 145SO
                                bd_bio_msg_ref, -- 145SO
                                bd_recip_esme_id, -- 145SO
                                bd_bio_req_type, -- 145SO
                                bd_signature, -- 146SO
                                bd_mo_roaming_prom, -- 147SO
                                bd_monitored, -- 696SO
                                bd_pacidmon, -- 696SO
                                bd_outputmon -- 696SO
                                            )
                    VALUES      (
                        ocdrinfo.billingdetailid,
                        p_srctype,
                        0,
                        p_bihid,
                        ocdrinfo.mappingstateid,
                        p_recordnr,
                        ocdrinfo.schedule1,
                        ocdrinfo.schedule2,
                        ocdrinfo.schedule3,
                        ocdrinfo.origaddress,
                        ocdrinfo.origaddresston,
                        ocdrinfo.origaddressnpi,
                        ocdrinfo.msgpid,
                        TO_DATE (ocdrinfo.datetime, cstrmecdatetimeformat),
                        ocdrinfo.deliverpid,
                        ocdrinfo.msgstatus,
                        ocdrinfo.shortid,
                        ocdrinfo.vsmscid,
                        ocdrinfo.seglength,
                        ocdrinfo.deliverimsi,
                        ocdrinfo.origgti,
                        ocdrinfo.delivergti, -- 069SO
                        ocdrinfo.prepaid,
                        ocdrinfo.ratingzoneid,
                        ocdrinfo.amountcustomer,
                        ocdrinfo.revenuesharemobile,
                        ocdrinfo.revenueshareprovider,
                        ocdrinfo.transportcost, -- 032SO -- 031SO
                        ocdrinfo.vascontractid,
                        ocdrinfo.tariffid, -- 057SO-- 017SO
                        ocdrinfo.interworkingcontractid,
                        ocdrinfo.cdrtypeid, -- 012AA
                        ocdrinfo.foreignrecipient, -- 012AA
                        ocdrinfo.interworkingcase, -- 012AA
                        ocdrinfo.errorid,
                        ocdrinfo.cdrbilled,
                        ocdrinfo.cdrrated,
                        ocdrinfo.packingidhb,
                        ocdrinfo.outputhb,
                        TO_DATE (ocdrinfo.origsubmittime, cstrmecdatetimeformat), -- 054SO
                        ocdrinfo.origbillingid, -- 054SO
                        ocdrinfo.onlinecharge, -- 068SO
                        l_msgreference, -- 142SO -- 068SO
                        l_smscid, -- 070SO
                        ocdrinfo.origimsi, -- 071SO
                        ocdrinfo.pppser, -- 071SO
                        ocdrinfo.dser, -- 113SO
                        ocdrinfo.origsca, -- 113SO
                        ocdrinfo.isgenerated, -- 114SO
                        ocdrinfo.scaopkey, -- 118SO
                        ocdrinfo.origgtiopkey, -- 117SO
                        ocdrinfo.deliveropkey, -- 117SO
                        ocdrinfo.submitmicros, -- 'BD_SUBMIT_US'
                        ocdrinfo.submitgti, -- 'BD_SUBMIT_GT'
                        ocdrinfo.submitapp, -- 'BD_SUBMIT_APP'
                        ocdrinfo.origcharset, -- 'BD_ORIG_CHARSET'
                        ocdrinfo.origesmeid, -- 'BD_ORIG_ESME_ID'
                        ocdrinfo.origip, -- 'BD_ORIG_IP'
                        ocdrinfo.deliveraddress, -- 'BD_DELIVER_ADR'
                        ocdrinfo.deliveraddresston, -- 'BD_DELIVER_TON'
                        ocdrinfo.deliveraddressnpi, -- 'BD_DELIVER_NPI'
                        ocdrinfo.deliveresmeid, -- 'BD_DELIVER_ESME_ID'
                        ocdrinfo.deliverip, -- 'BD_DELIVER_IP'
                        ocdrinfo.msgreqtype, -- 'BD_MSGREQTYPE'
                        TO_DATE (ocdrinfo.msgscheduletime, cstrmecdatetimeformat), -- 'BD_MSGSCHEDULETIME' -- 130SO
                        TO_DATE (ocdrinfo.msgexpirytime, cstrmecdatetimeformat), -- 'BD_MSGEXPIRYTIME'   -- 130SO
                        l_segmentid, -- 'BD_SEG_ID'          -- 142SO
                        ocdrinfo.segcount, -- 'BD_SEG_COUNT'
                        ocdrinfo.errortype, -- 'BD_ERR_TYPE'
                        ocdrinfo.errorcode, -- 'BD_ERR_CODE'
                        ocdrinfo.diaresult, -- 'BD_DIA_RESULT'
                        ocdrinfo.recipimsi, -- 'BD_RECIP_IMSI' -- 125SO
                        ocdrinfo.recipaddress, -- 'BD_RECIP_ADR'  -- 126SO
                        ocdrinfo.recipaddresston, -- 'BD_RECIP_TON'  -- 126SO
                        ocdrinfo.recipaddressnpi, -- 'BD_RECIP_NPI'  -- 126SO
                        ocdrinfo.deliveraddress, -- BD_MSISDN_B -- 132SO
                        ocdrinfo.deliveraddresston, -- BD_TON_B -- 132SO
                        ocdrinfo.deliveraddressnpi, -- BD_NPI_B -- 132SO
                        ocdrinfo.origdcs, -- BD_ORIG_DCS -- 136SO
                        ocdrinfo.origmessageid, -- BD_ORIG_MSG_ID -- 137SO
                        ocdrinfo.origimei, -- BD_ORIG_IMEI -- 139SO
                        ocdrinfo.origpaniheader, -- BD_PANI_HEADER -- 140SO -- 139SO
                        ocdrinfo.bioclientid, -- BD_BIO_CLIENT_ID     -- 145SO
                        ocdrinfo.bioorigesmeid, -- BD_BIO_ORIG_ESME_ID  -- 145SO
                        ocdrinfo.biomsgreference, -- BD_BIO_MSG_REF       -- 145SO
                        ocdrinfo.recipesmeid, -- BD_RECIP_ESME_ID     -- 145SO
                        ocdrinfo.biorequesttype, -- BD_BIO_REQ_TYPE      -- 145SO
                           -- BD_SIGNATURE                                                 -- 146SO
                           -- 01: ZERO     0=zero charged, 1=nonzero charged or not charged
                           -- 02: BILLED   1=billed, 0=not billed, 2=uninitialized, ... 8=recv-frng , 9=ogti-frng (see table BDBSTATE)
                           -- 03: MAPSID   E=Error, M=Mapping
                           -- 04: ORIGIN   S=SS7, I=IMS, E=SMSBroker, R=RCS, A=AO, G=Generated, H=HomeRouted, M=M2M(HRON)
                           -- 05: ORIGNET  S=System(Swisscom+TFL), C=CH, F=Foreign, U=Unknown
                           -- 06: DEST     S=SS7, I=IMS, E=Extern, R=RCS, A=AT, G=Generated, U=Unknown
                           -- 07: DESTNET  S=System(Swisscom+TFL), C=CH, F=Foreign, U=Unknown
                           -- 08: MSISDN   T=TFL(42377..), S=others(Swisscom)
                           -- 09: PREPAID  Y=yes, N=no, U=unknown
                           -- 10: TARID    L=LA, S=BN-IS, P=Portal-IS, I=Tariff i, T=Televote, V=free-free, X=intern or '-' =P2P
                           -- 11: STATUS   0=delivered, 1=expired, 2=deleted, 3=replaced, 4=submitted
                           -- 12: BIOREQT  0=standalone (chargeable), 1=standalone+link (not chargeable), 2=break_out_delivery, U=unknown  -- 147SO
                           -- 13: RATZONE  0=normal, 1=la-handygroup(SMS-HG-a/SMS-HG-b/SMS-HG-d) -- 147SO
                           -- 14: MOPROM   0=no, 1=yes                                     -- 147SO
                           -- 15: MONITORED 0=no/implicit, 1=explicit                      -- 156SO -- 147SO
                           -- 16: RESERVED '-'=unused                                      -- 147SO
                           -- 17: RESERVED '-'=unused                                      -- 147SO
                           DECODE (ocdrinfo.amountcustomer, 0.0, '0', '1')
                        || ocdrinfo.cdrbilled
                        || ocdrinfo.mappingstateid
                        || l_origin
                        || l_orignet
                        || l_dest
                        || l_destnet
                        || DECODE (SUBSTR (l_origin || ocdrinfo.origaddress, 1, 6),  'S42377', 'T',  'I42377', 'T',  'R42377', 'T',  'S')
                        || NVL (ocdrinfo.prepaid, '-')
                        || DECODE (ocdrinfo.tariffid,  'X', 'X',  'V', 'V',  'S', 'S',  'P', 'P',  'T', 'T',  NULL, '-',  'L')
                        || ocdrinfo.msgstatus
                        || DECODE (ocdrinfo.biorequesttype,  0, '0',  1, '1',  2, '2',  NULL, 'U')
                        || DECODE (SUBSTR (ocdrinfo.ratingzoneid, 1, 6), 'SMS-HG', '1', '0') -- 147SO
                        || DECODE (ocdrinfo.moroamingpromotion, 1, '1', '0') -- 147SO
                        || DECODE (ocdrinfo.cdrmonitored, 1, '1', '0') -- 156SO -- 147SO
                        || '-' -- 147SO
                        || '-', -- 147SO
                        ocdrinfo.moroamingpromotion, -- 147SO
                        ocdrinfo.cdrmonitored, -- 696SO 'BD_MONITORED'
                        ocdrinfo.packingidmon, -- 696SO 'BD_PACIDMON'
                        ocdrinfo.outputmon -- 696SO 'BD_OUTPUTMON'
                                          );
            ELSE
                INSERT INTO bdetail2 (
                                bd_id,
                                bd_srctype,
                                bd_demo,
                                bd_bihid,
                                bd_mapsid,
                                bd_birecno,
                                bd_pacsid1,
                                bd_pacsid2,
                                bd_pacsid3,
                                bd_msisdn_a,
                                bd_ton_a,
                                bd_npi_a,
                                bd_pid_a,
                                bd_datetime,
                                bd_datesubmit,
                                bd_pid_b,
                                bd_status,
                                bd_consolidation,
                                bd_vsmscid,
                                bd_length,
                                bd_imsi,
                                bd_prepaid,
                                bd_ogti,
                                bd_dgti,
                                bd_amountcu,
                                bd_retsharemo,
                                bd_retsharepv,
                                bd_conid,
                                bd_tarid, -- 017SO
                                bd_znid,
                                bd_tocid,
                                bd_cdrtid, -- 012AA
                                bd_int, -- 012AA
                                bd_iw, -- 012AA
                                bd_errid,
                                bd_billed,
                                bd_rated,
                                bd_pacidhb,
                                bd_outputhb,
                                bd_origsubmit, -- 054SO
                                bd_billid, -- 054SO
                                bd_onlinecharge, -- 068SO
                                bd_messagereference, -- 068SO
                                bd_smscid, -- 070SO
                                bd_originatorimsi,
                                bd_dser, -- 113SO
                                bd_origsca, -- 113SO
                                bd_generated, -- 114SO
                                bd_sca_opkey, -- 118SO
                                bd_ogti_opkey, -- 117SO
                                bd_deliver_opkey, -- 117SO
                                bd_dgti_opkey, -- 117SO
                                bd_submit_us, -- 124SO
                                bd_submit_gt,
                                bd_submit_app,
                                bd_orig_charset,
                                bd_orig_esme_id,
                                bd_orig_ip,
                                bd_deliver_us,
                                bd_deliver_att,
                                bd_deliver_adr,
                                bd_deliver_ton,
                                bd_deliver_npi,
                                bd_deliver_esme_id,
                                bd_deliver_ip,
                                bd_msgreqtype,
                                bd_msgscheduletime,
                                bd_msgexpirytime,
                                bd_seg_id,
                                bd_seg_count,
                                bd_err_type,
                                bd_err_code,
                                bd_dia_result,
                                bd_recip_imsi, -- 125SO
                                bd_recip_adr, -- 126SO
                                bd_recip_ton, -- 126SO
                                bd_recip_npi, -- 126SO
                                bd_iw_amount, -- 128SO
                                bd_iw_apmn, -- 128SO
                                bd_iw_curid, -- 128SO
                                bd_iw_dir, -- 128SO
                                bd_iw_scenario, -- 128SO
                                bd_iw_constate, -- 128SO
                                bd_msisdn_b, -- 132SO
                                bd_ton_b, -- 132SO
                                bd_npi_b, -- 132SO
                                bd_amounttr, -- 135SO
                                bd_orig_dcs, -- 136SO
                                bd_orig_msg_id, -- 137SO
                                bd_orig_imei, -- 139SO
                                bd_deliver_imei, -- 139SO
                                bd_pani_header, -- 139SO
                                bd_deliver_pani_header, -- 141SO
                                bd_deliver_map_gti, -- 141SO
                                bd_bio_client_id, -- 145SO
                                bd_bio_orig_esme_id, -- 145SO
                                bd_bio_msg_ref, -- 145SO
                                bd_recip_esme_id, -- 145SO
                                bd_bio_req_type, -- 145SO
                                bd_signature, -- 146SO
                                bd_mo_roaming_prom, -- 147SO
                                bd_monitored, -- 696SO
                                bd_pacidmon, -- 696SO
                                bd_outputmon -- 696SO
                                            )
                    VALUES      (
                        ocdrinfo.billingdetailid,
                        p_srctype,
                        0,
                        p_bihid,
                        ocdrinfo.mappingstateid,
                        p_recordnr,
                        ocdrinfo.schedule1,
                        ocdrinfo.schedule2,
                        ocdrinfo.schedule3,
                        ocdrinfo.origaddress,
                        ocdrinfo.origaddresston,
                        ocdrinfo.origaddressnpi,
                        ocdrinfo.msgpid,
                        TO_DATE (ocdrinfo.datetime, cstrmecdatetimeformat), -- 055SO
                        TO_DATE (ocdrinfo.requesttime, cstrmecdatetimeformat),
                        ocdrinfo.deliverpid,
                        ocdrinfo.msgstatus,
                        ocdrinfo.shortid,
                        ocdrinfo.vsmscid,
                        ocdrinfo.seglength,
                        ocdrinfo.deliverimsi,
                        ocdrinfo.prepaid,
                        ocdrinfo.origgti,
                        ocdrinfo.delivergti,
                        ocdrinfo.amountcustomer,
                        ocdrinfo.revenuesharemobile,
                        ocdrinfo.revenueshareprovider,
                        ocdrinfo.vascontractid,
                        ocdrinfo.tariffid, -- 057SO-- 017SO
                        ocdrinfo.ratingzoneid,
                        ocdrinfo.interworkingcontractid,
                        ocdrinfo.cdrtypeid, -- 012AA
                        ocdrinfo.foreignrecipient, -- 012AA
                        ocdrinfo.interworkingcase, -- 012AA
                        ocdrinfo.errorid,
                        ocdrinfo.cdrbilled,
                        ocdrinfo.cdrrated,
                        ocdrinfo.packingidhb,
                        ocdrinfo.outputhb,
                        TO_DATE (ocdrinfo.origsubmittime, cstrmecdatetimeformat), -- 054SO
                        ocdrinfo.origbillingid, -- 054SO
                        ocdrinfo.onlinecharge, -- 068SO
                        l_msgreference, -- 142SO -- 068SO
                        l_smscid, -- 070SO
                        ocdrinfo.origimsi,
                        ocdrinfo.dser, -- 113SO
                        ocdrinfo.origsca, -- 113SO
                        ocdrinfo.isgenerated, -- 114SO
                        ocdrinfo.scaopkey, -- 118SO
                        ocdrinfo.origgtiopkey, -- 117SO
                        ocdrinfo.deliveropkey, -- 117SO
                        ocdrinfo.delivergtiopkey, -- 117SO
                        ocdrinfo.submitmicros, -- 'BD_SUBMIT_US'
                        ocdrinfo.submitgti, -- 'BD_SUBMIT_GT'
                        ocdrinfo.submitapp, -- 'BD_SUBMIT_APP'
                        ocdrinfo.origcharset, -- 'BD_ORIG_CHARSET'
                        ocdrinfo.origesmeid, -- 'BD_ORIG_ESME_ID'
                        ocdrinfo.origip, -- 'BD_ORIG_IP'
                        ocdrinfo.delivermicros, -- 'BD_DELIVER_US'
                        ocdrinfo.deliverattempt, -- 'BD_DELIVER_ATT'
                        ocdrinfo.deliveraddress, -- 'BD_DELIVER_ADR'
                        ocdrinfo.deliveraddresston, -- 'BD_DELIVER_TON'
                        ocdrinfo.deliveraddressnpi, -- 'BD_DELIVER_NPI'
                        ocdrinfo.deliveresmeid, -- 'BD_DELIVER_ESME_ID'
                        ocdrinfo.deliverip, -- 'BD_DELIVER_IP'
                        ocdrinfo.msgreqtype, -- 'BD_MSGREQTYPE'
                        TO_DATE (ocdrinfo.msgscheduletime, cstrmecdatetimeformat), -- 'BD_MSGSCHEDULETIME' -- 130SO
                        TO_DATE (ocdrinfo.msgexpirytime, cstrmecdatetimeformat), -- 'BD_MSGEXPIRYTIME'   -- 130SO
                        l_segmentid, -- 'BD_SEG_ID'          -- 142SO
                        ocdrinfo.segcount, -- 'BD_SEG_COUNT'
                        ocdrinfo.errortype, -- 'BD_ERR_TYPE'
                        ocdrinfo.errorcode, -- 'BD_ERR_CODE'
                        ocdrinfo.diaresult, -- 'BD_DIA_RESULT'
                        ocdrinfo.recipimsi, -- 'BD_RECIP_IMSI'-- 125SO
                        ocdrinfo.recipaddress, -- 'BD_RECIP_ADR'  -- 126SO
                        ocdrinfo.recipaddresston, -- 'BD_RECIP_TON'  -- 126SO
                        ocdrinfo.recipaddressnpi, -- 'BD_RECIP_NPI'  -- 126SO
                        ocdrinfo.interworkingamount, -- 'BD_IW_AMOUNT'   -- 128SO
                        ocdrinfo.interworkingapmn, -- 'BD_IW_APMN'     -- 128SO
                        ocdrinfo.interworkingcurrency, -- 'BD_IW_CURID'    -- 128SO
                        ocdrinfo.interworkingdirection, -- 'BD_IW_DIR'      -- 128SO
                        ocdrinfo.interworkingscenario, -- 'BD_IW_SCENARIO' -- 128SO
                        ocdrinfo.interworkingstate, -- 'BD_IW_CONSTATE' -- 128SO
                        ocdrinfo.deliveraddress, -- BD_MSISDN_B -- 132SO
                        ocdrinfo.deliveraddresston, -- BD_TON_B -- 132SO
                        ocdrinfo.deliveraddressnpi, -- BD_NPI_B -- 132SO
                        ocdrinfo.transportcost, -- BD_AMOUNTTR  -- 135SO
                        ocdrinfo.origdcs, -- BD_ORIG_DCS -- 136SO
                        ocdrinfo.origmessageid, -- BD_ORIG_MSG_ID -- 137SO
                        ocdrinfo.origimei, -- BD_ORIG_IMEI -- 139SO
                        ocdrinfo.deliverimei, -- BD_DELIVER_IMEI -- 139SO
                        ocdrinfo.origpaniheader, -- BD_PANI_HEADER -- 140SO-- 139SO
                        ocdrinfo.deliverpaniheader, -- BD_DELIVER_PANI_HEADER -- 141SO
                        ocdrinfo.delivermapgti, -- BD_DELIVER_MAP_GTI  -- 141SO
                        ocdrinfo.bioclientid, -- BD_BIO_CLIENT_ID     -- 145SO
                        ocdrinfo.bioorigesmeid, -- BD_BIO_ORIG_ESME_ID  -- 145SO
                        ocdrinfo.biomsgreference, -- BD_BIO_MSG_REF       -- 145SO
                        ocdrinfo.recipesmeid, -- BD_RECIP_ESME_ID     -- 145SO
                        ocdrinfo.biorequesttype, -- BD_BIO_REQ_TYPE      -- 145SO
                           -- BD_SIGNATURE                                                 -- 146SO
                           -- 01: ZERO     0=zero charged, 1=nonzero charged or not charged
                           -- 02: BILLED   1=billed, 0=not billed, 2=uninitialized, ... 8=recv-frng , 9=ogti-frng (see table BDBSTATE)
                           -- 03: MAPSID   E=Error, M=Mapping
                           -- 04: ORIGIN   S=SS7, I=IMS, E=SMSBroker, R=RCS, A=AO, G=Generated, H=HomeRouted, M=M2M(HRON)
                           -- 05: ORIGNET  S=System(Swisscom+TFL), C=CH, F=Foreign, U=Unknown
                           -- 06: DEST     S=SS7, I=IMS, E=Extern, R=RCS, A=AT, G=Generated, U=Unknown
                           -- 07: DESTNET  S=System(Swisscom+TFL), C=CH, F=Foreign, U=Unknown
                           -- 08: MSISDN   T=TFL(42377..), S=others(Swisscom)
                           -- 09: PREPAID  Y=yes, N=no, U=unknown
                           -- 10: TARID    L=LA, S=BN-IS, P=Portal-IS, I=Tariff i, T=Televote, V=free-free, X=intern or '-' =P2P
                           -- 11: STATUS   0=delivered, 1=expired, 2=deleted, 3=replaced, 4=submitted
                           -- 12: BIOREQT  0=standalone (chargeable), 1=standalone+link (not chargeable), 2=break_out_delivery, U=unknown  -- 147SO
                           -- 13: RATZONE  0=normal, 1=la-handygroup(SMS-HG-a/SMS-HG-b/SMS-HG-d) -- 147SO
                           -- 14: MOPROM   0=no, 1=yes                                     -- 147SO
                           -- 15: MONITORED 0=no/implicit, 1=explicit                      -- 156SO -- 147SO
                           -- 16: RESERVED '-'=unused                                      -- 147SO
                           -- 17: RESERVED '-'=unused                                      -- 147SO
                           DECODE (ocdrinfo.amountcustomer, 0.0, '0', '1')
                        || ocdrinfo.cdrbilled
                        || ocdrinfo.mappingstateid
                        || l_origin
                        || l_orignet
                        || l_dest
                        || l_destnet
                        || DECODE (SUBSTR (l_dest || ocdrinfo.deliveraddress, 1, 6),  'S42377', 'T',  'I42377', 'T',  'R42377', 'T',  'S')
                        || NVL (ocdrinfo.prepaid, '-')
                        || DECODE (ocdrinfo.tariffid,  'X', 'X',  'V', 'V',  'S', 'S',  'P', 'P',  'T', 'T',  NULL, '-',  'L')
                        || ocdrinfo.msgstatus
                        || DECODE (ocdrinfo.biorequesttype,  0, '0',  1, '1',  2, '2',  NULL, 'U')
                        || DECODE (SUBSTR (ocdrinfo.ratingzoneid, 1, 6), 'SMS-HG', '1', '0') -- 147SO
                        || DECODE (ocdrinfo.moroamingpromotion, 1, '1', '0') -- 147SO
                        || DECODE (ocdrinfo.cdrmonitored, 1, '1', '0') -- 156SO -- 147SO
                        || '-' -- 147SO
                        || '-', -- 147SO
                        ocdrinfo.moroamingpromotion, -- 147SO
                        ocdrinfo.cdrmonitored, -- 696SO 'BD_MONITORED'
                        ocdrinfo.packingidmon, -- 696SO 'BD_PACIDMON'
                        ocdrinfo.outputmon -- 696SO 'BD_OUTPUTMON'
                                          );

                IF     NOT (l_smscid IS NULL)
                   AND ocdrinfo.schedule1 = 'S'
                THEN
                    -- Populate archive table for SC terminating IW SMS
                    INSERT INTO sms_iw_mt_arch (
                                    bda_day,
                                    bda_smscid,
                                    bda_bihid,
                                    bda_birecno,
                                    bda_sca,
                                    bda_datetime,
                                    bda_msisdn_a,
                                    bda_imsi,
                                    bda_msisdn_b,
                                    bda_mscid)
                    VALUES      (
                        TRUNC (TO_DATE (ocdrinfo.datetime, cstrmecdatetimeformat)),
                        l_smscid,
                        p_bihid,
                        p_recordnr,
                        ocdrinfo.origsca, -- 125SO
                        TO_DATE (ocdrinfo.datetime, cstrmecdatetimeformat),
                        ocdrinfo.recipaddress,
                        ocdrinfo.recipimsi, -- 126SO
                        ocdrinfo.origaddress,
                        ocdrinfo.submitgti);
                END IF;
            END IF;

            p_inserted := p_inserted + 1; -- 143SO

            IF     p_softerrorid IS NULL
               AND ocdrinfo.mappingstateid <> cstrmappingstatesuccess
            THEN
                p_softerrorid := ocdrinfo.errorid; -- first error only !
            END IF;

            IF ocdrinfo.mappingstateid <> cstrmappingstatesuccess
            THEN
                p_softerrorcount := p_softerrorcount + 1; -- 152SO
            END IF;
        END LOOP;

        RETURN;
    --    Exception
    --        When others then
    --            -- 110SO
    --            L('p_BihId**********',p_BihId);
    --            L('p_RecordNr*******',p_RecordNr);
    --            L('Error*******',PKG_COMMON.getHardErrorDesc);  -- 130SO
    --            L('BD_AMOUNTCU',oCdrInfo.AmountCustomer);
    --            L('BD_BIHID',p_BihId);
    --            L('BD_BILLED',oCdrInfo.CdrBilled);
    --            L('BD_BILLID',oCdrInfo.OrigBillingId);
    --            L('BD_BIRECNO',p_RecordNr);
    --            L('BD_CDRTID',oCdrInfo.CdrTypeId);
    --            L('BD_CONID',oCdrInfo.VasContractId);
    --            L('BD_CONSOLIDATION',oCdrInfo.ShortId);
    --            L('BD_DATESUBMIT',oCdrInfo.SubmitTime);
    --            L('BD_DATETIME',oCdrInfo.DateTime);
    --            L('BD_DELIVER_ADR',oCdrInfo.DeliverAddress);
    --            L('BD_DELIVER_ATT',oCdrInfo.DeliverAttempt);
    --            L('BD_DELIVER_ESME_ID',oCdrInfo.DeliverEsmeId);
    --            L('BD_DELIVER_IP',oCdrInfo.DeliverIp);
    --            -- L('BD_DELIVER_NPI',oCdrInfo.DeliverNpi);
    --            -- L('BD_DELIVER_TON',oCdrInfo.DeliverTon);
    --            L('BD_DELIVER_US',oCdrInfo.DeliverMicros);
    --            L('BD_DEMO',0);
    --            L('BD_DGTI',oCdrInfo.DeliverGti);
    --            L('BD_DGTI_OPKEY',oCdrInfo.DeliverGtiOpKey);
    --            L('BD_DIA_RESULT',oCdrInfo.DiaResult);
    --            L('BD_ERRID',oCdrInfo.ErrorId);
    --            L('BD_ERR_CODE',oCdrInfo.ErrorCode);
    --            L('BD_ERR_TYPE',oCdrInfo.ErrorType);
    --            L('BD_ID',oCdrInfo.BillingDetailId);
    --            L('BD_IMSI',oCdrInfo.DeliverImsi);
    --            L('BD_INT',oCdrInfo.ForeignRecipient);
    --            L('BD_IW',oCdrInfo.InterworkingCase);
    --            L('BD_LENGTH',oCdrInfo.SegLength);
    --            L('BD_MAPSID',oCdrInfo.MappingStateId);
    --            L('BD_MESSAGEREFERENCE',oCdrInfo.MsgReference);
    --            L('BD_MSGEXPIRYTIME',oCdrInfo.MsgExpiryTime);
    --            L('BD_MSGREQTYPE',oCdrInfo.MsgReqType);
    --            L('BD_MSGSCHEDULETIME',oCdrInfo.MsgScheduleTime);
    --            L('BD_MSISDN_A',oCdrInfo.OrigAddress);
    --            L('BD_MSISDN_B',oCdrInfo.RecipAddress);
    --            L('BD_NPI_A',oCdrInfo.OrigAddressNpi);
    --            L('BD_NPI_B',oCdrInfo.RecipAddressNpi);
    --            L('BD_OGTI',oCdrInfo.OrigGti);
    --            L('BD_OGTI_OPKEY',oCdrInfo.OrigGtiOpKey);
    --            L('BD_ONLINECHARGE',oCdrInfo.OnlineCharge);
    --            L('BD_ORIGSUBMIT',oCdrInfo.OrigSubmitTime);
    --            L('BD_ORIG_CHARSET',oCdrInfo.OrigCharset);
    --            L('BD_ORIG_SUBMIT_APP',oCdrInfo.SubmitApp);
    --            L('BD_ORIG_ESME_ID',oCdrInfo.OrigEsmeId);
    --            L('BD_ORIG_IP',oCdrInfo.OrigIp);
    --            L('BD_OUTPUTHB',oCdrInfo.OutputHb);
    --            L('BD_PACIDHB',oCdrInfo.PackingIdHb);
    --            L('BD_PACSID1',oCdrInfo.Schedule1);
    --            L('BD_PACSID2',oCdrInfo.Schedule2);
    --            L('BD_PACSID3',oCdrInfo.Schedule3);
    --            L('BD_PID_A',oCdrInfo.MsgPid);
    --            L('BD_PID_B',oCdrInfo.DeliverPid);
    --            L('BD_PREPAID',oCdrInfo.Prepaid);
    --            L('BD_RATED',oCdrInfo.CdrRated);
    --            L('BD_RECIP_IMSI',oCdrInfo.RecipImsi);
    --            L('BD_DELIVER_OPKEY',oCdrInfo.DeliverOpKey);
    --            L('BD_RETSHAREMO',oCdrInfo.RevenueShareMobile);
    --            L('BD_RETSHAREPV',oCdrInfo.RevenueShareProvider);
    --            L('BD_SCA_OPKEY',oCdrInfo.ScaOpKey);
    --            L('BD_SEG_COUNT',oCdrInfo.Segcount);
    --            L('BD_SEG_ID',oCdrInfo.SegId);
    --            L('BD_SMSCID',l_SmscId);
    --            L('BD_SRCTYPE',p_SrcType);
    --            L('BD_STATUS',oCdrInfo.MsgStatus);
    --            L('BD_SUBMIT_APP',oCdrInfo.SubmitApp);
    --            L('BD_SUBMIT_GT',oCdrInfo.SubmitMicros);
    --            L('BD_TARID',oCdrInfo.TariffId);
    --            L('BD_TOCID',oCdrInfo.InterworkingContractId);
    --            L('BD_TON_A',oCdrInfo.OrigAddressTon);
    --            L('BD_TON_B',oCdrInfo.RecipAddressTon);
    --            L('BD_VSMSCID',oCdrInfo.VsmscId);
    --            L('BD_ZNID',oCdrInfo.RatingZoneId);
    --            L('BD_IW_AMOUNT',oCdrInfo.InterworkingAmount);      -- 130SO
    --            L('BD_IW_APMN',oCdrInfo.InterworkingApmn);          -- 130SO
    --            L('BD_IW_CURID',oCdrInfo.InterworkingCurrency);     -- 130SO
    --            L('BD_IW_DIR',oCdrInfo.InterworkingDirection);      -- 130SO
    --            L('BD_IW_SCENARIO',oCdrInfo.InterworkingScenario);  -- 130SO
    --            L('BD_IW_CONSTATE',oCdrInfo.InterworkingState);     -- 130SO
    --           RAISE;
    END insert_csv_smsn;
END pkg_mec_ic_ascii0;
/