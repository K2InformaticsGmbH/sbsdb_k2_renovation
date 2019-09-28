CREATE OR REPLACE PACKAGE sbs1_admin.pkg_toac_cpro
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

    PROCEDURE gpsh_currency_exr_del (
        p_exr_curid                             IN VARCHAR2,
        p_exr_start                             IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_exr_curid - TODO.
          p_exr_start - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           10.08.2016  Created
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_currency_exr_put (
        p_cur_id                                IN VARCHAR2,
        p_exr_json                              IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_cur_id   - TODO.
          p_exr_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           10.08.16    Created
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_currency_put (p_cur_json IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_cur_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           10.08.16    Created
        */
                                                        ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_con_del (p_con_id IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_con_id - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           21.07.2016  Created
        */
                                                      ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_con_put (
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
        SS           21.07.2016    Created
        SS           22.07.2016    Added Name, Opkey, json into contract
        001SO        11.11.2016    Re-Implement table difference with set operations
        002SS        11.11.2016    Fixed bad condition fir MMS prices
        003S0        26.05.2017    Fill in / fix minimum message sizes for MMS transport Prices
        004SO        07.08.2016    Added CON_DATECRE, CON_DATEMOD attributes
        005SS        11.10.2017    changed the VATO and VATT number precision
        006SO        15.11.2018    Remove CON_DEMO and CON_COMMENT
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_smsc_del (
        p_smsc_code                             IN VARCHAR2,
        p_smsc_conopkey                         IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_smsc_code     - TODO.
          p_smsc_conopkey - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           05.10.2017  Created
        */
                                                            ;

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE gpsh_toac_smsc_put (
        p_conop_key                             IN VARCHAR2,
        p_smsc_json                             IN VARCHAR2) /*<>
        TODO.

        Input Parameter:
          p_conop_key - TODO.
          p_smsc_json - TODO.

        Restrictions:
          - TODO.

        MODIFICATION HISTORY
        ---------    ------      -------------------------------------------
        Person       Date        Comments
        SS           05.10.17    Created
        */
                                                            ;
END pkg_toac_cpro;
/
