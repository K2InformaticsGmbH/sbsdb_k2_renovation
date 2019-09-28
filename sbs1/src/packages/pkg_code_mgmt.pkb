CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_code_mgmt
IS
    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION get_ddl (
        lvtype                                  IN VARCHAR2,
        lvname                                  IN VARCHAR2,
        lvschema                                IN VARCHAR2)
        RETURN CLOB
    IS
        code                                    CLOB;
    BEGIN
        code := DBMS_METADATA.get_ddl (lvtype, lvname, lvschema);
        RETURN code;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN TO_CLOB ('ORA' || SQLCODE);
    END get_ddl;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION get_ddl_file_name (
        lvtype                                  IN VARCHAR2,
        lvname                                  IN VARCHAR2,
        lvschema                                IN VARCHAR2) -- TODO unused parameter? (wwe)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE lvtype
                   WHEN 'VIEW'
                   THEN
                       LOWER (lvname) || '.vw'
                   WHEN 'FUNCTION'
                   THEN
                       LOWER (lvname) || '.fnc'
                   WHEN 'PROCEDURE'
                   THEN
                       LOWER (lvname) || '.prc'
                   WHEN 'TRIGGER'
                   THEN
                       LOWER (lvname) || '.trg'
                   WHEN 'MATERIALIZED VIEW'
                   THEN
                       LOWER (lvname) || '.sql'
                   WHEN 'SEQUENCE'
                   THEN
                       LOWER (lvname) || '.sql'
                   WHEN 'SYNONYM'
                   THEN
                       LOWER (lvname) || '.sql'
                   WHEN 'TYPE'
                   THEN
                       LOWER (lvname) || '.tps'
                   WHEN 'TYPE BODY'
                   THEN
                       LOWER (lvname) || '.tpb'
                   WHEN 'PACKAGE'
                   THEN
                       LOWER (lvname) || '.pks'
                   WHEN 'PACKAGE BODY'
                   THEN
                       LOWER (lvname) || '.pkb'
                   ELSE
                       LOWER (lvname) || '.' || LOWER (REPLACE (lvtype, ' '))
               END;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN LOWER (lvname) || '.' || LOWER (REPLACE (lvtype, ' '));
    END get_ddl_file_name;

    /* =========================================================================
        TODO.
        ---------------------------------------------------------------------- */

    FUNCTION md5checksum (
        lvtype                                  IN VARCHAR2,
        lvname                                  IN VARCHAR2,
        lvschema                                IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN DBMS_CRYPTO.hash (DBMS_METADATA.get_ddl (lvtype, lvname, lvschema), DBMS_CRYPTO.hash_md5);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'ORA' || SQLCODE;
    END md5checksum;
/* =========================================================================
   Public Procedure Implementation.
   ---------------------------------------------------------------------- */

END pkg_code_mgmt;
/