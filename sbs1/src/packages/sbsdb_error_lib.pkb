CREATE OR REPLACE PACKAGE BODY sbsdb_error_lib
IS
    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Log an error based on a PL/SQL exception or an application error
       ---------------------------------------------------------------------- */

    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t DEFAULT NULL,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t DEFAULT NULL,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t DEFAULT NULL)
    IS
    BEGIN -- without parameters
        LOG (
            p_errcode_in,
            p_errmsg_in,
            p_scope_in,
            p_extra_in,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param,
            sbsdb_type_lib.gc_empty_rec_param);
    END LOG;

    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t,
        p_log_param_2_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_3_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_4_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_5_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_6_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_7_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_8_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_9_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_10_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_11_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_12_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_13_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_14_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_15_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_16_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_17_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_18_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_19_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_20_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_21_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_22_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_23_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_24_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_25_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_26_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_27_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_28_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_29_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
    BEGIN -- without extra (clob attachment)
        LOG (
            p_errcode_in,
            p_errmsg_in,
            p_scope_in,
            NULL,
            p_log_param_1_in,
            p_log_param_2_in,
            p_log_param_3_in,
            p_log_param_4_in,
            p_log_param_5_in,
            p_log_param_6_in,
            p_log_param_7_in,
            p_log_param_8_in,
            p_log_param_9_in,
            p_log_param_10_in,
            p_log_param_11_in,
            p_log_param_12_in,
            p_log_param_13_in,
            p_log_param_14_in,
            p_log_param_15_in,
            p_log_param_16_in,
            p_log_param_17_in,
            p_log_param_18_in,
            p_log_param_19_in,
            p_log_param_20_in,
            p_log_param_21_in,
            p_log_param_22_in,
            p_log_param_23_in,
            p_log_param_24_in,
            p_log_param_25_in,
            p_log_param_26_in,
            p_log_param_27_in,
            p_log_param_28_in,
            p_log_param_29_in,
            p_log_param_30_in);
    END LOG;

    PROCEDURE LOG (
        p_errcode_in                            IN PLS_INTEGER,
        p_errmsg_in                             IN sbsdb_type_lib.logger_message_t,
        p_scope_in                              IN sbsdb_type_lib.logger_scope_t,
        p_extra_in                              IN sbsdb_type_lib.logger_extra_t,
        p_log_param_1_in                        IN sbsdb_type_lib.logger_param_rec_t,
        p_log_param_2_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_3_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_4_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_5_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_6_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_7_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_8_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_9_in                        IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_10_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_11_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_12_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_13_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_14_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_15_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_16_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_17_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_18_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_19_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_20_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_21_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_22_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_23_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_24_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_25_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_26_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_27_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_28_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_29_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param,
        p_log_param_30_in                       IN sbsdb_type_lib.logger_param_rec_t := sbsdb_type_lib.gc_empty_rec_param)
    IS
        l_log_params                            sbsdb_type_lib.logger_param_tab_t := sbsdb_type_lib.gc_empty_tab_param;
        l_text                                  sbsdb_type_lib.logger_message_t;
    BEGIN
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_1_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_2_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_3_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_4_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_5_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_6_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_7_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_8_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_9_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_10_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_11_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_12_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_13_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_14_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_15_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_16_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_17_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_18_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_19_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_20_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_21_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_22_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_23_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_24_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_25_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_26_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_27_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_28_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_29_in);
        sbsdb_logger_lib.append_log_param (l_log_params, p_log_param_30_in);

        sbsdb_sql_lib.put_line (NVL (p_errmsg_in, '[ORA' || TO_CHAR (p_errcode_in) || ']'));
        
        IF     LENGTH (p_errmsg_in) > 1
           AND SUBSTR (p_errmsg_in, 1, 2) = '{"'
           AND SUBSTR (TRIM (p_errmsg_in), -1) = '}'
        THEN
            l_text := p_errmsg_in;
        ELSE
            l_text := p_errmsg_in || ' [ORA' || TO_CHAR (p_errcode_in) || '] [' || DBMS_UTILITY.format_error_backtrace () || ']';
        END IF;

        sbsdb_logger_lib.log_error (
            p_text_in                            => l_text,
            p_scope_in                           => p_scope_in,
            p_extra_in                           => p_extra_in,
            p_log_param_1_in                     => p_log_param_1_in,
            p_log_param_2_in                     => p_log_param_2_in,
            p_log_param_3_in                     => p_log_param_3_in,
            p_log_param_4_in                     => p_log_param_4_in,
            p_log_param_5_in                     => p_log_param_5_in,
            p_log_param_6_in                     => p_log_param_6_in,
            p_log_param_7_in                     => p_log_param_7_in,
            p_log_param_8_in                     => p_log_param_8_in,
            p_log_param_9_in                     => p_log_param_9_in,
            p_log_param_10_in                    => p_log_param_10_in,
            p_log_param_11_in                    => p_log_param_11_in,
            p_log_param_12_in                    => p_log_param_12_in,
            p_log_param_13_in                    => p_log_param_13_in,
            p_log_param_14_in                    => p_log_param_14_in,
            p_log_param_15_in                    => p_log_param_15_in,
            p_log_param_16_in                    => p_log_param_16_in,
            p_log_param_17_in                    => p_log_param_17_in,
            p_log_param_18_in                    => p_log_param_18_in,
            p_log_param_19_in                    => p_log_param_19_in,
            p_log_param_20_in                    => p_log_param_20_in,
            p_log_param_21_in                    => p_log_param_21_in,
            p_log_param_22_in                    => p_log_param_22_in,
            p_log_param_23_in                    => p_log_param_23_in,
            p_log_param_24_in                    => p_log_param_24_in,
            p_log_param_25_in                    => p_log_param_25_in,
            p_log_param_26_in                    => p_log_param_26_in,
            p_log_param_27_in                    => p_log_param_27_in,
            p_log_param_28_in                    => p_log_param_28_in,
            p_log_param_29_in                    => p_log_param_29_in,
            p_log_param_30_in                    => p_log_param_30_in);
    END LOG;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END sbsdb_error_lib;
/