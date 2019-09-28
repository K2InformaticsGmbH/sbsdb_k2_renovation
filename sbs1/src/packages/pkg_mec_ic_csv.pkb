CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_mec_ic_csv
IS
    cstrtab                                 VARCHAR2 (1) := CHR (9);

    cstrcomma                               VARCHAR2 (1) := ','; -- 080DA
    cstrcr                                  VARCHAR2 (1) := CHR (13);
    cstrfieldseparator                      VARCHAR2 (1) := cstrtab;
    cstrlf                                  VARCHAR2 (1) := CHR (10);
    cstrmecdatetimeformat                   VARCHAR2 (20) := 'YYYYMMDDHH24MISS';
    cstrsemicolon                           VARCHAR2 (1) := ';'; -- 080DA
    rmappingstate                           pkg_common_mapping.tmapesid; -- 009SO -- 007SO
    rsourcetype                             pkg_common.tsrctype; -- 007SO

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_ccndc (
        p_srctype                               IN     VARCHAR2, -- 010SO
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2,
        p_recordnr                              IN     NUMBER,
        p_recorddata                            IN     VARCHAR2,
        p_recordversion                         IN     VARCHAR2, -- 011SO
        p_inserted                                 OUT BOOLEAN,
        p_ignored                                  OUT BOOLEAN,
        p_datetime                                 OUT VARCHAR2,
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    PROCEDURE insert_csv_mccmnc (
        p_srctype                               IN     VARCHAR2, -- 010SO
        p_bihid                                 IN     VARCHAR2,
        p_dataheader                            IN     VARCHAR2,
        p_recordnr                              IN     NUMBER,
        p_recorddata                            IN     VARCHAR2,
        p_recordversion                         IN     VARCHAR2, -- 011SO
        p_inserted                                 OUT BOOLEAN,
        p_ignored                                  OUT BOOLEAN,
        p_datetime                                 OUT VARCHAR2,
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2);

    /* =========================================================================
       Public Function Implemenatation.
       ---------------------------------------------------------------------- */

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
        l_srctype                               VARCHAR2 (10);

        l_inserted                              BOOLEAN;
        l_ignored                               BOOLEAN;
        l_error                                 BOOLEAN;
        l_datetime                              VARCHAR2 (20);
        l_softerrorid                           VARCHAR2 (10);
        l_softerrdesc                           VARCHAR2 (2000);

        l_count_errors                          BOOLEAN := TRUE; -- Rec counting default behaviour
        l_count_ignores                         BOOLEAN := TRUE; -- Rec counting default behaviour
        l_recordindex                           PLS_INTEGER;
        l_record_version                        VARCHAR2 (20); -- 011SO
    BEGIN
        -- get source type from biheader id
        l_srctype := pkg_common_mapping.getsrctypeforbiheader (p_bihid); -- 009SO
        l_record_version := NULL; -- 011SO (may later be extracted from the header)

        IF p_batchsize > 0
        THEN
            IF p_recordnr (1) < p_batchsize
            THEN
                -- used to detect the first batch                                   -- 019SO
                IF l_srctype = rsourcetype.ccndc
                THEN
                    DELETE FROM all_cc_ndc; -- 019SO
                ELSIF l_srctype = rsourcetype.mccmnc
                THEN
                    DELETE FROM all_mcc_mnc; -- 019SO
                END IF;
            END IF;
        END IF;

        FOR i IN 1 .. p_batchsize
        LOOP
            l_recordindex := i;
            l_error := FALSE;

            IF l_srctype = rsourcetype.ccndc
            THEN
                insert_csv_ccndc (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_ignored,
                    l_datetime,
                    l_softerrorid,
                    l_softerrdesc); -- 010SO
            ELSIF l_srctype = rsourcetype.mccmnc
            THEN
                insert_csv_mccmnc (
                    l_srctype,
                    p_bihid,
                    p_dataheader,
                    p_recordnr (i),
                    p_recorddata (i),
                    l_record_version,
                    l_inserted,
                    l_ignored,
                    l_datetime,
                    l_softerrorid,
                    l_softerrdesc); -- 010SO
            END IF;

            -- set first and last datetime of record and do the record counting
            IF l_inserted
            THEN
                p_reccount := p_reccount + 1;

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
            ELSE
                IF l_ignored
                THEN
                    IF l_count_ignores
                    THEN
                        p_reccount := p_reccount + 1;
                    END IF;
                ELSE
                    -- must be an error, even when not specified in  l_SoftErrorId or l_SoftErrDesc
                    l_error := TRUE;
                    p_errcount := p_errcount + 1;

                    IF l_count_errors
                    THEN
                        p_reccount := p_reccount + 1;
                    END IF;
                END IF;
            END IF;

            -- soft error logging
            IF l_error
            THEN
                pkg_common.insert_warning ( -- 007SO
                    'PKG_MEC_IC_CSV',
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
        THEN -- not used yet
            p_errorcode := pkg_common.eno_missing_header_fld;
            p_errordesc := pkg_common.edesc_missing_header_fld || ': ????? in *** ' || p_dataheader;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errordesc := pkg_common.getharderrordesc; -- 014SO
            p_returnstatus := pkg_common.return_status_failure; -- 014SO
            -- hard error logging                                                   -- 005SO
            pkg_common.insert_warning ( -- 007SO
                'PKG_MEC_IC_CSV',
                'SP_INSERT_CSV',
                'INSERT_CSV_' || l_srctype,
                p_errordesc || ' *** ' || p_recorddata (l_recordindex), -- 014SO
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
    IS
        l_srctype                               VARCHAR2 (10); -- 004SO
    BEGIN
        pkg_common_mapping.insert_biheader ( -- 009SO -- 007SO -- 003SO
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

        l_srctype := pkg_common_mapping.getsrctypeforbiheader (p_bih_id); -- 009SO

        IF l_srctype = rsourcetype.ccndc
        THEN
            DELETE FROM all_cc_ndc;
        ELSIF l_srctype = rsourcetype.mccmnc
        THEN
            DELETE FROM all_mcc_mnc;
        END IF;

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
            p_errordesc := pkg_common.getharderrordesc; -- 014SO
            p_returnstatus := pkg_common.return_status_failure;
    END sp_insert_header;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE sp_update_header (
        p_bihid                                 IN     VARCHAR2,
        p_maxage                                IN     NUMBER, -- TODO unused parameter? (wwe)
        p_dataheader                            IN     VARCHAR2, -- 012SO -- TODO unused parameter? (wwe)
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
    BEGIN
        l_srctype := pkg_common_mapping.getsrctypeforbiheader (p_bihid); -- 009SO

        -- Update the given Biheader Id with the information supplied
        IF p_errcount + p_preparseerrcount = 0
        THEN
            l_headerstate := 'RDY';
        ELSE
            l_headerstate := 'ERR';
        END IF;

        UPDATE biheader
        SET    bih_esid = l_headerstate,
               bih_datefc = TO_DATE (p_datefc, cstrmecdatetimeformat), -- 013DA
               bih_datelc = TO_DATE (p_datelc, cstrmecdatetimeformat), -- 013DA
               bih_reccount = p_reccount,
               bih_errcount = p_errcount + p_preparseerrcount,
               bih_end = SYSDATE
        WHERE  bih_id = p_bihid;

        UPDATE mapping
        SET    map_datedone = SYSDATE -- 016SO
        WHERE  map_id IN (SELECT bih_mapid
                          FROM   biheader
                          WHERE  bih_id = p_bihid);

        p_returnstatus := pkg_common.return_status_ok;
        RETURN;
    EXCEPTION
        WHEN pkg_common.excp_missing_header_fld
        THEN -- not used yet
            p_errorcode := pkg_common.eno_missing_header_fld;
            p_errordesc := pkg_common.edesc_missing_header_fld;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN pkg_common.excp_reccount_mismatch
        THEN -- 014SO not used yet
            p_errorcode := pkg_common.eno_reccount_mismatch;
            p_errordesc := pkg_common.edesc_reccount_mismatch;
            p_returnstatus := pkg_common.return_status_failure;
        WHEN OTHERS
        THEN
            p_errorcode := SQLCODE;
            p_errordesc := pkg_common.getharderrordesc; -- 014SO
            p_returnstatus := pkg_common.return_status_failure;
            RETURN;
    END sp_update_header;

    /* =========================================================================
       Private Function Implemenatation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_ccndc (
        p_srctype                               IN     VARCHAR2, -- 010SO -- TODO unused parameter? (wwe)
        p_bihid                                 IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_dataheader                            IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- TODO unused parameter? (wwe)
        p_recorddata                            IN     VARCHAR2,
        p_recordversion                         IN     VARCHAR2, -- 011SO -- TODO unused parameter? (wwe)
        p_inserted                                 OUT BOOLEAN,
        p_ignored                                  OUT BOOLEAN,
        p_datetime                                 OUT VARCHAR2,
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS
        TYPE tccndcrecinfo IS RECORD
        (
            ccandndc VARCHAR2 (20),
            country_name VARCHAR2 (100),
            operator_name VARCHAR2 (100),
            operatorkey VARCHAR2 (100), -- 006SO allow some reserve for checking
            location VARCHAR2 (100)
        );

        l_recorddata                            VARCHAR2 (4000);
        l_orecinfo                              tccndcrecinfo;
    BEGIN
        p_inserted := FALSE;
        p_ignored := FALSE;
        p_datetime := NULL;
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- tab-separated data
        l_recorddata := p_recorddata;

        -- split the values and assign them to the structure one by one
        l_orecinfo.ccandndc := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon); -- 015SO
        l_orecinfo.country_name := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.operator_name := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.operatorkey := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.location := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);

        IF pkg_common.sp_is_numeric (l_orecinfo.operatorkey) = 0
        THEN
            p_ignored := TRUE; -- 021SO -- 017SO -- 006SO
        END IF;

        IF NOT p_ignored
        THEN
            INSERT INTO all_cc_ndc (
                            acndc_nbr,
                            acndc_country,
                            acndc_opname,
                            acndc_opkey)
            VALUES      (
                            l_orecinfo.ccandndc,
                            l_orecinfo.country_name,
                            l_orecinfo.operator_name,
                            SUBSTR (l_orecinfo.operatorkey, 1, 20) -- 018SO
                                                                  );

            p_inserted := TRUE;
        END IF;

        RETURN;
    EXCEPTION
        -- 005SO
        -- When INVALID_NUMBER Then
        --     p_SoftErrorId := '';
        --     p_SoftErrDesc := 'INVALID_NUMBER';
        -- When VALUE_ERROR Then
        --     p_SoftErrorId := '';
        --     p_SoftErrDesc := 'VALUE_ERROR';
        WHEN OTHERS
        THEN
            RAISE;
    END insert_csv_ccndc;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    PROCEDURE insert_csv_mccmnc (
        p_srctype                               IN     VARCHAR2, -- 010SO -- TODO unused parameter? (wwe)
        p_bihid                                 IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_dataheader                            IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_recordnr                              IN     NUMBER, -- TODO unused parameter? (wwe)
        p_recorddata                            IN     VARCHAR2,
        p_recordversion                         IN     VARCHAR2, -- 011SO -- TODO unused parameter? (wwe)
        p_inserted                                 OUT BOOLEAN,
        p_ignored                                  OUT BOOLEAN,
        p_datetime                                 OUT VARCHAR2,
        p_softerrorid                              OUT VARCHAR2,
        p_softerrdesc                              OUT VARCHAR2)
    IS
        TYPE tmccmncrecinfo IS RECORD
        (
            mcc VARCHAR2 (10),
            mnc VARCHAR2 (10),
            country_name VARCHAR2 (100),
            operator_name VARCHAR2 (100),
            operator_key VARCHAR2 (100), -- 018SO
            start_date VARCHAR2 (20),
            ceased_date VARCHAR2 (20)
        );

        l_recorddata                            VARCHAR2 (4000);
        l_orecinfo                              tmccmncrecinfo;
    BEGIN
        p_inserted := FALSE;
        p_ignored := FALSE;
        p_datetime := NULL;
        p_softerrorid := NULL;
        p_softerrdesc := NULL;

        -- tab-separated data
        l_recorddata := p_recorddata;

        -- split the values and assign them to the structure one by one
        l_orecinfo.mcc := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon); -- 015SO
        l_orecinfo.mnc := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.country_name := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.operator_name := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.operator_key := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.start_date := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);
        l_orecinfo.ceased_date := pkg_common.cutfirstitem (l_recorddata, cstrsemicolon);

        IF pkg_common.is_numeric (l_orecinfo.operator_key) = 0
        THEN
            p_ignored := TRUE; -- 021SO
        END IF;

        IF NOT p_ignored
        THEN
            INSERT INTO all_mcc_mnc (
                            amcmnc_mcc,
                            amcmnc_mnc,
                            amcmnc_country,
                            amcmnc_opname,
                            amcmnc_opkey,
                            amcmnc_startdate,
                            amcmnc_ceasedate)
            VALUES      (
                            l_orecinfo.mcc,
                            l_orecinfo.mnc,
                            l_orecinfo.country_name,
                            l_orecinfo.operator_name,
                            SUBSTR (l_orecinfo.operator_key, 1, 20), -- 018SO
                            l_orecinfo.start_date,
                            l_orecinfo.ceased_date);

            p_inserted := TRUE;
        END IF;

        RETURN;
    EXCEPTION
        -- 005SO
        -- When INVALID_NUMBER Then
        --     p_SoftErrorId := '';
        --     p_SoftErrDesc := 'INVALID_NUMBER';
        -- When VALUE_ERROR Then
        --     p_SoftErrorId := '';
        --     p_SoftErrDesc := 'VALUE_ERROR';
        WHEN OTHERS
        THEN
            RAISE;
    END insert_csv_mccmnc;
END pkg_mec_ic_csv;
/
