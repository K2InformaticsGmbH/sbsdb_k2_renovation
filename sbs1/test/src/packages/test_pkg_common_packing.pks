CREATE OR REPLACE PACKAGE test_pkg_common_packing
IS
    /*<>
       Unit testing package pkg_common_packing.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       getpackingcandidatefortype.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(getpackingcandidatefortype_aft)
    PROCEDURE getpackingcandidatefortype;

    PROCEDURE getpackingcandidatefortype_aft;

    /* =========================================================================
       getpackingparameter.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(getpackingparameter_after)
    PROCEDURE getpackingparameter;

    --%test
    --%throws(pkg_common_packing.excp_missing_packing_par)
    PROCEDURE getpackingparameter_1008;

    PROCEDURE getpackingparameter_after;

    /* =========================================================================
       gettypeforpacking.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(gettypeforpacking_after)
    PROCEDURE gettypeforpacking;

    --%test
    --%throws(no_data_found)
    PROCEDURE gettypeforpacking_1403;

    PROCEDURE gettypeforpacking_after;

    /* =========================================================================
       insert_boheader.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(insert_boheader_after)
    PROCEDURE insert_boheader_a;

    PROCEDURE insert_boheader_after;

    --%test
    --%aftertest(insert_boheader_after)
    PROCEDURE insert_boheader_b;

    --%test
    --%aftertest(insert_boheader_after)
    PROCEDURE insert_boheader_c;

    --%test
    --%aftertest(insert_boheader_after)
    PROCEDURE insert_boheader_d;

    --%test
    --%aftertest(insert_boheader_after)
    --%throws(pkg_common.excp_inconvenient_time)
    PROCEDURE insert_boheader_1003_a;

    --%test
    --%aftertest(insert_boheader_after)
    --%throws(pkg_common.excp_inconvenient_time)
    PROCEDURE insert_boheader_1003_c;

    /* =========================================================================
       insert_boheader_sptry.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(insert_boheader_sptry_after)
    PROCEDURE insert_boheader_sptry;

    PROCEDURE insert_boheader_sptry_after;

    /* =========================================================================
       istimeforpacking.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_a;

    PROCEDURE istimeforpacking_after;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_b;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_c;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_d;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_e;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_f;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_g;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_h;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_i;

    --%test
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_k;

    --%test
    --%throws(no_data_found)
    --%aftertest(istimeforpacking_after)
    PROCEDURE istimeforpacking_1403;

    /* =========================================================================
       modify_boheader.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(modify_boheader_after)
    PROCEDURE modify_boheader;

    PROCEDURE modify_boheader_after;

    --%test
    --%throws(pkg_common.excp_missing_header_fld)
    PROCEDURE modify_boheader_1005;

    /* =========================================================================
       setstringtagstolowercase.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE setstringtagstolowercase;

    /* =========================================================================
       sp_get_next_pac_seq.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_get_next_pac_seq_after)
    PROCEDURE sp_get_next_pac_seq;

    PROCEDURE sp_get_next_pac_seq_after;

    /* =========================================================================
       sp_insert_header.
       ---------------------------------------------------------------------- */

    --%test
    PROCEDURE sp_insert_header_a;

    PROCEDURE sp_insert_header_after;

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header_b;

    /* =========================================================================
       update_boheader.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(update_boheader_after)
    PROCEDURE update_boheader;

    PROCEDURE update_boheader_after;
END test_pkg_common_packing;
/