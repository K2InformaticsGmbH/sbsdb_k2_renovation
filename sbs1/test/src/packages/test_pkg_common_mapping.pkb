CREATE OR REPLACE PACKAGE BODY test_pkg_common_mapping
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method getsrctypeforbiheader - getsrctypeforbiheader]].
       ---------------------------------------------------------------------- */

    PROCEDURE getsrctypeforbiheader
    IS
    BEGIN
        test_data.crea_biheader_scratch ();

        COMMIT;

        ut.expect (pkg_common_mapping.getsrctypeforbiheader (p_bih_id => 'ut_id_a')).to_equal (test_data.gc_srct_id);

        ROLLBACK;
    END getsrctypeforbiheader;

    PROCEDURE getsrctypeforbiheader_after
    IS
    BEGIN
        test_data.del_biheader_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END getsrctypeforbiheader_after;

    /* =========================================================================
       Test: [Test method gettypeformapping - gettypeformapping]].
       ---------------------------------------------------------------------- */

    PROCEDURE gettypeformapping
    IS
    BEGIN
        test_data.crea_mapping_all ();

        COMMIT;

        ut.expect (pkg_common_mapping.gettypeformapping (p_bih_mapid => test_data.gc_mapt_id)).to_equal (test_data.gc_mapt_id);

        ROLLBACK;
    END gettypeformapping;

    PROCEDURE gettypeformapping_after
    IS
    BEGIN
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END gettypeformapping_after;

    /* =========================================================================
       Test: [Test method insert_biheader - insert_biheader]].
       ---------------------------------------------------------------------- */

    PROCEDURE insert_biheader
    IS
        l_biheader                              biheader%ROWTYPE;
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

        l_biheader.bih_id := test_data.gc_bih_id || '_1';

        COMMIT;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        ut.expect (l_biheader.bih_id).to_equal (test_data.gc_bih_id || '_1');

        l_biheader.bih_id := NULL;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        ut.expect (l_biheader.bih_id).to_be_not_null ();

        ROLLBACK;
    END insert_biheader;

    PROCEDURE insert_biheader_1001 -- excp_rdy_err_header_found
    IS
        l_biheader                              biheader%ROWTYPE;
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

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        UPDATE biheader
        SET    bih_esid = 'ERR'
        WHERE  bih_id = l_biheader.bih_id;

        l_biheader.bih_id := NULL;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);
    END insert_biheader_1001;

    PROCEDURE insert_biheader_1002 -- excp_rdy_err_many_retries
    IS
        l_biheader                              biheader%ROWTYPE;
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

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        UPDATE biheader
        SET    bih_esid = 'MAP'
        WHERE  bih_id = l_biheader.bih_id;

        l_biheader.bih_id := NULL;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        l_biheader.bih_id := NULL;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        l_biheader.bih_id := NULL;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);

        l_biheader.bih_id := NULL;

        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_biheader.bih_id,
            p_bih_demo                           => l_biheader.bih_demo,
            p_bih_fileseq                        => l_biheader.bih_fileseq,
            p_bih_filename                       => l_biheader.bih_filename,
            p_bih_filedate                       => TO_CHAR (l_biheader.bih_filedate, 'YYYYMMDDHH24MISS'),
            p_bih_mapid                          => test_data.gc_map_id,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);
    END insert_biheader_1002;

    PROCEDURE insert_biheader_1003 -- excp_inconvenient_time
    IS
        l_bih_id                                biheader.bih_id%TYPE;
    BEGIN
        pkg_common_mapping.insert_biheader (
            p_bih_id                             => l_bih_id,
            p_bih_demo                           => NULL,
            p_bih_fileseq                        => NULL,
            p_bih_filename                       => NULL,
            p_bih_filedate                       => NULL,
            p_bih_mapid                          => NULL,
            p_appname                            => NULL,
            p_appver                             => NULL,
            p_thread                             => NULL,
            p_taskid                             => NULL,
            p_hostname                           => NULL,
            p_status                             => NULL);
    END insert_biheader_1003;

    PROCEDURE insert_biheader_after
    IS
    BEGIN
        -- 0
        test_data.del_bihstate ();

        -- 1
        test_data.del_biheader_complete ();
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END insert_biheader_after;

    /* =========================================================================
       Test: [Test method istimeformapping - istimeformapping]].
       ---------------------------------------------------------------------- */

    PROCEDURE istimeformapping
    IS
    BEGIN
        ut.expect (pkg_common_mapping.istimeformapping (p_bih_mapid => NULL)).to_equal (0);

        test_data.crea_mapping_all ();

        UPDATE mapping
        SET    map_conditionalexec = 'SELECT ''FALSE'' FROM DUAL'
        WHERE  map_id = test_data.gc_map_id;

        COMMIT;

        ut.expect (pkg_common_mapping.istimeformapping (p_bih_mapid => test_data.gc_map_id)).to_equal (0);

        UPDATE mapping
        SET    map_conditionalexec = 'DUAL'
        WHERE  map_id = test_data.gc_map_id;

        ut.expect (pkg_common_mapping.istimeformapping (p_bih_mapid => test_data.gc_map_id)).to_equal (1);

        ROLLBACK;
    END istimeformapping;

    PROCEDURE istimeformapping_after
    IS
    BEGIN
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END istimeformapping_after;

    /* =========================================================================
       Test: [Test method sp_insert_header - sp_insert_header]].
       ---------------------------------------------------------------------- */

    PROCEDURE sp_insert_header
    IS
        l_bih_id                                biheader.bih_id%TYPE;
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

        l_bih_id := test_data.gc_bih_id || '_1';

        COMMIT;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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

        ut.expect (l_bih_id).to_equal (l_bih_id);
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errordesc).to_be_null ();
        ut.expect (l_returnstatus).to_equal (pkg_common.return_status_ok);

        l_bih_id := NULL;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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

        ut.expect (l_bih_id).to_be_not_null ();
        ut.expect (l_errorcode).to_be_null ();
        ut.expect (l_errordesc).to_be_null ();
        ut.expect (l_returnstatus).to_equal (pkg_common.return_status_ok);

        ROLLBACK;
    END sp_insert_header;

    PROCEDURE sp_insert_header_1001
    IS
        l_bih_id                                biheader.bih_id%TYPE;
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

        l_bih_id := NULL;

        COMMIT;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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
        WHERE  bih_id = l_bih_id;

        l_bih_id := NULL;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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

    PROCEDURE sp_insert_header_1002
    IS
        l_bih_id                                biheader.bih_id%TYPE;
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

        l_bih_id := NULL;

        COMMIT;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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
        WHERE  bih_id = l_bih_id;

        l_bih_id := NULL;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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

        l_bih_id := NULL;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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

        l_bih_id := NULL;

        pkg_common_mapping.sp_insert_header (
            p_bih_id                             => l_bih_id,
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

    PROCEDURE sp_insert_header_1003
    IS
        l_bih_id                                biheader.bih_id%TYPE;

        l_errorcode                             PLS_INTEGER;
        l_errordesc                             VARCHAR2 (512);

        l_returnstatus                          PLS_INTEGER;
    BEGIN
        pkg_common_mapping.sp_insert_header (
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
        -- 0
        test_data.del_bihstate ();

        -- 1
        test_data.del_biheader_complete ();
        test_data.del_mapping_complete ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END sp_insert_header_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_common_mapping;
/