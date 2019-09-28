CREATE OR REPLACE PROCEDURE sbs1_admin.app_create_synonym (
    obj                                     IN VARCHAR2,
    src                                     IN VARCHAR2,
    dest                                    IN VARCHAR2,
    p_exec                                  IN NUMBER DEFAULT 1)
/* =========================================================================
   Wrapper procedure.
   ---------------------------------------------------------------------- */
IS
BEGIN
    pkg_adhoc.app_create_synonym (obj, src, dest, p_exec);
END app_create_synonym;
/
