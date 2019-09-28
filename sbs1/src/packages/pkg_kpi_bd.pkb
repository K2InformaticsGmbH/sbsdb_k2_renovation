CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_kpi_bd
AS
    max_age_minutes                CONSTANT PLS_INTEGER := 30;
    max_proc_seconds               CONSTANT PLS_INTEGER := 60;
    min_age_minutes                CONSTANT PLS_INTEGER := 1;
    minutes_per_day                CONSTANT PLS_INTEGER := 1440;
    seconds_per_day                CONSTANT PLS_INTEGER := 86400;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE do_work (
        sqlt_str_pacid                          IN VARCHAR2,
        sqlt_str_bihid                          IN VARCHAR2,
        sqlt_dat_datetime                       IN DATE,
        sqlt_str_context                        IN VARCHAR2);

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_kpi (
        sqlt_str_pacid                          IN     VARCHAR2, -- 'KPI000' ... 'KPI999'
        sqlt_str_bohid                          IN OUT VARCHAR2,
        sqlt_int_records                           OUT NUMBER,
        sqlt_int_error                             OUT NUMBER,
        sqlt_str_errormsg                          OUT VARCHAR2,
        sqlt_int_retstatus                         OUT NUMBER)
    IS
        CURSOR cfilecand IS
            SELECT   bih_id,
                     bih_datetime,
                     bih_reccount,
                        '"FILENAME":'
                     || pkg_json.json_string (bih_filename)
                     || ',"ESID":'
                     || pkg_json.json_string (bih_esid)
                     || ',"DATEFC":'
                     || pkg_json.json_date (bih_datefc)
                     || ',"DATELC":'
                     || pkg_json.json_date (bih_datelc)
                     || ',"RECCOUNT":'
                     || pkg_json.json_number (bih_reccount)
                     || ',"ERRCOUNT":'
                     || pkg_json.json_number (bih_errcount)    AS bih_context
            FROM     biheader
            WHERE        bih_datetime >= SYSDATE - max_age_minutes / minutes_per_day
                     AND bih_datetime < SYSDATE - min_age_minutes / minutes_per_day
                     AND bih_srctype = 'ISRV'
                     AND bih_mapid IN ('MBS_CO',
                                       'MVP_CO')
                     AND bih_esid IN ('RDY',
                                      'ERR')
                     AND bih_reccount > 0
                     AND bih_id NOT IN (SELECT DISTINCT bdk_bihid
                                        FROM   bdkpi
                                        WHERE      bdk_datetime >= SYSDATE - max_age_minutes / minutes_per_day
                                               AND bdk_pacid = sqlt_str_pacid)
            ORDER BY bih_id ASC;

        cfilecandrow                            cfilecand%ROWTYPE;

        start_time                              DATE;
        end_time                                DATE;
    BEGIN
        start_time := SYSDATE;
        end_time := start_time + max_proc_seconds / seconds_per_day;
        sqlt_int_error := 0;
        sqlt_str_errormsg := NULL;
        sqlt_int_records := 0;
        sqlt_int_retstatus := pkg_common.return_status_ok; -- assume this for now

        OPEN cfilecand ();

        FETCH cfilecand INTO cfilecandrow;

        IF cfilecand%FOUND
        THEN
            pkg_common_packing.insert_boheader_sptry (sqlt_str_pacid, sqlt_str_bohid);

            LOOP
                do_work (sqlt_str_pacid, cfilecandrow.bih_id, cfilecandrow.bih_datetime, cfilecandrow.bih_context);
                sqlt_int_records := sqlt_int_records + cfilecandrow.bih_reccount;
                COMMIT WORK;
                EXIT WHEN SYSDATE > end_time;

                FETCH cfilecand INTO cfilecandrow;

                EXIT WHEN cfilecand%NOTFOUND;
            END LOOP;
        END IF;

        CLOSE cfilecand;
    EXCEPTION
        WHEN pkg_common.excp_inconvenient_time
        THEN
            sqlt_int_error := pkg_common.eno_inconvenient_time;
            sqlt_str_errormsg := pkg_common.edesc_inconvenient_time;
            sqlt_int_retstatus := pkg_common.return_status_suspended;
            ROLLBACK;
    /*
        when PKG_COMMON_PACKING.EXCP_STATISTICS_FAILURE then
            ErrorCode := PKG_COMMON_PACKING.ENO_STATISTICS_FAILURE;
            ErrorMsg := PKG_COMMON_PACKING.EDESC_STATISTICS_FAILURE;
            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
            ROLLBACK;
        when PKG_COMMON_PACKING.EXCP_WORKFLOW_ABORT then
            ErrorCode := PKG_COMMON_PACKING.ENO_WORKFLOW_ABORT;
            ErrorMsg := PKG_COMMON_PACKING.EDESC_WORKFLOW_ABORT;
            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
            ROLLBACK;
        when Others then
            ErrorCode := SqlCode;
            ErrorMsg  := SqlErrM;
            ReturnStatus := PKG_COMMON.RETURN_STATUS_FAILURE;
            RecordsAffected := 0;
            ROLLBACK;
    */

    END sp_try_kpi;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE do_work (
        sqlt_str_pacid                          IN VARCHAR2,
        sqlt_str_bihid                          IN VARCHAR2,
        sqlt_dat_datetime                       IN DATE,
        sqlt_str_context                        IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO bdkpi (
                        bdk_id,
                        bdk_datetime,
                        bdk_pacid,
                        bdk_schema,
                        bdk_table,
                        bdk_bihid,
                        bdk_code,
                        bdk_value,
                        bdk_cvalue)
            (SELECT pkg_bdetail_common.generatebase36kpikey (),
                    sqlt_dat_datetime,
                    sqlt_str_pacid,
                    'SBS1',
                    'BDETAIL',
                    sqlt_str_bihid,
                    kpi_code,
                    ROUND (kpi_value, 4),
                    '{"CODE":' || pkg_json.json_string (kpi_code) || ',"VALUE":' || pkg_json.json_number (ROUND (kpi_value, 4)) || ',' || sqlt_str_context || '}'
             FROM   (SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            -- Average Customer Price MBS + MVP NonZero Prices only
                           'BdPrice(Price<>0)'     AS kpi_code,
                           AVG (bd_amountcu)       AS kpi_value
                     FROM  bdetail
                     WHERE     bd_mapsid = 'R'
                           AND NVL (bd_amountcu, 0) <> 0
                           AND bd_datetime >= SYSDATE - 1
                           AND bd_bihid = sqlt_str_bihid
                     UNION -- TODO UNION ALL instead of UNION? (wwe)
                     SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            -- Average revenue Share MBS + MVP NonZero Shares only
                           'BdRShare(Price<>0)'     AS kpi_code,
                           AVG (bd_retsharepv)      AS kpi_value
                     FROM  bdetail
                     WHERE     bd_mapsid = 'R'
                           AND NVL (bd_amountcu, 0) <> 0
                           AND bd_datetime >= SYSDATE - 1
                           AND bd_bihid = sqlt_str_bihid
                     UNION -- TODO UNION ALL instead of UNION? (wwe)
                     SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            -- Percentage of Zero Price for MBS + MVP
                           'BdRate(Price=0)'    AS kpi_code,
                           CASE
                               WHEN COUNT (*) = 0
                               THEN
                                   NULL
                               ELSE
                                   SUM (DECODE (bd_amountcu,  0, 0,  NULL, 0,  1)) / COUNT (*)
                           END                  AS kpi_value
                     FROM  bdetail
                     WHERE     bd_mapsid IN ('R',
                                             'E')
                           AND bd_datetime >= SYSDATE - 1
                           AND bd_bihid = sqlt_str_bihid
                     UNION -- TODO UNION ALL instead of UNION? (wwe)
                     SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            -- Average trans�port cost for MBS + MVP (NonNzero only)
                           'BdAmountTr(AmountTr<>0)'     AS kpi_code,
                           AVG (bd_amounttr)             AS kpi_value
                     FROM  bdetail
                     WHERE     bd_mapsid = 'R'
                           AND NVL (bd_amounttr, 0) <> 0
                           AND bd_datetime >= SYSDATE - 1
                           AND bd_bihid = sqlt_str_bihid
                     UNION -- TODO UNION ALL instead of UNION? (wwe)
                     SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            -- Percentage of Zero Transport Cost  for MBS + MVP
                           'BdRate(AmountTr=0)'    AS kpi_code,
                           CASE
                               WHEN COUNT (*) = 0
                               THEN
                                   NULL
                               ELSE
                                   SUM (DECODE (bd_amounttr, 0, 1, 0)) / COUNT (*)
                           END                     AS kpi_value
                     FROM  bdetail
                     WHERE     bd_mapsid IN ('R')
                           AND bd_datetime >= SYSDATE - 1
                           AND bd_bihid = sqlt_str_bihid
                     UNION -- TODO UNION ALL instead of UNION? (wwe)
                     SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            'BdRateError'    AS kpi_code,
                            CASE
                                WHEN COUNT (*) = 0
                                THEN
                                    NULL
                                ELSE
                                    SUM (DECODE (bd_mapsid, 'R', 0, 1)) / COUNT (*)
                            END              AS kpi_value
                     FROM   bdetail
                     WHERE      bd_mapsid IN ('R',
                                              'E')
                            AND bd_datetime >= SYSDATE - 1
                            AND bd_bihid = sqlt_str_bihid
                     UNION -- TODO UNION ALL instead of UNION? (wwe)
                     SELECT /*+ INDEX (BDETAIL IDX_BD_BIHID) */
                            'BdRateUnknown'    AS kpi_code,
                            CASE
                                WHEN COUNT (*) = 0
                                THEN
                                    NULL
                                ELSE
                                    SUM (DECODE (bd_prepaid,  'U', 1,  NULL, 1,  0)) / COUNT (*)
                            END                AS kpi_value
                     FROM   bdetail
                     WHERE      bd_mapsid IN ('R',
                                              'E')
                            AND bd_datetime >= SYSDATE - 1
                            AND bd_bihid = sqlt_str_bihid));
    END do_work;
END pkg_kpi_bd;
/