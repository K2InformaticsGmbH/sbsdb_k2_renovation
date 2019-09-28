CREATE OR REPLACE PACKAGE BODY test_pkg_code_mgmt
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method get_ddl - get_ddl]].
       ---------------------------------------------------------------------- */

    PROCEDURE get_ddl
    IS
        l_clob                                  CLOB;
    BEGIN
        l_clob := pkg_code_mgmt.get_ddl (lvtype => NULL, lvname => NULL, lvschema => NULL);

        ut.expect (l_clob).to_equal (TO_CLOB ('ORA-31600'));

        l_clob := pkg_code_mgmt.get_ddl (lvtype => 'PACKAGE_SPEC', lvname => 'test_pkg_code_mgmt', lvschema => NULL);

        ut.expect (l_clob).to_equal (TO_CLOB ('ORA-31603'));

        l_clob := pkg_code_mgmt.get_ddl (lvtype => 'PACKAGE_SPEC', lvname => 'TEST_PKG_CODE_MGMT', lvschema => NULL);

        ut.expect (INSTR (l_clob, 'CREATE OR REPLACE EDITIONABLE PACKAGE "SBS1_ADMIN"."TEST_PKG_CODE_MGMT"')).to_equal (4);

        ROLLBACK;
    END get_ddl;

    /* =========================================================================
       Test: [Test method get_ddl_file_name - get_ddl_file_name]].
       ---------------------------------------------------------------------- */

    PROCEDURE get_ddl_file_name
    IS
    BEGIN
        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => NULL, lvname => NULL, lvschema => NULL)).to_equal ('.');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'VIEW', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.vw');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'FUNCTION', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.fnc');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'PROCEDURE', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.prc');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'TRIGGER', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.trg');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'MATERIALIZED VIEW', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.sql');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'SEQUENCE', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.sql');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'SYNONYM', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.sql');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'TYPE', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.tps');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'TYPE BODY', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.tpb');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'PACKAGE', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.pks');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'PACKAGE BODY', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.pkb');

        ut.expect (pkg_code_mgmt.get_ddl_file_name (lvtype => 'UNKNOWN TYPE', lvname => 'My_Object', lvschema => NULL)).to_equal ('my_object.unknowntype');

        ROLLBACK;
    END get_ddl_file_name;

    /* =========================================================================
       Test: [Test method md5checksum - md5checksum]].
       ---------------------------------------------------------------------- */

    PROCEDURE md5checksum
    IS
    BEGIN
        ut.expect (pkg_code_mgmt.md5checksum (lvtype => NULL, lvname => NULL, lvschema => NULL)).to_equal ('ORA-31600');

        ut.expect (pkg_code_mgmt.md5checksum (lvtype => 'PACKAGE_SPEC', lvname => 'test_pkg_code_mgmt', lvschema => NULL)).to_equal ('ORA-31603');

        ut.expect (pkg_code_mgmt.md5checksum (lvtype => 'PACKAGE_SPEC', lvname => 'TEST_PKG_CODE_MGMT', lvschema => NULL)).to_equal ('4015E077481B5FA52DAC5568B5319B50');

        ROLLBACK;
    END md5checksum;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_code_mgmt;
/