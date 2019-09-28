CREATE OR REPLACE PACKAGE sbs1_admin.pkg_zoning
IS
    /*<>
    Contains all the ZONE-related function and procedures.
    
    This procedure applies the Zoning rules to the input data and returns the ZONE
    
    
        -- Start template for smsc zone lookup -------
        PROCEDURE sp_get_zone_id_smsc
        IS
        BEGIN
            NULL;
        EXCEPTION
            WHEN OTHERS
            THEN
                errorcode := SQLCODE;
                errormsg := SQLERRM;
                returnstatus := 0;
                p_zoneid := NULL;
        END sp_get_zone_id_smsc;
        -- End  template for smsc zone lookup -------
    
    
    Called from:
        PKG_BDETAIL_MSC.SP_INSERT_MSC
    
    MODIFICATION HISTORY
    Person      Date         Comments
    AA           03.06.2002  created the package and procedure (SP_GET_ZONE_ID)
    000SO        13.02.2019  HASH:15B9FD10CA8E0A55730E81382ECE04F4 pkg_zoning.pkb
    */

/* =========================================================================
   Public Function Declaration.
   ---------------------------------------------------------------------- */

/* =========================================================================
   Public Procedure Declaration.
   ---------------------------------------------------------------------- */

END pkg_zoning;
/
