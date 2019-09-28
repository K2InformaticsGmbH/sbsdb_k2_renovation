/*
   Create or update the unit test schema.
*/

SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 200
SET PAGESIZE 0
SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED
SET TAB OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;

BEGIN
    DBMS_OUTPUT.put_line ('================================================================================');
    DBMS_OUTPUT.put_line ('Start sbsdb_ut_schema_ut_create_or_update.sql');
    DBMS_OUTPUT.put_line ('Session user: ' || SYS_CONTEXT ('userenv', 'session_user'));
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
END;
/

VARIABLE user_username_sbsdb       VARCHAR2 ( 128 )
EXECUTE :user_username_sbsdb       := UPPER('&1');
VARIABLE user_username_ut          VARCHAR2 ( 128 )
EXECUTE :user_username_ut          := UPPER('&2');
VARIABLE var_username              VARCHAR2 ( 128 )

DECLARE
    l_sql_stmnt                             VARCHAR2 (4000);
BEGIN
    IF :user_username_ut <> :user_username_sbsdb
    THEN
        BEGIN
            SELECT username
            INTO   :var_username
            FROM   sys.dba_users
            WHERE  username = :user_username_ut;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                :var_username := 'n/a';
        END;

        IF :var_username = :user_username_ut
        THEN
            DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
            DBMS_OUTPUT.put_line ('Unit test schema ' || UPPER ('&2') || ' is already existing !');
            DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
        ELSE
            DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
            DBMS_OUTPUT.put_line ('Unit test schema ' || UPPER ('&2') || ' will now be created ...');
            DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

            l_sql_stmnt := 'CREATE USER ' || :user_username_ut || ' IDENTIFIED BY &3';
            EXECUTE IMMEDIATE l_sql_stmnt;
            DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

            l_sql_stmnt := 'ALTER USER ' || :user_username_ut || ' ACCOUNT UNLOCK';
            EXECUTE IMMEDIATE l_sql_stmnt;
            DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

            l_sql_stmnt := 'ALTER USER ' || :user_username_ut || ' DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp';
            EXECUTE IMMEDIATE l_sql_stmnt;
            DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
        END IF;

        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');
        DBMS_OUTPUT.put_line ('GRANT system privileges required by unit test schema ...');
        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');

        l_sql_stmnt := 'GRANT CREATE ANY PROCEDURE TO ' || :user_username_ut;
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'GRANT CREATE ANY TRIGGER TO ' || :user_username_ut;
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'GRANT CREATE SEQUENCE TO ' || :user_username_ut;
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'GRANT CREATE SESSION TO ' || :user_username_ut;
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

        l_sql_stmnt := 'GRANT CREATE TABLE TO ' || :user_username_ut;
        EXECUTE IMMEDIATE l_sql_stmnt;
        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
    END IF;

    l_sql_stmnt := 'GRANT GRANT ANY PRIVILEGE TO ' || :user_username_ut;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);

    l_sql_stmnt := 'GRANT SELECT ON SYS.USER_SYS_PRIVS TO ' || :user_username_ut;
    EXECUTE IMMEDIATE l_sql_stmnt;
    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);
END;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_ut_schema_ut_create_or_update.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
