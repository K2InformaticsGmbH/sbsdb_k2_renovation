CREATE OR REPLACE PACKAGE test_pkg_bdetail_settlement
IS
    /*<>
       Unit testing package pkg_bdetail_settlement.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       nextavailableorder.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(nextavailableorder_after)
    PROCEDURE nextavailableorder;

    PROCEDURE nextavailableorder_after;

    /* =========================================================================
       settledduration.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE settledduration;

    /* =========================================================================
       sp_add_setdetail.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_add_setdetail_after)
    PROCEDURE sp_add_setdetail;

    --%test
    --%throws(-1403)
    PROCEDURE sp_add_setdetail_01403;

    PROCEDURE sp_add_setdetail_after;

    /* =========================================================================
       sp_add_setdetail_by_date.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_add_setdetail_by_date_after)
    PROCEDURE sp_add_setdetail_by_date;

    --%test
    --%throws(-1403)
    PROCEDURE sp_add_setdetail_by_date_01403;

    PROCEDURE sp_add_setdetail_by_date_after;

    /* =========================================================================
       sp_cons_insert_period.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE sp_cons_insert_period;

    /* =========================================================================
       sp_lam_mcc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_lam_mcc_after)
    PROCEDURE sp_lam_mcc_a;

    PROCEDURE sp_lam_mcc_after;

    --%test
    --%aftertest(sp_lam_mcc_after)
    PROCEDURE sp_lam_mcc_b;

    --%test
    --%aftertest(sp_lam_mcc_after)
    PROCEDURE sp_lam_mcc_c;

    --%test
    --%aftertest(sp_lam_mcc_after)
    PROCEDURE sp_lam_mcc_d;

    /* =========================================================================
       sp_lapmcc.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_lapmcc_after)
    PROCEDURE sp_lapmcc_a;

    PROCEDURE sp_lapmcc_after;

    --%test
    --%aftertest(sp_lapmcc_after)
    PROCEDURE sp_lapmcc_b;

    /* =========================================================================
       sp_lat_cdr.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_lat_cdr_after)
    PROCEDURE sp_lat_cdr_a;

    PROCEDURE sp_lat_cdr_after;

    --%test
    --%aftertest(sp_lat_cdr_after)
    PROCEDURE sp_lat_cdr_b;

    /* =========================================================================
       sp_lit_cdr.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_lit_cdr_after)
    PROCEDURE sp_lit_cdr_a;

    PROCEDURE sp_lit_cdr_after;

    --%test
    --%aftertest(sp_lit_cdr_after)
    PROCEDURE sp_lit_cdr_b;
END test_pkg_bdetail_settlement;
/