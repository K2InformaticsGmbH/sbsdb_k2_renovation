-- GENERATED CODE

/*
      Revoke the SBSDB unit testing object privileges for the code coverage.
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
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_execute_revoke_cover.sql');
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
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_adhoc FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_adhoc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_admin_common FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_admin_common FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_bdetail_common FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_bdetail_common FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_bdetail_info FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_bdetail_info FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_bdetail_mmsc FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_bdetail_mmsc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_bdetail_msc FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_bdetail_msc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_bdetail_settlement FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_bdetail_settlement FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_bdetail_smsc FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_bdetail_smsc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_code_mgmt FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_code_mgmt FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_common FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_common FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_common_mapping FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_common_mapping FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_common_packing FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_common_packing FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_common_stats FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_common_stats FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_cpro FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_cpro FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_debug FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_debug FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_interworking FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_interworking FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_json FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_json FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_kpi_bd FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_kpi_bd FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_kpi_bd1 FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_kpi_bd1 FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_kpi_bd2 FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_kpi_bd2 FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_mec_hb FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_mec_hb FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_mec_ic_ascii0 FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_mec_ic_ascii0 FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_mec_ic_csv FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_mec_ic_csv FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_mec_oc FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_mec_oc FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_partag FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_partag FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_reva FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_reva FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_revi FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_revi FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_script FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_script FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_stats FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_stats FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_toac_cpro FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_toac_cpro FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_tpac_cpro FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_tpac_cpro FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON pkg_zoning FROM &1;');
END;
/
REVOKE EXECUTE ON pkg_zoning FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_api_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_api_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_db_con FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_db_con FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_error_con FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_error_con FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_error_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_error_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_help_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_help_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_io_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_io_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_logger_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_logger_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_sql_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_sql_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_type_lib FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_type_lib FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON sbsdb_user_con FROM &1;');
END;
/
REVOKE EXECUTE ON sbsdb_user_con FROM &1;
/

BEGIN
    DBMS_OUTPUT.put_line ('REVOKE EXECUTE ON usermng_sbs FROM &1;');
END;
/
REVOKE EXECUTE ON usermng_sbs FROM &1;
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
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_execute_revoke_cover.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
