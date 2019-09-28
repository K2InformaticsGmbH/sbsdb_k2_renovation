/*
   Create the SBSDB schema.
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
    DBMS_OUTPUT.put_line ('Current user is now: ' || USER);
    DBMS_OUTPUT.put_line ('================================================================================');
    DBMS_OUTPUT.put_line ('Start sbsdb_schema_create.sql');
END;
/

VARIABLE user_username        VARCHAR2 ( 128 )
EXECUTE :user_username        := UPPER('&1');
VARIABLE var_username         VARCHAR2 ( 128 )

DECLARE
    TYPE l_object_names_nt IS TABLE OF VARCHAR2 (128);

    TYPE l_privileges_nt IS TABLE OF VARCHAR2 (40);

    l_object_name                           VARCHAR2 (128);
    l_object_names_ntv                      l_object_names_nt;
    l_privileges_ntv                        l_privileges_nt;
    l_sql_stmnt                             VARCHAR2 (4000);
BEGIN
    BEGIN
        SELECT username
        INTO   :var_username
        FROM   sys.dba_users
        WHERE  username = :user_username;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            :var_username := 'n/a';
    END;

    IF :var_username = :user_username
    THEN
        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
        DBMS_OUTPUT.put_line ('Update SBSDB schema ' || UPPER ('&1') || ' ...');
    ELSE
        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
        DBMS_OUTPUT.put_line ('Create SBSDB schema ' || UPPER ('&1') || ' ...');
        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

        l_sql_stmnt := 'CREATE USER ' || :user_username || ' IDENTIFIED BY &2';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'ALTER USER ' || :user_username || ' ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'ALTER USER ' || :user_username || ' DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'ALTER USER ' || :user_username || ' QUOTA UNLIMITED ON users';
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'GRANT CREATE VIEW TO ' || :user_username;
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    END IF;
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_schema_create.sql');
END;
/
