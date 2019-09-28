@echo off

rem ----------------------------------------------------------------------------
rem
rem run_install_full.bat: SBSDB - full installation of the database software.
rem
rem ----------------------------------------------------------------------------

if "%1"=="" (
    set /P PASSWORD_SYS="Enter SYS password "
    set /P PASSWORD_SBSDB="Enter SBSDB password "
    set /P CONNECT_IDENTIFIER="Enter connect identifier "
) else (
    set PASSWORD_SYS=%1
    set PASSWORD_SBSDB=%2
    set CONNECT_IDENTIFIER=%3
)

set USERNAME_SBSDB=sbs1_admin

echo.
echo Skript %0 is now running
echo.
echo You can find the run log in the file run_install_full.log
echo.
echo Please wait ...
echo.

> run_install_full.log (

    echo =======================================================================
    echo Start %0
    echo -----------------------------------------------------------------------
    echo Installing SBSDB Schema
    echo -----------------------------------------------------------------------
    echo USERNAME_SBSDB     : %USERNAME_SBSDB%
    echo CONNECT_IDENTIFIER : %CONNECT_IDENTIFIER%
    echo -----------------------------------------------------------------------
    echo:| TIME
    echo =======================================================================

    (
        echo @install/sbsdb_schema_create.sql %USERNAME_SBSDB% %PASSWORD_SBSDB%
        echo @install/generated/sbsdb_schema_update_privileges.sql %USERNAME_SBSDB% %PASSWORD_SBSDB% %CONNECT_IDENTIFIER%
        echo @install/generated/sbsdb_schema_update_software.sql %USERNAME_SBSDB% %PASSWORD_SBSDB% %CONNECT_IDENTIFIER%
        echo @install/sbsdb_view_create.sql
        echo EXECUTE sys.UTL_RECOMP.recomp_serial;
        echo exit
    ) | sqlplus -s sys/%PASSWORD_SYS%@%CONNECT_IDENTIFIER% as sysdba

    echo:| TIME
    echo -----------------------------------------------------------------------
    echo End   %0
    echo =======================================================================
)
