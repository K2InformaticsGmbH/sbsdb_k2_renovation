# Application Log

## 1 Purpose

The purpose of an application log file is to document SBSDB API usage, flow issues and application problems. It also contains information about user and system actions that have occurred. Logged events include the following:

- Start of SBSDB API functions or procedures (methods), including parameters.
- End of SBSDB API methods, possibly including function result.
- Error situations.

In the following we use a program excerpt to show typical logger usage in the application code.

```SQL
    PROCEDURE revoke_role (
        p_role_in                      IN sbsdb_type_lib.input_name_t := NULL,
        p_username_in                  IN sbsdb_type_lib.input_name_t := NULL)
    IS
        l_quoted_role                  sbsdb_type_lib.input_name_t;
        l_quoted_username              sbsdb_type_lib.input_name_t;
        l_role                         SYS.dba_roles.role%TYPE;
        l_username                     SYS.dba_users.username%TYPE;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'revoke_role'),
            sbsdb_logger_lib.log_param ('p_role_in', p_role_in),
            sbsdb_logger_lib.log_param ('p_username_in', p_username_in));

        sbsdb_db_con.raise_non_valid_db_version ();

        ...

        sbsdb_sql_lib.sql_exec ('REVOKE :1 FROM :2', l_quoted_role, l_quoted_username);

        sbsdb_sql_lib.put_line ('role ' || l_quoted_role || ' revoked.');

        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'revoke_role'));
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (
                SQLCODE,
                SQLERRM,
                sbsdb_logger_lib.scope ($$plsql_unit, 'revoke_role'),
                sbsdb_logger_lib.log_param ('p_role_in', p_role_in),
                sbsdb_logger_lib.log_param ('p_username_in', p_username_in));
            RAISE;
    END revoke_role;
```

## 2 Log Calls

### Method start and end logging

These log calls are used to control the program flow. The first and the last statement of a method - for a function immediately before the `RETURN` - consist of the call of the procedure `sbsdb_logger_lib.log_info`:

```SQL
    PROCEDURE log_info (
        p_text_in                               IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_2_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_3_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_4_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_5_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
    Application can use this to log application events on info level.

    Parameters:
        p_text_in       - text describing the event to be logged
        p_scope_in      - method qualified name without schema <package>.<method>
        p_params_1_in   - (optional) method parameters (name,val) of request parameters
        p_params_%_in   - (optional) method parameters (name,val) of request parameters
    */;
```

- `p_text_in` contains either the string `Start` or `End`

### Error logging

These logging calls are used to document user and program errors. To do this, the procedure `sbsdb_error_lib.log` is called in the exception section:

```SQL
    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t,
        p_log_param_2_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_3_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_4_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_5_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param) /*<>
    Creates the error message and calls the print and logging utility

    Parameters:
        p_errcode_in        - the SQLCODE
        p_errmsg_in         - the error text to print (or NULL for the default)
        p_log_scope_in      - the logging scope  <package>.<procedure>
        p_log_param_1_in    - optional interesting input parameter name and value
        p_log_param_2_in    - optional interesting input parameter name and value
        p_log_param_3_in    - optional interesting input parameter name and value
        p_log_param_4_in    - optional interesting input parameter name and value
        p_log_param_5_in    - optional interesting input parameter name and value
    */;
```

## 3 Log Entry Content

A log entry contains the following data:

