CREATE OR REPLACE PACKAGE test_pkg_bdetail_mmsc
IS
    /*<>
       Unit testing package pkg_bdetail_mmsc.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       sp_cons_lam_mms.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_lam_mms_after)
    PROCEDURE sp_cons_lam_mms;

    PROCEDURE sp_cons_lam_mms_after;

    --%test
    --%aftertest(sp_cons_lam_mms_after)
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE sp_cons_lam_mms_1008;

    /* =========================================================================
       sp_cons_lapmcc_mms.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE sp_cons_lapmcc_mms;

    /* =========================================================================
       sp_cons_lat_mms.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_lat_mms_after)
    PROCEDURE sp_cons_lat_mms_a;

    PROCEDURE sp_cons_lat_mms_after;

    --%test
    --%aftertest(sp_cons_lat_mms_after)
    PROCEDURE sp_cons_lat_mms_b;

    --%test
    --%aftertest(sp_cons_lat_mms_after)
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE sp_cons_lat_mms_1008;

    /* =========================================================================
       sp_cons_lit_mms.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_lit_mms_after)
    PROCEDURE sp_cons_lit_mms_a;

    PROCEDURE sp_cons_lit_mms_after;

    --%test
    --%aftertest(sp_cons_lit_mms_after)
    PROCEDURE sp_cons_lit_mms_b;

    --%test
    --%aftertest(sp_cons_lit_mms_after)
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE sp_cons_lit_mms_1008;

    /* =========================================================================
       sp_cons_mmsc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_mmsc_after)
    PROCEDURE sp_cons_mmsc;

    PROCEDURE sp_cons_mmsc_after;

    /* =========================================================================
       sp_try_laa_mmsc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_try_laa_mmsc_after)
    PROCEDURE sp_try_laa_mmsc_a;

    PROCEDURE sp_try_laa_mmsc_after;

    --%test
    --%aftertest(sp_try_laa_mmsc_after)
    PROCEDURE sp_try_laa_mmsc_b;

    --%test
    --%aftertest(sp_try_laa_mmsc_after)
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE sp_try_laa_mmsc_1008;

    /* =========================================================================
       sp_try_lia_mmsc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_try_lia_mmsc_after)
    PROCEDURE sp_try_lia_mmsc_a;

    PROCEDURE sp_try_lia_mmsc_after;

    --%test
    --%aftertest(sp_try_lia_mmsc_after)
    PROCEDURE sp_try_lia_mmsc_b;

    --%test
    --%aftertest(sp_try_lia_mmsc_after)
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE sp_try_lia_mmsc_1008;
END test_pkg_bdetail_mmsc;
/