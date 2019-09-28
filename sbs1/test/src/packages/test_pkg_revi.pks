CREATE OR REPLACE PACKAGE test_pkg_revi
IS
    /*<>
       Unit testing package pkg_revi.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       revi_index_file.
       ---------------------------------------------------------------------- */

    PROCEDURE revi_index_file_after;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_content_a;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_content_b;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_content_c;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_content_d;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_content_e;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_content_f;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_mms;

    --%test
    --%throws(-14400)
    PROCEDURE revi_index_file_mms_14400;

    --%test
    --%aftertest(revi_index_file_after)
    PROCEDURE revi_index_file_sms;

    --%test
    --%throws(-14400)
    PROCEDURE revi_index_file_sms_14400;

    /* =========================================================================
       sp_cons_revicd.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_revicd_after)
    PROCEDURE sp_cons_revicd_a;

    PROCEDURE sp_cons_revicd_after;

    --%test
    --%aftertest(sp_cons_revicd_after)
    PROCEDURE sp_cons_revicd_b;

    --%test
    --%aftertest(sp_cons_revicd_after)
    PROCEDURE sp_cons_revicd_c;

    --%test
    --%aftertest(sp_cons_revicd_after)
    PROCEDURE sp_cons_revicd_d;

    --%test
    --%aftertest(sp_cons_revicd_after)
    PROCEDURE sp_cons_revicd_e;

    --%test
    PROCEDURE sp_cons_revicd_f;

    /* =========================================================================
       sp_cons_revics.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_revics_after)
    PROCEDURE sp_cons_revics_a;

    PROCEDURE sp_cons_revics_after;

    --%test
    --%aftertest(sp_cons_revics_after)
    PROCEDURE sp_cons_revics_b;

    --%test
    --%aftertest(sp_cons_revics_after)
    PROCEDURE sp_cons_revics_c;

    --%test
    --%aftertest(sp_cons_revics_after)
    PROCEDURE sp_cons_revics_d;

    --%test
    --%aftertest(sp_cons_revics_after)
    PROCEDURE sp_cons_revics_e;

    --%test
    --%throws(-2149)
    PROCEDURE sp_cons_revics_02149;

    /* =========================================================================
       sp_cons_revim.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_revim_after)
    PROCEDURE sp_cons_revim_a;

    PROCEDURE sp_cons_revim_after;

    --%test
    --%aftertest(sp_cons_revim_after)
    PROCEDURE sp_cons_revim_e;

    --%test
    --%throws(-2149)
    PROCEDURE sp_cons_revim_02149;

    /* =========================================================================
       sp_cons_revipre.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_revipre_after)
    PROCEDURE sp_cons_revipre_a;

    PROCEDURE sp_cons_revipre_after;

    --%test
    --%aftertest(sp_cons_revipre_after)
    PROCEDURE sp_cons_revipre_b;

    --%test
    --%aftertest(sp_cons_revipre_after)
    PROCEDURE sp_cons_revipre_e;

    --%test
    --%throws(-2149)
    PROCEDURE sp_cons_revipre_02149;

    /* =========================================================================
       sp_cons_reviprm.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_reviprm_after)
    PROCEDURE sp_cons_reviprm_a;

    PROCEDURE sp_cons_reviprm_after;

    --%test
    --%aftertest(sp_cons_reviprm_after)
    PROCEDURE sp_cons_reviprm_e;

    --%test
    --%throws(-2149)
    PROCEDURE sp_cons_reviprm_02149;

    /* =========================================================================
       sp_cons_reviprs.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_reviprs_after)
    PROCEDURE sp_cons_reviprs_a;

    PROCEDURE sp_cons_reviprs_after;

    --%test
    --%aftertest(sp_cons_reviprs_after)
    PROCEDURE sp_cons_reviprs_e;

    --%test
    --%throws(-2149)
    PROCEDURE sp_cons_reviprs_02149;

    /* =========================================================================
       sp_cons_revis.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_cons_revis_after)
    PROCEDURE sp_cons_revis_a;

    PROCEDURE sp_cons_revis_after;

    --%test
    --%aftertest(sp_cons_revis_after)
    PROCEDURE sp_cons_revis_e;

    --%test
    --%throws(-2149)
    PROCEDURE sp_cons_revis_02149;
END test_pkg_revi;
/