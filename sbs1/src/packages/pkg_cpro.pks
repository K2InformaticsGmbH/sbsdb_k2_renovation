CREATE OR REPLACE PACKAGE sbs1_admin.pkg_cpro
IS
    /*<>
    TODO.

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Function Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       Return The Adr_Id of a new tpac address.
       ---------------------------------------------------------------------- */

    FUNCTION gpsh_tpac_new_adr_id (
        p_adr_email                             IN VARCHAR2,
        p_adr_invoiceemail                      IN NUMBER DEFAULT 0,
        p_adr_statisticsmail                    IN NUMBER DEFAULT 0)
        RETURN VARCHAR2 /*<>
    Return The Adr_Id of a new tpac address.

    Input Parameter:
      p_adr_email          - TODO.
      p_adr_invoiceemail   - TODO.
      p_adr_statisticsmail - TODO.

    Return Parameter:
      Adr_Id of a tpac address.

    Restrictions:
      - TODO.

    Modification History
    Person       Date        Comments
    ----------   ----------  -------------------------------------------
    SO           11.04.2016  Initial version
    */
                       ;

    /* =========================================================================
       To generate contentservice JSON value (sbsgui like) for the corresponding
       to contract id and cs id.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_content_service_json (p_cs_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    To generate contentservice JSON value (sbsgui like) for the corresponding
    to contract id and cs id.

    Input Parameter:
      p_cs_id - TODO.

    Return Parameter:
      Contentservice JSON value.

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          14.10.16 Created
    */
                       ;

    /* =========================================================================
       To generate JSON value (sbsgui like) for the corresponding currency key.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_currency_json (p_cur_key IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    To generate JSON value (sbsgui like) for the corresponding currency key.

    Input Parameter:
      p_cur_key - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          17.8.16 Created
    SS          04.8.17 Added ID to the exchangerate vlaue
    */
                       ;

    /* =========================================================================
       To generate keyword JSON value (sbsgui like) for the corresponding to
       contract id.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_keyword_json (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    To generate keyword JSON value (sbsgui like) for the corresponding to
    contract id.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          14.10.16 Created
    */
                       ;

    /* =========================================================================
       To generate JSON value (sbsgui like) for the corresponding price key.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_price_json (p_price_key IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    To generate JSON value (sbsgui like) for the corresponding price key.

    Input Parameter:
      p_price_key - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          17.08.2016 Created
    SO001       16.02.2017 NULL PM Version End Date if 01.01.2100
    SS002       28.02.2017 PM version return "" instead of null
    SS003       28.01.2018 PM content prepaid revenue not using nvl
    */
                       ;

    /* =========================================================================
       To generate toac smsc JSON value (sbsgui like).
       ---------------------------------------------------------------------- */

    FUNCTION gpull_toac_smsc_json (p_smsc_code IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    To generate toac smsc JSON value (sbsgui like).

    Input Parameter:
      p_smsc_code - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          04.10.17 Created
    */
                       ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_tocon_json (p_con_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    TODO.

    Input Parameter:
      p_con_id - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person   Date        Comments
    -------- ----------  -------------------------------------------
    001SO    15.11.2018  Remove reference to CON_COMMENT
    */
                       ;

    /* =========================================================================
       To generate tpac JSON value (sbsgui like) for the corresponding to
       account id.
       ---------------------------------------------------------------------- */

    FUNCTION gpull_tpac_json (p_ac_id IN VARCHAR2)
        RETURN VARCHAR2 /*<>
    To generate tpac JSON value (sbsgui like) for the corresponding to account id.

    Input Parameter:
      p_ac_id - TODO.

    Return Parameter:
      JSON value (sbsgui like).

    Restrictions:
      - TODO.

    MODIFICATION HISTORY
    Person      Date    Comments
    ---------   ------  -------------------------------------------
    SS          24.02.17 Created
    001SS       24.07.17 MBUNIT added
    */
                       ;
/* =========================================================================
   Public Procedure Declaration.
   ---------------------------------------------------------------------- */

END pkg_cpro;
/
