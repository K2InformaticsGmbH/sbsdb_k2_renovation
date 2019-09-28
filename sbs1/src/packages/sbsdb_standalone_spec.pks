CREATE OR REPLACE PACKAGE sbsdb_standalone_spec
IS
    /*<>
    Specification package for standalone methods.

    This package consists only of the package specification. It is used for
    standalone functions and procedures to support the annotation and API
    documentation mechanisms.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Functions.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Procedures.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE configure_for_test /*<>
        TODO.

        Restrictions:
          - TODO.

        -- MODIFICATION HISTORY
        -- ---------    ------      -------------------------------------------
        -- Person       Date        Comments
        -- SO           06.11.2006  Created
        -- SO           27.10.2008  Remove MMSVAS Provisioning sections
        -- SO           27.10.2008  Add MMSC Provisioning sections
        -- SO           27.10.2008  Add SMCH30, CMCH80, SMCH90
        -- 001SO        15.07.2010  Reset Cleanup and refresh
        -- 002SO        09.07.2010  Enabling test Mapping for SMCH30
        -- 003SO        25.08.2010  Adapt to new NAS paths
        -- 004SO        01.03.2012  Remove S B S 0 and CAT Code
        -- 005SO        19.03.2012  Correct MUS eMail Address
        -- 006SO        12.07.2012  Adapt to Exadata environment
        -- 007SO        08.01.2014  Truncate log and debug tables
        -- 008SO        08.01.2014  Delete provisioning states for production platforms
        -- 009SO        08.04.2014  Correct NAS paths for production and test
        -- 010SO        18.07.2016  Changes brought in with Ora12c tests
        -- 011SO        17.01.2018  Point to new NAS path
        -- 012SO        17.10.2018  Remove REFERENCES to ENPLA
        */
                                ;
END sbsdb_standalone_spec;
/
