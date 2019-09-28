-- GENERATED CODE

/*
   Create or update the SBSDB unit testing.
*/

SET ECHO         OFF
SET FEEDBACK     OFF
SET HEADING      OFF
SET LINESIZE     200
SET PAGESIZE     0
SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED
SET TAB          OFF
SET VERIFY       OFF
WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;

BEGIN
    DBMS_OUTPUT.put_line ('================================================================================');
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_package_create.sql');
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Process package specifications ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_in_development.pks');
END;
/
@src/packages/test_in_development.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_admin_common.pks');
END;
/
@src/packages/test_pkg_admin_common.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_common.pks');
END;
/
@src/packages/test_pkg_bdetail_common.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_info.pks');
END;
/
@src/packages/test_pkg_bdetail_info.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_mmsc.pks');
END;
/
@src/packages/test_pkg_bdetail_mmsc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_msc.pks');
END;
/
@src/packages/test_pkg_bdetail_msc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_settlement.pks');
END;
/
@src/packages/test_pkg_bdetail_settlement.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_smsc.pks');
END;
/
@src/packages/test_pkg_bdetail_smsc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_code_mgmt.pks');
END;
/
@src/packages/test_pkg_code_mgmt.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common.pks');
END;
/
@src/packages/test_pkg_common.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common_mapping.pks');
END;
/
@src/packages/test_pkg_common_mapping.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common_packing.pks');
END;
/
@src/packages/test_pkg_common_packing.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common_stats.pks');
END;
/
@src/packages/test_pkg_common_stats.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_debug.pks');
END;
/
@src/packages/test_pkg_debug.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_json.pks');
END;
/
@src/packages/test_pkg_json.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_mec_ic_csv.pks');
END;
/
@src/packages/test_pkg_mec_ic_csv.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_reva.pks');
END;
/
@src/packages/test_pkg_reva.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_revi.pks');
END;
/
@src/packages/test_pkg_revi.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_sbsdb_io.pks');
END;
/
@src/packages/test_sbsdb_io.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_sbsdb_logger.pks');
END;
/
@src/packages/test_sbsdb_logger.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_sbsdb_standalone.pks');
END;
/
@src/packages/test_sbsdb_standalone.pks

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Process package bodies ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_in_development.pkb');
END;
/
@src/packages/test_in_development.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_admin_common.pkb');
END;
/
@src/packages/test_pkg_admin_common.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_common.pkb');
END;
/
@src/packages/test_pkg_bdetail_common.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_info.pkb');
END;
/
@src/packages/test_pkg_bdetail_info.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_mmsc.pkb');
END;
/
@src/packages/test_pkg_bdetail_mmsc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_msc.pkb');
END;
/
@src/packages/test_pkg_bdetail_msc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_settlement.pkb');
END;
/
@src/packages/test_pkg_bdetail_settlement.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_bdetail_smsc.pkb');
END;
/
@src/packages/test_pkg_bdetail_smsc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_code_mgmt.pkb');
END;
/
@src/packages/test_pkg_code_mgmt.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common.pkb');
END;
/
@src/packages/test_pkg_common.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common_mapping.pkb');
END;
/
@src/packages/test_pkg_common_mapping.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common_packing.pkb');
END;
/
@src/packages/test_pkg_common_packing.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_common_stats.pkb');
END;
/
@src/packages/test_pkg_common_stats.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_debug.pkb');
END;
/
@src/packages/test_pkg_debug.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_json.pkb');
END;
/
@src/packages/test_pkg_json.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_mec_ic_csv.pkb');
END;
/
@src/packages/test_pkg_mec_ic_csv.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_reva.pkb');
END;
/
@src/packages/test_pkg_reva.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_pkg_revi.pkb');
END;
/
@src/packages/test_pkg_revi.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_sbsdb_io.pkb');
END;
/
@src/packages/test_sbsdb_io.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_sbsdb_logger.pkb');
END;
/
@src/packages/test_sbsdb_logger.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/test_sbsdb_standalone.pkb');
END;
/
@src/packages/test_sbsdb_standalone.pkb

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_package_create.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
