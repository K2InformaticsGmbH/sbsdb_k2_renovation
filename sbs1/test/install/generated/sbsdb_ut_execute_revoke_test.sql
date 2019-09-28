-- GENERATED CODE

/*
      Revoke the SBSDB unit testing object privileges for the unit tests.
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
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_execute_revoke_test.sql');
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
END;
/

VARIABLE user_username VARCHAR2 ( 128 )
EXECUTE :user_username := UPPER('&1');

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Process package specifications ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_in_development FROM &1;');
END;
/
REVOKE EXECUTE ON test_in_development FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_admin_common FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_admin_common FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_bdetail_common FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_bdetail_common FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_bdetail_info FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_bdetail_info FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_bdetail_mmsc FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_bdetail_mmsc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_bdetail_msc FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_bdetail_msc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_bdetail_settlement FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_bdetail_settlement FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_bdetail_smsc FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_bdetail_smsc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_code_mgmt FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_code_mgmt FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_common FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_common FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_common_mapping FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_common_mapping FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_common_packing FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_common_packing FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_common_stats FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_common_stats FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_debug FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_debug FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_json FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_json FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_mec_ic_csv FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_mec_ic_csv FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_reva FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_reva FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_pkg_revi FROM &1;');
END;
/
REVOKE EXECUTE ON test_pkg_revi FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_sbsdb_io FROM &1;');
END;
/
REVOKE EXECUTE ON test_sbsdb_io FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_sbsdb_logger FROM &1;');
END;
/
REVOKE EXECUTE ON test_sbsdb_logger FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON test_sbsdb_standalone FROM &1;');
END;
/
REVOKE EXECUTE ON test_sbsdb_standalone FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_execute_revoke_test.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
