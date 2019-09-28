-- GENERATED CODE

/*
      Grant the SBSDB unit testing object privileges for the code coverage.
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
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_execute_grant_cover.sql');
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
END;
/

VARIABLE user_username VARCHAR2 ( 128 )
EXECUTE :user_username := UPPER('&1');

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Process package bodies - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_adhoc TO &1;');
END;
/
GRANT EXECUTE ON pkg_adhoc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_admin_common TO &1;');
END;
/
GRANT EXECUTE ON pkg_admin_common TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_bdetail_common TO &1;');
END;
/
GRANT EXECUTE ON pkg_bdetail_common TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_bdetail_info TO &1;');
END;
/
GRANT EXECUTE ON pkg_bdetail_info TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_bdetail_mmsc TO &1;');
END;
/
GRANT EXECUTE ON pkg_bdetail_mmsc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_bdetail_msc TO &1;');
END;
/
GRANT EXECUTE ON pkg_bdetail_msc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_bdetail_settlement TO &1;');
END;
/
GRANT EXECUTE ON pkg_bdetail_settlement TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_bdetail_smsc TO &1;');
END;
/
GRANT EXECUTE ON pkg_bdetail_smsc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_code_mgmt TO &1;');
END;
/
GRANT EXECUTE ON pkg_code_mgmt TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_common TO &1;');
END;
/
GRANT EXECUTE ON pkg_common TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_common_mapping TO &1;');
END;
/
GRANT EXECUTE ON pkg_common_mapping TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_common_packing TO &1;');
END;
/
GRANT EXECUTE ON pkg_common_packing TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_common_stats TO &1;');
END;
/
GRANT EXECUTE ON pkg_common_stats TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_cpro TO &1;');
END;
/
GRANT EXECUTE ON pkg_cpro TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_debug TO &1;');
END;
/
GRANT EXECUTE ON pkg_debug TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_interworking TO &1;');
END;
/
GRANT EXECUTE ON pkg_interworking TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_json TO &1;');
END;
/
GRANT EXECUTE ON pkg_json TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_kpi_bd TO &1;');
END;
/
GRANT EXECUTE ON pkg_kpi_bd TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_kpi_bd1 TO &1;');
END;
/
GRANT EXECUTE ON pkg_kpi_bd1 TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_kpi_bd2 TO &1;');
END;
/
GRANT EXECUTE ON pkg_kpi_bd2 TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_mec_hb TO &1;');
END;
/
GRANT EXECUTE ON pkg_mec_hb TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_mec_ic_ascii0 TO &1;');
END;
/
GRANT EXECUTE ON pkg_mec_ic_ascii0 TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_mec_ic_csv TO &1;');
END;
/
GRANT EXECUTE ON pkg_mec_ic_csv TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_mec_oc TO &1;');
END;
/
GRANT EXECUTE ON pkg_mec_oc TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_partag TO &1;');
END;
/
GRANT EXECUTE ON pkg_partag TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_reva TO &1;');
END;
/
GRANT EXECUTE ON pkg_reva TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_revi TO &1;');
END;
/
GRANT EXECUTE ON pkg_revi TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_script TO &1;');
END;
/
GRANT EXECUTE ON pkg_script TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_stats TO &1;');
END;
/
GRANT EXECUTE ON pkg_stats TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_toac_cpro TO &1;');
END;
/
GRANT EXECUTE ON pkg_toac_cpro TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_tpac_cpro TO &1;');
END;
/
GRANT EXECUTE ON pkg_tpac_cpro TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON pkg_zoning TO &1;');
END;
/
GRANT EXECUTE ON pkg_zoning TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_api_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_api_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_db_con TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_db_con TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_error_con TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_error_con TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_error_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_error_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_help_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_help_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_io_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_io_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_logger_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_logger_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_sql_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_sql_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_type_lib TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_type_lib TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON sbsdb_user_con TO &1;');
END;
/
GRANT EXECUTE ON sbsdb_user_con TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('GRANT EXECUTE ON usermng_sbs TO &1;');
END;
/
GRANT EXECUTE ON usermng_sbs TO &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Process package bodies - generated versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');
END;
/
BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_execute_grant_cover.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
