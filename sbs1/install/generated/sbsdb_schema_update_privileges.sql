-- GENERATED CODE

/*
   Create or update the SBSDB schema - privileges.
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
    DBMS_OUTPUT.put_line ('Start sbsdb_schema_update_privileges.sql');
END;
/

VARIABLE user_username        VARCHAR2 ( 128 )
EXECUTE :user_username        := UPPER('&1');
VARIABLE connect_identifier   VARCHAR2 ( 128 )
EXECUTE :connect_identifier   := UPPER('&3');
VARIABLE var_username         VARCHAR2 ( 128 )

DECLARE
    TYPE l_object_names_nt IS TABLE OF VARCHAR2 (128);
    TYPE l_privileges_nt IS TABLE OF VARCHAR2 (40);

    l_object_name                  VARCHAR2 (128);
    l_object_names_ntv             l_object_names_nt;
    l_privileges_ntv               l_privileges_nt;
    l_sql_stmnt                    VARCHAR2 (4000);
BEGIN
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
    DBMS_OUTPUT.put_line ('GRANT privileges required by SBSDB ...');
    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

    l_sql_stmnt := 'GRANT EXECUTE ON sys.utl_file TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT SELECT ON sys.v_$database TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CONNECT TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CREATE PROCEDURE TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CREATE SEQUENCE TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CREATE SESSION TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CREATE TABLE TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CREATE TYPE TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT CREATE USER TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT UNLIMITED TABLESPACE TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT SELECT ON sys.dba_objects TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    l_sql_stmnt := 'GRANT SELECT ON sys.v_$parameter TO ' || :user_username;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

END;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_schema_update_privileges.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
