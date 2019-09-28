-- GENERATED CODE

/*
   Drop the SBSDB unit testing.
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
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_package_drop.sql');
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Uninstall packages ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_in_development');
END;
/
DROP PACKAGE test_in_development
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_admin_common');
END;
/
DROP PACKAGE test_pkg_admin_common
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_bdetail_common');
END;
/
DROP PACKAGE test_pkg_bdetail_common
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_bdetail_info');
END;
/
DROP PACKAGE test_pkg_bdetail_info
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_bdetail_mmsc');
END;
/
DROP PACKAGE test_pkg_bdetail_mmsc
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_bdetail_msc');
END;
/
DROP PACKAGE test_pkg_bdetail_msc
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_bdetail_settlement');
END;
/
DROP PACKAGE test_pkg_bdetail_settlement
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_bdetail_smsc');
END;
/
DROP PACKAGE test_pkg_bdetail_smsc
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_code_mgmt');
END;
/
DROP PACKAGE test_pkg_code_mgmt
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_common');
END;
/
DROP PACKAGE test_pkg_common
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_common_mapping');
END;
/
DROP PACKAGE test_pkg_common_mapping
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_common_packing');
END;
/
DROP PACKAGE test_pkg_common_packing
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_common_stats');
END;
/
DROP PACKAGE test_pkg_common_stats
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_debug');
END;
/
DROP PACKAGE test_pkg_debug
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_json');
END;
/
DROP PACKAGE test_pkg_json
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_mec_ic_csv');
END;
/
DROP PACKAGE test_pkg_mec_ic_csv
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_reva');
END;
/
DROP PACKAGE test_pkg_reva
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_pkg_revi');
END;
/
DROP PACKAGE test_pkg_revi
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_sbsdb_io');
END;
/
DROP PACKAGE test_sbsdb_io
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_sbsdb_logger');
END;
/
DROP PACKAGE test_sbsdb_logger
/

BEGIN
    DBMS_OUTPUT.put_line ('DROP PACKAGE test_sbsdb_standalone');
END;
/
DROP PACKAGE test_sbsdb_standalone
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_package_drop.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
