CREATE OR REPLACE PACKAGE BODY test_pkg_json
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method from_json_boolean - from_json_boolean].
       ---------------------------------------------------------------------- */

    PROCEDURE from_json_boolean
    IS
    BEGIN
        ut.expect (pkg_json.from_json_boolean ('abc')).to_be_null ();
        ut.expect (pkg_json.from_json_boolean ('False')).to_be_null ();
        ut.expect (pkg_json.from_json_boolean ('false')).to_equal (0);
        ut.expect (pkg_json.from_json_boolean ('null')).to_be_null ();
        ut.expect (pkg_json.from_json_boolean ('True')).to_be_null ();
        ut.expect (pkg_json.from_json_boolean ('true')).to_equal (1);
    END from_json_boolean;

    /* =========================================================================
       Test: [Test method from_json_date - from_json_date].
       ---------------------------------------------------------------------- */

    PROCEDURE from_json_date
    IS
    BEGIN
        ut.expect (pkg_json.from_json_date ('1951-06-21 12:00:00')).to_equal (TO_DATE ('1951-06-21 12:00:00', 'yyyy-mm-dd hh24:mi:ss'));
        ut.expect (pkg_json.from_json_date ('1951-06-21')).to_equal (TO_DATE ('1951-06-21', 'yyyy-mm-dd'));
        ut.expect (pkg_json.from_json_date ('1951-06-21T00:00:00Z')).to_equal (TO_DATE ('21.06.1951', 'dd.mm.yyyy'));
        ut.expect (pkg_json.from_json_date (NULL)).to_be_null ();
    END from_json_date;

    /* =========================================================================
       Test: [Test method json_boolean - json_boolean].
       ---------------------------------------------------------------------- */

    PROCEDURE json_boolean
    IS
    BEGIN
        ut.expect (pkg_json.json_boolean ('0')).to_equal ('false');
        ut.expect (pkg_json.json_boolean ('0', 'abc')).to_equal ('false');
        ut.expect (pkg_json.json_boolean ('1')).to_equal ('true');
        ut.expect (pkg_json.json_boolean ('1951-06-21')).to_equal ('null');
        ut.expect (pkg_json.json_boolean ('1951-06-21', 'abc')).to_equal ('abc');
        ut.expect (pkg_json.json_boolean ('false')).to_equal ('false');
        ut.expect (pkg_json.json_boolean ('FALSE')).to_equal ('false');
        ut.expect (pkg_json.json_boolean ('true')).to_equal ('true');
        ut.expect (pkg_json.json_boolean ('TRUE')).to_equal ('true');
        ut.expect (pkg_json.json_boolean (NULL)).to_equal ('null');
        ut.expect (pkg_json.json_boolean (NULL, 'abc')).to_equal ('abc');
    END json_boolean;

    /* =========================================================================
       Test: [Test method json_date - json_date].
       ---------------------------------------------------------------------- */

    PROCEDURE json_date
    IS
    BEGIN
        ut.expect (pkg_json.json_date (NULL)).to_equal ('""');
        ut.expect (pkg_json.json_date (TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('"1951-06-21T00:00:00Z"');
    END json_date;

    /* =========================================================================
       Test: [Test method json_foreign_key - json_foreign_key].
       ---------------------------------------------------------------------- */

    PROCEDURE json_foreign_key
    IS
    BEGIN
        ut.expect (pkg_json.json_foreign_key ('a')).to_equal ('{"fk":["a"]}');
        ut.expect (pkg_json.json_foreign_key ('a', 'BB')).to_equal ('{"fk":["a","BB"]}');
        ut.expect (
            pkg_json.json_foreign_key (
                p_1                                  => 'a',
                p_2                                  => 'BB',
                p_3                                  => 'ccc',
                p_4                                  => 'DDDD',
                p_5                                  => 'eeee',
                p_6                                  => 'FFF',
                p_7                                  => 'gg',
                p_8                                  => 'H',
                p_9                                  => 'ii',
                p_a                                  => 'JJ')).to_equal ('{"fk":["a","BB","ccc","DDDD","eeee","FFF","gg","H","ii","JJ"]}');
        ut.expect (pkg_json.json_foreign_key (NULL)).to_equal ('{"fk":[[]]}');
    END json_foreign_key;

    /* =========================================================================
       Test: [Test method json_foreign_key_2 - json_foreign_key_2].
       ---------------------------------------------------------------------- */

    PROCEDURE json_foreign_key_2
    IS
    BEGIN
        ut.expect (pkg_json.json_foreign_key_2 ('a', 'BB')).to_equal ('{"fk":["a","BB"]}');
        ut.expect (pkg_json.json_foreign_key_2 ('a', NULL)).to_equal ('{"fk":["a",""]}');
        ut.expect (pkg_json.json_foreign_key_2 (NULL, 'BB')).to_equal ('{"fk":["","BB"]}');
        ut.expect (pkg_json.json_foreign_key_2 (NULL, NULL)).to_equal ('{"fk":["",""]}');
    END json_foreign_key_2;

    /* =========================================================================
       Test: [Test method json_foreign_keys - json_foreign_keys].
       ---------------------------------------------------------------------- */

    PROCEDURE json_foreign_keys
    IS
    BEGIN
        ut.expect (pkg_json.json_foreign_keys ('a')).to_equal ('{"fks":[["a"]]}');
        ut.expect (pkg_json.json_foreign_keys ('a', 'BB')).to_equal ('{"fks":[["a","BB"]]}');
        ut.expect (
            pkg_json.json_foreign_keys (
                p_1                                  => 'a',
                p_2                                  => 'BB',
                p_3                                  => 'ccc',
                p_4                                  => 'DDDD',
                p_5                                  => 'eeee',
                p_6                                  => 'FFF',
                p_7                                  => 'gg',
                p_8                                  => 'H',
                p_9                                  => 'ii',
                p_a                                  => 'JJ')).to_equal ('{"fks":[["a","BB","ccc","DDDD","eeee","FFF","gg","H","ii","JJ"]]}');
        ut.expect (pkg_json.json_foreign_keys (NULL)).to_equal ('{"fks":[[[]]]}');
    END json_foreign_keys;

    /* =========================================================================
       Test: [Test method json_foreign_keys_2 - json_foreign_keys_2].
       ---------------------------------------------------------------------- */

    PROCEDURE json_foreign_keys_2
    IS
    BEGIN
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ')).to_equal ('{"fks":[["a",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ;  ')).to_equal ('{"fks":[["a",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ;  ;')).to_equal ('{"fks":[["a",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ;')).to_equal ('{"fks":[["a",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ;B B  ')).to_equal ('{"fks":[["a","BB"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ;B B  ;')).to_equal ('{"fks":[["a","BB"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', '  ;BB')).to_equal ('{"fks":[["a","BB"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', 'BB')).to_equal ('{"fks":[["a","BB"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 ('a', NULL)).to_equal ('{"fks":[["a",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ')).to_equal ('{"fks":[["",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ;  ')).to_equal ('{"fks":[["",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ;  ;')).to_equal ('{"fks":[["",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ;')).to_equal ('{"fks":[["",null]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ;a  ')).to_equal ('{"fks":[["","a"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ;a  ;')).to_equal ('{"fks":[["","a"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, '  ;a')).to_equal ('{"fks":[["","a"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, 'BB')).to_equal ('{"fks":[["","BB"]]}');
        ut.expect (pkg_json.json_foreign_keys_2 (NULL, NULL)).to_equal ('{"fks":[["",null]]}');
    END json_foreign_keys_2;

    /* =========================================================================
       Test: [Test method json_key_sn - json_key_sn].
       ---------------------------------------------------------------------- */

    PROCEDURE json_key_sn
    IS
    BEGIN
        ut.expect (pkg_json.json_key_sn ('aBc', 1234)).to_equal ('["aBc",1234]');
        ut.expect (pkg_json.json_key_sn ('aBc', NULL)).to_equal ('["aBc",]');
        ut.expect (pkg_json.json_key_sn (NULL, 1234)).to_equal ('[[],1234]');
        ut.expect (pkg_json.json_key_sn (NULL, NULL)).to_equal ('[[],]');
    END json_key_sn;

    /* =========================================================================
       Test: [Test method json_key_snn - json_key_snn].
       ---------------------------------------------------------------------- */

    PROCEDURE json_key_snn
    IS
    BEGIN
        ut.expect (pkg_json.json_key_snn ('aBc', 1234, 5678)).to_equal ('["aBc",1234,5678]');
        ut.expect (pkg_json.json_key_snn ('aBc', 1234, NULL)).to_equal ('["aBc",1234,]');
        ut.expect (pkg_json.json_key_snn ('aBc', NULL, 1234)).to_equal ('["aBc",,1234]');
        ut.expect (pkg_json.json_key_snn ('aBc', NULL, NULL)).to_equal ('["aBc",,]');
        ut.expect (pkg_json.json_key_snn (NULL, 1234, 5678)).to_equal ('[[],1234,5678]');
        ut.expect (pkg_json.json_key_snn (NULL, 1234, NULL)).to_equal ('[[],1234,]');
        ut.expect (pkg_json.json_key_snn (NULL, NULL, 1234)).to_equal ('[[],,1234]');
        ut.expect (pkg_json.json_key_snn (NULL, NULL, NULL)).to_equal ('[[],,]');
    END json_key_snn;

    /* =========================================================================
       Test: [Test method json_key_sns - json_key_sns].
       ---------------------------------------------------------------------- */

    PROCEDURE json_key_sns
    IS
    BEGIN
        ut.expect (pkg_json.json_key_sns ('aBc', 1234, '5678')).to_equal ('["aBc",1234,"5678"]');
        ut.expect (pkg_json.json_key_sns ('aBc', 1234, NULL)).to_equal ('["aBc",1234,""]');
        ut.expect (pkg_json.json_key_sns ('aBc', NULL, '1234')).to_equal ('["aBc",,"1234"]');
        ut.expect (pkg_json.json_key_sns ('aBc', NULL, NULL)).to_equal ('["aBc",,""]');
        ut.expect (pkg_json.json_key_sns (NULL, 1234, '5678')).to_equal ('[[],1234,"5678"]');
        ut.expect (pkg_json.json_key_sns (NULL, 1234, NULL)).to_equal ('[[],1234,""]');
        ut.expect (pkg_json.json_key_sns (NULL, NULL, '1234')).to_equal ('[[],,"1234"]');
        ut.expect (pkg_json.json_key_sns (NULL, NULL, NULL)).to_equal ('[[],,""]');
    END json_key_sns;

    /* =========================================================================
       Test: [Test method json_not_null - json_not_null].
       ---------------------------------------------------------------------- */

    PROCEDURE json_not_null
    IS
    BEGIN
        ut.expect (pkg_json.json_not_null ('aBc', '""')).to_be_null ();
        ut.expect (pkg_json.json_not_null ('aBc', '1234')).to_equal (',"aBc":"1234"');
        ut.expect (pkg_json.json_not_null ('aBc', NULL)).to_be_null ();
        ut.expect (pkg_json.json_not_null (NULL, '""')).to_be_null ();
        ut.expect (pkg_json.json_not_null (NULL, '1234')).to_equal (',"":"1234"');
        ut.expect (pkg_json.json_not_null (NULL, NULL)).to_be_null ();
    END json_not_null;

    /* =========================================================================
       Test: [Test method json_num - json_num].
       ---------------------------------------------------------------------- */

    PROCEDURE json_num
    IS
    BEGIN
        ut.expect (pkg_json.json_num ('aBc', 1234)).to_equal ('"aBc"');
        ut.expect (pkg_json.json_num ('DeF')).to_equal ('"DeF"');
        ut.expect (pkg_json.json_num (5678)).to_equal ('5678');
        ut.expect (pkg_json.json_num (5678, 1234)).to_equal ('5678');
        ut.expect (pkg_json.json_num (NULL)).to_equal ('0');
        ut.expect (pkg_json.json_num (NULL, 1234)).to_equal ('1234');
    END json_num;

    /* =========================================================================
       Test: [Test method json_number - json_number].
       ---------------------------------------------------------------------- */

    PROCEDURE json_number
    IS
    BEGIN
        ut.expect (pkg_json.json_number (-.5678, -.1234)).to_equal ('-0.5678');
        ut.expect (pkg_json.json_number (.5678, .1234)).to_equal ('0.5678');
        ut.expect (pkg_json.json_number (5.678, 1.234)).to_equal ('5.678');
        ut.expect (pkg_json.json_number (5678, 1234)).to_equal ('5678');
        ut.expect (pkg_json.json_number (5678, NULL)).to_equal ('5678');
        ut.expect (pkg_json.json_number (NULL, -.1234)).to_equal ('-0.1234');
        ut.expect (pkg_json.json_number (NULL, .1234)).to_equal ('0.1234');
        ut.expect (pkg_json.json_number (NULL, 1.234)).to_equal ('1.234');
        ut.expect (pkg_json.json_number (NULL, 1234)).to_equal ('1234');
        ut.expect (pkg_json.json_number (NULL, NULL)).to_equal ('null');
    END json_number;

    /* =========================================================================
       Test: [Test method json_numstr - json_numstr].
       ---------------------------------------------------------------------- */

    PROCEDURE json_numstr
    IS
    BEGIN
        ut.expect (pkg_json.json_numstr (-123.4, 0)).to_equal ('"-123"');
        ut.expect (pkg_json.json_numstr (-123.4, 1)).to_equal ('"-123.4"');
        ut.expect (pkg_json.json_numstr (-123.4, 2)).to_equal ('"-123.40"');
        ut.expect (pkg_json.json_numstr (-123.4, 3)).to_equal ('"-123.400"');
        ut.expect (pkg_json.json_numstr (-123.4, 4)).to_equal ('"-123.4000"');
        ut.expect (pkg_json.json_numstr (-123.4, 4711)).to_equal ('"-123.4"');
        ut.expect (pkg_json.json_numstr (-123.45, 1)).to_equal ('"-123.5"');
        ut.expect (pkg_json.json_numstr (-123.45, 2)).to_equal ('"-123.45"');
        ut.expect (pkg_json.json_numstr (-123.45, 3)).to_equal ('"-123.450"');
        ut.expect (pkg_json.json_numstr (-123.45, 4)).to_equal ('"-123.4500"');
        ut.expect (pkg_json.json_numstr (-123.45, 4711)).to_equal ('"-123.45"');
        ut.expect (pkg_json.json_numstr (-1234, 0)).to_equal ('"-1234"');
        ut.expect (pkg_json.json_numstr (-1234, 1)).to_equal ('"-1234.0"');
        ut.expect (pkg_json.json_numstr (-1234, 2)).to_equal ('"-1234.00"');
        ut.expect (pkg_json.json_numstr (-1234, 3)).to_equal ('"-1234.000"');
        ut.expect (pkg_json.json_numstr (-1234, 4)).to_equal ('"-1234.0000"');
        ut.expect (pkg_json.json_numstr (-1234, 4711)).to_equal ('"-1234"');
        ut.expect (pkg_json.json_numstr (123.4, 0)).to_equal ('"123"');
        ut.expect (pkg_json.json_numstr (123.4, 1)).to_equal ('"123.4"');
        ut.expect (pkg_json.json_numstr (123.4, 2)).to_equal ('"123.40"');
        ut.expect (pkg_json.json_numstr (123.4, 3)).to_equal ('"123.400"');
        ut.expect (pkg_json.json_numstr (123.4, 4)).to_equal ('"123.4000"');
        ut.expect (pkg_json.json_numstr (123.4, 4711)).to_equal ('"123.4"');
        ut.expect (pkg_json.json_numstr (123.45, 1)).to_equal ('"123.5"');
        ut.expect (pkg_json.json_numstr (123.45, 2)).to_equal ('"123.45"');
        ut.expect (pkg_json.json_numstr (123.45, 3)).to_equal ('"123.450"');
        ut.expect (pkg_json.json_numstr (123.45, 4)).to_equal ('"123.4500"');
        ut.expect (pkg_json.json_numstr (123.45, 4711)).to_equal ('"123.45"');
        ut.expect (pkg_json.json_numstr (1234, 0)).to_equal ('"1234"');
        ut.expect (pkg_json.json_numstr (1234, 1)).to_equal ('"1234.0"');
        ut.expect (pkg_json.json_numstr (1234, 2)).to_equal ('"1234.00"');
        ut.expect (pkg_json.json_numstr (1234, 3)).to_equal ('"1234.000"');
        ut.expect (pkg_json.json_numstr (1234, 4)).to_equal ('"1234.0000"');
        ut.expect (pkg_json.json_numstr (1234, 4711)).to_equal ('"1234"');
        ut.expect (pkg_json.json_numstr (NULL, 1234)).to_equal ('""');
        ut.expect (pkg_json.json_numstr (NULL, NULL)).to_equal ('""');
    END json_numstr;

    /* =========================================================================
       Test: [Test method json_prefix - json_prefix].
       ---------------------------------------------------------------------- */

    PROCEDURE json_prefix
    IS
    BEGIN
        ut.expect (pkg_json.json_prefix ('Hello world!')).to_equal (',Hello world!');
        ut.expect (pkg_json.json_prefix (NULL)).to_be_null ();
    END json_prefix;

    /* =========================================================================
       Test: [Test method json_string - json_string].
       ---------------------------------------------------------------------- */

    PROCEDURE json_string
    IS
    BEGIN
        ut.expect (pkg_json.json_string ('"\' || CHR (8) || CHR (9) || CHR (10) || CHR (12) || CHR (13))).to_equal ('"\"\\\b\t\n\f\r"');
        ut.expect (pkg_json.json_string ('Hello world!')).to_equal ('"Hello world!"');
        ut.expect (pkg_json.json_string (NULL)).to_equal ('""');
    END json_string;

    /* =========================================================================
       Test: [Test method json_string_key - json_string_key].
       ---------------------------------------------------------------------- */

    PROCEDURE json_string_key
    IS
    BEGIN
        ut.expect (pkg_json.json_string_key ('p_1')).to_equal ('["p_1"]');
        ut.expect (pkg_json.json_string_key ('p_1', 'P_2')).to_equal ('["p_1","P_2"]');
        ut.expect (pkg_json.json_string_key ('p_1', 'P_2', 'p_3')).to_equal ('["p_1","P_2","p_3"]');
        ut.expect (pkg_json.json_string_key ('p_1', 'P_2', 'p_3', 'P_4')).to_equal ('["p_1","P_2","p_3","P_4"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => 'p_1',
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5')).to_equal ('["p_1","P_2","p_3","P_4","p_5"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => 'p_1',
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6')).to_equal ('["p_1","P_2","p_3","P_4","p_5","P_6"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => 'p_1',
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7')).to_equal ('["p_1","P_2","p_3","P_4","p_5","P_6","p_7"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => 'p_1',
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7',
                p_8                                  => 'P_8')).to_equal ('["p_1","P_2","p_3","P_4","p_5","P_6","p_7","P_8"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => 'p_1',
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7',
                p_8                                  => 'P_8',
                p_9                                  => 'p_9')).to_equal ('["p_1","P_2","p_3","P_4","p_5","P_6","p_7","P_8","p_9"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => 'p_1',
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7',
                p_8                                  => 'P_8',
                p_9                                  => 'p_9',
                p_a                                  => 'P_10')).to_equal ('["p_1","P_2","p_3","P_4","p_5","P_6","p_7","P_8","p_9","P_10"]');

        ut.expect (pkg_json.json_string_key (NULL)).to_equal ('[[]]');
        ut.expect (pkg_json.json_string_key (NULL, 'P_2')).to_equal ('[[],"P_2"]');
        ut.expect (pkg_json.json_string_key (NULL, 'P_2', 'p_3')).to_equal ('[[],"P_2","p_3"]');
        ut.expect (pkg_json.json_string_key (NULL, 'P_2', 'p_3', 'P_4')).to_equal ('[[],"P_2","p_3","P_4"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => NULL,
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5')).to_equal ('[[],"P_2","p_3","P_4","p_5"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => NULL,
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6')).to_equal ('[[],"P_2","p_3","P_4","p_5","P_6"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => NULL,
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7')).to_equal ('[[],"P_2","p_3","P_4","p_5","P_6","p_7"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => NULL,
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7',
                p_8                                  => 'P_8')).to_equal ('[[],"P_2","p_3","P_4","p_5","P_6","p_7","P_8"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => NULL,
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7',
                p_8                                  => 'P_8',
                p_9                                  => 'p_9')).to_equal ('[[],"P_2","p_3","P_4","p_5","P_6","p_7","P_8","p_9"]');
        ut.expect (
            pkg_json.json_string_key (
                p_1                                  => NULL,
                p_2                                  => 'P_2',
                p_3                                  => 'p_3',
                p_4                                  => 'P_4',
                p_5                                  => 'p_5',
                p_6                                  => 'P_6',
                p_7                                  => 'p_7',
                p_8                                  => 'P_8',
                p_9                                  => 'p_9',
                p_a                                  => 'P_10')).to_equal ('[[],"P_2","p_3","P_4","p_5","P_6","p_7","P_8","p_9","P_10"]');
    END json_string_key;

    /* =========================================================================
       Test: [Test method json_string_key_2 - json_string_key_2].
       ---------------------------------------------------------------------- */

    PROCEDURE json_string_key_2
    IS
    BEGIN
        ut.expect (pkg_json.json_string_key_2 ('AbC', 'bCd')).to_equal ('["AbC","bCd"]');
        ut.expect (pkg_json.json_string_key_2 ('AbC', NULL)).to_equal ('["AbC",""]');
        ut.expect (pkg_json.json_string_key_2 (NULL, 'bCd')).to_equal ('[[],"bCd"]');
        ut.expect (pkg_json.json_string_key_2 (NULL, NULL)).to_equal ('[[],""]');
    END json_string_key_2;

    /* =========================================================================
       Test: [Test method json_suffix - json_suffix].
       ---------------------------------------------------------------------- */

    PROCEDURE json_suffix
    IS
    BEGIN
        ut.expect (pkg_json.json_suffix ('Hello world!')).to_equal ('Hello world!,');
        ut.expect (pkg_json.json_suffix (NULL)).to_be_null ();
    END json_suffix;

    /* =========================================================================
       Test: [Test method json_text - json_text].
       ---------------------------------------------------------------------- */

    PROCEDURE json_text
    IS
    BEGIN
        ut.expect (pkg_json.json_text ('string_1')).to_equal ('"string_1"');
        ut.expect (pkg_json.json_text ('string_1', 'STRING_2')).to_equal ('"string_1\r\nSTRING_2"');
        ut.expect (pkg_json.json_text ('string_1', 'STRING_2', 'string_3')).to_equal ('"string_1\r\nSTRING_2\r\nstring_3"');
        ut.expect (pkg_json.json_text ('string_1', NULL, 'string_3')).to_equal ('"string_1\r\n\r\nstring_3"');
        ut.expect (pkg_json.json_text (NULL)).to_equal ('""');
    END json_text;

    /* =========================================================================
       Test: [Test method json_true - json_true].
       ---------------------------------------------------------------------- */

    PROCEDURE json_true
    IS
    BEGIN
        ut.expect (pkg_json.json_true ('name_1', 'false')).to_be_null ();
        ut.expect (pkg_json.json_true ('name_1', 'True')).to_equal (',"name_1":true');
        ut.expect (pkg_json.json_true ('name_1', 'true')).to_equal (',"name_1":true');
        ut.expect (pkg_json.json_true ('name_1', 'value_1')).to_be_null ();
        ut.expect (pkg_json.json_true ('name_1', NULL)).to_be_null ();
        ut.expect (pkg_json.json_true (NULL, 'false')).to_be_null ();
        ut.expect (pkg_json.json_true (NULL, 'True')).to_equal (',"":true');
        ut.expect (pkg_json.json_true (NULL, 'true')).to_equal (',"":true');
        ut.expect (pkg_json.json_true (NULL, 'value_1')).to_be_null ();
        ut.expect (pkg_json.json_true (NULL, NULL)).to_be_null ();
    END json_true;

    /* =========================================================================
       Test: [Test method json_type - json_type].
       ---------------------------------------------------------------------- */

    PROCEDURE json_type
    IS
    BEGIN
        ut.expect (pkg_json.json_type ('any', '123')).to_equal ('"123"');
        ut.expect (pkg_json.json_type ('any', '123.4')).to_equal ('"123.4"');
        ut.expect (pkg_json.json_type ('any', 'abc')).to_equal ('"abc"');
        ut.expect (pkg_json.json_type ('any', NULL)).to_equal ('""');
        ut.expect (pkg_json.json_type ('boolean', '123')).to_equal ('null');
        ut.expect (pkg_json.json_type ('boolean', '123.4')).to_equal ('null');
        ut.expect (pkg_json.json_type ('boolean', 'abc')).to_equal ('null');
        ut.expect (pkg_json.json_type ('boolean', 'false')).to_equal ('false');
        ut.expect (pkg_json.json_type ('boolean', 'FALSE')).to_equal ('false');
        ut.expect (pkg_json.json_type ('boolean', 'true')).to_equal ('true');
        ut.expect (pkg_json.json_type ('boolean', 'TRUE')).to_equal ('true');
        ut.expect (pkg_json.json_type ('boolean', NULL)).to_equal ('null');
        ut.expect (pkg_json.json_type ('double', '123')).to_equal ('123');
        ut.expect (pkg_json.json_type ('double', '123.4')).to_equal ('123.4');
        ut.expect (pkg_json.json_type ('double', 'abc')).to_equal ('"abc"');
        ut.expect (pkg_json.json_type ('double', NULL)).to_equal ('null');
        ut.expect (pkg_json.json_type ('integer', '123')).to_equal ('123');
        ut.expect (pkg_json.json_type ('integer', '123.4')).to_equal ('123.4');
        ut.expect (pkg_json.json_type ('integer', 'abc')).to_equal ('"abc"');
        ut.expect (pkg_json.json_type ('integer', NULL)).to_equal ('null');
        ut.expect (pkg_json.json_type ('name_1', '**null**')).to_equal ('null');
        ut.expect (pkg_json.json_type (NULL)).to_equal ('""');
        ut.expect (pkg_json.json_type (NULL, '**null**')).to_equal ('null');
    END json_type;

    /* =========================================================================
       Test: [Test method jsond - jsond].
       ---------------------------------------------------------------------- */

    PROCEDURE jsond
    IS
    BEGIN
        ut.expect (pkg_json.jsond ('%{', 'key_1', NULL)).to_equal ('%{"key_1":""');
        ut.expect (pkg_json.jsond ('%{', 'key_1', TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('%{"key_1":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond ('%{', NULL, NULL)).to_equal ('%{"":""');
        ut.expect (pkg_json.jsond ('%{', NULL, TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('%{"":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond ('other_value', 'key_1', NULL)).to_equal ('other_value,"key_1":""');
        ut.expect (pkg_json.jsond ('other_value', 'key_1', TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('other_value,"key_1":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond ('other_value', NULL, NULL)).to_equal ('other_value,"":""');
        ut.expect (pkg_json.jsond ('other_value', NULL, TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('other_value,"":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond (NULL, 'key_1', NULL)).to_equal ('"key_1":""');
        ut.expect (pkg_json.jsond (NULL, 'key_1', TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('"key_1":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond (NULL, NULL, NULL)).to_equal ('"":""');
        ut.expect (pkg_json.jsond (NULL, NULL, TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('"":"1951-06-21T00:00:00Z"');
    END jsond;

    /* =========================================================================
       Test: [Test method jsond0 - jsond0].
       ---------------------------------------------------------------------- */

    PROCEDURE jsond0
    IS
    BEGIN
        ut.expect (pkg_json.jsond0 ('%{', 'key_1', NULL)).to_equal ('%{');
        ut.expect (pkg_json.jsond0 ('%{', 'key_1', TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('%{"key_1":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond0 ('%{', NULL, NULL)).to_equal ('%{');
        ut.expect (pkg_json.jsond0 ('%{', NULL, TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('%{"":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond0 ('other_value', 'key_1', NULL)).to_equal ('other_value');
        ut.expect (pkg_json.jsond0 ('other_value', 'key_1', TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('other_value,"key_1":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond0 ('other_value', NULL, NULL)).to_equal ('other_value');
        ut.expect (pkg_json.jsond0 ('other_value', NULL, TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('other_value,"":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond0 (NULL, 'key_1', NULL)).to_be_null ();
        ut.expect (pkg_json.jsond0 (NULL, 'key_1', TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('"key_1":"1951-06-21T00:00:00Z"');
        ut.expect (pkg_json.jsond0 (NULL, NULL, NULL)).to_be_null ();
        ut.expect (pkg_json.jsond0 (NULL, NULL, TO_DATE ('21.06.1951', 'dd.mm.yyyy'))).to_equal ('"":"1951-06-21T00:00:00Z"');
    END jsond0;

    /* =========================================================================
       Test: [Test method jsonn - jsonn].
       ---------------------------------------------------------------------- */

    PROCEDURE jsonn
    IS
    BEGIN
        ut.expect (pkg_json.jsonn ('%{', 'key_1', 1234)).to_equal ('%{"key_1":1234');
        ut.expect (pkg_json.jsonn ('%{', 'key_1', NULL)).to_equal ('%{"key_1":null');
        ut.expect (pkg_json.jsonn ('%{', NULL, 1234)).to_equal ('%{"":1234');
        ut.expect (pkg_json.jsonn ('%{', NULL, NULL)).to_equal ('%{"":null');
        ut.expect (pkg_json.jsonn ('other_value', 'key_1', 1234)).to_equal ('other_value,"key_1":1234');
        ut.expect (pkg_json.jsonn ('other_value', 'key_1', NULL)).to_equal ('other_value,"key_1":null');
        ut.expect (pkg_json.jsonn ('other_value', NULL, 1234)).to_equal ('other_value,"":1234');
        ut.expect (pkg_json.jsonn ('other_value', NULL, NULL)).to_equal ('other_value,"":null');
        ut.expect (pkg_json.jsonn (NULL, 'key_1', 1234)).to_equal ('"key_1":1234');
        ut.expect (pkg_json.jsonn (NULL, 'key_1', NULL)).to_equal ('"key_1":null');
        ut.expect (pkg_json.jsonn (NULL, NULL, 1234)).to_equal ('"":1234');
        ut.expect (pkg_json.jsonn (NULL, NULL, NULL)).to_equal ('"":null');
    END jsonn;

    /* =========================================================================
       Test: [Test method jsonn0 - jsonn0].
       ---------------------------------------------------------------------- */

    PROCEDURE jsonn0
    IS
    BEGIN
        ut.expect (pkg_json.jsonn0 ('%{', 'key_1', 1234)).to_equal ('%{"key_1":1234');
        ut.expect (pkg_json.jsonn0 ('%{', 'key_1', NULL)).to_equal ('%{');
        ut.expect (pkg_json.jsonn0 ('%{', NULL, 1234)).to_equal ('%{"":1234');
        ut.expect (pkg_json.jsonn0 ('%{', NULL, NULL)).to_equal ('%{');
        ut.expect (pkg_json.jsonn0 ('other_value', 'key_1', 1234)).to_equal ('other_value,"key_1":1234');
        ut.expect (pkg_json.jsonn0 ('other_value', 'key_1', NULL)).to_equal ('other_value');
        ut.expect (pkg_json.jsonn0 ('other_value', NULL, 1234)).to_equal ('other_value,"":1234');
        ut.expect (pkg_json.jsonn0 ('other_value', NULL, NULL)).to_equal ('other_value');
        ut.expect (pkg_json.jsonn0 (NULL, 'key_1', 1234)).to_equal ('"key_1":1234');
        ut.expect (pkg_json.jsonn0 (NULL, 'key_1', NULL)).to_be_null ();
        ut.expect (pkg_json.jsonn0 (NULL, NULL, 1234)).to_equal ('"":1234');
        ut.expect (pkg_json.jsonn0 (NULL, NULL, NULL)).to_be_null ();
    END jsonn0;

    /* =========================================================================
       Test: [Test method jsons - jsons].
       ---------------------------------------------------------------------- */

    PROCEDURE jsons
    IS
    BEGIN
        ut.expect (pkg_json.jsons ('%{', 'key_1', 'value_1')).to_equal ('%{"key_1":"value_1"');
        ut.expect (pkg_json.jsons ('%{', 'key_1', NULL)).to_equal ('%{"key_1":""');
        ut.expect (pkg_json.jsons ('%{', NULL, 'value_1')).to_equal ('%{"":"value_1"');
        ut.expect (pkg_json.jsons ('%{', NULL, NULL)).to_equal ('%{"":""');
        ut.expect (pkg_json.jsons ('other_value', 'key_1', 'value_1')).to_equal ('other_value,"key_1":"value_1"');
        ut.expect (pkg_json.jsons ('other_value', 'key_1', NULL)).to_equal ('other_value,"key_1":""');
        ut.expect (pkg_json.jsons ('other_value', NULL, 'value_1')).to_equal ('other_value,"":"value_1"');
        ut.expect (pkg_json.jsons ('other_value', NULL, NULL)).to_equal ('other_value,"":""');
        ut.expect (pkg_json.jsons (NULL, 'key_1', 'value_1')).to_equal ('"key_1":"value_1"');
        ut.expect (pkg_json.jsons (NULL, 'key_1', NULL)).to_equal ('"key_1":""');
        ut.expect (pkg_json.jsons (NULL, NULL, 'value_1')).to_equal ('"":"value_1"');
        ut.expect (pkg_json.jsons (NULL, NULL, NULL)).to_equal ('"":""');
    END jsons;

    /* =========================================================================
       Test: [Test method jsons0 - jsons0].
       ---------------------------------------------------------------------- */

    PROCEDURE jsons0
    IS
    BEGIN
        ut.expect (pkg_json.jsons0 ('%{', 'key_1', 'value_1')).to_equal ('%{"key_1":"value_1"');
        ut.expect (pkg_json.jsons0 ('%{', 'key_1', NULL)).to_equal ('%{');
        ut.expect (pkg_json.jsons0 ('%{', NULL, 'value_1')).to_equal ('%{"":"value_1"');
        ut.expect (pkg_json.jsons0 ('%{', NULL, NULL)).to_equal ('%{');
        ut.expect (pkg_json.jsons0 ('other_value', 'key_1', 'value_1')).to_equal ('other_value,"key_1":"value_1"');
        ut.expect (pkg_json.jsons0 ('other_value', 'key_1', NULL)).to_equal ('other_value');
        ut.expect (pkg_json.jsons0 ('other_value', NULL, 'value_1')).to_equal ('other_value,"":"value_1"');
        ut.expect (pkg_json.jsons0 ('other_value', NULL, NULL)).to_equal ('other_value');
        ut.expect (pkg_json.jsons0 (NULL, 'key_1', 'value_1')).to_equal ('"key_1":"value_1"');
        ut.expect (pkg_json.jsons0 (NULL, 'key_1', NULL)).to_be_null ();
        ut.expect (pkg_json.jsons0 (NULL, NULL, 'value_1')).to_equal ('"":"value_1"');
        ut.expect (pkg_json.jsons0 (NULL, NULL, NULL)).to_be_null ();
    END jsons0;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_json;
/