| Name             | Content |
| ---------------- | ------------- |
| ckey             | consecutive number based on the sequence `SBSDB_LOG_SEQ` |
| action           | return value of the `SYS_CONTEXT ('userenv', 'action')` call |
| callStack        | stack trace from the `DBMS_UTILITY.format_call_stack` call |
| clientIdentifier | return value of the `SYS_CONTEXT ('userenv', 'client_identifier')` call |
| clientInfo       | return value of the `SYS_CONTEXT ('userenv', 'client_info')` call |
| extra            | maps the optional `extra` parameter of the logging call |
| lineNo           | line number from the stack trace |
| loggerLevel      | 1 = permanent / 2 = error / 8 = information |
| module           | return value of the `SYS_CONTEXT ('userenv', 'module')` call |
| osUerName        | return value of the `SYS_CONTEXT ('userenv', 'os_user')` call |
| scn              | column `CURRENT_SCN` from view `V$DATABASE` |
| scope            | maps the `scope` parameter of the logging call  |
| sid              | return value of the `SYS_CONTEXT ('userenv', 'sid')` call |
| text             | maps the `text` parameter of the logging call |
| timeStamp        | return value of the `SYSTIMESTAMP`function |
| unitName         | unit from the stack trace |
| userName         | return value of the `USER` function |

The scope parameter will define the API usage signature of the log event. 
The application code contributes <method_name> and possibly <package_name> if running in a package.
The logger library prefixes this with the unique database name and the PDB name, if running in a PDB.

Example logging entry in JSON format:

```JSON
	{"ckey":58,"action":"test_sbsdb_logger","callStack":"  object      line  object\n  handle    number  name\n00007FF92F349D50       788  package body SBS1_ADMIN.SBSDB_LOGGER_LIB.LOG_INFO\n00007FF92F349D50       336  package body SBS1_ADMIN.SBSDB_LOGGER_LIB.LOG_INFO\n00007FF9309A0F28       239  package body SBS1_ADMIN.TEST_SBSDB_LOGGER.LOG_INFO_TABLE\n00007FF927547850         6  anonymous block\n00007FF93DA15C58      1721  package body SYS.DBMS_SQL.EXECUTE\n00007FF93057BAD0       142  type body UT3.UT_EXECUTABLE.DO_EXECUTE\n00007FF93057BAD0        40  type body UT3.UT_EXECUTABLE.DO_EXECUTE\n00007FF92E38EF30        57  type body UT3.UT_EXECUTABLE_TEST.DO_EXECUTE\n00007FF92E38EF30        21  type body UT3.UT_EXECUTABLE_TEST.DO_EXECUTE\n00007FF92E38D8D0        78  type body UT3.UT_TEST.DO_EXECUTE\n00007FF930474118        49  type body UT3.UT_SUITE_ITEM.DO_EXECUTE\n00007FF92E390220        66  type body UT3.UT_SUITE.DO_EXECUTE\n00007FF93047D748        66  type body UT3.UT_RUN.DO_EXECUTE\n00007FF930474118        49  type body UT3.UT_SUITE_ITEM.DO_EXECUTE\n00007FF92E55A900       149  package body UT3.UT_RUNNER.RUN\n00007FF9254E8BF0         1  anonymous block\n","clientIdentifier":"","clientInfo":"log_info_table","extra":"","lineNo":336,"loggerLevel":8,"module":"utPLSQL","osUserName":"Walter","scn":7387381,"scope":"db122non:test_sbsdb_logger.log_info_table","sid":134,"text":"This is the alleged information no. 1/0.","timeStamp":"2019-02-02 12:32:41.205000","unitName":"SBS1_ADMIN.SBSDB_LOGGER_LIB.LOG_INFO","userName":"WWE"}
```

## 4 Log File Format

The logging entries are stored in the database table `SBSDB_LOG`. The database table `SBSDB_LOG` is created during installation in the `SBS1_ADMIN` schema in the default tablespace.

![DDL Table SBSDB_LOG](https://i.imgur.com/Aq0AdMR.jpg)

The content of the column `ckey` is based on the sequence `SBSDB_LOG_SEQ` ind SBSDB schema. The column `cvalue` contains the logging entry in JSON format. The column `chash` is currently not used.

The view `SBSDB_LOG_DETAILS` presents the name/value pairs of the `cvalue` column in a more relational view:

![DDL View SBSDB_LOG_DETAILS](https://i.imgur.com/uVqSlVD.jpg)