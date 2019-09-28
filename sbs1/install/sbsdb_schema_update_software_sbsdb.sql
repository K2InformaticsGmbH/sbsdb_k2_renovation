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
    DBMS_OUTPUT.put_line ('Start sbsdb_schema_update_software_sbsdb.sql');
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
    DBMS_OUTPUT.put_line ('End   sbsdb_schema_update_software_sbsdb.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
