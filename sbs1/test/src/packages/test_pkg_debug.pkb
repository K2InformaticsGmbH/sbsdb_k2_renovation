CREATE OR REPLACE PACKAGE BODY test_pkg_debug
IS
    gc_is_del_all                           BOOLEAN := TRUE;

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Test: [Test method debug_reva - debug_reva]].
       ---------------------------------------------------------------------- */

    PROCEDURE debug_reva
    IS
        l_reva_debug                            reva_debug%ROWTYPE;
    BEGIN
        l_reva_debug.bih_id := 'ut_id_a';
        l_reva_debug.boh_id := 'ut_id_a';
        l_reva_debug.hint := 'ut_hint_a';
        l_reva_debug.reccount := 12345;
        l_reva_debug.revah_id := 'ut_id_a';

        pkg_debug.debug_reva (
            lbih_id                              => l_reva_debug.bih_id,
            lboh_id                              => l_reva_debug.boh_id,
            lrevah_id                            => l_reva_debug.revah_id,
            lreccount                            => l_reva_debug.reccount,
            what                                 => 'update',
            lhint                                => l_reva_debug.hint);

        pkg_debug.debug_reva (
            lbih_id                              => l_reva_debug.bih_id,
            lboh_id                              => l_reva_debug.boh_id,
            lrevah_id                            => l_reva_debug.revah_id,
            lreccount                            => l_reva_debug.reccount,
            what                                 => 'start',
            lhint                                => l_reva_debug.hint);
    END debug_reva;

    PROCEDURE debug_reva_after
    IS
    BEGIN
        test_data.del_reva_debug ();

        IF gc_is_del_all
        THEN
            test_data.del_all (p_is_debug_rows_all => TRUE);
        END IF;
    END debug_reva_after;
/* ==========================================================================
   Initializing Package.
   ----------------------------------------------------------------------- */
BEGIN
    DBMS_OUTPUT.enable (buffer_size => NULL);
END test_pkg_debug;
/
