CREATE OR REPLACE PACKAGE BODY test_sbsdb_logger
IS
    gc_is_del_all                  CONSTANT BOOLEAN := TRUE;
    gc_json_invalid                CONSTANT sbsdb_type_lib.logger_cvalue_t := 'This is not a JSON expression!';
    gc_json_valid                  CONSTANT sbsdb_type_lib.logger_cvalue_t := '{"number":4711,"string":"my text","boolean":true,"array":[0,1,2],"null":null,"object":{"a":"aac","b":11}}';

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.append_log_param].
       ---------------------------------------------------------------------- */

    PROCEDURE append_log_param
    IS
        l_log_params                            sbsdb_type_lib.logger_param_tab_t;
        l_param                                 sbsdb_type_lib.logger_param_rec_t;
    BEGIN
        l_log_params := sbsdb_type_lib.gc_empty_tab_param;
        ut.expect (l_log_params.COUNT ()).to_equal (0);

        l_param.name := 'Name1';
        l_param.val := 'Value1';
        sbsdb_logger_lib.append_log_param (l_log_params, l_param);
        ut.expect (l_log_params.COUNT ()).to_equal (1);

        l_param.name := 'Name2';
        l_param.val := 'Value2';
        sbsdb_logger_lib.append_log_param (l_log_params, l_param);
        ut.expect (l_log_params.COUNT ()).to_equal (2);

        l_param.name := 'Name3';
        l_param.val := 'Value3';
        sbsdb_logger_lib.append_log_param (l_log_params, l_param);
        ut.expect (l_log_params.COUNT ()).to_equal (3);

        l_param.name := 'Name4';
        l_param.val := 'Value4';
        sbsdb_logger_lib.append_log_param (l_log_params, l_param);
        ut.expect (l_log_params.COUNT ()).to_equal (4);

        l_param.name := 'Name5';
        l_param.val := 'Value5';
        sbsdb_logger_lib.append_log_param (l_log_params, l_param);
        ut.expect (l_log_params.COUNT ()).to_equal (5);

        l_param.name := 'Name1';
        l_param.val := 'Value1';
        sbsdb_logger_lib.append_log_param (l_log_params, l_param);
        ut.expect (l_log_params.COUNT ()).to_equal (6);
    END append_log_param;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.get_valid_json].
       ---------------------------------------------------------------------- */

    PROCEDURE get_valid_json_fnc_false
    IS
    BEGIN
        ut.expect (sbsdb_logger_lib.get_valid_json (gc_json_invalid)).to_equal ('{"invalid_json":"' || gc_json_invalid || '"}');
    END get_valid_json_fnc_false;

    PROCEDURE get_valid_json_fnc_true
    IS
    BEGIN
        ut.expect (sbsdb_logger_lib.get_valid_json (gc_json_valid)).to_equal (gc_json_valid);
    END get_valid_json_fnc_true;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.get_valid_json].
       ---------------------------------------------------------------------- */

    PROCEDURE get_valid_json_prc_false
    IS
        l_result                                sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_result := gc_json_invalid;
        sbsdb_logger_lib.get_valid_json (l_result);

        ut.expect (l_result).to_equal ('{"invalid_json":"' || gc_json_invalid || '"}');
    END get_valid_json_prc_false;

    PROCEDURE get_valid_json_prc_true
    IS
        l_result                                sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_result := gc_json_valid;

        sbsdb_logger_lib.get_valid_json (l_result);

        ut.expect (l_result).to_equal (gc_json_valid);
    END get_valid_json_prc_true;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.is_valid_json].
       ---------------------------------------------------------------------- */

    PROCEDURE is_valid_json_false
    IS
    BEGIN
        ut.expect (sbsdb_logger_lib.is_valid_json (gc_json_invalid)).to_equal (sbsdb_type_lib.FALSE);
    END is_valid_json_false;

    PROCEDURE is_valid_json_true
    IS
    BEGIN
        ut.expect (sbsdb_logger_lib.is_valid_json (gc_json_valid)).to_equal (sbsdb_type_lib.TRUE);
    END is_valid_json_true;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_array].
       ---------------------------------------------------------------------- */

    PROCEDURE json_array
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_array';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_array (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":[]}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);

        l_json_element := '1,2,3';
        l_json := sbsdb_logger_lib.json_array (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":[1,2,3]}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);

        l_json_element := '[1,2,3]';
        l_json := sbsdb_logger_lib.json_array (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":[1,2,3]}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_array;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_array].
       ---------------------------------------------------------------------- */

    PROCEDURE json_array_add
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_array';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_array_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":[]';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '1,2,3';
        l_json := sbsdb_logger_lib.json_array_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":[1,2,3]';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '[1,2,3]';
        l_json := sbsdb_logger_lib.json_array_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":[1,2,3]';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_array_add;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_array].
       ---------------------------------------------------------------------- */

    PROCEDURE json_array_first
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_array';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_array_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":[]';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '1,2,3';
        l_json := sbsdb_logger_lib.json_array_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":[1,2,3]';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '[1,2,3]';
        l_json := sbsdb_logger_lib.json_array_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":[1,2,3]';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_array_first;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_array].
       ---------------------------------------------------------------------- */

    PROCEDURE json_array_last
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_array';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_array_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":[]}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '1,2,3';
        l_json := sbsdb_logger_lib.json_array_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":[1,2,3]}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '[1,2,3]';
        l_json := sbsdb_logger_lib.json_array_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":[1,2,3]}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_array_last;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_object].
       ---------------------------------------------------------------------- */

    PROCEDURE json_object
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_object';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_object (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":{}}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);

        l_json_element := '"a_string":"a_element","b_string":4711';
        l_json := sbsdb_logger_lib.json_object (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);

        l_json_element := '{"a_string":"a_element","b_string":4711}';
        l_json := sbsdb_logger_lib.json_object (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_object;

    /* =========================================================================
       Test: {Test method sbsdb_logger_lib.json_object}.
       ---------------------------------------------------------------------- */

    PROCEDURE json_object_add
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_object';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_object_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":{}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '"a_string":"a_element","b_string":4711';
        l_json := sbsdb_logger_lib.json_object_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '{"a_string":"a_element","b_string":4711}';
        l_json := sbsdb_logger_lib.json_object_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_object_add;

    /* =========================================================================
       Test: {Test method sbsdb_logger_lib.json_object}.
       ---------------------------------------------------------------------- */

    PROCEDURE json_object_first
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_object';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_object_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":{}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '"a_string":"a_element","b_string":4711';
        l_json := sbsdb_logger_lib.json_object_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '{"a_string":"a_element","b_string":4711}';
        l_json := sbsdb_logger_lib.json_object_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_object_first;

    /* =========================================================================
       Test: {Test method sbsdb_logger_lib.json_object}.
       ---------------------------------------------------------------------- */

    PROCEDURE json_object_last
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_object';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := NULL;
        l_json := sbsdb_logger_lib.json_object_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":{}}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '"a_string":"a_element","b_string":4711';
        l_json := sbsdb_logger_lib.json_object_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := '{"a_string":"a_element","b_string":4711}';
        l_json := sbsdb_logger_lib.json_object_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":{"a_string":"a_element","b_string":4711}}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_object_last;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_other].
       ---------------------------------------------------------------------- */

    PROCEDURE json_other_boolean
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_boolean';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          BOOLEAN;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := FALSE;
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":false}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);

        l_json_element := TRUE;
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":true}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_other_boolean;

    PROCEDURE json_other_date
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          DATE;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSDATE;
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_other_date;

    PROCEDURE json_other_null
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_null';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json := sbsdb_logger_lib.json_other (lc_json_string);
        l_json_expected := '{"' || lc_json_string || '":null}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_other_null;

    PROCEDURE json_other_number
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_number';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          NUMBER;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 4711;
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":4711}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);

        l_json_element := 4711.1234;
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":4711.1234}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_other_number;

    PROCEDURE json_other_string
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 'my_element';
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":"my_element"}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_other_string;

    PROCEDURE json_other_timestamp
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_timestamp';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          TIMESTAMP;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSTIMESTAMP;
        l_json := sbsdb_logger_lib.json_other (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"}';

        ut.expect (l_json).to_equal (l_json_expected);
        ut.expect (sbsdb_logger_lib.is_valid_json (l_json)).to_equal (sbsdb_type_lib.TRUE);
    END json_other_timestamp;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_other_add].
       ---------------------------------------------------------------------- */

    PROCEDURE json_other_add_boolean
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_boolean';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          BOOLEAN;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := FALSE;
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":false';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := TRUE;
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":true';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_add_boolean;

    PROCEDURE json_other_add_date
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          DATE;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSDATE;
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_add_date;

    PROCEDURE json_other_add_null
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_null';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string);
        l_json_expected := ',"' || lc_json_string || '":null';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_add_null;

    PROCEDURE json_other_add_number
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_number';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          NUMBER;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 4711;
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":4711';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := 4711.1234;
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":4711.1234';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_add_number;

    PROCEDURE json_other_add_string
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 'my_element';
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":"my_element"';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_add_string;

    PROCEDURE json_other_add_timestamp
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_timestamp';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          TIMESTAMP;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSTIMESTAMP;
        l_json := sbsdb_logger_lib.json_other_add (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_add_timestamp;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_other_first].
       ---------------------------------------------------------------------- */

    PROCEDURE json_other_first_boolean
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_boolean';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          BOOLEAN;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := FALSE;
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":false';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := TRUE;
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":true';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_first_boolean;

    PROCEDURE json_other_first_date
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          DATE;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSDATE;
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_first_date;

    PROCEDURE json_other_first_null
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_null';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string);
        l_json_expected := '{"' || lc_json_string || '":null';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_first_null;

    PROCEDURE json_other_first_number
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_number';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          NUMBER;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 4711;
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":4711';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := 4711.1234;
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":4711.1234';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_first_number;

    PROCEDURE json_other_first_string
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 'my_element';
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":"my_element"';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_first_string;

    PROCEDURE json_other_first_timestamp
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_timestamp';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          TIMESTAMP;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSTIMESTAMP;
        l_json := sbsdb_logger_lib.json_other_first (lc_json_string, l_json_element);
        l_json_expected := '{"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_first_timestamp;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.json_other_last].
       ---------------------------------------------------------------------- */

    PROCEDURE json_other_last_boolean
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_boolean';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          BOOLEAN;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := FALSE;
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":false}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := TRUE;
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":true}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_last_boolean;

    PROCEDURE json_other_last_date
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          DATE;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSDATE;
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_last_date;

    PROCEDURE json_other_last_null
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_null';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string);
        l_json_expected := ',"' || lc_json_string || '":null}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_last_null;

    PROCEDURE json_other_last_number
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_number';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          NUMBER;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 4711;
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":4711}';

        ut.expect (l_json).to_equal (l_json_expected);

        l_json_element := 4711.1234;
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":4711.1234}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_last_number;

    PROCEDURE json_other_last_string
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_date';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          sbsdb_type_lib.logger_json_element_t;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := 'my_element';
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":"my_element"}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_last_string;

    PROCEDURE json_other_last_timestamp
    IS
        lc_json_string                 CONSTANT sbsdb_type_lib.logger_json_string_t := 'string_other_timestamp';

        l_json                                  sbsdb_type_lib.logger_cvalue_t;
        l_json_element                          TIMESTAMP;
        l_json_expected                         sbsdb_type_lib.logger_cvalue_t;
    BEGIN
        l_json_element := SYSTIMESTAMP;
        l_json := sbsdb_logger_lib.json_other_last (lc_json_string, l_json_element);
        l_json_expected := ',"' || lc_json_string || '":"' || TO_CHAR (l_json_element AT TIME ZONE SESSIONTIMEZONE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') || '"}';

        ut.expect (l_json).to_equal (l_json_expected);
    END json_other_last_timestamp;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.log_debug].
       ---------------------------------------------------------------------- */

    PROCEDURE log_debug_table
    IS
        lc_extra                       CONSTANT sbsdb_type_lib.logger_extra_t := TO_CLOB ('This is a test extra.');
        lc_text                        CONSTANT sbsdb_type_lib.logger_message_t := 'This is the alleged debug entry no. :1.';
        lc_scope                       CONSTANT sbsdb_type_lib.logger_scope_t := LOWER (sbsdb_logger_lib.scope ($$plsql_unit, 'log_debug_table'));
        lc_scope_without               CONSTANT sbsdb_type_lib.logger_scope_t := LOWER (sbsdb_logger_lib.scope ('sbsdb_logger_lib', 'log_debug'));

        l_ckey                                  sbsdb_type_lib.logger_ckey_t;

        l_log_param_1                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_2                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_3                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_4                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_5                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_6                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_7                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_8                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_9                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_10                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_11                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_12                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_13                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_14                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_15                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_16                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_17                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_18                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_19                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_20                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_21                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_22                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_23                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_24                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_25                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_26                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_27                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_28                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_29                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_30                          sbsdb_type_lib.logger_param_rec_t;

        l_sql_stmnt                             sbsdb_type_lib.sql_stmnt_t;
        l_text                                  sbsdb_type_lib.logger_message_t;
    BEGIN
        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            RETURN;
        END IF;

        sbsdb_io_lib.set_io_type_log_file;

        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            sbsdb_io_lib.set_io_type_log_table;
        END IF;

        l_sql_stmnt := 'DELETE FROM sbsdb_log
                              WHERE cvalue LIKE ''%"scope":"' || lc_scope || '"%''
                                 OR cvalue LIKE ''%"scope":"' || lc_scope_without || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_');

        COMMIT;

        l_log_param_1.name := 'Name1';
        l_log_param_1.val := 'Value1';
        l_log_param_2.name := 'Name2';
        l_log_param_2.val := 'Value2';
        l_log_param_3.name := 'Name3';
        l_log_param_3.val := 'Value3';
        l_log_param_4.name := 'Name4';
        l_log_param_4.val := 'Value4';
        l_log_param_5.name := 'Name5';
        l_log_param_5.val := 'Value5';
        l_log_param_6.name := 'Name6';
        l_log_param_6.val := 'Value6';
        l_log_param_7.name := 'Name7';
        l_log_param_7.val := 'Value7';
        l_log_param_8.name := 'Name8';
        l_log_param_8.val := 'Value8';
        l_log_param_9.name := 'Name9';
        l_log_param_9.val := 'Value9';
        l_log_param_10.name := 'Name10';
        l_log_param_10.val := 'Value10';
        l_log_param_11.name := 'Name11';
        l_log_param_11.val := 'Value11';
        l_log_param_12.name := 'Name12';
        l_log_param_12.val := 'Value12';
        l_log_param_13.name := 'Name13';
        l_log_param_13.val := 'Value13';
        l_log_param_14.name := 'Name14';
        l_log_param_14.val := 'Value14';
        l_log_param_15.name := 'Name15';
        l_log_param_15.val := 'Value15';
        l_log_param_16.name := 'Name16';
        l_log_param_16.val := 'Value16';
        l_log_param_17.name := 'Name17';
        l_log_param_17.val := 'Value17';
        l_log_param_18.name := 'Name18';
        l_log_param_18.val := 'Value18';
        l_log_param_19.name := 'Name19';
        l_log_param_19.val := 'Value19';
        l_log_param_20.name := 'Name20';
        l_log_param_20.val := 'Value20';
        l_log_param_21.name := 'Name21';
        l_log_param_21.val := 'Value21';
        l_log_param_22.name := 'Name22';
        l_log_param_22.val := 'Value22';
        l_log_param_23.name := 'Name23';
        l_log_param_23.val := 'Value23';
        l_log_param_24.name := 'Name24';
        l_log_param_24.val := 'Value24';
        l_log_param_25.name := 'Name25';
        l_log_param_25.val := 'Value25';
        l_log_param_26.name := 'Name26';
        l_log_param_26.val := 'Value26';
        l_log_param_27.name := 'Name27';
        l_log_param_27.val := 'Value27';
        l_log_param_28.name := 'Name28';
        l_log_param_28.val := 'Value28';
        l_log_param_29.name := 'Name29';
        l_log_param_29.val := 'Value29';
        l_log_param_30.name := 'Name30';
        l_log_param_30.val := 'Value30';

        -- 1. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '1/0');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => lc_scope);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 2. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '2/0');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => NULL, p_extra_in => lc_extra);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope_without || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 3. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '3/0');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => lc_extra);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 4. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '4/1');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => NULL, p_extra_in => NULL, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope_without || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 5. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '5/1');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => NULL, p_extra_in => lc_extra, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope_without || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 6. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '6/1');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => NULL, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 7. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '7/1');

        sbsdb_logger_lib.log_debug (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => lc_extra, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 8. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '8/5');

        sbsdb_logger_lib.log_debug (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 9. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '9/5');

        sbsdb_logger_lib.log_debug (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_extra_in                           => lc_extra,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;
    END log_debug_table;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.log_error].
       ---------------------------------------------------------------------- */

    PROCEDURE log_error_table
    IS
        lc_text                        CONSTANT sbsdb_type_lib.logger_message_t := 'This is the alleged error no. :1.';
        lc_scope                       CONSTANT sbsdb_type_lib.logger_scope_t := LOWER (sbsdb_logger_lib.scope ($$plsql_unit, 'log_error_table'));
        lc_extra                       CONSTANT sbsdb_type_lib.logger_extra_t := TO_CLOB ('This is a test extra.');

        l_ckey                                  sbsdb_type_lib.logger_ckey_t;

        l_log_param_1                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_2                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_3                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_4                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_5                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_6                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_7                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_8                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_9                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_10                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_11                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_12                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_13                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_14                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_15                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_16                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_17                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_18                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_19                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_20                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_21                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_22                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_23                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_24                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_25                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_26                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_27                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_28                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_29                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_30                          sbsdb_type_lib.logger_param_rec_t;

        l_sql_stmnt                             sbsdb_type_lib.sql_stmnt_t;
        l_text                                  sbsdb_type_lib.logger_message_t;
    BEGIN
        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            RETURN;
        END IF;

        sbsdb_io_lib.set_io_type_log_file;

        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            sbsdb_io_lib.set_io_type_log_table;
        END IF;

        l_sql_stmnt := 'DELETE FROM sbsdb_log
                              WHERE cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_');

        COMMIT;

        l_log_param_1.name := 'Name1';
        l_log_param_1.val := 'Value1';
        l_log_param_2.name := 'Name2';
        l_log_param_2.val := 'Value2';
        l_log_param_3.name := 'Name3';
        l_log_param_3.val := 'Value3';
        l_log_param_4.name := 'Name4';
        l_log_param_4.val := 'Value4';
        l_log_param_5.name := 'Name5';
        l_log_param_5.val := 'Value5';
        l_log_param_6.name := 'Name6';
        l_log_param_6.val := 'Value6';
        l_log_param_7.name := 'Name7';
        l_log_param_7.val := 'Value7';
        l_log_param_8.name := 'Name8';
        l_log_param_8.val := 'Value8';
        l_log_param_9.name := 'Name9';
        l_log_param_9.val := 'Value9';
        l_log_param_10.name := 'Name10';
        l_log_param_10.val := 'Value10';
        l_log_param_11.name := 'Name11';
        l_log_param_11.val := 'Value11';
        l_log_param_12.name := 'Name12';
        l_log_param_12.val := 'Value12';
        l_log_param_13.name := 'Name13';
        l_log_param_13.val := 'Value13';
        l_log_param_14.name := 'Name14';
        l_log_param_14.val := 'Value14';
        l_log_param_15.name := 'Name15';
        l_log_param_15.val := 'Value15';
        l_log_param_16.name := 'Name16';
        l_log_param_16.val := 'Value16';
        l_log_param_17.name := 'Name17';
        l_log_param_17.val := 'Value17';
        l_log_param_18.name := 'Name18';
        l_log_param_18.val := 'Value18';
        l_log_param_19.name := 'Name19';
        l_log_param_19.val := 'Value19';
        l_log_param_20.name := 'Name20';
        l_log_param_20.val := 'Value20';
        l_log_param_21.name := 'Name21';
        l_log_param_21.val := 'Value21';
        l_log_param_22.name := 'Name22';
        l_log_param_22.val := 'Value22';
        l_log_param_23.name := 'Name23';
        l_log_param_23.val := 'Value23';
        l_log_param_24.name := 'Name24';
        l_log_param_24.val := 'Value24';
        l_log_param_25.name := 'Name25';
        l_log_param_25.val := 'Value25';
        l_log_param_26.name := 'Name26';
        l_log_param_26.val := 'Value26';
        l_log_param_27.name := 'Name27';
        l_log_param_27.val := 'Value27';
        l_log_param_28.name := 'Name28';
        l_log_param_28.val := 'Value28';
        l_log_param_29.name := 'Name29';
        l_log_param_29.val := 'Value29';
        l_log_param_30.name := 'Name30';
        l_log_param_30.val := 'Value30';

        -- 1. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '1/0');

        sbsdb_logger_lib.log_error (p_text_in => l_text, p_scope_in => lc_scope);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                          FROM sbsdb_log
                         WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 2. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '2/0');

        sbsdb_logger_lib.log_error (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => lc_extra);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 3. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '3/1');

        sbsdb_logger_lib.log_error (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => NULL, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 4. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '4/1');

        sbsdb_logger_lib.log_error (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => lc_extra, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 5. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '5/5');

        sbsdb_logger_lib.log_error (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 6. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '6/5');

        sbsdb_logger_lib.log_error (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_extra_in                           => lc_extra,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;
    END log_error_table;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.log_info].
       ---------------------------------------------------------------------- */

    PROCEDURE log_info_table
    IS
        lc_text                        CONSTANT sbsdb_type_lib.logger_message_t := 'This is the alleged information no. :1.';
        lc_scope                       CONSTANT sbsdb_type_lib.logger_scope_t := LOWER (sbsdb_logger_lib.scope ($$plsql_unit, 'log_info_table'));

        l_ckey                                  sbsdb_type_lib.logger_ckey_t;

        l_log_param_1                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_2                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_3                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_4                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_5                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_6                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_7                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_8                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_9                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_10                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_11                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_12                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_13                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_14                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_15                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_16                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_17                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_18                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_19                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_20                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_21                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_22                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_23                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_24                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_25                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_26                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_27                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_28                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_29                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_30                          sbsdb_type_lib.logger_param_rec_t;

        l_sql_stmnt                             sbsdb_type_lib.sql_stmnt_t;
        l_text                                  sbsdb_type_lib.logger_message_t;
    BEGIN
        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            RETURN;
        END IF;

        sbsdb_io_lib.set_io_type_log_file;

        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            sbsdb_io_lib.set_io_type_log_table;
        END IF;

        l_sql_stmnt := 'DELETE FROM sbsdb_log
                              WHERE cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_');

        COMMIT;

        l_log_param_1.name := 'Name1';
        l_log_param_1.val := 'Value1';
        l_log_param_2.name := 'Name2';
        l_log_param_2.val := 'Value2';
        l_log_param_3.name := 'Name3';
        l_log_param_3.val := 'Value3';
        l_log_param_4.name := 'Name4';
        l_log_param_4.val := 'Value4';
        l_log_param_5.name := 'Name5';
        l_log_param_5.val := 'Value5';
        l_log_param_6.name := 'Name6';
        l_log_param_6.val := 'Value6';
        l_log_param_7.name := 'Name7';
        l_log_param_7.val := 'Value7';
        l_log_param_8.name := 'Name8';
        l_log_param_8.val := 'Value8';
        l_log_param_9.name := 'Name9';
        l_log_param_9.val := 'Value9';
        l_log_param_10.name := 'Name10';
        l_log_param_10.val := 'Value10';
        l_log_param_11.name := 'Name11';
        l_log_param_11.val := 'Value11';
        l_log_param_12.name := 'Name12';
        l_log_param_12.val := 'Value12';
        l_log_param_13.name := 'Name13';
        l_log_param_13.val := 'Value13';
        l_log_param_14.name := 'Name14';
        l_log_param_14.val := 'Value14';
        l_log_param_15.name := 'Name15';
        l_log_param_15.val := 'Value15';
        l_log_param_16.name := 'Name16';
        l_log_param_16.val := 'Value16';
        l_log_param_17.name := 'Name17';
        l_log_param_17.val := 'Value17';
        l_log_param_18.name := 'Name18';
        l_log_param_18.val := 'Value18';
        l_log_param_19.name := 'Name19';
        l_log_param_19.val := 'Value19';
        l_log_param_20.name := 'Name20';
        l_log_param_20.val := 'Value20';
        l_log_param_21.name := 'Name21';
        l_log_param_21.val := 'Value21';
        l_log_param_22.name := 'Name22';
        l_log_param_22.val := 'Value22';
        l_log_param_23.name := 'Name23';
        l_log_param_23.val := 'Value23';
        l_log_param_24.name := 'Name24';
        l_log_param_24.val := 'Value24';
        l_log_param_25.name := 'Name25';
        l_log_param_25.val := 'Value25';
        l_log_param_26.name := 'Name26';
        l_log_param_26.val := 'Value26';
        l_log_param_27.name := 'Name27';
        l_log_param_27.val := 'Value27';
        l_log_param_28.name := 'Name28';
        l_log_param_28.val := 'Value28';
        l_log_param_29.name := 'Name29';
        l_log_param_29.val := 'Value29';
        l_log_param_30.name := 'Name30';
        l_log_param_30.val := 'Value30';

        -- 1. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '1/0');

        sbsdb_logger_lib.log_info (p_text_in => l_text, p_scope_in => lc_scope);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                          FROM sbsdb_log
                         WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 2. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '2/5');

        sbsdb_logger_lib.log_info (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                          FROM sbsdb_log
                         WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;
    END log_info_table;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.log_param].
       ---------------------------------------------------------------------- */

    PROCEDURE log_param_boolean
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 BOOLEAN;
    BEGIN
        l_name := 'boolean';
        l_value := TRUE;
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('boolean=TRUE');

        l_name := 'Boolean';
        l_value := FALSE;
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('Boolean=FALSE');
    END log_param_boolean;

    PROCEDURE log_param_date
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 DATE;
    BEGIN
        l_name := 'Date';
        l_value := TO_DATE ('210651', 'DDMMYY');
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('Date=21-JUN-2051 00:00:00');
    END log_param_date;

    PROCEDURE log_param_number
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 NUMBER (38);
        l_value_decimals                        NUMBER (36, 2);
    BEGIN
        l_name := 'Number';
        l_value := 4711;
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('Number=4711');

        l_value_decimals := 12.34;
        l_result := sbsdb_logger_lib.log_param (l_name, l_value_decimals);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('Number=12.34');
    END log_param_number;

    PROCEDURE log_param_sys_refcursor
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 SYS_REFCURSOR;
    BEGIN
        l_name := 'SysRefcursoe';

        OPEN l_value FOR SELECT 1 FROM DUAL;

        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('SysRefcursoe=**SYS_REFCURSOR**');
    END log_param_sys_refcursor;

    PROCEDURE log_param_timestamp
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 TIMESTAMP;
    BEGIN
        l_name := 'Timestamp';
        l_value := TIMESTAMP '1951-06-21 15:00:00 -7:00';
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('Timestamp=21-JUN-1951 15:00:00:000000000');
    END log_param_timestamp;

    PROCEDURE log_param_timestamp_w_local_tz
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 TIMESTAMP WITH LOCAL TIME ZONE;
    BEGIN
        l_name := 'TimestampLocalTZ';
        l_value := TIMESTAMP '1951-06-21 15:00:00 -7:00';
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_match ('TimestampLocalTZ=21-JUN-1951 23:00:00:000000000 *');
    END log_param_timestamp_w_local_tz;

    PROCEDURE log_param_timestamp_w_tz
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 TIMESTAMP WITH TIME ZONE;
    BEGIN
        l_name := 'TimestampTZ';
        l_value := TIMESTAMP '1951-06-21 15:00:00 -7:00';
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('TimestampTZ=21-JUN-1951 15:00:00:000000000 -07:00');
    END log_param_timestamp_w_tz;

    PROCEDURE log_param_varchar2
    IS
        l_name                                  sbsdb_type_lib.logger_param_name_t;
        l_result                                sbsdb_type_lib.logger_param_rec_t;
        l_value                                 sbsdb_type_lib.logger_param_val_t;
    BEGIN
        l_name := 'Varchar2';
        l_value := 'TesT';
        l_result := sbsdb_logger_lib.log_param (l_name, l_value);
        ut.expect (l_result.name || '=' || l_result.val).to_equal ('Varchar2=TesT');
    END log_param_varchar2;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.log_permanent].
       ---------------------------------------------------------------------- */

    PROCEDURE log_permanent_table
    IS
        lc_extra                       CONSTANT sbsdb_type_lib.logger_extra_t := TO_CLOB ('This is a test extra.');
        lc_text                        CONSTANT sbsdb_type_lib.logger_message_t := 'This is the alleged permanent entry no. :1.';
        lc_scope                       CONSTANT sbsdb_type_lib.logger_scope_t := LOWER (sbsdb_logger_lib.scope ($$plsql_unit, 'log_permanent_table'));
        lc_scope_without               CONSTANT sbsdb_type_lib.logger_scope_t := LOWER (sbsdb_logger_lib.scope ('sbsdb_logger_lib', 'log_permanent'));

        l_ckey                                  sbsdb_type_lib.logger_ckey_t;

        l_log_param_1                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_2                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_3                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_4                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_5                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_6                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_7                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_8                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_9                           sbsdb_type_lib.logger_param_rec_t;
        l_log_param_10                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_11                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_12                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_13                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_14                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_15                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_16                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_17                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_18                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_19                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_20                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_21                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_22                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_23                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_24                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_25                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_26                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_27                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_28                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_29                          sbsdb_type_lib.logger_param_rec_t;
        l_log_param_30                          sbsdb_type_lib.logger_param_rec_t;

        l_sql_stmnt                             sbsdb_type_lib.sql_stmnt_t;
        l_text                                  sbsdb_type_lib.logger_message_t;
    BEGIN
        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            RETURN;
        END IF;

        sbsdb_io_lib.set_io_type_log_file;

        IF sbsdb_io_lib.get_io_type_log <> sbsdb_io_lib.get_io_type_log_table
        THEN
            sbsdb_io_lib.set_io_type_log_table;
        END IF;

        l_sql_stmnt := 'DELETE FROM sbsdb_log
                              WHERE cvalue LIKE ''%"scope":"' || lc_scope || '"%''
                                 OR cvalue LIKE ''%"scope":"' || lc_scope_without || '"%''';

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_');

        COMMIT;

        l_log_param_1.name := 'Name1';
        l_log_param_1.val := 'Value1';
        l_log_param_2.name := 'Name2';
        l_log_param_2.val := 'Value2';
        l_log_param_3.name := 'Name3';
        l_log_param_3.val := 'Value3';
        l_log_param_4.name := 'Name4';
        l_log_param_4.val := 'Value4';
        l_log_param_5.name := 'Name5';
        l_log_param_5.val := 'Value5';
        l_log_param_6.name := 'Name6';
        l_log_param_6.val := 'Value6';
        l_log_param_7.name := 'Name7';
        l_log_param_7.val := 'Value7';
        l_log_param_8.name := 'Name8';
        l_log_param_8.val := 'Value8';
        l_log_param_9.name := 'Name9';
        l_log_param_9.val := 'Value9';
        l_log_param_10.name := 'Name10';
        l_log_param_10.val := 'Value10';
        l_log_param_11.name := 'Name11';
        l_log_param_11.val := 'Value11';
        l_log_param_12.name := 'Name12';
        l_log_param_12.val := 'Value12';
        l_log_param_13.name := 'Name13';
        l_log_param_13.val := 'Value13';
        l_log_param_14.name := 'Name14';
        l_log_param_14.val := 'Value14';
        l_log_param_15.name := 'Name15';
        l_log_param_15.val := 'Value15';
        l_log_param_16.name := 'Name16';
        l_log_param_16.val := 'Value16';
        l_log_param_17.name := 'Name17';
        l_log_param_17.val := 'Value17';
        l_log_param_18.name := 'Name18';
        l_log_param_18.val := 'Value18';
        l_log_param_19.name := 'Name19';
        l_log_param_19.val := 'Value19';
        l_log_param_20.name := 'Name20';
        l_log_param_20.val := 'Value20';
        l_log_param_21.name := 'Name21';
        l_log_param_21.val := 'Value21';
        l_log_param_22.name := 'Name22';
        l_log_param_22.val := 'Value22';
        l_log_param_23.name := 'Name23';
        l_log_param_23.val := 'Value23';
        l_log_param_24.name := 'Name24';
        l_log_param_24.val := 'Value24';
        l_log_param_25.name := 'Name25';
        l_log_param_25.val := 'Value25';
        l_log_param_26.name := 'Name26';
        l_log_param_26.val := 'Value26';
        l_log_param_27.name := 'Name27';
        l_log_param_27.val := 'Value27';
        l_log_param_28.name := 'Name28';
        l_log_param_28.val := 'Value28';
        l_log_param_29.name := 'Name29';
        l_log_param_29.val := 'Value29';
        l_log_param_30.name := 'Name30';
        l_log_param_30.val := 'Value30';

        -- 1. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '1/0');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                          FROM sbsdb_log
                         WHERE cvalue LIKE ''%"text":"' || l_text || '"%'' AND cvalue LIKE ''%"scope":"' || lc_scope_without || '"%''';

        sbsdb_logger_lib.log_permanent (p_text_in => l_sql_stmnt, p_scope_in => lc_scope);

        EXECUTE IMMEDIATE REPLACE (l_sql_stmnt, ':', '_')
            INTO                                     l_ckey;

        -- 2. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '2/0');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => lc_scope);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 3. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '3/0');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => NULL, p_extra_in => lc_extra);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope_without || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 4. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '4/0');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => lc_extra);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 5. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '5/1');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => NULL, p_extra_in => NULL, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope_without || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 6. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '6/1');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => NULL, p_extra_in => lc_extra, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope_without || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 7. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '7/1');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => NULL, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 8. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '8/1');

        sbsdb_logger_lib.log_permanent (p_text_in => l_text, p_scope_in => lc_scope, p_extra_in => lc_extra, p_log_param_1_in => l_log_param_1);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 9. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '9/5');

        sbsdb_logger_lib.log_permanent (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;

        -- 10. Test -------------------------------------------------------------

        l_text := REPLACE (lc_text, ':1', '10/5');

        sbsdb_logger_lib.log_permanent (
            p_text_in                            => l_text,
            p_scope_in                           => lc_scope,
            p_extra_in                           => lc_extra,
            p_log_param_1_in                     => l_log_param_1,
            p_log_param_2_in                     => l_log_param_2,
            p_log_param_3_in                     => l_log_param_3,
            p_log_param_4_in                     => l_log_param_4,
            p_log_param_5_in                     => l_log_param_5,
            p_log_param_6_in                     => l_log_param_6,
            p_log_param_7_in                     => l_log_param_7,
            p_log_param_8_in                     => l_log_param_8,
            p_log_param_9_in                     => l_log_param_9,
            p_log_param_10_in                    => l_log_param_10,
            p_log_param_11_in                    => l_log_param_11,
            p_log_param_12_in                    => l_log_param_12,
            p_log_param_13_in                    => l_log_param_13,
            p_log_param_14_in                    => l_log_param_14,
            p_log_param_15_in                    => l_log_param_15,
            p_log_param_16_in                    => l_log_param_16,
            p_log_param_17_in                    => l_log_param_17,
            p_log_param_18_in                    => l_log_param_18,
            p_log_param_19_in                    => l_log_param_19,
            p_log_param_20_in                    => l_log_param_20,
            p_log_param_21_in                    => l_log_param_21,
            p_log_param_22_in                    => l_log_param_22,
            p_log_param_23_in                    => l_log_param_23,
            p_log_param_24_in                    => l_log_param_24,
            p_log_param_25_in                    => l_log_param_25,
            p_log_param_26_in                    => l_log_param_26,
            p_log_param_27_in                    => l_log_param_27,
            p_log_param_28_in                    => l_log_param_28,
            p_log_param_29_in                    => l_log_param_29,
            p_log_param_30_in                    => l_log_param_30);

        ROLLBACK;

        l_sql_stmnt := 'SELECT ckey
                              FROM sbsdb_log
                             WHERE INSTR (cvalue, ''"text"' || CHR (58) || '"' || l_text || '"'') <> 0 AND INSTR (cvalue, ''"scope"' || CHR (58) || '"' || lc_scope || '",'') <> 0';

        EXECUTE IMMEDIATE l_sql_stmnt
            INTO                                     l_ckey;
    END log_permanent_table;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.scope_method].
       ---------------------------------------------------------------------- */

    PROCEDURE scope_method
    IS
        lc_prefix                      CONSTANT sbsdb_type_lib.oracle_name_t
                                                    :=    sbsdb_db_con.dbuname ()
                                                       || CASE
                                                              WHEN sbsdb_db_con.is_cdb () = sbsdb_type_lib.TRUE
                                                              THEN
                                                                  '.' || sbsdb_db_con.pdbname ()
                                                              ELSE
                                                                  NULL
                                                          END
                                                       || ':' ;
    BEGIN
        ut.expect (sbsdb_logger_lib.scope ('method')).to_equal (lc_prefix || 'method');
        ut.expect (sbsdb_logger_lib.scope ('METHOD')).to_equal (lc_prefix || 'method');
        ut.expect (sbsdb_logger_lib.scope (NULL)).to_equal (lc_prefix);
    END scope_method;

    /* =========================================================================
       Test: [Test method sbsdb_logger_lib.scope_package].
       ---------------------------------------------------------------------- */

    PROCEDURE scope_package
    IS
        lc_prefix                      CONSTANT sbsdb_type_lib.oracle_name_t
                                                    :=    sbsdb_db_con.dbuname ()
                                                       || CASE
                                                              WHEN sbsdb_db_con.is_cdb () = sbsdb_type_lib.TRUE
                                                              THEN
                                                                  '.' || sbsdb_db_con.pdbname ()
                                                              ELSE
                                                                  NULL
                                                          END
                                                       || ':' ;
    BEGIN
        ut.expect (sbsdb_logger_lib.scope ('package', 'method')).to_equal (lc_prefix || 'package.method');
        ut.expect (sbsdb_logger_lib.scope ('PACKAGE', 'METHOD')).to_equal (lc_prefix || 'package.method');
        ut.expect (sbsdb_logger_lib.scope ('', 'method')).to_equal (lc_prefix || '.method');
        ut.expect (sbsdb_logger_lib.scope ('package', '')).to_equal (lc_prefix || 'package.');
        ut.expect (sbsdb_logger_lib.scope ('', '')).to_equal (lc_prefix || '.');
    END scope_package;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_sbsdb_logger;
/
