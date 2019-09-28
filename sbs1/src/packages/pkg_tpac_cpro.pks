CREATE OR REPLACE PACKAGE sbs1_admin.pkg_tpac_cpro
IS
    /*<>
    TODO.

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

    PROCEDURE gpsh_price_content_put (
        p_pme_pmvid                             IN VARCHAR2,
        p_pme_json                              IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_pme_pmvid - TODO.
          p_pme_json  - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.16    Created
        SS001        28.02.17    Deleting and inserting if the rows and size of the list dont match
        SS002        17.04.17    checking if the pmv_id exists if not integrity constraint error occurs
        SS003        28.01.18    PM content prepaid revenue not using nvl
        SS004        29.01.18    PM PME_AMOUNTMO removed nvl as ACU and SPO are required fields
        SS005        29.01.18    Checking difference between json and table using (A - B) <> 0 and (B - A) <> 0
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_model_put (
        p_pm_id                                 IN VARCHAR2,
        p_pm_json                               IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_pm_id   - TODO.
          p_pm_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.16    Created
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_transport_put (
        p_pmvt_pmvid                            IN VARCHAR2,
        p_pmvt_json                             IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_pmvt_pmvid - TODO.
          p_pmvt_json  - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.16    Created
        SS001        17.04.17    checking if the pmv_id exists if not integrity constraint error occurs
        SS002        05.05.17    Deleting and inserting if the rows and size of the list dont match
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_version_del (p_pmv_id IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_pmv_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           26.07.2016  Created
        */
                                                           ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_price_version_put (
        p_pmv_pmid                              IN VARCHAR2,
        p_pmv_id                                IN VARCHAR2,
        p_pmv_json                              IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_pmv_pmid - TODO.
          p_pmv_id   - TODO.
          p_pmv_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           25.07.2016  Created
        SO001        16.02.2017  Defaul NULL end Date to 01.01.2100
        SS002        17.04.17    checking if the pm_id exists if not integrity constraint error occurs
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_con_del (p_con_id IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_con_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           11.04.2016  Created
        */
                                                      ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_con_put (
        p_con_id                                IN VARCHAR2,
        p_con_json                              IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_con_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           11.04.2016  Created
        SO           18.04.2016  Added CON_SRCTYPE
        SS           25.07.2016  Added CON_SETOPT
        001SO        07.08.2016  Added CON_DATECRE, CON_DATEMOD attributes
        SS           11.01.2018  Removed CON_IGNORE_DUOBILL attribute
        002SS        15.02.2018  Removed CON_MFLID and added CON_PRICEPG
        003SO        15.11.2018  Remove CON_DEMO CON_PROTOCOL
        003SS        16.11.2018  Changed interface to accept json and added MWD paramters
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_cs_del (p_cs_id IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_cs_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           28.08.2016  Created
        */
                                                    ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_cs_put (
        p_con_id                                IN VARCHAR2,
        p_cs_id                                 IN VARCHAR2,
        p_con_json                              IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_cs_id    - TODO.
          p_con_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           28.08.16    Created
        SS           20.03.17    added ESID Check for update
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_del (p_ac_id IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_ac_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           24.02.2017  Created
        */
                                                 ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_keyword_del (p_con_id IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_con_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           28.08.2016  Created
        */
                                                          ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_keyword_put (
        p_con_id                                IN VARCHAR2,
        p_key_json                              IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_con_id   - TODO.
          p_key_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS001        28.09.2016  Created
        SO002        28.09.2016  Counter datatypes and comparison changed
        SS003        05.05.2017  Checking the count of input and data in db before comparing values
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_longid_map_del (
        p_longm_longid1                         IN VARCHAR2,
        p_longm_longid2                         IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_longm_longid1 - TODO.
          p_longm_longid2 - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           21.06.2017  Created
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_longid_map_put (p_longid_json IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_longid_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SO           25.04.2016  Created
        SO           21.06.2017  Deletion added (to be converted to use JSON)
        SS           22.06.2017  Using JSON input
        */
                                                                  ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_tpac_put (
        p_ac_id                                 IN VARCHAR2,
        p_ac_json                               IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_ac_id   - TODO.
          p_ac_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           24.02.2017  Created
        SS           25.07.2017  Added MBUNIT
        */
                                                            ;
END pkg_tpac_cpro;
/
