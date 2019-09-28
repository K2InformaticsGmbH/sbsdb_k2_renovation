-- GENERATED CODE

/*
   Create or update the SBSDB schema.
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
    DBMS_OUTPUT.put_line ('Current user is now: ' || USER);
    DBMS_OUTPUT.put_line ('================================================================================');
    DBMS_OUTPUT.put_line ('Start sbsdb_schema_update_software.sql');
END;
/

VARIABLE user_username        VARCHAR2 ( 128 )
EXECUTE :user_username        := UPPER('&1');
VARIABLE connect_identifier   VARCHAR2 ( 128 )
EXECUTE :connect_identifier   := UPPER('&3');
VARIABLE var_username         VARCHAR2 ( 128 )

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Switching database user ...');
END;
/

CONNECT &1/&2@&3;
/

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
    DBMS_OUTPUT.put_line ('Current user is now: ' || USER);
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/

DECLARE
    l_object_name                  VARCHAR2 (128);
    l_sql_stmnt                    VARCHAR2 (4000);
BEGIN
    DBMS_OUTPUT.put_line ('Installing Logger Sequence ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

    SELECT OBJECT_NAME
      INTO l_object_name
      FROM SYS.ALL_OBJECTS
     WHERE OBJECT_TYPE = 'SEQUENCE'
       AND OBJECT_NAME = 'SBSDB_LOG_SEQ'
       AND OWNER = UPPER(:user_username);

    DBMS_OUTPUT.put_line ('Database sequence SBSDB_LOG_SEQ is already existing !!!');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        l_sql_stmnt := 'CREATE SEQUENCE sbsdb_log_seq MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 CACHE 20';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

DECLARE
    l_object_name                  VARCHAR2 (128);
    l_sql_stmnt                    VARCHAR2 (4000);
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Installing SBSDB Log Table ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

    SELECT OBJECT_NAME
      INTO l_object_name
      FROM SYS.ALL_OBJECTS
     WHERE OBJECT_TYPE = 'TABLE'
       AND OBJECT_NAME = 'SBSDB_LOG'
       AND OWNER = UPPER(:user_username);

    DBMS_OUTPUT.put_line ('Database table SBSDB_LOG is already existing !!!');
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        l_sql_stmnt := '
CREATE TABLE sbsdb_log (
    ckey              NUMBER          NOT NULL,
    cvalue            CLOB            NOT NULL,
    chash             VARCHAR2 (20),
    logger_level      NUMBER,
    scope             VARCHAR2 (1000),
    time_stamp        TIMESTAMP (6),
    CONSTRAINT sbsdb_log_pk PRIMARY KEY (ckey) ENABLE)';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
        l_sql_stmnt := 'CREATE BITMAP INDEX idx_sdbsdb_log_01 ON sbsdb_log (logger_level)';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
        l_sql_stmnt := 'CREATE INDEX idx_sdbsdb_log_02 ON sbsdb_log (scope)';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
        l_sql_stmnt := 'CREATE INDEX idx_sdbsdb_log_03 ON sbsdb_log (time_stamp)';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compile prerequisites ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of types file src/types/sbsdb.tps');
END;
/
@src/types/sbsdb.tps
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_type_lib.pks');
END;
/
@src/packages/sbsdb_type_lib.pks
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_api_lib.pks');
END;
/
@src/packages/sbsdb_api_lib.pks
/

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile views - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('There are no views in the given directory !!!');
END;
/
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile synonyms - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('There are no synonyms in the given directory !!!');
END;
/
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile functions - generated versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/generated/sbsdb_api_group_trans.fnc');
END;
/
@src/functions/generated/sbsdb_api_group_trans.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/generated/sbsdb_api_scope_help.fnc');
END;
/
@src/functions/generated/sbsdb_api_scope_help.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/generated/sbsdb_api_scope_trans.fnc');
END;
/
@src/functions/generated/sbsdb_api_scope_trans.fnc

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile package specifications - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_adhoc.pks');
END;
/
@src/packages/pkg_adhoc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_admin_common.pks');
END;
/
@src/packages/pkg_admin_common.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_common.pks');
END;
/
@src/packages/pkg_bdetail_common.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_info.pks');
END;
/
@src/packages/pkg_bdetail_info.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_mmsc.pks');
END;
/
@src/packages/pkg_bdetail_mmsc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_msc.pks');
END;
/
@src/packages/pkg_bdetail_msc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_settlement.pks');
END;
/
@src/packages/pkg_bdetail_settlement.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_smsc.pks');
END;
/
@src/packages/pkg_bdetail_smsc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_code_mgmt.pks');
END;
/
@src/packages/pkg_code_mgmt.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common.pks');
END;
/
@src/packages/pkg_common.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common_mapping.pks');
END;
/
@src/packages/pkg_common_mapping.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common_packing.pks');
END;
/
@src/packages/pkg_common_packing.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common_stats.pks');
END;
/
@src/packages/pkg_common_stats.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_cpro.pks');
END;
/
@src/packages/pkg_cpro.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_debug.pks');
END;
/
@src/packages/pkg_debug.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_interworking.pks');
END;
/
@src/packages/pkg_interworking.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_json.pks');
END;
/
@src/packages/pkg_json.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_kpi_bd.pks');
END;
/
@src/packages/pkg_kpi_bd.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_kpi_bd1.pks');
END;
/
@src/packages/pkg_kpi_bd1.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_kpi_bd2.pks');
END;
/
@src/packages/pkg_kpi_bd2.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_hb.pks');
END;
/
@src/packages/pkg_mec_hb.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_ic_ascii0.pks');
END;
/
@src/packages/pkg_mec_ic_ascii0.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_ic_csv.pks');
END;
/
@src/packages/pkg_mec_ic_csv.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_oc.pks');
END;
/
@src/packages/pkg_mec_oc.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_partag.pks');
END;
/
@src/packages/pkg_partag.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_reva.pks');
END;
/
@src/packages/pkg_reva.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_revi.pks');
END;
/
@src/packages/pkg_revi.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_script.pks');
END;
/
@src/packages/pkg_script.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_stats.pks');
END;
/
@src/packages/pkg_stats.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_toac_cpro.pks');
END;
/
@src/packages/pkg_toac_cpro.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_tpac_cpro.pks');
END;
/
@src/packages/pkg_tpac_cpro.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_zoning.pks');
END;
/
@src/packages/pkg_zoning.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_db_con.pks');
END;
/
@src/packages/sbsdb_db_con.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_error_con.pks');
END;
/
@src/packages/sbsdb_error_con.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_error_lib.pks');
END;
/
@src/packages/sbsdb_error_lib.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_help_lib.pks');
END;
/
@src/packages/sbsdb_help_lib.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_io_lib.pks');
END;
/
@src/packages/sbsdb_io_lib.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_logger_lib.pks');
END;
/
@src/packages/sbsdb_logger_lib.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_sql_lib.pks');
END;
/
@src/packages/sbsdb_sql_lib.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_standalone_spec.pks');
END;
/
@src/packages/sbsdb_standalone_spec.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_user_con.pks');
END;
/
@src/packages/sbsdb_user_con.pks

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/usermng_sbs.pks');
END;
/
@src/packages/usermng_sbs.pks

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile package specifications - generated versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('There are no package specifications in the given directory !!!');
END;
/
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile package bodies - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_adhoc.pkb');
END;
/
@src/packages/pkg_adhoc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_admin_common.pkb');
END;
/
@src/packages/pkg_admin_common.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_common.pkb');
END;
/
@src/packages/pkg_bdetail_common.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_info.pkb');
END;
/
@src/packages/pkg_bdetail_info.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_mmsc.pkb');
END;
/
@src/packages/pkg_bdetail_mmsc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_msc.pkb');
END;
/
@src/packages/pkg_bdetail_msc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_settlement.pkb');
END;
/
@src/packages/pkg_bdetail_settlement.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_bdetail_smsc.pkb');
END;
/
@src/packages/pkg_bdetail_smsc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_code_mgmt.pkb');
END;
/
@src/packages/pkg_code_mgmt.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common.pkb');
END;
/
@src/packages/pkg_common.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common_mapping.pkb');
END;
/
@src/packages/pkg_common_mapping.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common_packing.pkb');
END;
/
@src/packages/pkg_common_packing.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_common_stats.pkb');
END;
/
@src/packages/pkg_common_stats.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_cpro.pkb');
END;
/
@src/packages/pkg_cpro.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_debug.pkb');
END;
/
@src/packages/pkg_debug.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_interworking.pkb');
END;
/
@src/packages/pkg_interworking.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_json.pkb');
END;
/
@src/packages/pkg_json.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_kpi_bd.pkb');
END;
/
@src/packages/pkg_kpi_bd.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_kpi_bd1.pkb');
END;
/
@src/packages/pkg_kpi_bd1.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_kpi_bd2.pkb');
END;
/
@src/packages/pkg_kpi_bd2.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_hb.pkb');
END;
/
@src/packages/pkg_mec_hb.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_ic_ascii0.pkb');
END;
/
@src/packages/pkg_mec_ic_ascii0.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_ic_csv.pkb');
END;
/
@src/packages/pkg_mec_ic_csv.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_mec_oc.pkb');
END;
/
@src/packages/pkg_mec_oc.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_partag.pkb');
END;
/
@src/packages/pkg_partag.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_reva.pkb');
END;
/
@src/packages/pkg_reva.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_revi.pkb');
END;
/
@src/packages/pkg_revi.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_script.pkb');
END;
/
@src/packages/pkg_script.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_stats.pkb');
END;
/
@src/packages/pkg_stats.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_toac_cpro.pkb');
END;
/
@src/packages/pkg_toac_cpro.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_tpac_cpro.pkb');
END;
/
@src/packages/pkg_tpac_cpro.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/pkg_zoning.pkb');
END;
/
@src/packages/pkg_zoning.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_api_lib.pkb');
END;
/
@src/packages/sbsdb_api_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_db_con.pkb');
END;
/
@src/packages/sbsdb_db_con.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_error_con.pkb');
END;
/
@src/packages/sbsdb_error_con.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_error_lib.pkb');
END;
/
@src/packages/sbsdb_error_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_help_lib.pkb');
END;
/
@src/packages/sbsdb_help_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_io_lib.pkb');
END;
/
@src/packages/sbsdb_io_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_logger_lib.pkb');
END;
/
@src/packages/sbsdb_logger_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_sql_lib.pkb');
END;
/
@src/packages/sbsdb_sql_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_type_lib.pkb');
END;
/
@src/packages/sbsdb_type_lib.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_user_con.pkb');
END;
/
@src/packages/sbsdb_user_con.pkb

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/usermng_sbs.pkb');
END;
/
@src/packages/usermng_sbs.pkb

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile package bodies - generated versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');
END;
/
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile functions - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/duration.fnc');
END;
/
@src/functions/duration.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/generateuniquekey.fnc');
END;
/
@src/functions/generateuniquekey.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpsh_tpac_new_adr_id.fnc');
END;
/
@src/functions/gpsh_tpac_new_adr_id.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_content_service_json.fnc');
END;
/
@src/functions/gpull_content_service_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_currency_json.fnc');
END;
/
@src/functions/gpull_currency_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_keyword_json.fnc');
END;
/
@src/functions/gpull_keyword_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_price_json.fnc');
END;
/
@src/functions/gpull_price_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_toac_smsc_json.fnc');
END;
/
@src/functions/gpull_toac_smsc_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_tocon_json.fnc');
END;
/
@src/functions/gpull_tocon_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/gpull_tpac_json.fnc');
END;
/
@src/functions/gpull_tpac_json.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/is_integer.fnc');
END;
/
@src/functions/is_integer.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/is_numeric.fnc');
END;
/
@src/functions/is_numeric.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/job_datefrom.fnc');
END;
/
@src/functions/job_datefrom.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/job_dateto.fnc');
END;
/
@src/functions/job_dateto.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/job_parameter.fnc');
END;
/
@src/functions/job_parameter.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/json_boolean.fnc');
END;
/
@src/functions/json_boolean.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/json_date.fnc');
END;
/
@src/functions/json_date.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/json_key_snn.fnc');
END;
/
@src/functions/json_key_snn.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/json_number.fnc');
END;
/
@src/functions/json_number.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/json_string.fnc');
END;
/
@src/functions/json_string.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/json_string_key.fnc');
END;
/
@src/functions/json_string_key.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/longid_range.fnc');
END;
/
@src/functions/longid_range.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/reva_sigmask_merge.fnc');
END;
/
@src/functions/reva_sigmask_merge.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/settledduration.fnc');
END;
/
@src/functions/settledduration.fnc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of function file src/functions/speed.fnc');
END;
/
@src/functions/speed.fnc

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile procedures - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/app_create_synonym.prc');
END;
/
@src/procedures/app_create_synonym.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/configure_for_test.prc');
END;
/
@src/procedures/configure_for_test.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_currency_exr_del.prc');
END;
/
@src/procedures/gpsh_currency_exr_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_currency_exr_put.prc');
END;
/
@src/procedures/gpsh_currency_exr_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_currency_put.prc');
END;
/
@src/procedures/gpsh_currency_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_price_content_put.prc');
END;
/
@src/procedures/gpsh_price_content_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_price_model_put.prc');
END;
/
@src/procedures/gpsh_price_model_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_price_transport_put.prc');
END;
/
@src/procedures/gpsh_price_transport_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_price_version_del.prc');
END;
/
@src/procedures/gpsh_price_version_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_price_version_put.prc');
END;
/
@src/procedures/gpsh_price_version_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_toac_con_del.prc');
END;
/
@src/procedures/gpsh_toac_con_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_toac_con_put.prc');
END;
/
@src/procedures/gpsh_toac_con_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_toac_smsc_del.prc');
END;
/
@src/procedures/gpsh_toac_smsc_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_toac_smsc_put.prc');
END;
/
@src/procedures/gpsh_toac_smsc_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_con_del.prc');
END;
/
@src/procedures/gpsh_tpac_con_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_con_put.prc');
END;
/
@src/procedures/gpsh_tpac_con_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_cs_del.prc');
END;
/
@src/procedures/gpsh_tpac_cs_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_cs_put.prc');
END;
/
@src/procedures/gpsh_tpac_cs_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_del.prc');
END;
/
@src/procedures/gpsh_tpac_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_keyword_del.prc');
END;
/
@src/procedures/gpsh_tpac_keyword_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_keyword_put.prc');
END;
/
@src/procedures/gpsh_tpac_keyword_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_longid_map_del.prc');
END;
/
@src/procedures/gpsh_tpac_longid_map_del.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_longid_map_put.prc');
END;
/
@src/procedures/gpsh_tpac_longid_map_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/gpsh_tpac_put.prc');
END;
/
@src/procedures/gpsh_tpac_put.prc

BEGIN
    DBMS_OUTPUT.put_line ('Compilation of procedure file src/procedures/sbsdb_help.prc');
END;
/
@src/procedures/sbsdb_help.prc

BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Compile triggers - handy versions ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('There are no triggers in the given directory !!!');
END;
/
DECLARE
    l_rownum                       PLS_INTEGER;
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('Initialization of the SBSDB log table ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

    BEGIN
        SELECT ROWNUM
          INTO l_rownum
          FROM sbsdb_log
         WHERE ROWNUM = 1;

         DBMS_OUTPUT.put_line ('Table SBSDB_LOG is already initialized !!!');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            sbsdb_logger_lib.log_permanent ('SBSDB Logger installed.');
            DBMS_OUTPUT.put_line ('Table SBSDB_LOG is now initialized.');
    END;
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_schema_update_software.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
