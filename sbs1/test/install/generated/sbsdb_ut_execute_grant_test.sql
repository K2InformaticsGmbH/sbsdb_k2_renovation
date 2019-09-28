-- GENERATED CODE

/*
      Grant the SBSDB unit testing object privileges for the unit tests.
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
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_execute_grant_test.sql');
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
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_in_development TO &1;');
END;
/
GRANT EXECUTE ON test_in_development TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_admin_common TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_admin_common TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_bdetail_common TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_bdetail_common TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_bdetail_info TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_bdetail_info TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_bdetail_mmsc TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_bdetail_mmsc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_bdetail_msc TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_bdetail_msc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_bdetail_settlement TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_bdetail_settlement TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_bdetail_smsc TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_bdetail_smsc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_code_mgmt TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_code_mgmt TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_common TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_common TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_common_mapping TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_common_mapping TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_common_packing TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_common_packing TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_common_stats TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_common_stats TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_debug TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_debug TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_json TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_json TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_mec_ic_csv TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_mec_ic_csv TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_reva TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_reva TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_pkg_revi TO &1;');
END;
/
GRANT EXECUTE ON test_pkg_revi TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_sbsdb_io TO &1;');
END;
/
GRANT EXECUTE ON test_sbsdb_io TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_sbsdb_logger TO &1;');
END;
/
GRANT EXECUTE ON test_sbsdb_logger TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON test_sbsdb_standalone TO &1;');
END;
/
GRANT EXECUTE ON test_sbsdb_standalone TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_execute_grant_test.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
