CREATE OR REPLACE PACKAGE BODY test_pkg_mec_ic_csv
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sp_insert_csv - sp_insert_csv]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_csv
    IS
        l_arrrecnr                              pkg_mec_ic_csv.arrrecnr;
        l_arrrecdata                            pkg_mec_ic_csv.arrrecdata;

        l_datefc                                DATE;
        l_datelc                                DATE;

        l_errcount                              PLS_INTEGER;
        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_preparseerrcount                      PLS_INTEGER;

        l_reccount                              PLS_INTEGER;
        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_biheader_scratch ();

        test_data.crea_mapping_all ();

        UPDATE mapping
        SET    map_conditionalexec = NULL,
               map_execute = 1,
               map_srctid = test_data.gc_srct_id
        WHERE  map_id = test_data.gc_map_id;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_csv (
            p_bihid                              => test_data.gc_bih_id,
            p_batchsize                          => 0,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_recordnr                           => l_arrrecnr,
            p_recorddata                         => l_arrrecdata,
            p_reccount                           => l_reccount,
            p_preparseerrcount                   => l_preparseerrcount,
            p_errcount                           => l_errcount,
            p_datefc                             => l_datefc,
            p_datelc                             => l_datelc,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_reccount).to_be_null ();
        ut.expect (l_preparseerrcount).to_be_null ();
        ut.expect (l_errcount).to_be_null ();
        ut.expect (l_datefc).to_be_null ();
        ut.expect (l_datelc).to_be_null ();
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errordesc).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        l_arrrecnr (1) := 0;
        l_arrrecdata (1) := 'n/a';

        pkg_mec_ic_csv.sp_insert_csv (
            p_bihid                              => test_data.gc_bih_id,
            p_batchsize                          => 1,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_recordnr                           => l_arrrecnr,
            p_recorddata                         => l_arrrecdata,
            p_reccount                           => l_reccount,
            p_preparseerrcount                   => l_preparseerrcount,
            p_errcount                           => l_errcount,
            p_datefc                             => l_datefc,
            p_datelc                             => l_datelc,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_reccount).to_be_null ();
        ut.expect (l_preparseerrcount).to_be_null ();
        ut.expect (l_errcount).to_be_null ();
        ut.expect (l_datefc).to_be_null ();
        ut.expect (l_datelc).to_be_null ();
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errordesc).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        UPDATE biheader
        SET    bih_srctype = 'CCNDC'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE mapping
        SET    map_srctid = 'CCNDC'
        WHERE  map_id = test_data.gc_map_id;

        l_arrrecdata (1) := '1;2;3;4;5;6';
        l_datefc := SYSDATE + 1;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_csv (
            p_bihid                              => test_data.gc_bih_id,
            p_batchsize                          => 1,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_recordnr                           => l_arrrecnr,
            p_recorddata                         => l_arrrecdata,
            p_reccount                           => l_reccount,
            p_preparseerrcount                   => l_preparseerrcount,
            p_errcount                           => l_errcount,
            p_datefc                             => l_datefc,
            p_datelc                             => l_datelc,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_reccount).to_be_null ();
        ut.expect (l_preparseerrcount).to_be_null ();
        ut.expect (l_errcount).to_be_null ();
        ut.expect (l_datefc).to_equal (TRUNC (SYSDATE) + 1);
        ut.expect (l_datelc).to_be_null ();
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errordesc).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        UPDATE biheader
        SET    bih_srctype = 'MCCMNC'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE mapping
        SET    map_srctid = 'MCCMNC'
        WHERE  map_id = test_data.gc_map_id;

        l_datefc := NULL;
        l_datelc := SYSDATE + 1;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_csv (
            p_bihid                              => test_data.gc_bih_id,
            p_batchsize                          => 1,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_recordnr                           => l_arrrecnr,
            p_recorddata                         => l_arrrecdata,
            p_reccount                           => l_reccount,
            p_preparseerrcount                   => l_preparseerrcount,
            p_errcount                           => l_errcount,
            p_datefc                             => l_datefc,
            p_datelc                             => l_datelc,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_reccount).to_be_null ();
        ut.expect (l_preparseerrcount).to_be_null ();
        ut.expect (l_errcount).to_be_null ();
        ut.expect (l_datefc).to_be_null ();
        ut.expect (l_datelc).to_equal (TRUNC (SYSDATE) + 1);
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errordesc).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_insert_csv;

    PROCEDURE sp_insert_csv_after
    IS
    BEGIN
        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_insert_csv_after;

    /* =========================================================================
       Test: [Test method sp_insert_header - sp_insert_header]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header
    IS
        l_biheader                              biheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_biheader_scratch ();
        test_data.crea_mapping_all ();

        UPDATE mapping
        SET    map_conditionalexec = NULL,
               map_execute = 1,
               map_srctid = test_data.gc_srct_id
        WHERE  map_id = test_data.gc_map_id;

        SELECT *
        INTO   l_biheader
        FROM   biheader
        WHERE  bih_id = test_data.gc_bih_id;

        l_biheader.bih_id := test_data.gc_bih_id || '_1';

        COMMIT;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_biheader.bih_id).to_equal (test_data.gc_bih_id || '_1');
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        UPDATE biheader
        SET    bih_srctype = 'CCNDC'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE mapping
        SET    map_conditionalexec = NULL,
               map_execute = 1,
               map_srctid = 'CCNDC'
        WHERE  map_id = test_data.gc_map_id;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_biheader.bih_id).to_equal (test_data.gc_bih_id || '_1');
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        UPDATE biheader
        SET    bih_srctype = 'MCCMNC'
        WHERE  bih_id = test_data.gc_bih_id;

        UPDATE mapping
        SET    map_conditionalexec = NULL,
               map_execute = 1,
               map_srctid = 'MCCMNC'
        WHERE  map_id = test_data.gc_map_id;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_biheader.bih_id).to_equal (test_data.gc_bih_id || '_1');
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_insert_header;

    PROCEDURE sp_insert_header_1001 -- excp_rdy_err_header_found
    IS
        l_biheader                              biheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_biheader_scratch ();
        test_data.crea_mapping_all ();

        UPDATE mapping
        SET    map_srctid = test_data.gc_srct_id
        WHERE  map_id = test_data.gc_map_id;

        SELECT *
        INTO   l_biheader
        FROM   biheader
        WHERE  bih_id = test_data.gc_bih_id;

        l_biheader.bih_id := NULL;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        UPDATE biheader
        SET    bih_esid = 'ERR'
        WHERE  bih_id = l_biheader.bih_id;

        l_biheader.bih_id := NULL;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_equal (pkg_common.eno_rdy_err_header_found);
        ut.expect (l_errordesc).to_equal (pkg_common.edesc_rdy_err_header_found);
        ut.expect (l_returnstatus).to_equal (pkg_common.return_status_failure);

        ROLLBACK;
    END sp_insert_header_1001;

    PROCEDURE sp_insert_header_1002 -- excp_rdy_err_many_retries
    IS
        l_biheader                              biheader%ROWTYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_bihstate_all ();
        test_data.crea_biheader_scratch ();
        test_data.crea_mapping_all ();

        UPDATE mapping
        SET    map_srctid = test_data.gc_srct_id
        WHERE  map_id = test_data.gc_map_id;

        SELECT *
        INTO   l_biheader
        FROM   biheader
        WHERE  bih_id = test_data.gc_bih_id;

        l_biheader.bih_id := NULL;

        COMMIT;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        UPDATE biheader
        SET    bih_esid = 'MAP'
        WHERE  bih_id = l_biheader.bih_id;

        l_biheader.bih_id := NULL;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        l_biheader.bih_id := NULL;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        l_biheader.bih_id := NULL;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        l_biheader.bih_id := NULL;

        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_equal (pkg_common.eno_rdy_err_many_retries);
        ut.expect (l_errordesc).to_equal (pkg_common.edesc_rdy_err_many_retries);
        ut.expect (l_returnstatus).to_equal (pkg_common.return_status_failure);

        ROLLBACK;
    END sp_insert_header_1002;

    PROCEDURE sp_insert_header_1003 -- excp_inconvenient_time
    IS
        l_bih_id                                biheader.bih_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_mec_ic_csv.sp_insert_header (
            p_bih_id                             => l_bih_id,
            p_bih_demo                           => NULL,
            p_bih_fileseq                        => NULL,
            p_bih_filename                       => NULL,
            p_bih_filedate                       => NULL,
            p_bih_mapid                          => NULL,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_jobid                              => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_equal (pkg_common.eno_inconvenient_time);
        ut.expect (l_errordesc).to_equal (pkg_common.edesc_inconvenient_time);
        ut.expect (l_returnstatus).to_equal (pkg_common.return_status_suspended);

        ROLLBACK;
    END sp_insert_header_1003;

    PROCEDURE sp_insert_header_after
    IS
    BEGIN
        -- Level 0
        test_data.del_bihstate ();

        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_insert_header_after;

    /* =========================================================================
       Test: [Test method sp_update_header - sp_update_header]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_update_header
    IS
        l_datefc                                DATE;
        l_datelc                                DATE;

        l_errorcode                             PLS_INTEGER;
        l_errcount                              PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        test_data.crea_biheader_scratch ();

        test_data.crea_mapping_all ();

        UPDATE mapping
        SET    map_conditionalexec = NULL,
               map_execute = 1,
               map_srctid = test_data.gc_srct_id
        WHERE  map_id = test_data.gc_map_id;

        COMMIT;

        pkg_mec_ic_csv.sp_update_header (
            p_bihid                              => test_data.gc_bih_id,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => NULL,
            p_preparseerrcount                   => NULL,
            p_errcount                           => l_errcount,
            p_datefc                             => l_datefc,
            p_datelc                             => l_datelc,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;

        l_errcount := 0;

        pkg_mec_ic_csv.sp_update_header (
            p_bihid                              => test_data.gc_bih_id,
            p_maxage                             => NULL,
            p_dataheader                         => NULL,
            p_reccount                           => NULL,
            p_preparseerrcount                   => 0,
            p_errcount                           => l_errcount,
            p_datefc                             => l_datefc,
            p_datelc                             => l_datelc,
            p_errorcode                          => l_errorcode,
            p_errordesc                          => l_errordesc,
            p_returnstatus                       => l_returnstatus);

        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_returnstatus).to_equal (1);

        ROLLBACK;
    END sp_update_header;

    PROCEDURE sp_update_header_after
    IS
    BEGIN
        -- Level 1
        test_data.del_biheader_complete ();
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_update_header_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_mec_ic_csv;
/
