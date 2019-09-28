/*
   Create the SBSDB view(s).
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
    DBMS_OUTPUT.put_line ('Start sbsdb_view_create.sql');
END;
/

CREATE OR REPLACE VIEW sbsdb_log_details
AS
   SELECT ckey,
          cvalue,
          chash,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"action":"')           + LENGTH ( ',"action":"'),           INSTR (cvalue, '","callStack":"')        - LENGTH ( ',"action":"')           - INSTR (cvalue,  ',"action":"')))                                                   AS action,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"callStack":"')        + LENGTH ( ',"callStack":"'),        INSTR (cvalue, '","clientIdentifier":"') - LENGTH ( ',"callStack":"')        - INSTR (cvalue,  ',"callStack":"')))                                                AS call_stack,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"clientIdentifier":"') + LENGTH ( ',"clientIdentifier":"'), INSTR (cvalue, '","clientInfo":"')       - LENGTH ( ',"clientIdentifier":"') - INSTR (cvalue,  ',"clientIdentifier":"')))                                         AS client_identifier,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","clientInfo":"')       + LENGTH ('","clientInfo":"'),       INSTR (cvalue, '","extra":"')            - LENGTH ('","clientInfo":"')       - INSTR (cvalue, '","clientInfo":"')))                                               AS client_info,
                SUBSTR      (TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","extra":"')            + LENGTH ('","extra":"'),            INSTR (cvalue, '","lineNo":')            - LENGTH ('","extra":"')            - INSTR (cvalue, '","extra":"'))), 1, 4000)                                          AS extra,
                TO_NUMBER   (TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","lineNo":')            + LENGTH ('","lineNo":'),            INSTR (cvalue,  ',"loggerLevel":')       - LENGTH ('","lineNo":')            - INSTR (cvalue, '","lineNo":'))))                                                   AS line_no,
--              TO_NUMBER   (TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"loggerLevel":')       + LENGTH ( ',"loggerLevel":'),       INSTR (cvalue,  ',"module":"')           - LENGTH ( ',"loggerLevel":')       - INSTR (cvalue,  ',"loggerLevel":'))))                                              AS logger_level,
          logger_level,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"module":"')           + LENGTH ( ',"module":"'),           INSTR (cvalue, '","osUserName":"')       - LENGTH ( ',"module":"')           - INSTR (cvalue,  ',"module":"')))                                                   AS module,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","osUserName":"')       + LENGTH ('","osUserName":"'),       INSTR (cvalue, '","scn":')               - LENGTH ('","osUserName":"')       - INSTR (cvalue, '","osUserName":"')))                                               AS os_user_name,
                TO_NUMBER   (TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","scn":')               + LENGTH ('","scn":'),               INSTR (cvalue,  ',"scope":"')            - LENGTH ('","scn":')               - INSTR (cvalue, '","scn":'))))                                                      AS scn,
--                           TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"scope":"')            + LENGTH ( ',"scope":"'),            INSTR (cvalue, '","sid":')               - LENGTH ( ',"scope":"')            - INSTR (cvalue,  ',"scope":"')))                                                    AS scope,
          scope,
                TO_NUMBER   (TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","sid":')               + LENGTH ('","sid":'),               INSTR (cvalue,  ',"text":"')             - LENGTH ('","sid":')               - INSTR (cvalue, '","sid":'))))                                                      AS sid,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"text":"')             + LENGTH ( ',"text":"'),             INSTR (cvalue, '","timeStamp":"')        - LENGTH ( ',"text":"')             - INSTR (cvalue,  ',"text":"')))                                                     AS text,
--        CAST (TO_TIMESTAMP(TO_CHAR (SUBSTR (cvalue, INSTR (cvalue,  ',"timeStamp":"')        + LENGTH ( ',"timeStamp":"'),        INSTR (cvalue, '","unitName":"')         - LENGTH ( ',"timeStamp":"')        - INSTR (cvalue,  ',"timeStamp":"'))), 'YYYY-MM-DD HH24:MI:SS.FF9') AS TIMESTAMP(6)) AS time_stamp,
          time_stamp,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","unitName":"')         + LENGTH ('","unitName":"'),         INSTR (cvalue, '","userName":"')         - LENGTH ('","unitName":"')         - INSTR (cvalue, '","unitName":"')))                                                 AS unit_name,
                             TO_CHAR (SUBSTR (cvalue, INSTR (cvalue, '","userName":"')         + LENGTH ('","userName":"'),         INSTR (cvalue, '"}')                     - LENGTH ('","userName":"')         - INSTR (cvalue, '","userName":"')))                                                 AS user_name
   FROM   sbsdb_log;
/

BEGIN
    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.put_line ('End   sbsdb_view_create.sql');
    DBMS_OUTPUT.put_line ('================================================================================');
END;
/
