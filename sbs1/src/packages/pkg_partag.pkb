CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_partag
IS
    bdebug                                  BOOLEAN := TRUE;
    csmsachivets                            VARCHAR2 (20) := 'SBS1_ARCHIV_DATA'; --014SO --007SO --006SO use 'ARCHIV_DATA' for Prod
    rconfig                                 partag_config%ROWTYPE;

    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    FUNCTION getpartagconfig (p_data_type IN VARCHAR2 DEFAULT 'DEFAULT')
        RETURN partag_config%ROWTYPE;

    FUNCTION get_tab_partition_count (
        p_table_name                            IN VARCHAR2, -- e.g. BDCUC, BDCUCIDXA, BD6CUCIDXBE
        p_partition_name                        IN VARCHAR2, -- e.g. CUCA20051128
        p_tablespace_name                       IN VARCHAR2 -- e.g. CUCA_DATA_O1 (empty means ANY)
                                                           )
        RETURN INTEGER;

    FUNCTION get_ind_partition_count (
        p_index_name                            IN VARCHAR2, -- e.g. IDX_BDA_DATETIME_TRAUD
        p_partition_name                        IN VARCHAR2, -- e.g. MTRC20051231
        p_tablespace_name                       IN VARCHAR2 -- e.g. MTRC_INDEX_01 (empty means ANY)
                                                           )
        RETURN INTEGER;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_month_partition (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_partition_code                        IN VARCHAR2, -- e.g. 20051128
        p_tablespace_prefix                     IN VARCHAR2, -- e.g. CUCA_DATA
        p_indexspace_prefix                     IN VARCHAR2 -- e.g. CUCA_INDEX
                                                           );

    PROCEDURE sp_age_month_partitions (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_tablespace_prefix                     IN VARCHAR2, -- e.g. CUCA_DATA
        p_indexspace_prefix                     IN VARCHAR2 -- e.g. CUCA_INDEX
                                                           );

    PROCEDURE sp_cpr_month_partitions (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_tablespace_prefix                     IN VARCHAR2, -- e.g. CUCA_DATA
        p_indexspace_prefix                     IN VARCHAR2 -- e.g. CUCA_INDEX
                                                           );

    PROCEDURE sp_drop_month_partition (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_partition_code                        IN VARCHAR2 -- e.g. 20051128
                                                           );

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION partreorg_exch_partition (
        own                                     IN VARCHAR2,
        tbl                                     IN VARCHAR2,
        part                                    IN VARCHAR2)
        -- $Id: function.sbs1_admin.partreorg_part_exchange.sql 24 2012-12-06 10:32:54Z svnrepo $
        RETURN NUMBER
    --  -1: prepared table to exchange does not exist
    --   1: Before exchange: prepared table and corresponding partition with different number of rows
    --   2: After  exchange: prepared table and corresponding partition with different number of rows
    --   3: Exchange partition unsuccessful
    IS
        val                                     VARCHAR2 (4000);
        sqlcmd                                  VARCHAR2 (4000);
        prt                                     NUMBER;
        tab                                     NUMBER := -1;
        cnt                                     NUMBER;
        ungleich1                               EXCEPTION;
        ungleich2                               EXCEPTION;
        tbl_not_exists                          EXCEPTION;
    BEGIN
        SELECT COUNT (*)
        INTO   cnt
        FROM   all_tables
        WHERE      table_name = UPPER (tbl || '_' || part)
               AND owner = UPPER (own);

        IF cnt = 0
        THEN
            val := 'compressed part_table does not exist';
            DBMS_OUTPUT.put_line (val);
            pkg_common.insert_warning (
                'EXCHANGE',
                'exchange partition',
                tbl || '(' || part || ')',
                val,
                NULL,
                NULL);
            RETURN -1;
        ELSE
            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || '_' || part
                INTO                                     tab;

            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || ' partition (' || part || ')'
                INTO                                     prt;

            IF prt <> tab
            THEN
                val := 'rows in partition=' || prt || ' part_table=' || tab;
                DBMS_OUTPUT.put_line (val);
                pkg_common.insert_warning (
                    'EXCHANGE',
                    'rowcount difference before exchange',
                    tbl || '(' || part || ')',
                    val,
                    NULL,
                    NULL);
                RETURN 1;
            END IF;

            sqlcmd := 'alter table ' || own || '.' || tbl || ' exchange partition ' || part || ' with table ' || own || '.' || tbl || '_' || part || ' including indexes';
            DBMS_OUTPUT.put_line (sqlcmd || ';');

            BEGIN
                EXECUTE IMMEDIATE sqlcmd;
            EXCEPTION
                WHEN OTHERS
                THEN
                    val := SQLERRM;
                    DBMS_OUTPUT.put_line (val);
                    pkg_common.insert_warning (
                        'EXCHANGE',
                        'exchange partition',
                        tbl || '(' || part || ')',
                        val,
                        NULL,
                        NULL);
                    RETURN 3;
            END;

            -- check once again
            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || '_' || part
                INTO                                     tab;

            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || ' partition (' || part || ')'
                INTO                                     prt;

            IF prt <> tab
            THEN
                val := 'rows in partition=' || prt || ' part_table=' || tab;
                DBMS_OUTPUT.put_line (val);
                pkg_common.insert_warning (
                    'EXCHANGE',
                    'rowcount difference after exchange',
                    tbl || '(' || part || ')',
                    val,
                    NULL,
                    NULL);
                RETURN 2;
            END IF;

            sqlcmd := 'drop table ' || own || '.' || tbl || '_' || part;
            DBMS_OUTPUT.put_line (sqlcmd || ';');

            EXECUTE IMMEDIATE sqlcmd;
        END IF;

        DBMS_OUTPUT.put_line ('anz partition: ' || prt || ' ; anz tabelle ' || tab);
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            val := SQLERRM;
            DBMS_OUTPUT.put_line (val);
            pkg_common.insert_warning (
                'EXCHANGE',
                'unspecified operation',
                tbl || '(' || part || ')',
                val,
                NULL,
                NULL);
            RAISE;
    END partreorg_exch_partition;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION partreorg_prepare (
        own                                     IN VARCHAR2,
        tbl                                     IN VARCHAR2,
        part                                    IN VARCHAR2)
        -- $Id: function partreorg_prepare.sql 24 2012-12-06 10:32:54Z svnrepo $

        --027SO 09.09.2015  Patch Compression rules for re-compressing badly compressed older partitions $$$$ TO BE REMOVED $$$$

        RETURN NUMBER
    --   1: prepared table and corresponding partition with different number of rows
    --   2: specified table-partition does not exist
    --   3: reorg-table already exists
    IS
        val                                     VARCHAR2 (4000);
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
        -- Bestimmung Tablespace-Name der Partition. TBS f?r komprimierte Partition ist *_QC  (Query Compressed)
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
                val := 'Partition ' || own || '.' || tbl || '.' || part || ' does not exist';
                DBMS_OUTPUT.put_line (val);
                pkg_common.insert_warning (
                    'COMPRESS',
                    'tablespace_name',
                    tbl || '(' || part || ')',
                    val,
                    NULL,
                    NULL);
                RETURN 2;
            WHEN OTHERS
            THEN
                val := SQLERRM;
                DBMS_OUTPUT.put_line (val);
                pkg_common.insert_warning (
                    'COMPRESS',
                    'tablespace_name',
                    tbl || '(' || part || ')',
                    val,
                    NULL,
                    NULL);
                RAISE;
        END;

        IF tbs LIKE '%_UC'
        THEN
            tbs := SUBSTR (tbs, 1, LENGTH (tbs) - 3) || '_QC';
        ELSIF tbs LIKE '%_NC'
        THEN
            tbs := SUBSTR (tbs, 1, LENGTH (tbs) - 3) || '_QC';
        ELSIF tbs LIKE '%_HC'
        THEN
            tbs := SUBSTR (tbs, 1, LENGTH (tbs) - 3) || '_QC'; --027SO
        END IF;

        -- erstellen der neuen komprimierten Tabelle fuer den Partition-Exchange
        sqlcmd :=
               'create table '
            || own
            || '.'
            || tbl
            || '_'
            || part
            || ' compress for query high parallel 8 tablespace '
            || tbs
            || ' as select * from '
            || own
            || '.'
            || tbl
            || ' partition ('
            || part
            || ')';

        BEGIN
            DBMS_OUTPUT.put_line (TO_CHAR (SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
            DBMS_OUTPUT.put_line (sqlcmd || ';');
            sdat := SYSDATE;

            EXECUTE IMMEDIATE sqlcmd;

            diff := SYSDATE - sdat;
            DBMS_OUTPUT.put_line ('Duration (create table): ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
        EXCEPTION
            WHEN OTHERS
            THEN
                IF SQLCODE = -955
                THEN -- ORA-00955: name is already used by an existing object
                    val := 'Table ' || own || '.' || tbl || '_' || part || ' for re-organization already exists';
                    DBMS_OUTPUT.put_line (val);
                    pkg_common.insert_warning (
                        'COMPRESS',
                        'create table',
                        tbl || '(' || part || ')',
                        val,
                        NULL,
                        NULL);
                    RETURN 3;
                ELSE
                    val := SQLERRM;
                    DBMS_OUTPUT.put_line (val);
                    pkg_common.insert_warning (
                        'COMPRESS',
                        'create table',
                        tbl || '(' || part || ')',
                        val,
                        NULL,
                        NULL);
                END IF;
        END;

        BEGIN
            -- Erstellen der Indices
            tbs := REPLACE (tbs, 'DATA', 'INDEX');

           <<loop_all_indexes>>
            FOR ind IN (SELECT *
                        FROM   all_indexes --all_ind_columns
                        WHERE      table_owner = own
                               AND table_name = tbl
                               AND (table_owner,
                                    table_name) IN (SELECT table_owner, table_name FROM all_tab_partitions) --027SO where compression='DISABLED'
                                                                                                           )
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

                IF LENGTH (ind.index_name || '_' || part) > 30
                THEN
                    objname := SUBSTR (ind.index_name || '_' || part, -30); --indexnamen muessen eindeutig sein. Bei aktueller Namenskonvention funktioniert das
                ELSE
                    objname := ind.index_name || '_' || part;
                END IF;

                sqlcmd := 'create index ' || ind.owner || '.' || objname || ' on ' || ind.table_owner || '.' || ind.table_name || '_' || part || ' (' || felder || ') tablespace ' || tbs;
                DBMS_OUTPUT.put_line (sqlcmd || ';');
                sdat := SYSDATE;

                BEGIN
                    EXECUTE IMMEDIATE sqlcmd;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        val := SQLERRM;
                        DBMS_OUTPUT.put_line (val);
                        pkg_common.insert_warning (
                            'COMPRESS',
                            'create index ' || objname,
                            tbl || '(' || part || ')',
                            val,
                            NULL,
                            NULL);
                        RAISE;
                END;

                diff := SYSDATE - sdat;
                DBMS_OUTPUT.put_line ('Duration (create index' || objname || '): ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
            END LOOP loop_all_indexes;

           -- Foreign Key Constraints (novalidate)
           <<loop_all_constraints>>
            FOR c0 IN (SELECT constraint_name,
                              DECODE (status, 'ENABLED', ' enable ', 'disable ')     en
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

                BEGIN
                    EXECUTE IMMEDIATE sqlcmd;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        val := SQLERRM;
                        DBMS_OUTPUT.put_line (val);
                        pkg_common.insert_warning (
                            'COMPRESS',
                            'add constraint ' || objname,
                            tbl || '(' || part || ')',
                            val,
                            NULL,
                            NULL);
                        RAISE;
                END;

                diff := SYSDATE - sdat;
                DBMS_OUTPUT.put_line ('Duration: ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
            END LOOP loop_all_constraints;

           -- Foreign Key Constraints (validate)
           <<loop_all_constraints_2>>
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

                BEGIN
                    EXECUTE IMMEDIATE sqlcmd;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        val := SQLERRM;
                        DBMS_OUTPUT.put_line (val);
                        pkg_common.insert_warning (
                            'COMPRESS',
                            'enable constraint ' || objname,
                            tbl || '(' || part || ')',
                            val,
                            NULL,
                            NULL);
                        RAISE;
                END;

                diff := SYSDATE - sdat;
                DBMS_OUTPUT.put_line ('Duration: ' || TRUNC (diff * 24) || ':' || TRUNC (MOD (diff * 24 * 60, 60)) || ':' || TRUNC (MOD (diff * 24 * 60 * 60, 60)));
            END LOOP loop_all_constraints_2;

            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || '_' || part
                INTO                                     tab;

            EXECUTE IMMEDIATE 'select count(*) from ' || own || '.' || tbl || ' partition (' || part || ')'
                INTO                                     prt;

            IF prt <> tab
            THEN
                val := 'rows in original partition / compressed: ' || part || ' / ' || tab;
                DBMS_OUTPUT.put_line (val);
                pkg_common.insert_warning (
                    'COMPRESS',
                    'check counts',
                    tbl || '(' || part || ')',
                    val,
                    NULL,
                    NULL);
                RETURN 1;
            END IF;

            RETURN 0;
        EXCEPTION
            WHEN OTHERS
            THEN
                val := SQLERRM;
                DBMS_OUTPUT.put_line (val);
                pkg_common.insert_warning (
                    'COMPRESS',
                    'enable constraint ' || objname,
                    tbl || '(' || part || ')',
                    val,
                    NULL,
                    NULL);

                BEGIN
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
    END partreorg_prepare;

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE cleanup (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS
        vdeleted                                NUMBER;
    BEGIN
        errorcode := 0;
        errormsg := NULL;
        recordsaffected := 0;

        -- SBS1
        cleanup_delete ('biheader', 'bih_datetime < ADD_MONTHS(TRUNC(SYSDATE),-17) and ROWNUM <= 100000', p_boh_id, vdeleted);
        recordsaffected := recordsaffected + vdeleted;
        cleanup_delete ('boheader', 'boh_datetime < ADD_MONTHS(TRUNC(SYSDATE),-17) and ROWNUM <= 100000', p_boh_id, vdeleted);
        recordsaffected := recordsaffected + vdeleted;
        cleanup_delete ('dgticonsol', 'TO_DATE(dgtic_sepid,''YYYYMM'') < ADD_MONTHS(TRUNC(SYSDATE),-17) and ROWNUM <= 100000', p_boh_id, vdeleted);
        recordsaffected := recordsaffected + vdeleted;
        cleanup_delete ('ogticonsol', 'TO_DATE(ogtic_sepid,''yyyymm'') < ADD_MONTHS(TRUNC(SYSDATE),-17) and ROWNUM <= 100000', p_boh_id, vdeleted);
        recordsaffected := recordsaffected + vdeleted;
        cleanup_delete ('warning', 'w_errortime < ADD_MONTHS(TRUNC(SYSDATE),-17) and ROWNUM <= 100000', p_boh_id, vdeleted);
        recordsaffected := recordsaffected + vdeleted;

        returnstatus := 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc;
            returnstatus := 0;
    END cleanup;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE cleanup_delete (
        pintablename                            IN     VARCHAR2,
        pinwhereclause                          IN     VARCHAR2,
        pinboh_id                               IN     VARCHAR2,
        poutdeleted                                OUT NUMBER)
    IS
        v_script_id                             VARCHAR2 (10);
        v_script_state                          VARCHAR2 (10);
    BEGIN
        v_script_id :=
            pkg_script.create_and_delete (
                'CLEANUP_DELETE',
                1,
                pintablename,
                pinwhereclause,
                NULL,
                pinboh_id,
                v_script_state);

        IF v_script_state = 'OK'
        THEN
            poutdeleted := 1; -- for true
        ELSE
            -- do an error logging
            pkg_common.insert_warning (
                'ANONYMOUS',
                'CLEANUP_DELETE',
                pintablename,
                'See SCRIPT ID = ' || v_script_id,
                NULL,
                pinboh_id);
            poutdeleted := 0; -- for false
        END IF;
    END cleanup_delete;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_info_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --009SO
    BEGIN
        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL9',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVI_CONTENT_SUB',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVI_CONTENT_DEL',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVI_SMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVI_MMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVI_PRE',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVIPRE_SMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'REVIPRE_MMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDKPI',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --030SO

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_add_info_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_info_partitions_man (p_partition_code IN VARCHAR2)
    IS
    BEGIN
        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL9',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVI_CONTENT_SUB',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVI_CONTENT_DEL',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVI_SMS',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVI_MMS',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVI_PRE',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVIPRE_SMS',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'REVIPRE_MMS',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --015SO  --011SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'BDKPI',
            NULL,
            'INFO',
            p_partition_code,
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --030SO

        pkg_common.compile_all; --008SO

        RETURN;
    END sp_add_info_partitions_man;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_mmsc_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --009SO
    BEGIN
        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL6',
            NULL,
            'MMSC',
            'SBS1_MMSC_DATA',
            'SBS1_MMSC_INDEX');

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_add_mmsc_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_mmsc_partitions_man (p_partition_code IN VARCHAR2)
    IS
    BEGIN
        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL6',
            NULL,
            'MMSC',
            p_partition_code,
            'SBS1_MMSC_DATA',
            'SBS1_MMSC_INDEX');

        pkg_common.compile_all; --008SO

        RETURN;
    END sp_add_mmsc_partitions_man;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_msca_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --009SO
    BEGIN
        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL4',
            NULL,
            'MSCA',
            'SBS1_MSCA_DATA',
            'SBS1_MSCA_INDEX');

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_add_msca_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_msca_partitions_man (p_partition_code IN VARCHAR2)
    IS
    BEGIN
        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL4',
            NULL,
            'MSCA',
            p_partition_code,
            'SBS1_MSCA_DATA',
            'SBS1_MSCA_INDEX');

        pkg_common.compile_all; --008SO

        RETURN;
    END sp_add_msca_partitions_man;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsa_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --006SO
    BEGIN
        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'SMS_IW_MT_ARCH',
            NULL,
            'SMSA',
            NULL,
            csmsachivets);

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_add_smsa_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsa_partitions_man (p_partition_code IN VARCHAR2)
    IS
    BEGIN
        pkg_partag.sp_add_month_partition (
            NULL,
            'SMS_IW_MT_ARCH',
            NULL,
            'SMSA',
            p_partition_code,
            NULL,
            csmsachivets);

        pkg_common.compile_all; --008SO

        RETURN;
    END sp_add_smsa_partitions_man;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsc_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --006SO
    BEGIN
        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL1',
            NULL,
            'SMSC',
            'SBS1_SMSC_DATA',
            'SBS1_SMSC_INDEX'); --015SO

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_add_smsc_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsc_partitions_man (p_partition_code IN VARCHAR2)
    IS
    BEGIN
        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL1',
            NULL,
            'SMSC',
            p_partition_code,
            'SBS1_SMSC_DATA',
            'SBS1_SMSC_INDEX'); --015SO

        pkg_common.compile_all; --008SO

        RETURN;
    END sp_add_smsc_partitions_man;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsd_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --006SO
    BEGIN
        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL2',
            NULL,
            'SMSD',
            'SBS1_SMSD_DATA', --007SO
            'SBS1_SMSD_INDEX' --007SO
                             ); --015SO

        pkg_partag.sp_age_month_partitions (
            p_boh_id,
            'BDETAIL7',
            NULL,
            'SMSD',
            'SBS1_SMSD_DATA',
            'SBS1_SMSD_INDEX'); --023SO --022SO

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_add_smsd_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_smsd_partitions_man (p_partition_code IN VARCHAR2)
    IS
    BEGIN
        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL2',
            NULL,
            'SMSD',
            p_partition_code,
            'SBS1_SMSD_DATA', --007SO
            'SBS1_SMSD_INDEX' --007SO
                             ); --015SO

        pkg_partag.sp_add_month_partition (
            NULL,
            'BDETAIL7',
            NULL,
            'SMSD',
            p_partition_code,
            'SBS1_SMSD_DATA', --007SO
            'SBS1_SMSD_INDEX' --007SO
                             ); --023SO --022SO

        pkg_common.compile_all; --008SO

        RETURN;
    END sp_add_smsd_partitions_man;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_info_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --019SO
    BEGIN
        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL9',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDKPI',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX'); --029SO

        pkg_common.compile_all;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_cpr_info_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_mmsc_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --019SO
    BEGIN
        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL6',
            NULL,
            'MMSC',
            'SBS1_MMSC_DATA',
            'SBS1_MMSC_INDEX');

        pkg_common.compile_all;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_cpr_mmsc_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_msca_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --019SO
    BEGIN
        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL4',
            NULL,
            'MSCA',
            'SBS1_MSCA_DATA',
            'SBS1_MSCA_INDEX');

        pkg_common.compile_all;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_cpr_msca_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_revi_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --019SO
    BEGIN
        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVI_CONTENT_SUB',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVI_CONTENT_DEL',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVI_SMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVI_MMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVI_PRE',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVIPRE_SMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'REVIPRE_MMS',
            NULL,
            'INFO',
            'SBS1_INFO_DATA',
            'SBS1_INFO_INDEX');

        pkg_common.compile_all;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_cpr_revi_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_smsc_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --019SO
    BEGIN
        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL1',
            NULL,
            'SMSC',
            'SBS1_SMSC_DATA',
            'SBS1_SMSC_INDEX');

        pkg_common.compile_all;

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_cpr_smsc_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_smsd_partitions (
        p_pact_id                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_boh_id                                IN     VARCHAR2,
        recordsaffected                            OUT NUMBER,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER)
    IS --019SO
    BEGIN
        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL2',
            NULL,
            'SMSD',
            'SBS1_SMSD_DATA',
            'SBS1_SMSD_INDEX');

        pkg_partag.sp_cpr_month_partitions (
            p_boh_id,
            'BDETAIL7',
            NULL,
            'SMSD',
            'SBS1_SMSD_DATA',
            'SBS1_SMSD_INDEX'); --026SO

        pkg_common.compile_all; --008SO

        errorcode := 0;
        errormsg := NULL;
        returnstatus := 1;

        RETURN;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := pkg_common.getharderrordesc; --021SO
            returnstatus := 0;
            recordsaffected := 0;
    END sp_cpr_smsd_partitions;

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION getpartagconfig (p_data_type IN VARCHAR2 DEFAULT 'DEFAULT')
        RETURN partag_config%ROWTYPE
    IS
        vconfig                                 partag_config%ROWTYPE;
    BEGIN
        SELECT *
        INTO   vconfig
        FROM   partag_config
        WHERE  partagc_id = p_data_type;

        IF vconfig.partagc_debugmode = 1
        THEN
            bdebug := TRUE;
        ELSE
            bdebug := FALSE;
        END IF;

        RETURN vconfig;
    END getpartagconfig;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_tab_partition_count (
        p_table_name                            IN VARCHAR2, -- e.g. BDCUC, BDCUCIDXA, BD6CUCIDXBE
        p_partition_name                        IN VARCHAR2, -- e.g. CUCA20051128
        p_tablespace_name                       IN VARCHAR2 -- e.g. CUCA_DATA_O1 (empty means ANY)
                                                           )
        RETURN INTEGER
    IS
        v_partition_count                       PLS_INTEGER;
    BEGIN
        IF p_tablespace_name IS NOT NULL
        THEN
            SELECT COUNT (*)
            INTO   v_partition_count
            FROM   all_tab_partitions
            WHERE      table_name = p_table_name
                   AND partition_name = p_partition_name
                   AND tablespace_name = p_tablespace_name;
        ELSE
            SELECT COUNT (*)
            INTO   v_partition_count
            FROM   all_tab_partitions
            WHERE      table_name = p_table_name
                   AND partition_name = p_partition_name;
        END IF;

        RETURN v_partition_count;
    END get_tab_partition_count;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION get_ind_partition_count (
        p_index_name                            IN VARCHAR2, -- e.g. IDX_BDA_DATETIME_TRAUD
        p_partition_name                        IN VARCHAR2, -- e.g. MTRC20051231
        p_tablespace_name                       IN VARCHAR2 -- e.g. MTRC_INDEX_01 (empty means ANY)
                                                           )
        RETURN INTEGER
    IS
        v_partition_count                       PLS_INTEGER;
    BEGIN
        IF p_tablespace_name IS NOT NULL
        THEN
            SELECT COUNT (*)
            INTO   v_partition_count
            FROM   all_ind_partitions
            WHERE      index_name = p_index_name
                   AND partition_name = p_partition_name
                   AND tablespace_name = p_tablespace_name;
        ELSE
            SELECT COUNT (*)
            INTO   v_partition_count
            FROM   all_ind_partitions
            WHERE      index_name = p_index_name
                   AND partition_name = p_partition_name;
        END IF;

        RETURN v_partition_count;
    END get_ind_partition_count;

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_add_month_partition (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_partition_code                        IN VARCHAR2, -- e.g. 20051128
        p_tablespace_prefix                     IN VARCHAR2, -- e.g. CUCA_DATA
        p_indexspace_prefix                     IN VARCHAR2 -- e.g. CUCA_INDEX
                                                           )
    IS --006SO
        CURSOR cindexes (x_table_name IN VARCHAR2)
        IS
            SELECT index_name
            FROM   user_indexes
            WHERE      table_name = x_table_name
                   AND index_type = 'NORMAL';

        v_ddl                                   VARCHAR2 (2000);
        v_script_id                             VARCHAR2 (10);
        v_script_state                          VARCHAR2 (10);

        v_table_name                            VARCHAR2 (20);
        v_partition_name                        VARCHAR2 (12);
        v_partition_start_date                  DATE;
        v_partition_end_date                    DATE;
        v_tablespace_name                       VARCHAR2 (20);
        v_tablespace_code                       VARCHAR2 (2);
        v_indexspace_name                       VARCHAR2 (20);
    BEGIN
        rconfig := getpartagconfig (p_partition_prefix); --006SO

        v_partition_start_date := TO_DATE (p_partition_code, 'YYYYMM'); --006SO
        v_partition_end_date := ADD_MONTHS (v_partition_start_date, 1); --006SO -- one month
        v_partition_name := p_partition_prefix || p_partition_code;
        v_table_name := p_table_prefix || p_table_ext;

        IF     rconfig.partagc_tablespaces = 1
           AND p_tablespace_prefix IN ('SBS1_INFO_DATA',
                                       'SBS1_SMSC_DATA',
                                       'SBS1_SMSD_DATA')
        THEN
            v_tablespace_code := 'UC'; --024SO
            v_tablespace_name := NVL (p_tablespace_prefix, p_indexspace_prefix) || '_' || v_tablespace_code;
            v_indexspace_name := p_indexspace_prefix || '_' || v_tablespace_code;
        ELSIF rconfig.partagc_tablespaces = 1
        THEN -- no compression, use *_NC
            v_tablespace_code := 'NC'; --020SO --013SO
            v_tablespace_name := NVL (p_tablespace_prefix, p_indexspace_prefix) || '_' || v_tablespace_code; --018SO
            v_indexspace_name := p_indexspace_prefix || '_' || v_tablespace_code; --013SO
        ELSE
            -- rotate tablespaces
            v_tablespace_code := TO_CHAR (MOD (MONTHS_BETWEEN (TO_DATE (p_partition_code, 'yyyymm'), TO_DATE ('199909', 'yyyymm')), rconfig.partagc_tablespaces) + 1, 'fm00');
            v_tablespace_name := NVL (p_tablespace_prefix, p_indexspace_prefix) || '_' || v_tablespace_code;
            v_indexspace_name := p_indexspace_prefix || '_' || v_tablespace_code;
        END IF;

        BEGIN
            v_script_state := 'OK'; -- in case partition alredy exist in correct tablespace

            IF get_tab_partition_count (v_table_name, v_partition_name, NULL) = 0
            THEN
                -- partition does not exist

                -- make sure indexes will be created in proper tablespace               --003SO whole block added
                FOR i IN cindexes (v_table_name)
                LOOP
                    -- IOTs won't have any additional indexes besides the PK
                    v_ddl := 'ALTER INDEX ' || i.index_name || ' MODIFY DEFAULT ATTRIBUTES TABLESPACE ' || v_indexspace_name;
                    v_script_id :=
                        pkg_script.create_and_execute (
                            'CreateTabPartition',
                            rconfig.partagc_execute,
                            v_ddl,
                            p_table_ext,
                            p_boh_id,
                            v_script_state);

                    IF v_script_state <> 'OK'
                    THEN
                        -- do an error logging
                        pkg_common.insert_warning ( --008SO
                            'PKG_PARTAG',
                            'SP_ADD_SINGLE_MONTH_PARTITION',
                            'Scripting Error',
                            'See SCRIPT ID = ' || v_script_id,
                            NULL,
                            p_boh_id);
                    END IF;
                END LOOP;

                IF v_table_name LIKE 'REVI%'
                THEN --011SO
                    -- Create candidate partition for a date code partition key  YYYYMM(DD)
                    v_ddl :=
                           'ALTER TABLE '
                        || v_table_name
                        || ' ADD PARTITION '
                        || v_partition_name
                        || ' VALUES LESS THAN ('''
                        || TO_CHAR (v_partition_end_date, 'YYYYMM')
                        || ''') TABLESPACE '
                        || v_tablespace_name;
                ELSE
                    -- Create candidate partition for a date partition key
                    v_ddl :=
                           'ALTER TABLE '
                        || v_table_name
                        || ' ADD PARTITION '
                        || v_partition_name
                        || ' VALUES LESS THAN (to_date('''
                        || TO_CHAR (v_partition_end_date, 'YYYYMMDD')
                        || ''',''YYYYMMDD'')) TABLESPACE '
                        || v_tablespace_name;
                END IF;

                v_script_id :=
                    pkg_script.create_and_execute (
                        'CreateTabPartition',
                        rconfig.partagc_execute,
                        v_ddl,
                        p_table_ext,
                        p_boh_id,
                        v_script_state);
            END IF;

            IF p_tablespace_prefix IS NULL
            THEN
                -- It's an IOT
                IF get_ind_partition_count ('PK_' || v_table_name, v_partition_name, v_indexspace_name) = 0
                THEN
                    -- IOT partition may exist, but in wrong tablespace
                    -- Correcting Oracle Bug No. 1541222
                    v_ddl := 'ALTER TABLE ' || v_table_name || ' MOVE PARTITION ' || v_partition_name || ' TABLESPACE ' || v_indexspace_name;
                    v_script_id :=
                        pkg_script.create_and_execute (
                            'MoveIotPartition',
                            rconfig.partagc_execute,
                            v_ddl,
                            p_table_ext,
                            p_boh_id,
                            v_script_state);
                END IF;
            ELSE
                -- It is an ordinary partitioned table
                IF get_tab_partition_count (v_table_name, v_partition_name, v_tablespace_name) = 0
                THEN
                    -- partition may exist, but in wrong tablespace
                    -- Correcting Oracle Bug No. 1541222
                    v_ddl := 'ALTER TABLE ' || v_table_name || ' MOVE PARTITION ' || v_partition_name || ' TABLESPACE ' || v_tablespace_name;
                    v_script_id :=
                        pkg_script.create_and_execute (
                            'MoveTabPartition',
                            rconfig.partagc_execute,
                            v_ddl,
                            p_table_ext,
                            p_boh_id,
                            v_script_state);
                END IF;
            END IF;

            IF v_script_state <> 'OK'
            THEN
                -- do an error logging
                pkg_common.insert_warning ( --008SO
                    'PKG_PARTAG',
                    'SP_ADD_SINGLE_MONTH_PARTITION',
                    'Scripting Error',
                    'See SCRIPT ID = ' || v_script_id,
                    NULL,
                    p_boh_id);
            END IF;

            FOR i IN cindexes (v_table_name)
            LOOP
                -- IOTs won't have any additional indexes besides the PK
                IF get_ind_partition_count (i.index_name, v_partition_name, NULL) > 0
                THEN
                    -- candidate index exists
                    IF get_ind_partition_count (i.index_name, v_partition_name, v_indexspace_name) = 0
                    THEN
                        -- but not in correct tablespace. Need to move it!
                        v_ddl := 'ALTER INDEX ' || i.index_name || ' REBUILD PARTITION ' || v_partition_name || ' TABLESPACE ' || v_indexspace_name; --002SO  ' ONLINE'
                        v_script_id :=
                            pkg_script.create_and_execute (
                                'RebuildIndPartition',
                                rconfig.partagc_execute,
                                v_ddl,
                                p_table_ext,
                                p_boh_id,
                                v_script_state);

                        IF v_script_state <> 'OK'
                        THEN
                            -- do an error logging
                            pkg_common.insert_warning ( --008SO
                                'PKG_PARTAG',
                                'SP_ADD_SINGLE_MONTH_PARTITION',
                                'Scripting Error',
                                'See SCRIPT ID = ' || v_script_id,
                                NULL,
                                p_boh_id);
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END;

        RETURN;
    END sp_add_month_partition;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_age_month_partitions (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_tablespace_prefix                     IN VARCHAR2, -- e.g. CUCA_DATA
        p_indexspace_prefix                     IN VARCHAR2 -- e.g. CUCA_INDEX
                                                           )
    IS --006SO
        CURSOR oldest_partition IS
            SELECT NVL (MIN (partition_name), 'none')
            FROM   all_tab_partitions
            WHERE      table_name = p_table_prefix || p_table_ext
                   AND partition_name LIKE p_partition_prefix || '______' --006SO
                                                                         ;

        CURSOR newest_partition IS
            SELECT NVL (MAX (partition_name), 'none')
            FROM   all_tab_partitions
            WHERE      table_name = p_table_prefix || p_table_ext
                   AND partition_name LIKE p_partition_prefix || '______' --006SO
                                                                         ;

        CURSOR exchange_partition IS
            SELECT MIN (SUBSTR (table_name, LENGTH (p_table_prefix || p_table_ext || '_') + 1))     AS partition_name
            FROM   all_tables
            WHERE      owner = 'SBS1_ADMIN'
                   AND tablespace_name LIKE '%_QC'
                   AND table_name LIKE p_table_prefix || p_table_ext || '_' || p_partition_prefix || '______'; --025SO --019SO

        v_partition_date_old                    DATE; -- partitions older than this are to be deleted
        v_partition_date_new                    DATE; -- partitions older or equal to this are to be created

        v_partition_name                        VARCHAR2 (20);
        v_partition_start_date                  DATE;
        v_partition_code                        VARCHAR2 (8);

        v_result_code                           PLS_INTEGER; --019SO

        v_retries                               PLS_INTEGER; -- create/delete attempts per invocation
        v_retries_max_deletes                   PLS_INTEGER; -- max. number of delete tries per run
        v_retries_max_creates                   PLS_INTEGER; -- max. number of create tries per run
        v_retries_max_exchanges                 PLS_INTEGER; --019SO -- max. number of exchange tries per run
    BEGIN
        rconfig := getpartagconfig (p_partition_prefix);

        v_partition_date_old := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -rconfig.partagc_history); -- partitions older than this will be deleted; standard = 60
        v_partition_date_new := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), rconfig.partagc_advanced); -- partitions older or equal to this should be created

        v_retries_max_deletes := 7; -- not more than 7 partition delete attempts in one round
        v_retries_max_creates := 7; -- not more than 7 partition insert attempts in one round
        v_retries_max_exchanges := 3; --019SO -- not more than 3 partition exchange attempts in one round

        -- PART 1 ADD NEW PARTITIONS
        v_retries := 0;

        LOOP
            OPEN newest_partition;

            FETCH newest_partition INTO v_partition_name;

            IF newest_partition%NOTFOUND
            THEN
                -- the next one to be created will be for 'this month'
                v_partition_name := p_partition_prefix || TO_CHAR (ADD_MONTHS (SYSDATE, -1), 'YYYYMM');
            END IF;

            CLOSE newest_partition;

            -- calculate partition code for next partition to be created
            v_partition_start_date := ADD_MONTHS (TO_DATE (SUBSTR (v_partition_name, LENGTH (p_partition_prefix) + 1, 6), 'YYYYMM'), 1);
            v_partition_code := TO_CHAR (v_partition_start_date, 'YYYYMM');

            EXIT WHEN v_partition_start_date > v_partition_date_new;

            sp_add_month_partition (
                p_boh_id,
                p_table_prefix,
                p_table_ext,
                p_partition_prefix,
                v_partition_code,
                p_tablespace_prefix,
                p_indexspace_prefix);

            v_retries := v_retries + 1;
            EXIT WHEN v_retries > v_retries_max_creates;
        END LOOP;

        -- PART 2 DELETE OLD PARTITIONS

        v_retries := 0;

        LOOP
            OPEN oldest_partition;

            FETCH oldest_partition INTO v_partition_name;

            IF oldest_partition%NOTFOUND
            THEN
                v_partition_name := 'none';
            END IF;

            CLOSE oldest_partition;

            EXIT WHEN v_partition_name = 'none';

            -- calculate partition code for this potentially outdated partition
            v_partition_start_date := TO_DATE (SUBSTR (v_partition_name, LENGTH (p_partition_prefix) + 1, 6), 'YYYYMM');
            v_partition_code := TO_CHAR (v_partition_start_date, 'YYYYMM');

            EXIT WHEN v_partition_start_date >= v_partition_date_old;

            sp_drop_month_partition (
                p_boh_id,
                p_table_prefix,
                p_table_ext,
                p_partition_prefix,
                v_partition_code);

            v_retries := v_retries + 1;
            EXIT WHEN v_retries > v_retries_max_deletes;
        END LOOP;

        -- PART 3 EXCHANGE COMPRESSED PARTITIONS                                    --019SO

        v_retries := 0;

        LOOP
            OPEN exchange_partition;

            FETCH exchange_partition INTO v_partition_name;

            IF exchange_partition%NOTFOUND
            THEN
                v_partition_name := 'none';
            END IF;

            CLOSE exchange_partition;

            EXIT WHEN v_partition_name = 'none';

            -- calculate partition start date for this potentially outdated exchange partition
            v_partition_start_date := TO_DATE (SUBSTR (v_partition_name, LENGTH (p_partition_prefix) + 1, 6), 'YYYYMM');

            IF     (v_partition_start_date >= v_partition_date_old)
               AND (v_partition_start_date < TRUNC (SYSDATE, 'MONTH'))
            THEN
                -- only swap-in partitions in the correct time range
                v_result_code := partreorg_exch_partition ('SBS1_ADMIN', p_table_prefix || p_table_ext, v_partition_name);

                CASE
                    WHEN v_result_code = -1
                    THEN -- -1: prepared table to exchange does not exist
                        RAISE NO_DATA_FOUND;
                    WHEN v_result_code = 0
                    THEN -- 0: success
                        NULL;
                    WHEN v_result_code = 1
                    THEN -- 1: Before exchange row count mismatch
                        RAISE TOO_MANY_ROWS;
                    WHEN v_result_code = 2
                    THEN -- 2: After  exchange  row count mismatch
                        RAISE TOO_MANY_ROWS;
                    WHEN v_result_code = 3
                    THEN -- 3: Exchange partition command unsuccessful
                        RAISE STORAGE_ERROR;
                    ELSE
                        RAISE VALUE_ERROR;
                END CASE;
            END IF;

            v_retries := v_retries + 1;
            EXIT WHEN v_retries > v_retries_max_exchanges;
        END LOOP;
    END sp_age_month_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_cpr_month_partitions (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345 -- TODO unused parameter? (wwe)
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_tablespace_prefix                     IN VARCHAR2, -- e.g. CUCA_DATA -- TODO unused parameter? (wwe)
        p_indexspace_prefix                     IN VARCHAR2 -- e.g. CUCA_INDEX -- TODO unused parameter? (wwe)
                                                           )
    IS --019SO
        CURSOR uncompressed_partition IS
            SELECT MIN (p.partition_name)     AS partition_name
            FROM   all_tab_partitions p
            WHERE      p.table_name = p_table_prefix || p_table_ext
                   AND p.compression = 'DISABLED' --028SO
                   AND p.table_owner = 'SBS1_ADMIN'
                   AND NOT EXISTS
                           (SELECT a.table_name
                            FROM   all_tables a
                            WHERE      a.owner = p.table_owner
                                   AND a.tablespace_name LIKE '%_QC'
                                   AND a.table_name = p.table_name || '_' || partition_name); --025SO --019SO

        v_partition_date_old                    DATE; -- partitions older than this are to be deleted
        v_partition_date_new                    DATE; -- partitions older or equal to this are to be created

        v_partition_name                        VARCHAR2 (20);
        v_partition_start_date                  DATE;

        v_result_code                           PLS_INTEGER; --019SO

        v_retries                               PLS_INTEGER; -- create/delete attempts per invocation
        v_retries_max                           PLS_INTEGER; --019SO -- max. number of compressing tries per run
    BEGIN
        rconfig := getpartagconfig (p_partition_prefix);

        v_partition_date_old := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), -rconfig.partagc_history); -- partitions older than this will be deleted; standard = 60
        v_partition_date_new := ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), rconfig.partagc_advanced); -- partitions older or equal to this should be created

        v_retries_max := 3; --019SO -- not more than 3 partition compress attempts in one round
        v_retries := 0;

        LOOP
            OPEN uncompressed_partition;

            FETCH uncompressed_partition INTO v_partition_name;

            IF uncompressed_partition%NOTFOUND
            THEN
                v_partition_name := 'none';
            END IF;

            CLOSE uncompressed_partition;

            EXIT WHEN v_partition_name = 'none';

            -- calculate partition start date for this potentially outdated uncompressed partition
            v_partition_start_date := TO_DATE (SUBSTR (v_partition_name, LENGTH (p_partition_prefix) + 1, 6), 'YYYYMM');

            IF v_partition_start_date < TRUNC (SYSDATE, 'MONTH')
            THEN
                -- only compress partitions in the correct time range
                v_result_code := partreorg_prepare ('SBS1_ADMIN', p_table_prefix || p_table_ext, v_partition_name);

                CASE
                    WHEN v_result_code = 0
                    THEN -- 0: success
                        NULL;
                    WHEN v_result_code = 1
                    THEN -- 1: prepared table and corresponding partition with different number of rows
                        RAISE TOO_MANY_ROWS;
                    WHEN v_result_code = 2
                    THEN -- 2: specified table-partition does not exist
                        RAISE NO_DATA_FOUND;
                    WHEN v_result_code = 3
                    THEN -- 3: reorg-table already exists
                        RAISE DUP_VAL_ON_INDEX;
                    ELSE
                        RAISE VALUE_ERROR;
                END CASE;
            END IF;

            v_retries := v_retries + 1;
            EXIT WHEN v_retries > v_retries_max;
        END LOOP;
    END sp_cpr_month_partitions;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_drop_month_partition (
        p_boh_id                                IN VARCHAR2, -- e.g. 0000012345
        p_table_prefix                          IN VARCHAR2, -- e.g. BDCUC, BDCUCIDX, BD6CUCIDX
        p_table_ext                             IN VARCHAR2, -- e.g. <NULL>, A, B, AE, BE
        p_partition_prefix                      IN VARCHAR2, -- e.g. CUCA
        p_partition_code                        IN VARCHAR2 -- e.g. 20051128
                                                           )
    IS --006SO
        v_ddl                                   VARCHAR2 (2000);
        v_script_id                             VARCHAR2 (10);
        v_script_state                          VARCHAR2 (10);

        v_table_name                            VARCHAR2 (20);
        v_partition_name                        VARCHAR2 (12);
    BEGIN
        v_partition_name := p_partition_prefix || p_partition_code;
        v_table_name := p_table_prefix || p_table_ext;
        v_script_state := 'OK'; -- in case partition alredy exist in correct tablespace

        IF get_tab_partition_count (v_table_name, v_partition_name, NULL) > 0
        THEN
            -- partition does exist
            -- Drop candidate partition
            v_ddl := 'ALTER TABLE ' || v_table_name || ' DROP PARTITION ' || v_partition_name;
            v_script_id :=
                pkg_script.create_and_execute (
                    'DropPartition',
                    1,
                    v_ddl,
                    p_table_ext,
                    p_boh_id,
                    v_script_state);
        END IF;

        IF v_script_state <> 'OK'
        THEN
            -- do an error logging
            pkg_common.insert_warning ( --008SO
                'PKG_PARTAG',
                'SP_DROP_SINGLE_MONTH_PARTITION',
                'Scripting Error',
                'See SCRIPT ID = ' || v_script_id,
                NULL,
                p_boh_id);
        END IF;
    END sp_drop_month_partition;
END pkg_partag;
/
