CREATE OR REPLACE PACKAGE test_pkg_bdetail_smsc
IS
    /*<>
       Unit testing package pkg_bdetail_smsc.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       sp_cons_dgti.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_dgti_after)
    PROCEDURE sp_cons_dgti;

    PROCEDURE sp_cons_dgti_after;

    /* =========================================================================
       sp_cons_iwt.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_iwt_after)
    PROCEDURE sp_cons_iwt;

    PROCEDURE sp_cons_iwt_after;

    /* =========================================================================
       sp_cons_laa_mfgr.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_laa_mfgr_after)
    PROCEDURE sp_cons_laa_mfgr_a;

    PROCEDURE sp_cons_laa_mfgr_after;

    --%test
    --%aftertest(sp_cons_laa_mfgr_after)
    PROCEDURE sp_cons_laa_mfgr_b;

    /* =========================================================================
       sp_cons_lam_sms.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_lam_sms_after)
    PROCEDURE sp_cons_lam_sms;

    PROCEDURE sp_cons_lam_sms_after;

    /* =========================================================================
       sp_cons_lapmcc_sms.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_lapmcc_sms_after)
    PROCEDURE sp_cons_lapmcc_sms;

    PROCEDURE sp_cons_lapmcc_sms_after;

    /* =========================================================================
       sp_cons_lat_mfgr.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_lat_mfgr_after)
    PROCEDURE sp_cons_lat_mfgr_a;

    PROCEDURE sp_cons_lat_mfgr_after;

    --%test
    --%aftertest(sp_cons_lat_mfgr_after)
    PROCEDURE sp_cons_lat_mfgr_b;
--
--    --%test
--    --%aftertest(sp_cons_lat_mfgr_after)
--    PROCEDURE sp_cons_lat_mfgr_c;

END test_pkg_bdetail_smsc;
/