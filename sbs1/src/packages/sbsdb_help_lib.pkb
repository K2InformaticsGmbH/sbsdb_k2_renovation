CREATE OR REPLACE PACKAGE BODY sbsdb_help_lib
IS
    /* =========================================================================
       Public Implementation
       ---------------------------------------------------------------------- */

    SUBTYPE eol_t IS VARCHAR2 (10);

    c_col1_width                   CONSTANT PLS_INTEGER := 22;

    FUNCTION help_text (
        p_api_group_in                          IN sbsdb_type_lib.api_scope_t,
        p_api_method_in                         IN sbsdb_type_lib.api_scope_t)
        RETURN sbsdb_type_lib.api_message_t
    IS
        l_list                                  SYS_REFCURSOR;
        l_result                                sbsdb_type_lib.api_message_t;
    BEGIN
        IF p_api_group_in IS NULL
        THEN
            OPEN l_list FOR SELECT api_help_text
                            FROM   TABLE (sbsdb_api_scope_help ())
                            WHERE  api_scope = p_api_method_in;
        ELSIF p_api_method_in IS NULL
        THEN
            OPEN l_list FOR SELECT api_help_text
                            FROM   TABLE (sbsdb_api_scope_help ())
                            WHERE  api_scope = p_api_group_in;
        ELSE
            OPEN l_list FOR SELECT api_help_text
                            FROM   TABLE (sbsdb_api_scope_help ())
                            WHERE  api_scope = p_api_group_in || '.' || p_api_method_in;
        END IF;

        FETCH l_list INTO l_result;

        CLOSE l_list;

        RETURN l_result;
    END help_text;

    /* =========================================================================
       Create a link Lor Help drill-down (for Server Output or Table Function)
       ---------------------------------------------------------------------- */
    FUNCTION method_link (
        p_api_package_in                        IN sbsdb_type_lib.api_scope_t,
        p_api_method_in                         IN sbsdb_type_lib.api_scope_t)
        RETURN sbsdb_type_lib.api_message_t
    IS
        l_result                                sbsdb_type_lib.api_message_t;
    BEGIN
        -- exec sbsdb.sbsdb_help('package.method');
        l_result := l_result || 'exec ' || LOWER (sbsdb_db_con.sbsdb_schema);
        l_result := l_result || '.sbsdb_help(''';

        IF p_api_package_in IS NULL
        THEN
            l_result := l_result || LOWER (p_api_method_in) || ''');';
        ELSIF p_api_method_in IS NULL
        THEN
            l_result := l_result || LOWER (p_api_package_in) || ''');';
        ELSE
            l_result := l_result || LOWER (p_api_package_in) || '.' || LOWER (p_api_method_in) || ''');';
        END IF;

        RETURN l_result;
    END method_link;

    /* =========================================================================
       Provide a Help Search table function (similar to UNIX MAN pages)
       ---------------------------------------------------------------------- */
    PROCEDURE HELP (sqlt_str_filter IN sbsdb_type_lib.input_name_t:= NULL)
    AS
        l_counts_cur                            SYS_REFCURSOR;
        l_detail_cur                            SYS_REFCURSOR;
        l_overview_cur                          SYS_REFCURSOR;
        l_match                                 sbsdb_type_lib.sql_stmnt_t := UPPER (NVL (sqlt_str_filter, '%'));
        l_api_groups                            PLS_INTEGER;
        l_api_methods                           PLS_INTEGER;
        l_api_group                             sbsdb_type_lib.api_scope_t;
        l_api_method                            sbsdb_type_lib.api_scope_t;
        l_help_text                             sbsdb_type_lib.api_help_t;
    BEGIN
        sbsdb_logger_lib.log_info ('Start', sbsdb_logger_lib.scope ($$plsql_unit, 'HELP'), sbsdb_logger_lib.log_param ('sqlt_str_filter', sqlt_str_filter));

        IF INSTR (sqlt_str_filter, '%') = 0
        THEN
            l_match := '%' || l_match || '%';
        END IF;

        -- count number of search matches
        sbsdb_db_con.raise_non_valid_db_version;

        OPEN l_counts_cur FOR SELECT   COUNT (DISTINCT api_group)       AS api_groups,
                                       COUNT (DISTINCT method_name)     AS api_methods
                              FROM     (SELECT api_group,
                                               method_name
                                        FROM   TABLE (sbsdb_api_group_trans ())
                                        WHERE      api_group NOT IN ('HIDDEN')
                                               AND (   api_group LIKE l_match
                                                    OR api_scope LIKE l_match
                                                    OR method_name LIKE l_match
                                                    OR (package_name || '.' || method_name) LIKE l_match))
                              ORDER BY api_groups ASC;

        FETCH l_counts_cur
            INTO l_api_groups,
                 l_api_methods;

        CLOSE l_counts_cur;

        CASE
            WHEN     l_api_groups = 0
                 AND l_api_methods = 0
            THEN
                sbsdb_sql_lib.put_line ('not_found, Please use the wildcard character % to find more topics');
            WHEN     l_api_groups <= 1
                 AND l_api_methods <= 1
            THEN
                -- single match, lookup and output the help text
                OPEN l_detail_cur FOR SELECT   api_group,
                                               package_name || '.' || method_name                       AS api_method,
                                               sbsdb_help_lib.help_text (package_name, method_name)     AS help_text
                                      FROM     TABLE (sbsdb_api_group_trans ())
                                      WHERE        api_group NOT IN ('HIDDEN')
                                               AND (   api_group LIKE l_match
                                                    OR api_scope LIKE l_match
                                                    OR method_name LIKE l_match
                                                    OR (package_name || '.' || method_name) LIKE l_match)
                                      ORDER BY api_group ASC;

                FETCH l_detail_cur
                    INTO l_api_group,
                         l_api_method,
                         l_help_text;

                sbsdb_sql_lib.put_line ('--------------------------------------------------------------------------------');
                sbsdb_sql_lib.put_line (RPAD ('HELP API METHOD', c_col1_width) || 'HELP API GROUP = ' || l_api_group);
                sbsdb_sql_lib.put_line ('--------------------------------------------------------------------------------');
                sbsdb_sql_lib.put_line (LOWER (l_api_method));
                sbsdb_sql_lib.put_line (l_help_text);
                sbsdb_sql_lib.put_line ('--------------------------------------------------------------------------------');

                CLOSE l_detail_cur;
            ELSE
                -- multi match, list am overwiew with detail links
                OPEN l_overview_cur FOR SELECT   api_group,
                                                 sbsdb_help_lib.method_link (package_name, method_name)     AS api_method_link
                                        FROM     TABLE (sbsdb_api_group_trans ())
                                        WHERE        api_group NOT IN ('HIDDEN')
                                                 AND (   api_group LIKE l_match
                                                      OR api_scope LIKE l_match
                                                      OR method_name LIKE l_match
                                                      OR (package_name || '.' || method_name) LIKE l_match)
                                        ORDER BY api_method_link ASC,
                                                 api_group ASC;

                sbsdb_sql_lib.put_line ('--------------------------------------------------------------------------------');
                sbsdb_sql_lib.put_line (RPAD ('HELP API GROUP', c_col1_width) || 'HELP METHOD LINK');
                sbsdb_sql_lib.put_line ('--------------------------------------------------------------------------------');

                LOOP
                    FETCH l_overview_cur
                        INTO l_api_group,
                             l_help_text;

                    EXIT WHEN l_overview_cur%NOTFOUND;
                    sbsdb_sql_lib.put_line (RPAD (LOWER (l_api_group), c_col1_width) || l_help_text);
                END LOOP;

                sbsdb_sql_lib.put_line ('--------------------------------------------------------------------------------');

                CLOSE l_overview_cur;
        END CASE;

        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'help'));
    EXCEPTION
        WHEN OTHERS
        THEN
            sbsdb_error_lib.LOG (SQLCODE, SQLERRM, sbsdb_logger_lib.scope ($$plsql_unit, 'help'));
            RAISE;
    END HELP;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_help_lib;
/