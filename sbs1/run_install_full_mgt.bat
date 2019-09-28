@echo off
REM ----------------------------------------------------------------------------
REM
REM run_install_full_mgt.bat: SBSDB - full installation of the database software.
REM
REM ----------------------------------------------------------------------------

set USERNAME_SBSDB=sbs1_admin
set PASSWORD_SBSDB=t7GkAFQk7CFuEpdJ
set CONNECT_IDENTIFIER=SBSMGT1_RW

ECHO.
ECHO Skript %0 is now running
ECHO.
ECHO You can find the run log in the file run_install_full_mgt.log
ECHO.
ECHO Please wait ...
ECHO.

> run_install_full_mgt.log (

    ECHO =======================================================================
    ECHO Start %0
    ECHO -----------------------------------------------------------------------
    ECHO Installing SBSDB Schema - Swisscom Management Database.
    ECHO -----------------------------------------------------------------------
    ECHO USERNAME_SBSDB     : %USERNAME_SBSDB%
    ECHO CONNECT_IDENTIFIER : %CONNECT_IDENTIFIER%
    ECHO -----------------------------------------------------------------------
    ECHO:| TIME
    ECHO =======================================================================

    (
        echo @install/generated/sbsdb_schema_update_software.sql %USERNAME_SBSDB% %PASSWORD_SBSDB% %CONNECT_IDENTIFIER%
        echo @install/sbsdb_view_create.sql
        echo exit
    ) | sqlplus -s %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER%

    ECHO:| TIME
    ECHO -----------------------------------------------------------------------
    ECHO End   %0
    ECHO =======================================================================
)
