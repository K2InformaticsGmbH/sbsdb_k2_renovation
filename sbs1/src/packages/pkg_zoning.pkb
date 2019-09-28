CREATE OR REPLACE PACKAGE BODY sbs1_admin.pkg_zoning
IS
    /* =========================================================================
       Private Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Declaration.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_zone_id_msc (
        p_bd_srctype                            IN     VARCHAR2,
        p_bd_demo                               IN     NUMBER,
        p_cdrtype                               IN     VARCHAR2, -- in case of MSC: originating/terminating CDR
        p_msisdna                               IN     VARCHAR2,
        p_msisdnb                               IN     VARCHAR2,
        p_imsi                                  IN     VARCHAR2,
        p_zoneid                                IN OUT VARCHAR2,
        p_zonecode                              IN OUT VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER);

    /* =========================================================================
       Public Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Public Procedure Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Function Implementation.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Private Procedure Implementation.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_get_zone_id_msc (
        p_bd_srctype                            IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_bd_demo                               IN     NUMBER, -- TODO unused parameter? (wwe)
        p_cdrtype                               IN     VARCHAR2, -- in case of MSC: originating/terminating CDR
        p_msisdna                               IN     VARCHAR2, -- TODO unused parameter? (wwe)
        p_msisdnb                               IN     VARCHAR2,
        p_imsi                                  IN     VARCHAR2,
        p_zoneid                                IN OUT VARCHAR2, -- TODO looks very odd (wwe)
        p_zonecode                              IN OUT VARCHAR2,
        errorcode                                  OUT NUMBER,
        errormsg                                   OUT VARCHAR2,
        returnstatus                            IN OUT NUMBER) -- TODO looks very odd (wwe)
    IS
    BEGIN
        returnstatus := 1;

        IF p_msisdnb <= 8
        THEN
            p_zonecode := 'VAS-SCM';
        ELSIF    (p_imsi LIKE '22801%')
              OR (p_imsi NOT LIKE '22801%')
              OR (p_cdrtype = 'MSC-MT')
        THEN
            p_zonecode := 'RAW';
        ELSIF p_msisdnb NOT LIKE '41%'
        THEN
            p_zonecode := 'SMS-INT';
        ELSE
            p_zonecode := 'SMS-NAT';
        END IF;

        SELECT zn_id
        INTO   p_zoneid
        FROM   zone
        WHERE  zn_code = p_zonecode;

        IF SQL%NOTFOUND
        THEN
            p_zoneid := NULL;
            returnstatus := 0;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            errorcode := SQLCODE;
            errormsg := SQLERRM;
            returnstatus := 0;
            p_zoneid := NULL;
    END sp_get_zone_id_msc;
END pkg_zoning;
/