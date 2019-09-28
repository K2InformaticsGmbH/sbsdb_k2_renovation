CREATE OR REPLACE PACKAGE test_pkg_common_mapping
IS
    /*<>
       Unit testing package pkg_common_mapping.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite
    --%rollback(manual)

    /* =========================================================================
       getsrctypeforbiheader.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(getsrctypeforbiheader_after)
    PROCEDURE getsrctypeforbiheader;

    PROCEDURE getsrctypeforbiheader_after;

    /* =========================================================================
       gettypeformapping.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(gettypeformapping_after)
    PROCEDURE gettypeformapping;

    PROCEDURE gettypeformapping_after;

    /* =========================================================================
       insert_biheader.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(insert_biheader_after)
    PROCEDURE insert_biheader;

    --%test
    --%aftertest(insert_biheader_after)
    --%throws(PKG_COMMON.excp_rdy_err_header_found)
    PROCEDURE insert_biheader_1001;

    --%test
    --%aftertest(insert_biheader_after)
    --%throws(PKG_COMMON.excp_rdy_err_many_retries)
    PROCEDURE insert_biheader_1002;

    --%test
    --%throws(PKG_COMMON.excp_inconvenient_time)
    PROCEDURE insert_biheader_1003;

    PROCEDURE insert_biheader_after;

    /* =========================================================================
       istimeformapping.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(istimeformapping_after)
    PROCEDURE istimeformapping;

    PROCEDURE istimeformapping_after;

    /* =========================================================================
       sp_insert_header.
       ---------------------------------------------------------------------- */

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header;

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header_1001;

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header_1002;

    --%test
    --%aftertest(sp_insert_header_after)
    PROCEDURE sp_insert_header_1003;

    PROCEDURE sp_insert_header_after;
END test_pkg_common_mapping;
/
