CREATE OR REPLACE PACKAGE sbs1_admin.pkg_kpi_bd
IS
    /*<>
    Implementation of the KPI calculation for the KPIs KPI000 to KPI999.

    MODIFICATION HISTORY
    Person   Date        Comments
    001SO    15.11.2017  Create for Project SBS-17.08 Technical_Application_KPI_Plotter
    000SO    13.02.2019  HASH:1C78C9E9BD2632A6331BC08A4791F294 pkg_kpi_bd.pkb
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    /* =========================================================================
       TODO.
       ---------------------------------------------------------------------- */

    PROCEDURE sp_try_kpi (
        sqlt_str_pacid                          IN     VARCHAR2,
        sqlt_str_bohid                          IN OUT VARCHAR2,
        sqlt_int_records                           OUT NUMBER,
        sqlt_int_error                             OUT NUMBER,
        sqlt_str_errormsg                          OUT VARCHAR2,
        sqlt_int_retstatus                         OUT NUMBER) /*<>
    TODO.

    Input Parameter:
      sqlt_str_pacid - the name of the desired KPI - must be between KPI000 and KPI999.
      sqlt_str_bohid - TODO.

    Output Parameter:
      sqlt_str_bohid     - TODO.
      sqlt_int_records   - the number of data records processed.
      sqlt_int_error     - error code:
                           ok  - 0
                           nok - others
      sqlt_str_errormsg  - error message:
                           ok  - NULL
                           nok - others
      sqlt_int_retstatus - return status:
                           ok  - pkg_common.return_status_ok
                           nok - others

    Restrictions:
      - TODO.
    */
                                                              ;
END pkg_kpi_bd;
/
