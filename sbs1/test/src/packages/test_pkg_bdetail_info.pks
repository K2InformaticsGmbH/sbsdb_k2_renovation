CREATE OR REPLACE PACKAGE test_pkg_bdetail_info
IS
    /*<>
       Unit testing package pkg_bdetail_info.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       sp_cons_is.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_is_after)
    PROCEDURE sp_cons_is;

    PROCEDURE sp_cons_is_after;

    /* =========================================================================
       sp_cons_ismsisdn.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_ismsisdn_after)
    PROCEDURE sp_cons_ismsisdn;

    PROCEDURE sp_cons_ismsisdn_after;

    /* =========================================================================
       sp_cons_tr.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_tr_after)
    PROCEDURE sp_cons_tr;

    PROCEDURE sp_cons_tr_after;
END test_pkg_bdetail_info;
/