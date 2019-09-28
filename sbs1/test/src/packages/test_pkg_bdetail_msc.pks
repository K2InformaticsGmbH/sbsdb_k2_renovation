CREATE OR REPLACE PACKAGE test_pkg_bdetail_msc
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
       sp_try_msccu.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_try_msccu_after)
    PROCEDURE sp_try_msccu;

    PROCEDURE sp_try_msccu_after;

    --%test
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE sp_try_msccu_1008;
END test_pkg_bdetail_msc;
/